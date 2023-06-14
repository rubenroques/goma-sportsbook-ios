//
//  File.swift
//  
//
//  Created by Ruben Roques on 28/02/2023.
//

import Foundation

enum SocketMessageParseHelper {

    static func extractEventId(_ inputString: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "\\[idfoevent=(\\d+(\\.\\d+)?)\\]")
        let range = NSRange(location: 0, length: inputString.utf16.count)
        if let match = regex.firstMatch(in: inputString, options: [], range: range) {
            let id = (inputString as NSString).substring(with: match.range(at: 1))
            return id
        }
        return nil
    }

    static func extractMarketId(_ inputString: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "\\[idfomarket=(\\d+(\\.\\d+)?)\\]")
        let range = NSRange(location: 0, length: inputString.utf16.count)
        if let match = regex.firstMatch(in: inputString, options: [], range: range) {
            let id = (inputString as NSString).substring(with: match.range(at: 1))
            return id
        }
        return nil
    }

    static func extractSelectionId(_ inputString: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "\\[idfoselection=(\\d+(\\.\\d+)?)\\]")
        let range = NSRange(location: 0, length: inputString.utf16.count)
        if let match = regex.firstMatch(in: inputString, options: [], range: range) {
            let id = (inputString as NSString).substring(with: match.range(at: 1))
            return id
        }
        return nil
    }

    static func extractMatchMinutes(from matchTime: String) -> String? {
        let pattern = #"(?<=^|\s)(\d{1,2}):(\d{2})(?:\s\+(\d{1,2}:\d{2}))?(?=$|\s)"#
        guard let range = matchTime.range(of: pattern, options: .regularExpression) else {
            return nil
        }

        let minuteString = String(matchTime[range])
        let components = minuteString.components(separatedBy: ":")
        let minutes = Int(components[0]) ?? 0

        if let extraTimeRange = minuteString.range(of: #"\s\+([\d:]+)"#, options: .regularExpression),
            let extraTime = Int(String(minuteString[extraTimeRange].dropFirst(2)).components(separatedBy: ":").first ?? "") {
            return "\(minutes)'+\(extraTime)"
        }

        return "\(minutes)'"
    }

    static func extractNodeId(_ inputString: String) -> String? {
        let regex = try! NSRegularExpression(pattern: "\\[idfwbonavigation=(\\d+(\\.\\d+)?)\\]")
        let range = NSRange(location: 0, length: inputString.utf16.count)
        if let match = regex.firstMatch(in: inputString, options: [], range: range) {
            let id = (inputString as NSString).substring(with: match.range(at: 1))
            return id
        }
        return nil
    }

}
