#!/usr/bin/env bash
# macOS Dev Environment Setup Script
# Usage: bash install.sh [--all] [--git] [--node] [--python] [--conda] [--go] [--rust] [--apps]
# With no flags, runs in interactive mode.

set -e

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓ $*${NC}"; }
warn() { echo -e "${YELLOW}⚠ $*${NC}"; }
info() { echo -e "  $*"; }
fail() { echo -e "${RED}✗ $*${NC}"; exit 1; }

# ── Flags ─────────────────────────────────────────────────────────────────────
INSTALL_ALL=false
INSTALL_GIT=false; INSTALL_NODE=false; INSTALL_PYTHON=false
INSTALL_CONDA=false; INSTALL_GO=false; INSTALL_RUST=false; INSTALL_APPS=false

for arg in "$@"; do
  case $arg in
    --all)    INSTALL_ALL=true ;;
    --git)    INSTALL_GIT=true ;;
    --node)   INSTALL_NODE=true ;;
    --python) INSTALL_PYTHON=true ;;
    --conda)  INSTALL_CONDA=true ;;
    --go)     INSTALL_GO=true ;;
    --rust)   INSTALL_RUST=true ;;
    --apps)   INSTALL_APPS=true ;;
  esac
done

# ── Interactive mode if no flags ───────────────────────────────────────────────
if ! $INSTALL_ALL && ! $INSTALL_GIT && ! $INSTALL_NODE && ! $INSTALL_PYTHON && \
   ! $INSTALL_CONDA && ! $INSTALL_GO && ! $INSTALL_RUST && ! $INSTALL_APPS; then
  echo ""
  echo "=== macOS Dev Environment Setup ==="
  echo ""
  echo "Select what to install (y/n), or press Enter to install all:"
  echo ""
  read -rp "  Install everything? [Y/n]: " ans
  if [[ -z "$ans" || "$ans" =~ ^[Yy] ]]; then
    INSTALL_ALL=true
  else
    read -rp "  Git                  [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_GIT=true
    read -rp "  NVM + Node.js LTS    [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_NODE=true
    read -rp "  Python 3             [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_PYTHON=true
    read -rp "  Miniconda            [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_CONDA=true
    read -rp "  Go                   [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_GO=true
    read -rp "  Rust                 [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_RUST=true
    read -rp "  Apps (VSCode/Chrome/ClashX) [y/n]: " ans; [[ "$ans" =~ ^[Yy] ]] && INSTALL_APPS=true
  fi
fi

if $INSTALL_ALL; then
  INSTALL_GIT=true; INSTALL_NODE=true; INSTALL_PYTHON=true
  INSTALL_CONDA=true; INSTALL_GO=true; INSTALL_RUST=true; INSTALL_APPS=true
fi

# ── Detect architecture ────────────────────────────────────────────────────────
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# ── Helper: add line to zshrc if not present ──────────────────────────────────
add_to_zshrc() {
  local line="$1"
  grep -qF "$line" ~/.zshrc 2>/dev/null || echo "$line" >> ~/.zshrc
}

echo ""
echo "=== Starting macOS Dev Environment Setup ==="
echo ""

# ── 1. Xcode Command Line Tools ───────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "  Please complete the Xcode CLT installation popup, then press Enter to continue."
  read -r
else
  ok "Xcode Command Line Tools already installed"
fi

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"' >> ~/.zprofile
  eval "$($BREW_PREFIX/bin/brew shellenv)"
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
  brew update --quiet
fi

# ── 3. Git ────────────────────────────────────────────────────────────────────
if $INSTALL_GIT; then
  if ! command -v git &>/dev/null || [[ "$(git --version)" == *"Apple"* ]]; then
    info "Installing Git..."
    brew install git
  fi
  ok "Git $(git --version | awk '{print $3}')"
  echo ""
  read -rp "  Git user.name  (leave blank to skip): " git_name
  read -rp "  Git user.email (leave blank to skip): " git_email
  [[ -n "$git_name" ]]  && git config --global user.name "$git_name"
  [[ -n "$git_email" ]] && git config --global user.email "$git_email"
  git config --global init.defaultBranch main
fi

# ── 4. NVM + Node.js ──────────────────────────────────────────────────────────
if $INSTALL_NODE; then
  if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
  add_to_zshrc 'export NVM_DIR="$HOME/.nvm"'
  add_to_zshrc '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  nvm alias default node
  ok "Node $(node --version) via NVM"
fi

# ── 5. Python ─────────────────────────────────────────────────────────────────
if $INSTALL_PYTHON && ! $INSTALL_CONDA; then
  brew install python
  ok "Python $(python3 --version | awk '{print $2}')"
fi

# ── 6. Miniconda ──────────────────────────────────────────────────────────────
if $INSTALL_CONDA; then
  if ! command -v conda &>/dev/null; then
    info "Installing Miniconda..."
    brew install --cask miniconda
    conda init zsh
    conda config --set auto_activate_base false
  fi
  ok "Conda $(conda --version 2>/dev/null || echo 'installed — restart shell to activate')"
fi

# ── 7. Go ─────────────────────────────────────────────────────────────────────
if $INSTALL_GO; then
  brew install go
  add_to_zshrc 'export GOPATH=$HOME/go'
  add_to_zshrc 'export PATH=$PATH:$GOPATH/bin'
  ok "Go $(go version | awk '{print $3}')"
fi

# ── 8. Rust ───────────────────────────────────────────────────────────────────
if $INSTALL_RUST; then
  if ! command -v rustc &>/dev/null; then
    info "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
  add_to_zshrc 'source "$HOME/.cargo/env"'
  ok "Rust $(rustc --version | awk '{print $2}')"
fi

# ── 9. GUI Apps (via Homebrew Cask) ───────────────────────────────────────────
if $INSTALL_APPS; then
  info "Installing GUI apps via Homebrew Cask..."
  info "(Homebrew will download the official installers automatically)"
  echo ""

  if ! ls /Applications/Visual\ Studio\ Code.app &>/dev/null; then
    info "Downloading & installing VSCode..."
    brew install --cask visual-studio-code
    ok "VSCode installed"
  else
    ok "VSCode already installed"
  fi

  if ! ls /Applications/Google\ Chrome.app &>/dev/null; then
    info "Downloading & installing Google Chrome..."
    brew install --cask google-chrome
    ok "Chrome installed"
  else
    ok "Chrome already installed"
  fi

  if ! ls /Applications/ClashX.app &>/dev/null; then
    info "Downloading & installing ClashX..."
    brew install --cask clashx
    ok "ClashX installed — configure your proxy subscription URL in the app"
  else
    ok "ClashX already installed"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Run 'source ~/.zshrc' or open a new terminal to apply all PATH changes."
echo ""

