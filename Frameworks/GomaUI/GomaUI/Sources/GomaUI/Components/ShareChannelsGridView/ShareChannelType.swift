import Foundation
import UIKit

public enum ShareChannelType: String, CaseIterable, Identifiable {
    case twitter
    case whatsApp
    case facebook
    case telegram
    case messenger
    case viber
    case sms
    case email

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .twitter:
            return "Twitter"
        case .whatsApp:
            return "WhatsApp"
        case .facebook:
            return "Facebook"
        case .telegram:
            return "Telegram"
        case .messenger:
            return "Messenger"
        case .viber:
            return "Viber"
        case .sms:
            return "SMS"
        case .email:
            return "Email"
        }
    }

    public var iconName: String {
        switch self {
        case .twitter:
            return "twitter_icon"
        case .whatsApp:
            return "whatsapp_icon"
        case .facebook:
            return "facebook_icon"
        case .telegram:
            return "telegram_icon"
        case .messenger:
            return "messenger_icon"
        case .viber:
            return "viber_icon"
        case .sms:
            return "message.circle.fill"
        case .email:
            return "envelope.circle.fill"
        }
    }

    public var backgroundColor: UIColor {
        switch self {
        case .twitter:
            return UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
        case .whatsApp:
            return UIColor(red: 37/255, green: 211/255, blue: 102/255, alpha: 1.0)
        case .facebook:
            return UIColor(red: 24/255, green: 119/255, blue: 242/255, alpha: 1.0)
        case .telegram:
            return UIColor(red: 34/255, green: 173/255, blue: 225/255, alpha: 1.0)
        case .messenger:
            return UIColor(red: 0/255, green: 132/255, blue: 255/255, alpha: 1.0)
        case .viber:
            return UIColor(red: 115/255, green: 79/255, blue: 150/255, alpha: 1.0)
        case .sms:
            return UIColor(red: 82/255, green: 196/255, blue: 26/255, alpha: 1.0)
        case .email:
            return UIColor(red: 88/255, green: 166/255, blue: 255/255, alpha: 1.0)
        }
    }

    public var urlScheme: String? {
        switch self {
        case .twitter:
            return "twitter://"
        case .whatsApp:
            return "whatsapp://"
        case .facebook:
            return "fb://"
        case .telegram:
            return "tg://"
        case .messenger:
            return "fb-messenger://"
        case .viber:
            return "viber://"
        case .sms:
            return "sms:"
        case .email:
            return "mailto:"
        }
    }
}
