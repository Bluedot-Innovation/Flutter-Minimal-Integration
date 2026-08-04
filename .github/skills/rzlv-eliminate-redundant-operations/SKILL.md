---
name: 'rzlv-eliminate-redundant-operations'
description: 'Review Flutter/Dart code for unnecessary operations in hot paths: redundant checks, duplicate calculations, unnecessary allocations, and obsolete code paths that hurt performance.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Eliminate Redundant Operations

## Purpose

Identify and flag unnecessary operations that impact performance. Focus especially on hot paths such as widget `build()` methods, message handlers, and frequently called callbacks where repeated redundant work accumulates.

## When to Apply

Trigger this skill when a PR touches:
- Widget `build()` or `rebuild()` methods
- Message handlers or event listeners
- Methods called on every frame or user interaction
- Data structure initialization inside loops or callbacks
- Validation or guard checks before calling other functions

## Key Practices

1. **Remove redundant null/validation checks** that are already handled by the called function:
   ```dart
   // Avoid — parseFloat already handles NaN
   if (parsed != null && !parsed.isNaN) { styleProperty = parsed; }

   // Better — let parseFloat handle it
   styleProperty = parsed;
   ```

2. **Avoid unnecessary allocations in hot paths** — don't create new objects (e.g., `List.from(...)`) on every message or event:
   ```dart
   // Avoid — allocates a new list on every message
   final List<Handler> handlers = List<Handler>.from(_messageHandlers);

   // Better — use debug assertions to guard against modification during iteration
   ```

3. **Move expensive operations out of `build()`** — ancestor chain walks (`Navigator.maybeOf`, `InheritedWidget` lookups) should live in `didChangeDependencies` or be cached:
   ```dart
   // Avoid — walks ancestor chain on every rebuild
   if (Navigator.maybeOf(context, rootNavigator: true) != this) { ... }

   // Better — move to didChangeDependencies and cache the result
   ```

4. **Avoid duplicate calculations** — restructure branches so each code path computes a value at most once:
   ```dart
   // Avoid — lerpValue computed then divided again
   lerpValue = (lerpValue * widget.divisions!).round() / widget.divisions!;

   // Better — use if-else with a single computation per path
   ```

5. **Remove redundant code paths** — delete fallback logic made obsolete by API changes.

## Review Checklist

- [ ] Are there null/type checks that duplicate what the called API already validates?
- [ ] Are new objects allocated inside loops or frequent callbacks?
- [ ] Are expensive lookups (ancestor walks, map lookups) happening inside `build()`?
- [ ] Is the same value computed more than once within a single execution path?
- [ ] Is any fallback code now dead after recent API changes?

## Output

Raise findings as:
- 🔴 **Blocking** — causes measurable jank or memory pressure in production hot paths
- 🟡 **Important** — redundant work that adds up over many calls
- 🔵 **Minor** — style-level simplification with minor perf benefit

