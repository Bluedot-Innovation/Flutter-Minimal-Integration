# Push Notifications Integration

> **Platform status**
> | Platform | Status |
> |----------|--------|
> | Android  | ✅ Implemented |
> | iOS      | ✅ Implemented |

---

## Enabling Push Notifications - Android (opt-in)

Push notifications are **disabled by default**. The app builds and runs without any Firebase or APNs configuration. Follow these steps to turn the feature on.

### Prerequisites

- A [Firebase](https://console.firebase.google.com/) project with an Android app registered.
- The package name used to register the Firebase app must match the one in your build (default: `io.bluedot.flutter_minimal_app`).
- A Bluedot project with push campaigns configured in the [Bluedot Canvas](https://app.bluedot.io/).

### Android – step-by-step

#### 1. Download `google-services.json`

In the [Firebase Console](https://console.firebase.google.com/), open your project → **Project settings** → **Your apps** → download `google-services.json`.

Place it at:

```
android/app/google-services.json
```


#### 2. Set `PUSH_ENABLED=true`

Open `android/gradle.properties` and change:

```properties
PUSH_ENABLED=false
```
to:
```properties
PUSH_ENABLED=true
```

Alternatively, pass it as an environment variable without touching the file:

```bash
PUSH_ENABLED=true flutter run
# or
PUSH_ENABLED=true flutter build apk
```

#### 3. Change the application package name

Current package name for the Android app is `io.bluedot.flutter_minimal_app`. To make push notifications work with your own Firebase project, 
you must change the package name in several places to match the one you registered in Firebase.

| File | Field | Change to |
|------|-------|-----------|
| `android/app/build.gradle` | `applicationId` | your package name |
| `android/app/src/main/AndroidManifest.xml` | `package` attribute | your package name |
| `android/app/src/main/kotlin/io/bluedot/flutter_minimal_app/MainActivity.kt` | directory path + `package` declaration | your package name |
| Firebase Console | Android app registration | must match `applicationId` |

#### 4. Build and run

```bash
flutter pub get
flutter run          # or: PUSH_ENABLED=true flutter run
```

The **Push Notifications** button will appear on the home screen and the app will request notification permission on launch.

---

## Enabling Push Notifications - iOS (opt-in)

Push notifications are disabled by default. No PointSDK-specific AppDelegate code is required: the Flutter plugin registers with APNs and forwards notification lifecycle events to PointSDK.

### Prerequisites

- An Apple Developer App ID and provisioning profile with the Push Notifications capability.
- A bundle identifier matching that App ID (the sample default is `io.bluedot.flutterMinIntegrationApp`).
- An APNs authentication key or certificate configured for the app in Bluedot Canvas.
- A Bluedot Canvas project with a push campaign and location-based trigger configured.
- A physical iOS device. APNs registration and location-triggered delivery should not be validated on the simulator.

### iOS – step-by-step

#### 1. Configure signing

Open `ios/Runner.xcworkspace` in Xcode, select the **Runner** target, then choose your team and an APNs-enabled bundle identifier under **Signing & Capabilities**. The sample already includes the Push Notifications capability and the `remote-notification` background mode.

#### 2. Set `PUSH_ENABLED` to true

Open `ios/Runner/Info.plist` and change:

```xml
<key>PUSH_ENABLED</key>
<false/>
```

to:

```xml
<key>PUSH_ENABLED</key>
<true/>
```

#### 3. Configure Canvas

In Bluedot Canvas, configure the APNs credentials for the same bundle identifier, then create a push campaign. Choose the required zone entry, exit, or dwell event for a location-triggered notification.

#### 4. Build and run

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run
```

Accept notification permission when prompted. The app registers with APNs only after permission is granted, and received/clicked PointSDK push events appear on the **Push Notifications** page.
