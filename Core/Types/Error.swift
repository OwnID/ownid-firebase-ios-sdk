import OwnIDCoreSDK
import Foundation

public extension OwnID.FirebaseSDK {
    enum Error: PluginError {
        case firebaseSDK(error: Swift.Error)
        case firebaseAuthIsMissing
        case emailIsNotValid
        case passwordIsNotValid
        case mainSDKCancelled
        case tokenIsMissing
        case metadataIsMissing
    }
}

extension OwnID.FirebaseSDK.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .firebaseSDK(error: let error):
            return error.localizedDescription
        case .emailIsNotValid:
            return "Email is not valid"
        case .passwordIsNotValid:
            return "Password is not valid"
        case .mainSDKCancelled:
            return "Cancelled"
        case .tokenIsMissing:
            return "Token is missing"
        case .firebaseAuthIsMissing:
            return "Auth is missing"
        case .metadataIsMissing:
            return "Metadata is missing"
        }
    }
}
