#!/bin/bash
# Script para gerar AppImage da Calculator
# Autor: Marcos
# Versão: 1.0

set -e  # Sair em caso de erro

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variáveis
APP_NAME="calculator"
VERSION=$(grep '^version = ' Cargo.toml | head -n1 | cut -d'"' -f2)
ARCH=$(uname -m)
BUILD_DIR="AppDir"
OUTPUT_DIR="dist/appimage"

echo -e "${BLUE}🔨 Gerando AppImage para ${APP_NAME} v${VERSION}${NC}"

# Verifica se appimagetool está instalado
if ! command -v appimagetool &> /dev/null; then
    echo -e "${YELLOW}⚠️  appimagetool não encontrado${NC}"
    echo -e "${BLUE}📦 Baixando appimagetool...${NC}"
    
    mkdir -p tools
    cd tools
    
    if [ "$ARCH" = "x86_64" ]; then
        APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    elif [ "$ARCH" = "aarch64" ]; then
        APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-aarch64.AppImage"
    else
        echo -e "${RED}❌ Arquitetura não suportada: $ARCH${NC}"
        exit 1
    fi
    
    wget -O appimagetool "$APPIMAGETOOL_URL"
    chmod +x appimagetool
    APPIMAGETOOL="./tools/appimagetool"
    cd ..
else
    APPIMAGETOOL="appimagetool"
fi

# Compila o projeto em modo release
echo -e "${BLUE}🏗️  Compilando ${APP_NAME} em modo release...${NC}"
cargo build --release

# Limpa e cria diretório AppDir
echo -e "${BLUE}📁 Preparando estrutura AppDir...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$BUILD_DIR/usr/share/${APP_NAME}/assets"
mkdir -p "$BUILD_DIR/usr/share/${APP_NAME}/ui"

# Copia o binário
echo -e "${BLUE}📋 Copiando arquivos...${NC}"
cp "target/release/${APP_NAME}" "$BUILD_DIR/usr/bin/"

# Copia recursos
if [ -d "assets" ]; then
    cp -r assets/* "$BUILD_DIR/usr/share/${APP_NAME}/assets/"
fi

if [ -d "ui" ]; then
    cp -r ui/* "$BUILD_DIR/usr/share/${APP_NAME}/ui/"
fi

# Copia ícone
if [ -f "assets/logo.png" ]; then
    cp "assets/logo.png" "$BUILD_DIR/usr/share/icons/hicolor/256x256/apps/${APP_NAME}.png"
    cp "assets/logo.png" "$BUILD_DIR/${APP_NAME}.png"
fi

# Cria arquivo .desktop
echo -e "${BLUE}📝 Criando arquivo .desktop...${NC}"
cat > "$BUILD_DIR/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Name=Calculator
Comment=Calculadora Desktop em Rust + Slint
Exec=calculator
Icon=calculator
Terminal=false
Type=Application
Categories=Utility;Calculator;
Keywords=calculator;calculadora;math;
StartupNotify=true
EOF

# Copia .desktop para raiz do AppDir
cp "$BUILD_DIR/usr/share/applications/${APP_NAME}.desktop" "$BUILD_DIR/"

# Cria AppRun script
echo -e "${BLUE}⚙️  Criando AppRun...${NC}"
cat > "$BUILD_DIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share:${XDG_DATA_DIRS}"

# Executa o aplicativo
exec "${HERE}/usr/bin/calculator" "$@"
EOF

chmod +x "$BUILD_DIR/AppRun"

# Gera o AppImage
echo -e "${BLUE}📦 Gerando AppImage...${NC}"
mkdir -p "$OUTPUT_DIR"

# Remove AppImage antigo se existir
rm -f "$OUTPUT_DIR/${APP_NAME}-${VERSION}-${ARCH}.AppImage"

# Gera AppImage
ARCH=$ARCH $APPIMAGETOOL "$BUILD_DIR" "$OUTPUT_DIR/${APP_NAME}-${VERSION}-${ARCH}.AppImage"

# Torna executável
chmod +x "$OUTPUT_DIR/${APP_NAME}-${VERSION}-${ARCH}.AppImage"

# Limpa diretório temporário
echo -e "${BLUE}🧹 Limpando arquivos temporários...${NC}"
rm -rf "$BUILD_DIR"

# Sucesso
echo ""
echo -e "${GREEN}✅ AppImage gerado com sucesso!${NC}"
echo -e "${GREEN}📍 Localização: ${OUTPUT_DIR}/${APP_NAME}-${VERSION}-${ARCH}.AppImage${NC}"
echo ""
echo -e "${YELLOW}Para executar:${NC}"
echo -e "  ./${OUTPUT_DIR}/${APP_NAME}-${VERSION}-${ARCH}.AppImage"
echo ""
echo -e "${YELLOW}Para integrar ao sistema:${NC}"
echo -e "  chmod +x ${OUTPUT_DIR}/${APP_NAME}-${VERSION}-${ARCH}.AppImage"
echo -e "  ./${OUTPUT_DIR}/${APP_NAME}-${VERSION}-${ARCH}.AppImage --appimage-extract"
echo -e "  mv squashfs-root ~/.local/share/applications/${APP_NAME}"
echo ""
