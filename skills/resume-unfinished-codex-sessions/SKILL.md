---
name: resume-unfinished-codex-sessions
description: >-
  Audit, inspect, resume, recover, or finish abandoned or incomplete Codex (and coding agent) sessions across repositories. Discovers unarchived threads in Codex sqlite databases, correlates active worktrees and branches, triages blockers, tests and completes WIP changes, merges ready PRs, and safely archives finished sessions.
---

# Resume Unfinished Codex Sessions

Audit, triage, recover, and finish stranded or incomplete Codex and coding agent sessions across local repositories.

## Hard Rules

1. **Ground Truth First**: Never guess what an agent did. Check the local SQLite database (`~/.codex/state_5.sqlite`), thread history (`~/.codex/thread_history_1.sqlite`), git status in the session's worktree (`~/.codex/worktrees/`), and live GitHub PR/issue state (`gh`).
2. **Do Not Overwrite Active Work**: Before modifying any session worktree, confirm whether a process or agent is currently writing to it (`ps aux | grep -i codex`, lockfiles in `~/.codex/thread-writer-locks`).
3. **Verify Before Shipping**: Never push, open a PR, or merge code without running the repository's test suite and verifying that relevant tests pass.
4. **Close the Loop**: When finishing a session, always complete the lifecycle: merge or open the PR, clean up local/remote branches, delete orphaned worktrees, and archive the thread in the Codex database so it does not clutter future sessions.
5. **No Secret Disclosure**: When inspecting logs or tool payloads, never output credentials, API keys, bearer tokens, or webhook secrets.

---

## Workflow

### Step 1: Discover Unarchived Sessions

Run a query against Codex's state database to find active and unarchived sessions:

```bash
sqlite3 ~/.codex/state_5.sqlite \
  "SELECT id, title, cwd, git_branch, datetime(updated_at, 'unixepoch'), preview \
   FROM threads \
   WHERE archived = 0 \
   ORDER BY updated_at DESC \
   LIMIT 15;"
```

For each candidate session, check:
- `cwd`: The working directory (often `~/.codex/worktrees/<hash>/<repo>`).
- `git_branch`: The branch the agent checked out.
- `updated_at`: When the last turn occurred.

### Step 2: Inspect Session History & Last Turn

To understand where the agent stopped and why, query the last few items from `~/.codex/thread_history_1.sqlite`:

```python
import sqlite3, json

conn = sqlite3.connect('/Users/fgvaleriop/.codex/thread_history_1.sqlite')
c = conn.cursor()
c.execute(
    'SELECT item_type, item_json FROM thread_items WHERE thread_id = ? ORDER BY rollout_ordinal DESC LIMIT 5',
    (thread_id,)
)
for it, ij in reversed(c.fetchall()):
    d = json.loads(ij)
    # Inspect type, text/content, command execution, and tool status
```

Common stopping reasons:
- **Waiting on CI**: The agent pushed a commit or PR, was waiting for CI checks, and timed out or exited.
- **Tool / Command Failure**: The agent ran an invalid command, missing dependency, or incorrect CLI flag and stalled.
- **Context Limit / Interrupted**: The agent exhausted tokens or was interrupted by the user mid-implementation.
- **Orphaned Exploration**: The agent was researching files or searching the web and stopped without committing.

### Step 3: Check Git & GitHub State in Session Worktree

Inspect the session's worktree directory:

```bash
cd "$SESSION_CWD"
git status --short
git log -n 3 --oneline
```

Check GitHub PR and issue status:

```bash
# Check if a branch has an open PR
gh pr list --head "$GIT_BRANCH" --json number,title,state,mergeable,statusCheckRollup

# Check linked issues if referenced in the branch or commit messages
gh issue view "$ISSUE_NUMBER" --json state,assignees,labels
```

---

## Session Classification & Resolution Playbook

Classify each unfinished session into one of five categories and execute the corresponding resolution:

### Category A: PR Ready / CI Green
The session created a pull request, and CI checks have completed successfully.

1. **Verify**:
   ```bash
   gh pr view <PR_NUMBER> --json state,statusCheckRollup,reviewDecision,mergeable
   ```
   Ensure `mergeable == MERGEABLE` and all CI checks are `SUCCESS`. Confirm no unanswered blocking review comments.
2. **Merge**:
   ```bash
   gh pr merge <PR_NUMBER> --squash --delete-branch
   ```
3. **Sync Local Base**:
   ```bash
   git -C "$REPO_DIR" checkout main && git -C "$REPO_DIR" pull --ff-only origin main
   ```
4. **Archive Session**:
   ```bash
   sqlite3 ~/.codex/state_5.sqlite \
     "UPDATE threads SET archived = 1, archived_at = strftime('%s','now') WHERE id = '$THREAD_ID';"
   ```

### Category B: WIP Changes with Passing Tests
The session was actively implementing a feature or bugfix, wrote code and tests, but stopped before committing, pushing, or opening a PR.

1. **Review Diff**:
   ```bash
   cd "$SESSION_CWD"
   git diff
   ```
2. **Run Targeted Tests**:
   Execute the specific unit and integration tests covering the modified files.
3. **Commit & Push**:
   ```bash
   git add .
   git commit -m "feat/fix(<scope>): <description> (#<ISSUE_NUMBER>)"
   git push -u origin "$GIT_BRANCH"
   ```
4. **Create PR**:
   ```bash
   gh pr create --title "..." --body "..." --base main --head "$GIT_BRANCH"
   ```
5. **Verify Preview / E2E**:
   Check CI checks on the newly opened PR. If ready, merge and archive.

### Category C: Blocked on Command / CLI Flag / Tool Failure
The session failed when executing a command or trying to interact with an external CLI.

1. **Isolate Root Cause**: Inspect the failed `commandExecution` or `toolCall` in `thread_history_1.sqlite`.
2. **Reproduce & Fix**: Test the CLI command directly with `--help` or documentation to find the correct flag, configuration file, or environment variable.
3. **Resume Implementation**: Apply the required fix, run tests, and advance the session to Category B or A.

### Category D: Duplicate / Competing Sessions
Multiple sessions tackled the same issue independently in separate worktrees.

1. **Compare Diff & Progress**: Evaluate which worktree has the more complete implementation, better test coverage, and cleaner architecture.
2. **Consolidate**: Port any missing tests or improvements from the secondary session into the primary branch.
3. **Release Claims**: Remove any stale `agent-claim` comments on GitHub issues from the abandoned session.
4. **Prune Stale Worktree & Archive**:
   ```bash
   git worktree remove "$STALE_WORKTREE_PATH"
   sqlite3 ~/.codex/state_5.sqlite \
     "UPDATE threads SET archived = 1, archived_at = strftime('%s','now') WHERE id = '$STALE_THREAD_ID';"
   ```

### Category E: Abandoned Automations / Stale Background Tasks
Periodic automation sessions that failed early, encountered timeouts, or left stale claims.

1. Check if the automation accomplished any durable work.
2. If no useful code was produced, release any claimed issues (`gh issue comment <ID> --body "agent-unclaim"`).
3. Archive the thread in `state_5.sqlite`.

---

## Archiving & Cleanup Checklist

Before concluding any session recovery:

- [ ] Uncommitted changes committed or cleanly discarded.
- [ ] PR merged, closed, or handed off with a clear summary.
- [ ] Remote branch deleted if PR was merged.
- [ ] Local base branch (`main` / `master`) updated.
- [ ] Worktree pruned if no longer needed (`git worktree prune`).
- [ ] Thread marked archived in `~/.codex/state_5.sqlite`:
  ```sql
  UPDATE threads SET archived = 1, archived_at = strftime('%s','now') WHERE id = '<THREAD_ID>';
  ```
