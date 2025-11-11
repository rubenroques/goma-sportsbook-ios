
import Foundation

extension EveryMatrix {

    /// Lightweight struct for pre-parsing Casino API error responses
    /// Casino API returns HTTP 200 with error details in the response body (not 401/403 status codes)
    struct CasinoAPIErrorCheck: Decodable {
        let success: Bool?
        let errorCode: Int?
        let errorMessage: String?
    }
}
