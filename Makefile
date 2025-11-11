# Makefile para Calculator - Aplicação Rust + Slint
# Autor: Marcos
# Versão: 1.0

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
.PHONY: help build run watch clean release test fmt clippy install-deps all

# Target padrão
all: build

# Exibe ajuda com todos os comandos disponíveis
help:
	@echo "${BLUE}📦 Makefile para $(PROJECT_NAME)${NC}"
	@echo ""
	@echo "${YELLOW}Comandos disponíveis:${NC}"
	@echo "  ${GREEN}build${NC}        - Compila o projeto em modo debug"
	@echo "  ${GREEN}run${NC}          - Executa a aplicação"
	@echo "  ${GREEN}watch${NC}        - Executa com hot reload (recompila automaticamente)"
	@echo "  ${GREEN}release${NC}      - Compila o projeto em modo release (otimizado)"
	@echo "  ${GREEN}test${NC}         - Executa os testes"
	@echo "  ${GREEN}fmt${NC}          - Formata o código usando rustfmt"
	@echo "  ${GREEN}clippy${NC}       - Executa o linter clippy"
	@echo "  ${GREEN}clean${NC}        - Remove arquivos de build"
	@echo "  ${GREEN}install-deps${NC} - Instala dependências necessárias"
	@echo "  ${GREEN}all${NC}          - Executa build (target padrão)"
	@echo "  ${GREEN}help${NC}         - Exibe esta ajuda"

# Compila o projeto em modo debug
build:
	@echo "${BLUE}🔨 Compilando $(PROJECT_NAME) em modo debug...${NC}"
	$(CARGO) build

# Executa a aplicação
run:
	@echo "${GREEN}🚀 Executando $(PROJECT_NAME)...${NC}"
	$(CARGO) run

# Executa com hot reload usando cargo-watch
watch:
	@echo "${YELLOW}👀 Iniciando watch mode para $(PROJECT_NAME)...${NC}"
	@echo "${YELLOW}A aplicação será recompilada automaticamente quando arquivos forem modificados.${NC}"
	@echo "${YELLOW}Pressione Ctrl+C para parar.${NC}"
	@if command -v cargo-watch >/dev/null 2>&1; then \
		$(CARGO_WATCH) -x run; \
	else \
		echo "${RED}❌ cargo-watch não está instalado!${NC}"; \
		echo "${YELLOW}💡 Para instalar, execute: make install-deps${NC}"; \
		exit 1; \
	fi

# Compila em modo release (otimizado)
release:
	@echo "${BLUE}🏗️  Compilando $(PROJECT_NAME) em modo release...${NC}"
	$(CARGO) build --release
	@echo "${GREEN}✅ Build de release criado em: target/release/$(PROJECT_NAME)${NC}"

# Executa os testes
test:
	@echo "${BLUE}🧪 Executando testes...${NC}"
	$(CARGO) test

# Formata o código
fmt:
	@echo "${BLUE}🎨 Formatando código...${NC}"
	$(CARGO) fmt
	@echo "${GREEN}✅ Código formatado!${NC}"

# Executa o linter clippy
clippy:
	@echo "${BLUE}🔍 Executando clippy (linter)...${NC}"
	$(CARGO) clippy -- -D warnings
	@echo "${GREEN}✅ Clippy executado!${NC}"

# Remove arquivos de build
clean:
	@echo "${YELLOW}🧹 Limpando arquivos de build...${NC}"
	$(CARGO) clean
	@echo "${GREEN}✅ Arquivos de build removidos!${NC}"

# Instala dependências necessárias para desenvolvimento
install-deps:
	@echo "${BLUE}📦 Instalando dependências de desenvolvimento...${NC}"
	@echo "${YELLOW}Instalando cargo-watch...${NC}"
	$(CARGO) install cargo-watch
	@echo "${GREEN}✅ Dependências instaladas!${NC}"

# Target para desenvolvimento completo
dev: fmt clippy build

# Target para CI/CD
ci: fmt clippy test build

# Verifica se há updates nas dependências
check-updates:
	@echo "${BLUE}🔄 Verificando atualizações das dependências...${NC}"
	@if command -v cargo-outdated >/dev/null 2>&1; then \
		cargo outdated; \
	else \
		echo "${YELLOW}💡 Para verificar atualizações, instale cargo-outdated:${NC}"; \
		echo "  cargo install cargo-outdated"; \
	fi

# Executa a aplicação em modo release
run-release: release
	@echo "${GREEN}🚀 Executando $(PROJECT_NAME) (release)...${NC}"
	./target/release/$(PROJECT_NAME)

# Mostra informações do projeto
info:
	@echo "${BLUE}📊 Informações do projeto:${NC}"
	@echo "  Nome: $(PROJECT_NAME)"
	@echo "  Versão Rust: $(shell rustc --version)"
	@echo "  Versão Cargo: $(shell cargo --version)"
	@echo "  Diretório: $(PWD)"
	@echo ""
	@echo "${BLUE}📈 Estatísticas do código:${NC}"
	@find src/ -name "*.rs" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print "  Linhas de código Rust: " $$1}' || echo "  Linhas de código: Não disponível"
	@find ui/ -name "*.slint" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print "  Linhas de código Slint: " $$1}' || echo "  Linhas de UI: Não disponível"