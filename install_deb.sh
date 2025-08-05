#!/bin/bash
# installi_deb.sh – Instalador automático do Vim-GPT

DEB_PACKAGE="vim-gpt_1.0.0_all.deb"

if command -v dpkg &> /dev/null && [ -f "$DEB_PACKAGE" ]; then
  echo "📦 Instalando via pacote .deb..."
  sudo dpkg -i "$DEB_PACKAGE"
else
  echo "⚙️ Instalação manual..."
  mkdir -p ~/.vim/pack/plugins/start/
  cp -r vim-gpt ~/.vim/pack/plugins/start/
  echo "✅ Vim-GPT instalado em ~/.vim/pack/plugins/start/vim-gpt"
fi

echo "🧠 Lembre-se de configurar sua API Key em:"
echo "~/.vim/pack/plugins/start/vim-gpt/config/apikey"

