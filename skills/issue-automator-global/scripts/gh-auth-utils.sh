#!/usr/bin/env bash
# gh-auth-utils.sh
# Helper functions to validate GitHub CLI auth, fallback to another logged-in
# user if the current account cannot access the current repository, and restore
# the original user after workflow completion.

# Saves the active gh user for later restoration.
save_gh_user() {
  if [ -n "${GH_AUTH_TMP:-}" ] && [ -f "$GH_AUTH_TMP" ]; then
    return 0
  fi

  GH_AUTH_TMP=$(mktemp /tmp/gh-auth-XXXXXX 2>/dev/null || mktemp -t gh-auth 2>/dev/null)
  gh auth status --json hosts --jq '.hosts["github.com"][] | select(.active) | .login' > "$GH_AUTH_TMP" 2>/dev/null || echo "" > "$GH_AUTH_TMP"
}

# Restores the gh user that was active before fallback switching.
restore_gh_user() {
  if [ ! -f "${GH_AUTH_TMP:-}" ]; then
    return 0
  fi

  local original_user
  original_user=$(cat "$GH_AUTH_TMP" 2>/dev/null || echo "")
  rm -f "$GH_AUTH_TMP" 2>/dev/null || true
  unset GH_AUTH_TMP

  if [ -n "$original_user" ]; then
    gh auth switch --user "$original_user" >/dev/null 2>&1 || {
      echo "Warning: Failed to restore gh user to '$original_user'." >&2
    }
  fi
}

current_gh_user() {
  gh auth status --json hosts --jq '.hosts["github.com"][] | select(.active) | .login' 2>/dev/null
}

list_gh_users() {
  gh auth status --json hosts --jq '.hosts["github.com"][].login' 2>/dev/null
}

switch_gh_user() {
  local user="$1"
  gh auth switch --user "$user" >/dev/null 2>&1
}

require_gh_auth() {
  if ! command -v gh &> /dev/null; then
    echo "Error: 'gh' CLI is not installed or not in PATH." >&2
    return 127
  fi

  if ! gh auth status &> /dev/null; then
    echo "Error: 'gh' CLI is not authenticated. Run 'gh auth login' or configure GITHUB_TOKEN." >&2
    return 1
  fi
}

has_repo_access() {
  gh repo view --json nameWithOwner --jq '.nameWithOwner' >/dev/null 2>&1
}

# Ensures gh is authenticated and can access the current repository. If the
# active user has no access, tries other logged-in users and keeps the first
# user that works.
ensure_repo_access_with_fallback() {
  require_gh_auth || return $?
  save_gh_user

  if has_repo_access; then
    return 0
  fi

  local original_user candidate
  original_user="$(current_gh_user || true)"

  while IFS= read -r candidate; do
    [ -n "$candidate" ] || continue
    [ "$candidate" = "$original_user" ] && continue

    if switch_gh_user "$candidate" && has_repo_access; then
      echo "Switched gh user to '$candidate' because '$original_user' has no access to this repo." >&2
      return 0
    fi
  done < <(list_gh_users)

  if [ -n "$original_user" ]; then
    switch_gh_user "$original_user" >/dev/null 2>&1 || true
  fi
  echo "Error: No logged-in gh user has access to this repository." >&2
  return 1
}
