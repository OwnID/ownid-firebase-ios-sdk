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
        
        func login(payload: OwnID.CoreSDK.Payload, email: String) -> AnyPublisher<OperationResult, OwnID.CoreSDK.Error> {
            OwnID.FirebaseSDK.SignIn.signIn(payload: payload, auth: auth)
                .map { $0 as OperationResult }
                .eraseToAnyPublisher()
        }
    }
}

extension OwnID.FirebaseSDK.LoginPerformer: LoginPerformer { }

public extension OwnID.FirebaseSDK {
    enum SignIn {
        static func signIn(payload: OwnID.CoreSDK.Payload, auth: Auth) -> EventPublisher {
            Future<VoidOperationResult, OwnID.CoreSDK.Error> { promise in
                let idToken = (payload.dataContainer as? [String: Any])?["idToken"] as? String
                func handle(error: OwnID.FirebaseSDK.Error) {
                    OwnID.CoreSDK.logger.logFirebase(entry: .errorEntry(context: payload.context,
                                                                        message: "error: \(error.localizedDescription), idtoken: \(String(describing: idToken))",
                                                                        Self.self))
                    promise(.failure(.plugin(error: error)))
                }
                guard let idToken else { handle(error: .tokenIsMissing); return }
                auth.signIn(withCustomToken: idToken) { auth, error in
                    if let error {
                        handle(error: .firebaseSDK(error: error))
                    }
                    guard auth != nil else { handle(error: .firebaseAuthIsMissing); return }
                    OwnID.CoreSDK.logger.logFirebase(entry: .entry(context: payload.context, Self.self))
                    promise(.success(VoidOperationResult()))
                }
            }
            .eraseToAnyPublisher()
        }
    }
}
