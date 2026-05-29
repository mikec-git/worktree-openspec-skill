#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$repo_dir/skills/worktree-openspec-workflow"

codex_skills_dir="${CODEX_SKILLS_DIR:-${CODEX_HOME:-$HOME/.codex}/skills}"
claude_skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

link_skill() {
  local skills_dir="$1"
  local dest="$skills_dir/worktree-openspec-workflow"

  mkdir -p "$skills_dir"

  if [[ -L "$dest" ]]; then
    unlink "$dest"
  elif [[ -e "$dest" ]]; then
    echo "Refusing to replace non-symlink path: $dest" >&2
    exit 1
  fi

  ln -s "$skill_dir" "$dest"
  echo "Linked $dest -> $skill_dir"
}

link_skill "$codex_skills_dir"
link_skill "$claude_skills_dir"

echo "Installed Worktree OpenSpec Workflow for Codex and Claude."
