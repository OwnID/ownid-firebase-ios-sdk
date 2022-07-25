# OwnID Firebase-iOS SDK
The OwnID Firebase-iOS SDK is a client library written in Swift that provides a passwordless login alternative for your iOS application by using cryptographic keys to replace the traditional password. Integrating the SDK with your iOS app adds a Skip Password option to its registration and login screens. For more general information about OwnID SDKs, see [OwnID iOS SDK](../README.md).

## Table of contents
* [Before You Begin](#before-you-begin)
* [Add Package Dependency](#add-package-dependency)
* [Add Property List File to Project](#add-property-list-file-to-project)
* [Create URL Type (Custom URL Scheme)](#create-url-type-custom-url-scheme)
* [Import OwnID Modules](#import-ownid-modules)
* [Initialize the SDK](#initialize-the-sdk)
* [Implement the Registration Screen](#implement-the-registration-screen)
  + [Customize View Model](#customize-view-model)
  + [Add the OwnID View](#add-the-ownid-view)
* [Implement the Login Screen](#implement-the-login-screen)
  + [Customize View Model](#customize-view-model-1)
  + [Add OwnID View](#add-ownid-view)
* [Errors](#errors)
* [Advanced Configuration](#advanced-configuration)
  + [Alternative Syntax for Configure Function 🎛](#alternative-syntax-for-configure-function-)
  + [OwnID Web App language](#ownid-web-app-language)
  + [Directing Users to the OwnID iOS App](#directing-users-to-the-ownid-ios-app)
* [Logging](#logging)

## Before You Begin
Before incorporating OwnID into your iOS app, you must create an OwnID application and integrate it with your Firebase project. For step-by-step instructions, see [OwnID-Firebase Integration Basics](firebase-integration-basics.md).

In addition, ensure you have done everything to [add Firebase authentication to your iOS project](https://firebase.google.com/docs/ios/setup).

## Add Package Dependency
The OwnID iOS SDK is distributed as an SPM package. Use the Swift Package Manager to add the following package dependency to your project:

```
https://github.com/OwnID/ownid-ios-sdk
```
When prompted, select the **OwnIDFirebaseSDK** product.

## Add Property List File to Project

When the application starts, the OwnID SDK automatically reads `OwnIDConfiguration.plist` from the file system to configure the default instance that is created. At a minimum, this PLIST file defines a redirection URI and unique app id. Create `OwnIDConfiguration.plist` and define the following mandatory parameters:

[Complete example](../Demo/FirebaseDemo/Misc/OwnIDConfiguration.plist)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>OwnIDRedirectionURL</key>
	<string>com.myapp.demo://bazco</string>
	<key>OwnIDAppID</key>
	<string>4tb9nt6iaur0zv</string>
</dict>
</plist>
```
Where:

- The `OwnIDAppID` is the unique AppID, which you can obtain from the [OwnID Console](https://console.ownid.com).
- The `OwnIDRedirectionURL` is the full redirection URL, including its custom scheme. This URL custom scheme must match the one that you defined in your target.

## Create URL Type (Custom URL Scheme)
You need to open your project and create a new URL type that corresponds to the redirection URL specified in `OwnIDConfiguration.plist`. In Xcode, go to **Info > URL Types**, and then use the **URL Schemes** field to specify the redirection URL. For example, if the value of the `OwnIDRedirectionURL` key is `com.myapp.demo://bazco`, then you could copy `com.myapp.demo` and paste it into the **URL Schemes** field.

## Import OwnID Module
Once you have added the OwnID package dependency, you need to import the OwnID module so you can access the SDK features. As you implement OwnID in your project, add the following to your source files:

[Complete example](../Demo/FirebaseDemo/App/FirebaseLoggedIn.swift)
```swift
import OwnIDFirebaseSDK
```

## Initialize the SDK
The OwnID SDK must be initialized properly using the `configure()` function, preferably in the main entry point of your app (in the `@main` `App` struct). For example, enter:

[Complete example](../Demo/FirebaseDemo/App/DemoApp.swift)
```swift
@main
struct ExampleApp: App {
    init() {
        OwnID.FirebaseSDK.configure()
    }
}
```

If you did not follow the recommendation for creating the `OwnIDConfiguration.plist` file, you need to specify arguments when calling the `configure` function. For details, see [Alternative Syntax for Configure Function](#alternative-syntax-for-configure-function-).

## Implement the Registration Screen
Within a Model-View-ViewModel (MVVM) architecture pattern, adding the Skip Password option to your registration screen is as easy as adding an OwnID view model and subscription to your app's ViewModel layer, then adding the OwnID view to your main View. That's it! When the user selects Skip Password, your app waits for events while the user interacts with the OwnID Web App, then calls a function to register the user once they have completed the Skip Password process.

**Important:** When a user registers with OwnID, a random password is generated and set for the user's Firebase account.

### Customize View Model
The OwnID view that inserts the Skip Password UI is bound to an instance of the OwnID view model. Before modifying your View layer, create an instance of this view model, `OwnID.FlowsSDK.RegisterView.ViewModel`, within your ViewModel layer:

[Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/Register/RegisterViewModel.swift)
```swift
final class MyRegisterViewModel: ObservableObject {
    // MARK: OwnID
    let ownIDViewModel = OwnID.FirebaseSDK.registrationViewModel()
}
```

After creating this OwnID view model, your View Model layer should listen to events from the OwnID Event Publisher, which allows your app to know what actions to take based on the user's interaction with the OwnID Web App. Simply add the following to your existing ViewModel layer to subscribe to the OwnID Event Publisher and respond to events (it can be placed just after the code that creates the OwnID view model instance).

[Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/Register/RegisterViewModel.swift)
```swift
final class MyRegisterViewModel: ObservableObject {
    // MARK: OwnID
    let ownIDViewModel = OwnID.FirebaseSDK.registrationViewModel()

    init() {
     subscribe(to: ownIDViewModel.eventPublisher)
    }

     func subscribe(to eventsPublisher: OwnID.RegistrationPublisher) {
       eventsPublisher
           .sink { [unowned self] event in
               switch event {
               case .success(let event):
                   switch event {
                   // Event when user successfully
                   // finishes Skip Password
                   // in OwnID Web App
                   case .readyToRegister:
                     // If needed, ask user to enter
                     // email (mandatory) and call
                     // OwnID.FlowsSDK.RegisterView.ViewModel.
                     // register(with email: String)
                     // to finish registration
                     ownIDViewModel.register(with: email)

                   // Event when OwnID creates Firebase
                   // account and logs in user
                   case .userRegisteredAndLoggedIn:
                     // User is registered and logged in with OwnID
                     // if you need to update user's name or other info
                     // it is good place to do this by calling
                     // currentUser.createProfileChangeRequest()
                     // in Firebase
                     
                   case .loading:
                     // Display loading indicator according to your designs
                   }

               case .failure(let error):
                // Handle OwnID.CoreSDK.Error here
               }
           }
           .store(in: &bag)
   }
}
```

**Important:** The OwnID `ownIDViewModel.register` function must be called in response to the `.readyToRegister` event. This `ownIDViewModel.register` function eventually calls the standard Firebase function `createUser(withEmail: password:)` to register the user in Firebase, so you do not need to call this Firebase function yourself.

### Add the OwnID View
Inserting the OwnID view into your View layer results in the OwnID button appearing in your app. When the user selects OwnID button, the SDK opens a sheet to interact with the user. The code that creates this view accepts the OwnID view model as its argument. It is suggested that you pass user's email binding for properly creating accounts.

It is reccomended to set height of button the same as text field and disable text field when OwnID is enabled. 

![how it looks like](../drawings/skip_button_design.png) ![how it looks like](../drawings/skip_button_design_dark.png)

[Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/Register/RegisterView.swift)
```swift
//Put RegisterView inside your main view, preferably besides password field
var body: some View {
    OwnID.FirebaseSDK.createRegisterView(viewModel: viewModel.ownIDViewModel, email: usersEmail)
}
```

It is recommended that you hide `OwnID.FlowsSDK.RegisterView` when the user starts typing in the password text field. [Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/Register/RegisterView.swift)

## Implement the Login Screen
The process of implementing your Login screen is very similar to the one used to implement the Registration screen. When the user selects Skip Password on the Login screen and if the user has previously set up OwnID authentication, allows them to log in with OwnID.

Like the Registration screen, you add Skip Password to your application's Login screen by including an OwnID view. In this case, it is `OwnID.LoginView`. This OwnID view has its own view model, `OwnID.LoginView.ViewModel`.

### Customize View Model
You need to create an instance of the view model, `OwnID.LoginView.ViewModel`, that the OwnID login view uses. Within your ViewModel layer, enter:

[Complete example](../Demo/FirebaseDemo/App/FirebaseLogin.swift)
```swift
final class MyLogInViewModel: ObservableObject {
    // MARK: OwnID
    let ownIDViewModel = OwnID.FirebaseSDK.loginViewModel()
}
```

After creating this OwnID view model, your View Model layer should listen to events from the OwnID Event Publisher, which allows your app to know what actions to take based on the user's interaction with the Skip Password option. Simply add the following to your existing ViewModel layer to subscribe to the OwnID Event Publisher and respond to events.

[Complete example](../Demo/FirebaseDemo/App/FirebaseLogin.swift)
[Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/LogIn/LogInViewModel.swift)
```swift
final class MyLogInViewModel: ObservableObject {
    // MARK: OwnID
    let ownIDViewModel = OwnID.FirebaseSDK.loginViewModel()

 	  init() {
       subscribe(to: ownIDViewModel.eventPublisher)
   	}

     func subscribe(to eventsPublisher: OwnID.LoginPublisher) {
       eventsPublisher
           .sink { [unowned self] event in
               switch event {
               case .success(let event):
                   switch event {
                   // Event when user who previously set up
                   // OwnID logs in with Skip Password
                   case .loggedIn:
                     // User is logged in with OwnID

                   case .loading:
                     // Display loading indicator according to your designs
                   }

               case .failure(let error):
                 // Handle OwnID.CoreSDK.Error here
               }
           }
           .store(in: &bag)
   }
}
```

### Add OwnID View
Inserting the OwnID view into your View layer results in the Skip Password option appearing in your app. When the user selects Skip Password, the SDK opens a sheet to interact with the user. It is recommended that you place the OwnID view, `OwnID.LoginView`, immediately after the password text field. The code that creates this view accepts the OwnID view model as its argument. It is suggested that you pass user's email binding for properly creating accounts.

[Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/LogIn/LogInView.swift)
[Complete example](../Demo/FirebaseDemo/App/FirebaseLogin.swift)
```swift
//Put LoginView inside your main view, preferably below password field
var body: some View {
  //...
  // User's email binding `$viewModel.email` is used to display identity
  // name when logging in. Additionally, this email is used to get
  // information if user already has OwnID account
  OwnID.FirebaseSDK.createLoginView(viewModel: viewModel.ownIDViewModel,
                                    usersEmail: $viewModel.email)
  //...
}
```

![how it looks like](../drawings/skip_button_design.png) ![how it looks like](../drawings/skip_button_design_dark.png)

It is recommended that you hide `OwnID.FlowsSDK.LoginView` when the user starts typing in the password text field. 
[Complete example](../Demo/ios-sdk-demo-components/DemoApp/LoggedOut/LogIn/LogInView.swift)


## Errors
All errors from the SDK have an `OwnID.CoreSDK.Error` type. You can use them, for example, to properly ask the user to perform an action.

Here are some of the possible errors:
[Complete example](../OwnIDCoreSDK/SDK/Types/Error.swift)
```swift
switch error {
case .unsecuredHttpPassed:
    print("unsecuredHttpPassed")

case .notValiedRedirectionURLOrNotMatchingFromConfiguration:
    print("notValiedRedirectionURLOrNotMatchingFromConfiguration")

case .emailIsInvalid:
    print("emailIsInvalid")

case .flowCancelled:
    print("flowCancelled")

case .statusRequestResponseIsEmpty:
    print("statusRequestResponseIsEmpty")

case .statusRequestFail(underlying: let underlying):
    print("statusRequestFail: \(underlying)")

case .plugin(let pluginError):
    print("plugin: \(pluginError)")
}
```
## Advanced Configuration

### Button Apperance
It is possible to set button visual settings by passing `OwnID.UISDK.VisualLookConfig`.

```swift
let config = OwnID.UISDK.VisualLookConfig(buttonForegroundColor: .red,
                                          backgroundColor: .brown,
                                          borderColor: .brown,
                                          shadowColor: .cyan)
OwnID.FirebaseSDK.createLoginView(viewModel: ownIDViewModel,
                                  usersEmail: usersEmail,
                                  visualConfig: config)
```

### Alternative Syntax for Configure Function 🎛
If you followed the recommendation to add `OwnIDConfiguration.plist` to your project, calling `configure()` without any arguments is enough to initialize the SDK. If you did not follow this recommendation, you can still initialize the SDK with one of the following calls. Remember that these calls should be made within your app's `@main` `App` struct.

* `OwnID.FirebaseSDK.configure(plistUrl: plist)` explicitly provides the path to the OwnID configuration file, where `plist` is the path to the file.
* `OwnID.FirebaseSDK.configure(appID: String, redirectionURL: URL)` explicitly defines the configuration options rather than using a PLIST file. The app id is unique to your OwnID application, and can be obtained in the [OwnID Console](https://console.ownid.com). The redirection URL is your app's redirection URL, including its custom scheme.

### OwnID Web App language

By default, the OwnID Web App is launched with a language TAGs list (well-formed [IETF BCP 47 language tag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Language)) based on the device locales set by the user in system. You can override this behavior and set the Web App language list manually by passing languages in an array. Example:

```swift
OwnID.FirebaseSDK.createRegisterView(viewModel: viewModel.ownIDViewModel, webLanguages: OwnID.CoreSDK.Languages.init(rawValue: ["he"]))
```

### Directing Users to the OwnID iOS App
By default, the SDK directs the user to the OwnID Web App to register or login with OwnID. However, with a small configuration, users who have the native OwnID app installed on their mobile device can complete the registration/login process in the native app rather than the web app.

To direct the user to the OwnID native app, edit the `LSApplicationQueriesSchemes` key in your `Info.plist` file. Simply add `ownidopener` as a string in the `LSApplicationQueriesSchemes` array.
Example:
[Complete example](../Demo/FirebaseDemo/Misc/Info.plist)
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>ownidopener</string>
</array>
```

## Logging
You can enable console logging by calling `OwnID.startDebugConsoleLogger()`.
