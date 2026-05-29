# Dark Factory User Manual

This manual is for a human operator who wants to start, observe, and control the Dark Factory loop from the terminal.

## What the factory does

The factory reads `df/runtime/board.md`, picks the highest-priority actionable task, resolves the responsible role from the task state, and launches exactly one role-session at a time.

In `auto` mode it keeps chaining role-sessions until one of these happens:

- all work is `DONE`;
- all remaining work is `BLOCKED`;
- there are no actionable tasks;
- the iteration cap is reached; or
- a role-session makes no board change and stall protection stops the loop.

## Prerequisites

Before starting the factory, make sure these prerequisites are satisfied:

1. you are in the repository root;
2. `df/runtime/board.md` exists and contains at least one actionable task;
3. your selected agent runner is installed and available on `PATH`;
4. the agent runner authentication is working for the account you want to use, if required;
5. `.df-factory.env` exists if you want local overrides for model, runner, or iteration defaults; and
6. you understand that the factory will update runtime files and task artifacts in this repository.

Quick checks:

```zsh
pwd
sed -n '1,80p' df/runtime/board.md
```

## Before you start

Make sure you are in the repository root:

```zsh
cd "/path/to/your/project"
```

The local launcher configuration lives in `.df-factory.env` when you create it.

Template defaults in this framework:

- adapter: `auto`
- max iterations: `300`

## Fast start

Start the factory with repository defaults:

```zsh
./start factory
```

## What you will see in the terminal

The same terminal will show three kinds of messages:

1. router messages, prefixed with `df-router`;
2. launcher messages, prefixed with `df-agent-runner`; and
3. live child-agent output, prefixed with `df-agent-runner][stdout]` or `df-agent-runner][stderr]`.

If you see heartbeat lines, the session is active and not silent.

## Common commands

### Preview only

```zsh
./call-start-factory.bash --dry-run
```

### Start one specific task

```zsh
./call-start-factory.bash --task-id TASK-001
```

### Force the first role-session

```zsh
./call-start-factory.bash --role sa
```

### Run one manual step only

```zsh
./call-start-factory.bash --adapter manual
```

### Limit the iteration count for one run

```zsh
./call-start-factory.bash --max-iterations 10
```

## How to stop the factory

Press `Ctrl+C` in the terminal where you started it.

## How to inspect current state

```zsh
sed -n '1,200p' df/runtime/board.md
sed -n '1,240p' df/runtime/activity-log.md
```

## Troubleshooting

### The factory looks stuck

If you see heartbeat lines such as:

```text
[df-agent-runner] Copilot still running (30s elapsed) ...
```

then it is not frozen; it is still processing.

### The wrong task was selected

Inspect `df/runtime/board.md` and verify the task `State`. The router chooses by state priority, not by free-text notes.

### I want different local defaults

Edit `.df-factory.env`.

Example:

```dotenv
DF_AGENT_CMD='./df/agent-router/run-role-session.bash'
DF_AGENT_RUNNER='copilot'
DF_AGENT_MODEL='gpt-5.4'
DF_AGENT_MODE='autopilot'
DF_FACTORY_ADAPTER='auto'
DF_FACTORY_MAX_ITERATIONS='300'
```

