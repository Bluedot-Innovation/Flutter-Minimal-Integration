---
name: 'rzlv-avoid-breaking-changes'
description: 'Review Flutter/Dart APIs for backward compatibility: flag breaking parameter changes, missing deprecations, and altered default values that would force consumers to update code.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Avoid Breaking Changes

## Purpose

Review API changes to ensure backward compatibility. Flag changes that would force developers to maintain separate code paths for different SDK versions, and recommend safer alternatives such as deprecation with migration paths or optional parameters with sensible defaults.

## When to Apply

Trigger this skill when a PR:
- Modifies a public method signature (adds/removes/reorders parameters)
- Changes an existing default value
- Removes or renames a public API
- Adds a required parameter to an existing method
- Changes the behavior of an existing API

## Key Practices

- **Make new parameters optional with defaults** instead of required:
  ```dart
  // Instead of breaking change:
  void getHandleAnchor(TextSelectionHandleType type, double textLineHeight, {required double cursorWidth})

  // Use optional with default:
  void getHandleAnchor(TextSelectionHandleType type, double textLineHeight, {double cursorWidth = 2.0})
  ```

- **Use `@Deprecated` with a migration message** rather than direct removal:
  ```dart
  @Deprecated(
    'Use sendAnnouncement instead. '
    'This API is incompatible with multiple windows. '
    'This feature was deprecated after 3.35.0-0.1.pre.'
  )
  static Future<void> announce(String message) { ... }
  ```

- **Never change existing default values** — this is a silent breaking change. Add new options while preserving existing defaults.

- **Design new APIs to be explicit** — avoid implicit assumptions that would require breaking changes when those assumptions need updating.

## Review Checklist

- [ ] Does the PR add any required parameters to existing public methods?
- [ ] Are any existing default values changed?
- [ ] Are removed/renamed APIs replaced with properly annotated `@Deprecated` wrappers?
- [ ] Do deprecation messages include the target replacement and the version deprecated after?
- [ ] Are new parameters optional with sensible defaults?

## Output

Raise findings as:
- 🔴 **Blocking** — change breaks existing consumers without a migration path
- 🟡 **Important** — change is technically breaking but could be mitigated with deprecation
- 🔵 **Minor** — default value choice or API design suggestion for future-proofing

