---
rzlv_findings: [] # accumulated findings list — append throughout this step
---

# Step 2: rzlv Standards Review

## RULES

- Review `{diff_output}` through **every** rzlv- skill lens listed below. Do not skip any.
- For each lens: load the skill's `SKILL.md`, apply its guidelines to the diff, collect violations.
- A finding must reference a specific file and line range from the diff if possible.
- If a skill's guidelines are not violated by anything in the diff, record it as ✅ clean for that lens.

## FINDING FORMAT

Each finding must be structured as:

```
- **[<SKILL-ID>]** `<file>:<line>` — <one-line title>
  > <Detail: what the code does, why it violates the guideline, what should be done instead.>
```

If no violations are found for a lens:
```
- ✅ **[<SKILL-ID>]** No violations found.
```


## INSTRUCTIONS

Work through each lens in sequence. For each lens:
1. Read the referenced `SKILL.md` file fully.
2. Scan `{diff_output}` for violations of the guidelines in that skill.
3. Append all findings (or the clean ✅ note) to `{rzlv_findings}`.

Process lenses in this order:

---

### Lens 1 — Algorithm Precision Handling
**Skill file:** `.github/skills/rzlv-algorithm-precision-handling/SKILL.md`

Look for: incorrect mathematical formulas, missing edge case validation (zero, negative, infinite values), unsafe `split()` where `substring()` is needed, missing unit conversions (e.g. degrees → radians).

---

### Lens 2 — Avoid Breaking Changes
**Skill file:** `.github/skills/rzlv-avoid-breaking-changes/SKILL.md`

Look for: new required parameters added to existing public methods, changed default values, removed or renamed APIs without `@Deprecated` wrappers, deprecation annotations missing a migration message or version reference.

---

### Lens 3 — Eliminate Redundant Operations
**Skill file:** `.github/skills/rzlv-eliminate-redundant-operations/SKILL.md`

Look for: redundant null/validation checks duplicating what the callee already handles, unnecessary object allocations inside hot paths (message handlers, `build()`, frequent callbacks), expensive ancestor-chain lookups inside `build()`, duplicate calculations within a single execution path, dead fallback code made obsolete by API changes.

---

### Lens 4 — Explain Non-Obvious Code
**Skill file:** `.github/skills/rzlv-explain-non-obvious-code/SKILL.md`

Look for: magic numeric literals without explanatory comments, parameter constraints or interactions undocumented in dartdoc, implementation decisions that are not self-explanatory, platform-specific branches without annotation, assumed input invariants not documented.

---

### Lens 5 — Explicit Null Validation
**Skill file:** `.github/skills/rzlv-explicit-null-validation/SKILL.md`

Look for: `?? fallback` expressions masking unexpected nulls, nullable parameters interacting with predicates or invariants without explicit assertion, numeric inputs used in arithmetic without `isFinite`/`isNaN` checks, missing callbacks silently ignored instead of asserted.

---

### Lens 6 — Extract Methods for Clarity
**Skill file:** `.github/skills/rzlv-extract-methods-for-clarity/SKILL.md`

Look for: methods longer than ~35 lines, `if/else` branches each containing more than ~8 lines of complex logic, repeated initialization or computation patterns across multiple call sites, inline boolean conditions requiring significant parsing.

---

### Lens 7 — Future-Proof Configuration Defaults
**Skill file:** `.github/skills/rzlv-future-proof-configuration-defaults/SKILL.md`

Look for: non-negatable boolean flags, hardcoded numeric range limits or operational constants that should be configurable properties, ambiguous nullable config fields (null vs. explicitly-disabled), deprecated options missing a replacement and removal timeline.

---

### Lens 8 — Make Errors Explicit
**Skill file:** `.github/skills/rzlv-make-errors-explicit/SKILL.md`

Look for: silent default returns (e.g. `return 0`, `return null`) on unexpected code paths instead of assertions, unchecked results of `find()` / `firstWhere()` / map lookups before use, caught exceptions with no logging or re-throw, impossible states silently skipped instead of asserted or logged.

---

### Lens 9 — Manage State Dependencies Properly
**Skill file:** `.github/skills/rzlv-manage-state-dependencies-properly/SKILL.md`

Look for: `Overlay.of`, `Navigator.maybeOf`, or similar context lookups that don't establish a rebuild dependency, `setState` or state-mutating callbacks invoked during `build()` or `didChangeDependencies`, expensive or reactive context lookups not cached in `didChangeDependencies`.

---

### Lens 10 — Test Observable Behavior
**Skill file:** `.github/skills/rzlv-test-observable-behavior/SKILL.md`

Look for: tests asserting internal controller values or private state instead of rendered output, `@visibleForTesting` on production code added solely for test assertions, tests that would break on internal refactors while the user-facing behavior remains unchanged.

---

### Lens 11 — Thread Safety & Synchronization
**Skill file:** `.github/skills/rzlv-thread-safety-synchronization/SKILL.md`

Look for: writes to shared data structures without a mutex or equivalent lock, handlers/callbacks registered and not unregistered before object destruction, logically related multi-step operations split across different task runners/threads, missing `_destroyed` or `_invalidated` guards on async callbacks.

---

### Lens 12 — Use Descriptive Names
**Skill file:** `.github/skills/rzlv-use-descriptive-names/SKILL.md`

Look for: function names describing mechanism rather than purpose, variables using abbreviations or single letters, type names reflecting implementation details instead of semantics, missing `k` prefix on Dart/C++ constants, callback parameters missing `handle` prefix, anonymous `_` parameters where a name would clarify meaning.

---

### Lens 13 — Use Named Constants
**Skill file:** `.github/skills/rzlv-use-named-constants/SKILL.md`

Look for: string literals repeated more than once or used as identifiers/prefixes, magic numeric values whose purpose requires surrounding context to understand, file paths or resource names hardcoded inline, constants not following the language's naming convention (`k` prefix in Dart/C++, `ALL_CAPS` in Java/Kotlin).

---

## COMPLETION

Once all 13 lenses are processed, confirm:
> ✅ All 13 rzlv lenses applied. Proceeding to general review.


## NEXT

Read fully and follow `./step-03-general-review.md`
