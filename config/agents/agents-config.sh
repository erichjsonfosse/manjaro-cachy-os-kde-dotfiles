#!/usr/bin/env bash

# This script sets up the AI agent directory structure and links skills for agentic tools.

# Fallback definitions for standalone execution
if [ -z "$HOMEDIR" ]; then
  HOMEDIR="$HOME"
fi

if [ -z "$LOGNAME" ]; then
  LOGNAME="$USER"
fi

if ! command -v logHeader &>/dev/null; then
  logHeader() { echo "=== $1 ==="; }
  logInfo() { echo "  [i] $1"; }
  logSuccess() { echo "  [✔] $1"; }
  logWarning() { echo "  [!] $1"; }
fi

logHeader "Configuring AI Agent Skills & Environment"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/skills"
AGENTS_SKILLS_DIR="$HOMEDIR/.agents/skills"
GEMINI_CLI_DIR="$HOMEDIR/.gemini/antigravity-cli"
GEMINI_SKILLS_LINK="$GEMINI_CLI_DIR/skills"

# Ensure ~/.agents/skills directory exists
su "$LOGNAME" -c "mkdir -p \"$AGENTS_SKILLS_DIR\""

# Copy all skill directories from repository into ~/.agents/skills
if [ -d "$SOURCE_SKILLS_DIR" ]; then
  shopt -s nullglob
  for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      logInfo "Syncing skill: $skill_name..."
      su "$LOGNAME" -c "mkdir -p \"$AGENTS_SKILLS_DIR/$skill_name\""
      su "$LOGNAME" -c "cp -rT \"$skill_dir\" \"$AGENTS_SKILLS_DIR/$skill_name\""
    fi
  done
  shopt -u nullglob
fi

# Ensure ~/.gemini/antigravity-cli parent directory exists
su "$LOGNAME" -c "mkdir -p \"$GEMINI_CLI_DIR\""

# If ~/.gemini/antigravity-cli/skills is an existing non-symlink directory, migrate its contents
if [ -d "$GEMINI_SKILLS_LINK" ] && [ ! -L "$GEMINI_SKILLS_LINK" ]; then
  logInfo "Migrating existing skills directory to ~/.agents/skills..."
  su "$LOGNAME" -c "cp -rn \"$GEMINI_SKILLS_LINK/\"* \"$AGENTS_SKILLS_DIR/\" 2>/dev/null || true"
  su "$LOGNAME" -c "rm -rf \"$GEMINI_SKILLS_LINK\""
fi

# Symlink ~/.agents/skills into ~/.gemini/antigravity-cli/skills
su "$LOGNAME" -c "ln -sfn \"$AGENTS_SKILLS_DIR\" \"$GEMINI_SKILLS_LINK\""

# Ensure correct user ownership
chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.agents" 2>/dev/null || true
chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.gemini" 2>/dev/null || true

logSuccess "AI agent skills directory linked successfully: $GEMINI_SKILLS_LINK -> $AGENTS_SKILLS_DIR"
