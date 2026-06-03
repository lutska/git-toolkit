#!/usr/bin/env bash

set -e

REPO_URL="https://raw.githubusercontent.com/lutska/git-toolkit/main"

echo "Installing Gitleaks Pre-Commit Hook..."

HOOK_FILE="$(git rev-parse --git-dir)/hooks/pre-commit"

mkdir -p "$(dirname "$HOOK_FILE")"

if [ -f "$HOOK_FILE" ]; then
  cp "$HOOK_FILE" "${HOOK_FILE}.bak.$(date +%s)"
  echo "[install] Existing pre-commit hook backed up."
fi

curl -sSfL "$HOOK_URL" -o "$HOOK_FILE"
chmod +x "$HOOK_FILE"

git config hooks.gitleaks true

echo ""
echo "Installation completed."
echo "Hook enabled: $(git config --get hooks.gitleaks)"