//
//  FileListViewController.swift
//  Demo
//
//  Created by zhaixian on 2023/11/24.
//

import UIKit
import AliyunpanSDK
import AVKit

class FileListViewController: UIViewController {
    private var client: AliyunpanClient {
        return (UIApplication.shared.delegate as! AppDelegate).client
    }
        
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, DisplayItem> = {
        let cellRegistration = UICollectionView.CellRegistration<FileCell, DisplayItem> { [weak self] cell, indexPath, item in
            guard let self else {
                return
            }
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.text = item.file.name
            let fileSize = item.file.size ?? 0
            if fileSize > 0 {
                contentConfiguration.secondaryText = "\(String(format: "%.2f", Double(fileSize) / 1_000_000))MB"
            } else {
                contentConfiguration.secondaryText = nil
            }
            cell.contentConfiguration = contentConfiguration
            
            cell.fill(item)
            cell.delegate = self
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
            displayItems.map { $0.file }
        }
        set {
            displayItems = newValue.map { DisplayItem($0) }
        }
    }
    
    private var displayItems: [DisplayItem] = []
    
    private var downloaderMap: [AliyunpanFile: AliyunpanDownloader] = [:]
    private var downloadSpeedMap: [AliyunpanFile: Int64] = [:] {
        didSet {
            let totalSpeed = downloadSpeedMap.values.reduce(0, +)
            let label = UILabel()
            label.text = "\(String(format: "%.2f", Double(totalSpeed) / 1_000_000))MB/s"
            label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: label)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, DisplayItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(displayItems)
        dataSource.apply(snapshot)
    }
    
    private func updateDownloadResult(_ result: AliyunpanDownloadResult, for item: DisplayItem) {
        guard let index = displayItems.firstIndex(where: { $0.file == item.file }) else {
            return
        }
        displayItems[index] = DisplayItem(file: item.file, downloadResult: result)
        var snapshot = NSDiffableDataSourceSnapshot<Int, DisplayItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(displayItems)
        dataSource.apply(snapshot, animatingDifferences: false)
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
        
        let file = dataSource.snapshot().itemIdentifiers[indexPath.row].file
        
        /// 文件夹
        if file.isFolder {
            navigateToFolder(file)
            return
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
            break
        }
    }
}

extension FileListViewController: FileCellDelegate {
    func getDownloader(for item: DisplayItem) -> AliyunpanDownloader? {
        if let downloader = downloaderMap[item.file] {
            return downloader
        }
        guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return nil
        }
        let file = item.file
        let filename = file.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let destination = url.appendingPathComponent(filename)
        let downloader = client.downloader(file, to: destination)
        downloader.networkSpeedMonitor = { [weak self] bytes in
            self?.downloadSpeedMap[item.file] = bytes
        }
        downloaderMap[item.file] = downloader
        return downloader
    }
    
    func fileCell(_ cell: FileCell, willOpen item: DisplayItem) {
        guard let url = item.downloadResult?.url else {
            return
        }
        if item.file.category == .video {
            playMedia(url)
        } else {
            let viewController = UIDocumentInteractionController(url: url)
            viewController.delegate = self
            viewController.presentPreview(animated: true)
        }
    }
    
    func fileCell(_ cell: FileCell, didUpdateDownloadResult result: AliyunpanDownloadResult, for item: DisplayItem) {
        updateDownloadResult(result, for: item)
    }
}

extension FileListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
