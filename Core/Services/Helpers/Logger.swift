//
//  Logger.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/08/2021.
//

import Foundation
import Combine

let Logger = LoggerService(destination: logsPath()) // swiftlint:disable:this identifier_name

func logsPath() -> URL {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    return docs.appendingPathComponent("logs_output.txt")
}

class LoggerService {

    enum LogType: String {
        case info
        case debug
        case warning
        case error
    }

    let destination: URL
    lazy fileprivate var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "HH:mm:ss.SSS"

        return formatter
    }()
    lazy fileprivate var fileHandle: FileHandle? = {
        let path = self.destination.path
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)

        do {
            let fileHandle = try FileHandle(forWritingTo: self.destination)
            return fileHandle
        }
        catch let error as NSError {
            print("Serious error in logging: could not open path to log file. \(error).")
        }

        return nil
    }()

    private var cancellables: Set<AnyCancellable>

    init(destination: URL) {
        self.destination = destination
        self.cancellables = []
    }

    deinit {
        fileHandle?.closeFile()
    }

    func log(_ message: String, _ logType: LogType = .info, file: String = #file, line: Int = #line) {

        let logMessage = stringRepresentation(message, file: file, line: line)

        var prefix = ""
        switch logType {
        case .info:
            prefix = "INFO "
        case .debug:
            prefix = "DEBG "
        case .warning:
            prefix = "WARN "
        case .error:
            prefix = "ERRO "
        }

        printToConsole("▫️" + prefix + logMessage)
        printToDestination(prefix + logMessage)

    }
}

private extension LoggerService {
    func stringRepresentation(_ message: String, file: String, line: Int) -> String {
        let dateString = dateFormatter.string(from: Date())

        let file = URL(fileURLWithPath: file).lastPathComponent
        return "\(dateString) [\(file)/\(line)] \(message)\n"
    }

    func printToConsole(_ logMessage: String) {
        print(logMessage, terminator: "")
    }

    func printToDestination(_ logMessage: String) {
        if let data = logMessage.data(using: String.Encoding.utf8) {
            fileHandle?.write(data)
        }
        else {
            print("Serious error in logging: could not encode logged string into data.")
        }
    }

    func printToServer(_ type: String, logMessage: String) {

//        Env.gomaNetworkClient.sendLog(type: type, message: logMessage)
//            .sink(receiveCompletion: { completion in
//
//            }, receiveValue: { response in
//
//            })
//            .store(in: &cancellables)

        // "ht tps://sportsbook-api.gomagaming.com" + logs

//        let urlString = TargetVariables.gomaGamingHost + "/logs/api/v1"
//        var request = URLRequest(url: URL(string: urlString)! )
//        request.httpMethod = "POST"
//
//        let bodyJSON = [
//            "type": type,
//            "text": logMessage
//        ]
//
//        let jsonData = try! JSONEncoder().encode(bodyJSON) // swiftlint:disable:this force_try
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTaskPublisher(for: request)
//            .sink(receiveCompletion: { _ in
//
//            })
//            { data, response  in
//                let stringData = String(data: data, encoding: .utf8)
//                print(stringData)
//            }
//            .store(in: &cancellables)

    }

}
