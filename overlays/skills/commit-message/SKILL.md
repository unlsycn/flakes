---
name: commit-message
description: Draft a commit message for the currently staged changes by inspecting the staged diff and recent local commit history
---

# Commit Message

## Goal

Analyze staged changes and recent git history to generate a concise commit
message following recent patterns.

## Required workflow

1. Check whether there are staged changes.
2. Inspect the staged diff and staged diff summary.
3. Inspect recent local commit history to match the existing style.
4. Draft a commit message.
5. Ask the user whether to proceed.
6. If the user agrees, commit with `--signoff`.

## Expected behavior

- Default to a single subject line.
- Only add a body when the change is not self-explanatory and the subject
  alone cannot convey why the change was made.
- Prefer the local repository's existing commit style.
- The body should explain rationale, not list individual file changes.
- Do not append `Co-Authored-By` trailers.
- If there are no staged changes, say so plainly instead of drafting a message.

## Suggested checks

- `git status --short`
- `git diff --cached --stat`
- `git diff --cached`
- `git log --oneline -n 10`

## Output

Provide:

- a proposed subject line
- an optional body when needed
- a brief note on why that message matches the staged change
- a confirmation question before committing

If the user confirms, proceed with `git commit --signoff`.
