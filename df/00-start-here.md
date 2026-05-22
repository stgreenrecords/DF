# 00 - Dark Factory Start Here

This is the boot sequence for every AI agent.

## Mission

Operate a self-correcting SDLC loop where AI agents deliver tasks through development, QA, and product-owner acceptance with full traceability.

## Human start command

Any of these commands starts the factory:

```text
Dark Factory: start work.
DF start.
Start the factory.
Pick up the next task.
Continue SDLC.
```

The exact wording does not matter. If the intent is to begin or continue autonomous delivery, start the loop.

## Boot sequence

1. Read this file.
2. Read `df/01-operating-model.md`.
3. Read `df/02-state-machine.md`.
4. Read `df/03-orchestration-rules.md`.
5. Read `df/04-documentation-standards.md`.
6. Read the relevant role file in `df/roles/`.
7. Inspect `df/runtime/board.md`.
8. Pick the highest-priority task that is not blocked.
9. Create or update a task folder under `df/artifacts/{task-id}/`.
10. Execute the responsible role's checklist.
11. Update runtime documentation.
12. Hand off to the next role.
13. Continue until the factory has no actionable tasks or is blocked.

## Task selection order

Choose tasks in this order:

1. Tasks explicitly requested by the user in the current message.
2. Tasks marked `RETURNED_TO_DEV`, because rejected work must be fixed first.
3. Tasks marked `QA_FAILED` or `PO_REJECTED`.
4. Tasks marked `READY_FOR_DEV` by priority.
5. Tasks marked `OPEN` by priority.
6. Bugs before enhancements when priority is equal.
7. Smaller unblocked task before larger task when all else is equal.

## If there is no board yet

Create `df/runtime/board.md` from `df/templates/board.md`. Add an initial task if the user provided one. If no task exists, record `NO_TASKS` and ask the human to add a task.

## If requirements are unclear

Do not invent critical business requirements. Add questions to the task artifact and mark the task `BLOCKED` if the ambiguity prevents safe work. If a reasonable assumption can be made safely, document it and continue.

## Factory heartbeat

At the end of every agent turn, document:

- current role;
- task id;
- current state;
- actions completed;
- evidence produced;
- next role/action;
- blockers, risks, and assumptions.

