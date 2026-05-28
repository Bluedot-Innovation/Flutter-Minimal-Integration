---
name: 'rzlv-manage-state-dependencies-properly'
description: 'Review Flutter widget code for improper state dependency management: direct context lookups that bypass the dependency system, setState calls during build phases, and missing didChangeDependencies updates.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Manage State Dependencies Properly

## Purpose

Flag Flutter widget code that accesses inherited or external state without establishing a proper rebuild dependency, and identify `setState` calls that occur during a build phase and would cause "setState() or markNeedsBuild() called during build" errors.

## When to Apply

Trigger this skill when a PR:
- Calls `Overlay.of(context)`, `Navigator.maybeOf(context)`, or similar without using the dependency-establishing variant
- Reads `InheritedWidget` data directly instead of via `context.dependOnInheritedWidgetOfExactType`
- Calls `setState` or a state-mutating callback from `didChangeDependencies` or `build`
- Stores a result from a context lookup at construction time (bypassing reactive updates)

## Key Practices

- **Use dependency-establishing lookups** so widgets rebuild when inherited state changes:
  ```dart
  // Problematic: Overlay.of does not establish a dependency
  final overlayState = Overlay.of(context);

  // Better: Use the InheritedWidget-based API that establishes a rebuild dependency
  // Ensures the widget rebuilds when the overlay changes
  ```

- **Defer state updates triggered during build** using `addPostFrameCallback`:
  ```dart
  void handleCloseRequest() {
    if (widget.onCloseRequested != null) {
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
        // Defer to avoid setState during build
        SchedulerBinding.instance.addPostFrameCallback((_) {
          widget.onCloseRequested!();
        });
      } else {
        widget.onCloseRequested!();
      }
    }
  }
  ```

- **Move expensive or reactive lookups to `didChangeDependencies`** rather than `build()`, and cache the result in state.

- **Never mutate state inside `build()`** — any mutation triggered transitively from `build` will crash in debug mode.

## Review Checklist

- [ ] Are all `InheritedWidget` lookups using the dependency-establishing variants?
- [ ] Are there `setState` or callback invocations that could be triggered during a build phase?
- [ ] Are context lookups stored at widget construction time (where they won't update reactively)?
- [ ] Are expensive or potentially-null context reads guarded with `didChangeDependencies` caching?
- [ ] Does the code handle the case where the scheduler phase is `persistentCallbacks`?

## Output

Raise findings as:
- 🔴 **Blocking** — causes a crash (`setState during build`) or missed rebuilds in production
- 🟡 **Important** — stale data shown to user or unpredictable rebuild behavior
- 🔵 **Minor** — missed optimization or defensive guard that would improve robustness

