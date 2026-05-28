---
name: 'rzlv-make-errors-explicit'
description: 'Review Flutter/Dart code for hidden error conditions: silent default returns, unchecked dereferences, swallowed exceptions, and missing error logging that obscure failures instead of surfacing them.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Make Errors Explicit

## Purpose

Flag error conditions that are silently swallowed, hidden behind default return values, or left unlogged. Errors should be visible during development and provide actionable context when they occur.

## When to Apply

Trigger this skill when a PR:
- Returns a default/sentinel value (e.g., `0`, `null`, `false`) on an unexpected code path
- Calls `find()`, `firstWhere()`, or similar without checking the result
- Catches exceptions without re-throwing or logging
- Silently ignores duplicate events or unexpected state transitions
- Uses conditional execution (`if (itemExtent > 0.0)`) to bypass a computation that should always be valid

## Key Practices

- **Replace silent default returns with assertions**:
  ```dart
  // Bad — hides error by returning 0
  if (itemExtent > 0.0) {
    final double actual = scrollOffset / itemExtent;
    if (!actual.isFinite) {
      return 0; // Caller has no idea something went wrong
    }
  }

  // Good — asserts the precondition; crashes fast in debug mode
  assert(scrollOffset.isFinite && itemExtent.isFinite,
         'scrollOffset and itemExtent must be finite');
  if (itemExtent > 0.0) {
    final double actual = scrollOffset / itemExtent;
  }
  ```

- **Check results before dereferencing** — calls to `find()`, map lookups, or `firstWhere()` should be validated before use.

- **Log unexpected conditions** — use `FML_LOG(ERROR)` (C++) or `FlutterError.reportError` (Dart) for states that should never occur.

- **Throw on duplicate events** rather than silently ignoring them — duplicate pointer events, duplicate registrations, etc. indicate a logic error upstream.

## Review Checklist

- [ ] Are there `return defaultValue` statements on error paths instead of assertions?
- [ ] Are results of `find()`, `firstWhere()`, or map lookups checked before use?
- [ ] Are caught exceptions logged or re-thrown?
- [ ] Are "impossible" states (e.g., duplicate events) asserted or logged rather than silently skipped?
- [ ] Are preconditions for arithmetic (finite, non-zero) asserted explicitly?

## Output

Raise findings as:
- 🔴 **Blocking** — silent failure masks a correctness bug that will be invisible in production
- 🟡 **Important** — missing assertion or log makes debugging significantly harder
- 🔵 **Minor** — additional logging that would aid future diagnosis

