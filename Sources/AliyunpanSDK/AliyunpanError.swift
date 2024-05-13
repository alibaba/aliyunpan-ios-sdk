//
//  AliyunpanError.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/22.
//

import Foundation

public struct AliyunpanError {
    /// 授权错误
    public enum AuthorizeError: Error {
        /// 错误的授权链接
        case invalidAuthorizeURL
        /// 当前设备未安装阿里云盘
        case notInstalledApp
        /// 授权错误
        case authorizeFailed(error: String?, errorMsg: String?)
        /// 验证码授权超时
        case qrCodeAuthorizeTimeout
        /// 未授权或授权已过期
        case accessTokenInvalid
        /// 授权 code 错误
        case invalidCode
    }

    /// 网络层错误
    public struct ServerError: Error, Decodable {
        public enum Code: String, Decodable {
            /// 二维码过期
            case qrCodeExpired = "QRCodeExpired"
            /// 容量超限
            case quotaExhaustedDrive = "QuotaExhausted.Drive"
            /// access_token 过期
            case accessTokenExpired = "AccessTokenExpired"
            /// access_token 格式不对
            case accessTokenInvalid = "AccessTokenInvalid"
            /// refresh_token 过期
            case refreshTokenExpired = "RefreshTokenExpired"
            /// refresh_token 格式不对
            case refreshTokenInvalid = "RefreshTokenInvalid"
            /// 用户已取消授权，或权限已失效，或 token 无效。需要重新发起授权
            case permissionDenied = "PermissionDenied"
            /// 回收站文件不允许操作
            case forbiddenFileInTheRecycleBin = "ForbiddenFileInTheRecycleBin"
            /// 用户容量超限，限制播放，需要扩容或者删除不必要的文件释放空间
            case exceedCapacityForbidden = "ExceedCapacityForbidden"
            /// 文件找不到
            case notFound = "NotFound.FileId"
            /// 请求过快
            case tooManyRequests = "TooManyRequests"
            /// 应用不存在
            case appNotExists = "AppNotExists"
            /// 应用密钥不对
            case invalidClientSecret = "InvalidClientSecret"
            /// 授权码为空或过期
            case invalidCode = "InvalidCode"
            /// 应用ID和构造授权链接时填的不一致
            case invalidClientId = "InvalidClientId"
            /// 无效的担保类型，目前仅支持 authorization_code 和 refresh_token
            case invalidGrantType = "InvalidGrantType"
            /// 文件drive被锁，操作无法执行
            case forbiddenDriveLocked = "ForbiddenDriveLocked"
            /// 非法访问drive
            case forbiddenDriveNotValid = "ForbiddenDriveNotValid"
            /// 快传预检匹配成功
            case preHashMatched = "PreHashMatched"
        }
        
        public let code: Code
        public let message: String?
        public let requestId: String?
        
        public var isAccessTokenInvalidOrExpired: Bool {
            code == .accessTokenExpired || code == .accessTokenInvalid
        }
    }

    /// 下载错误
    public enum DownloadError: Error {
        /// 下载链接过期
        case downloadURLExpired
        /// 错误的下载链接
        case invalidDownloadURL
        /// 主动取消
        case userCancelled
        /// 缺少 client
        case invalidClient
    }
    
    /// 上传错误
    public enum UploadError: Error {
        /// 缺少 client
        case invalidClient
        /// 快传预检查失败
        case preHashNotMatched
    }

    /// 系统级网络层错误
    public enum NetworkSystemError: Error {
        case invalidURL
        case httpError(statusCode: Int, data: Data, response: HTTPURLResponse)
    }
}
