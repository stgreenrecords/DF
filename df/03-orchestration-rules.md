# 03 - Dark Factory Orchestration Rules

## Goal

Keep the SDLC moving after the human starts the factory. Agents should not wait for repeated human commands between roles.

## Main loop

```text
while factory is running:
  load board
  choose highest-priority actionable task
  choose role from task state
  execute role checklist
  validate outputs
  update documentation
  hand off to next role
  if task is DONE:
    choose next task
  if no task is actionable:
    record NO_TASKS or BLOCKED and stop
```

## Refinement loop

When a task enters `INTAKE`, the following sub-loop applies:

```text
SA reads raw input
SA generates only decision-grade questions + options + recommendations
SA moves task to REFINEMENT_QUESTIONS
PO answers questions from available product authority/context
if PO cannot answer safely:
  PO marks task BLOCKED for human/product input
PO moves task to REFINEMENT_IN_PROGRESS
SA reviews answers
if more questions needed (max 3 rounds):
  SA posts new questions -> loop
else:
  SA writes acceptance criteria
  SA moves task to REFINED
  SA decides: NEEDS_ARCHITECTURE or READY_FOR_DEV
```

### Refinement challenge rules

The refinement loop is mandatory for ambiguous work, but it must not become a bureaucracy loop or a hallucination source.

- Ask questions only when the answer can change scope, acceptance criteria, architecture, testing, risk, priority, or decomposition.
- Do not ask questions that can be answered by reading repository code, existing docs, tests, logs, or linked artifacts.
- Each question must include impact if unanswered and a recommended default when a safe default exists.
- The PO role may answer from documented business context, existing product decisions, or explicit human input only. If none exists, PO must not invent stakeholder intent.
- Critical unanswered questions must move the task to `BLOCKED`; they must not be converted into assumptions merely because the round limit was reached.
- Low-risk assumptions are allowed only when documented in `task.md`, referenced in the handoff, and later verified by QA/PO.
- If refinement discovers multiple independent deliverables, SA must split or propose child tasks instead of creating one oversized task.
- Refinement completion does not replace QA or final PO acceptance.

### Refinement skip conditions

The refinement loop may be skipped when:

- the task already has clear, testable acceptance criteria;
- the task is a well-defined bug with reproduction steps;
- a human explicitly marked the task as pre-refined;
- the task is a simple chore with no ambiguity.

Document the skip reason in the task artifact.

## Priority rules

Sort actionable tasks by:

1. production incident / critical bug;
2. user-requested task from current session;
3. rejected or failed task;
4. high business priority;
5. dependency unblocks other work;
6. oldest task;
7. smallest safe task.

## Parallel work rules

Agents may work in parallel only when tasks do not touch the same files, components, infrastructure, or acceptance criteria.

Parallel work is forbidden when:

- tasks modify the same code area;
- architecture is not stable;
- one task blocks another;
- the repository has unresolved merge conflicts;
- shared test environments cannot isolate changes.

## Handoff rules

Every handoff must include:

- task id;
- current state;
- previous role result;
- files changed or artifacts created;
- tests run and results;
- known risks;
- next role checklist;
- explicit acceptance or rejection criteria.

Use `df/templates/handoff.md`.

## Rework rules

If QA or PO rejects work:

1. Create/update a defect report in the task artifact folder.
2. Move task to `RETURNED_TO_DEV`.
3. Dev must fix root cause, not only the visible symptom.
4. Dev must add or update tests proving the defect is fixed when feasible.
5. The task must go through QA and PO again.

## Evidence hierarchy

Prefer stronger evidence:

1. automated tests and CI logs;
2. local command output;
3. browser/API/UI screenshots;
4. structured manual test notes;
5. reasoned code inspection.

Do not claim a test passed unless it was executed or an authoritative CI result was inspected.

## Tool failure handling

If an MCP tool, IDE action, terminal command, browser, test runner, or external service fails:

1. Retry once if failure looks transient.
2. Capture the failure message.
3. Try an alternative verification path.
4. If still blocked, document `BLOCKED` with exact reason.

## Budget and rate-limit handling

If an AI model, API, CI runner, or external service reaches a limit:

- record the limit;
- reduce scope to the current task only;
- switch to available tooling if safe;
- stop only when no safe progress remains.

## Security and privacy gate

Before executing commands, changing infrastructure, reading secrets, or using production data, agents must verify that the action is allowed by the current environment. Secrets must never be pasted into Markdown.

## Stop conditions

The factory may stop only when:

- all tasks are `DONE`;
- all remaining tasks are `BLOCKED`;
- no task exists;
- human explicitly says stop;
- continuing would risk data loss, security exposure, policy violation, or production outage.

