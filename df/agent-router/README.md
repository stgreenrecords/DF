# Dark Factory Agent Router

The router lets a human **start the factory once** and then drives the SDLC loop
automatically. On each iteration it:

1. reads `df/runtime/board.md`;
2. selects the highest-priority actionable task (per `df/00-start-here.md`);
3. resolves the responsible role from the task state (and the delivery lane from
   the board owner column); and
4. launches exactly **one** fresh role-session through the chosen adapter.

After a session returns, the router re-reads the board and launches the next
role-session, repeating until the work reaches `DONE` / `NO_TASKS` / `BLOCKED`,
the safety `--max-iterations` cap is hit, or a session makes no board change
(stall protection).

This preserves the **one role per session** principle — each iteration is an
isolated single-role session — while removing the need for a human to re-trigger
each role by hand.

For human-facing start, monitoring, and troubleshooting instructions, see
`FACTORY-USER-MANUAL.md` in the repository root.

## Files

- `start-factory.bash` — entrypoint and main loop.
- `state-role-map.bash` — state → role mapping and task-selection ranking.
- `board-parser.bash` — `board.md` table parser.

## Usage

```bash
# One-time local setup for your agent launcher.
cp .df-factory.env.example .df-factory.env

# Default startup: auto adapter, 300 iterations.
./start factory

# Equivalent direct wrapper invocation.
./call-start-factory.bash

# Autonomous with explicit one-off overrides.
DF_AGENT_CMD="my-agent-cli" ./call-start-factory.bash --adapter auto --max-iterations 300

# Plan only, no sessions launched.
./call-start-factory.bash --dry-run

# Conservative: prepare ONE role-session prompt and stop (human-driven chaining).
./call-start-factory.bash --adapter manual
```

## Adapters

| Adapter | Behavior |
|---|---|
| `manual` | Prints the next role-session prompt and stops after one role. A human copies it into a new session. |
| `auto`   | Runs `$DF_AGENT_CMD` for every role-session and loops automatically until a stop condition. |

`call-start-factory.bash` loads an optional repo-local `.df-factory.env` file
before launching the router. Use it to persist `DF_AGENT_CMD` and override the
default startup values without retyping them on every run.

### `auto` adapter contract

`DF_AGENT_CMD` must run exactly one role-session. The router calls it as:

```text
$DF_AGENT_CMD <role> <task-id> <state> <prompt-file>
```

and pipes the same prompt on stdin. The command MUST update `df/runtime/board.md`
to reflect the new task state before returning. If the board is unchanged after a
session, the router stops with a stall error to avoid an infinite loop.

`DF_AGENT_CMD` is intentionally tool-neutral: point it at any AI agent CLI, script,
or wrapper that can read the prompt and act on the repository.

## Stop conditions

- no actionable task remains (`NO_TASKS` / all `DONE` / all `BLOCKED`);
- `--max-iterations` reached (re-run to continue);
- a role-session produced no board change (stall protection);
- the agent command exits non-zero (the loop aborts).
