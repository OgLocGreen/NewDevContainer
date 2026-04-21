---
mode: 'ask'
description: 'Load all reference docs from docs/package_b/ into context'
---

Read and internalize all files in `docs/package_b/` as authoritative reference material
for this session.

For each file found:
1. Read the full content.
2. Note the package name, available types, key API calls, and any listed gotchas.
3. Confirm with a short summary per file: *"Loaded: <filename> – <one-line description>"*.

From this point on, apply this knowledge automatically whenever the user asks about
code that involves these packages — without being asked again.
