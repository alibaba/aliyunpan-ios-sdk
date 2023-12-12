//
//  FileCell.swift
//  Demo
//
//  Created by zhaixian on 2023/12/12.
//

import UIKit
import AliyunpanSDK

protocol FileCellDelegate: AnyObject {
    func getDownloader(for item: DisplayItem) -> AliyunpanDownloader?
    
    func fileCell(_ cell: FileCell, didUpdateDownloadResult result: DownloadResult, for item: DisplayItem)
    func fileCell(_ cell: FileCell, willOpen item: DisplayItem)
}

class FileCell: UICollectionViewListCell {
    weak var delegate: FileCellDelegate?
    weak var client: AliyunpanClient?
    
    private var item: DisplayItem?

    private var downloader: AliyunpanDownloader? {
        guard let item else {
            return nil
        }
        return delegate?.getDownloader(for: item)
    }
    
    private lazy var pauseButton: UIButton = {
        let pauseButton = UIButton()
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        pauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
        pauseButton.tintColor = .gray
        return pauseButton
    }()
    
    private lazy var downloadButton: UIButton = {
        let downloadButton = UIButton()
        downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
        downloadButton.setImage(.add, for: .normal)
        return downloadButton
    }()
    
    private lazy var progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.textColor = .gray
        progressLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        progressLabel.adjustsFontSizeToFitWidth = true
        return progressLabel
    }()
    
    private lazy var openButton: UIButton = {
        let openFileButton = UIButton()
        openFileButton.addTarget(self, action: #selector(openFile), for: .touchUpInside)
        openFileButton.setImage(.actions, for: .normal)
        return openFileButton
    }()
    
    @objc private func download() {
        guard let item else {
            return
        }
        
        if downloader?.state == .pause {
            downloader?.resume()
            return
        }
    
        downloader?.download { [weak self] progress in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return
                }
                self.delegate?.fileCell(self, didUpdateDownloadResult: .progressing(progress), for: item)
            }
        } completionHandle: { [weak self] result in
            if let url = try? result.get() {
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    self.delegate?.fileCell(self, didUpdateDownloadResult: .completed(url), for: item)
                }
            }
        }
    }
    
    @objc private func pause() {
        downloader?.pause()
        
        if let item {
            fill(item)
        }
    }
    
    @objc private func openFile() {
        guard let item else {
            return
        }
        delegate?.fileCell(self, willOpen: item)
    }
    
    func fill(_ item: DisplayItem) {
        self.item = item
        if item.file.isFolder {
            accessories = [.disclosureIndicator()]
            return
        }
        
        if let progress = item.downloadResult?.progress {
            progressLabel.text = "\(String(format: "%.2f", progress * 100))%"
        } else {
            progressLabel.text = nil
        }
        
        var views: [UIView] = [progressLabel]
        if item.downloadResult?.url != nil {
            views.append(openButton)
        } else {
            if downloader?.state == .downloading {
                views.append(pauseButton)
            } else {
                views.append(downloadButton)
            }
        }
        accessories = views.map {
            UICellAccessory.customView(
                configuration: .init(customView: $0, placement: .trailing()))
        }
    }
}

