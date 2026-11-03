# Flutter Minimal Integration App

This app demonstrates integration of `bluedot_point_sdk` 3.0.0 and
`bluedot_point_sdk_push` 2.0.0 with Flutter 3.44 or newer.

The iOS plugins use Flutter's Swift Package Manager integration. PointSDK 19.0.0 is not yet
available from its configured package URL, so current migration validation uses the plugins'
temporary PointSDK 18.1.0 pins. PointSDK 19.0.0 release acceptance remains blocked until the
package resolves and the app validation is rerun.