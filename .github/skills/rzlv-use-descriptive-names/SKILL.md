---
name: 'rzlv-use-descriptive-names'
description: 'Review Flutter/Dart/C++ code for vague, abbreviated, or misleading names: functions, variables, constants, and types that do not clearly communicate their purpose, behavior, or data type.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Use Descriptive Names

## Purpose

Flag names that are too generic, abbreviated, or misleading. Names should clearly describe what a symbol represents or does — not how it is implemented, and not via shorthand that requires domain knowledge to decode.

## When to Apply

Trigger this skill when a PR introduces or renames:
- Function names that describe mechanism rather than purpose
- Variable names using abbreviations or single/double letters
- Type names that reflect implementation details instead of semantics
- Constants missing the `k` prefix (Dart/C++ convention)
- Callback parameters named `_` (anonymous) without good reason
- C++ identifiers using snake_case where camelCase is expected (or vice versa per language style)

## Key Practices

- **Name functions by what they do, not how**:
  ```dart
  // Bad: Generic, describes a check, not the action
  void _checkOnCustomDaysDisplay() { ... }

  // Good: Clearly states the outcome
  void _scrollToFirstSelectableDate() { ... }
  ```

- **Use full words instead of abbreviations**:
  ```cpp
  // Bad
  const double hsw = half_stroke_width;

  // Good
  const double halfStrokeWidth = half_stroke_width;
  ```

- **Reflect the actual data type or concept** in type and variable names:
  ```dart
  // Bad: Name implies a size but it holds constraints
  Map<int, ExpectedFrameSize> expectedFrameConstraints;

  // Good
  Map<int, ExpectedFrameConstraints> expectedFrameConstraints;
  ```

- **Use semantic names over widget-layer names**:
  ```dart
  // Bad: 'overlayPortalParent' leaks widget implementation details
  final overlayPortalParent = ...;

  // Good: Describes the traversal role
  final traversalOwner = ...;
  ```

- **Apply conventional prefixes consistently**:
  - `k` prefix for constants: `kSystemToolbarToggleDebounceThreshold`
  - `handle` prefix for callbacks: `handleSystemHideToolbar`
  - `_` prefix for private members in Dart

## Review Checklist

- [ ] Do method names describe *what* they do rather than *how*?
- [ ] Are abbreviations expanded to their full forms?
- [ ] Do type names reflect actual data semantics, not implementation details?
- [ ] Are constants prefixed with `k` per Flutter/Dart conventions?
- [ ] Are callback parameters named `handle<Event>` for clarity?
- [ ] Do C++ identifiers follow the project's naming style guide?

## Output

Raise findings as:
- 🔴 **Blocking** — misleading name that inverts or obscures the meaning of critical logic
- 🟡 **Important** — ambiguous name that will confuse reviewers and future maintainers
- 🔵 **Minor** — abbreviation or style inconsistency that reduces readability

