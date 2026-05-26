#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."

usage() {
  cat <<EOF
Usage: install.sh [OPTIONS]

Install Spec Kit Extras as a Spec Kit extension or standalone commands.

Modes:
  --extension       Install as Spec Kit extension (default)
  --standalone      Install commands directly into agent commands directory

Options:
  --pack <name>     Extension pack to install: extras (default), bolt, all
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
PACK="extras"
AGENT="claude"
TARGET=""
DRY_RUN=false
LIST=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --extension) MODE="extension"; shift ;;
    --standalone) MODE="standalone"; shift ;;
    --pack) PACK="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --list) LIST=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

get_pack_dir() {
  case "$1" in
    extras) echo "$REPO_ROOT/extension" ;;
    bolt)   echo "$REPO_ROOT/extension-bolt" ;;
    *) echo "Unknown pack: $1. Available: extras, bolt, all" >&2; exit 1 ;;
  esac
}

get_pack_commands() {
  case "$1" in
    extras) echo "selfreview pr dora decompose" ;;
    bolt)   echo "bolt archive retrospective roadmap" ;;
    *) echo "Unknown pack: $1" >&2; exit 1 ;;
  esac
}

get_templates_dir() {
  case "$1" in
    extras) echo "$REPO_ROOT/templates/commands" ;;
    bolt)   echo "$REPO_ROOT/extension-bolt/commands" ;;
    *) echo "Unknown pack: $1" >&2; exit 1 ;;
  esac
}

if [[ "$LIST" == true ]]; then
  for pack in extras bolt; do
    echo "[$pack]"
    pack_dir=$(get_pack_dir "$pack")
    for f in "$pack_dir"/commands/speckit.*.md; do
      name=$(basename "$f" .md | sed 's/^speckit\.//')
      desc=$(sed -n 's/^description: *"\{0,1\}//p' "$f" | sed 's/"\{0,1\}$//' | head -1)
      echo "  speckit.$name — $desc"
    done
    echo ""
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

install_single_extension() {
  local pack="$1"
  local pack_dir
  pack_dir=$(get_pack_dir "$pack")
  local dest="${TARGET:-.specify/extensions/$pack}"

  echo "Installing extension: $pack"
  echo "Target: $dest"
  echo ""

  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$dest/commands"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  WOULD COPY extension.yml → $dest/extension.yml"
  else
    cp "$pack_dir/extension.yml" "$dest/extension.yml"
    echo "  INSTALLED $dest/extension.yml"
  fi

  local installed=0
  for f in "$pack_dir"/commands/speckit.*.md; do
    local name
    name=$(basename "$f")
    local dest_file="$dest/commands/$name"

    if [[ "$DRY_RUN" == true ]]; then
      echo "  WOULD COPY $f → $dest_file"
    else
      cp "$f" "$dest_file"
      echo "  INSTALLED $dest_file"
    fi
    installed=$((installed + 1))
  done

  if [[ -d "$pack_dir/scripts" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  WOULD COPY scripts/ → $dest/scripts/"
    else
      cp -r "$pack_dir/scripts" "$dest/scripts"
      chmod +x "$dest"/scripts/bash/*.sh 2>/dev/null || true
      echo "  INSTALLED $dest/scripts/"
    fi
  fi

  echo ""
  echo "Done. $pack extension installed ($installed commands)."
}

install_extension() {
  if [[ "$PACK" == "all" ]]; then
    install_single_extension "extras"
    echo ""
    TARGET="" install_single_extension "bolt"
  else
    install_single_extension "$PACK"
  fi

  echo ""
  echo "Next steps:"
  echo "  1. The specify CLI will register commands for your agent on next run"
  echo "  2. Or manually copy commands to your agent directory with:"
  echo "     $0 --standalone --agent <your-agent> --pack <pack>"
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

  local packs
  if [[ "$PACK" == "all" ]]; then
    packs="extras bolt"
  else
    packs="$PACK"
  fi

  echo "Installing Spec Kit ($packs) standalone for: $AGENT"
  echo "Target directory: $TARGET"
  echo "Format: $format"
  echo ""

  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$TARGET"
  fi

  local installed=0
  for pack in $packs; do
    local pack_dir
    pack_dir=$(get_pack_dir "$pack")

    for src in "$pack_dir"/commands/speckit.*.md; do
      local cmd_name
      cmd_name=$(basename "$src" .md | sed 's/^speckit\.//')
      local dest="$TARGET/${prefix}${cmd_name}${ext}"

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
      installed=$((installed + 1))
    done
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
