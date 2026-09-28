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

## Updated Point SDK

The app now runs Bluedot Point SDK **18.1.0** on iOS and **18.0.0** on Android, which introduces
support for location-triggered push notifications.

## Requirements

- **iOS 15.6 or later**, or **Android 10 (API 29) or later**.
- A physical device. Simulators cannot receive push notifications.
- Notification permission must be granted. The app asks on first launch and registers for push only
  after permission is granted. Background location access is required for notifications to arrive
  while the app is not in the foreground.
- Campaigns must be published in Bluedot Canvas before notifications can be delivered.
