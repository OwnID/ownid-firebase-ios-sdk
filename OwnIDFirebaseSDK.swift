@_exported import OwnIDCoreSDK
@_exported import OwnIDUISDK
import FirebaseAuth
import FirebaseFirestore
import Combine
import SwiftUI

extension OwnID.FirebaseSDK {
    static let sdkName = "Firebase"
    static let version = "1.0.1"
}

public extension OwnID {
    final class FirebaseSDK {
        
        // MARK: Setup
        
        public static func info() -> OwnID.CoreSDK.SDKInformation {
            (sdkName, version)
        }
        
        /// Standart configuration, searches for default .plist file
        public static func configure() {
            OwnID.CoreSDK.shared.configure(userFacingSDK: info(), underlyingSDKs: [])
        }
        
        /// Configures SDK from URL
        /// - Parameter plistUrl: Config plist URL
        public static func configure(plistUrl: URL) {
            OwnID.CoreSDK.shared.configureFor(plistUrl: plistUrl, userFacingSDK: info(), underlyingSDKs: [])
        }
        
        /// Configures SDK from parameters
        /// - Parameters:
        ///   - serverURL: ServerURL
        ///   - redirectionURL: RedirectionURL
        public static func configure(appID: String, redirectionURL: String, environment: String? = .none) {
            OwnID.CoreSDK.shared.configure(appID: appID,
                                           redirectionURL: redirectionURL,
                                           userFacingSDK: info(),
                                           underlyingSDKs: [],
                                           environment: environment)
        }
        
        /// Used to handle the redirects from browser after webapp is finished
        /// - Parameter url: URL returned from webapp after it has finished
        public static func handle(url: URL) {
            OwnID.CoreSDK.shared.handle(url: url, sdkConfigurationName: sdkName)
        }
        
        // MARK: View Model Flows
        
        /// Creates view model for register flow in Firebase and manages ``OwnID.FlowsSDK.RegisterView``
        /// - Parameters:
        ///   - auth: Firebase Auth
        /// - Returns: View model for register flow
        public static func registrationViewModel(webLanguages: OwnID.CoreSDK.Languages = .init(rawValue: Locale.preferredLanguages),
                                                 auth: Auth = .auth(),
                                                 firestore: Firestore = .firestore()) -> OwnID.FlowsSDK.RegisterView.ViewModel {
            let performer = RegistrationPerformer(auth: auth, firestore: firestore)
            return OwnID.FlowsSDK.RegisterView.ViewModel(registrationPerformer: performer,
                                                         sdkConfigurationName: sdkName,
                                                         webLanguages: webLanguages)
        }
        
        /// View that encapsulates management of ``OwnID.CoreSDK.SkipPasswordView`` state
        /// - Parameter viewModel: ``OwnID.FlowsSDK.RegisterView.ViewModel``
        /// - Parameter webLanguages: Languages for web view. List of well-formed [IETF BCP 47 language tag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language) .
        /// - Parameter email: to be used toregister. Displayed when logging in
        /// - Parameter visualConfig: contains information about how views will look like
        /// - Parameter shouldImmidiatelyShowTooltip: provides direct control over if tooltip popover should be displayed
        /// - Returns: View to display
        public static func createRegisterView(viewModel: OwnID.FlowsSDK.RegisterView.ViewModel,
                                              email: Binding<String>,
                                              visualConfig: OwnID.UISDK.VisualLookConfig = .init(),
                                              shouldImmidiatelyShowTooltip: Binding<Bool>? = .none) -> OwnID.FlowsSDK.RegisterView {
            OwnID.FlowsSDK.RegisterView(viewModel: viewModel,
                                        usersEmail: email,
                                        visualConfig: visualConfig,
                                        shouldImmidiatelyShowTooltip: shouldImmidiatelyShowTooltip)
        }
        
        /// Creates view model for login flow in Firebase and manages ``OwnID.FlowsSDK.LoginView``
        /// - Parameters:
        ///   - auth: Firebase Auth
        ///   - webLanguages: Languages for web view. List of well-formed [IETF BCP 47 language tag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language) .
        /// - Returns: View model for log in
        public static func loginViewModel(auth: Auth = .auth(),
                                          webLanguages: OwnID.CoreSDK.Languages = .init(rawValue: Locale.preferredLanguages)) -> OwnID.FlowsSDK.LoginView.ViewModel {
            let performer = LoginPerformer(auth: auth, sdkConfigurationName: sdkName)
            return OwnID.FlowsSDK.LoginView.ViewModel(loginPerformer: performer,
                                                      sdkConfigurationName: sdkName,
                                                      webLanguages: webLanguages)
        }
        
        /// View that encapsulates management of ``OwnID.CoreSDK.SkipPasswordView`` state
        /// - Parameter viewModel: ``OwnID.FlowsSDK.LoginView.ViewModel``
        /// - Parameter usersEmail: Email to be used in link and login flow. Displayed when logging in
        /// - Parameter visualConfig: contains information about how views will look like
        /// - Parameter shouldImmidiatelyShowTooltip: provides direct control over if tooltip popover should be displayed
        /// - Returns: View to display
        public static func createLoginView(viewModel: OwnID.FlowsSDK.LoginView.ViewModel,
                                           usersEmail: Binding<String>,
                                           visualConfig: OwnID.UISDK.VisualLookConfig = .init(),
                                           shouldImmidiatelyShowTooltip: Binding<Bool>? = .none) -> OwnID.FlowsSDK.LoginView {
            OwnID.FlowsSDK.LoginView(viewModel: viewModel,
                                     usersEmail: usersEmail,
                                     visualConfig: visualConfig,
                                     shouldImmidiatelyShowTooltip: shouldImmidiatelyShowTooltip)
        }
    }
}
