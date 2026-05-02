---
name: brainstorming
description: Explore intent and design before implementation, then hand the approved spec to Humanize plan generation.
---

# Brainstorming Ideas Into Designs

Turn a loose request into an approved design before any implementation work starts.

<HARD-GATE>
Do not implement code, edit repository source files, or enter RLCR during brainstorming.
</HARD-GATE>

## Process

1. Explore the current repository context first.
2. Ask clarifying questions one at a time until purpose, constraints, and success criteria are clear.
3. Propose 2-3 approaches with trade-offs and a recommendation.
4. Present the recommended design in sections and get explicit user approval.
5. Write the approved spec to `.humanize/specs/YYYY-MM-DD-<topic>.md`.
6. After the spec is approved, hand off to the Humanize plan generator for the current backend.

## Key Rules

- One question at a time.
- Prefer concrete options over open-ended prompts when possible.
- Stay inside scope; do not add unrelated refactors.
- Follow existing repository patterns.
- The spec is the output of brainstorming. Planning belongs to Humanize.

## Spec Output

Every approved spec should be usable as direct input to:

```text
humanize-gen-plan --input .humanize/specs/<file>.md --output .humanize/plans/<file>.md
```

On Claude, the equivalent handoff is:

```text
/humanize:gen-plan --input .humanize/specs/<file>.md --output .humanize/plans/<file>.md
```
