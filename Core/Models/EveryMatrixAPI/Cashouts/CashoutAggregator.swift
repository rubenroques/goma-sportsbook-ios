//
//  CashoutAggregator.swift
//  Sportsbook
//
//  Created by André Lascas on 11/01/2022.
//

import Foundation

extension EveryMatrix {

    enum CashoutAggregatorContentType {
        case update(content: [CashoutContentUpdate])
        case initialDump(content: [CashoutContent])
    }

    struct CashoutAggregator: Decodable {

        var messageType: CashoutAggregatorContentType

        enum CodingKeys: String, CodingKey {
            case content = "records"
            case messageType = "messageType"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let messageTypeString = try container.decode(String.self, forKey: .messageType)
            if messageTypeString == "UPDATE" {
                let rawItems = try container.decode([FailableDecodable<CashoutContentUpdate>].self, forKey: .content).compactMap({ $0.base })
                let filteredItems = rawItems.filter({
                    if case .unknown = $0 {
                        return false
                      }
                      return true
                })
                messageType = .update(content: filteredItems)
            }
            else if messageTypeString == "INITIAL_DUMP" {
                let items = try container.decode([FailableDecodable<CashoutContent>].self, forKey: .content).compactMap({ $0.base })
                messageType = .initialDump(content: items)
            }
            else {
                messageType = .update(content: [])
            }
        }

        var content: [CashoutContent]? {
            switch self.messageType {
            case .initialDump(let content):
                return content
            default: return nil
            }
        }

        var contentUpdates: [CashoutContentUpdate]? {
            switch self.messageType {
            case .update(let contents):
                return contents
            default: return nil
            }
        }
    }

    ///
    enum CashoutContentUpdateError: Error {
        case uknownUpdateType
        case invalidUpdateFormat
    }

    enum CashoutContentUpdate: Decodable {
        // UPDATES
        case cashoutUpdate(id: String, value: Double?, stake: Double?)
        // CREATES
        case cashoutCreate(cashout: EveryMatrix.Cashout)
        case cashoutDelete(cashoutId: String)
        case unknown(typeName: String)

        enum CodingKeys: String, CodingKey {
            case type = "_type"
            case changeType = "changeType"
            case entityType = "entityType"
            case contentId = "id"
            case oddValue = "odds"
            case changedProperties = "changedProperties"
            case entity = "entity"
        }

        enum CashoutCodingKeys: String, CodingKey {
            case value = "value"
            case stake = "stake"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard
                let changeTypeString = try? container.decode(String.self, forKey: .changeType),
                let entityTypeString = try? container.decode(String.self, forKey: .entityType)
            else {
                throw CashoutContentUpdateError.uknownUpdateType
            }

            self = .unknown(typeName: entityTypeString)

            var contentUpdateType: CashoutContentUpdate?

            if changeTypeString == "UPDATE", let contentId = try? container.decode(String.self, forKey: .contentId) {

                if entityTypeString == "CASHOUT" {
                    if let changedPropertiesContainer = try? container.nestedContainer(keyedBy: CashoutCodingKeys.self, forKey: .changedProperties) {

                        let value = try? changedPropertiesContainer.decode(Double.self, forKey: .value)
                        let stake = try? changedPropertiesContainer.decode(Double.self, forKey: .stake)
                        self = .cashoutUpdate(id: contentId, value: value, stake: stake)

                        contentUpdateType = self

                    }
                }

            }
            else if changeTypeString == "CREATE", let contentId = try? container.decode(String.self, forKey: .contentId) {
                if entityTypeString == "CASHOUT" {

                    if let cashout = try? container.decode(EveryMatrix.Cashout.self, forKey: .entity) {
                        contentUpdateType = .cashoutCreate(cashout: cashout)

                    }
                }
            }
            else if changeTypeString == "DELETE", let contentId = try? container.decode(String.self, forKey: .contentId) {
                contentUpdateType = .cashoutDelete(cashoutId: contentId)
            }

            if let contentUpdateTypeValue = contentUpdateType {
                self = contentUpdateTypeValue
            }
            else {
                self = .unknown(typeName: entityTypeString)
            }

        }

    }

    ///

    enum CashoutContent: Decodable {

        case cashout(EveryMatrix.Cashout)
        case unknown

        enum CodingKeys: String, CodingKey {
            case type = "_type"
        }

        enum CashoutContentTypeKey: String, Decodable {

            case cashout = "CASHOUT"
            case unknown

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let type = try container.decode(String.self)
                if let contentTypeKey = CashoutContentTypeKey(rawValue: type) {
                    self = contentTypeKey
                }
                else {
                    self = .unknown
                }
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard let type = try? container.decode(CashoutContentTypeKey.self, forKey: .type) else {
                self = .unknown
                return
            }

            let objectContainer = try decoder.singleValueContainer()

            switch type {

            case .cashout:
                let cashout = try objectContainer.decode(EveryMatrix.Cashout.self)
                self = .cashout(cashout)

            case .unknown:
                self = .unknown
            }
        }
    }

}
