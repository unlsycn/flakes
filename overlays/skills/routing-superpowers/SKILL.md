---
name: routing-superpowers
description: Use when the current work does not already have an explicit active route - before selecting skills or workflows, before delegating, and whenever new information may change the route
---

# Routing Superpowers

## Overview

Route first. Then execute the chosen flow consistently.

This is the mandatory entry point whenever a route must be established or revised. Determine the most appropriate route for the task, make it explicit, and keep later agents aligned to that active route.

<EXTREMELY-IMPORTANT>
If the current work does not already have an explicit active route, you MUST route it now.

If new information may change the active route, you MUST route again before selecting skills, changing workflows, or delegating.

Do not proceed on an implicit route. Do not choose skills first and justify the route later.
</EXTREMELY-IMPORTANT>

## When to Use

Use this whenever a route must be established or revised.

This includes the start of new work, delegation, and any change that may invalidate the current `Route Context`.

## Route Selection

Classify the task on two axes:

- `task_type`: `inspect | review | chore | implement | debug`
- `lane`: `Light | Design-only | Designed execution`

Choose the most appropriate lane for the task:

- `Light`: bounded analysis, mechanical edits, config work, or small changes with clear scope
- `Design-only`: design or requirements need clarification, but a formal implementation plan is not yet warranted
- `Designed execution`: the task is multi-stage, cross-cutting, plan-worthy, or expensive to redo

## Flow Rules

- `Light`
  - work directly
  - skip `brainstorming` and `writing-plans`
  - for implementation changes, finish with `requesting-code-review` and `verification-before-completion`
- `Design-only`
  - use `brainstorming`
  - reroute after the design result
- `Designed execution`
  - use `brainstorming`, then `writing-plans`
  - execute with `executing-plans` or `subagent-driven-development`
  - finish with `requesting-code-review` and `verification-before-completion`

Add extra skills only when triggered:

- `systematic-debugging` when root cause is unclear
- `receiving-code-review` when addressing review feedback
- `test-driven-development` when behavior changes and practical tests can be written
- `using-git-worktrees` when isolation, parallel work, or higher-risk execution justifies it

## Required Announcement

Before substantive work, publish:

```text
Route: <task_type> + <lane>
Use: <skills selected>
Skip: <heavy skills skipped and why>
```

Then create a `Route Context`. Use the canonical template in `references/route-context.md`.

## Propagation

The controller must create the active `Route Context` and paste that block into every subtask and review prompt unchanged.

Every child agent must carry the active block forward unchanged unless a new routing decision has been made.

When the route changes, replace the old block with the new active `Route Context` before selecting skills, changing workflows, or delegating again.

## Common Mistakes

- routing too late, after skills or workflows have already been chosen
- treating every coding task as `Designed execution`
- letting a reviewer or subagent continue on an outdated route
- omitting `verification-before-completion`
