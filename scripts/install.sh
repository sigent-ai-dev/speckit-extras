#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."
EXTENSION_DIR="$REPO_ROOT/extension"
TEMPLATES_DIR="$REPO_ROOT/templates/commands"

usage() {
  cat <<EOF
Usage: install.sh [OPTIONS]

Install Spec Kit Extras as a Spec Kit extension or standalone commands.

Modes:
  --extension       Install as Spec Kit extension into .specify/extensions/extras/ (default)
  --standalone      Install commands directly into agent commands directory

Options:
  --agent <agent>   Target agent (standalone mode). See list below. (default: claude)
  --target <dir>    Override install directory
  --list            List available commands
  --dry-run         Show what would be installed without copying
  -h, --help        Show this help

Supported agents:
  claude          .claude/commands/
  gemini          .gemini/commands/          (TOML format)
  copilot         .github/agents/
  cursor-agent    .cursor/commands/
  qwen            .qwen/commands/            (TOML format)
  opencode        .opencode/command/
  codex           .codex/commands/
  windsurf        .windsurf/workflows/
  kilocode        .kilocode/rules/
  auggie          .augment/rules/
  roo             .roo/rules/
  codebuddy       .codebuddy/commands/
  q               .amazonq/prompts/
  amp             .agents/commands/
  shai            .shai/commands/
EOF
  exit 0
}

MODE="extension"
AGENT="claude"
TARGET=""
DRY_RUN=false
LIST=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --extension) MODE="extension"; shift ;;
    --standalone) MODE="standalone"; shift ;;
    --agent) AGENT="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --list) LIST=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

COMMANDS=("selfreview" "pr" "dora" "decompose")

if [[ "$LIST" == true ]]; then
  echo "Available commands:"
  for cmd in "${COMMANDS[@]}"; do
    desc=$(sed -n '2s/^description: //p' "$TEMPLATES_DIR/$cmd.md")
    echo "  speckit.$cmd — $desc"
  done
  exit 0
fi

get_target_dir() {
  case "$1" in
    claude)       echo ".claude/commands" ;;
    gemini)       echo ".gemini/commands" ;;
    copilot)      echo ".github/agents" ;;
    cursor-agent) echo ".cursor/commands" ;;
    qwen)         echo ".qwen/commands" ;;
    opencode)     echo ".opencode/command" ;;
    codex)        echo ".codex/commands" ;;
    windsurf)     echo ".windsurf/workflows" ;;
    kilocode)     echo ".kilocode/rules" ;;
    auggie)       echo ".augment/rules" ;;
    roo)          echo ".roo/rules" ;;
    codebuddy)    echo ".codebuddy/commands" ;;
    q)            echo ".amazonq/prompts" ;;
    amp)          echo ".agents/commands" ;;
    shai)         echo ".shai/commands" ;;
    *) echo "Unknown agent: $1" >&2; exit 1 ;;
  esac
}

get_format() {
  case "$1" in
    gemini|qwen) echo "toml" ;;
    *)           echo "markdown" ;;
  esac
}

get_prefix() {
  case "$1" in
    claude|gemini|cursor-agent|qwen|opencode|codex|codebuddy|amp|shai) echo "speckit." ;;
    copilot|windsurf|kilocode|auggie|roo|q) echo "speckit-" ;;
  esac
}

get_extension() {
  case "$1" in
    gemini|qwen) echo ".toml" ;;
    *)           echo ".md" ;;
  esac
}

convert_to_toml() {
  local src="$1"
  local desc
  desc=$(sed -n 's/^description: //p' "$src" | head -1)

  local body
  # shellcheck disable=SC2016
  body=$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$src" | sed 's/\$ARGUMENTS/{{args}}/g')

  cat <<TOML
description = "$desc"

prompt = """
$body
"""
TOML
}

install_extension() {
  local dest="${TARGET:-.specify/extensions/extras}"

  echo "Installing Spec Kit Extras as extension"
  echo "Target: $dest"
  echo ""

  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$dest/commands"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  WOULD COPY extension.yml → $dest/extension.yml"
  else
    cp "$EXTENSION_DIR/extension.yml" "$dest/extension.yml"
    echo "  INSTALLED $dest/extension.yml"
  fi

  local installed=0
  for cmd in "${COMMANDS[@]}"; do
    local src="$EXTENSION_DIR/commands/speckit.$cmd.md"
    local dest_file="$dest/commands/speckit.$cmd.md"

    if [[ ! -f "$src" ]]; then
      echo "  SKIP speckit.$cmd (source not found)"
      continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
      echo "  WOULD COPY $src → $dest_file"
    else
      cp "$src" "$dest_file"
      echo "  INSTALLED $dest_file"
    fi
    ((installed++))
  done

  echo ""
  echo "Done. Extension installed ($installed commands)."
  echo ""
  echo "Next steps:"
  echo "  1. The specify CLI will register commands for your agent on next run"
  echo "  2. Or manually copy commands to your agent directory with:"
  echo "     $0 --standalone --agent <your-agent>"
}

install_standalone() {
  if [[ -z "$TARGET" ]]; then
    TARGET=$(get_target_dir "$AGENT")
  fi

  local format
  format=$(get_format "$AGENT")
  local prefix
  prefix=$(get_prefix "$AGENT")
  local ext
  ext=$(get_extension "$AGENT")

  echo "Installing Spec Kit Extras (standalone) for: $AGENT"
  echo "Target directory: $TARGET"
  echo "Format: $format"
  echo ""

  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$TARGET"
  fi

  local installed=0
  for cmd in "${COMMANDS[@]}"; do
    local src="$TEMPLATES_DIR/$cmd.md"
    local dest="$TARGET/${prefix}${cmd}${ext}"

    if [[ ! -f "$src" ]]; then
      echo "  SKIP $cmd (source not found: $src)"
      continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
      echo "  WOULD INSTALL $dest ($format)"
    else
      if [[ "$format" == "toml" ]]; then
        convert_to_toml "$src" > "$dest"
      else
        cp "$src" "$dest"
      fi
      echo "  INSTALLED $dest"
    fi
    ((installed++))
  done

  echo ""
  echo "Done. $installed command(s) installed for $AGENT."

  if [[ "$format" == "toml" ]]; then
    echo ""
    echo "NOTE: Commands converted to TOML format for $AGENT."
    echo "Argument placeholder changed from \$ARGUMENTS to {{args}}."
  elif [[ "$AGENT" != "claude" ]]; then
    echo ""
    echo "NOTE: Templates are authored in Claude Code format."
    echo "Some frontmatter fields (handoffs) may not apply to $AGENT."
  fi
}

if [[ "$MODE" == "extension" ]]; then
  install_extension
else
  install_standalone
fi
