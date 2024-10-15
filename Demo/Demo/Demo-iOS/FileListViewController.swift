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
    private lazy var networkSpeedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        return label
    }()
        
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, DisplayItem> = {
        let cellRegistration = UICollectionView.CellRegistration<FileCell, DisplayItem> { [weak self] cell, _, item in
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
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .grouped))
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        return collectionView
    }()
    
    var files: [AliyunpanFile] {
        get {
            displayItems.map(\.file)
        }
        set {
            displayItems = newValue.map { DisplayItem($0) }
        }
    }
    
    private var displayItems: [DisplayItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                    
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, DisplayItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(displayItems)
        dataSource.apply(snapshot)
        
        client.downloader.addDelegate(self)
        client.downloader.enableNetworkSpeedMonitor()
    }
    
    /// 播放音频
    @MainActor
    private func playMedia(_ url: URL, mimeType: String?) {
        let headers = [
            "Authorization": "Bearer \(client.accessToken ?? "")"
        ]
        let asset: AVURLAsset
        if #available(iOS 17.0, *), let mimeType {
            asset = AVURLAsset(url: url, options: [
                "AVURLAssetHTTPHeaderFieldsKey": headers,
                AVURLAssetOverrideMIMETypeKey: mimeType
            ])
        } else {
            asset = AVURLAsset(url: url, options: [
                "AVURLAssetHTTPHeaderFieldsKey": headers
            ])
        }
        
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
            let files = try await client
                .authorize()
                .send(AliyunpanScope.File.GetFileList(
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
                    let playInfo = try await client
                        .authorize()
                        .send(
                            AliyunpanScope.Video.GetVideoPreviewPlayInfo(
                                .init(
                                    drive_id: file.drive_id,
                                    file_id: file.file_id)))

                    /// 获取画质最高的已转码播放链接
                    let playURL = playInfo.video_preview_play_info.live_transcoding_task_list
                        .filter { $0.status == .finished }
                        .compactMap(\.url)
                        .last

                    if let playURL {
                        playMedia(playURL, mimeType: file.mime_type)
                    }
                } catch {
                    print(error)
                }
            }
        case .audio:
            Task {
                do {
                    /// 目前音频需要使用 download url 播放
                    let playURL = try await client
                        .authorize()
                        .send(
                            AliyunpanScope.File.GetFileDownloadUrl(
                                .init(
                                    drive_id: file.drive_id,
                                    file_id: file.file_id))).url
                    playMedia(playURL, mimeType: file.mime_type)
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
    func fileCell(_ cell: FileCell, willDownload item: DisplayItem) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        if let task = client.downloader.tasks.first(where: { $0.file.isSameFile(item.file) }) {
            // 恢复下载
            client.downloader.resume(task)
        } else {
            let file = item.file
            let filename = file.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            let destination = url.appendingPathComponent("Download").appendingPathComponent(filename)
            client.downloader.download(file: file, to: destination)
        }
    }
    
    func fileCell(_ cell: FileCell, willPause item: DisplayItem) {
        guard let task = client.downloader.tasks.first(where: { $0.file.isSameFile(item.file) }) else {
            return
        }
        client.downloader.pause(task)
    }
    
    func fileCell(_ cell: FileCell, willResume item: DisplayItem) {
        guard let task = client.downloader.tasks.first(where: { $0.file.isSameFile(item.file) }) else {
            return
        }
        client.downloader.resume(task)
    }
    
    func fileCell(_ cell: FileCell, willOpen item: DisplayItem) {
        guard case .finished(let url) = item.downloadState else {
            return
        }
        if item.file.category == .video {
            playMedia(url, mimeType: item.file.mime_type)
        } else {
            let viewController = UIDocumentInteractionController(url: url)
            viewController.delegate = self
            viewController.presentPreview(animated: true)
        }
    }
}

extension FileListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        self
    }
}

extension FileListViewController: AliyunpanDownloadDelegate {
    func downloader(_ downloader: AliyunpanDownloader, didUpdatedNetworkSpeed networkSpeed: Int64) {
        networkSpeedLabel.text = "\(String(format: "%.2f", Double(networkSpeed) / 1_000_000))MB/s"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: networkSpeedLabel)
    }
    
    func downloader(_ downloader: AliyunpanDownloader, didUpdateTaskState state: AliyunpanDownloadTask.State, for task: AliyunpanDownloadTask) {
        guard let index = displayItems.firstIndex(where: { $0.file.isSameFile(task.file) }) else {
            return
        }
        displayItems[index] = DisplayItem(file: task.file, downloadState: state)
        var snapshot = NSDiffableDataSourceSnapshot<Int, DisplayItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(displayItems)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
