# OpenSpec Artifact Sequence

Use this reference after the worktree and change scaffold exist.

## Commands

```bash
openspec status --change "<change>" --json
openspec instructions proposal --change "<change>" --json
openspec instructions design --change "<change>" --json
openspec instructions specs --change "<change>" --json
openspec instructions tasks --change "<change>" --json
openspec validate "<change>" --type change --strict --no-interactive
openspec instructions apply --change "<change>" --json
openspec status --change "<change>"
```

## Rules

- Create artifacts inside the implementation worktree, not the parent checkout.
- Read each `openspec status --change "<change>" --json` response to determine which artifacts are ready, blocked, or done.
- Read each `openspec instructions ... --json` response before writing that artifact.
- Do not paste instruction `context` or `rules` blocks into artifact files.
- Keep proposal focused on why and user-visible behavior.
- Keep design focused on implementation approach and tradeoffs when OpenSpec requests it.
- Create spec files only for capabilities listed in the proposal.
- Keep tasks concrete, ordered, and verifiable.
- Create `tasks.md` before implementation handoff. OpenSpec apply is blocked until the task artifact exists and uses `- [ ]` checkbox items.
- Confirm `openspec instructions apply --change "<change>" --json` does not return `state: "blocked"` before telling an implementation worker to apply the change.
- Stop and report if requirements are too vague to write meaningful scenarios.

## Handoff

Report:

- Change name and path.
- Artifacts created.
- Current `openspec status --change <change>` result.
- Current `openspec instructions apply --change <change> --json` state.
- Branch/worktree details.
