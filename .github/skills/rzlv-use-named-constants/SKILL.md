---
name: 'rzlv-use-named-constants'
description: 'Review Flutter/Dart/Java code for hardcoded string literals and magic values that should be extracted into named constants to prevent typos, improve readability, and create a single source of truth.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
---

# rzlv: Use Named Constants

## Purpose

Flag hardcoded string literals, numeric magic values, and repeated raw values that should be extracted into named constants. A named constant prevents typos, makes the code self-documenting, and ensures all usages stay in sync when the value changes.

## When to Apply

Trigger this skill when a PR introduces or uses:
- String literals repeated more than once, or used as identifiers/prefixes
- Numeric literals with non-obvious meaning (e.g., buffer sizes, timeouts, offsets)
- String prefixes or suffixes used in string parsing/construction
- File paths or resource names hardcoded inline

## Key Practices

- **Extract string prefixes and resource names to constants**:
  ```java
  // Bad: Hardcoded literal used for string manipulation
  String prefix = "--aot-shared-library-name=";
  Path path = internalStorageDirAsPathObj.resolve(Paths.get("library.so"));

  // Good: Named constants that communicate intent
  private static final String AOT_SHARED_LIBRARY_NAME_PREFIX = "--aot-shared-library-name=";
  private static final String DEFAULT_LIBRARY_NAME = "library.so";

  String prefix = AOT_SHARED_LIBRARY_NAME_PREFIX;
  Path path = internalStorageDirAsPathObj.resolve(Paths.get(DEFAULT_LIBRARY_NAME));
  ```

- **Apply Flutter/Dart constant conventions**:
  ```dart
  // Good: k-prefixed constant with descriptive name
  const double kSystemToolbarToggleDebounceThreshold = 0.5;
  const String kDefaultFontFamily = 'Roboto';
  ```

- **Group related constants** in a dedicated constants file or class, rather than scattering them across implementations.

- **Use constants for quantities that may change** — even if a value is used once, a named constant communicates intent and makes future changes safe.

## Review Checklist

- [ ] Are there string literals that appear more than once, or that function as identifiers?
- [ ] Are numeric values with non-obvious meaning extracted into named constants?
- [ ] Are file paths, resource names, or prefixes hardcoded inline?
- [ ] Do constant names follow the language's conventions (`k` prefix in Dart/C++, `ALL_CAPS` in Java)?
- [ ] Are related constants co-located for discoverability?

## Output

Raise findings as:
- 🔴 **Blocking** — duplicate literal where a mistake in one copy causes a silent bug
- 🟡 **Important** — magic value whose purpose requires reading surrounding code to understand
- 🔵 **Minor** — single-use literal that would benefit from a name for clarity

