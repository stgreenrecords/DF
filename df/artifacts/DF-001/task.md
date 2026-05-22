# Task - DF-001

## Summary

Initialize the Dark Factory documentation framework.

## Type

Task

## Priority

P2

## Current state

DONE

## Business goal

Create a reusable, MCP-agnostic Markdown framework that allows AI agents to run an autonomous SDLC with Dev, QA, SA, and PO roles.

## Acceptance criteria

- [x] Provide universal instructions for any AI agent.
- [x] Provide adapter instructions for Claude Code, GitHub Copilot, and JetBrains AI Assistant.
- [x] Define Dev, QA, SA, and PO role behavior.
- [x] Define autonomous start/continue behavior.
- [x] Define SDLC states and handoffs.
- [x] Define documentation and evidence standards.
- [x] Provide runtime board/log files and reusable templates.

## Out of scope

- Building an executable scheduler/orchestrator.
- Integrating with Jira/GitHub Issues.
- Creating application source code.

## Assumptions

- Markdown is the lowest-common-denominator format all agents can read.
- Runtime state can be tracked in repository files until an external tracker is integrated.

## Dependencies

None.

## Risks

- Future automation may require scripts or CI workflows.

## Links

- Main instructions: `AGENTS.md`
- Framework docs: `df/`

