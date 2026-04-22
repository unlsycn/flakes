---
name: routing-flows
description: Choose the right task-level flow before doing substantive work, then enter either Superpowers or Humanize intentionally.
---

# Routing Flows

## Overview

Pick the task-level flow first. Then execute that flow consistently.

This is the mandatory entry point whenever a task starts without an active flow, or when new information may invalidate the current flow choice.

<EXTREMELY-IMPORTANT>
If the current work does not already have an explicit active flow, you MUST choose one now.

Do not silently default to Superpowers. Recommend a flow, ask the user to confirm, then continue inside that flow.

If the user already explicitly selected `superpowers` or `humanize` for this task, respect that choice.

For repo-changing work, include `requesting-code-review` and `verification-before-completion` in `Finish` from the start. Do not mark the task complete until both have been run.

Repo-changing work includes adding, deleting, generating, formatting, or editing files that belong to the change.
</EXTREMELY-IMPORTANT>

## When to Use

Use this whenever a flow must be established or revised.

This includes the start of new work and any change that may invalidate the current task-level flow.

## Flow Selection

Recommend `superpowers` when the task is primarily:

- inspect
- review
- debug
- a bounded config change
- a small implementation that does not need formal plan generation or RLCR
- a task that should use `subagent-driven-development` as a side path

Recommend `humanize` when the task is primarily:

- multi-stage implementation
- cross-cutting work that is expensive to redo
- a task where formal planning already exists and execution should go through Humanize's looped review
- a task where the point is RLCR, hooks, and Humanize state tracking

## Shared Planning Backend

`brainstorming` and Humanize plan generation are shared planning stages.

Use them whenever the task needs an approved design or a formal implementation plan, regardless of whether execution will later continue in `superpowers` or `humanize`.

- On Codex, use `humanize-gen-plan`.
- On Claude, use `/humanize:gen-plan`.

Humanize plan refinement is not a default step after plan generation.
Use it only when the generated plan has been annotated with review comments that need to be resolved and removed before execution.

## Decision Style

Before substantive work, publish:

```text
Flow Recommendation: <superpowers|humanize>
Why: <1 short sentence>
Need Confirmation: yes
```

Then get user confirmation before entering the chosen flow.

## Entering Superpowers

If the user confirms `superpowers`, classify the task on two axes:

- `task_type`: `inspect | review | chore | implement | debug`
- `lane`: `Light | Design-only | Designed execution`

Choose the most appropriate lane:

- `Light`: bounded analysis, mechanical edits, config work, or small changes with clear scope
- `Design-only`: design or requirements need clarification
- `Designed execution`: plan-worthy execution that is not going through Humanize

Then publish:

```text
Flow: superpowers
Route: <task_type>:<lane>
Use: <skills selected for this phase>
Finish: <skills that must be run before the task is complete>
Skip: <heavy skills skipped and why>
```

Then create a `Flow Context`. Use the canonical template in `references/flow-context.md`.

- `Use` lists the skills active right now
- `Finish` lists the skills that must actually be run before the task is complete
- for repo-changing work, `Finish` MUST include `requesting-code-review` and `verification-before-completion`

## Entering Humanize

If the user confirms `humanize`, do not create or propagate a context block.

Instead, hand off directly into the Humanize phase that matches the task state:

- `brainstorming` when design clarification is still needed
- plan generation when a formal plan still needs to be generated
- plan refinement only when the plan already exists and contains review annotations
- RLCR when planning is complete and execution should enter the loop

Backend-specific handoff:

- Codex: `humanize-gen-plan`, `humanize-refine-plan`, `humanize-rlcr`
- Claude: `/humanize:gen-plan`, `/humanize:refine-plan`, `/humanize:start-rlcr-loop`

Once inside Humanize, follow Humanize's own process and hooks.

## Common Mistakes

- defaulting to Superpowers without asking
- treating flow selection and lane selection as the same thing
- treating Humanize plan generation as Humanize-exclusive instead of shared planning infrastructure
- treating plan refinement as mandatory after every plan generation
- generating a context block for Humanize
- leaving review and verification out of Superpowers repo-changing work
- continuing on an old task-level flow after the task has materially changed
