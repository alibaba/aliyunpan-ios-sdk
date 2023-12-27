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

[👉 如何注册三方开发者](https://www.yuque.com/aliyundrive/zpfszx/tyzl591kxmft4e81)

## 快速开始

### 1. 创建 Client

你可以使用 SDK 提供的任意授权方式创建 Client
#### [Credentials](https://alibaba.github.io/aliyunpan-ios-sdk/Enums/AliyunpanCredentials.html)
- .pkce
无需服务端，需要安装阿里云盘
- .server(AliyunpanBizServer)
需要有服务端，需要已安装阿里云盘客户端
- .qrCode(AliyunpanQRCodeContainer)
二维码授权，无需服务端，无需安装阿里云盘
   

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

SDK 封装了基础网盘能力

### 下载
```swift
let downloader = client.downloader

// 下载
let task = downloader.download(file: file, to: destination)
// let task = downloader.tasks.first

// 修改并发数，默认为10
downloader.maxConcurrentOperationCount = 10

// 暂停
downloader.pause(task)
// 恢复
downloader.resume(task)
// 取消
downloader.cancel(task)

// AliyunpanDownloadDelegate
//   下载速度变化
//   func downloader(_ downloader: AliyunpanDownloader, didUpdatedNetworkSpeed networkSpeed: Int64)
//   下载任务状态变化 
//   func downloader(_ downloader: AliyunpanDownloader, didUpdateTaskState state: AliyunpanDownloadTask.State, for task: AliyunpanDownloadTask)
downloadr.addDelegate(DELEGATE)
```

#### 示例
[FileListViewController](Demo/Demo-iOS/FileListViewController.swift)

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

## 要求

- iOS 13.0+ (CocoaPods)
- Swift 5.0+ 

## 文档

[👉 文档](https://alibaba.github.io/aliyunpan-ios-sdk/)

## License

This project is licensed under the [MIT License](LICENSE).
