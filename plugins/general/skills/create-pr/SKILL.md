---
name: create-pr
description: "Create a GitHub or GitLab Pull Request/Merge Request from the current or specified branch. Use when: opening a PR/MR, submitting code for review, creating a draft PR/MR, publishing a branch as a pull request/merge request, proposing changes to a repository."
argument-hint: "Optionally specify a title, base branch, or whether to create as a draft"
---

# Create a GitHub or GitLab Pull Request/Merge Request

Gather the necessary information, prepare a clear title and description, then call the tool to open the pull request.

## When to Use

- The user wants to open a PR for their current or a specified branch
- The user has finished a feature or fix and wants to submit it for review
- The user wants to create a draft PR to share work in progress
- The user asks to "open a PR", "create a pull request", or "submit for review"

## Procedure

### 0. Setup

1. **Create a new branch**: Create a new git branch ONLY if you are in `main` branch and if YOU ARE NOT in another branch. Name the branch according to the change you are working on, following the naming conventions of the project. Do it always in english language, using lowercase letters and hyphens to separate words. For example, if you are adding a new feature for user authentication, you might name the branch `feat-user-authentication`. If you are fixing a bug related to the login process, you might name it `fix-login-bug`. This helps in identifying the purpose of the branch easily.

### 1. Gather Information

Determine the required parameters before calling the tool:

- **Head branch**: If the user has not specified a branch, use workspace or git context to find the current branch name. Do not use `owner:branch` format - pass just the branch name (e.g. `my-feature`).
- **Base branch**: If the user has not specified a base branch, omit it and let the tool use the repository's default branch.
- **Draft**: Ask or infer whether the PR should be a draft. Default to non-draft unless the user indicates the work is not ready for review.
- **Summary of the changes**: After all changes and commits are made, create OR update (if not the first commit in the current branch) a markdown file (.md) inside the `./context/` directory, the file should be the name or the git branch (replace the slash with dashes). Example: `./context/feat-my-new-feature.md`. Also follow these rules:
    - VERY IMPORTANT: DO NOT create a new file if I ask you to make new changes if there is already one context file with the same name as the current git branch, just update the current one. 
    - VERY IMPORTANT: The content of the file should contain a summary of ALL the commit and changes made in the branch, considering all the commits/changes but describe it as it's a UNIQUE commit, including any relevant context, examples, and explanations.
    - VERY IMPORTANT: If you has more than 1 commit in the current branch, maintain the topic of the description based in the first commit of the branch an based on the original request prompt and DO NOT mention following fixes, refactors of previous commits or errors because of mistakes you make.
    - Use clear and concise language, and structure the documentation with headings, lists, and code blocks as needed.
    - DO NOT commit this file, it's in the .gitignore.
    - The title should be the same as the commit message, or if there is more than one commit, use the first commit message as the title.
    - Add a description that summarizes the changes made for a Pull Request description, and reference any relevant issues from Jira, Github or Confluence documentation (if applicable).
    - IMPORTANT: Add corresponding sections of the description only if they are relevant to the changes made, removing any sections that do not apply. The format of the Pull Request description is available in the [description template](./description-template.md) file

### 2. Check for Uncommitted or Unpushed Changes

Before creating the PR, inspect the working tree state. If you need to run git commands, give an explanation for why the command needs to be run.

1. **Check for uncommitted changes**: Use the git tool or VS Code SCM context to determine whether there are staged or unstaged file changes. If yes:
    1. **Create a commit using conventional-commits**:
        - Make sure to write a clear and concise commit message that follows the conventional commits format, including a precise subject line under 50 characters with the format `<type>(<optional scope>): <description>`.
        - Use types: feat, fix, build, ci, docs, style, refactor, perf, test. Always add a body for more details and footers for references or breaking changes.
        - If breaking, use BREAKING CHANGE: or ! after the type/scope.
        - Start the first line always with lowercase.
        - Examples: feat(lang): add Polish language, fix: prevent racing of requests, refactor(code): optimize loop performance.
        - Do it always in English language.
        - VERY IMPORTANT: Always make the commit assuming the repository has a pre-commit hook, so wait until is finished before proceed.
        - ONLY if the pre-commit command is not working or is not available, make commit with the --no-verify flag to skip it.
        - ALWAYS check for manual commits or changes not created by you, and include them in your commit.
        - Make the commit ONLY AFTER all unit tests, integration tests, functional tests (like running `python main.py` or `make run`), linters and pre-commit hooks are passing.

2. **Check for unpushed commits**: Determine whether the local branch has commits that have not been pushed to the remote (i.e. the branch is ahead of its upstream). If yes:
	 - Ask the user if they want to push before opening the PR, or let them know the tool will attempt to push automatically if needed.
	 - If pushing manually is preferred, run `git push` (or `git push --set-upstream origin <branch>` if no upstream is set yet) before calling the tool.

3. **Confirm the branch is on the remote**: The `create_pull_request` tool requires the head branch to be present on the remote. If it is not, push it first.

If all changes are already committed and pushed, proceed directly to the next step.

### 3. Prepare PR Details

**Title**: Use imperative mood, keep it under 72 characters, and describe *what* the PR does based in the context `/context/<git-branch-name>.md` file

**Body**: Description based in the context `/context/<git-branch-name>.md` file.

### 4. Create the Pull Request or Merge Request

Open a Pull Request or Merge Request from the newly created branch using either:

1. If you are in a Github Repository:
a. `gh pr create` CLI command (recommended)
```
$ gh pr create --title '<descriptive title>' --body '<description>' --base '<base-branch>' --head '<branch-name>' --draft --reviewer '<available-reviewers>'
```

b. `github-pull-request_create_pull_request` tool with the gathered parameters:

```
github-pull-request_create_pull_request({
	title: '<descriptive title>',
	head: '<branch-name>',        // branch name only, not owner:branch
	body: '<description>',        // optional but recommended
	base: '<base-branch>',        // optional; omit to use repo default
	draft: false,                 // set true for work-in-progress
	headOwner: '<owner>',         // optional; omit if same as repo owner
	repo: { owner: '<owner>', name: '<repo>' }  // optional
})
```

2. If you are in a Gitlab Repository:
a. `glab mr create` CLI command (recommended)
```
glab mr create --title '<descriptive title>' --description '<description>' --source-branch '<branch-name>' --target-branch '<base-branch>' --draft --reviewer '<available-reviewers>'
```

b. `gitlab-create_merge_request` tool with the gathered parameters

### 5. Confirm Result

After the tool returns successfully:

- Report the PR number and URL to the user as a markdown link. The link should be:
  - For Github Repository: VS Code URI like `vscode-insiders://github.vscode-pull-request-github/open-pull-request-webview?uri=https://github.com/microsoft/vscode-css-languageservice/pull/460` or `vscode://github.vscode-pull-request-github/open-pull-request-webview?uri=https://github.com/microsoft/vscode-css-languageservice/pull/460`.
  - For Gitlab Repository: the URL of the merge request on Gitlab.
- Mention the base branch the PR targets.
- If the PR was created as a draft, remind the user to mark it ready for review when appropriate.

6. **Request reviews**: If you have a tool for it available, request reviews from Copilot, @codex or available code review agents. Also add relevant team members or stakeholders to ensure the changes are reviewed and approved before merging.

## Best Practices

### Titles
- Use conventional-commits format for the title also
- Be specific: `fix: null pointer in user login flow` beats `fix: bug`.
- Keep it under 72 characters so it displays cleanly in GitHub and email notifications.

### Descriptions
- Start with a one-sentence summary.
- Explain *why* the change is needed, not just *what* it does - reviewers benefit from context.
- Reference related issues in the References section with `Fixes #<number>` or `Closes #<number>` to auto-close them on merge.
- If the change is large, add a brief list of the main files or components touched.

### Draft PRs
- Use `draft: true` when the code is not yet ready for formal review (e.g. work in progress, awaiting feedback on approach, CI not yet passing).
- Draft PRs are visible to collaborators but will not show as review-requested until marked ready.
- Suggest using a draft when the user mentions they are still working on it or just want early feedback.

Also, follow these very important rules for completing the task:

- VERY IMPORTANT: Execute terminal commands assuming we are in a git repository and in a virtual environment, but DO NOT try to activate or deactivate it.
- VERY IMPORTANT: ALWAYS check if there are uncommitted changes, manual git commits or changes not created by you, and include them in your context.
- VERY IMPORTANT: ALWAYS use the Context7 MCP tools to fetch for relevant documentation about dependencies/libraries/packages to complete the task.
