#!/bin/bash
# build_deb.sh – Gera pacote .deb do Vim-GPT

set -e

PKG_NAME="vim-gpt"
VERSION="1.0.0"
ARCH="all"
BUILD_DIR="deb_build"
INSTALL_DIR="$BUILD_DIR/usr/share/$PKG_NAME"

echo "🛠️ Criando estrutura do pacote .deb..."

# Limpa build antiga
rm -rf "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

# Copia os arquivos principais
cp -r vim-gpt "$INSTALL_DIR/"
cp LICENSE README.md "$INSTALL_DIR/"
chmod -R 755 "$INSTALL_DIR"

# Metadados do pacote
mkdir -p "$BUILD_DIR/DEBIAN"
cat <<EOF > "$BUILD_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $VERSION
Section: editors
Priority: optional
Architecture: $ARCH
Maintainer: Monsenhor Filipo <monsenhor@example.com>
Description: Plugin Vim com integração à OpenAI GPT.
 Integração para terminal usando Vim, com geração de código, documentação e logs.
EOF

# Script pós-instalação
cat <<EOF > "$BUILD_DIR/DEBIAN/postinst"
#!/bin/bash
echo "✅ Vim-GPT instalado com sucesso!"
echo "📁 Local: /usr/share/vim-gpt"
echo "⚙️ Copie ou linke para ~/.vim/pack/plugins/start/vim-gpt se necessário."
EOF
chmod 755 "$BUILD_DIR/DEBIAN/postinst"

# Gera o pacote
dpkg-deb --build "$BUILD_DIR"
mv "${BUILD_DIR}.deb" "${PKG_NAME}_${VERSION}_${ARCH}.deb"

echo "🎉 Pacote .deb criado: ${PKG_NAME}_${VERSION}_${ARCH}.deb"

