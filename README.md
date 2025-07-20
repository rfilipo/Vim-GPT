# Vim-GPT 🧠✨

AI-Powered Assistance Directly in Vim or Neovim using OpenAI's GPT API

---

## 📦 Installation

You can install Vim-GPT with a one-liner:

### Using `curl`

```bash
curl -s https://raw.githubusercontent.com/rfilipo/Vim-GPT/main/install.sh | bash
```

### Using `wget`

```bash
wget -qO- https://raw.githubusercontent.com/rfilipo/Vim-GPT/main/install.sh | bash
```

This script installs:

* System dependencies (build tools, SSL, SQLite, etc.)
* `pyenv` and the latest stable Python
* OpenAI's Python SDK
* This plugin under `~/.vim/pack/plugins/start/vim-gpt` (or for Neovim, compatible path)
* Your API key in: `~/.vim/pack/plugins/start/vim-gpt/config/apikey`

Also adds the following to `~/.bashrc` (and `.zshrc` if needed):

```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
```

For **macOS users**, `brew` is used to install required dependencies.

For **Neovim users**, the plugin works just like in Vim. It uses the same paths and logic.

### ✅ Vim-Plug (Optional)

If you prefer Vim-Plug, add this to your `.vimrc` or `init.vim`:

```vim
Plug 'rfilipo/Vim-GPT', { 'rtp': 'vim-gpt' }
```

Then run `:PlugInstall` and run the install script manually for dependencies:

```bash
curl -s https://raw.githubusercontent.com/rfilipo/Vim-GPT/main/install.sh | bash
```

---

## ⚙️ Usage

Once installed, launch Vim or Neovim and use the following commands in **Normal** or **Visual** mode:

### 🔸 `:GPTDoc`

Generate documentation for the selected code or current line.

### 🔸 `:GPTExplain`

Get an explanation of the selected code snippet or current line.

### 🔸 `:GPTRefactor`

Ask GPT to refactor or improve the selected code.

### 🔸 `:GPTComplete`

(Coming soon) Autocompletes code using AI suggestions.

---

## 🔑 API Key

Your API key must be placed at:

```bash
~/.vim/pack/plugins/start/vim-gpt/config/apikey
```

The installer will prompt you to paste it the first time.

To generate an API key:

* Visit [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)

---

## 📁 Plugin Structure

```
vim-gpt/
├── autoload/
│   └── gpt.vim          # Vim commands and logic
├── python/
│   └── gpt_backend.py   # Python script for OpenAI API requests
├── config/
│   └── apikey           # Your OpenAI API key (not committed)
├── README.md
```

---

## 🧪 Requirements

### OS:

* Debian/Ubuntu Linux, macOS (for installer script)

### Tools Installed:

* Python (via `pyenv`)
* `pip` with `openai`
* Vim (8.0+) or Neovim

---

## 💬 Feedback / Contributions

PRs are welcome at:
[https://github.com/rfilipo/Vim-GPT](https://github.com/rfilipo/Vim-GPT)

---

Crafted with 🧠 by @rfilipo and GPT ✨

