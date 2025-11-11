#!/usr/bin/env bash
# Instala o AppImage do Calculator no sistema
# Usa o ícone em assets/logo.png
# Requer privilégios de administrador

set -euo pipefail

# ===== Cores =====
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# ===== Escalada de privilégio =====
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo -e "${YELLOW}⚠️  Este script precisa de privilégios de administrador.${NC}"
  exec sudo -E bash "$0" "$@"
fi

# ===== Variáveis =====
APP_NAME="calculator"
INSTALL_DIR="/opt/${APP_NAME}"
BIN_LINK="/usr/local/bin/${APP_NAME}"
DESKTOP_FILE="/usr/share/applications/${APP_NAME}.desktop"
ICON_DIR="/usr/share/icons/hicolor/256x256/apps"
ICON_FILE="${ICON_DIR}/${APP_NAME}.png"
PIXMAP_ICON="/usr/share/pixmaps/${APP_NAME}.png"
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
ASSET_ICON_SRC="${PROJECT_ROOT}/assets/logo.png"
DEFAULT_APPIMAGE_DIR="${PROJECT_ROOT}/dist/appimage"

# Caminho do AppImage (1º argumento opcional)
APPIMAGE_PATH="${1:-}"
if [ -z "${APPIMAGE_PATH}" ]; then
  # Tenta localizar um AppImage em dist/appimage
  if [ -d "${DEFAULT_APPIMAGE_DIR}" ]; then
    # Pega o mais recente correspondente ao nome do app
    APPIMAGE_CANDIDATE=$(ls -1t "${DEFAULT_APPIMAGE_DIR}"/${APP_NAME}-*.AppImage 2>/dev/null | head -n1 || true)
    if [ -n "${APPIMAGE_CANDIDATE}" ]; then
      APPIMAGE_PATH="${APPIMAGE_CANDIDATE}"
    fi
  fi
fi

if [ -z "${APPIMAGE_PATH}" ] || [ ! -f "${APPIMAGE_PATH}" ]; then
  echo -e "${RED}❌ AppImage não encontrado.${NC}"
  echo -e "${YELLOW}Informe o caminho do AppImage como argumento ou gere com 'make appimage'. Ex:${NC}"
  echo -e "  sudo ./install-appimage.sh dist/appimage/${APP_NAME}-0.1.0-$(uname -m).AppImage"
  exit 1
fi

# ===== Instalação =====
echo -e "${BLUE}📦 Instalando ${APP_NAME} AppImage...${NC}"
mkdir -p "${INSTALL_DIR}"
install -m 0755 "${APPIMAGE_PATH}" "${INSTALL_DIR}/${APP_NAME}.AppImage"

# Symlink para facilitar execução no terminal
ln -sf "${INSTALL_DIR}/${APP_NAME}.AppImage" "${BIN_LINK}"

# Instala ícone
if [ -f "${ASSET_ICON_SRC}" ]; then
  mkdir -p "${ICON_DIR}"
  install -m 0644 "${ASSET_ICON_SRC}" "${ICON_FILE}"
  install -m 0644 "${ASSET_ICON_SRC}" "${PIXMAP_ICON}"
else
  echo -e "${YELLOW}⚠️  Ícone não encontrado em ${ASSET_ICON_SRC}. Pulando instalação de ícone.${NC}"
fi

# Cria .desktop
cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Name=Calculator
Comment=Calculadora Desktop em Rust + Slint
Exec=${INSTALL_DIR}/${APP_NAME}.AppImage
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Utility;Calculator;
Keywords=calculator;calculadora;math;
StartupNotify=true
EOF
chmod 0644 "${DESKTOP_FILE}"

# Atualiza caches de desktop e ícones
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f /usr/share/icons/hicolor || true

echo -e "${GREEN}✅ Instalação concluída!${NC}"
echo -e "${GREEN}• Executável: ${INSTALL_DIR}/${APP_NAME}.AppImage${NC}"
echo -e "${GREEN}• Atalho: ${BIN_LINK}${NC}"
echo -e "${GREEN}• Menu: disponível como 'Calculator' no lançador de apps${NC}"

echo -e "${YELLOW}Como executar via terminal:${NC}"
echo "  ${APP_NAME}"
