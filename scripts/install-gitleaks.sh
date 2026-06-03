#!/usr/bin/env bash
set -e

INSTALL_DIR="${HOME}/.local/bin"

if command -v gitleaks >/dev/null 2>&1; then
  echo "[gitleaks] Already installed: $(gitleaks version)"
  exit 0
fi

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64|amd64)  ARCH="x64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *)
    echo "[gitleaks] ERROR: Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

LATEST_VERSION="$(curl -sSfL https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
  | grep '"tag_name"' \
  | sed -E 's/.*"([^"]+)".*/\1/')"

if [ -z "$LATEST_VERSION" ]; then
  echo "[gitleaks] ERROR: Could not detect latest Gitleaks version."
  exit 1
fi

echo "[gitleaks] Latest version: $LATEST_VERSION"

mkdir -p "$INSTALL_DIR"

case "$OS" in
  Linux*)
    FILE="gitleaks_${LATEST_VERSION#v}_linux_${ARCH}.tar.gz"
    ;;

  Darwin*)
    FILE="gitleaks_${LATEST_VERSION#v}_darwin_${ARCH}.tar.gz"
    ;;

  MINGW*|MSYS*|CYGWIN*)
    FILE="gitleaks_${LATEST_VERSION#v}_windows_${ARCH}.zip"
    ;;

  *)
    echo "[gitleaks] ERROR: Unsupported OS: $OS"
    exit 1
    ;;
esac

URL="https://github.com/gitleaks/gitleaks/releases/download/${LATEST_VERSION}/${FILE}"

echo "[gitleaks] Downloading: $URL"

TMP_DIR="$(mktemp -d)"
cd "$TMP_DIR"

if [[ "$FILE" == *.zip ]]; then
  curl -sSfL "$URL" -o gitleaks.zip
  unzip -o gitleaks.zip gitleaks.exe -d "$INSTALL_DIR"
else
  curl -sSfL "$URL" -o gitleaks.tar.gz
  tar -xzf gitleaks.tar.gz -C "$INSTALL_DIR" gitleaks
fi

chmod +x "$INSTALL_DIR"/gitleaks*

cd - >/dev/null
rm -rf "$TMP_DIR"

export PATH="${INSTALL_DIR}:${PATH}"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo "[gitleaks] WARNING: $INSTALL_DIR is not in your PATH."
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "[gitleaks] ERROR: Gitleaks installed to $INSTALL_DIR but is not available in PATH."
  echo "[gitleaks] Add this to your shell config:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
  exit 1
fi

echo "[gitleaks] Installed successfully to $INSTALL_DIR"
gitleaks version