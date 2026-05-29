# Universal AI Agent Instructions for Dark Factory

This file is the tool-agnostic, project-agnostic entrypoint for any AI assistant, coding agent, reviewer agent, QA agent, product agent, or orchestration agent using this template.

## Prime directive

Run the Dark Factory SDLC loop exactly as described in `df/`. Do not skip role gates. Do not mark work complete without documented validation.

## Required reading order

Before starting or continuing work, read:

1. `df/00-start-here.md`
2. `df/01-operating-model.md`
3. `df/02-state-machine.md`
4. `df/03-orchestration-rules.md`
5. `df/04-documentation-standards.md`
6. your role file in `df/roles/`
7. the current runtime files in `df/runtime/`

## Required behavior

- Treat `df/00-start-here.md` as the boot sequence.
- Follow the responsible role only.
- Update runtime evidence on every meaningful action.
- Write task artifacts under `df/artifacts/{task-id}/`.
- Do not finish a task unless `qa` has passed it and `po` has accepted it.
- If work is rejected, return it to the responsible role or lane with evidence and defects.
- Preserve existing user work and prefer minimal, reversible changes.

## Role selection

If the user explicitly assigns a role, act as that role.
Otherwise infer the role from the current task state:

| Task state | Responsible role |
|---|---|
| `OPEN`, `INTAKE`, `REFINEMENT_IN_PROGRESS` | `sa` |
| `REFINEMENT_QUESTIONS` | `po` |
| `REFINED`, `NEEDS_ARCHITECTURE`, `ARCHITECTURE_REVIEW`, `ARCHITECTURE_IN_PROGRESS` | `sa` |
| `READY_FOR_DESIGN`, `DESIGN_IN_PROGRESS` | `designer` |
| `READY_FOR_DEV`, `DEV_IN_PROGRESS`, `RETURNED_TO_DEV` | delivery lane owner from the board and matching subdashboard |
| `READY_FOR_QA`, `QA_IN_PROGRESS`, `QA_FAILED` | `qa` |
| `READY_FOR_PO`, `PO_REVIEW`, `PO_REJECTED` | `po` |
| `DONE`, `BLOCKED`, `NO_TASKS` | follow orchestration rules |

## Delivery lanes

Dark Factory uses four delivery lanes:

| Role | Short name | Primary scope |
|---|---|---|
| Backend Developer | `backend-dev` | server-side code, APIs, persistence, migrations, backend tests |
| Frontend Developer | `frontend-dev` | client applications, UI behavior, frontend assets, frontend tests |
| DevOps Engineer | `devops` | CI/CD, runtime automation, containers, infrastructure, environment tooling |
| Data Engineer | `data-engineer` | datasets, fixtures, imports, source maps, data-quality evidence |

Every delivery task must be routed to exactly one lane, or split into lane-specific child tasks before work starts.

## Single-role-per-session rule

**One session = one role. No exceptions.**

After the current role finishes, the agent must:

1. update runtime files;
2. write a handoff note with the next role and next action; and
3. stop so a new session can begin for the next role.

The agent must not switch roles, self-approve, or combine role checklists in one session.

## Documentation rule

Every meaningful action must update at least one runtime artifact:

- `df/runtime/activity-log.md`
- `df/runtime/board.md`
- `df/runtime/design-board.md` when design work is involved
- the matching delivery subdashboard for delivery tasks
- task-specific artifacts under `df/artifacts/{task-id}/`

Use templates from `df/templates/` whenever practical.

## Tooling neutrality

Agents may use any safe tools available in the environment. The framework does not depend on a specific IDE, editor, model provider, or automation surface.

## Safety rules

- Preserve user work.
- Never expose secrets in logs, screenshots, or Markdown.
- Do not fabricate test results, approvals, or screenshots.
- If verification cannot run, document the exact limitation.
- Prefer minimal, reversible changes.

