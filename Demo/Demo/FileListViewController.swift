//
//  FileListViewController.swift
//  Demo
//
//  Created by zhaixian on 2023/11/24.
//

import UIKit
import AliyunpanSDK
import AVKit

extension AliyunpanFile: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: AliyunpanFile, rhs: AliyunpanFile) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension DownloadResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(progress)
        hasher.combine(url)
    }
    
    public static func == (lhs: DownloadResult, rhs: DownloadResult) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct DisplayFile: Hashable {
    let originFile: AliyunpanFile
    let downloadResult: DownloadResult?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(originFile)
        hasher.combine(downloadResult)
    }
    
    public static func == (lhs: DisplayFile, rhs: DisplayFile) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class FileListViewController: UIViewController {
    // swiftlint:disable force_cast
    private var client: AliyunpanClient {
        return (UIApplication.shared.delegate as! AppDelegate).client
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, DisplayFile> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayFile> { cell, indexPath, file in
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.text = file.originFile.name
            cell.contentConfiguration = contentConfiguration
            
            let downloadButton = UIButton()
            downloadButton.addTarget(self, action: #selector(self.download(_:)), for: .touchUpInside)
            downloadButton.tag = 10000 + indexPath.row
            downloadButton.setTitleColor(.black, for: .normal)
            downloadButton.titleLabel?.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            downloadButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            let openFileButton = UIButton()
            openFileButton.addTarget(self, action: #selector(self.openFile(with:)), for: .touchUpInside)
            openFileButton.setImage(.actions, for: .normal)
            openFileButton.tag = 10000 + indexPath.row

            if file.originFile.isFolder {
                cell.accessories = [.disclosureIndicator()]
            } else if file.downloadResult?.url != nil {
                cell.accessories = [
                    .customView(
                        configuration:
                                .init(
                                    customView: openFileButton,
                                    placement: .trailing())),
                    .disclosureIndicator()]
            } else {
                if let downloadResult = file.downloadResult {
                    downloadButton.setTitle("\(String.init(format: "%.2f", downloadResult.progress * 100))%", for: .normal)
                    downloadButton.setImage(nil, for: .normal)
                } else {
                    downloadButton.setTitle(nil, for: .normal)
                    downloadButton.setImage(.add, for: .normal)
                }
                
                cell.accessories = [
                    .customView(
                        configuration:
                                .init(
                                    customView: downloadButton,
                                    placement: .trailing())),
                    .disclosureIndicator()]
            }
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration.init(appearance: .grouped))
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        return collectionView
    }()
    
    var files: [AliyunpanFile] {
        get {
            displayFiles.map { $0.originFile }
        }
        set {
            displayFiles = newValue.map { DisplayFile(originFile: $0, downloadResult: nil) }
        }
    }
    private var displayFiles: [DisplayFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, DisplayFile>()
        snapshot.appendSections([0])
        snapshot.appendItems(displayFiles)
        dataSource.apply(snapshot)
    }
    
    @MainActor
    func updateDownloadResult(_ result: DownloadResult, for file: AliyunpanFile) {
        guard let index = displayFiles.firstIndex(where: { $0.originFile == file }) else {
            return
        }
        displayFiles[index] = DisplayFile(originFile: file, downloadResult: result)
        var snapshot = NSDiffableDataSourceSnapshot<Int, DisplayFile>()
        snapshot.appendSections([0])
        snapshot.appendItems(displayFiles)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
       
    @objc private func download(_ sender: UIButton) {
        let index = sender.tag - 10000
        let file = dataSource.snapshot().itemIdentifiers[index].originFile
        downloadFile(file)
    }
    
    @objc private func openFile(with sender: UIButton) {
        let index = sender.tag - 10000
        let file = dataSource.snapshot().itemIdentifiers[index]
        guard let url = file.downloadResult?.url else {
            return
        }
        if file.originFile.category == .video {
            playMedia(url)
        } else {
            let viewController = UIDocumentInteractionController(url: url)
            viewController.delegate = self
            viewController.presentPreview(animated: true)
        }
    }
    
    private func downloadFile(_ file: AliyunpanFile) {
        guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return
        }
        let filename = file.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let destination = url.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: destination.path) {
            updateDownloadResult(.completed(url: destination), for: file)
        } else {
            Task {
                let downloader = try await client.downloader(file, to: destination)
                downloader.download { [weak self] progress in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateDownloadResult(.progressing(progress), for: file)
                    }
                } completionHandle: { [weak self] result in
                    if let url = try? result.get() {
                        DispatchQueue.main.async { [weak self] in
                            self?.updateDownloadResult(.completed(url: url), for: file)
                        }
                    }
                }
            }
        }
    }
    
    /// 播放音频
    @MainActor
    private func playMedia(_ url: URL) {
        let headers = [
            "Authorization": "Bearer \(client.accessToken ?? "")"
        ]
        let asset = AVURLAsset(url: url, options: [
            "AVURLAssetHTTPHeaderFieldsKey": headers
        ])
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    /// 打开文件夹
    @MainActor
    private func navigateToFolder(_ folder: AliyunpanFile) {
        Task {
            let files = try await client.send(AliyunpanScope.File.GetFileList(
                .init(drive_id: folder.drive_id, parent_file_id: folder.file_id)))
                .items
            
            let filelistViewController = FileListViewController()
            filelistViewController.files = files
            navigationController?.pushViewController(filelistViewController, animated: true)
        }
    }
}

extension FileListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let file = dataSource.snapshot().itemIdentifiers[indexPath.row].originFile
        
        /// 文件夹
        if file.isFolder {
            navigateToFolder(file)
        }
        
        switch file.category ?? .others {
        case .video:
            Task {
                do {
                    let playInfo = try await self.client.send(
                        AliyunpanScope.Video.GetVideoPreviewPlayInfo(
                            .init(
                                drive_id: file.drive_id,
                                file_id: file.file_id)))

                    /// 获取画质最高的已转码播放链接
                    let playURL = playInfo.video_preview_play_info.live_transcoding_task_list
                        .filter { $0.status == .finished }
                        .compactMap { $0.url }
                        .last

                    if let playURL {
                        playMedia(playURL)
                    }
                } catch {
                    print(error)
                }
            }
        case .audio:
            Task {
                do {
                    /// 目前音频需要使用 download url 播放
                    let playURL = try await self.client.send(
                        AliyunpanScope.File.GetFileDownloadUrl(
                            .init(
                                drive_id: file.drive_id,
                                file_id: file.file_id))).url
                    playMedia(playURL)
                } catch {
                    print(error)
                }
            }
        default:
            downloadFile(file)
        }
    }
}

extension FileListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
