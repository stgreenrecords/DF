# Dark Factory Template

Dark Factory is a documentation-first workflow for autonomous AI-assisted software delivery. This template packages the framework as a clean, project-agnostic, IDE-agnostic starting point.

## What this template includes

- core workflow rules under `df/`
- role definitions for `sa`, `designer`, `backend-dev`, `frontend-dev`, `devops`, `data-engineer`, `qa`, and `po`
- runtime tracking skeletons under `df/runtime/`
- reusable task and evidence templates under `df/templates/`
- a repository-owned role-session router under `df/agent-router/`
- cross-platform convenience wrappers: `call-start-factory.bash` and `call-start-factory.ps1`

## What this template intentionally excludes

- project-specific backlog items
- project-specific architecture, domain, or product content
- IDE-specific adapters or watcher automation
- IDE-specific files, docs, or launch flows
- repository-specific implementation code

## Recommended reading order

1. `AGENTS.md`
2. `df/00-start-here.md`
3. `df/01-operating-model.md`
4. `df/02-state-machine.md`
5. `df/03-orchestration-rules.md`
6. `df/04-documentation-standards.md`
7. the active role file in `df/roles/`
8. the current runtime files in `df/runtime/`

## Minimal structure

```text
.
|-- AGENTS.md
|-- call-start-factory.bash
|-- call-start-factory.ps1
|-- design/
`-- df/
    |-- 00-start-here.md
    |-- 01-operating-model.md
    |-- 02-state-machine.md
    |-- 03-orchestration-rules.md
    |-- 04-documentation-standards.md
    |-- agent-router/
    |-- artifacts/
    |-- roles/
    |-- runtime/
    `-- templates/
```

## First-time setup

1. Copy this folder into a new repository.
2. Update `AGENTS.md` only if you need repo-specific guardrails.
3. Start with an empty runtime board or add your first task to `df/runtime/board.md`.
4. Create project-specific backlog/docs outside this template if you need them.

## Start the factory

```bash
./call-start-factory.bash --dry-run
```

```powershell
.\call-start-factory.ps1 -DryRun
```

The included router is intentionally conservative. It supports the `manual` adapter only and expects transcript/evidence files to drive verification rather than IDE automation.

## Non-negotiable principles

- One role per session.
- No work is done until QA passes and PO accepts.
- Every meaningful action updates runtime evidence.
- Block unclear or unsafe work instead of guessing.
- Preserve user work and prefer minimal, reversible changes.

