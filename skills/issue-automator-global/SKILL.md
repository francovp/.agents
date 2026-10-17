---
name: issue-automator-global
description: >-
  Use when processing open GitHub issues or their linked pull requests in the current repository, including issue resolution, tracker sync, preview verification, or review-thread follow-up. Use GitHub only; do not use for unrelated Git operations.
---

## Hard Rules

1. If the user names an issue, work on that issue. Otherwise, select the oldest open GitHub issue.
2. Process one issue by default. Process at most one fallback issue, and only after a zero-write skip on an issue selected from the oldest-issue queue. Never switch away from a user-specified issue.
3. Never inspect or plan a third issue. Do not build an unbounded queue; select and inspect one candidate at a time.
4. Do not create duplicate issues or pull requests. Search open issues before creating one, and reuse an existing PR that covers the issue.
5. Respect ownership. Read the repository's issue-claim instructions and use its established helper or label protocol. Treat a fresh claim by another agent as `CLAIMED`; do not work around it. Reconfirm ownership before consequential GitHub writes. Take over only through the repository's documented stale-claim process. If no claim protocol exists, do not invent a helper, claim comment, or expiry rule.
6. Base decisions on live repository and GitHub state. Prefer `gh` when available; use GitHub MCP when the CLI is unavailable or cannot access the repository. Do not switch GitHub accounts unless the user or repository instructions require it.
7. Read the current repository's `AGENTS.md` and relevant contribution, test, CI, and deployment instructions. Discover the actual commands and preview setup; never assume a package manager, test command, hosting provider, URL pattern, label, or notification endpoint.
8. Separate an issue-specific blocker from a run-wide blocker. Retry a failed action only when there is a clear reason it may succeed, and keep retries bounded.
9. Send email, chat, webhook, or other external notifications only when the user explicitly authorized that workflow. Repository configuration may supply its endpoint and destination, but does not itself authorize sending. Never include secret values in a notification.
10. Stop on `DONE`, `SHIPPED`, `SYNCED`, `NEEDS_USER`, or `AMBIGUOUS`. After any write-producing outcome, stop processing additional issues. A run-wide `GLOBAL_BLOCKED` also stops the run.

## Procedural Workflow

### Step 1: Pre-flight and Selection

1. Find the current repository root. Read its `AGENTS.md` and identify any issue-automation, contribution, test, CI, and deployment instructions that apply.
2. If the user specified an issue number, fetch that issue. Otherwise, use `scripts/get-oldest-issue.sh` if it exists and is documented for this repository; if not, use `gh issue list --state open --sort created --direction asc --limit 1 --json number,title,createdAt,labels,url`.
3. If no issue is available and none was specified, stop.
4. Fetch only the minimum issue state needed to check ownership. Claim it using the repository's documented protocol before reading all comments or doing other deep analysis.

### Step 2: Ownership and Existing Work

1. Follow the claim helper's explicit result. A foreign active claim ends this candidate with `CLAIMED`; do not change its issue or PR. A stale claim may be taken over only as the repository's documented protocol allows.
2. For an owned issue, read its description and relevant comments from all participants. Check related issues and open, closed, merged, and draft PRs that reference it. If a PR exists, inspect its review threads and check status.
3. Recheck ownership immediately before consequential writes, including issue or PR edits, pushes, PR creation, and handoff. If ownership changed, stop writing and record `CLAIMED`.
4. If the work is already merged or completed, synchronize only the necessary tracker state and record `SHIPPED`, `DONE`, or `SYNCED` as appropriate. Do not create a parallel PR.

### Step 3: Confirm Scope and Tracker State

1. Derive the requested outcome and acceptance criteria from the issue, its comments, and repository instructions. Do not add unsupported requirements.
2. Search for duplicate issues before creating a follow-up GitHub issue. Link a new issue to the primary one when the user or repository workflow authorizes creating it.
3. If the issue is blocked with no safe next action, record `LOCAL_DEADLOCK`. If it needs user input or its meaning is materially ambiguous, record `NEEDS_USER` or `AMBIGUOUS` and stop.
4. If a linked PR already has actionable review feedback, treat it as work to address rather than as a blocker. Consider feedback from every participant and verify technical claims against the repository.

### Step 4: Implement and Prepare the PR

1. Use a clean branch that follows the repository's branch conventions. Preserve unrelated working-tree changes.
2. Implement only the issue's supported scope. Use the repository's documented test and smoke-test commands for the changed behavior; do not substitute a guessed command.
3. For documentation-only changes, use relevant documentation checks if configured. Code tests, app startup, code-only checks, and preview verification are not applicable unless repository instructions or the user require them. Do not bypass required branch protection.
4. Reuse an existing PR. Before creating or updating a PR, reconfirm ownership. Link the issue in the PR description and use `Closes #<NUMBER>` when the PR should close it on merge.
5. Follow repository instructions for PR creation and description. Use an available PR skill when it is required by those instructions.

### Step 5: Verify and Handle Review Feedback

1. Read [readiness-and-verification.md](references/readiness-and-verification.md) for the generic readiness and verification criteria.
2. Confirm the implementation meets the acceptance criteria, relevant checks pass, and no actionable review threads remain unresolved. Paginate review threads and comments when the API requires it; do not assume a flat comment list includes inline discussions.
3. For code changes, verify a preview only when this repository has a configured preview workflow. Resolve the URL from an active deployment record or the repository's documented resolver; never construct or guess a host. When the deployment exposes a commit SHA, confirm it matches the PR head before reporting the preview as verified.
4. Run applicable E2E or direct endpoint checks when the repository defines them. Mark checks `N/A` when the change or repository configuration does not call for them; report unavailable checks as unverified, not passed.
5. Use bounded waits and retries. Do not poll continuously or retry an unchanged failure without new evidence.

### Step 6: Bounded Fallback

1. A fallback is allowed only when the initial issue came from the oldest-issue queue and ended without agent writes as `CLAIMED`, `LOCAL_DEADLOCK`, an item-scoped `GLOBAL_BLOCKED` that remains after one bounded recovery attempt, or pre-existing `IN_REVIEW` with no agent writes.
2. Before moving on, leave a concise blocker summary when appropriate, release only this session's claim, and sync tracker state according to repository conventions. Do not modify an issue or PR owned by another session.
3. Select the next oldest issue while excluding candidates already considered. Inspect no more than one fallback issue, and never advance after the fallback or after any write-producing outcome.
4. A GitHub access or authentication failure that prevents selecting another issue is run-wide `GLOBAL_BLOCKED`; stop instead of attempting a fallback.

### Step 7: Finalization and Handoff

1. Remove this session's ownership marker when work ends. Never remove another agent's claim.
2. Apply review or completion labels only when the repository uses those labels. Record the final outcome using [outcomes-and-deadlocks.md](references/outcomes-and-deadlocks.md).
3. Notify people only through an explicitly authorized or repository-configured channel. Include relevant issue and PR links, and do not disclose credentials or secret values.

## Outcome Summary Contract

Always report:

1. The primary issue and its outcome; include the fallback issue only if one was processed.
2. Whether the agent made code, issue, or PR writes; identify any remaining blocker and any bounded recovery attempt.
3. Tools used (`gh`, GitHub MCP, repository scripts) and verification performed: tests, CI, reviews, preview URL and deployed SHA when available, and E2E. State `N/A` or `unverified` where appropriate.
4. Final GitHub issue/PR state and whether this session's claim was released.
5. Any authorized notification sent, or required human action.

## Error Handling

- **GitHub authentication:** Check `gh auth status`. Use an available GitHub MCP path if the CLI cannot authenticate. If both paths fail, record run-wide `GLOBAL_BLOCKED` and stop. Never print tokens or credentials.
- **Merge conflicts:** Use the actual PR base branch and repository instructions; do not assume a branch name. Resolve only when safe, then rerun applicable checks. If the correct resolution is unclear, stop with `AMBIGUOUS`.
- **Preview failure:** Resolve the configured deployment target and compare its deployed revision with the PR head where possible. After bounded retries, classify an issue-specific failure as `LOCAL_DEADLOCK`; classify an access or tooling failure that prevents all work as `GLOBAL_BLOCKED`.
- **Ownership conflict:** Do not remove or overwrite an active foreign claim. Wait or stop with `CLAIMED`/`NEEDS_USER` according to whether the user selected a specific issue.
