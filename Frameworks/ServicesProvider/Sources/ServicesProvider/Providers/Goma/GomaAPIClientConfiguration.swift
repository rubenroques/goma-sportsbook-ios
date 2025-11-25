
import Foundation
import Extensions

public struct GomaAPIClientConfiguration {
    
    enum Environment {
        case betsson
        case betssonCameroon
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
        case .betssonCameroon: return "https://cms.betssonem.com/"
        case .gomaDemo: return "https://api.gomademo.com/"
        case .development: return "https://api.gomademo.com/"
        }
    }
    
    public var instanceBusinessUnitToken: String {
        switch self.environment {
        case .betsson: return "i4iStOcZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSvqPNhi"
        case .betssonCameroon: return "B8kLrPdZWBFbrmWvwaccKpdVhyRpRB6uZGE9akT6IFMpSwIa0Ghl4lqsFSFsUYcI"
        case .gomaDemo: return "oSxUgVW5VdFmRpn1k8ve6XExaqyiQjN0z4XDfd8iqOhSDvufVCj0pBs5NLZVeHSu"
        case .development: return "oSxUgVW5VdFmRpn1k8ve6XExaqyiQjN0z4XDfd8iqOhSDvufVCj0pBs5NLZVeHSu"
        }
    }
        
}
