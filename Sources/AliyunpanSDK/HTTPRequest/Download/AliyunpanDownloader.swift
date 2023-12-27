//
//  AliyunpanDownloader.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/18.
//

import Foundation

public typealias DownloadTasks = [AliyunpanDownloadTask]

extension DownloadTasks {
    mutating func finish(_ task: Element) {
        removeAll(where: {
            $0.id == task.id
        })
    }
}

public protocol AliyunpanDownloadDelegate: AnyObject {
    /// 下载速度更新
    @MainActor
    func downloader(_ downloader: AliyunpanDownloader, didUpdatedNetworkSpeed networkSpeed: Int64)
    
    /// 下载进度发生变化
    @MainActor
    func downloader(_ downloader: AliyunpanDownloader, didUpdateTaskState state: AliyunpanDownloadTask.State, for task: AliyunpanDownloadTask)
}

/// 下载器
public class AliyunpanDownloader: NSObject {
    /// 最大并发数，默认为10
    public var maxConcurrentOperationCount: Int {
        get {
            operationQueue.maxConcurrentOperationCount
        }
        set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
    }
    
    /// 当前下载任务
    public private(set) var tasks: DownloadTasks = []

    private var operationQueue = OperationQueue(
        name: "com.aliyunpanSDK.downloader.queue",
        maxConcurrentOperationCount: 10)
    
    private var delegates: [Weak<AnyObject>] = []
    
    /// 网速监听 Timer
    private lazy var networkSpeedTimer: Timer = {
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else {
                return
            }
            let offset = self.currentWritedSize - self.lastWritedSize
            self.lastWritedSize = self.currentWritedSize
            self.delegates.compactMap { $0.value as? AliyunpanDownloadDelegate }
                .forEach { delegate in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {
                            return
                        }
                        delegate.downloader(self, didUpdatedNetworkSpeed: offset)
                    }
                }
        }
        RunLoop.current.add(timer, forMode: .common)
        return timer
    }()
    
    private var lastWritedSize: Int64 = 0
    
    private var currentWritedSize: Int64 = 0

    weak var client: AliyunpanClient?
    
    deinit {
        networkSpeedTimer.invalidate()
    }
    
    override init() {
        super.init()
    }
}

extension AliyunpanDownloader {
    /// 添加代理
    public func addDelegate(_ delegate: AliyunpanDownloadDelegate) {
        delegates = (delegates + [.init(value: delegate)]).filter {
            $0.value != nil
        }
    }
    
    /// 开启网速监听
    public func enableNetworkSpeedMonitor() {
        networkSpeedTimer.fire()
    }
    
    /// 下载文件
    /// - Parameters:
    ///   - file: 目标文件
    ///   - destination: 目标目录
    /// - Returns: DownloadTask
    @discardableResult
    public func download(file: AliyunpanFile, to destination: URL) -> AliyunpanDownloadTask {
        Logger.log(.info, msg: "[Downloader] download \(file.name), to:\(destination)")

        let task = AliyunpanDownloadTask(file: file, destination: destination, delegate: self)
        tasks.append(task)
        task.start()
        return task
    }

    /// 暂停下载
    /// - Parameter task: 目标任务
    public func pause(_ task: AliyunpanDownloadTask) {
        Logger.log(.info, msg: "[Downloader] pause \(task.file.name)")
        task.pause()
    }
    
    /// 恢复下载
    /// - Parameter task: 目标任务
    public func resume(_ task: AliyunpanDownloadTask) {
        Logger.log(.info, msg: "[Downloader] resume \(task.file.name)")
        task.start()
    }
    
    /// 取消下载，会清空已下载内容
    /// - Parameter task: 目标任务
    public func cancel(_ task: AliyunpanDownloadTask) {
        Logger.log(.info, msg: "[Downloader] cancel \(task.file.name)")
        task.cancel()
        tasks.finish(task)
    }
}

extension AliyunpanDownloader: AliyunpanDownloadTaskDelegate {
    func getFileDownloadUrl(driveId: String, fileId: String) async throws -> AliyunpanScope.File.GetFileDownloadUrl.Response {
        guard let client else {
            throw AliyunpanError.DownloadError.invalidClient
        }
        return try await client.send(
            AliyunpanScope.File.GetFileDownloadUrl(
                .init(drive_id: driveId, file_id: fileId)))
    }
    
    func getOperationQueue() -> OperationQueue {
        operationQueue
    }
    
    func downloadTask(_ task: AliyunpanDownloadTask, didUpdateState state: AliyunpanDownloadTask.State) {
        delegates.compactMap { $0.value as? AliyunpanDownloadDelegate }
            .forEach { delegate in
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    delegate.downloader(self, didUpdateTaskState: state, for: task)
                }
            }
    }
    
    func downloadTask(task: AliyunpanDownloadTask, didWriteData bytesWritten: Int64) {
        currentWritedSize += bytesWritten
    }
}
