---
name: 'rzlv-test-observable-behavior'
description: 'Review Flutter test code for tests that check internal implementation details rather than observable user-facing behavior, and flag uses of @visibleForTesting that exist solely to enable white-box testing.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Test Observable Behavior

## Purpose

Flag tests that verify internal implementation details rather than user-observable outcomes. Tests should remain valid when the implementation changes, and should not require `@visibleForTesting` annotations on production code just to enable assertions.

## When to Apply

Trigger this skill when a PR:
- Tests internal controller values or private state directly
- Adds `@visibleForTesting` to production code solely for testing purposes
- Verifies that a specific internal method was called rather than what the user sees
- Tests the number of internal objects rather than the rendered output
- Bypasses the public API to set up or assert against widget state

## Key Practices

- **Test visual output, not controller internals**:
  ```dart
  // Bad: Tests the internal controller value
  expect(controller.value, closeTo(0.5, 0.01));

  // Good: Tests what the user actually sees
  expect(
    find.byType(LinearProgressIndicator),
    paints
      ..rect(rect: expectedBackgroundRect)
      ..rect(rect: expectedProgressRect)
  );
  ```

- **Avoid `@visibleForTesting` on production code**:
  ```dart
  // Bad: Exposes internals just for a test assertion
  @visibleForTesting
  Set<Color> distinctVisibleOuterColors() { ... }

  // Good: Test the observable rendering instead
  expect(find.byType(FadeTransition), paints..opacity(0.5));
  ```

- **Prefer `paints` matchers** for visual widgets — they verify what is actually drawn.
- **Test interactions and their effects** — simulate user gestures and assert on the resulting UI state.
- **Test accessibility semantics** — verify `Semantics` labels and announcements rather than internal state.
- **Use public APIs** to set up test scenarios; use platform channel mocks for system integrations.

## Review Checklist

- [ ] Are tests verifying rendered output rather than internal state or controller values?
- [ ] Is `@visibleForTesting` used only for code that genuinely needs exposure, not to work around encapsulation?
- [ ] Are `paints` matchers used instead of private field checks for visual widgets?
- [ ] Do tests remain valid if the internal implementation is refactored?
- [ ] Are user interactions tested end-to-end rather than individual internal method calls?

## Output

Raise findings as:
- 🔴 **Blocking** — test will break on any internal refactor, giving false regression signals
- 🟡 **Important** — `@visibleForTesting` leak or internal assertion that should use public API
- 🔵 **Minor** — test could be more meaningful or resilient with a small change

