//
//  ViewController.swift
//  Demo
//
//  Created by zhaixian on 2023/11/23.
//

import UIKit
import AliyunpanSDK

class ViewController: UIViewController {
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<String, Example> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Example> { cell, _, example in
            var contentConfiguration = UIListContentConfiguration.subtitleCell()
            contentConfiguration.text = example.rawValue
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.disclosureIndicator()]
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }()
    
    private lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = "AliyunpanSDK Demo"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
                
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        var snapshot = NSDiffableDataSourceSnapshot<String, Example>()
        snapshot.appendSections(["User"])
        snapshot.appendItems([.getUserInfo, .getDriveInfo, .getSpaceInfo, .getVIPInfo])
        snapshot.appendSections(["VIP"])
        snapshot.appendItems([.getVipFeatureList])
        snapshot.appendSections(["File"])
        snapshot.appendItems([.fetchFileList])
        snapshot.appendItems([.uploadFileToRoot])
        snapshot.appendItems([.createFolderOnRoot])
        dataSource.apply(snapshot)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func uploadFile(withURL url: URL) {
        Task {
            do {
                let driveInfo = try await client
                    .authorize()
                    .send(AliyunpanScope.User.GetDriveInfo())
                
                let driveId = driveInfo.default_drive_id
                
                let file = try await client.uploader
                    .upload(
                        fileURL: url,
                        fileName: url.lastPathComponent,
                        driveId: driveId,
                        folderId: "root",
                        useProof: true)
                
                showAlert(message: file.description)
            } catch {
                print(error)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let item = dataSource.snapshot().itemIdentifiers(inSection: section)[indexPath.row]
        switch item {
        case .getUserInfo:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    let vipInfo = try await client
                        .authorize()
                        .send(AliyunpanScope.User.GetUsersInfo())
                    showAlert(message: String(describing: vipInfo))
                    activityIndicatorView.stopAnimating()
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getDriveInfo:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    let vipInfo = try await client
                        .authorize()
                        .send(AliyunpanScope.User.GetDriveInfo())
                    showAlert(message: String(describing: vipInfo))
                    activityIndicatorView.stopAnimating()
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getSpaceInfo:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    let vipInfo = try await client
                        .authorize()
                        .send(AliyunpanScope.User.GetSpaceInfo())
                    showAlert(message: String(describing: vipInfo))
                    activityIndicatorView.stopAnimating()
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getVIPInfo:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    let vipInfo = try await client
                        .authorize()
                        .send(AliyunpanScope.User.GetVipInfo())
                    showAlert(message: String(describing: vipInfo))
                    activityIndicatorView.stopAnimating()
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getVipFeatureList:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    let featureList = try await client
                        .authorize()
                        .send(AliyunpanScope.VIP.GetVipFeatureList())
                    showAlert(message: String(describing: featureList))
                    activityIndicatorView.stopAnimating()
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .fetchFileList:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    let driveInfo = try await client
                        .authorize()
                        .send(AliyunpanScope.User.GetDriveInfo())
                    
                    let driveId = driveInfo.default_drive_id
                    
                    let fileList = try await client
                        .authorize()
                        .send(AliyunpanScope.File.GetFileList(.init(drive_id: driveId, parent_file_id: "root")))
                    
                    let vc = FileListViewController()
                    vc.files = fileList.items
                    print(fileList.items.map(\.description).joined(separator: "\n"))
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    activityIndicatorView.stopAnimating()
                } catch {
                    print(error)
                }
            }
        case .uploadFileToRoot:
            let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
            documentPickerController.delegate = self
            present(documentPickerController, animated: true)
        case .createFolderOnRoot:
            Task {
                do {
                    activityIndicatorView.startAnimating()
                    
                    let driveInfo = try await client
                        .authorize()
                        .send(AliyunpanScope.User.GetDriveInfo())
                    
                    let driveId = driveInfo.default_drive_id
                    
                    let response = try await client
                        .authorize()
                        .send(
                            AliyunpanScope.File.CreateFile(
                                .init(
                                    drive_id: driveId,
                                    parent_file_id: "root",
                                    name: "TestFolder",
                                    type: .folder,
                                    check_name_mode: .auto_rename)))
                    
                    print(response)
                    
                    activityIndicatorView.stopAnimating()
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        uploadFile(withURL: selectedFileURL)
    }
}
