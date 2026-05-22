# 01 - Dark Factory Operating Model

## Roles

Dark Factory uses four required roles.

| Role | Short name | Purpose |
|---|---|---|
| Solution Architect | `sa` | Converts requirements into a safe, coherent technical plan and guards architecture quality. |
| Developer | `dev` | Implements the task, writes/updates tests, and prepares evidence for QA. |
| Quality Engineer | `qa` | Verifies the implementation through automated and manual-quality checks. |
| Product Owner | `po` | Validates business outcome through E2E review, screenshots, and acceptance/rejection. |

## Role ownership

A role owns the task only while the task is in that role's state. Ownership must be documented in `df/runtime/board.md` and the task artifact.

## Standard flow

```text
OPEN
  -> NEEDS_ARCHITECTURE
  -> READY_FOR_DEV
  -> DEV_IN_PROGRESS
  -> READY_FOR_QA
  -> QA_IN_PROGRESS
  -> READY_FOR_PO
  -> PO_REVIEW
  -> DONE
  -> next task
```

If architecture is unnecessary for a small, low-risk task, `dev` may document `Architecture: not required` with a reason and move directly from `OPEN` to `READY_FOR_DEV`.

## Rework flow

```text
QA_FAILED -> RETURNED_TO_DEV -> DEV_IN_PROGRESS -> READY_FOR_QA
PO_REJECTED -> RETURNED_TO_DEV -> DEV_IN_PROGRESS -> READY_FOR_QA
```

All rework must include defect evidence, reproduction steps, expected result, actual result, and severity.

## Communication protocol

Agents communicate through Markdown, not private memory.

Required communication points:

- role start note;
- role completion note;
- handoff note;
- blocker note;
- decision record for meaningful architecture/product decisions;
- verification evidence.

## Definition of Ready

A task is ready for development when:

- task id and summary exist;
- acceptance criteria exist or assumptions are documented;
- dependencies and blockers are known;
- architecture guidance exists when needed;
- expected validation path is defined.

## Definition of Done

A task is done only when:

- implementation is complete;
- relevant unit tests pass or a documented reason explains why none apply;
- relevant integration tests pass or a documented reason explains why none apply;
- QA has approved the task;
- PO has completed E2E validation;
- screenshots or equivalent visual evidence are attached for UI changes;
- PO has accepted the result;
- all runtime files are updated.

## Human-in-the-loop rules

Ask for human input only when required:

- credentials/secrets are missing;
- paid service or infrastructure change is needed;
- destructive data operation is required;
- legal/security/privacy risk exists;
- requirement ambiguity cannot be safely resolved;
- external system access is unavailable.

Do not ask humans to perform routine SDLC work that agents can do with available tools.

