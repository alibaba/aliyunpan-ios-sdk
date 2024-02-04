//
//  ViewController.swift
//  Demo-MacOS
//
//  Created by zhaixian on 2023/12/13.
//

import Cocoa
import AliyunpanSDK

class ViewController: NSViewController {
    private lazy var client: AliyunpanClient = {
        let client = AliyunpanClient(
            .init(
                appId: "YOUR_APP_ID", // 替换成你的 AppID
                scope: "user:base,file:all:read,file:all:write",
                credentials: .qrCode(self)))
        return client
    }()
    
    private var authorizeButton = NSButton()
    private var imageView = NSImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (NSApplication.shared.delegate as! AppDelegate).client = client
        
        authorizeButton.title = "Authorize"
        authorizeButton.bezelStyle = .roundRect
        view.addSubview(authorizeButton)
        authorizeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorizeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authorizeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authorizeButton.widthAnchor.constraint(equalToConstant: 200),
            authorizeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        authorizeButton.action = #selector(showQRCode)
        
        view.addSubview(imageView)
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if client.accessToken != nil {
            // 已授权过
            navigateToExamples()
        }
    }
    
    @objc private func showQRCode() {
        Task {
            do {
                try await client.authorize()
            } catch {
                print(error)
            }
        }
    }
    
    private func navigateToExamples() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle.main)
        let splitViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.Name("MainSplitViewController")) as! MainSplitViewController
        view.window?.contentViewController = splitViewController
    }
}

extension ViewController: AliyunpanQRCodeContainer {
    func authorizeQRCodeStatusUpdated(_ status: AliyunpanSDK.AliyunpanAuthorizeQRCodeStatus) {
        print(status.rawValue)
        if status == .loginSuccess {
            navigateToExamples()
        }
    }
    
    func showAliyunpanAuthorizeQRCode(with url: URL) {
        authorizeButton.isHidden = true
        imageView.isHidden = false
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = NSImage(data: data)
            imageView.image = image
        }
    }
}
