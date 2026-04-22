# Flow Context

Use this block verbatim in subtask and review prompts for Superpowers work only.

```yaml
Flow Context:
  Flow: "superpowers"
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
Flow Context:
  Flow: "superpowers"
  Route: "chore:Light"
  Use: []
  Finish:
    - requesting-code-review
    - verification-before-completion
  Skip:
    - brainstorming
    - humanize-rlcr
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "Small scoped config edit with clear requirements."
```

## Read-Only Example

```yaml
Flow Context:
  Flow: "superpowers"
  Route: "review:Light"
  Use:
    - routing-flows
  Finish: []
  Skip:
    - brainstorming
    - humanize-rlcr
  Propagate: Copy this block unchanged into every subtask and review prompt.
  Rationale: "Bounded analysis task with no repo change."
```
