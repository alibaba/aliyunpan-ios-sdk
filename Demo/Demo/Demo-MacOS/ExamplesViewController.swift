//
//  ExamplesViewController.swift
//  Demo-MacOS
//
//  Created by zhaixian on 2023/12/15.
//

import Cocoa
import AliyunpanSDK

class ExamplesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet var tableView: NSTableView!
    
    let examples = Example.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        examples.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellView = tableView.makeView(withIdentifier: .init("MyCellViewID"), owner: nil) as? NSTableCellView {
            let example = examples[row]
            cellView.textField?.stringValue = example.rawValue
            
            return cellView
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // 当选中的行发生变化时被调用
        let selectedRow = tableView.selectedRow
        
        guard selectedRow >= 0, selectedRow < examples.count else {
            return
        }
        
        let item = examples[selectedRow]
        switch item {
        case .getUserInfo:
            Task {
                do {
                    let vipInfo = try await client.authorize().send(AliyunpanScope.User.GetUsersInfo())
                    showAlert(message: String(describing: vipInfo))
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getDriveInfo:
            Task {
                do {
                    let vipInfo = try await client.authorize().send(AliyunpanScope.User.GetDriveInfo())
                    showAlert(message: String(describing: vipInfo))
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getSpaceInfo:
            Task {
                do {
                    let vipInfo = try await client.authorize().send(AliyunpanScope.User.GetSpaceInfo())
                    showAlert(message: String(describing: vipInfo))
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getVIPInfo:
            Task {
                do {
                    let vipInfo = try await client.authorize().send(AliyunpanScope.User.GetVipInfo())
                    showAlert(message: String(describing: vipInfo))
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .getVipFeatureList:
            Task {
                do {
                    let featureList = try await client.authorize().send(AliyunpanScope.VIP.GetVipFeatureList())
                    showAlert(message: String(describing: featureList))
                } catch {
                    showAlert(message: String(describing: error))
                }
            }
        case .fetchFileList:
            Task {
                let driveInfo = try await client.authorize().send(AliyunpanScope.User.GetDriveInfo())
                
                let driveId = driveInfo.default_drive_id
                
                let fileList = try await client.authorize().send(AliyunpanScope.File.GetFileList(.init(drive_id: driveId, parent_file_id: "root"))).items
                
                showFileDetailViewController(files: fileList)
            }
        case .uploadFileToRoot:
            break
        case .createFolderOnRoot:
            Task {
                do {
                    let driveInfo = try await client.authorize().send(AliyunpanScope.User.GetDriveInfo())
                    
                    let driveId = driveInfo.default_drive_id
                    
                    let response = try await client.authorize().send(
                        AliyunpanScope.File.CreateFile(
                            .init(
                                drive_id: driveId,
                                parent_file_id: "root",
                                name: "TestFolder",
                                type: .folder,
                                check_name_mode: .auto_rename)))
                    
                    print(response)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @MainActor
    private func showFileDetailViewController(files: [AliyunpanFile]) {
        guard let splitViewController = parent as? NSSplitViewController,
              let viewController = storyboard?.instantiateController(withIdentifier: "DetailViewController") as? DetailViewController else { return }

        viewController.files = files
        let item = NSSplitViewItem(viewController: viewController)
        var items = splitViewController.splitViewItems
        if items.count > 1 {
            items[1] = item
        } else {
            items.append(item)
        }
        splitViewController.splitViewItems = items
    }
    
    @MainActor
    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

class DetailViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var files: [AliyunpanFile] = []
    
    var parentDetailViewController: DetailViewController?
    
    @IBOutlet var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        files.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let file = files[row]
        
        let text: String
        let cellIdentifier = "DetailCellID"
        if tableColumn == tableView.tableColumns[0] {
            text = file.name
        } else if tableColumn == tableView.tableColumns[1] {
            if file.isFolder {
                text = "--"
            } else {
                text = "\(String(format: "%.2f", Double(file.size ?? 0) / 1_000_000))MB"
            }
        } else {
            if let createdAt = file.created_at {
                text = ISO8601DateFormatter().string(from: createdAt)
            } else {
                text = "--"
            }
        }
     
        if let cell = tableView.makeView(withIdentifier: .init(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // do something
    }
}

class MainSplitViewController: NSSplitViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
