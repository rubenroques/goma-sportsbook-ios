//
//  File.swift
//  
//
//  Created by Ruben Roques on 21/12/2023.
//

import Foundation

enum GomaModels {
    
    struct GomaResponse<T: Codable>: Codable {
        let message: String?
        let data: T
        
        enum CodingKeys: String, CodingKey {
            case message = "message"
            case data = "data"
            
        }
        
    }
    
    struct BasicRegisterResponse: Codable {
        
        let id: Int
        let email: String
        let username: String
        let name: String
        let deviceId: String?
        let deviceType: String?
        let type: String?
        let code: String?
        let avatar: String?
        let createdAt: String?
        let updatedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case email = "email"
            case username = "username"
            case name = "name"
            case deviceId = "device_uuid"
            case deviceType = "device_type"
            case type = "type"
            case code = "code"
            case avatar = "avatar"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            
        }
    }
    
    struct LoginResponse: Codable {
        let message: String?
        let data: LoginData
        
        enum CodingKeys: String, CodingKey {
            case message = "message"
            case data = "data"
        }
    }
    
    struct LoginData: Codable {
        let token: String
        let expires: Int?
        let userData: BasicRegisterResponse
        
        enum CodingKeys: String, CodingKey{
            case token = "token"
            case expires = "expires_at"
            case userData = "user"
        }
    }
    
    struct AnonymousLoginResponse: Codable {
        let token: String
        
        enum CodingKeys: String, CodingKey {
            case token = "token"
        }
    }
    
    struct LogoutResponse: Codable {
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case message = "message"
        }
    }
    
    struct FavoriteItem: Codable {
        let id: Int
        let userId: Int
        let favoriteId: Int
        let type: FavorityItemType
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case userId = "user_id"
            case favoriteId = "favorite_id"
            case type = "favorite_type"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.userId = try container.decode(Int.self, forKey: .userId)
            self.favoriteId = try container.decode(Int.self, forKey: .favoriteId)
            
            let typeString = try container.decode(String.self, forKey: .type)
            
            if let favoriteItemType = FavorityItemType(typeString: typeString) {
                self.type = favoriteItemType
            } else {
                self.type = .event
            }
        }
        
    }
    
    enum FavorityItemType: Codable {
        case event
        case competition
        
        init?(typeString: String) {
            switch typeString {
            case "event":
                self = .event
            case "competition":
                self = .competition
            default:
                return nil
            }
        }
        
        var typeString: String {
            switch self {
            case .event:
                return "event"
            case .competition:
                return "competition"
            }
        }
    }
    
    struct FavoriteItemAddResponse: Codable {
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case message = "message"
        }
    }
    
    struct FavoriteItemDeleteResponse: Codable {
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case message = "message"
        }
    }
}
