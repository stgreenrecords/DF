# GitHub Copilot Instructions for Dark Factory

Follow the universal Dark Factory instructions in `AGENTS.md` and the detailed workflow in `df/`.

## Required behavior

- Treat `df/00-start-here.md` as the boot sequence.
- Use role files in `df/roles/` for behavior and deliverables.
- Update runtime evidence in `df/runtime/` and task artifacts in `df/artifacts/{task-id}/`.
- Do not finish a task unless `qa` has passed it and `po` has accepted it.
- If work is rejected, return it to `dev` with evidence and defects.

## Pull request behavior

When creating or reviewing pull requests:

- Link the PR to the task id.
- Include implementation summary, test evidence, risks, and rollback notes.
- Do not merge if tests fail, requirements are unclear, or PO acceptance is missing unless a human explicitly overrides.

