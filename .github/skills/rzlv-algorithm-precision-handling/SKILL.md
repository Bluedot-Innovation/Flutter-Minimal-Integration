---
name: 'rzlv-algorithm-precision-handling'
description: 'Review Flutter/Dart code for algorithm precision issues: edge cases, floating-point handling, boundary conditions, and correct mathematical formulas.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Algorithm Precision Handling

## Purpose

Review code changes for algorithm correctness, mathematical precision, and robust edge case handling. Flag subtle bugs caused by approximations, incorrect formulas, or unvalidated boundary conditions that surface only under specific conditions.

## When to Apply

Trigger this skill when a PR introduces or modifies:
- Mathematical calculations or formulas
- String parsing or splitting logic
- Division, rounding, or floating-point arithmetic
- Validation functions that check numeric constraints
- Coordinate or geometry calculations

## Key Practices

- **Use `substring()` over `split()` for string processing** when precise prefix control is needed — `currentLabel.substring(baseLabel.length)` avoids issues when the base pattern appears multiple times in the string.
- **Apply correct unit conversions** with mathematical constants — e.g., `event.rotation = (double)state->rotation * (M_PI / 180)` for degrees-to-radians conversion.
- **Handle floating-point precision in division** — use `lerpValue.round()` after render-level calculations rather than redundant division-based rounding.
- **Validate all edge cases**, especially zero values and boundary conditions — check for `metrics.physical_width == 0` and tight constraint relationships.
- **Fix mathematical formulas to use correct operations** — e.g., `(math.max(first.bottom, second.bottom) - math.min(first.top, second.top))` for proper area height calculation (`min` for top, not `max`).

## Review Checklist

- [ ] Are all numeric inputs validated before use (zero, negative, infinite)?
- [ ] Are mathematical formulas using the correct operations (min vs max, etc.)?
- [ ] Is string splitting done safely when the delimiter may appear multiple times?
- [ ] Are unit conversions explicit and correct (degrees → radians, etc.)?
- [ ] Are boundary conditions (empty, zero-size, max values) tested?

## Output

Raise findings as:
- 🔴 **Blocking** — incorrect formula that produces wrong output
- 🟡 **Important** — missing edge case that could cause runtime failure in production
- 🔵 **Minor** — precision improvement or safer alternative available

