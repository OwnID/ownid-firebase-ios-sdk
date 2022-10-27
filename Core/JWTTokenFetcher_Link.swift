import OwnIDCoreSDK
import FirebaseAuth
import Combine

//extension User: JWTTokenFetcher {
//    public func fetchJWTToken() -> AnyPublisher<OwnID.CoreSDK.JWTToken, OwnID.CoreSDK.Error> {
//        Deferred {
//            Future<OwnID.CoreSDK.JWTToken, OwnID.CoreSDK.Error> { promise in
//                OwnID.CoreSDK.logger.logFirebase(.entry(Self.self))
//                self.getIDToken(completion: { token, error in
//                    if let error = error {
//                        OwnID.CoreSDK.logger.logFirebase(.errorEntry(message: error.localizedDescription, Self.self))
//                        promise(.failure(OwnID.CoreSDK.Error.plugin(error: OwnID.FirebaseSDK.Error.firebaseSDK(error: error))))
//                    }
//                    guard let token = token else { promise(.failure(OwnID.CoreSDK.Error.plugin(error: OwnID.FirebaseSDK.Error.tokenIsMissing))); return }
//                    let jwtToken = OwnID.CoreSDK.JWTToken.initFromPlain(string: token)
//                    OwnID.CoreSDK.logger.logFirebase(.entry(Self.self))
//                    promise(.success(jwtToken))
//                })
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//}
