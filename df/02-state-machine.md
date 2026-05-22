# 02 - Dark Factory State Machine

This file defines task states and allowed transitions. Agents must update `df/runtime/board.md` when changing state.

## States

| State | Owner | Meaning |
|---|---|---|
| `OPEN` | factory | Task exists but has not been prepared. |
| `NEEDS_ARCHITECTURE` | `sa` | Task needs solution design before development. |
| `ARCHITECTURE_IN_PROGRESS` | `sa` | SA is designing or reviewing the approach. |
| `READY_FOR_DEV` | `dev` | Task can be implemented. |
| `DEV_IN_PROGRESS` | `dev` | Dev is implementing the task. |
| `READY_FOR_QA` | `qa` | Dev work is complete and ready for QA. |
| `QA_IN_PROGRESS` | `qa` | QA is verifying the task. |
| `QA_FAILED` | `qa` | QA found issues. |
| `READY_FOR_PO` | `po` | QA passed and PO review is needed. |
| `PO_REVIEW` | `po` | PO is performing E2E/product validation. |
| `PO_REJECTED` | `po` | PO rejected the result. |
| `RETURNED_TO_DEV` | `dev` | Rework is required. |
| `BLOCKED` | human/factory | Work cannot continue without external input. |
| `DONE` | factory | Task accepted and complete. |
| `NO_TASKS` | factory | No actionable work exists. |

## Allowed transitions

| From | To | Required evidence |
|---|---|---|
| `OPEN` | `NEEDS_ARCHITECTURE` | Architecture needed reason. |
| `OPEN` | `READY_FOR_DEV` | Acceptance criteria and no architecture needed reason. |
| `NEEDS_ARCHITECTURE` | `ARCHITECTURE_IN_PROGRESS` | SA start note. |
| `ARCHITECTURE_IN_PROGRESS` | `READY_FOR_DEV` | Solution design artifact. |
| `READY_FOR_DEV` | `DEV_IN_PROGRESS` | Dev start note. |
| `RETURNED_TO_DEV` | `DEV_IN_PROGRESS` | Rework plan. |
| `DEV_IN_PROGRESS` | `READY_FOR_QA` | Implementation summary and dev test evidence. |
| `READY_FOR_QA` | `QA_IN_PROGRESS` | QA start note and test plan. |
| `QA_IN_PROGRESS` | `QA_FAILED` | Defect report. |
| `QA_FAILED` | `RETURNED_TO_DEV` | QA handoff with reproduction steps. |
| `QA_IN_PROGRESS` | `READY_FOR_PO` | QA report with pass result. |
| `READY_FOR_PO` | `PO_REVIEW` | PO start note. |
| `PO_REVIEW` | `PO_REJECTED` | PO rejection report with screenshots/evidence. |
| `PO_REJECTED` | `RETURNED_TO_DEV` | Rework request. |
| `PO_REVIEW` | `DONE` | PO acceptance report and final evidence. |
| Any active state | `BLOCKED` | Blocker reason and owner. |
| `BLOCKED` | previous actionable state | Blocker resolution note. |
| `DONE` | next task state | Factory heartbeat and next task selection. |

## State update format

When changing state, append this block to `df/runtime/activity-log.md`:

```markdown
## {timestamp} - State change

- Task: {task-id}
- From: {old-state}
- To: {new-state}
- Role: {role}
- Reason: {why}
- Evidence: {links/files}
- Next: {next role/action}
```

## Blocker handling

When blocked:

1. Keep all work artifacts.
2. Document exact missing input.
3. Assign blocker owner: `human`, `external-system`, `credential-owner`, `security`, or `product`.
4. State what can continue independently.
5. Do not spin in a loop.

