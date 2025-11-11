# Makefile para Calculator - Aplicação Rust + Slint
# Autor: Marcos
# Versão: 2.0

# Variáveis
PROJECT_NAME := calculator
CARGO := cargo
CARGO_WATCH := cargo-watch

# Cores para output
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RED := \033[31m
NC := \033[0m # No Color

# Targets principais
.PHONY: help build run watch clean release install-deps all

# Target padrão
all: build

# Exibe ajuda com todos os comandos disponíveis
help:
	@echo -e "${BLUE}📦 Makefile para $(PROJECT_NAME)${NC}"
	@echo ""
	@echo -e "${YELLOW}Comandos disponíveis:${NC}"
	@echo -e "  ${GREEN}build${NC}        - Compila o projeto em modo debug"
	@echo -e "  ${GREEN}run${NC}          - Executa a aplicação"
	@echo -e "  ${GREEN}watch${NC}        - Executa com hot reload (recompila automaticamente)"
	@echo -e "  ${GREEN}release${NC}      - Compila o projeto em modo release (otimizado)"
	@echo -e "  ${GREEN}clean${NC}        - Remove arquivos de build"
	@echo -e "  ${GREEN}install-deps${NC} - Instala cargo-watch para desenvolvimento"
	@echo -e "  ${GREEN}all${NC}          - Executa build (target padrão)"
	@echo -e "  ${GREEN}help${NC}         - Exibe esta ajuda"

# Compila o projeto em modo debug
build:
	@echo -e "${BLUE}🔨 Compilando $(PROJECT_NAME) em modo debug...${NC}"
	$(CARGO) build

# Executa a aplicação
run:
	@echo -e "${GREEN}🚀 Executando $(PROJECT_NAME)...${NC}"
	$(CARGO) run

# Executa com hot reload usando cargo-watch
watch:
	@echo -e "${YELLOW}👀 Iniciando watch mode para $(PROJECT_NAME)...${NC}"
	@echo -e "${YELLOW}A aplicação será recompilada automaticamente quando arquivos forem modificados.${NC}"
	@echo -e "${YELLOW}Pressione Ctrl+C para parar.${NC}"
	@if command -v cargo-watch >/dev/null 2>&1; then \
		$(CARGO_WATCH) -x run; \
	else \
		echo -e "${RED}❌ cargo-watch não está instalado!${NC}"; \
		echo -e "${YELLOW}💡 Para instalar, execute: make install-deps${NC}"; \
		exit 1; \
	fi

# Compila em modo release (otimizado)
release:
	@echo -e "${BLUE}🏗️  Compilando $(PROJECT_NAME) em modo release...${NC}"
	$(CARGO) build --release
	@echo -e "${GREEN}✅ Build de release criado em: target/release/$(PROJECT_NAME)${NC}"

# Remove arquivos de build
clean:
	@echo -e "${YELLOW}🧹 Limpando arquivos de build...${NC}"
	$(CARGO) clean
	@echo -e "${GREEN}✅ Arquivos de build removidos!${NC}"

# Instala dependências necessárias para desenvolvimento
install-deps:
	@echo -e "${BLUE}📦 Instalando cargo-watch...${NC}"
	$(CARGO) install cargo-watch
	@echo -e "${GREEN}✅ cargo-watch instalado!${NC}"