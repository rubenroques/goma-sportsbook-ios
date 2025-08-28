
import Foundation
import Extensions

public struct GomaAPIClientConfiguration {
    
    enum Environment {
        case betsson
        case gomaDemo
        case development
    }
    
    var environment: Environment
    public static var shared = GomaAPIClientConfiguration(environment: .development)
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    public var apiHostname: String {
        switch self.environment {
        case .betsson: return "https://api.gomademo.com/"
        case .gomaDemo, .development: return "https://api.gomademo.com/"
        }
    }
    
    public var instanceBusinessUnitToken: String {
        switch self.environment {
        case .betsson: return "i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi"
        case .gomaDemo: return "oSxUgVW5VdFmRpn1k8ve6XExaqyiQjN0z4XDfd8iqOhSDvufVCj0pBs5NLZVeHSu"
        case .development: return "oSxUgVW5VdFmRpn1k8ve6XExaqyiQjN0z4XDfd8iqOhSDvufVCj0pBs5NLZVeHSu"
        }
    }
    
    
}
