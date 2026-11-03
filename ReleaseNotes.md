# Flutter Minimal Integration v2.2.0 Release Notes

This release adds PointSDK push notifications to the Minimal Integration app and updates the app to
the latest Bluedot Point SDK.

## Push notifications

The app can now receive notifications from Bluedot Canvas campaigns, triggered by location rather
than by a schedule. A campaign can notify a user when they enter a zone, leave it, or dwell there,
so a message can arrive with the app in the background or closed.

Notifications appear like any other iOS or Android notification, and open the app when tapped.

Every notification received or tapped is listed on the **Push Notifications** screen, along with the
campaign, zone and time it arrived.

## Flutter plugin integration

The app now integrates `bluedot_point_sdk` **3.0.0** and `bluedot_point_sdk_push` **2.0.0** using
Flutter **3.44 or newer**. On iOS, the plugins are integrated through Flutter's Swift Package
Manager support while unsupported plugins remain managed by CocoaPods.

PointSDK **19.0.0** is not yet available from its configured package URL. This migration is
currently validated against the Flutter plugins' temporary PointSDK **18.1.0** pins; PointSDK
19.0.0 release acceptance remains blocked until that package resolves and validation is rerun.

## Requirements

- **iOS 15.6 or later**, or **Android 10 (API 29) or later**.
- A physical device. Simulators cannot receive push notifications.
- Notification permission must be granted. The app asks on first launch and registers for push only
  after permission is granted. Background location access is required for notifications to arrive
  while the app is not in the foreground.
- Campaigns must be published in Bluedot Canvas before notifications can be delivered.
