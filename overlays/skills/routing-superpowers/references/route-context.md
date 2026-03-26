# Route Context

Use this block verbatim in subtask and review prompts.

```yaml
Route Context:
  Route: implement:Designed-execution
  Use:
    - ...
  Skip:
    - ...
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "<1 short sentence>"
```

## Minimal Example

```yaml
Route Context:
  Route: chore:Light
  Use:
    - requesting-code-review
    - verification-before-completion
  Skip:
    - brainstorming
    - writing-plans
    - test-driven-development
    - using-git-worktrees
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "Small scoped config edit with clear requirements."
```

## Upgrade Example

```yaml
Route Context:
  Route: implement:Designed-execution
  Use:
    - brainstorming
    - writing-plans
  Skip:
    - using-git-worktrees
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "Cross-cutting behavior change with unresolved design edges."
```
