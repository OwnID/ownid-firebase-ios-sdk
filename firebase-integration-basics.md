# OwnID-Firebase Integration Basics
Before incorporating the "Skip Password" feature into your web or mobile application, you need to create an OwnID application and integrate it with your Firebase project.

## Create OwnID Application
To create an OwnID application:
1. Open the [OwnID Console](https://console.ownid.com/) and create an account or log in to an existing account.
2. Select **Create Application**.
3. Define the details of the OwnID application, and select **Next**.
4. If you are ready to configure Firebase, select the **Firebase Authentication** card and proceed to Configure Firebase. If you would like to complete these steps later, select **Skip for Now**.

## Configure Firebase
The OwnID-Firebase integration assumes you have already created a Firebase project. If you created an OwnID application without starting the Firebase integration, open the application in the [OwnID Console](https://console.ownid.com/) and select the **Integration** tab before taking the following steps.

### Generate Private Key for the Firebase Admin SDK Service Account
An Own ID application needs a private key for the Firebase Admin SDK service account in order to integrate itself with the Firebase project. Private keys associated with a service account provide the credentials needed to access Firebase services.
1. In the [Firebase Console](https://console.firebase.google.com/), go to ⚙️ > Project Settings > **Service accounts**. If you do not see the **Service accounts** tab, make sure you are an owner of the Firebase project.
2. With **Firebase Admin SDK** highlighted, select **Generate new private key**, and then confirm by selecting **Generate key**. You are prompted to save the key as a JSON file.
3. Use the OwnID console to choose or drag-and-drop the JSON file with the generated key.

### Define Firestore Security Rules
You need to define basic [Firestore Security Rules](https://cloud.google.com/firestore/docs/security/get-started) that provide access control for an app using OwnID. These rules protect the database from attempts to access data with unauthorized requests. To define the security rules required by OwnID:
1. In the Firebase Console, select **Firestore Database** > **Rules**.
2. Enter the following rules in the text box:
```
        rules_version = '2';
        service cloud.firestore {
            match /databases/{database}/documents {
                match /ownid {
                    allow read, write : if false
                }
            }
        }
```
3. Select **Publish**.

### Confirm Email/Password Authentication
If you have not already done so, you need to enable the Email/Password sign-in method for your Firebase authentication. To verify that the Email/Password sign-in method is enabled:
1. In the Firebase Console, select **Authentication** > **Sign-in method**.
2. Find **Email/Password** and confirm that its status is **Enabled**. If the status is disabled, select the Pencil icon to open the configuration, switch the **Enabled** toggle, and select **Save**.

### Confirm Password Recovery URL
Firebase authentication provides a template that sends an email to a user when they cannot remember their password. This email template must be configured so users are directed to your website's Account Recovery page, which can include the OwnID widget. To verify that the Firebase email template includes the URL of the Account Recovery page:
1. In the Firebase Console, select **Authentication** > **Templates**.
2. Select **Password reset**
3. Select the Pencil icon to edit the template.
4. Confirm that the **Action URL** field specifies the URL of your website's Account Recovery page. If it does not, select **Customize action URL**, enter the correct URL, and confirm by selecting **Save** twice.
