# Claude Code Adapter for Dark Factory

Claude Code must use `AGENTS.md` as the universal entrypoint and follow all files under `df/`.

## Startup behavior

When the user says any equivalent of `start work`, immediately:

1. Read `AGENTS.md`.
2. Read `df/00-start-here.md`.
3. Inspect `df/runtime/board.md`.
4. Select the highest-priority actionable task.
5. Act as the responsible role from `df/roles/`.
6. Continue the Dark Factory loop until no actionable task remains or a blocker is documented.

## Claude-specific notes

- Do not replace the Dark Factory workflow with ad-hoc coding.
- Keep a written handoff before switching roles.
- Use available tools for file edits, commands, tests, and screenshots if provided by the environment.
- If tool access is missing, document the limitation in `df/runtime/activity-log.md` and continue with the strongest available evidence.

