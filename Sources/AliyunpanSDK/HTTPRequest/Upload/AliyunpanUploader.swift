//
//  AliyunpanUploader.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2024/3/25.
//

import Foundation

extension FileManager {
    func dataChunk(at path: URL, in range: Range<Int>) throws -> Data {
        let fileHandle = try FileHandle(forReadingFrom: path)
        try fileHandle.seek(toOffset: UInt64(range.lowerBound))
        let data = fileHandle.readData(ofLength: range.upperBound - range.lowerBound)
        try fileHandle.close()
        
        return data
    }
    
    func fileSizeOfItem(at path: URL) throws -> Int64 {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: path.path)
        return fileAttributes[.size] as? Int64 ?? 0
    }
}

fileprivate extension Array where Element == AliyunpanFile.PartInfo {
    init(fileSize: Int64, chunkSize: Int64) {
        self = stride(from: 0, to: fileSize, by: Int64.Stride(chunkSize)).enumerated().map {
            let partSize = Swift.min(fileSize - $0.element, chunkSize)
            return AliyunpanFile.PartInfo(
                part_number: $0.offset + 1,
                part_size: partSize
            )
        }
    }
}

/// 上传器
public class AliyunpanUploader: NSObject {
    weak var client: AliyunpanClient?
    /// 默认每 2G 分片，最大1000片
    private static let defaultMaxChunkCount: Int64 = 1000
    private static let defaultChunkSize: Int64 = 2_000_000_000
    private static func realChunkSize(fileSize: Int64) -> Int64 {
        max(defaultChunkSize, fileSize / defaultMaxChunkCount)
    }

    /// 创建上传任务，并适当分片
    private func createUploadTask(
        client: AliyunpanClient,
        fileURL: URL,
        fileName: String,
        fileSize: Int64,
        driveId: String,
        folderId: String,
        checkNameMode: AliyunpanFile.CheckNameMode
    ) async throws -> AliyunpanScope.File.CreateFile.Response {
        let partInfoList = [AliyunpanFile.PartInfo](fileSize: fileSize, chunkSize: Self.realChunkSize(fileSize: fileSize))
        
        let task = try await client.send(
            AliyunpanScope.File.CreateFile(
                .init(
                    drive_id: driveId,
                    parent_file_id: folderId,
                    name: fileName,
                    check_name_mode: .ignore,
                    part_info_list: partInfoList
                )
            )
        )
        return task
    }
    
    private func preProofMatch(
        client: AliyunpanClient,
        fileURL: URL,
        fileName: String,
        fileSize: Int64,
        driveId: String,
        folderId: String,
        checkNameMode: AliyunpanFile.CheckNameMode
    ) async throws -> Bool {
        let preData = try FileManager.default.dataChunk(
            at: fileURL,
            in: 0..<1024
        )
        
        let preSHA1 = AliyunpanCrypto.sha1AndHex(preData)
        do {
            _ = try await client.send(
                AliyunpanScope.File.CreateFile(
                    .init(
                        drive_id: driveId,
                        parent_file_id: folderId,
                        name: fileName,
                        check_name_mode: checkNameMode,
                        pre_hash: preSHA1,
                        size: Int(fileSize)
                    )
                )
            )
            return false
        } catch {
            guard let error = error as? AliyunpanError.ServerError else {
                return false
            }
            return error.code == .preHashMatched
        }
    }
    
    /// 创建秒传任务
    private func createProofUploadTask(
        client: AliyunpanClient,
        fileURL: URL,
        fileName: String,
        fileSize: Int64,
        driveId: String,
        folderId: String,
        checkNameMode: AliyunpanFile.CheckNameMode
    ) async throws -> AliyunpanScope.File.CreateFile.Response {
        guard let token = await client.token else {
            throw AliyunpanError.AuthorizeError.accessTokenInvalid
        }

        let partInfoList = [AliyunpanFile.PartInfo](fileSize: fileSize, chunkSize: Self.realChunkSize(fileSize: fileSize))
        
        var isPreHashMatched = false
        // 大于 10M 的文件先预校验
        if fileSize > 10_000_000 {
            isPreHashMatched = try await preProofMatch(client: client, fileURL: fileURL, fileName: fileName, fileSize: fileSize, driveId: driveId, folderId: folderId, checkNameMode: checkNameMode)
        }
        
        if !isPreHashMatched {
            throw AliyunpanError.UploadError.preHashNotMatched
        }
        
        let contentHash = AliyunpanCrypto.sha1AndHex(fileURL)
        let proofCode = AliyunpanCrypto.getProofCode(accessToken: token.access_token, fileURL: fileURL)
        
        let task = try await client.send(
            AliyunpanScope.File.CreateFile(
                .init(
                    drive_id: driveId,
                    parent_file_id: folderId,
                    name: fileName,
                    check_name_mode: checkNameMode,
                    part_info_list: partInfoList,
                    size: Int(fileSize),
                    content_hash: contentHash,
                    content_hash_name: "sha1",
                    proof_code: proofCode,
                    proof_version: "v1"
                )
            )
        )
        return task
    }
    
    /// 完成上传任务
    private func completeUploadTask(
        client: AliyunpanClient,
        driveId: String,
        fileId: String,
        uploadId: String
    ) async throws -> AliyunpanFile {
        try await client.send(
            AliyunpanScope.File.CompleteUpload(
                .init(drive_id: driveId, file_id: fileId, upload_id: uploadId)
            )
        )
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - fileURL: 文件 URL
    ///   - fileName: 文件名，可选，不填时为 fileURL.lastPathComponent
    ///   - driveId: 目标 drive id
    ///   - folderId: 目标文件夹 id
    ///   - checkNameMode: 重名策略，默认 .ignore
    ///   - useProof: 使用秒传，默认 false
    ///   - session: 上传使用的 URLSession
    /// - Returns: AliyunpanFile
    public func upload(
        fileURL: URL,
        fileName: String? = nil,
        driveId: String,
        folderId: String = "root",
        checkNameMode: AliyunpanFile.CheckNameMode = .ignore,
        useProof: Bool = false,
        session: URLSession = URLSession.shared
    ) async throws -> AliyunpanFile {
        guard let client else {
            throw AliyunpanError.UploadError.invalidClient
        }
        
        let fileName = fileName ?? fileURL.lastPathComponent
        let fileSize = try FileManager.default.fileSizeOfItem(at: fileURL)
        
        let task: AliyunpanScope.File.CreateFile.Response
        if useProof {
            task = try await createProofUploadTask(
                client: client,
                fileURL: fileURL,
                fileName: fileName,
                fileSize: fileSize,
                driveId: driveId,
                folderId: folderId,
                checkNameMode: checkNameMode
            )
        } else {
            task = try await createUploadTask(
                client: client,
                fileURL: fileURL,
                fileName: fileName,
                fileSize: fileSize,
                driveId: driveId,
                folderId: folderId,
                checkNameMode: checkNameMode
            )
        }
        
        if task.rapid_upload == true {
            // 秒传成功
        } else {
            // 正常上传
            // 不支持并发上传
            let partInfoEnumerated = (task.part_info_list ?? [])
                .enumerated()
            for (index, partInfo) in partInfoEnumerated {
                guard let uploadURL = partInfo.upload_url else {
                    continue
                }
                var urlRequest = URLRequest(url: uploadURL)
                urlRequest.httpMethod = "put"
                urlRequest.allHTTPHeaderFields = [
                    "Content-Length": "\(partInfo.part_size ?? 0)",
                    "Content-Type": "" // 不能传 Cotent-Type，否则会失败
                ]
                let beginOffset = Int64(index) * Self.realChunkSize(fileSize: fileSize)
                let endOffset = beginOffset + Int64(partInfo.part_size ?? 0)
                let data = try FileManager.default.dataChunk(at: fileURL, in: Int(beginOffset)..<Int(endOffset))
                _ = try await session.upload(for: urlRequest, from: data)
            }
        }
                
        return try await completeUploadTask(
            client: client,
            driveId: driveId,
            fileId: task.file_id,
            uploadId: task.upload_id ?? ""
        )
    }
}
