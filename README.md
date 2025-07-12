# ✨ Vim-GPT — Classic Vim AI Assistant

Vim-GPT is a powerful AI integration for **classic Vim** (not Neovim) that brings the capabilities of OpenAI (ChatGPT) directly into your editor. It supports code documentation, inline completion, and interactive prompts — with native Vimscript and Python integration.

🧠 Powered by OpenAI's GPT models.  
⚙️ Designed for speed, extensibility, and full keyboard-driven control.

---

## 📦 Features

- ✅ `:GPTDoc` – Insert AI-generated documentation above selected code (supports mouse and visual selection)
- ✅ `:GPTComplete` – Complete selected code blocks or prompts
- ✅ Insert-mode trigger `<C-Space>` for inline code completion
- ✅ Language-aware prompts with automatic comment formatting
- ✅ Logs all interactions to:
  - Markdown files (`doc/logs/YYYY-MM-DD_HH-MM-SS.md`)
  - SQLite database (`doc/gpt_log.db`)

---

## Advise

## 🛠 Installation

Requires:

- Vim 8.0+ (Classic Vim, not Neovim)
- Python 3.x
- OpenAI Python SDK (`pip install openai`)

### Manual Install

Clone the source:

```sh
git clone https://github.com/rfilipo/Vim-GPT.git
mkdir -p ~/.vim/pack/plugins/start
cp -R ./Vim-GPT/vim-gpt ~/.vim/pack/plugins/start
```

### API Key

Create a file with your OpenAI API key:

```sh
echo "sk-..." > ~/.vim/pack/plugins/start/vim-gpt/config/api_key
chmod 600 ~/.vim/pack/plugins/start/vim-gpt/config/api_key
```

---

## ⚡ Usage

### 🧾 `:GPTDoc`

Generate documentation for selected code.

```vim
# Select code (Visual or with mouse)
:GPTDoc
```

* Inserts language-formatted comment blocks above the selected code.
* Supports: `php`, `js`, `ts`, `python`, `c`, `cpp`, `java`, `html`, `css`, `go`, `rust`, and more.

---

### ✍️ `:GPTComplete`

Complete code snippets or prompts.

```vim
# Select code or type a prompt
:GPTComplete "Write a Python function that calculates factorial"
```

* Inserts GPT’s response below the selected lines or current line.

---

### ⌨️ Insert Mode Completion (`<C-Space>`)

Trigger inline completions while coding.

```vim
def is_prime(n):<C-Space>
```

To ensure terminal support, add to `.vimrc`:

```vim
map <Nul> <C-Space>
map! <Nul> <C-Space>
inoremap <C-Space> <C-N>
```

---

## 🗂 Logs

Every interaction is logged automatically:

* **Markdown logs**: `~/.vim/pack/plugins/start/vim-gpt/doc/logs/*.md`
* **Database**: `~/.vim/pack/plugins/start/vim-gpt/doc/gpt_log.db`

---

## 📚 Commands Summary

| Command        | Description                                      |
| -------------- | ------------------------------------------------ |
| `:GPTDoc`      | Add AI-generated documentation above code block  |
| `:GPTComplete` | Generate code or content from a selection/prompt |
| `<C-Space>`    | Inline code completion in Insert mode            |

---

## 🧠 Roadmap

* [ ] `:GPTLogOpen` and `:GPTLogSearch` utilities
* [ ] Floating preview support (GVim/terminal UI)
* [ ] Caching and offline prompt re-use
* [ ] Refactor, rename, explain, or test selected code
* [ ] Seamless Git/Gist integration

---

## 🤝 Credits

Created by [Monsenhor Filipo](https://github.com/kobkob) with the support of ChatGPT.
OpenAI API usage and ideas powered by community inspiration.

---

## 🛡 License

MIT — free to use, adapt, and contribute.


