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

- `make run` - Executa a aplicação
- `make watch` - Execução com hot reload (recompila automaticamente)
- `make build` - Compila em modo debug
- `make release` - Compila em modo release otimizado
- `make clean` - Remove arquivos de build
- `make test` - Executa testes
- `make fmt` - Formata o código
- `make clippy` - Executa o linter
- `make install-deps` - Instala dependências de desenvolvimento
- `make help` - Mostra todos os comandos disponíveis

## 📁 Estrutura do Projeto

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

- **slint**: Framework UI principal (versão 1.14.1)
- **slint-build**: Ferramentas de build para desenvolvimento (versão 1.14.1)

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
