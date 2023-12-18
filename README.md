# AliyunpanSDK
[![pod version](https://img.shields.io/cocoapods/v/AliyunpanSDK?color=%23526efa)](https://cocoapods.org/pods/AliyunpanSDK) ![](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS-Green
)

This is the open-source SDK for Aliyunpan OpenAPI. 

## Getting Started

To begin using the sdk, visit our guide that will walk you through the setup process:

[👉 Guide](https://www.yuque.com/aliyundrive/zpfszx/tyzl591kxmft4e81)

## Quick start

### 1. Create a client

You can create a client either by using a credentials.
#### [Credentials](https://alibaba.github.io/aliyunpan-ios-sdk/Enums/AliyunpanCredentials.html)
- .pkce

    serverless authorization, require AliyunDrive client.
- .server(AliyunpanBizServer)

    server authorization, require AliyunDrive client.
- .qrCode(AliyunpanQRCodeContainer)

    serverless authorization and does not require AliyunDrive client.

```swift
let client: AliyunpanClient = AliyunpanClient(
    .init(
        appId: "YOUR_APP_ID",
        scope: "YOUR_SCOPE", // e.g. user:base,file:all:read
        credentials: SOMEONE_CREDENTIALS))
``` 

### 2. Send Commands

With this SDK, you can easily interface all openAPIs and their request/response models.

```swift
// Concurrency
try await client.send(
    AliyunpanScope.User.GetUsersInfo()) // -> GetUsersInfo.Response

try await client.send(
    AliyunpanScope.File.GetFileList(
        .init(drive_id: driveId, parent_file_id: "root")))) // -> GetFileList.Response
        
// Closure
client.send(
    AliyunpanScope.User.GetUsersInfo()) { result in
    /// do something
}
```

## Advanced Usage

This SDK also provides advanced functionalities to make your development faster and smoother.

### Download

```swift
let downloader = client.downloader(file, to: destination)

downloader.download { progress in
    // do something..
} completionHandle: { result in
    if let url = try? result.get() {
        // File is downloaded, process the file
    } else {
        // Handle other cases
    }
}

downloader.networkSpeedMonitor = { bytesReceived in
    // This closure is called with the number of bytes downloaded in the last second.
    // You can use `bytesReceived` to update the UI or perform other actions based on the current network speed.
}
```

## Requirements

- iOS 13.0+
- Swift 5.0+ 

## Installation

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/alibaba/aliyunpan-ios-sdk.git`

#### CocoaPods

```ruby
target 'MyApp' do
  pod 'AliyunpanSDK', '~> 0.1.0'
end
```

## Documents

[👉 Documents](https://alibaba.github.io/aliyunpan-ios-sdk/)

## License

This project is licensed under the [MIT License](LICENSE).
