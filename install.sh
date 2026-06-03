#!/usr/bin/env bash

set -e

REPO_URL="https://raw.githubusercontent.com/lutska/git-toolkit/main"
HOOK_URL="${REPO_URL}/hooks/pre-commit"
GITLEAKS_INSTALL_URL="${REPO_URL}/scripts/install-gitleaks.sh"
GITLEAKS_CONFIG_URL="${REPO_URL}/.gitleaks.toml"

echo "Installing Gitleaks Pre-Commit Hook..."

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "[install] ERROR: Not inside a Git repository."
  exit 1
fi

# Install Gitleaks
curl -sSfL "$GITLEAKS_INSTALL_URL" | bash


# Install pre-commit hook
HOOK_FILE="$(git rev-parse --git-dir)/hooks/pre-commit"

mkdir -p "$(dirname "$HOOK_FILE")"

if [ -f "$HOOK_FILE" ]; then
  cp "$HOOK_FILE" "${HOOK_FILE}.bak.$(date +%s)"
  echo "[install] Existing pre-commit hook backed up."
fi

curl -sSfL "$HOOK_URL" -o "$HOOK_FILE"
chmod +x "$HOOK_FILE"
echo "[install] Hook installed at: $HOOK_FILE"

# Install .gitleaks.toml
REPO_ROOT="$(git rev-parse --show-toplevel)"
CONFIG_FILE="${REPO_ROOT}/.gitleaks.toml"

if [ -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%s)"
  echo "[install] Existing .gitleaks.toml backed up."
fi

curl -sSfL "$GITLEAKS_CONFIG_URL" -o "$CONFIG_FILE"

echo "[install] Gitleaks configuration installed at: $CONFIG_FILE"


# Enable hook
git config hooks.gitleaks true

echo ""
echo "Installation completed."
echo "Hook enabled: $(git config --get hooks.gitleaks)"