# Dark Factory Decisions

## DF-DEC-001 - Documentation-first, MCP-agnostic framework

- Date: 2026-05-22
- Status: Accepted
- Owner role: SA
- Related task: DF-001

### Context

The framework must work with Claude Code, GitHub Copilot, JetBrains AI Assistant, and future agents regardless of MCP implementation.

### Decision

Use Markdown files as the portable source of truth. Provide adapter files for common AI tools that all redirect to `AGENTS.md` and `df/`.

### Consequences

- Any AI tool can participate by reading Markdown.
- Runtime state remains inspectable by humans.
- External issue trackers and CI systems can be integrated later without changing core role rules.

### Alternatives considered

- Tool-specific prompts only: rejected because it creates lock-in.
- External orchestrator first: deferred because documentation standards are needed before automation.

