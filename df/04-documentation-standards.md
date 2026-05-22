# 04 - Dark Factory Documentation Standards

## Required runtime files

| File | Purpose |
|---|---|
| `df/runtime/board.md` | Current task queue and states. |
| `df/runtime/activity-log.md` | Chronological record of factory activity. |
| `df/runtime/decisions.md` | Architecture/product/quality decisions. |
| `df/runtime/risks.md` | Open risks, blockers, and mitigations. |

## Required task artifact folder

Each task must have a folder:

```text
df/artifacts/{task-id}/
```

Recommended files:

```text
df/artifacts/{task-id}/
├── task.md
├── solution-design.md
├── dev-notes.md
├── qa-report.md
├── po-review.md
├── defects.md
├── handoffs.md
└── screenshots/
```

If a task has no UI, the `screenshots/` folder may be omitted and PO must state why screenshots are not applicable.

## Timestamp format

Use ISO-like local timestamp:

```text
YYYY-MM-DD HH:mm {timezone if known}
```

If timezone is unknown, use local system time and write `local`.

## Evidence links

Evidence can point to:

- files in this repository;
- terminal command output copied into an artifact;
- CI build URLs;
- PR URLs;
- issue tracker URLs;
- screenshot file paths;
- logs with secrets redacted.

## Markdown quality rules

- Be factual and concise.
- Separate expected vs actual behavior.
- Record assumptions explicitly.
- Record commands exactly as run.
- Redact secrets and personal data.
- Do not overwrite historical logs; append new entries.
- When correcting a previous entry, add a correction note instead of deleting history.

## Minimum activity log entry

```markdown
## {timestamp} - {role} - {task-id}

- State: {state}
- Action: {what was done}
- Evidence: {files/commands/screenshots}
- Result: {pass/fail/blocked/partial}
- Next: {next role/action}
```

## Screenshot rules

PO must capture screenshots for UI-facing changes when possible.

Screenshot evidence should include:

- final happy-path result;
- changed UI area;
- error state if relevant;
- browser/device/viewport when known;
- file path under `df/artifacts/{task-id}/screenshots/`.

If screenshot capture is impossible, PO must document:

- why it is impossible;
- what alternative evidence was used;
- whether acceptance is conditional.

## Test evidence rules

QA and Dev must record:

- test command;
- environment;
- result;
- failures;
- reruns;
- skipped tests and reason.

## Decision record rules

Use `df/templates/decision-record.md` for decisions that affect architecture, scope, behavior, security, data, test strategy, or deployment.

