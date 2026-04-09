---
name: macos-init
description: Initialize a new Mac with a complete development environment. Use this skill whenever the user wants to set up a new Mac, bootstrap a fresh macOS installation, install dev tools (Node.js, NVM, Python, Conda, Go, Rust, Git, VSCode, Chrome, ClashX, etc.), or configure their development environment from scratch. Trigger even if the user just mentions "new Mac", "fresh install", "setup my Mac", or lists any combination of these tools.
---

# macOS Dev Environment Initializer

Help the user set up a complete development environment on a new Mac. Work interactively — check what's already installed, confirm what to install, then execute in the right order.

## Step 1: Assess Current State

Run these checks first to understand what's already installed:

```bash
# Check key tools
which brew && brew --version
which git && git --version
which node && node --version
which nvm
which python3 && python3 --version
which conda
which go && go version
which rustc && rustc --version
which code
```

Report what's missing vs already installed. Don't reinstall things that already work.

## Step 2: Confirm Install Plan

Present a checklist of what will be installed and ask the user to confirm or adjust. Default selection based on user's request:

- [ ] Homebrew (package manager — required first)
- [ ] Git + config (name, email)
- [ ] NVM + Node.js LTS
- [ ] Python 3 + pip
- [ ] Miniconda
- [ ] Go
- [ ] Rust (via rustup)
- [ ] VSCode
- [ ] Google Chrome
- [ ] ClashX (proxy client)

## Step 3: Install in Order

Follow this exact order to avoid dependency issues.

### 3.1 Xcode Command Line Tools

```bash
xcode-select --install 2>/dev/null; xcode-select -p
```

If already installed, skip. This is required for Homebrew and Git.

### 3.2 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After install on Apple Silicon, add to shell profile:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

On Intel Mac the prefix is `/usr/local` — adjust accordingly.

### 3.3 Git

```bash
brew install git
```

Configure identity:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

Always ensure both `user.name` and `user.email` are configured. Do not skip this step.

### 3.4 NVM + Node.js

Install NVM (do NOT use `brew install node` — NVM gives version flexibility):
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

Add to `~/.zshrc` if not already present:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Then install Node LTS:
```bash
source ~/.zshrc
nvm install --lts
nvm use --lts
nvm alias default node
```

### 3.5 Python + Miniconda

Install Miniconda (includes Python + conda):
```bash
brew install --cask miniconda
conda init zsh
```

Restart shell or `source ~/.zshrc`, then verify:
```bash
conda --version
python --version
```

If the user only wants plain Python without conda:
```bash
brew install python
```

### 3.6 Go

```bash
brew install go
```

Add to `~/.zshrc`:
```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

### 3.7 Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Choose option 1 (default install). Then:
```bash
source "$HOME/.cargo/env"
rustc --version
cargo --version
```

### 3.8 GUI Apps via Homebrew Cask

```bash
brew install --cask visual-studio-code
brew install --cask google-chrome
brew install --cask clashx
```

For VSCode, also install the `code` CLI:
```bash
# Script mode already appends VSCode CLI path to ~/.zshrc:
echo 'export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"' >> ~/.zshrc
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Then installs common extensions automatically:
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension eamodio.gitlens
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension golang.go
code --install-extension rust-lang.rust-analyzer
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension bradlc.vscode-tailwindcss
code --install-extension PKief.material-icon-theme
code --install-extension GitHub.github-vscode-theme
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension formulahendry.auto-rename-tag
code --install-extension christian-kohler.path-intellisense
```

## Step 4: Shell Profile Cleanup

After all installs, consolidate additions to `~/.zshrc`. Show the user the final relevant sections and offer to clean up duplicates.

Recommended `~/.zshrc` additions block:
```bash
# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Rust
source "$HOME/.cargo/env"

# Conda (added by conda init — leave as-is)
```

## Step 5: Verify Everything

Run a final check:
```bash
echo "=== Dev Environment Check ===" && \
git --version && \
node --version && nvm --version && \
python --version && conda --version && \
go version && \
rustc --version && cargo --version && \
code --version && \
echo "All done!"
```

Report any failures and help the user fix them.

## One-click Install Script

If the user wants to run everything automatically, use the bundled script:

```bash
# Interactive mode (prompts for each tool)
bash scripts/install.sh

# Install everything at once
bash scripts/install.sh --all

# Install specific tools
bash scripts/install.sh --git --node --apps
```

Available flags: `--all`, `--git`, `--node`, `--python`, `--conda`, `--go`, `--rust`, `--apps`

The script handles Homebrew + Xcode CLT installation automatically before anything else.

## How GUI Apps Are Installed (VSCode, Chrome, ClashX)

These apps don't require the user to manually download anything. `brew install --cask` handles it:
- Homebrew downloads the **official installer/DMG** from the vendor's website
- Installs it to `/Applications/` automatically
- No need to visit any download page

This is equivalent to downloading manually, but fully automated. The user just needs to wait for the download to finish.

## Notes

- **Apple Silicon vs Intel**: Homebrew path differs (`/opt/homebrew` vs `/usr/local`). Detect with `uname -m`.
- **ClashX**: After install, the user needs to manually configure their proxy subscription URL in the app.
- **Miniconda auto-activation**: If the user doesn't want conda to activate by default, run `conda config --set auto_activate_base false`.
- **NVM version**: Check https://github.com/nvm-sh/nvm for the latest version before installing.

