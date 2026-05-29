# 03 - Dark Factory Orchestration Rules

## Goal

Keep delivery moving after a human starts the factory, while preserving role separation and evidence quality.

## Main loop

```text
while factory is running:
  load board
  load design and delivery subdashboards
  choose the highest-priority actionable task
  choose the responsible role from task state
  execute exactly one role session
  validate outputs
  update runtime documentation
  hand off to the next role
  if no task is actionable:
    record NO_TASKS or BLOCKED and stop
```

## Refinement loop

When a task is ambiguous:

```text
SA reads raw input
SA asks only decision-grade questions
PO answers with documented authority
SA writes acceptance criteria
SA routes to architecture, design, or delivery
```

Rules:

- ask questions only when the answer can change scope, tests, risks, architecture, or acceptance criteria;
- do not ask questions that can be answered from repository context;
- use documented low-risk assumptions only when safe;
- block the task when a critical answer is missing.

## Priority rules

Sort actionable tasks by:

1. user-requested task in the current session;
2. rejected or failed work;
3. highest business priority;
4. dependency-unblocking value;
5. oldest task;
6. smallest safe task.

## Routing rules

- `designer` owns design packages.
- `backend-dev`, `frontend-dev`, `devops`, and `data-engineer` own delivery work.
- UI-facing frontend work must have design input first.
- Multi-lane work should be split into child tasks whenever practical.

## Handoff rules

Every handoff must include:

- task id;
- current state;
- previous role result;
- files changed or artifacts created;
- checks performed and results;
- known risks;
- next role instructions.

## Evidence hierarchy

Prefer stronger evidence in this order:

1. automated tests or machine validation;
2. exact command output;
3. screenshots or exported artifacts;
4. structured manual notes;
5. reasoned inspection.

## Tool failure handling

If a tool or command fails:

1. retry once if the failure appears transient;
2. capture the exact error;
3. try a safe alternative path;
4. if still blocked, document the blocker and stop.

## Stop conditions

The session must stop when:

- the current role's work is complete and the handoff is written;
- all tasks are `DONE`;
- all remaining tasks are `BLOCKED`;
- no task exists; or
- continuing would risk data loss, security exposure, or policy violation.

**One session = one role.**

