---
name: supermemory-forget
description: Remove or negate incorrect memory. Use when user says a stored preference, decision, or past context should be deleted, corrected, or no longer used.
allowed-tools: Bash(node:*)
---

# Super Forget

Use this when the user wants a stored memory removed or corrected.

## Step 1: Identify What To Remove

Figure out the specific memory, preference, or decision the user wants forgotten.

## Step 2: Format The Forget Request

Describe the memory to remove clearly and concretely.

Example:

```text
Forget the previous preference that I always want Tailwind. That is no longer true.
```

## Step 3: Run The Forget Script

```bash
node ~/.codex/supermemory/forget-memory.js "FORGET_REQUEST_HERE"
```

## Step 4: Confirm Outcome

Tell the user the forget request was sent and note that future recall should stop using that outdated memory.
