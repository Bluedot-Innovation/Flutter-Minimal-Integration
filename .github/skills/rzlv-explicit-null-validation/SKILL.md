---
name: 'rzlv-explicit-null-validation'
description: 'Review Flutter/Dart code for silent null fallbacks: flag implicit null handling that should instead use assertions, explicit checks, or fast-fail patterns to surface programming errors early.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Explicit Null Validation

## Purpose

Flag silent null fallbacks and implicit null handling. When a null value indicates a programming error, the code should fail fast with a clear message rather than silently substituting a default value and masking the bug.

## When to Apply

Trigger this skill when a PR:
- Uses `?? SomeFallback()` where null would indicate a caller error
- Optionally calls a callback without documenting the null case
- Performs numeric operations without checking for `isFinite`, `isNaN`, or zero
- Adds nullable parameters that interact with non-null predicates or invariants

## Key Practices

- **Prefer `assert` over silent fallbacks** when null is unexpected:
  ```dart
  // Bad — silent fallback hides caller error
  selectableDayPredicate?.call(initialDateTime ?? DateTime.now())

  // Good — explicit assertion surfaces the issue
  assert(
    selectableDayPredicate == null ||
    initialDate == null ||
    selectableDayPredicate!(initialDate!),
    'Initial date must be selectable when predicate is provided'
  );
  ```

- **Assert unexpected nulls before optional dispatch**:
  ```dart
  // Bad — silent no-op if callback is missing
  final VoidCallback? callback = callbacks[actionId];
  if (callback != null) { callback(); }

  // Good — assert the expected state, then call
  final VoidCallback? callback = callbacks[actionId];
  assert(callback != null, 'No callback registered for action: $actionId');
  callback?.call();
  ```

- **Validate numeric values explicitly**:
  ```dart
  // Bad — silently skips on invalid values
  if (itemExtent > 0.0) { ... }

  // Good — asserts the expected precondition
  assert(scrollOffset.isFinite && itemExtent.isFinite,
    'scrollOffset and itemExtent must be finite');
  if (itemExtent > 0.0) { ... }
  ```

## Review Checklist

- [ ] Are `?? fallback` expressions intentional, or are they masking unexpected nulls?
- [ ] Are nullable parameters that interact with predicates or invariants validated explicitly?
- [ ] Are numeric inputs checked for `isFinite`, `isNaN`, and zero before arithmetic?
- [ ] Are missing callbacks asserted rather than silently ignored?
- [ ] Do assertion messages provide actionable context?

## Output

Raise findings as:
- 🔴 **Blocking** — silent fallback masks a caller error that will be hard to debug in production
- 🟡 **Important** — null case is plausible but undocumented and unasserted
- 🔵 **Minor** — defensive check that would improve clarity or debuggability

