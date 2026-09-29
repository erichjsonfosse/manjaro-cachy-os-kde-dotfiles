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
mkdir -p "$AGENTS_SKILLS_DIR"

# Copy all skill directories from repository into ~/.agents/skills
if [ -d "$SOURCE_SKILLS_DIR" ]; then
  shopt -s nullglob
  for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
    if [ -d "$skill_dir" ]; then
      skill_name=$(basename "$skill_dir")
      logInfo "Syncing skill: $skill_name..."
      mkdir -p "$AGENTS_SKILLS_DIR/$skill_name"
      cp -rT "$skill_dir" "$AGENTS_SKILLS_DIR/$skill_name"
    fi
  done
  shopt -u nullglob
fi

# Ensure ~/.gemini/antigravity-cli parent directory exists
mkdir -p "$GEMINI_CLI_DIR"

# If ~/.gemini/antigravity-cli/skills is an existing non-symlink directory, migrate its contents
if [ -d "$GEMINI_SKILLS_LINK" ] && [ ! -L "$GEMINI_SKILLS_LINK" ]; then
  logInfo "Migrating existing skills directory to ~/.agents/skills..."
  cp -rn "$GEMINI_SKILLS_LINK/"* "$AGENTS_SKILLS_DIR/" 2>/dev/null || true
  rm -rf "$GEMINI_SKILLS_LINK"
fi

# Symlink ~/.agents/skills into ~/.gemini/antigravity-cli/skills
ln -sfn "$AGENTS_SKILLS_DIR" "$GEMINI_SKILLS_LINK"

logSuccess "AI agent skills directory linked successfully: $GEMINI_SKILLS_LINK -> $AGENTS_SKILLS_DIR"

# Configure AI Agent Plugins
SOURCE_PLUGINS_DIR="$SCRIPT_DIR/plugins"
GEMINI_CONFIG_PLUGINS_DIR="$HOMEDIR/.gemini/config/plugins"
AGENTS_PLUGINS_DIR="$HOMEDIR/.agents/plugins"

if [ -d "$SOURCE_PLUGINS_DIR" ]; then
  mkdir -p "$GEMINI_CONFIG_PLUGINS_DIR"
  mkdir -p "$AGENTS_PLUGINS_DIR"
  shopt -s nullglob
  for plugin_dir in "$SOURCE_PLUGINS_DIR"/*/; do
    if [ -d "$plugin_dir" ]; then
      plugin_name=$(basename "$plugin_dir")
      logInfo "Linking plugin: $plugin_name (dotfiles -> ~/.agents -> ~/.gemini)..."
      ln -sfn "$plugin_dir" "$AGENTS_PLUGINS_DIR/$plugin_name"
      ln -sfn "$AGENTS_PLUGINS_DIR/$plugin_name" "$GEMINI_CONFIG_PLUGINS_DIR/$plugin_name"
    fi
  done
  shopt -u nullglob
  logSuccess "AI agent plugins linked successfully: dotfiles -> $AGENTS_PLUGINS_DIR -> $GEMINI_CONFIG_PLUGINS_DIR"
fi
