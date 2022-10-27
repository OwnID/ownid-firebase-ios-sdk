import OwnIDCoreSDK
import Combine
import FirebaseAuth

public extension OwnID.FirebaseSDK {
    typealias EventPublisher = AnyPublisher<VoidOperationResult, OwnID.CoreSDK.Error>
}
