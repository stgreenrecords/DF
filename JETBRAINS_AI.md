# JetBrains AI Assistant Adapter for Dark Factory

JetBrains AI Assistant must follow `AGENTS.md` and all workflow files in `df/`.

## Start command behavior

When the user asks to start work:

1. Inspect the current project and `df/runtime/board.md`.
2. Pick the highest-priority actionable task.
3. Use the role instructions in `df/roles/`.
4. Use IDE capabilities for code navigation, tests, inspections, run configurations, and screenshots when available.
5. Record every step in the runtime documentation.

## IDE-specific expectations

- Prefer project-aware inspections and tests before declaring work complete.
- Preserve current editor/user changes.
- If a task needs UI verification, PO must capture screenshots or document why screenshots are impossible in this environment.
- If the IDE cannot execute a step, document the limitation and the alternative evidence used.

