# Dark Factory Framework

Dark Factory is a documentation-first workflow for autonomous AI-assisted software delivery.
This extracted folder contains only the reusable framework and startup tooling, without the current LAN file sharing project backlog or runtime history.

## Included

- framework rules under `df/`
- role guides under `df/roles/`
- reusable templates under `df/templates/`
- router scripts under `df/agent-router/`
- clean runtime skeletons under `df/runtime/`
- startup helpers: `start`, `call-start-factory.bash`, `call-start-factory.ps1`
- operator guide: `FACTORY-USER-MANUAL.md`

## Not included

- project-specific task backlog
- project-specific task artifacts
- project-specific runtime history
- project-specific decisions or risks

## Quick start

From this folder:

```zsh
./start factory --dry-run
```

That shows the next planned role-session without launching a real agent session.

## First use in a new project

1. copy this folder into a new repository;
2. update `AGENTS.md` only if you need repository-specific guardrails;
3. create or edit tasks in `df/runtime/board.md`;
4. configure `.df-factory.env` if you want local launcher defaults; and
5. start the factory.

## Main commands

Start with defaults:

```zsh
./start factory
```

Preview only:

```zsh
./call-start-factory.bash --dry-run
```

Manual one-step mode:

```zsh
./call-start-factory.bash --adapter manual
```

## More help

See:

- `FACTORY-USER-MANUAL.md`
- `AGENTS.md`
- `df/agent-router/README.md`

