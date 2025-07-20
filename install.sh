
#!/usr/bin/env bash

set -e

echo "🌟 Starting Vim-GPT Installation..."

# Detect OS
OS_TYPE="$(uname)"
echo "Detected OS: $OS_TYPE"

# Determine shell profile (bash or zsh)
SHELL_PROFILE="~/.bashrc"
if [[ "$SHELL" == */zsh ]]; then
  SHELL_PROFILE="~/.zshrc"
fi

# Install dependencies
install_dependencies_linux() {
  echo "Installing dependencies for Linux (APT)..."
  sudo apt update
  sudo apt install -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
    liblzma-dev git openssh-server
}

install_dependencies_mac() {
  echo "Installing dependencies for macOS (Homebrew)..."
  brew update
  brew install openssl readline sqlite3 xz zlib llvm make git pyenv curl
}

if [[ "$OS_TYPE" == "Darwin" ]]; then
  command -v brew >/dev/null 2>&1 || { echo >&2 "Homebrew is not installed. Install it first from https://brew.sh"; exit 1; }
  install_dependencies_mac
else
  install_dependencies_linux
fi

# Install pyenv
if ! command -v pyenv >/dev/null 2>&1; then
  echo "Installing pyenv..."
  curl https://pyenv.run | bash
else
  echo "✅ pyenv is already installed."
fi

# Setup pyenv in shell profile
echo "🔧 Configuring pyenv in $SHELL_PROFILE..."
PYENV_BLOCK='\n# Pyenv Setup\nexport PYENV_ROOT="$HOME/.pyenv"\nexport PATH="$PYENV_ROOT/bin:$PATH"\nif command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi\n'
grep -q 'pyenv init' "$SHELL_PROFILE" || echo -e "$PYENV_BLOCK" >> "$SHELL_PROFILE"

# Install Vim-Plug if missing
install_vimplug() {
  echo "Installing Vim-Plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_vimplug_nvim() {
  echo "Installing Vim-Plug for Neovim..."
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

# Clone the plugin
PLUGIN_DIR_VIM="$HOME/.vim/pack/plugins/start/vim-gpt"
PLUGIN_DIR_NVIM="$HOME/.config/nvim/pack/plugins/start/vim-gpt"

mkdir -p "$(dirname "$PLUGIN_DIR_VIM")"
mkdir -p "$(dirname "$PLUGIN_DIR_NVIM")"

echo "📦 Cloning Vim-GPT plugin..."
git clone https://github.com/rfilipo/Vim-GPT.git /tmp/Vim-GPT

cp -r /tmp/Vim-GPT/vim-gpt "$PLUGIN_DIR_VIM"
cp -r /tmp/Vim-GPT/vim-gpt "$PLUGIN_DIR_NVIM"

# Create config folder and apikey path
mkdir -p "$PLUGIN_DIR_VIM/config"
mkdir -p "$PLUGIN_DIR_NVIM/config"
touch "$PLUGIN_DIR_VIM/config/apikey"
touch "$PLUGIN_DIR_NVIM/config/apikey"

# Install Vim-Plug if not present
[[ -f ~/.vim/autoload/plug.vim ]] || install_vimplug
[[ -f ~/.local/share/nvim/site/autoload/plug.vim ]] || install_vimplug_nvim

echo "✅ Installation complete!"
echo "👉 Now open Vim or Neovim and run :PlugInstall if you're using Vim-Plug."
echo "👉 Don’t forget to set your OpenAI API key in the file: ~/.vim/pack/plugins/start/vim-gpt/config/apikey"
