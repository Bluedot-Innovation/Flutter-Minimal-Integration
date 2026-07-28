# Push Notifications Integration

> **Platform status**
> | Platform | Status |
> |----------|--------|
> | Android  | ✅ Implemented |
> | iOS      | 🚧 Not yet implemented |

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
