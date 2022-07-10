import Foundation
import OwnIDCoreSDK

extension OwnID.FirebaseSDK {
    public class FlowLogEntry: OwnID.CoreSDK.StandardMetricLogEntry {
        internal init(context: String,
                      requestPath: String? = .none,
                      logLevel: OwnID.CoreSDK.LogLevel = .information,
                      message: String,
                      codeInitiator: String) {
            super.init(context: context,
                       requestPath: requestPath,
                       level: logLevel,
                       message: message,
                       codeInitiator: codeInitiator,
                       sdkName: OwnID.FirebaseSDK.sdkName,
                       version: OwnID.FirebaseSDK.version)
        }
    }
}

public extension OwnID.FirebaseSDK.FlowLogEntry {
    static func entry<T>(function: String = #function, file: String = #file, context: String = "empty", message: String = "", _ : T.Type = T.self) -> OwnID.FirebaseSDK.FlowLogEntry {
        OwnID.FirebaseSDK.FlowLogEntry(context: context, message: "\(message) \(function) \(file)", codeInitiator: String(describing: T.self))
    }
    
    static func errorEntry<T>(function: String = #function, file: String = #file, context: String = "empty", message: String = "", _ : T.Type = T.self) -> OwnID.FirebaseSDK.FlowLogEntry {
        OwnID.FirebaseSDK.FlowLogEntry(context: context, logLevel: .error, message: "\(message) \(function) \(file)", codeInitiator: String(describing: T.self))
    }
}

extension LoggerProtocol {
    func logFirebase(entry: OwnID.FirebaseSDK.FlowLogEntry) {
        self.log(entry)
    }
}
