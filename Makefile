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
.PHONY: help build run watch clean release test fmt clippy install-deps all \
	install-packaging-deps package-prep package-deb package-rpm package-arch package-arch-pkgbuild packages packaging-clean

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
	@echo "  ${GREEN}install-packaging-deps${NC} - Instala ferramentas para empacotar (.deb/.rpm)"
	@echo "  ${GREEN}package-deb${NC}  - Gera pacote .deb (Debian/Ubuntu) via fpm"
	@echo "  ${GREEN}package-rpm${NC}  - Gera pacote .rpm (Fedora/RHEL/openSUSE) via fpm"
	@echo "  ${GREEN}package-arch${NC} - Gera pacote Arch Linux (.pkg.tar.*) via fpm"
	@echo "  ${GREEN}package-arch-pkgbuild${NC} - Gera pacote Arch usando PKGBUILD + makepkg (nativo)"
	@echo "  ${GREEN}packages${NC}     - Gera .deb, .rpm e pacote Arch"
	@echo "  ${GREEN}packaging-clean${NC} - Limpa artefatos de empacotamento (dist/)"
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

# ==============================
# Empacotamento (.deb e .rpm)
# Estratégia: usamos o fpm para gerar pacotes a partir de um diretório staging.
# Em Arch Linux, você pode instalar o fpm via RubyGems.
# ==============================

# Coleta a versão do Cargo.toml (primeira ocorrência de version = "x.y.z")
VERSION := $(shell sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -n1)
ARCH := $(shell uname -m)
# Mapeia arquitetura para formato Debian
DEB_ARCH := $(if $(filter $(ARCH),x86_64),amd64,$(if $(filter $(ARCH),aarch64),arm64,$(ARCH)))
RPM_ARCH := $(ARCH)

# Diretórios de saída
DIST_DIR := dist
PKGROOT := $(DIST_DIR)/pkgroot
DEB_OUT := $(DIST_DIR)/deb
RPM_OUT := $(DIST_DIR)/rpm
ARCH_OUT := $(DIST_DIR)/arch

# Instala ferramentas de empacotamento (requer sudo para pacman/gem)
install-packaging-deps:
	@echo "${BLUE}📦 Instalando ferramentas de empacotamento (fpm)...${NC}"
	@if command -v fpm >/dev/null 2>&1; then \
		echo "${GREEN}✅ fpm já instalado${NC}"; \
	else \
		echo "${YELLOW}⚠️  fpm não encontrado.${NC}"; \
		echo "${YELLOW}Em Arch Linux, você pode instalar via:${NC}"; \
		echo "  sudo pacman -S --needed ruby ruby-rdoc"; \
		echo "  sudo gem install --no-document fpm"; \
		echo "${YELLOW}Ou via AUR: ruby-fpm${NC}"; \
	fi

# Prepara diretório staging com binário e recursos
package-prep: release packaging-clean
	@echo "${BLUE}📁 Preparando diretório staging para empacotamento...${NC}"
	@mkdir -p $(PKGROOT)/usr/bin
	@mkdir -p $(PKGROOT)/usr/share/$(PROJECT_NAME)/assets
	@mkdir -p $(PKGROOT)/usr/share/$(PROJECT_NAME)/ui
	@install -m 0755 target/release/$(PROJECT_NAME) $(PKGROOT)/usr/bin/$(PROJECT_NAME)
	@# Copia recursos (se existirem)
	@if [ -d assets ]; then cp -a assets/. $(PKGROOT)/usr/share/$(PROJECT_NAME)/assets/; fi
	@if [ -d ui ]; then cp -a ui/. $(PKGROOT)/usr/share/$(PROJECT_NAME)/ui/; fi
	@echo "${GREEN}✅ Staging pronto em $(PKGROOT)${NC}"

# Gera pacote .deb usando fpm
package-deb: package-prep
	@echo "${BLUE}📦 Gerando pacote .deb (Debian/Ubuntu)...${NC}"
	@if ! command -v fpm >/dev/null 2>&1; then \
		echo "${RED}❌ fpm não está instalado. Execute: make install-packaging-deps${NC}"; \
		exit 1; \
	fi
	@mkdir -p $(DEB_OUT)
	@fpm -s dir -t deb \
		-n $(PROJECT_NAME) \
		-v $(VERSION) \
		-a $(DEB_ARCH) \
		--description "Calculator (Rust + Slint)" \
		--license "MIT" \
		--url "https://github.com/marcos2872/calculator" \
		--maintainer "Marcos" \
		--deb-compression xz \
		--prefix / \
		-C $(PKGROOT) \
		-p $(DEB_OUT)/
	@echo "${GREEN}✅ Pacote .deb gerado em $(DEB_OUT)${NC}"

# Gera pacote .rpm usando fpm
package-rpm: package-prep
	@echo "${BLUE}📦 Gerando pacote .rpm (Fedora/RHEL/openSUSE)...${NC}"
	@if ! command -v fpm >/dev/null 2>&1; then \
		echo "${RED}❌ fpm não está instalado. Execute: make install-packaging-deps${NC}"; \
		exit 1; \
	fi
	@mkdir -p $(RPM_OUT)
	@fpm -s dir -t rpm \
		-n $(PROJECT_NAME) \
		-v $(VERSION) \
		-a $(RPM_ARCH) \
		--description "Calculator (Rust + Slint)" \
		--license "MIT" \
		--url "https://github.com/marcos2872/calculator" \
		--maintainer "Marcos" \
		--prefix / \
		-C $(PKGROOT) \
		-p $(RPM_OUT)/
	@echo "${GREEN}✅ Pacote .rpm gerado em $(RPM_OUT)${NC}"

# Gera ambos os pacotes
packages: package-deb package-rpm
	@echo "${GREEN}🎉 Pacotes gerados em $(DIST_DIR): .deb e .rpm${NC}"

# Gera pacote Arch Linux usando fpm (formato pacman)
package-arch: package-prep
	@echo "${BLUE}📦 Gerando pacote Arch Linux (.pkg.tar.*) via fpm...${NC}"
	@if ! command -v fpm >/dev/null 2>&1; then \
		echo "${RED}❌ fpm não está instalado. Execute: make install-packaging-deps${NC}"; \
		exit 1; \
	fi
	@mkdir -p $(ARCH_OUT)
	@fpm -s dir -t pacman \
		-n $(PROJECT_NAME) \
		-v $(VERSION) \
		-a $(ARCH) \
		--description "Calculator (Rust + Slint)" \
		--license "MIT" \
		--url "https://github.com/marcos2872/calculator" \
		--maintainer "Marcos" \
		--prefix / \
		-C $(PKGROOT) \
		-p $(ARCH_OUT)/
	@echo "${GREEN}✅ Pacote Arch gerado em $(ARCH_OUT)${NC}"

# Gera todos os pacotes, incluindo Arch
packages: package-arch

# Gera pacote Arch usando PKGBUILD + makepkg (método nativo do Arch Linux)
package-arch-pkgbuild: release
	@echo "${BLUE}📦 Gerando pacote Arch Linux usando PKGBUILD + makepkg...${NC}"
	@if ! command -v makepkg >/dev/null 2>&1; then \
		echo "${RED}❌ makepkg não está instalado (instale pacman/base-devel)${NC}"; \
		exit 1; \
	fi
	@echo "${YELLOW}📁 Preparando tarball de fontes...${NC}"
	@mkdir -p $(DIST_DIR)/arch-pkgbuild
	@# Cria tarball temporário com os fontes
	@tar --exclude='target' --exclude='dist' --exclude='.git' \
		-czf $(DIST_DIR)/arch-pkgbuild/$(PROJECT_NAME)-$(VERSION).tar.gz \
		-C .. $(notdir $(CURDIR))
	@# Copia o PKGBUILD para o diretório de build
	@cp packaging/arch/PKGBUILD $(DIST_DIR)/arch-pkgbuild/
	@echo "${YELLOW}🔨 Executando makepkg...${NC}"
	@cd $(DIST_DIR)/arch-pkgbuild && \
		PKGEXT='.pkg.tar.zst' makepkg -f --skipinteg
	@echo "${GREEN}✅ Pacote Arch (PKGBUILD) gerado em $(DIST_DIR)/arch-pkgbuild/${NC}"
	@echo "${YELLOW}💡 Para instalar: sudo pacman -U $(DIST_DIR)/arch-pkgbuild/$(PROJECT_NAME)-$(VERSION)-1-*.pkg.tar.zst${NC}"

# Limpa somente artefatos de empacotamento
packaging-clean:
	@rm -rf $(DIST_DIR)
	@mkdir -p $(DIST_DIR)