---
description: Stage changes and create a Conventional Commits commit. Shows status first, asks before adding anything unexpected, never pushes. Use after finishing a unit of work.
argument-hint: [optional scope or summary]
disable-model-invocation: true
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git branch:*) Bash(git add:*) Bash(git commit:*)
---

## Context (auto-collected)
- Branch: !`git branch --show-current`
- Status: !`git status --porcelain`
- Changes vs HEAD: !`git diff HEAD`
- Recent commits (for style reference): !`git log --oneline -8`

## Task
1. Review the status above. If there are no changes, say so and stop.
2. Stage the changes, but be careful with untracked files:
   - Stage tracked modifications.
   - Before staging untracked files, check them. If any look unintended
     (build artifacts, large binaries, .env or other secret-like files,
     paths outside the scope of this change), list them and ask before
     adding. Otherwise include them.
   - Never blindly run `git add -A` without this check.
3. Read the resulting staged diff (`git diff --cached`) and write a
   Conventional Commits message from it:
   - Subject: `type(scope): summary` — imperative, lowercase, no trailing
     period, <=50 chars. Types: feat, fix, docs, refactor, perf, test,
     build, ci, chore.
   - Body only if non-trivial: blank line, then *why* not *what*, ~72 chars.
   - Match the recent commits above when unsure.
   - If $ARGUMENTS is provided, use it as a hint for scope/summary.
4. Show the final message, then commit the staged changes with it.
5. Do NOT push. Stop after the commit and report the result.
EOF
