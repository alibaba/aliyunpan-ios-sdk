//
//  AliyunpanFile.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/23.
//

import Foundation

public struct AliyunpanFile: Codable {
    public let drive_id: String
    public let file_id: String
    /// 根目录是 root
    public let parent_file_id: String
    /// 文件名
    public let name: String
    public let size: Int64?
    public let file_extension: String?
    /// 文件 hash
    public let content_hash: String?
    public var category: FileCategory?
    public let type: FileType?
    /// 缩略图
    public let thumbnail: URL?
    /// 图片预览图地址、小于 5MB 文件的下载地址。超过5MB 请使用 /getDownloadUrl
    public let url: URL?
    public let created_at: Date?
    public let updated_at: Date?
    /// 播放进度
    public let play_cursor: String?
    /// 图片信息
    public let image_media_metadata: MediaMetadata?
    /// 视频信息
    public let video_media_metadata: MediaMetadata?
    /// 视频预览信息
    public var video_preview_metadata: AudioMetaData?
}

extension AliyunpanFile: CustomStringConvertible {
    public var description: String {
        """
[AliyunpanFile]
    name: \(name)
    drive_id: \(drive_id)
    file_id: \(file_id)
    parent_file_id: \(parent_file_id)
    size: \(size ?? -1)
    file_extension: \(file_extension ?? "nil")
    content_hash: \(content_hash ?? "nil")
    category: \(category?.rawValue ?? "nil")
    type: \(type?.rawValue ?? "nil")
    thumbnail: \(thumbnail?.absoluteString ?? "nil")
    url: \(url?.absoluteString ?? "nil")
    created_at: \(created_at?.timeIntervalSince1970 ?? -1)
    updated_at: \(updated_at?.timeIntervalSince1970 ?? -1)
    play_cursor: \(play_cursor ?? "nil")
    image_media_metadata: \(String(describing: image_media_metadata))
    video_media_metadata: \(String(describing: video_media_metadata))
    video_preview_metadata: \(String(describing: video_preview_metadata))
"""
    }
}

extension AliyunpanFile {
    /// 是否文件夹
    public var isFolder: Bool {
        type == .folder
    }
    
    /// 是否同一份文件，仅判断 drive_id、file_id 是否相同
    public func isSameFile(_ other: AliyunpanFile) -> Bool {
        drive_id == other.drive_id && file_id == other.file_id
    }
}

extension AliyunpanFile {
    public enum FileCategory: String, Codable {
        case video
        case doc
        case audio
        case zip
        case others
        case image
    }
    
    public enum FileType: String, Codable {
        case all
        case file
        case folder
    }
    
    public struct Template: Codable {
        public let template_id: String?
        public let status: String?
        public let url: URL?
        public let preview_url: URL?
    }
    
    public struct MediaMetadata: Codable {
        public struct VideoStream: Codable {
            /// 时长
            public let duration: String?
            /// 清晰度，，如 2160(4k)
            public let clarity: String?
            /// 帧率
            public let fps: String?
            /// 码率
            public let bitrate: String?
            /// 编码，如 hevc
            public let code_name: String?
        }
        
        public struct AudioStream: Codable {
            /// 时长
            public let duration: String?
            /// 声道数量
            public let channels: Int?
            /// 布局，如 stereo
            public let channel_layout: String?
            /// 码率
            public let bitrate: String?
            /// 编码，如 hevc
            public let code_name: String?
            /// 采样率，如 44100
            public let sample_rate: String?
        }
        
        public let duration: String?
        public let width: Int?
        public let height: Int?
        public let time: String?
        public let location: String?
        public let country: String?
        public let province: String?
        public let city: String?
        public let district: String?
        public let township: String?
        public let exif: String?
        public let video_media_video_stream: [VideoStream]?
        public let video_media_audio_stream: [AudioStream]?
    }
    
    public struct AudioMetaData: Codable {
        public struct AudioMeta: Codable {
            public let duration: String?
            public let bitrate: String?
            public let sample_rate: String?
            public let channels: Int?
        }
        
        public struct MusicMeta: Codable {
            public let title: String?
            public let artist: String?
            public let album: URL?
            public let cover_url: URL?
        }
        
        /// 时长
        public let duration: String?
        /// 码率
        public let bitrate: String?
        /// 格式
        public let audio_format: String?
        public let audio_sample_rate: String?
        public let audio_channels: Int?
        public let audio_meta: AudioMeta?
        public let audio_music_meta: MusicMeta?
        public let template_list: [Template]?
    }
    
    public enum CheckNameMode: String, Codable {
        /// 自动重命名，存在并发问题
        case auto_rename
        /// 同名不创建
        case refuse
        /// 同名文件可创建
        case ignore
    }
    
    public struct PartInfo: Codable {
        /// 分片编号
        public let part_number: Int
        /// 分片大小
        public let part_size: Int64?
        /// etag， 在上传分片结束后，服务端会返回这个分片的Etag，在complete的时候可以在uploadInfo指定分片的Etag，服务端会在合并时对每个分片Etag做校验
        public var etag: String?
        public var upload_url: URL?

        public init(part_number: Int, part_size: Int64? = nil, etag: String? = nil, upload_url: URL? = nil) {
            self.part_number = part_number
            self.part_size = part_size
            self.etag = etag
            self.upload_url = upload_url
        }
    }
    
    public struct StreamsInfo: Codable {
        public let content_hash: String?
        public let content_hash_name: String?
        public let proof_version: String?
        public let content_md5: String?
        public let pre_hash: String?
        public let size: String?
        public let part_info_list: [PartInfo]?
        
        public init(content_hash: String?, content_hash_name: String?, proof_version: String?, content_md5: String?, pre_hash: String?, size: String?, part_info_list: [PartInfo]?) {
            self.content_hash = content_hash
            self.content_hash_name = content_hash_name
            self.proof_version = proof_version
            self.content_md5 = content_md5
            self.pre_hash = pre_hash
            self.size = size
            self.part_info_list = part_info_list
        }
    }
    
    public struct VideoPreviewPlayInfo: Codable {
        public enum Status: String, Codable {
            /// 索引完成，可以获取到url
            case finished
            /// 正在索引，请稍等片刻重试
            case running
            /// 转码失败，请检查是否媒体文件，如果有疑问请联系客服
            case failed
        }
        
        public struct Meta: Codable {
            public let duration: Double
            public let width: Int
            public let height: Int
        }
        
        public struct LiveTranscodingTask: Codable {
            public let template_id: String
            public let template_name: String?
            public let template_width: Int?
            public let template_height: Int?
            /// 是否原画
            public let keep_original_resolution: Bool?
            public let stage: String?
            public let status: Status
            public let url: URL?
        }
        
        public struct LiveTranscodingSubtitleTask: Codable {
            /// chi | eng
            public let language: String
            public let status: Status
            public let url: URL?
        }
        
        /// live_transcoding
        public let category: String
        /// 播放进度，如 "5722.376"
        public let play_cursor: String?
        /// 播放信息
        public let live_transcoding_task_list: [LiveTranscodingTask]
        /// 字幕信息
        public let live_transcoding_subtitle_task_list: [LiveTranscodingSubtitleTask]?
    }
}
