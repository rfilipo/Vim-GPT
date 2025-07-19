#!/usr/bin/env bash

set -e

echo "🚀 Starting Vim-GPT plugin installation..."

# Update system and install dependencies
echo "🔧 Installing system dependencies..."
sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
  libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
  liblzma-dev git openssh-server

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
  echo "🐍 Installing pyenv..."
  curl https://pyenv.run | bash
else
  echo "✅ pyenv already installed."
fi

# Setup pyenv environment for the shell session
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install latest stable Python
PYTHON_VERSION=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
echo "🐍 Installing Python $PYTHON_VERSION with pyenv..."
pyenv install -s "$PYTHON_VERSION"
pyenv global "$PYTHON_VERSION"

# Install OpenAI SDK
echo "📦 Installing OpenAI Python SDK..."
pip install --upgrade pip
pip install openai

# Setup plugin folder
VIM_PLUGIN_DIR="$HOME/.vim/pack/plugins/start"
mkdir -p "$VIM_PLUGIN_DIR"
cd "$VIM_PLUGIN_DIR"

# Clone Vim-GPT
if [ ! -d "vim-gpt" ]; then
  echo "📥 Cloning Vim-GPT plugin..."
  git clone https://github.com/rfilipo/Vim-GPT.git vim-gpt
else
  echo "🔄 Updating Vim-GPT plugin..."
  cd vim-gpt && git pull
fi

# API Key
echo "🔑 Final step: create your OpenAI API key file."
if [ ! -f "$HOME/.openai_api_key" ]; then
  echo "👉 Paste your OpenAI API key below (starts with sk-...), then press [ENTER]:"
  read -r OPENAI_KEY
  echo "$OPENAI_KEY" > "$HOME/.openai_api_key"
  chmod 600 "$HOME/.openai_api_key"
  echo "✅ API key saved to ~/.openai_api_key"
else
  echo "✅ API key already exists at ~/.openai_api_key"
fi

echo "🎉 Done! Open Vim and run :GPTDoc or :GPTComplete to start using GPT inside Vim."

