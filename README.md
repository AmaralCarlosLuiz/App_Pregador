# Pregador Pro 📖✨

> Plataforma Multiplataforma de Apoio e Criação de Sermões para Pastores e Ministros do Evangelho.

O **Pregador Pro** é um aplicativo construído em **Flutter (Dart 3+)** com arquitetura limpa e UI adaptativa para rodar com alta fidelidade visual e performance nativa em:
- 📱 **Smartphones (Android / iOS)**
- 📲 **Tablets / iPads** (Layout expandido e Master-Detail Flow em modo paisagem)
- 💻 **Web & Desktop (Windows, macOS, Linux)**

---

## 🏗️ Arquitetura & Stack Tecnológica

| Camada | Tecnologia / Padrão |
| :--- | :--- |
| **Framework** | Flutter (Dart 3+) |
| **Gerenciamento de Estado** | Flutter Riverpod 2.x (`StateNotifier`, `ProviderScope`) |
| **Design System** | Material 3 com temas Claro, Escuro e Modo Púlpito (OLED Preto Puro) |
| **Responsividade** | `AdaptiveScaffold` (NavigationBar em mobile, NavigationRail em tablet e Sidebar em desktop) |
| **Backend / BaaS** | Supabase Flutter SDK (Auth, PostgreSQL, Row Level Security) |
| **Offline-First** | Cache local persistente (`SharedPreferences` / fallback resiliente) |
| **Hardware & Púlpito** | `wakelock_plus` (mantém tela 100% ativa no púlpito) |
| **Renderização & Exportação** | `flutter_markdown`, `pdf`, `printing`, `share_plus` |

---

## 📂 Estrutura de Diretórios

```
lib/
├── core/
│   ├── constants/            # Cores teológicas, livros bíblicos e categorias
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── network/              # Conexão e inicialização resiliente do Supabase
│   │   └── supabase_config.dart
│   ├── responsive/           # Breakpoints (Mobile, Tablet, Desktop) e AdaptiveScaffold
│   │   ├── breakpoints.dart
│   │   └── adaptive_scaffold.dart
│   ├── services/             # IA Homilética, exportação de PDF A4 e Wakelock
│   │   ├── ai_homiletics_service.dart
│   │   ├── pdf_export_service.dart
│   │   └── pulpit_wakelock_service.dart
│   ├── storage/              # Cache local para leitura offline
│   │   └── offline_cache_service.dart
│   └── theme/                # Temas Claro, Escuro e Púlpito Alto Contraste
│       └── app_theme.dart
├── models/                   # Modelos de Dados (Sermão, Blocos Homiléticos, Modelos, Perfil)
│   ├── sermon_block.dart
│   ├── sermon_model.dart
│   ├── sermon_template_model.dart
│   └── user_profile_model.dart
├── repositories/             # Repositórios (Sermões e Autenticação com sincronização)
│   ├── auth_repository.dart
│   └── sermon_repository.dart
├── providers/                # Providers do Riverpod
│   ├── ai_assistant_provider.dart
│   ├── auth_provider.dart
│   ├── pulpit_mode_provider.dart
│   ├── sermon_editor_provider.dart
│   ├── sermon_provider.dart
│   ├── templates_provider.dart
│   └── theme_provider.dart
└── presentation/
    ├── ai_assistant/         # Painel IA com Esboços, Ilustrações e Grego/Hebraico
    │   └── ai_assistant_sheet.dart
    ├── dashboard/            # Dashboard principal com métricas e sermões recentes
    │   ├── dashboard_screen.dart
    │   └── widgets/
    ├── editor/               # Editor modular de sermões homiléticos
    │   ├── sermon_editor_screen.dart
    │   └── widgets/
    ├── library/              # Biblioteca com Master-Detail Flow e busca instantânea
    │   └── sermon_library_screen.dart
    ├── navigation/           # Shell adaptativo de navegação
    │   └── adaptive_navigation_shell.dart
    ├── profile/              # Perfil pastoral e configurações
    │   └── profile_screen.dart
    ├── pulpit/               # Modo Púlpito com tela imersiva, timer e zoom de fonte
    │   ├── pulpit_mode_screen.dart
    │   └── widgets/
    └── templates/            # Acervo de modelos prontos
        └── sermon_templates_screen.dart
```

---

## ⚡ Módulos e Funcionalidades Principais

### 1. Arquitetura Adaptativa de Navegação
- **Smartphones (< 600px)**: `NavigationBar` inferior intuitiva com 4 destinos principais.
- **Tablets (600px - 1024px)**: `NavigationRail` à esquerda com ícones e labels compactos.
- **Desktop / Web (> 1024px)**: `Sidebar` permanente à esquerda com identidade visual, nome do pastor e navegação rápida.
- **Master-Detail Flow**: Em tablets no modo paisagem e computadores desktop, a biblioteca divide a tela entre a lista de sermões à esquerda (380px) e a leitura/prévia em tempo real à direita.

### 2. Dashboard Principal
- Resumo com métricas rápidas: Total de sermões, pregações ministradas, sermões prontos para o púlpito e favoritos.
- Ações rápidas: "+ Novo Sermão", "✨ Gerar com IA" e "📋 Acervo de Modelos".
- Sermões recentes com atalho de edição rápida e início direto no púlpito.

### 3. Editor de Sermões Estruturado (Sermon Builder)
- Formulário modular em blocos temáticos homiléticos:
  - Título e Tema
  - Seletor Bíblico Inteligente com livros do Antigo e Novo Testamento
  - Introdução
  - Pontos Principais dinâmicos (Título, Versículo, Explanação Teológica, Ilustração Prática, Aplicação para a Vida)
  - Conclusão e Apelo
- **Salvamento automático com debounce** (1.2s) garantindo persistência local e sincronização assíncrona com Supabase.
- **Exportação para PDF A4** pronta para impressão ou compartilhamento.

### 4. Modo Púlpito Especial (Imersão Total)
- Oculta completamente barra de status do sistema e navegação para evitar qualquer distração visual no palco.
- **Prevenção de bloqueio de tela** nativa via `wakelock_plus`.
- **Controles de Acessibilidade Flutuantes**: Botões `A-` e `A+` para aumentar/diminuir o tamanho da fonte em tempo real (16px a 38px).
- **Alto Contraste OLED**: Fundo preto puro (`#000000`) e opção de tom âmbar noturno para proteger a visão sob refletores de palco.
- **Cronômetro Duplo**: Modos Progressivo (cronômetro) e Regressivo (contagem decrescente baseada na duração estimada), com alerta visual vermelho piscante em caso de tempo estourado.
- Opção de registrar a ministração concluída para alimentar as estatísticas do pastor.

### 5. Assistente de IA para Homilética
- **Gerador de Esboço**: Parâmetros de entrada (Tema, Texto Bíblico, Tipo de Sermão: Expositivo / Temático / Textual) e botão para importar o esboço diretamente para o formulário de edição.
- **Sugestão de Ilustrações Práticas**: Gera analogias cotidianas para fixar o ponto homilético.
- **Contextualização e Exegese**: Análise léxica de termos em Grego e Hebraico com numeração de Strong e aplicação teológica.

### 6. Biblioteca & Acervo
- Busca instantânea e filtros rápidos por Categoria (Família, Fé, Cura, Evangelismo, etc.) e status.
- Resiliência total offline (leitura e edição garantidas mesmo sem acesso à internet no púlpito).

### 7. 🛡️ Blindagem Enterprise, Circuit Breakers & Restauração
- **Auditoria de Saúde em 1 Clique**: Diagnóstico instantâneo em tempo real de latência com a nuvem, integridade do cache local offline e hardware de tela (Wakelock).
- **Circuit Breakers & Timeouts**: Trava assíncrona de 3.5s / 4.0s para que oscilações de internet nunca congelem o aplicativo no púlpito.
- **Ponto de Restauração (Backup & Rollback em 1 Clique)**: Exportação de snapshot completo em JSON de todos os sermões (compartilhável por Drive, iCloud, WhatsApp) e restauração instantânea com validação de integridade.

---

## 🗄️ Modelagem de Dados Supabase (PostgreSQL)

O script SQL de migração está disponível em:
[`supabase/migrations/20261012_init_pregador_pro.sql`](file:///d:/Arquivos%20PESSOAIS/Projetos%20DEV/App%20Pregador/supabase/migrations/20261012_init_pregador_pro.sql)

Para aplicar:
1. Acesse o console do **Supabase** -> **SQL Editor**.
2. Cole o conteúdo de `20261012_init_pregador_pro.sql` e execute.
3. Configure suas credenciais em `lib/core/network/supabase_config.dart`.
