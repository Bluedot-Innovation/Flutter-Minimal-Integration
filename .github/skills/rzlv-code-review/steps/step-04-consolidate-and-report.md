---
---

# Step 4: Consolidate and Write Report

## RULES

- Write the report to `{report_path}`. Create parent directories if needed.
- Do not modify any source code files — this step is report-writing only.
- Every finding must be an actionable checklist item so the developer can work through them one by one.
- Deduplicate: if an rzlv finding and a general finding describe the same issue at the same location, merge them into a single item and note both sources.
- Include `{jira_findings}` in the deduplicated pool — a Jira finding and a general finding about the same gap should be merged.

## INSTRUCTIONS

### 1. Deduplicate findings

- Combine `{rzlv_findings}`, `{general_findings}`, and `{jira_findings}` into one pool.
- For any finding that refers to the same file, line range, and root cause, merge into one entry. Mark its source as both (e.g., `[rzlv-explicit-null-validation + GENERAL/CORRECTNESS]`).
- Count totals: `{rzlv_count}`, `{general_count}`, `{jira_count}`, `{merged_count}`, `{total_count}`.

### 2. Classify severity (if not already set)

- For each finding without an explicit severity, assign one:
  - **Critical** — crash risk, data loss, or security vulnerability
  - **High** — significant correctness or performance issue
  - **Medium** — maintainability, code-quality, or standards violation
  - **Low** — style, naming, or minor nit

### 3. Sort findings

Order the final list as:
1. Critical (top priority)
2. High
3. Medium
4. Low
5. ✅ Clean lenses (informational, kept at the bottom)

### 4. Write the report file

Create the file at `{report_path}` with the following structure:

---

```markdown
# Code Review Report

**Branch:** `{current_branch}`
**Compared to:** `{target_branch}`
**Date:** {date}
**Files changed:** <count> | **Lines:** +<added> / -<removed>
<!-- Include the next line only if {jira_ticket_key} is non-empty -->
**Jira Ticket:** [{jira_ticket_key}] {jira_ticket_summary} *(Status: {jira_ticket_status})*

---

## Summary

| Category         | Count |
|------------------|-------|
| 🔴 Critical       | N     |
| 🟠 High           | N     |
| 🟡 Medium         | N     |
| 🔵 Low            | N     |
| **Total issues** | **N** |
| ✅ Clean lenses   | N     |

---

## Jira Ticket Compliance

<!-- Include this entire section only if {jira_ticket_key} is non-empty. If empty, replace with a single line: "No Jira ticket associated with this branch." -->

**Ticket:** [{jira_ticket_key}] {jira_ticket_summary}
**Status:** {jira_ticket_status}

| Type           | Count |
|----------------|-------|
| ❌ Missing      | N     |
| ⚠️ Mismatch    | N     |
| 🔵 Incomplete  | N     |
| 🟡 Out of scope | N     |

### Compliance Action Items

- [ ] **[JIRA/{jira_ticket_key}/MISSING]** — <Title>
  > <Detail>

- [ ] **[JIRA/{jira_ticket_key}/MISMATCH]** — <Title>
  > <Detail>

*(repeat for all jira findings, grouped by type; omit types with zero findings)*

---

## Action Items

> Each item below is an independent task. Check it off once resolved.

### 🔴 Critical

- [ ] **[<SOURCE>]** `<file>:<line>` — <Title>
  > <Detail>

*(repeat for all Critical findings, or omit section if none)*

---

### 🟠 High

- [ ] **[<SOURCE>]** `<file>:<line>` — <Title>
  > <Detail>

*(repeat for all High findings, or omit section if none)*

---

### 🟡 Medium

- [ ] **[<SOURCE>]** `<file>:<line>` — <Title>
  > <Detail>

*(repeat for all Medium findings, or omit section if none)*

---

### 🔵 Low

- [ ] **[<SOURCE>]** `<file>:<line>` — <Title>
  > <Detail>

*(repeat for all Low findings, or omit section if none)*

---

## rzlv Standards Coverage

List every rzlv lens and its outcome:

| Lens | Result |
|------|--------|
| rzlv-algorithm-precision-handling          | ✅ Clean / ⚠️ N finding(s) |
| rzlv-avoid-breaking-changes                | ✅ Clean / ⚠️ N finding(s) |
| rzlv-eliminate-redundant-operations        | ✅ Clean / ⚠️ N finding(s) |
| rzlv-explain-non-obvious-code              | ✅ Clean / ⚠️ N finding(s) |
| rzlv-explicit-null-validation              | ✅ Clean / ⚠️ N finding(s) |
| rzlv-extract-methods-for-clarity           | ✅ Clean / ⚠️ N finding(s) |
| rzlv-future-proof-configuration-defaults   | ✅ Clean / ⚠️ N finding(s) |
| rzlv-make-errors-explicit                  | ✅ Clean / ⚠️ N finding(s) |
| rzlv-manage-state-dependencies-properly    | ✅ Clean / ⚠️ N finding(s) |
| rzlv-test-observable-behavior              | ✅ Clean / ⚠️ N finding(s) |
| rzlv-thread-safety-synchronization         | ✅ Clean / ⚠️ N finding(s) |
| rzlv-use-descriptive-names                 | ✅ Clean / ⚠️ N finding(s) |
| rzlv-use-named-constants                   | ✅ Clean / ⚠️ N finding(s) |

---

## General Review Coverage

| Area                        | Result |
|-----------------------------|--------|
| Correctness & Logic         | ✅ Clean / ⚠️ N finding(s) |
| Architecture & Design       | ✅ Clean / ⚠️ N finding(s) |
| Security                    | ✅ Clean / ⚠️ N finding(s) |
| Performance                 | ✅ Clean / ⚠️ N finding(s) |
| Concurrency & Thread Safety | ✅ Clean / ⚠️ N finding(s) |
| Error Handling & Resilience | ✅ Clean / ⚠️ N finding(s) |
| Test Coverage               | ✅ Clean / ⚠️ N finding(s) |
| Documentation & Readability | ✅ Clean / ⚠️ N finding(s) |

---

*Generated by rzlv-code-review skill*
```

---

### 5. Confirm write

After writing the file, announce:

> ✅ **Code review complete.**
>
> **Report written to:** `{report_path}`
>
> | Severity  | Issues |
> |-----------|--------|
> | 🔴 Critical | N |
> | 🟠 High     | N |
> | 🟡 Medium   | N |
> | 🔵 Low      | N |
> | **Total**  | **N** |
>
> <!-- Include if {jira_ticket_key} is non-empty -->
> **Jira compliance:** <N_MISSING> missing, <N_MISMATCH> mismatch, <N_INCOMPLETE> incomplete, <N_OOS> out-of-scope
>
> Open `{report_path}` to work through the action items.

### 6. Offer next steps

Present:

> **What would you like to do next?**
> 1. **Fix issues now** — I will start applying fixes from the top of the action list
> 2. **Walk through findings** — I will explain each one before touching code
> 3. **Done** — the report is saved, I will stop here

**HALT** — wait for the user's choice before taking any further action.

