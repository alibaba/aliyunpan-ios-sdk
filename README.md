# AliyunpanSDK
This is the open-source SDK for Aliyunpan OpenAPI. 

## Getting Started

To begin using the sdk, visit our guide that will walk you through the setup process:

[👉 Guide](https://www.yuque.com/aliyundrive/zpfszx/tyzl591kxmft4e81)

## Quick start

### 1. Create a client

You can create a client either by using PKCE or server credentials.

```swift
// Using PKCE
let client: AliyunpanClient = AliyunpanClient(
    .init(
        appId: "YOUR_APP_ID",
        scope: "YOUR_SCOPE", // e.g. user:base,file:all:read
        credentials: .pkce))

// Using server credentials
class YOUR_SERVER_CLASS: AliyunpanBizServer {
    ...
}
let client: AliyunpanClient = AliyunpanClient(
    .init(
        appId: "YOUR_APP_ID",
        scope: "YOUR_SCOPE", // e.g. user:base,file:all:read
        credentials: .server(YOUR_SERVER_CLASS())))
``` 

### 2. Send Commands

With this SDK, you can easily interface all openAPIs and their request/response models.

```swift
// Concurrency
try await client.send(
    AliyunpanScope.User.GetUserInfo()) // -> GetUserInfo.Response

try await client.send(
    AliyunpanScope.File.GetFileList(
        .init(drive_id: driveId, parent_file_id: "root")))) // -> GetFileList.Response
        
// Closure
client.send(
    AliyunpanScope.User.GetUserInfo()) { result in
    /// do something
}
```

## Advanced Usage

This SDK also provides advanced functionalities to make your development faster and smoother.

### Download

```swift
// Concurrency
let downloader = try await client.downloader(file, to: destination)
for try await result in downloader.download() {
    if let url = result.url {
        // File is downloaded, process the file
    } else {
        // Handle other cases
    }
}

// Closure
downloader.download { progress in
    // do something..
} completionHandle: { result in
    if let url = try? result.get() {
        // File is downloaded, process the file
    } else {
        // Handle other cases
    }
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
