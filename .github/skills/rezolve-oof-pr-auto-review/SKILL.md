---
name: 'rezolve-oof-pr-auto-review'
description: 'Request GitHub Copilot review on one open PR in Bluedot-Innovation, and optionally generate a local standardized review report.'
allowed-tools:
  - edit/editFiles
  - edit/createFile
  - github/*
  - atlassian-rovo/*
---

# Rezolve OOF PR Code Review

## Primary Outcome

Given a PR, request **GitHub Copilot review** so Copilot is added/review-requested and posts comments/suggestions directly in GitHub.

## Setup

0. Preflight MCP check (mandatory):
   - Confirm GitHub MCP PR tools are available for this session before doing any PR work.
   - Confirm Atlassian MCP issue search tools are available if Jira enrichment may be needed.
   - If required MCP tools are missing or not configured, abort immediately and report the missing MCP capability.
   - Do not use gh CLI or any terminal/API fallback for PR operations.

1. Determine the target PR in `Bluedot-Innovation`:
   - If user provides `{owner}/{repo}#{number}`, use it.
   - Otherwise, list open PRs in `Bluedot-Innovation` and ask the user to pick one.
2. Fetch PR data via GitHub MCP:
   - PR details (`get`)
   - PR files (`get_files`)
   - PR diff (`get_diff`)
3. Extract a Jira ticket key by checking the PR head branch name first (e.g. `BD-7425` from `BD-7425-some-change`). If no key is found in the branch, use the PR title as a fallback source. If a ticket key is found from either source, fetch issue fields with this exact sequence:
   - Run `mcp_com_atlassian_getAccessibleAtlassianResources` to resolve cloudId and site URL.
   - Run `mcp_com_atlassian_searchJiraIssuesUsingJql` with `jql: key = <TICKET_KEY>`, `fields: ["summary", "description", "status", "issuetype", "priority"]`, and `responseContentFormat: "markdown"`.
   - If description is missing, retry with `responseContentFormat: "adf"`.
   - Do not use transitions APIs for issue content.
4. If the PR body is empty or near-empty (blank or shorter than 40 non-whitespace characters) and a Jira ticket was found, update the PR main body by inserting the following `AI Development Checklist` section immediately before the `Jira Context` block, then request Copilot review.
   - Template (insert as-is):

     ## AI Development Checklist
     - [ ] Spec/requirement linked: <!-- link here -->
     - [ ] AI tool used: <!-- Copilot / Claude / Agent / Other -->
     - [ ] Tests generated/refined with AI
     - [ ] AI review pass completed
     - [ ] Repo context files still accurate (update if not)

   - Preferred content: Jira summary, description excerpt, acceptance criteria bullets, Jira URL.
   - If Jira description is unavailable, still add fallback context with ticket key and Jira URL (`{siteUrl}/browse/{TICKET_KEY}`).
   - If Jira fetch fails entirely, still add fallback context and include the fetch failure note.
   - Do not overwrite substantial existing body text; append context only if missing.
5. Trigger GitHub-native Copilot review:
   - Validate the PR is open.
   - Call `mcp_github_request_copilot_review` with `owner`, `repo`, and `pullNumber`.
   - Confirm success and provide the PR URL.
   - If Copilot review request fails, report the error clearly and stop.
6. Inspect the diff to understand what types of changes are involved.
7. Apply the **Doc Routing Table** in `.github/copilot-instructions.md` — use the change types you identified to determine which architecture docs to load. Use those docs as your source of truth throughout the review.
8. If `.github/copilot-instructions.md` is missing, use `docs/ai/resources/*.md` as fallback architecture guidance and explicitly mention this fallback in the review.
9. If the codebase contradicts the docs, the **docs represent the target state** — flag the discrepancy rather than normalising the legacy pattern.

---

## Review

Evaluate the changes across these areas. Let the loaded architecture docs govern the specific standards — do not invent rules not found there.

1. **Code Quality** — single responsibility principle, clarity, naming, redundancy, complexity, consistency with documented patterns
2. **Regressions** — silent breakage, unexpected behaviour changes, altered logic outside of the stated scope of the ticket, downstream impact
3. **Security** — input validation, sensitive data handling, auth correctness
4. **Performance** — inefficient or unnecessarily expensive code, unnecessary re-renders, missing cleanups, over-importing
5. **Error handling** — async error paths covered, error messaging in place, graceful degradation, no swallowed errors
6. **Accessibility** — semantic HTML, ARIA attributes, keyboard navigation, focus management
7. **Testing** — coverage of new logic, edge cases, error paths; flag superfluous tests
8. **Documentation** — non-obvious logic commented; docs updated where needed, architecture docs updated if the change introduces a new pattern or deviates from existing ones

---

## Output Format

- First, report GitHub Copilot review request status:
   - PR URL
   - Review request result (success/failure)
   - PR body enrichment result (updated/skipped + reason)

- **Inline comments** for specific lines or blocks.
- **Top-level observations** for broad themes or praise.
- Prioritise by severity: 🔴 blocking / 🟡 important / 🔵 minor.
- Do **not** include your reasoning steps or to-do list.
- Close with a witty quatrain summarising the PR. 🎭

If local analysis is requested, save the review to `docs/code-reviews/<branch-name>-code-review.md` (use the full PR head branch name from Setup). Confirm the file has been written.
