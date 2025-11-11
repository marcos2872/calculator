# Calculator - Calculadora Desktop em Rust + Slint

Uma aplicação desktop de calculadora moderna desenvolvida em Rust usando o framework UI Slint.

![Screenshot](images/1.png)

## 📋 Sobre o Projeto

Este é um projeto de calculadora desktop que demonstra como criar aplicações modernas usando Rust e Slint. A aplicação apresenta uma interface gráfica limpa inspirada em calculadoras iOS/Android, com design escuro e botões responsivos.

## ✨ Funcionalidades

- **Operações básicas**: Adição, subtração, multiplicação e divisão
- **Interface moderna**: Design escuro com botões coloridos e responsivos
- **Layout GridLayout**: Organização eficiente dos botões usando grid
- **Componentes customizados**: Botões personalizados com cores configuráveis
- **Janela personalizada**: Tamanho fixo otimizado (500x700px)
- **Ícone personalizado**: Logo próprio da aplicação
- **Empacotamento multiplataforma**: Suporte para .deb, .rpm e Arch Linux

## 🚀 Tecnologias Utilizadas

- **[Rust](https://www.rust-lang.org/)** - Linguagem de programação principal
- **[Slint](https://slint.rs/)** - Framework UI para aplicações desktop
- **Cargo** - Sistema de build e gerenciador de pacotes do Rust

## 📦 Pré-requisitos

Para executar este projeto, você precisa ter instalado:

- [Rust](https://rustup.rs/) (versão mais recente)
- [Cargo](https://doc.rust-lang.org/cargo/) (vem com o Rust)

## 🔧 Instalação e Execução

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/marcos2872/calculator.git
   cd calculator
   ```

2. **Usando Makefile (Recomendado):**

   ```bash
   # Ver todos os comandos disponíveis
   make help

   # Executar a aplicação
   make run

   # Desenvolvimento com hot reload
   make watch

   # Build de release
   make release
   ```

3. **Usando Cargo diretamente:**

   ```bash
   # Executar em modo debug
   cargo run

   # Build de release
   cargo build --release
   ```

### 📋 Comandos do Makefile

#### Desenvolvimento

- `make run` - Executa a aplicação
- `make watch` - Execução com hot reload (recompila automaticamente)
- `make build` - Compila em modo debug
- `make release` - Compila em modo release otimizado
- `make clean` - Remove arquivos de build
- `make test` - Executa testes
- `make fmt` - Formata o código
- `make clippy` - Executa o linter
- `make install-deps` - Instala dependências de desenvolvimento

#### Empacotamento

- `make install-packaging-deps` - Instala ferramentas para empacotamento (fpm)
- `make package-deb` - Gera pacote .deb (Debian/Ubuntu)
- `make package-rpm` - Gera pacote .rpm (Fedora/RHEL/openSUSE)
- `make package-arch` - Gera pacote Arch Linux (.pkg.tar.zst) via fpm
- `make package-arch-pkgbuild` - Gera pacote Arch usando PKGBUILD + makepkg (método nativo)
- `make packages` - Gera todos os pacotes (.deb, .rpm e Arch)
- `make packaging-clean` - Limpa artefatos de empacotamento

#### Outros

- `make help` - Mostra todos os comandos disponíveis
- `make info` - Mostra informações do projeto e estatísticas de código

## � Distribuição e Empacotamento

Este projeto suporta geração de pacotes para múltiplas distribuições Linux:

### 🔧 Pré-requisitos para Empacotamento

#### Para .deb, .rpm e Arch (via fpm)

1. **Instalar Ruby e fpm:**

   ```bash
   # No Arch Linux
   sudo pacman -S --needed ruby ruby-rdoc
   gem install --no-document fpm

   # Adicione ao PATH (adicione ao ~/.bashrc para tornar permanente)
   export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"
   ```

   Ou instale via AUR:

   ```bash
   yay -S ruby-fpm
   ```

2. **Verificar instalação:**

   ```bash
   make install-packaging-deps
   ```

#### Para Arch Linux (via PKGBUILD - método nativo)

```bash
# No Arch Linux (já vem instalado na maioria dos casos)
sudo pacman -S base-devel
```

### 📦 Gerando Pacotes

#### Pacote Debian (.deb)

```bash
make package-deb
```

**Instalação:**

```bash
sudo dpkg -i dist/deb/calculator_0.1.0_amd64.deb
# Ou
sudo apt install ./dist/deb/calculator_0.1.0_amd64.deb
```

#### Pacote RPM (.rpm)

```bash
make package-rpm
```

**Instalação:**

```bash
# Fedora/RHEL
sudo dnf install dist/rpm/calculator-0.1.0-1.x86_64.rpm
# openSUSE
sudo zypper install dist/rpm/calculator-0.1.0-1.x86_64.rpm
```

#### Pacote Arch Linux - Método 1 (via fpm, rápido)

```bash
make package-arch
```

**Instalação:**

```bash
sudo pacman -U dist/arch/calculator-0.1.0-1-x86_64.pkg.tar.zst
```

#### Pacote Arch Linux - Método 2 (via PKGBUILD, recomendado)

```bash
make package-arch-pkgbuild
```

**Instalação:**

```bash
sudo pacman -U dist/arch-pkgbuild/calculator-0.1.0-1-x86_64.pkg.tar.zst
```

**Nota:** O método PKGBUILD é o recomendado para Arch Linux pois:

- É o método oficial do Arch
- Perfeito para publicação no AUR
- Valida dependências corretamente
- Usa checksums e metadados padrão do Arch

#### Gerar Todos os Pacotes

```bash
make packages
```

Isso gera .deb, .rpm e pacote Arch de uma só vez.

### 📂 Estrutura dos Pacotes

Os pacotes instalam os seguintes arquivos:

```
/usr/bin/calculator                    # Binário executável
/usr/share/calculator/assets/          # Recursos da aplicação
/usr/share/calculator/ui/              # Arquivos de interface
/usr/share/licenses/calculator/LICENSE # Licença (somente PKGBUILD)
/usr/share/doc/calculator/README.md    # Documentação (somente PKGBUILD)
```

### 🌐 Publicar no AUR (Arch User Repository)

Se você deseja compartilhar com a comunidade Arch:

1. **Crie conta no AUR:** https://aur.archlinux.org
2. **Configure SSH keys**
3. **Clone o repositório AUR:**
   ```bash
   git clone ssh://aur@aur.archlinux.org/calculator.git aur-calculator
   cd aur-calculator
   ```
4. **Copie o PKGBUILD:**
   ```bash
   cp ../packaging/arch/PKGBUILD .
   ```
5. **Gere checksums e metadata:**
   ```bash
   updpkgsums
   makepkg --printsrcinfo > .SRCINFO
   ```
6. **Publique:**
   ```bash
   git add PKGBUILD .SRCINFO
   git commit -m "Initial commit: Calculator v0.1.0"
   git push
   ```

### 🧹 Limpar Artefatos de Empacotamento

```bash
make packaging-clean
```

## �📁 Estrutura do Projeto

```
calculator/
├── src/
│   └── main.rs                    # Código principal da aplicação
├── ui/
│   ├── app.slint                  # Interface principal em Slint
│   └── components/
│       └── button.slint           # Componente customizado de botão
├── assets/
│   └── logo.png                   # Ícone da aplicação
├── images/
│   └── 1.png                      # Screenshot da aplicação
├── packaging/
│   └── arch/
│       └── PKGBUILD               # Script de empacotamento para Arch Linux
├── build.rs                       # Script de build do Slint
├── Cargo.toml                     # Configuração do projeto Rust
├── Makefile                       # Comandos de build e desenvolvimento
└── README.md                      # Este arquivo
```

## 🎯 Como Usar

1. Execute a aplicação usando `make run` ou `cargo run`
2. A janela da calculadora será aberta
3. Clique nos botões numéricos (0-9) para inserir números
4. Use os operadores (+, -, x, ÷) para realizar cálculos
5. Pressione "=" para obter o resultado
6. Use "C" para limpar a calculadora
7. Feche a aplicação usando os controles da janela

### 🔄 Desenvolvimento com Hot Reload

Para desenvolvimento ágil, use o comando watch que recompila automaticamente:

```bash
make watch
```

Isso iniciará a aplicação e a recompilará sempre que você modificar arquivos `.rs` ou `.slint`.

## 🛠️ Desenvolvimento

### Modificando a Interface

A interface está definida no arquivo `ui/app.slint`. Você pode:

- Alterar cores dos botões (propriedade `bg_color`)
- Modificar o layout usando GridLayout
- Adicionar novos botões e operações
- Customizar o design do componente CalcButton em `ui/components/button.slint`

### Modificando a Lógica

O código principal está em `src/main.rs`. Aqui você pode:

- Implementar a lógica de cálculo
- Adicionar callbacks para os botões
- Gerenciar o estado da calculadora
- Implementar histórico de operações

### Build Personalizado

O arquivo `build.rs` configura como o Slint compila os arquivos de UI. Normalmente não precisa ser modificado.

## 📝 Dependências

### Dependências do Projeto

- **slint**: Framework UI principal (versão 1.14.1)
- **slint-build**: Ferramentas de build para desenvolvimento (versão 1.14.1)

### Dependências de Runtime (para pacotes)

Os pacotes gerados declaram as seguintes dependências:

**Debian/Ubuntu (.deb):**

- libxcb1, libx11-6, fontconfig, libxkbcommon0 (detectadas automaticamente pelo sistema)

**Arch Linux:**

- gcc-libs
- fontconfig
- libxkbcommon

**Fedora/RHEL/openSUSE (.rpm):**

- libxcb, libX11, fontconfig (detectadas automaticamente pelo sistema)

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Autor

**Marcos** - [@marcos2872](https://github.com/marcos2872)

## 🔗 Links Úteis

- [Documentação do Slint](https://slint.rs/documentation.html)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Exemplos do Slint](https://github.com/slint-ui/slint/tree/master/examples)

---

⭐ Se este projeto foi útil para você, considere dar uma estrela no repositório!
