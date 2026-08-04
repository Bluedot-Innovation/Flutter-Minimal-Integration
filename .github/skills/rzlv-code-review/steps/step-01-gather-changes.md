---
target_branch: ''       # set from invocation argument
current_branch: ''      # set at runtime via git
diff_output: ''         # set at runtime
changed_files: ''       # set at runtime
report_path: ''         # set at runtime
jira_ticket_key: ''     # set at runtime if branch contains a ticket number (e.g. BD-7558)
jira_ticket_summary: '' # set at runtime from Jira API
jira_ticket_body: ''    # set at runtime — full ticket description + acceptance criteria
jira_ticket_status: ''  # set at runtime
---

# Step 1: Gather Changes

## RULES

- Do not modify any source files. This step is read-only.
- All git commands must be run in the project root.
- **ALWAYS** use `git --no-pager` for every git command. Never omit `--no-pager`. Git may invoke a pager (`less`, `more`) on any command that produces output, which will block the terminal indefinitely.

## INSTRUCTIONS

### 1. Confirm target branch

- Set `{target_branch}` from the value parsed in workflow initialization.
- Run `git --no-pager branch -a | cat` to list branches, then check whether `{target_branch}` appears.
  - If not found locally, also run `git --no-pager ls-remote --heads origin {target_branch} | cat` to check remote.
  - If neither check finds the branch, HALT and tell the user: "Branch `{target_branch}` was not found. Please check the branch name and try again."

### 2. Identify current branch

- Run `git rev-parse --abbrev-ref HEAD` (no pager needed — single-line output) and store as `{current_branch}`.
- If the result is `HEAD` (detached HEAD state), HALT and warn the user.

### 3. Produce the diff

- Run: `git --no-pager diff {target_branch}...HEAD`
  - This shows all commits on `{current_branch}` that are **not** on `{target_branch}` (three-dot diff = changes introduced by this branch).
- Store the full output as `{diff_output}`.
- If `{diff_output}` is empty, HALT and tell the user: "No changes found between `{current_branch}` and `{target_branch}`. Nothing to review."

### 4. Build changed-files list and summary stats

- Run: `git --no-pager diff --name-only {target_branch}...HEAD`
- Store as `{changed_files}` (newline-separated list).
- Run: `git --no-pager diff --stat {target_branch}...HEAD | tail -1`
  - This produces the summary line only (e.g. `12 files changed, 340 insertions(+), 45 deletions(-)`). Using `tail -1` avoids piping the full per-file table.
- Present a short summary to the user:
  > Reviewing `{current_branch}` vs `{target_branch}`:
  > - **Files changed:** <count>
  > - **Lines added:** <+N>
  > - **Lines removed:** <-N>

### 5. Large diff warning

- If `{diff_output}` exceeds approximately 3000 lines, warn the user:
  > ⚠️ This diff is large (~N lines). The review will proceed but may take a while. Consider chunking if context limits are hit.
- Continue regardless — do not block.

### 6. Detect Jira ticket number

- Scan `{current_branch}` for a pattern matching a Jira ticket key: one or more uppercase letters, a hyphen, then one or more digits (regex: `[A-Z]+-\d+`).
  - Examples: `ak/BD-7558` → `BD-7558` | `feature/PROJ-123-some-description` → `PROJ-123`
- If a match is found:
  - Set `{jira_ticket_key}` to the matched value (e.g. `BD-7558`).
  - Announce: "🎫 Jira ticket detected: `{jira_ticket_key}`. Fetching ticket details…"
  - Proceed to instruction 6a.
- If no match is found:
  - Set `{jira_ticket_key}` = `""` (empty).
  - Announce: "ℹ️ No Jira ticket number found in branch name. Skipping Jira compliance review."
  - Skip to instruction 7.

#### 6a. Fetch Jira ticket via Atlassian MCP

1. Call `mcp_atlassian_getAccessibleAtlassianResources` to discover the available Jira cloud ID.
   - Use the first Jira resource returned and store its `id` as `{jira_cloud_id}`.
   - If the call fails or returns no resources, note the failure, set `{jira_ticket_key}` = `""`, and skip to instruction 7.

2. Call `mcp_atlassian_getJiraIssue` with:
   - `cloudId`: `{jira_cloud_id}`
   - `issueIdOrKey`: `{jira_ticket_key}`
   - `responseContentFormat`: `"markdown"`

3. If the call succeeds:
   - Set `{jira_ticket_summary}` = the issue `summary` field.
   - Set `{jira_ticket_status}` = the issue `status.name` field.
   - Set `{jira_ticket_body}` = the full issue `description` field (markdown). If the issue has an `Acceptance Criteria` custom field or a section labelled "Acceptance Criteria" in the description, extract and preserve it verbatim — it will be a primary review lens.
   - Announce:
     > 🎫 **Jira ticket loaded:** [`{jira_ticket_key}`] {jira_ticket_summary}
     > **Status:** {jira_ticket_status}

4. If the call fails (ticket not found, permission denied, network error):
   - Warn the user: "⚠️ Could not fetch Jira ticket `{jira_ticket_key}`: <error>. Jira compliance review will be skipped."
   - Set `{jira_ticket_key}` = `""`.

### 7. Determine report output path

- Set `{report_path}` = `.github/reviews/code-review-{current_branch}-{date}.md`
  - Replace `/` characters in `{current_branch}` with `-` to keep it filesystem-safe.
  - Format `{date}` as `YYYY-MM-DD`.
  - If `{jira_ticket_key}` is non-empty, include it for clarity:
    `.github/reviews/code-review-{jira_ticket_key}-{date}.md`
- Announce the output path to the user:
  > 📄 Report will be written to: `{report_path}`


## NEXT

Read fully and follow `./step-02-rzlv-review.md`

