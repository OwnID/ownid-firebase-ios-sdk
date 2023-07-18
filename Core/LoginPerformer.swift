import OwnIDCoreSDK
import FirebaseAuth
import Combine

extension OwnID.FirebaseSDK {
    final class LoginPerformer {
        private let auth: Auth
        private let sdkConfigurationName: String
        
        init(auth: Auth, sdkConfigurationName: String) {
            self.auth = auth
            self.sdkConfigurationName = sdkConfigurationName
        }
        
        func login(payload: OwnID.CoreSDK.Payload, loginId: String) -> OwnID.LoginResultPublisher {
            OwnID.FirebaseSDK.SignIn.signIn(payload: payload, auth: auth)
                .map { OwnID.LoginResult(operationResult: $0 as OperationResult) }
                .eraseToAnyPublisher()
        }
    }
}

extension OwnID.FirebaseSDK.LoginPerformer: LoginPerformer { }

public extension OwnID.FirebaseSDK {
    private enum Constants {
        static let idTokenKey = "idToken"
    }
    
    enum SignIn {
        static func signIn(payload: OwnID.CoreSDK.Payload, auth: Auth) -> EventPublisher {
            Future<VoidOperationResult, OwnID.CoreSDK.CoreErrorLogWrapper> { promise in
                let idToken = (payload.dataContainer as? [String: Any])?[Constants.idTokenKey] as? String
                func handle(error: OwnID.CoreSDK.Error) {
                    promise(.failure(.coreLog(error: error, type: Self.self)))
                }
                guard let idToken else {
                    handle(error: .userError(errorModel: OwnID.CoreSDK.UserErrorModel(message: ErrorMessage.tokenIsMissing)))
                    return
                }
                auth.signIn(withCustomToken: idToken) { auth, error in
                    if let error {
                        handle(error: .integrationError(underlying: error))
                    }
                    guard auth != nil else {
                        handle(error: .userError(errorModel: OwnID.CoreSDK.UserErrorModel(message: ErrorMessage.firebaseAuthIsMissing)))
                        return
                    }
                    OwnID.CoreSDK.logger.log(level: .debug, Self.self)
                    promise(.success(VoidOperationResult()))
                }
            }
            .eraseToAnyPublisher()
        }
    }
}
