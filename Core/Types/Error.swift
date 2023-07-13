import OwnIDCoreSDK
import Foundation

public extension OwnID.FirebaseSDK {
    enum ErrorMessage {
        static let firebaseAuthIsMissing = "Auth is missing"
        static let tokenIsMissing = "Token is missing"
        static let metadataIsMissing = "Metadata is missing"
    }
}
