#!/usr/bin/env bash
set -euo pipefail

repo="/Users/mchoi/repos/ccmux"
worktrees_root="/Users/mchoi/repos"
agent="codex"
task=""
change=""
skip_openspec=0
skip_openspec_artifacts=0

usage() {
  cat <<'USAGE'
Usage:
  setup_ccmux_worktree.sh --task <slug> [--agent codex|claude] [--repo <path>] [--worktrees-root <path>] [--change <name>] [--skip-openspec] [--skip-openspec-artifacts]

Creates:
  <worktrees-root>/ccmux-<slug>
  <agent>/<slug>
  OpenSpec tool integration files for <agent>
  openspec/changes/<change> inside the new worktree unless --skip-openspec is set
  openspec/changes/<change>/proposal.md from the OpenSpec template unless --skip-openspec-artifacts is set
USAGE
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      task="${2:-}"
      shift 2
      ;;
    --agent)
      agent="${2:-}"
      shift 2
      ;;
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --worktrees-root)
      worktrees_root="${2:-}"
      shift 2
      ;;
    --change)
      change="${2:-}"
      shift 2
      ;;
    --skip-openspec)
      skip_openspec=1
      shift
      ;;
    --skip-openspec-artifacts)
      skip_openspec_artifacts=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[[ -n "$task" ]] || die "--task is required"
[[ "$task" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "--task must be kebab-case"
[[ "$agent" == "codex" || "$agent" == "claude" ]] || die "--agent must be codex or claude"

change="${change:-$task}"
[[ "$change" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "--change must be kebab-case"

command -v git >/dev/null 2>&1 || die "git is required"

repo="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null)" || die "not a git repo: $repo"
worktree_path="${worktrees_root%/}/ccmux-${task}"
branch="${agent}/${task}"

[[ ! -e "$worktree_path" ]] || die "worktree path already exists: $worktree_path"
[[ -z "$(git -C "$repo" branch --list "$branch")" ]] || die "branch already exists: $branch"

printf 'Base repo: %s\n' "$repo"
printf 'Task: %s\n' "$task"
printf 'Agent: %s\n' "$agent"

git -C "$repo" fetch origin

current_branch="$(git -C "$repo" branch --show-current)"
base_ref="main"
if [[ "$current_branch" == "main" ]]; then
  tracked_dirty="$(git -C "$repo" status --short --untracked-files=no)"
  [[ -z "$tracked_dirty" ]] || die "main has tracked local changes; refuse to pull"
  git -C "$repo" pull --ff-only origin main
else
  base_ref="origin/main"
  printf 'Base checkout is on %s; using origin/main as worktree base.\n' "$current_branch"
fi

git -C "$repo" worktree add -b "$branch" "$worktree_path" "$base_ref"

if [[ "$skip_openspec" -eq 0 ]]; then
  command -v openspec >/dev/null 2>&1 || die "openspec is required; rerun with --skip-openspec to omit scaffold"
  if [[ "$skip_openspec_artifacts" -eq 0 ]]; then
    command -v jq >/dev/null 2>&1 || die "jq is required to initialize OpenSpec artifacts; rerun with --skip-openspec-artifacts to omit artifacts"
  fi
  [[ ! -e "$worktree_path/openspec/changes/$change" ]] || die "OpenSpec change already exists: $change"
  (cd "$worktree_path" && openspec init --tools "$agent")
  (cd "$worktree_path" && openspec new change "$change")

  if [[ "$skip_openspec_artifacts" -eq 0 ]]; then
    proposal_json="$(cd "$worktree_path" && openspec instructions proposal --change "$change" --json)"
    proposal_output_path="$(jq -r '.outputPath' <<<"$proposal_json")"
    proposal_template="$(jq -r '.template' <<<"$proposal_json")"
    [[ "$proposal_output_path" == "proposal.md" ]] || die "unexpected proposal output path: $proposal_output_path"
    [[ -n "$proposal_template" && "$proposal_template" != "null" ]] || die "OpenSpec proposal template was empty"
    proposal_path="$worktree_path/openspec/changes/$change/$proposal_output_path"
    [[ ! -e "$proposal_path" ]] || die "OpenSpec proposal already exists: $proposal_path"
    printf '%s\n' "$proposal_template" >"$proposal_path"
  fi
fi

base_commit="$(git -C "$worktree_path" rev-parse --short HEAD)"

printf '\nCreated ccmux worktree setup:\n'
printf '  Worktree: %s\n' "$worktree_path"
printf '  Branch:   %s\n' "$branch"
printf '  Base:     %s\n' "$base_commit"
if [[ "$skip_openspec" -eq 0 ]]; then
  printf '  OpenSpec: %s\n' "$worktree_path/openspec/changes/$change"
  printf '  Tool:     %s\n' "$agent"
  if [[ "$skip_openspec_artifacts" -eq 0 ]]; then
    printf '  Proposal: %s\n' "$worktree_path/openspec/changes/$change/proposal.md"
  fi
fi
