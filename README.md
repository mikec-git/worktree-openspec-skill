# Worktree OpenSpec Skill

A Codex skill for starting OpenSpec-backed implementation worktrees in a consistent shape.

The skill guides an agent through scope capture, creates a sibling git worktree, initializes OpenSpec for Codex or Claude, scaffolds a change, and requires the OpenSpec planning artifacts to be completed before implementation starts.

## What It Does

- Captures concrete task scope before any branch or file is created.
- Creates an agent-owned task branch such as `codex/my-task` or `claude/my-task`.
- Creates a sibling worktree for the task.
- Runs `openspec init --tools <agent>` inside that worktree.
- Creates an OpenSpec change and initializes `proposal.md` from the current OpenSpec template.
- Guides the agent through `design.md`, specs, `tasks.md`, validation, and apply-readiness checks.
- Produces a handoff with scope, branch, worktree, OpenSpec status, and verification details.

The included setup script currently defaults to the author's ccmux layout:

- Base repo: `/Users/mchoi/repos/ccmux`
- Worktree root: `/Users/mchoi/repos`
- Worktree name: `ccmux-<task>`

Those defaults can be overridden with `--repo` and `--worktrees-root`.

## Dependencies

Required for normal use:

- `git`
- `openspec`
- `jq`
- Codex with skill loading from `$CODEX_HOME/skills` or `~/.codex/skills`

Optional:

- `gh`, only if you want to publish or manage this repository through GitHub CLI.

The setup script fetches from `origin`, so the base repository should have an `origin` remote configured.

## Installation

Clone the repository somewhere durable:

```bash
git clone https://github.com/mikec-git/worktree-openspec-skill.git
```

Then symlink the skill directory into Codex:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
ln -sfn "$PWD/worktree-openspec-skill/skills/worktree-openspec-workflow" \
  "${CODEX_HOME:-$HOME/.codex}/skills/worktree-openspec-workflow"
```

After restarting or refreshing Codex, the skill should appear as `worktree-openspec-workflow`.

## Usage

In Codex, ask for the skill by name:

```text
Use $worktree-openspec-workflow to set up a Codex worktree for <task>.
```

The skill will first clarify scope. Once scope is concrete, it uses the bundled script for the mechanical setup:

```bash
skills/worktree-openspec-workflow/scripts/setup_ccmux_worktree.sh \
  --task my-task \
  --agent codex
```

For Claude-owned work:

```bash
skills/worktree-openspec-workflow/scripts/setup_ccmux_worktree.sh \
  --task my-task \
  --agent claude
```

To target a different project:

```bash
skills/worktree-openspec-workflow/scripts/setup_ccmux_worktree.sh \
  --task my-task \
  --agent codex \
  --repo /path/to/project \
  --worktrees-root /path/to/worktrees
```

## Script Options

```text
--task <slug>                  Required kebab-case task slug.
--agent codex|claude           Agent owner. Defaults to codex.
--repo <path>                  Base git repository. Defaults to /Users/mchoi/repos/ccmux.
--worktrees-root <path>        Parent directory for new worktrees. Defaults to /Users/mchoi/repos.
--change <name>                OpenSpec change name. Defaults to the task slug.
--skip-openspec                Create only the worktree and branch.
--skip-openspec-artifacts      Create the OpenSpec change without initializing proposal.md.
```

## Safety Behavior

The setup script is intentionally conservative:

- Refuses to overwrite an existing worktree path.
- Refuses to reuse an existing branch.
- Fetches `origin` before creating the worktree.
- Fast-forwards `main` only when the base checkout is on `main` and has no tracked local changes.
- Uses `origin/main` as the base when the current checkout is not on `main`.
- Refuses to continue when OpenSpec or `jq` is missing for artifact initialization.

## Repository Layout

```text
skills/worktree-openspec-workflow/
  SKILL.md                         Main Codex skill instructions.
  agents/openai.yaml               Skill metadata for OpenAI/Codex surfaces.
  references/openspec-artifacts.md OpenSpec artifact sequence reference.
  references/scope-brief.md        Scope capture and discovery prompt rubric.
  scripts/setup_ccmux_worktree.sh  Worktree and OpenSpec scaffold script.
```

## Current Limitations

- The bundled script name and default worktree naming are ccmux-specific.
- The workflow currently supports `codex` and `claude` agent owners.
- The script initializes only `proposal.md`; the active agent must complete the remaining OpenSpec artifacts from OpenSpec instructions before implementation starts.
