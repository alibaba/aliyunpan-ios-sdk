//
//  HTTPHeaders.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/23.
//

import Foundation

extension Bundle {
    var executableName: String {
        (infoDictionary?["CFBundleExecutable"] as? String) ??
            (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
            "Unknown"
    }
    
    var bundleId: String {
        infoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
    }
    
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

public struct HTTPHeader: Comparable, CustomStringConvertible {
    let name: String
    let value: String
    
    public static func < (lhs: HTTPHeader, rhs: HTTPHeader) -> Bool {
        lhs.name.lowercased() < rhs.name.lowercased()
    }
    
    public var description: String {
        return "\(name): \(value)"
    }
}

extension Collection<String> {
    func qualityEncoded() -> String {
        enumerated().map { index, encoding in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(encoding);q=\(quality)"
        }.joined(separator: ", ")
    }
}

extension HTTPHeader {
    static func accept(_ value: String) -> Self {
        HTTPHeader(name: "Accept", value: value)
    }
    
    static func acceptEncoding(_ value: String) -> Self {
        HTTPHeader(name: "Accept-Encoding", value: value)
    }
    
    static func userAgent(_ value: String) -> Self {
        HTTPHeader(name: "User-Agent", value: value)
    }
    
    static func contentType(_ value: String) -> Self {
        HTTPHeader(name: "Content-Type", value: value)
    }
    
    static func authorization(_ value: String) -> Self {
        HTTPHeader(name: "Authorization", value: value)
    }
    
    static func authorization(bearerToken: String) -> Self {
        authorization("Bearer \(bearerToken)")
    }
}

extension HTTPHeader {
    static let defaultContentType = HTTPHeader.contentType("application/json")
    static let defaultAcceptEncoding = HTTPHeader.acceptEncoding(["br", "gzip", "deflate"].qualityEncoded())
    /// `iOS Example/1.0 (org.aliyunpanSDK.iOS-Example; build:1; iOS 13.0.0) AliyunpanSDK/5.0.0`
    static var defaultUserAgent: HTTPHeader {
        let executable = Bundle.main.executableName
        let bundleId = Bundle.main.bundleId
        let appVersion = Bundle.main.appVersion
        let appBuild = Bundle.main.buildNumber
        let osNameVersion: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = {
#if os(iOS)
#if targetEnvironment(macCatalyst)
                return "macOS(Catalyst)"
#else
                return "iOS"
#endif
#elseif os(watchOS)
                return "watchOS"
#elseif os(tvOS)
                return "tvOS"
#elseif os(macOS)
                return "macOS"
#elseif os(Linux)
                return "Linux"
#elseif os(Windows)
                return "Windows"
#elseif os(Android)
                return "Android"
#else
                return "Unknown"
#endif
            }()
            
            return "\(osName) \(versionString)"
        }()
        
        let sdkVersion = "AliyunpanSDK/\(version)"

        let userAgent = "\(executable)/\(appVersion) (\(bundleId); build:\(appBuild); \(osNameVersion)) \(sdkVersion)"

        return .userAgent(userAgent)
    }
}

public struct HTTPHeaders {
    private var headers: [HTTPHeader] = []
    
    fileprivate var dictionary: [String: String] {
        Dictionary(
            headers.map { ($0.name, $0.value) }
        ) { first, _ in first }
    }
    
    init(_ headers: [HTTPHeader] = []) {
        self.headers = headers
    }
    
    public init(_ dictionary: [String: String]) {
        let headers = dictionary.compactMap { (name, value) in
            return HTTPHeader(name: name, value: value)
        }
        self = HTTPHeaders(headers)
    }
    
    mutating func add(_ header: HTTPHeader) {
        if let index = headers.firstIndex(where: { $0.name.lowercased() == header.name.lowercased() }) {
            headers.replaceSubrange(index...index, with: [header])
        } else {
            headers.append(header)
        }
    }
    
    mutating func remove(name: String) {
        guard let index = headers.firstIndex(where: { $0.name == name }) else {
            return
        }
        headers.remove(at: index)
    }
    
    func value(for name: String) -> String? {
        guard let header = headers.first(where: { $0.name == name }) else {
            return nil
        }
        return header.value
    }
    
    mutating func concat(_ headers: HTTPHeaders) {
        headers.headers.forEach {
            add($0)
        }
    }
    
    mutating func sort() {
        headers.sort { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    func sorted() -> HTTPHeaders {
        var headers = self
        headers.sort()
        return headers
    }
    
    subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let value = newValue {
                add(.init(name: name, value: value))
            } else {
                remove(name: name)
            }
        }
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

extension HTTPHeaders: Collection {
    public var startIndex: Int {
        headers.startIndex
    }

    public var endIndex: Int {
        headers.endIndex
    }

    public subscript(position: Int) -> HTTPHeader {
        headers[position]
    }

    public func index(after i: Int) -> Int {
        headers.index(after: i)
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements)
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        headers.map(\.description)
            .joined(separator: "\n")
    }
}

extension HTTPHeaders {
    static let `default`: HTTPHeaders = [
        HTTPHeader.defaultUserAgent,
        HTTPHeader.defaultContentType,
        HTTPHeader.defaultAcceptEncoding
    ]
}

extension URLRequest {
    var headers: HTTPHeaders {
        get {
            allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders()
        }
        set {
            allHTTPHeaderFields = newValue.dictionary
        }
    }
}

extension HTTPURLResponse {
    /// Returns `allHeaderFields` as `HTTPHeaders`.
    public var headers: HTTPHeaders {
        (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
    }
}
