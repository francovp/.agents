#!/usr/bin/env bash
# verify-e2e.sh
# Runs a project E2E command with bounded retries.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/gh-auth-utils.sh"

if [ "$#" -lt 1 ] && [ -z "${E2E_COMMAND:-}" ]; then
  echo "Usage: $0 '<e2e-command>'  (or set E2E_COMMAND env var)" >&2
  exit 1
fi

trap 'restore_gh_user' EXIT
ensure_repo_access_with_fallback

if [ "$#" -ge 1 ]; then
  E2E_CMD="$1"
else
  E2E_CMD="$E2E_COMMAND"
fi

echo "Running project E2E verification command..."
echo "Command: ${E2E_CMD}"

MAX_ATTEMPTS=3
DELAY_SECONDS=5
ATTEMPT=1
SUCCESS=0

while [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; do
  echo "Attempt $ATTEMPT of $MAX_ATTEMPTS..."
  
  set +e
  bash -lc "$E2E_CMD"
  cmd_exit_code=$?
  set -e

  if [ "$cmd_exit_code" -eq 0 ]; then
    echo "Success: E2E verification command passed."
    SUCCESS=1
    break
  fi

  echo "Warning: E2E command failed with exit code $cmd_exit_code." >&2

  if [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; then
    echo "Waiting $DELAY_SECONDS seconds before next attempt..."
    sleep "$DELAY_SECONDS"
  fi
  ATTEMPT=$((ATTEMPT + 1))
done

if [ "$SUCCESS" -eq 1 ]; then
  exit 0
else
  echo "Error: Failed to pass E2E verification command after $MAX_ATTEMPTS attempts." >&2
  exit 1
fi
