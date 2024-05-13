//
//  ViewController.swift
//  Demo-MacOS
//
//  Created by zhaixian on 2023/12/13.
//

import Cocoa
import AliyunpanSDK

class ViewController: NSViewController {    
    private var buttonContainer = NSStackView()
    private var pkceButton = NSButton()
    private var qrCodeButton = NSButton()

    private var imageView = NSImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonContainer.orientation = .vertical
        view.addSubview(buttonContainer)
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonContainer.widthAnchor.constraint(equalToConstant: 200),
            buttonContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        pkceButton.title = "Authorize（PKCE）"
        pkceButton.bezelStyle = .roundRect
        pkceButton.action = #selector(pkceAuthorize)
        
        qrCodeButton.title = "Authorize（QR Code）"
        qrCodeButton.bezelStyle = .roundRect
        qrCodeButton.action = #selector(showQRCode)
        
        buttonContainer.addArrangedSubview(pkceButton)
        buttonContainer.addArrangedSubview(qrCodeButton)
        
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
    
    @objc private func pkceAuthorize() {
        Task {
            do {
                try await client.authorize(
                    credentials: .pkce)
                navigateToExamples()
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func showQRCode() {
        Task {
            do {
                try await client.authorize(
                    credentials: .qrCode(self))
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
        buttonContainer.isHidden = true
        imageView.isHidden = false
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = NSImage(data: data)
            imageView.image = image
        }
    }
}
