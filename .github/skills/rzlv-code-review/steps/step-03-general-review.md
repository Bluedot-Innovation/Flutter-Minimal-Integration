---
general_findings: [] # accumulated findings from general review — append throughout this step
jira_findings: []    # accumulated findings from Jira ticket compliance — append if ticket present
---

# Step 3: General Code Review

## RULES

- Review `{diff_output}` from a broad engineering perspective, independent of the rzlv lenses.
- Focus on issues that the individual rzlv lenses do not already cover.
- Avoid duplicate findings — if an issue is already captured in `{rzlv_findings}`, do not repeat it here.

## FINDING FORMATS

General finding:
```
- **[GENERAL/<CATEGORY>]** `<file>:<line>` — <one-line title>
  > <Detail: what the problem is, why it matters, what should be done.>
  > **Severity:** Critical | High | Medium | Low
```

Jira compliance finding:
```
- **[JIRA/{jira_ticket_key}/<TYPE>]** — <one-line title>
  > <Detail: what is missing, mismatched, or out of scope relative to the ticket.>
  > **Severity:** Critical | High | Medium | Low
```

Use `<TYPE>` values: `MISSING` (requirement not implemented), `MISMATCH` (implemented differently than spec), `OUT_OF_SCOPE` (change not related to ticket), `INCOMPLETE` (partial implementation).

Use these General categories: `LOGIC`, `ARCHITECTURE`, `PERFORMANCE`, `SECURITY`, `CORRECTNESS`, `MAINTAINABILITY`, `CONCURRENCY`, `TESTING`, `DOCUMENTATION`.


## INSTRUCTIONS

### 0. Jira Ticket Compliance (run only if `{jira_ticket_key}` is non-empty)

Skip this section entirely if `{jira_ticket_key}` is empty and proceed directly to section 1.

You have the following ticket context:
- **Key:** `{jira_ticket_key}`
- **Summary:** `{jira_ticket_summary}`
- **Status:** `{jira_ticket_status}`
- **Description & Acceptance Criteria:** `{jira_ticket_body}`

Evaluate `{diff_output}` against the ticket. Produce findings in `{jira_findings}` for each of the following:

#### 0a. Requirements coverage
- Read every requirement, user story sentence, and acceptance criterion in `{jira_ticket_body}`.
- For each one: determine whether the diff contains code that implements it.
- If a requirement has **no corresponding change** in the diff, raise a `MISSING` finding.
- If a requirement is **partially addressed** (e.g. success path implemented but error path not), raise an `INCOMPLETE` finding.

#### 0b. Implementation fidelity
- Where the diff does implement ticket requirements, verify the implementation matches the spec intent.
- If behaviour, data structures, API signatures, or logic deviate from what the ticket describes, raise a `MISMATCH` finding.

#### 0c. Scope creep
- Identify changes in the diff that are **not** mentioned or implied by the ticket.
- If a change is unrelated to the ticket, raise an `OUT_OF_SCOPE` finding with justification.
- Minor refactors incidental to the main change do not need to be flagged unless they are substantial.

#### 0d. Ticket status sanity check
- If `{jira_ticket_status}` indicates the ticket is `Done`, `Closed`, or `Cancelled`, warn:
  > ⚠️ Ticket `{jira_ticket_key}` has status `{jira_ticket_status}`. Verify this is the correct ticket for these changes.

After processing all sub-sections, summarise:
> ✅ Jira compliance review complete for `{jira_ticket_key}`. Found: <N> MISSING, <N> MISMATCH, <N> OUT_OF_SCOPE, <N> INCOMPLETE.

---

Carefully scan `{diff_output}` and produce findings for each of the areas below. If an area has no issues, note that explicitly. Use your own judgment — this is a broad, experienced-engineer review.

### 1. Correctness & Logic

- Off-by-one errors, wrong operator precedence, incorrect conditionals
- Misuse of standard library functions
- Data mutations with unintended side effects
- Missing return values or unreachable code paths

### 2. Architecture & Design

- Violations of separation of concerns
- Tight coupling between widgets, services, or modules
- God classes / functions with too many responsibilities
- Breaking of established patterns visible in the codebase
- Widget responsibilities that belong in a state-management layer

### 3. Security

- Input validation gaps (unvalidated user/network input flowing into sensitive operations)
- Hardcoded credentials, tokens, or secrets
- Insecure data storage or logging of sensitive information
- Missing authentication/authorisation checks on new code paths
- Use of deprecated or insecure cryptographic methods

### 4. Performance

- Unnecessary object allocations inside `build()` or other hot paths
- Blocking calls on the main isolate (synchronous I/O, heavy computation without `compute()`)
- Missing stream subscription cancellation causing memory leaks
- Expensive operations (network calls, DB queries) triggered on every rebuild

### 5. Concurrency & Thread Safety

- Mutable shared state accessed from multiple isolates or platform threads without synchronisation
- Stream or `Future` subscription leaks (subscriptions started but never cancelled in `dispose()`)
- Race conditions between platform thread operations and the Dart UI thread
- Missing `mounted` checks before calling `setState` after an `await`

### 6. Error Handling & Resilience

- Swallowed exceptions (`catch (e) { }` with no action)
- Missing error propagation to callers
- Crash-prone code paths with no fallback (unguarded async I/O without try-catch)
- `Future` errors not surfaced to the user or logged

### 7. Test Coverage

- New logic paths not covered by accompanying tests
- Tests that verify internal implementation rather than observable behavior
- Tests that depend on execution order or share mutable state
- Missing widget tests for new UI components

### 8. Documentation & Readability

- Missing dartdoc (`///`) on new public APIs
- Misleading, stale, or contradictory comments
- TODO/FIXME comments introduced without a tracking issue reference


## NEXT

Read fully and follow `./step-04-consolidate-and-report.md`
