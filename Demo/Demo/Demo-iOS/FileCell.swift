//
//  FileCell.swift
//  Demo
//
//  Created by zhaixian on 2023/12/12.
//

import UIKit
import AliyunpanSDK

protocol FileCellDelegate: AnyObject {
    func fileCell(_ cell: FileCell, willOpen item: DisplayItem)
    func fileCell(_ cell: FileCell, willDownload item: DisplayItem)
    func fileCell(_ cell: FileCell, willPause item: DisplayItem)
    func fileCell(_ cell: FileCell, willResume item: DisplayItem)
}

class FileCell: UICollectionViewListCell {
    weak var delegate: FileCellDelegate?
    weak var client: AliyunpanClient?
    
    private var item: DisplayItem?
    
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
        delegate?.fileCell(self, willDownload: item)
    }
    
    @objc private func pause() {
        guard let item else {
            return
        }
        delegate?.fileCell(self, willPause: item)
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
        
        var views: [UIView] = [progressLabel]
        
        if let downloadState = item.downloadState {
            switch downloadState {
            case .waiting:
                progressLabel.text = "等待下载"
                
                views.append(pauseButton)
            case .downloading(let progress):
                progressLabel.text = "\(String(format: "%.2f", progress * 100))%"
                
                views.append(pauseButton)
            case .pause(let progress):
                progressLabel.text = "\(String(format: "%.2f", progress * 100))%"
                
                views.append(downloadButton)
            case .finished:
                progressLabel.text = nil
                
                views.append(openButton)
            case .failed:
                progressLabel.text = nil
            }
        } else {
            views.append(downloadButton)
        }
        
        accessories = views.map {
            UICellAccessory.customView(
                configuration: .init(customView: $0, placement: .trailing()))
        }
    }
}
