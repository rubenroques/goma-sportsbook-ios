
import Foundation

extension EveryMatrix {
    
    /// Response model for /sports#operatorInfo RPC call
    struct OperatorInfoResponse: Codable {
        let providerId: Int?
        let groupId: Int?
        let operatorId: Int?
        let apiVersion: Int?
        let ucsOperatorId: Int
        
        var operatorIdString: String {
            return String(ucsOperatorId)
        }
    }
    
    struct ClientIdentityResponse: Codable {
        let CID: String?
        let extendedCID: String?
        
        enum CodingKeys: String, CodingKey {
            case CID = "cid"
            case extendedCID = "cidEx"
        }
    }
    
}
