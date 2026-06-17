---
description: Generate a Conventional Commits message from staged changes, without committing. Use when you want to review or copy a message yourself.
argument-hint: [optional scope or summary]
disable-model-invocation: true
allowed-tools: Bash(git status:*) Bash(git diff:*) Bash(git log:*) Bash(git branch:*)
---

## Context (auto-collected)
- Branch: !`git branch --show-current`
- Staged diff: !`git diff --cached`
- Recent commits (for style reference): !`git log --oneline -8`

## Task
1. If nothing is staged, say so and stop — there is no diff to describe.
2. Read the staged diff. If it mixes several unrelated changes, note that
   it should probably be split into separate commits, then continue.
3. Output a Conventional Commits message and nothing else:
   - Subject: `type(scope): summary` — imperative, lowercase, no trailing
     period, <=50 chars. Types: feat, fix, docs, refactor, perf, test,
     build, ci, chore.
   - Body only if the change is non-trivial: blank line after subject,
     then explain *why* not *what*, wrapped at ~72 chars.
   - Match the style of the recent commits above when unsure.
4. If $ARGUMENTS is provided, treat it as a hint for scope and/or summary.
5. Do not run git add or git commit. Only print the message.
EOF
