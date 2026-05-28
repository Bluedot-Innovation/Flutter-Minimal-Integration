---
name: 'rzlv-explain-non-obvious-code'
description: 'Review Flutter/Dart code for missing explanatory comments: magic numbers, implementation decisions, parameter relationships, edge cases, and platform-specific behavior that are not self-evident.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Explain Non-Obvious Code

## Purpose

Flag code that lacks sufficient explanatory comments. Non-obvious logic, magic numbers, implementation decisions, and parameter constraints should always be documented to aid future maintainers and reviewers.

## When to Apply

Trigger this skill when a PR introduces or modifies:
- Hard-coded numeric constants without explanation
- Complex conditional logic or bitwise operations
- Platform-specific workarounds or version guards
- API parameters with non-obvious constraints or interactions
- Algorithms whose correctness is not immediately apparent

## Key Practices

- **Document magic numbers and constants** — explain how the value was derived and its significance:
  ```dart
  // Bad: No explanation
  TextSelectionHandleType.collapsed => const Offset(_kHandleSize / 2.18, -4.5),

  // Good: Explains origin
  // These values were eyeballed to match a physical Pixel 9 running Android 16,
  // which horizontally centers the anchor 1 pixel below the cursor.
  TextSelectionHandleType.collapsed => const Offset(_kHandleSize / 2.18, -4.5),
  ```

- **Document parameter relationships and edge-case behavior**:
  ```dart
  // Bad: Unclear parameter purpose
  void hideToolbar([bool hideHandles = true, Duration? toggleDebounceDuration]);

  // Good: Fully documented
  /// Hides the text selection toolbar.
  ///
  /// When [hideHandles] is false, the toolbar is hidden but handles remain visible.
  /// When [toggleDebounceDuration] is non-null, a subsequent call to [toggleToolbar]
  /// will not show the toolbar unless the duration threshold has been exceeded.
  void hideToolbar([bool hideHandles = true, Duration? toggleDebounceDuration]);
  ```

- **Clarify implementation decisions** — explain *why* a specific approach was chosen, not just *what* it does.

- **Document assumed constraints** — if a method only supports a subset of theoretically possible inputs (e.g., `baseLabel` is always a prefix of `currentLabel`), say so explicitly.

- **Note platform differences** — document behavior differences across platforms or SDK versions.

## Review Checklist

- [ ] Are all numeric literals either obvious or commented?
- [ ] Are parameter constraints and interactions documented in dartdoc?
- [ ] Is the *reason* for non-obvious logic explained (not just restated)?
- [ ] Are platform-specific branches annotated?
- [ ] Are assumptions about input values or invariants documented?

## Output

Raise findings as:
- 🔴 **Blocking** — absent comment makes the code dangerous to modify safely
- 🟡 **Important** — non-obvious logic that will confuse future maintainers
- 🔵 **Minor** — nice-to-have clarification that would improve readability

