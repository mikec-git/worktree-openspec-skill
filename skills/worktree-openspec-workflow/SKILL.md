---
name: worktree-openspec-workflow
description: Set up implementation worktrees consistently for Codex or Claude workers. Use when asked to create, prepare, or start a task branch/worktree, especially OpenSpec-backed work that needs a sibling worktree under /Users/mchoi/repos, an agent-prefixed task branch, and an OpenSpec change scaffold created inside the implementation worktree.
---

# Worktree OpenSpec Workflow

## Overview

Create task worktrees in the project-standard shape: scoped task brief, synced base, sibling worktree, agent-prefixed branch, OpenSpec change scaffold, and complete OpenSpec planning artifacts in the implementation worktree. Keep this workflow identical for Codex and Claude; only the branch prefix changes.

## Workflow

1. Discuss and capture task scope before creating anything.
   - Generate a 10-question discovery flow from the requested feature/spec, then ask those questions one at a time until the implementation scope is concrete enough to write a meaningful OpenSpec proposal.
   - Interactive keyboard-select prompts require Plan mode in clients where `request_user_input` is Plan-only. A skill cannot switch modes itself.
   - If a structured interactive input tool such as `request_user_input` is available, use it for one question at a time.
   - If the user explicitly wants keyboard-select prompts and `request_user_input` is unavailable because the session is not in Plan mode, explain that the session must be switched to Plan mode and stop before creating any files, branch, worktree, or OpenSpec change.
   - If no structured input tool is available, present exactly one numbered Yes/No/Chat prompt in chat, stop for the user's answer, then ask the next unanswered question on the following turn before creating any files, branch, worktree, or OpenSpec change.
   - Do not convert the discovery flow into open-ended checklist questions unless the user explicitly asks for a free-form flow.
   - Each generated discovery prompt must offer exactly three choices: `Yes`, `No`, and `Chat`.
   - Use `Chat` as the free-form escape hatch for any answer that does not fit the Yes/No mapping.
   - Generate questions from the feature/spec details, affected repo context, likely OpenSpec capability boundaries, expected surfaces, non-goals, and verification needs.
   - Avoid hardcoded generic question banks. Use `references/scope-brief.md` for the question-generation rubric, not as a fixed script.
   - Skip a generated question only when the user's prompt or existing project context already answers it clearly.
   - Ask follow-ups only when the answer changes ownership, capability boundaries, or acceptance criteria and cannot be captured by the generated prompt's Yes/No/Chat mapping.
   - If the user already provided enough detail, summarize the inferred scope and ask for confirmation only when an assumption is material.
   - Capture:
     - User problem and desired outcome.
     - In-scope behavior and workflows.
     - Explicit non-goals.
     - Affected interfaces, commands, routes, files, services, or integrations.
     - New or modified OpenSpec capability names when known.
     - Acceptance criteria and verification commands.
     - Agent owner, task slug, repo, worktree path, and OpenSpec change name.
   - Use the 10-question Yes/No/Chat generation rubric in `references/scope-brief.md`, asking only the next unanswered generated question unless the user asks for a shorter flow.
   - Chat fallback format:

     ```markdown
     Please choose one option:

     1. Should this task update the resume flow to restore the last selected conversation automatically?
        A. Yes - include automatic last-conversation restore in scope.
        B. No - keep resume selection manual.
        C. Chat - I will describe a different resume behavior.
     ```

     Ask only the next unanswered question needed for the scope, keep the choices short, and wait for the user's answer before asking another question.
   - Use `references/scope-brief.md` for the scope summary format.

2. Confirm the task slug and agent owner.
   - Use `codex/<task>` for Codex work.
   - Use `claude/<task>` for Claude work.
   - Default repo: `/Users/mchoi/repos/ccmux`.
   - Default worktree path: `/Users/mchoi/repos/ccmux-<task>`.
   - Default OpenSpec change name: `<task>`.

3. Inspect existing state before creating anything.
   - Run `git status --short --branch` in the base repo.
   - Run `git worktree list`.
   - Run `git branch --list <agent>/<task>`.
   - Preserve untracked or unrelated user changes. Do not clean, reset, or delete.

4. Use the bundled script for the mechanical setup.

   ```bash
   <skill-dir>/scripts/setup_ccmux_worktree.sh \
     --task <task> \
     --agent codex
   ```

   For Claude:

   ```bash
   <skill-dir>/scripts/setup_ccmux_worktree.sh \
     --task <task> \
     --agent claude
   ```

5. Complete the OpenSpec planning artifacts inside the new worktree.
   - The setup script runs `openspec init --tools <agent>` in the worktree before creating the change. This installs the selected agent's OpenSpec skills and commands according to the upstream OpenSpec tool adapter, then leaves existing `openspec/config.yaml` intact when present.
   - The setup script initializes `proposal.md` from `openspec instructions proposal --change <task> --json`.
   - Fill in `proposal.md` from the agreed task scope: why, behavior changes, capabilities, and impact.
   - Run `openspec status --change <task> --json`.
   - For each ready artifact shown by status, run `openspec instructions <artifact-id> --change <task> --json` before writing it.
   - Create only the artifact files requested by OpenSpec, in the dependency order reported by status and instructions.
   - For the `spec-driven` schema, do not stop after `proposal.md`; complete `design.md` when requested, `specs/<capability>/spec.md`, and `tasks.md`.
   - `tasks.md` is required before the apply phase can run. If `openspec instructions apply --change <task> --json` reports `state: "blocked"` because `tasks` is missing, continue artifact creation instead of handing off for implementation.
   - Re-run `openspec status --change <task> --json` after each artifact so the next artifact set comes from OpenSpec rather than assumptions.
   - Run `openspec validate <task> --type change --strict --no-interactive` after the artifacts are complete.
   - Run `openspec instructions apply --change <task> --json` and confirm the state is not `blocked` before presenting the worktree as ready for implementation.
   - See `references/openspec-artifacts.md` for the artifact sequence.

6. Handoff with:
   - Scope summary and explicit non-goals.
   - Worktree path.
   - Branch name.
   - Base commit.
   - OpenSpec change path.
   - OpenSpec artifacts created and current `openspec status --change <task>` result.
   - Current `openspec instructions apply --change <task> --json` state.
   - Verification commands run.
   - Any existing local changes that were intentionally left alone.

## Script Notes

The setup script is intentionally conservative:

- It fetches `origin`.
- It fast-forwards `main` only when the base checkout is currently on `main`.
- It refuses to overwrite an existing branch, worktree, or OpenSpec change.
- It creates the OpenSpec scaffold with `openspec new change <change>`.
- It initializes OpenSpec tool integration files first with `openspec init --tools <agent>`, so Codex worktrees get `.codex/skills/openspec-*/SKILL.md` and Claude worktrees get the corresponding `.claude/` integration files.
- It initializes `proposal.md` from the OpenSpec proposal template by default.
- It does not auto-create `design.md`, specs, or `tasks.md`; the active agent must create those after completing `proposal.md` and reading the next OpenSpec instructions.
- A worktree is mechanically created after the script runs, but it is not ready for implementation until OpenSpec apply instructions are unblocked.
- Use `--skip-openspec-artifacts` to create only the OpenSpec scaffold.

## Recovery

If the script stops because a path or branch already exists, inspect it instead of overwriting it:

```bash
git -C /Users/mchoi/repos/ccmux worktree list
git -C /Users/mchoi/repos/ccmux branch --list '<agent>/<task>'
```

Resume from the existing worktree only if it is clearly the same task. Otherwise choose a new slug and explain the collision.
