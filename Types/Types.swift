import OwnIDCoreSDK
import Combine
import FirebaseAuth
import OwnIDFlowsSDK

public extension OwnID.FirebaseSDK {
    typealias EventPublisher = AnyPublisher<VoidOperationResult, OwnID.CoreSDK.Error>
}
