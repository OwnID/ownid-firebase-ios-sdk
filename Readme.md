![OwnIDSDK](./logo.svg)

# OwnID Firebase-iOS SDK
The OwnID Firebase-iOS SDK is a client library written in Swift that provides a passwordless login alternative for your iOS application by using cryptographic keys to replace the traditional password. Integrating the SDK with your iOS app adds a Skip Password option to its registration and login screens. For more general information about OwnID SDKs, see [OwnID iOS SDK](../README.md).

## Table of contents
* [Before You Begin](#before-you-begin)
* [Add Package Dependency](#add-package-dependency)
* [Add Property List File to Project](#add-property-list-file-to-project)
* [Create URL Type (Custom URL Scheme)](#create-url-type-custom-url-scheme)
* [Import OwnID Modules](#import-ownid-module)
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
The SDK is distributed as an SPM package. Use the Swift Package Manager to add the following package dependency to your project:

```
https://github.com/OwnID/ownid-firebase-ios-sdk
```
When prompted, select the **OwnIDFirebaseSDK** product.

## Add Property List File to Project

When the application starts, the OwnID SDK automatically reads `OwnIDConfiguration.plist` from the file system to configure the default instance that is created. At a minimum, this PLIST file defines a redirection URI and unique app id. Create `OwnIDConfiguration.plist` and define the following mandatory parameters:

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/blob/master/FirebaseDemo/Misc/OwnIDConfiguration.plist)
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

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/blob/master/FirebaseDemo/App/FirebaseLoggedIn.swift)
```swift
import OwnIDFirebaseSDK
```

## Initialize the SDK
The OwnID SDK must be initialized properly using the `configure()` function, preferably in the main entry point of your app (in the `@main` `App` struct). For example, enter:

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/blob/master/FirebaseDemo/App/DemoApp.swift)
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

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/tree/master/DemoAppComponents/LoggedOut/Register/RegisterViewModel.swift)
```swift
final class MyRegisterViewModel: ObservableObject {
    // MARK: OwnID
    let ownIDViewModel = OwnID.FirebaseSDK.registrationViewModel()
}
```

After creating this OwnID view model, your View Model layer should listen to events from the OwnID Event Publisher, which allows your app to know what actions to take based on the user's interaction with the OwnID Web App. Simply add the following to your existing ViewModel layer to subscribe to the OwnID Event Publisher and respond to events (it can be placed just after the code that creates the OwnID view model instance).

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/tree/master/DemoAppComponents/LoggedOut/Register/RegisterViewModel.swift)
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
Inserting the OwnID view into your View layer results in the OwnID button appearing in your app. When the user selects OwnID button, the SDK presents in app Safari browser to interact with the user. The code that creates this view accepts the OwnID view model as its argument. It is suggested that you pass user's email binding for properly creating accounts.

It is reccomended to set height of button the same as text field and disable text field when OwnID is enabled. 

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/tree/master/DemoAppComponents/LoggedOut/Register/RegisterView.swift)
```swift
//Put RegisterView inside your main view, preferably besides password field
var body: some View {
    OwnID.FirebaseSDK.createRegisterView(viewModel: viewModel.ownIDViewModel, email: usersEmail)
}
```

## Implement the Login Screen
The process of implementing your Login screen is very similar to the one used to implement the Registration screen. When the user selects Skip Password on the Login screen and if the user has previously set up OwnID authentication, allows them to log in with OwnID.

Like the Registration screen, you add Skip Password to your application's Login screen by including an OwnID view. In this case, it is `OwnID.LoginView`. This OwnID view has its own view model, `OwnID.LoginView.ViewModel`.

### Customize View Model
You need to create an instance of the view model, `OwnID.LoginView.ViewModel`, that the OwnID login view uses. Within your ViewModel layer, enter:

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/blob/master/FirebaseDemo/App/FirebaseLogin.swift)
```swift
final class MyLogInViewModel: ObservableObject {
    // MARK: OwnID
    let ownIDViewModel = OwnID.FirebaseSDK.loginViewModel()
}
```

After creating this OwnID view model, your View Model layer should listen to events from the OwnID Event Publisher, which allows your app to know what actions to take based on the user's interaction with the Skip Password option. Simply add the following to your existing ViewModel layer to subscribe to the OwnID Event Publisher and respond to events.

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/blob/master/FirebaseDemo/App/FirebaseLogin.swift)
[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/tree/master/DemoAppComponents/LoggedOut/LogIn/LogInViewModel.swift)
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

[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/tree/master/DemoAppComponents/LoggedOut/LogIn/LogInView.swift)
[Complete example](https://github.com/OwnID/ownid-demo-ios-sdk/blob/master/FirebaseDemo/App/FirebaseLogin.swift)
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


## Errors
All errors from the SDK have an `OwnID.CoreSDK.Error` type. You can use them, for example, to properly ask the user to perform an action.

Here are some of the possible errors:
[Complete example](https://github.com/OwnID/ownid-core-ios-sdk/blob/master/Core/Sources/Types/Error.swift)
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
It is possible to set button visual settings by passing `OwnID.UISDK.VisualLookConfig`. Additionally, you can override default behaviour of tooltip appearing or other settings in `OwnID.UISDK.TooltipVisualLookConfig`.

```swift
let tooltipConfig = OwnID.UISDK.TooltipVisualLookConfig(backgroundColor: .pink,
                                                        borderColor: .accentColor,
                                                        shouldShowTooltip: false)
let config = OwnID.UISDK.VisualLookConfig(biometryIconColor: .red,
                                          shadowColor: .cyan,
                                          tooltipVisualLookConfig: tooltipConfig)
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


## Logging
You can enable console logging by calling `OwnID.startDebugConsoleLogger()`.


## License

```
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS


   Copyright 2022 OwnID INC.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

```
