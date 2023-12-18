<div align="center">
  <h3 align="center">AliyunpanSDK</h3>
  <p align="center">
    <a href="https://cocoapods.org/pods/AliyunpanSDK"><img src="https://img.shields.io/cocoapods/v/AliyunpanSDK?color=%23526efa"/></a>
    <a><img src="https://img.shields.io/badge/Platforms-macOS_iOS_tvOS-Green"/></a>
  </p>

  <p align="center">
  This is the open-source SDK for Aliyunpan OpenAPI. 
  </p>
  <p align="center">
    <a href="https://github.com/alibaba/aliyunpan-ios-sdk/tree/main/Demo">示例</a>
    ·
    <a href="https://github.com/alibaba/aliyunpan-ios-sdk/issues/new?labels=bug">反馈 Bug</a>
    ·
    <a href="https://github.com/alibaba/aliyunpan-ios-sdk/issues/new?labels=feature">提交需求</a>
    ·
    <a href="https://github.com/alibaba/aliyunpan-ios-sdk/tree/main/README.md">English</a>
  </p>
</div>

## 准备工作

在开始前，请查看阿里云盘开放平台接入指南：

[👉 接入指南](https://www.yuque.com/aliyundrive/zpfszx/tyzl591kxmft4e81)

## 快速开始

### 1. 创建 Client

你可以使用 SDK 提供的任意授权方式创建 Client
#### [Credentials](https://alibaba.github.io/aliyunpan-ios-sdk/Enums/AliyunpanCredentials.html)
- .pkce

    无需服务端，需要已安装阿里云盘客户端
- .server(AliyunpanBizServer)

    需要有服务端，需要已安装阿里云盘客户端
- .qrCode(AliyunpanQRCodeContainer)
    二维码授权，无需服务端，无需安装阿里云盘客户端
   

```swift
let client: AliyunpanClient = AliyunpanClient(
    .init(
        appId: "YOUR_APP_ID",
        scope: "YOUR_SCOPE", // e.g. user:base,file:all:read
        credentials: YOUR_CREDENTIALS))
``` 

### 2. 发送命令

使用 SDK，你可以轻松使用所有已提供的 OpenAPI 和它们的请求体、返回体模型

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

## 高级使用

SDK 封装了命令集合来使你的开发更快、更好

### 下载

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

## 要求

- iOS 13.0+
- Swift 5.0+ 

## 安装方式

#### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- 添加 `https://github.com/alibaba/aliyunpan-ios-sdk.git`

#### CocoaPods

```ruby
target 'MyApp' do
  pod 'AliyunpanSDK', '~> 0.1.0'
end
```

## 文档

[👉 文档](https://alibaba.github.io/aliyunpan-ios-sdk/)

## License

This project is licensed under the [MIT License](LICENSE).
