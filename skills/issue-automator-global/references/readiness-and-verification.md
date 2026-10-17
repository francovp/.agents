# Readiness and Verification

Use repository instructions and CI configuration as the source of truth. Classify the change before selecting checks.

## Documentation-Only Changes

A change is documentation-only when it does not alter runtime behavior, tests, scripts, dependencies, API/schema contracts, or build, CI, and deployment configuration. Run relevant documentation checks when configured. Code tests, app startup, code-only checks, and preview verification are `N/A` unless the repository instructions or user explicitly require them. Do not bypass branch protection or claim an unrun check passed.

## PR Readiness

Before handing a PR to a human:

1. Confirm the implementation matches the issue's acceptance criteria.
2. Confirm applicable tests and required checks pass, or are conclusively non-blocking under repository policy.
3. Read all actionable review feedback, including inline review threads and top-level comments. Address or explain each unresolved item; paginate when required by the API.
4. Confirm the PR links the source issue and that no active ownership conflict remains.
5. Confirm preview and E2E status only when those checks apply to the change and the repository has configured them.

If any required criterion is uncertain or requires product authority, hand off for human review and record the exact open question. Do not merge unless the user explicitly authorized merging or repository instructions clearly authorize it.

## Preview and E2E Verification

For code changes, use the deployment mechanism configured by the current repository. Resolve a preview URL from its active deployment record or documented resolver; never assume a host from the PR number or from another repository. Verify the relevant health check and changed routes, and compare the deployed revision with the PR head when the platform exposes a revision identifier. Run the repository's relevant E2E flow when configured.

If no preview is configured or available, record preview verification as `N/A` or `unverified`, with the reason. Do not label an unverified deployment healthy. Treat a failing preview as issue-specific only after checking that the URL and deployed revision target the current PR.

## Bounded Retries and Waiting

- Retry an action only when new evidence or a changed state gives it a reasonable chance to succeed.
- Bound checks and waits according to repository CI/deployment policy. Do not poll continuously or retry indefinitely.
- Observe a quiet period only when the repository requires one. Check review threads and checks at the documented intervals; do not invent a duration.
- A new commit may require re-running applicable checks. A new discussion requires a fresh review of that feedback.
- After repeated issue-specific failures, record `LOCAL_DEADLOCK`; classify failures that block repository-wide access as `GLOBAL_BLOCKED`.
