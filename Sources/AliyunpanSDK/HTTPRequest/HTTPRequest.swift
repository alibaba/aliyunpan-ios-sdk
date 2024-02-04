//
//  HTTPRequest.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/11/21.
//

import Foundation

extension Dictionary where Key == String {
    fileprivate func jsonToQueryItems() -> [URLQueryItem] {
        keys.sorted(by: <).compactMap { key -> [URLQueryItem]? in
            guard let value = self[key] else {
                return nil
            }
            if let arrayValue = value as? [Any] {
                return arrayValue.map {
                    URLQueryItem(name: "\(key)[]", value: "\($0)")
                }
            } else {
                return [URLQueryItem(name: key, value: "\(value)")]
            }
        }.flatMap { $0 }
    }
}

extension OperationQueue {
    convenience init(
        name: String,
        qualityOfService: QualityOfService = .default,
        maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
        self.init()
        self.qualityOfService = qualityOfService
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.name = name
    }
}

extension OperationQueue {
    static let rootQueue = OperationQueue(name: "com.aliyunpanSDK.session.rootQueue")
}

extension URLSession {
    static let rootSession = URLSession(configuration: .default)
}

class HTTPRequest<Command: AliyunpanCommand> {
    private var headers = HTTPHeaders.default
    private var decoder = JSONParameterDecoder.default
    private var serializationQueue = OperationQueue.rootQueue
    private var urlSession = URLSession.rootSession

    private let command: Command
    
    init(command: Command) {
        self.command = command
    }
    
    func headers(_ headers: HTTPHeaders) -> Self {
        self.headers.concat(headers)
        return self
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = try? AliyunpanURL(uri: command.uri).asURL() else {
            throw AliyunpanError.NetworkSystemError.invalidURL
        }
        var urlRequest = URLRequest(url: url)
        // set httpMethod
        urlRequest.httpMethod = command.httpMethod.rawValue
        // set headerField
        urlRequest.headers = headers
        // set parameters
        if let requestData = command.requestData {
            if command.httpMethod == .post {
                urlRequest.httpBody = requestData
            } else {
                if let json = try? JSONSerialization.jsonObject(with: requestData) as? [String: Any] {
                    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        let queryItems = json.jsonToQueryItems()
                        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
                        urlRequest.url = urlComponents.url
                    }
                }
            }
        }
        return urlRequest
    }
    
    func responseData() async throws -> Data {
        let urlRequest = try asURLRequest()
        Logger.log(.debug, msg: DebugDescription.description(of: urlRequest))
        let (data, response) = try await urlSession.data(for: urlRequest)
        Logger.log(.debug, msg: DebugDescription.description(of: response, data: data))
                
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            if let error = try? decoder.decode(AliyunpanError.ServerError.self, from: data) {
                throw error
            } else {
                throw AliyunpanError.NetworkSystemError.httpError(statusCode: response.statusCode, data: data, response: response)
            }
        }
        return data
    }
    
    func response() async throws -> Command.Response {
        let data = try await responseData()
        return try decoder.decode(Command.Response.self, from: data)
    }
}
