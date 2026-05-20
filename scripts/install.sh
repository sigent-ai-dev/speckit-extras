#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates/commands"

usage() {
  cat <<EOF
Usage: install.sh [--agent <agent>] [--target <dir>]

Install Spec Kit Extras commands into a project.

Options:
  --agent <agent>   Target agent: claude, gemini, copilot, cursor, amazonq, windsurf (default: claude)
  --target <dir>    Override the install directory (default: agent-specific)
  --list            List available commands
  --dry-run         Show what would be installed without copying
  -h, --help        Show this help

Agent target directories:
  claude    .claude/commands/
  gemini    .gemini/commands/
  copilot   .github/agents/
  cursor    .cursor/commands/
  amazonq   .amazonq/prompts/
  windsurf  .windsurf/workflows/
EOF
  exit 0
}

AGENT="claude"
TARGET=""
DRY_RUN=false
LIST=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --list) LIST=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

get_target_dir() {
  case "$1" in
    claude)   echo ".claude/commands" ;;
    gemini)   echo ".gemini/commands" ;;
    copilot)  echo ".github/agents" ;;
    cursor)   echo ".cursor/commands" ;;
    amazonq)  echo ".amazonq/prompts" ;;
    windsurf) echo ".windsurf/workflows" ;;
    *) echo "Unknown agent: $1" >&2; exit 1 ;;
  esac
}

get_prefix() {
  case "$1" in
    claude|gemini|cursor) echo "speckit." ;;
    copilot)              echo "speckit-" ;;
    amazonq|windsurf)     echo "speckit-" ;;
  esac
}

get_extension() {
  case "$1" in
    claude|gemini|copilot|cursor|amazonq) echo ".md" ;;
    windsurf) echo ".md" ;;
  esac
}

COMMANDS=("selfreview" "pr" "dora" "decompose")

if [[ "$LIST" == true ]]; then
  echo "Available commands:"
  for cmd in "${COMMANDS[@]}"; do
    desc=$(head -2 "$TEMPLATES_DIR/$cmd.md" | grep -A1 "^---" | tail -1 | sed 's/description: //')
    echo "  speckit.$cmd — $desc"
  done
  exit 0
fi

if [[ -z "$TARGET" ]]; then
  TARGET=$(get_target_dir "$AGENT")
fi

PREFIX=$(get_prefix "$AGENT")
EXT=$(get_extension "$AGENT")

echo "Installing Spec Kit Extras for: $AGENT"
echo "Target directory: $TARGET"
echo ""

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$TARGET"
fi

installed=0
for cmd in "${COMMANDS[@]}"; do
  src="$TEMPLATES_DIR/$cmd$EXT"
  dest="$TARGET/${PREFIX}${cmd}${EXT}"

  if [[ ! -f "$src" ]]; then
    echo "  SKIP $cmd (source not found: $src)"
    continue
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  WOULD COPY $src → $dest"
  else
    cp "$src" "$dest"
    echo "  INSTALLED $dest"
  fi
  ((installed++))
done

echo ""
echo "Done. $installed command(s) installed for $AGENT."

if [[ "$AGENT" != "claude" && "$DRY_RUN" == false ]]; then
  echo ""
  echo "NOTE: Templates are authored in Claude Code format."
  echo "Some frontmatter fields (handoffs, \$ARGUMENTS) may need"
  echo "adaptation for $AGENT. See README for details."
fi
