import FirebaseAuth
import FirebaseFirestore
import Combine
import SwiftUI
@_exported import OwnIDCoreSDK

extension OwnID.FirebaseSDK {
    static let sdkName = "Firebase"
    static let version = "2.2.0"
}

public extension OwnID {
    final class FirebaseSDK {
        
        // MARK: Setup
        
        public static func info() -> OwnID.CoreSDK.SDKInformation {
            (sdkName, version)
        }
        
        /// Standart configuration, searches for default .plist file
        public static func configure(supportedLanguages: OwnID.CoreSDK.Languages = .init(rawValue: Locale.preferredLanguages)) {
            OwnID.CoreSDK.shared.configure(userFacingSDK: info(), underlyingSDKs: [], supportedLanguages: supportedLanguages)
        }
        
        /// Configures SDK from URL
        /// - Parameter plistUrl: Config plist URL
        public static func configure(plistUrl: URL, supportedLanguages: OwnID.CoreSDK.Languages = .init(rawValue: Locale.preferredLanguages)) {
            OwnID.CoreSDK.shared.configureFor(plistUrl: plistUrl, userFacingSDK: info(), underlyingSDKs: [], supportedLanguages: supportedLanguages)
        }
        
        /// Configures SDK from parameters
        /// - Parameters:
        ///   - serverURL: ServerURL
        ///   - redirectionURL: RedirectionURL
        public static func configure(appID: String,
                                     redirectionURL: String,
                                     environment: String? = .none,
                                     supportedLanguages: OwnID.CoreSDK.Languages = .init(rawValue: Locale.preferredLanguages)) {
            OwnID.CoreSDK.shared.configure(appID: appID,
                                           redirectionURL: redirectionURL,
                                           userFacingSDK: info(),
                                           underlyingSDKs: [],
                                           environment: environment,
                                           supportedLanguages: supportedLanguages)
        }
        
        /// Used to handle the redirects from browser after webapp is finished
        /// - Parameter url: URL returned from webapp after it has finished
        public static func handle(url: URL) {
            OwnID.CoreSDK.shared.handle(url: url, sdkConfigurationName: sdkName)
        }
        
        // MARK: View Model Flows
        
        /// 
        /// - Parameters:
        ///   - auth: Firebase Auth
        ///   - firestore: Firestore
        public static func registrationViewModel(auth: Auth = .auth(),
                                                 firestore: Firestore = .firestore(),
                                                 emailPublisher: AnyPublisher<String, Never>) -> OwnID.FlowsSDK.RegisterView.ViewModel {
            let performer = RegistrationPerformer(auth: auth, firestore: firestore)
            let performerLogin = LoginPerformer(auth: auth, sdkConfigurationName: sdkName)
            return OwnID.FlowsSDK.RegisterView.ViewModel(registrationPerformer: performer,
                                                         loginPerformer: performerLogin,
                                                         sdkConfigurationName: sdkName,
                                                         emailPublisher: emailPublisher)
        }
        
        ///
        public static func createRegisterView(viewModel: OwnID.FlowsSDK.RegisterView.ViewModel,
                                              visualConfig: OwnID.UISDK.VisualLookConfig = .init()) -> OwnID.FlowsSDK.RegisterView {
            OwnID.FlowsSDK.RegisterView(viewModel: viewModel, visualConfig: visualConfig)
        }
        
        ///
        /// - Parameters:
        ///   - auth: Firebase Auth
        public static func loginViewModel(auth: Auth = .auth(),
                                          emailPublisher: AnyPublisher<String, Never>) -> OwnID.FlowsSDK.LoginView.ViewModel {
            let performer = LoginPerformer(auth: auth, sdkConfigurationName: sdkName)
            return OwnID.FlowsSDK.LoginView.ViewModel(loginPerformer: performer,
                                                      sdkConfigurationName: sdkName,
                                                      emailPublisher: emailPublisher)
        }
        
        ///
        public static func createLoginView(viewModel: OwnID.FlowsSDK.LoginView.ViewModel,
                                           visualConfig: OwnID.UISDK.VisualLookConfig = .init()) -> OwnID.FlowsSDK.LoginView {
            OwnID.FlowsSDK.LoginView(viewModel: viewModel, visualConfig: visualConfig)
        }
    }
}
