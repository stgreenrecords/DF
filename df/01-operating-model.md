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
  -> INTAKE
  -> REFINEMENT_IN_PROGRESS
  -> REFINEMENT_QUESTIONS (loop until all questions answered)
  -> REFINED
  -> NEEDS_ARCHITECTURE (if needed)
  -> READY_FOR_DEV
  -> DEV_IN_PROGRESS
  -> READY_FOR_QA
  -> QA_IN_PROGRESS
  -> READY_FOR_PO
  -> PO_REVIEW
  -> DONE
  -> next task
```

If the task already has clear acceptance criteria and no refinement is needed, it may skip directly from `OPEN` to `NEEDS_ARCHITECTURE` or `READY_FOR_DEV`.

If architecture is unnecessary for a small, low-risk task, `dev` may document `Architecture: not required` with a reason and move directly from `REFINED` to `READY_FOR_DEV`.

## Definition of Refined

A task may move to `REFINED` only when:

- raw input has been converted into a clear task summary and business goal;
- acceptance criteria are specific, testable, and scoped;
- refinement questions are answered with documented answer authority, or explicitly marked not applicable;
- critical unanswered product, legal, security, compliance, budget, or scope decisions are not present;
- low-risk assumptions, if any, are documented in `task.md` and referenced in the next handoff;
- independent deliverables have been split into child tasks or documented as intentionally bundled;
- expected validation approach is known well enough for Dev and QA to plan tests.

A task must not be marked `REFINED` when the only basis for a critical product decision is an AI-generated guess.

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
- refinement is complete (acceptance criteria exist or assumptions are documented);
- all refinement questions have been answered with authority, documented as safe low-risk assumptions, or moved to blockers;
- no critical unanswered refinement decision remains;
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

