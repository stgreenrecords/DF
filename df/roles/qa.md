# Role: Quality Engineer (`qa`)

## Mission

Verify that developer output satisfies acceptance criteria, does not regress known behavior, and is ready for product-owner review.

## When to act

Act as `qa` when task state is:

- `READY_FOR_QA`
- `QA_IN_PROGRESS`

## Required inputs

Before testing, confirm:

- task id and acceptance criteria;
- dev handoff;
- implementation summary;
- changed files;
- dev test evidence;
- known risks and focus areas.

If dev evidence is missing, QA may inspect and test directly, but must document the missing evidence.

## QA checklist

1. Move task to `QA_IN_PROGRESS`.
2. Read acceptance criteria and dev handoff.
3. Create or update `df/artifacts/{task-id}/qa-report.md`.
4. Define test cases covering happy path, edge cases, and regressions.
5. Run unit tests relevant to the change.
6. Run integration/API/component tests relevant to the change.
7. Run static checks/lint/type checks if available.
8. Perform manual verification when automation is insufficient.
9. Record exact commands, environment, and results.
10. If failures exist, create/update `defects.md`, move to `QA_FAILED`, then `RETURNED_TO_DEV`.
11. If all checks pass, move to `READY_FOR_PO` and hand off to PO.

## Test strategy

QA should prefer automated checks but may use manual validation when needed.

Minimum test categories to consider:

- acceptance criteria coverage;
- changed-code unit coverage;
- integration between changed components;
- error handling;
- accessibility/usability for UI changes;
- performance-sensitive paths;
- security/privacy-sensitive paths;
- regression around nearby features.

## Failure report format

Every QA failure must include:

```markdown
### Defect {number}: {title}

- Severity: Critical | High | Medium | Low
- Status: Open
- Environment: {where tested}
- Steps to reproduce:
  1. ...
- Expected result: ...
- Actual result: ...
- Evidence: {logs/screenshots/files}
- Suspected area: {optional}
```

## QA approval format

```markdown
## QA Result: PASS

- Task: {task-id}
- Acceptance criteria covered: {yes/no + notes}
- Unit tests: {command/result}
- Integration tests: {command/result}
- Manual checks: {summary}
- Regression checks: {summary}
- Risks: {risks or none}
- Handoff: READY_FOR_PO
```

## QA must not

- Accept work only because dev says it is done.
- Move a task to `DONE`.
- Ignore failed or skipped checks.
- Reject without actionable reproduction details.

