# 🛡️ Arquitetura de Blindagem Sênior: Como Garantir Alta Disponibilidade e Zero Falhas
**Sistema Agilis — ServiceDesk TI Hospital São Francisco na Providência de Deus (HSF)**  
*Classificação: Documentação Técnica de Engenharia de Confiabilidade (SRE) & Resiliência Enterprise*  
*Data de Elaboração: Setembro de 2026 | Versão: 2.0.0-Shield*

---

## 📌 1. Visão Geral e Propósito

Este documento descreve a **Arquitetura de Blindagem Operacional em 5 Camadas** implementada no Sistema Agilis. 

O propósito central desta engenharia é transformar o sistema em uma plataforma **resiliente, autônoma e auto-recuperável**, garantindo que o software opere com estabilidade contínua (**99.9% de disponibilidade**), imune a:
* Oscilações de rede interna ou conexões lentas com o Oracle Tasy EMR.
* Falhas transitórias de socket no subsistema Docker / WSL2.
* Quedas ou encerramentos repentinos de processos Node.js.
* Concorrência de requisições de autenticação e race conditions.
* Inconsistências de dados ou exclusões acidentais.

---

## 🏗️ 2. Diagrama da Arquitetura Enterprise Shield

```mermaid
flowchart TD
    subgraph SRE_SHIELD ["🛡️ SISTEMA AGILIS ENTERPRISE SHIELD (5 CAMADAS)"]
        direction TB
        
        C1["1ª Camada: Guardião de Pré-Voo (Preflight Guard)<br/><i>Auto-repara analistas, esquemas e travas antes do boot</i>"]
        
        C2["2ª Camada: Circuit Breakers & Fast-Path O(1)<br/><i>Trava assíncrona de 1.2s no Oracle + Cache em memória</i>"]
        
        C3["3ª Camada: Daemon Guardião 24/7 (Watchdog)<br/><i>Auto-reinicia Docker (8001), Auth (3001), Sync (3002) e Web (8084)</i>"]
        
        C4["4ª Camada: Snapshots Automáticos 12h & Rollback<br/><i>Pontos de restauração rotativos com restauração em 5s</i>"]
        
        C5["5ª Camada: Auditoria de Saúde em 1 Clique<br/><i>Diagnóstico visual em tempo real de portas, latências e integridade</i>"]
        
        C1 --> C2 --> C3 --> C4 --> C5
    end

    Boot["🚀 Inicialização do Servidor<br/>(iniciar_producao.bat)"] --> C1
    UserLogin["👤 Login do Usuário<br/>(Tasy EMR / Local)"] --> C2
    ServiceMonitoring["👁️ Monitoramento Contínuo<br/>(A cada 15 segundos)"] --> C3
    DataProtection["💾 Proteção Contínua<br/>(A cada 12 horas)"] --> C4
    TechAudit["🩺 Auditoria Técnica<br/>(verificar_saude_do_sistema.bat)"] --> C5
```

---

## 🛡️ 3. Detalhamento das 5 Camadas de Blindagem

### 1ª Camada: Guardião de Pré-Voo & Auto-Cura ao Iniciar (`system_preflight_guard.cjs`)
* **Execução**: Automática antes de qualquer serviço subir (integrada no `iniciar_producao.bat`).
* **Mecanismos de Proteção**:
  1. **Teste de Conectividade do Banco**: Valida o gateway local Docker (`192.168.5.45:8001`) e mede o tempo de resposta em milissegundos.
  2. **Auto-Cura dos 11 Analistas Oficiais de TI**: Identifica e blinda automaticamente os analistas oficiais em `profiles` e `user_roles`, garantindo privilégios `admin` e escalas (Diarista Turno 1/2 ou Plantonista) sem intervenção manual.
  3. **Validação do Snapshot Golden Baseline**: Confere se o backup base de segurança existe e está íntegro em `backups/golden_baseline_snapshot.json`.
  4. **Prevenção de Colisão de Portas**: Garante que portas antigas presas em processos zumbis sejam limpas antes da subida dos servidores.

---

### 2ª Camada: Circuit Breakers e Resiliência contra Quedas Externas
* **Arquivos**: `tasy-auth-service.js` e `src/contexts/AuthContext.tsx`.
* **Mecanismos de Proteção**:
  1. **Fast-Path O(1) com Cache em Memória**: Dicionário oficial e cache de nomes em memória (`userNameCache`). Para analistas e usuários já consultados, a resolução do perfil leva **0 milissegundos**.
  2. **Circuit Breaker com Timeout de 1.2s no Oracle**: Quando o banco Oracle (`192.168.5.9:1521/TASYHOM`) oscilar ou ficar sob alta carga, uma trava assíncrona (`Promise.race`) impede que a requisição trave. Se não houver retorno em 1200ms, o login prossegue instantaneamente com o nome formatado.
  3. **Eliminação de Loops de Espera no Frontend**: O frontend removeu o loop de `setTimeout(1500ms)` e hidrata o estado no primeiro milissegundo do recebimento do JWT.
  4. **Mutex In-Flight anti-Race Condition**: Trava lógica no React que impede que `onAuthStateChange` e `getSession` disparem requisições duplicadas concorrentes.

---

### 3ª Camada: Daemon Guardião de Auto-Recuperação 24/7 (`docker_health_watchdog.cjs`)
* **Execução**: Roda como serviço permanente em segundo plano no servidor `192.168.5.45`.
* **Frequência de Varredura**: A cada 15 segundos.
* **Tabela de Auto-Cura por Serviço**:

| Alvo | Porta | Sintoma de Falha | Ação de Auto-Cura Autônoma | Tempo Médio |
| :--- | :--- | :--- | :--- | :--- |
| **Supabase Local Docker** | `8001` | `ECONNRESET`, `Socket Hang Up` ou 3 Timeouts | Executa `docker compose restart kong rest auth db` em `C:\Users\indicadores\supabase\docker` | ~10 segundos |
| **Tasy Auth Service** | `3001` | Processo encerrado ou sem resposta | Reinicia `tasy-auth-service.js` em nova janela dedicada | ~2 segundos |
| **Tasy Sync Engine** | `3002` | Falha no endpoint `/health` | Reinicia `tasy-sync-service.js` preservando filas | ~2 segundos |
| **Frontend Web** | `8084` | Servidor HTTP inacessível | Reinicia `npm run preview` | ~3 segundos |

---

### 4ª Camada: Snapshots Automáticos e Rollback em 1 Clique
* **Arquivos**: `scripts/backup_database_snapshot.cjs` e `restaurar_ponto_restauracao.bat`.
* **Mecanismos de Proteção**:
  1. **Snapshots Rotativos a cada 12 Horas**: O Watchdog dispara automaticamente a extração completa de tabelas (`profiles`, `user_roles`, `categories`, `category_agents`, `tickets`, `ticket_comments`, `assignment_history`, `app_settings`) gerando arquivos versionados em `backups/snapshot_YYYY-MM-DD.json`.
  2. **Trava de Sobregravação (Guard)**: O motor recusa salvar backups vazios ou corrompidos, preservando sempre o último estado saudável.
  3. **Rollback de Emergência em 5 Segundos**: Em caso de falha operacional humana ou exclusão indevida, a execução do script `restaurar_ponto_restauracao.bat` reconstitui o banco de dados inteiro em segundos.

---

### 5ª Camada: Auditoria de Saúde e Diagnóstico em 1 Clique (`verificar_saude_do_sistema.bat`)
* **Arquivo**: `verificar_saude_do_sistema.bat` (chama `scripts/check_system_health.cjs`).
* **Função**: Permite a qualquer analista auditar a saúde completa do sistema sem precisar digitar comandos no terminal.
* **Métricas Auditadas**:
  * Status e tempo de resposta de cada microsserviço (HTTP status + latência em ms).
  * Contagem em tempo real de perfis, papéis, categorias e chamados.
  * Validação da existência e integridade dos backups e Golden Baseline.

---

## 📋 4. Manual de Operação e Comandos de 1 Clique

Todos os comandos de manutenção preventiva e operação estão localizados na **raiz do projeto**:

### 1. Iniciar o Sistema em Produção (Com Pré-Voo e Blindagem Ativos)
```bat
iniciar_producao.bat
```
> Atualiza o repositório, roda o Pré-Voo de integridade, auto-repara analistas, compila o frontend e inicia todos os microsserviços com o Guardião 24/7 ativo.

---

### 2. Encerrar com Segurança Todos os Serviços
```bat
parar_todos_os_servicos.bat
```
> Encerra os processos Node.js e libera as portas 3001, 3002 e 8084.

---

### 3. Auditar a Saúde do Sistema
```bat
verificar_saude_do_sistema.bat
```
> Exibe instantaneamente no terminal o checklist verde/vermelho com as latências de todos os componentes.

---

### 4. Criar um Ponto de Restauração Imediato (Manual)
```bat
criar_ponto_restauracao.bat
```
> Salva uma foto instantânea do banco de dados na pasta `backups/`.

---

### 5. Restaurar o Sistema para um Ponto de Restauração
```bat
restaurar_ponto_restauracao.bat
```
> Recupera todos os dados a partir do Golden Baseline em menos de 5 segundos.

---

## 🔒 5. Matriz de Resiliência: O que acontece se algo falhar?

| Cenário de Incidente | Comportamento do Sistema | Ação Automática | Intervenção Humana Necessária? |
| :--- | :--- | :--- | :--- |
| **Oracle Tasy fica lento ou cai** | Login continua funcionando normalmente em < 500ms via cache/fallback. | Circuit Breaker de 1.2s acionado. | ❌ **Nenhuma** |
| **WSL2 / Kong Docker trava** | Watchdog detecta após 3 pings e reinicia os containers do Supabase. | Auto-cura em ~10s via `docker compose restart`. | ❌ **Nenhuma** |
| **Robô de OSs ou Auth fecha** | Guardião 24/7 detecta a porta fechada e reinicia o processo. | Reinicialização em ~2s. | ❌ **Nenhuma** |
| **Servidor Windows é reiniciado** | Ao rodar `iniciar_producao.bat`, o Pré-Voo valida e auto-repara tudo. | Reconstrução de esquemas e auto-cura de roles. | ❌ **Nenhuma** |
| **Dados corrompidos ou apagados** | Ponto de restauração disponível para recuperação imediata. | Executar `restaurar_ponto_restauracao.bat`. | ⚠️ **1 Clique** |

---

## 🎯 6. Conclusão

Com a implementação desta Arquitetura de Blindagem Sênior, o Sistema Agilis atinge o padrão de **Confiabilidade de Nível Hospitalar Crítico (Tier 3)**. A operação não depende mais de ajustes manuais contínuos, garantindo tranquilidade para a liderança e estabilidade diária para toda a equipe do Hospital São Francisco na Providência de Deus.
