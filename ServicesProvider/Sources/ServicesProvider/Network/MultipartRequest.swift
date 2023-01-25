//
//  MultipartRequest.swift
//  
//
//  Created by André Lascas on 25/01/2023.
//

import Foundation

public struct MultipartRequest {

    public let boundary: String

    private let separator: String = "\r\n"
    private var data: Data

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = .init()
    }

    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }

    private mutating func appendSeparator() {
        data.append(separator)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }

    public mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    public var httpContentTypeHeaderValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }
}

public func mimeType(for data: Data) -> String {

    var b: UInt8 = 0
    data.copyBytes(to: &b, count: 1)

    switch b {
    case 0xFF:
        return "image/jpeg"
    case 0x89:
        return "image/png"
    case 0x47:
        return "image/gif"
    case 0x4D, 0x49:
        return "image/tiff"
    case 0x25:
        return "application/pdf"
    case 0xD0:
        return "application/vnd"
    case 0x46:
        return "text/plain"
    default:
        return "application/octet-stream"
    }
}

public extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
