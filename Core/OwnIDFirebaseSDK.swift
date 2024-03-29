import FirebaseAuth
import FirebaseFirestore
import Combine
import SwiftUI
@_exported import OwnIDCoreSDK

public extension OwnID.FirebaseSDK {
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
        public static func configure(supportedLanguages: [String] = Locale.preferredLanguages) {
            OwnID.CoreSDK.shared.configure(userFacingSDK: info(), underlyingSDKs: [], supportedLanguages: .init(rawValue: supportedLanguages))
        }
        
        /// Configures SDK from plist path URL
        public static func configure(plistUrl: URL, supportedLanguages: [String] = Locale.preferredLanguages) {
            OwnID.CoreSDK.shared.configureFor(plistUrl: plistUrl,
                                              userFacingSDK: info(),
                                              underlyingSDKs: [],
                                              supportedLanguages: .init(rawValue: supportedLanguages))
        }
        
        public static func configure(appID: OwnID.CoreSDK.AppID,
                                     redirectionURL: OwnID.CoreSDK.RedirectionURLString,
                                     environment: String? = .none,
                                     supportedLanguages: [String] = Locale.preferredLanguages) {
            OwnID.CoreSDK.shared.configure(appID: appID,
                                           redirectionURL: redirectionURL,
                                           userFacingSDK: info(),
                                           underlyingSDKs: [],
                                           environment: environment,
                                           supportedLanguages: .init(rawValue: supportedLanguages))
        }
        
        /// Handles redirects from other flows back to the app
        public static func handle(url: URL) {
            OwnID.CoreSDK.shared.handle(url: url, sdkConfigurationName: sdkName)
        }
        
        // MARK: View Model Flows
        
        public static func registrationViewModel(auth: Auth = .auth(),
                                                 firestore: Firestore = .firestore(),
                                                 loginIdPublisher: OwnID.CoreSDK.LoginIdPublisher) -> OwnID.FlowsSDK.RegisterView.ViewModel {
            let performer = RegistrationPerformer(auth: auth, firestore: firestore)
            let performerLogin = LoginPerformer(auth: auth, sdkConfigurationName: sdkName)
            return OwnID.FlowsSDK.RegisterView.ViewModel(registrationPerformer: performer,
                                                         loginPerformer: performerLogin,
                                                         sdkConfigurationName: sdkName,
                                                         loginIdPublisher: loginIdPublisher)
        }
        
        public static func createRegisterView(viewModel: OwnID.FlowsSDK.RegisterView.ViewModel,
                                              visualConfig: OwnID.UISDK.VisualLookConfig = .init()) -> OwnID.FlowsSDK.RegisterView {
            OwnID.FlowsSDK.RegisterView(viewModel: viewModel, visualConfig: visualConfig)
        }
        
        public static func loginViewModel(auth: Auth = .auth(),
                                          loginIdPublisher: OwnID.CoreSDK.LoginIdPublisher) -> OwnID.FlowsSDK.LoginView.ViewModel {
            let performer = LoginPerformer(auth: auth, sdkConfigurationName: sdkName)
            return OwnID.FlowsSDK.LoginView.ViewModel(loginPerformer: performer,
                                                      sdkConfigurationName: sdkName,
                                                      loginIdPublisher: loginIdPublisher)
        }
        
        public static func createLoginView(viewModel: OwnID.FlowsSDK.LoginView.ViewModel,
                                           visualConfig: OwnID.UISDK.VisualLookConfig = .init()) -> OwnID.FlowsSDK.LoginView {
            OwnID.FlowsSDK.LoginView(viewModel: viewModel, visualConfig: visualConfig)
        }
        
        public static func showInstantConnectView(viewModel: OwnID.FlowsSDK.LoginView.ViewModel,
                                                  sdkConfigurationName: String = sdkName,
                                                  visualConfig: OwnID.UISDK.VisualLookConfig = .init()) {
//            OwnID.UISDK.showInstantConnectView(viewModel: viewModel, visualConfig: visualConfig)
        }
    }
}
