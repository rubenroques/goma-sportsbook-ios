
import Foundation

extension Notification.Name {

    static let socketConnected = Notification.Name("socketConnected")
    static let socketDisconnected = Notification.Name("socketDisconnected")

    static let userSessionConnected = Notification.Name("userSessionConnected")
    static let userSessionDisconnected = Notification.Name("userSessionDisconnected")
    static let userSessionForcedLogoutDisconnected = Notification.Name("userSessionForcedLogoutDisconnected")

}
