import OwnIDCoreSDK
import FirebaseAuth
import FirebaseFirestore
import Combine

extension OwnID.FirebaseSDK {
    final class RegistrationPerformer {
        init(auth: Auth, firestore: Firestore) {
            self.auth = auth
            self.firestore = firestore
        }
        
        let auth: Auth
        let firestore: Firestore
        
        func register(configuration: OwnID.FlowsSDK.RegistrationConfiguration,
                      parameters: RegisterParameters) -> OwnID.RegistrationResultPublisher {
            OwnID.FirebaseSDK.register(auth: auth, db: firestore, configuration: configuration)
                .map { OwnID.RegisterResult(operationResult: $0 as OperationResult) }
                .eraseToAnyPublisher()
        }
    }
}

extension OwnID.FirebaseSDK.RegistrationPerformer: RegistrationPerformer { }

extension OwnID.FirebaseSDK {
    struct MetadataInfo: Decodable {
        let collectionName: String
        let docId: String
        let userIdKey: String
    }
}

extension OwnID.FirebaseSDK {
    static func register(auth: Auth, db: Firestore, configuration: OwnID.FlowsSDK.RegistrationConfiguration) -> EventPublisher {
        Future<VoidOperationResult, OwnID.CoreSDK.CoreErrorLogWrapper> { promise in
            func handle(error: OwnID.CoreSDK.Error) {
                promise(.failure(.coreLog(error: error, type: Self.self)))
            }
            
            OwnID.CoreSDK.logger.log(level: .debug, Self.self)
            
            guard let sessionData = configuration.payload.metadata,
                  let jsonData = try? JSONSerialization.data(withJSONObject: sessionData),
                  let metadata = try? JSONDecoder().decode(MetadataInfo.self, from: jsonData) else {
                handle(error: .userError(errorModel: OwnID.CoreSDK.UserErrorModel(message: ErrorMessage.metadataIsMissing)))
                return
            }
            
            guard var docData = configuration.payload.dataContainer as? [String: Any] else {
                handle(error: .userError(errorModel: OwnID.CoreSDK.UserErrorModel(message: ErrorMessage.metadataIsMissing)))
                return
            }
            
            auth.createUser(withEmail: configuration.payload.loginId ?? "",
                            password: OwnID.FlowsSDK.Password.generatePassword().passwordString) { auth, error in
                if let error {
                    handle(error: .integrationError(underlying: error))
                    return
                }
                guard let user = auth?.user else {
                    handle(error: .userError(errorModel: OwnID.CoreSDK.UserErrorModel(message: ErrorMessage.firebaseAuthIsMissing)))
                    return
                }
                
                docData[metadata.userIdKey] = user.uid
                db.collection(metadata.collectionName).document(metadata.docId).setData(docData) { error in
                    if let error {
                        handle(error: .integrationError(underlying: error))
                    } else {
                        promise(.success(VoidOperationResult()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
