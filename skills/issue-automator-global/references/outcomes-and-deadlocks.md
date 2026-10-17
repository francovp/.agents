# Outcomes and Deadlock Policy

End every issue candidate with exactly one outcome. Also report whether the agent made code, issue, or PR writes; that determines whether a fallback is allowed.

## Outcomes

- `DONE`: The issue is complete and its GitHub state reflects the result.
- `IN_REVIEW`: A PR is handed to a human for review and the repository's review state is synchronized.
- `SHIPPED`: The implementation is already covered by a merged PR or is otherwise shipped.
- `SYNCED`: Only issue/PR state or labels needed synchronization.
- `LOCAL_DEADLOCK`: An issue-specific problem prevents safe progress on this item, but does not block other repository work.
- `GLOBAL_BLOCKED`: Repository-wide access, authentication, or tooling prevents safe work. If a repository uses this label for a single PR deployment blocker, record that its scope is item-specific.
- `NEEDS_USER`: Progress depends on a user decision or missing information. This is a terminal handoff.
- `AMBIGUOUS`: The requested result or safe action cannot be determined. This is terminal.
- `CLAIMED`: A fresh ownership claim belongs to another agent. This is a zero-write outcome; do not edit the issue or its PR.

## Fallback Policy

Only an issue selected from the oldest-issue queue may advance to a fallback. An explicitly named issue is always terminal for this run if it is already handled, claimed, blocked, ambiguous, or waiting for user input.

For an unspecified queue selection, at most one fallback is allowed, and only after the primary issue ends with no agent writes as `CLAIMED`, `LOCAL_DEADLOCK`, an item-scoped `GLOBAL_BLOCKED` after one bounded recovery attempt, or pre-existing `IN_REVIEW` that required no agent writes. The run may therefore consider no more than two issue candidates total. Do not inspect later candidates until a fallback is allowed; never continue after the fallback or after any issue/PR/code writes.

`NEEDS_USER`, `AMBIGUOUS`, `DONE`, `SHIPPED`, `SYNCED`, write-producing `IN_REVIEW`, write-producing `GLOBAL_BLOCKED`, and run-wide `GLOBAL_BLOCKED` stop the run.

## Deadlock Policy

1. Classify a blocker by scope. An issue-specific failed check, preview, or missing acceptance detail is local. A broken GitHub authentication path, unavailable repository access, or workspace/tooling failure that prevents all work is global.
2. Try an unblock only when a clear, bounded action may change the result. Do not repeat an unchanged failure indefinitely.
3. If a local blocker remains, write a concise summary with the observed failure and smallest safe next action when the repository workflow supports that update. Release only this session's claim.
4. For an item-scoped `GLOBAL_BLOCKED`, make one bounded recovery attempt before deciding whether to continue. If GitHub remains available and no agent writes were made, it may use the single fallback. If access to GitHub itself is unavailable, stop with `GLOBAL_BLOCKED`.
5. A foreign ownership claim is not a blocker to remove. Record `CLAIMED` and leave the issue and PR unchanged.
6. Missing product authority or materially unclear requirements are `NEEDS_USER` or `AMBIGUOUS`, never `LOCAL_DEADLOCK`.
