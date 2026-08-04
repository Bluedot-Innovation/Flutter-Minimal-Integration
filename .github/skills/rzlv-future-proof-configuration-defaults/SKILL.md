---
name: 'rzlv-future-proof-configuration-defaults'
description: 'Review Flutter/Dart configuration design for hardcoded values, non-negatable flags, ambiguous null vs empty states, and missing migration paths that would prevent safe default changes in future versions.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Future-Proof Configuration Defaults

## Purpose

Flag configuration design choices that will be difficult or breaking to change later. Ensure boolean flags are negatable, values are configurable rather than hardcoded, null and empty states are distinguishable, and deprecated options have clear migration paths.

## When to Apply

Trigger this skill when a PR:
- Adds new CLI flags or build configuration options
- Hardcodes range limits (min/max) or operational constants
- Introduces nullable configuration fields
- Deprecates or removes existing configuration options
- Adds boolean parameters where the default might reasonably change in future

## Key Practices

- **Make boolean flags negatable** so users can opt out when the default changes:
  ```dart
  // Good: negatable: true allows flipping the default later without a breaking change
  addFlag('enable-gradle-managed-install', negatable: true)
  ```

- **Replace hardcoded opinionated values with configurable properties**:
  ```dart
  // Bad: Hardcoded and impossible to override
  setAttribute('aria-valuemin', "0")

  // Good: Configurable with sensible default
  class ProgressBarConfig {
    final double minValue;
    final double maxValue;
  }
  ```

- **Distinguish null (not configured) from empty/false (explicitly disabled)**:
  ```dart
  if (config != null && config.enabled) {
    // Feature explicitly enabled
  } else if (config != null && !config.enabled) {
    // Feature explicitly disabled
  } else {
    // config == null: use default behavior
  }
  ```

- **Provide clear deprecation messaging** with the replacement option and removal timeline when retiring configuration options.

## Review Checklist

- [ ] Are new boolean flags `negatable: true`?
- [ ] Are numeric constants (min, max, threshold) exposed as configurable properties rather than hardcoded?
- [ ] Is a nullable config field ambiguous between "not set" and "explicitly disabled"?
- [ ] Do deprecated options include a replacement and a "deprecated after X.Y.Z" message?
- [ ] Could the current default value need to change in a future release, and is that change safe?

## Output

Raise findings as:
- 🔴 **Blocking** — design forces a breaking change to update a default in future
- 🟡 **Important** — hardcoded value or non-negatable flag that limits future flexibility
- 🔵 **Minor** — missing deprecation messaging or ambiguous null state

