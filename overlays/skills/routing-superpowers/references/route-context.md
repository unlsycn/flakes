# Route Context

Use this block verbatim in subtask and review prompts.

```yaml
Route Context:
  Route: "<task_type>:<lane>"
  Use:
    - ...
  Finish:
    - ...
  Skip:
    - ...
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "<1 short sentence>"
```

## Repo-Changing Example

```yaml
Route Context:
  Route: "chore:Light"
  Use: []
  Finish:
    - requesting-code-review
    - verification-before-completion
  Skip:
    - brainstorming
    - writing-plans
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "Small scoped config edit with clear requirements."
```

## Read-Only Example

```yaml
Route Context:
  Route: "review:Light"
  Use:
    - routing-superpowers
  Finish: []
  Skip:
    - brainstorming
    - writing-plans
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "Bounded analysis task with no repo change."
```
