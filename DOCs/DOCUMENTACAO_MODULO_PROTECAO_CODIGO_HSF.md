# 🛡️ Diretiva & Documentação Técnica: Módulo de Proteção de Código Fonte (Defense-in-Depth)
**Sistema Pregador Pro — Plataforma Homilética de Alta Performance**  
*Desenvolvido no âmbito: Projetos DEV TI Hospital São Francisco na Providência de Deus (HSF)*  
*Classificação: Segurança da Informação, Proteção de Ativos & Conformidade LGPD*  
*Data de Atualização: Novembro de 2026 | Versão: 2.0.0-Shield*

---

## 🎯 1. Objetivo e Conformidade
- **Propósito**: Proteger a propriedade intelectual, os algoritmos de geração homilética, a estrutura exegética de 150 modelos e o código-fonte da aplicação contra inspeção não autorizada, engenharia reversa superficial e extração indevida de dados.
- **Conformidade**: Aderência estrita às diretrizes corporativas de segurança da informação da TI do Hospital São Francisco na Providência de Deus (HSF) e conformidade com a LGPD.

---

## 🧱 2. As 5 Camadas de Proteção Implementadas

| Camada | Mecanismo | Comportamento / Efeito no Pregador Pro |
| :--- | :--- | :--- |
| **1. Menu de Contexto** | `contextmenu` (Botão Direito) | Bloqueia o clique direito fora de áreas editáveis, disparando Toast institucional de aviso. **Permite interação natural em campos de texto (`input`, `textarea`), elementos com `contenteditable` e áreas de leitura bíblica**. |
| **2. Atalhos de Desenvolvedor** | `keydown` (Captura Global) | Bloqueia `F12`, `Ctrl+Shift+I`, `Ctrl+Shift+J`, `Ctrl+Shift+C`, `Ctrl+U` (Exibir Código Fonte), `Ctrl+S` (Salvar Página HTML) e variantes de macOS (`Cmd+Opt+I/J/C/U/S`). Exibe Toast de *Acesso Restrito*. |
| **3. Proteção de Ativos** | `dragstart` | Bloqueia arrastar e soltar (drag & drop) de ícones, ilustrações, marcas e vetores SVG (`<img>`, `<video>`, `<svg>`). |
| **4. Armadilha Anti-Debugger** | Loop `new Function("debugger")` | Disparado a cada 2.0s. Caso um usuário tente forçar a abertura de ferramentas de depuração do navegador, a aba *Sources* entra em pausa automática de execução. |
| **5. Sanitização de Console** | Override de Métodos `console.*` | Limpa o console de desenvolvimento e exibe o banner oficial de segurança institucional HSF, neutralizando métodos verbosos (`log`, `debug`, `dir`, `table`) para evitar vazamento de dados homiléticos ou tokens sensíveis. |

---

## 💻 3. Código-Fonte Oficial Implementado (`sourceProtection.js`)

O módulo foi implementado em `webapp/sourceProtection.js` e carregado de forma modular e assíncrona no `webapp/index.html`:

```javascript
/**
 * 🛡️ Módulo de Trava de Segurança e Proteção do Código Fonte (Defense-in-Depth)
 * Hospital São Francisco (TI HSF) - Aplicado ao Pregador Pro
 */

(function () {
  'use strict';

  const DEFAULT_CONFIG = {
    blockRightClick: true,
    blockDevToolsShortcuts: true,
    blockSelect: false, // Preserva seleção natural para pregação e leitura bíblica
    blockDragAndDrop: true,
    showConsoleWarning: true,
    enableAntiDebugger: true,
    enableConsoleSanitize: true,
  };

  let initialized = false;
  let antiDebuggerInterval = null;

  function showSecurityToast(title, description, type = 'warning') {
    if (window.showToast && typeof window.showToast === 'function') {
      window.showToast(`${title}: ${description}`, type);
      return;
    }
    const container = document.getElementById('toast-container');
    if (!container) return;
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.innerHTML = `
      <div style="font-weight: 700; font-size: 13px; margin-bottom: 2px;">🛡️ ${title}</div>
      <div style="font-size: 12px; opacity: 0.9;">${description}</div>
    `;
    container.appendChild(el);
    setTimeout(() => {
      el.style.opacity = '0';
      el.style.transform = 'translateY(8px)';
      el.style.transition = 'all 0.25s ease';
      setTimeout(() => el.remove(), 250);
    }, 3200);
  }

  function isEditableElement(target) {
    if (!target) return false;
    const tagName = target.tagName ? target.tagName.toUpperCase() : '';
    return (
      tagName === 'INPUT' ||
      tagName === 'TEXTAREA' ||
      target.isContentEditable ||
      (target.closest && target.closest('[contenteditable="true"]') !== null) ||
      (target.closest && target.closest('.allow-context-menu') !== null)
    );
  }

  function initSourceProtection(customConfig = {}) {
    if (initialized) return;
    initialized = true;

    const config = Object.assign({}, DEFAULT_CONFIG, customConfig);

    // 1. Bloqueio de Menu de Contexto
    if (config.blockRightClick) {
      document.addEventListener('contextmenu', function (e) {
        if (!isEditableElement(e.target)) {
          e.preventDefault();
          showSecurityToast(
            'Proteção de Código Ativa',
            'A inspeção e cópia do código fonte são restritas por políticas de segurança corporativa TI HSF.',
            'warning'
          );
        }
      }, { capture: true });
    }

    // 2. Bloqueio de Atalhos DevTools
    if (config.blockDevToolsShortcuts) {
      window.addEventListener('keydown', function (e) {
        const isCtrlOrCmd = e.ctrlKey || e.metaKey;
        const key = (e.key || '').toLowerCase();
        const code = e.code || '';

        const isF12 = e.keyCode === 123 || key === 'f12' || code === 'F12';
        const isCtrlU = isCtrlOrCmd && key === 'u';
        const isCtrlS = isCtrlOrCmd && key === 's';
        const isShiftF10 = e.shiftKey && (key === 'f10' || code === 'F10');
        const isInspect = (isCtrlOrCmd && e.shiftKey && (key === 'i' || key === 'j' || key === 'c')) ||
                          (e.metaKey && e.altKey && (key === 'i' || key === 'j' || key === 'c'));

        if (isF12 || isCtrlU || isCtrlS || isShiftF10 || isInspect) {
          e.preventDefault();
          e.stopPropagation();
          showSecurityToast(
            'Acesso Restrito',
            'Os atalhos de desenvolvedor e inspeção de código fonte estão desabilitados neste ambiente.',
            'error'
          );
        }
      }, { capture: true });
    }

    // 3. Bloqueio de Drag & Drop de Mídias
    if (config.blockDragAndDrop) {
      document.addEventListener('dragstart', function (e) {
        const t = e.target;
        if (t && (t.tagName === 'IMG' || t.tagName === 'VIDEO' || t.tagName === 'SVG')) {
          e.preventDefault();
        }
      });
    }

    // 4. Armadilha Anti-Debugger
    if (config.enableAntiDebugger) {
      try {
        antiDebuggerInterval = window.setInterval(function () {
          try {
            const fn = new Function('debugger');
            fn();
          } catch (_) {}
        }, 2000);
      } catch (_) {}
    }

    // 5. Sanitização de Console & Banner Institucional
    if (config.showConsoleWarning) {
      try {
        console.clear();
        console.log(
          '%c 🛡️ SEGURANÇA ENTERPRISE ATIVADA — SISTEMA TI HSF | PREGADOR PRO ',
          'background: #dc2626; color: #ffffff; font-size: 14px; font-weight: bold; padding: 6px 12px; border-radius: 6px;'
        );
        console.log(
          '%c ⚠️ ATENÇÃO: Esta é uma aplicação com propriedade intelectual protegida pela Diretiva de Segurança TI HSF.\nA inspeção indevida ou extração de código fonte viola as diretrizes de conformidade, segurança da informação e LGPD.',
          'color: #f59e0b; font-size: 11px; font-weight: 500; margin-top: 4px;'
        );
        if (config.enableConsoleSanitize) {
          const noop = function () {};
          console.log = noop;
          console.debug = noop;
          console.dir = noop;
          console.table = noop;
        }
      } catch (_) {}
    }
  }

  initSourceProtection();
  window.initSourceProtection = initSourceProtection;
})();
```

---

## ⚙️ 4. Preservação da Usabilidade Pastoral
O módulo foi cuidadosamente balanceado para **não prejudicar** a experiência pastoral e ministerial:
1. **Digitação e Edição Liberadas**: Nos campos de título, texto bíblico e anotações, a seleção de texto e o menu de colar/recortar do teclado funcionam perfeitamente.
2. **Leitura Bíblica Fluida**: A seleção de versículos para estudo ou citação continua permitida.
3. **Impressão Oficial A4**: A geração de PDF / impressão pelo botão oficial da bancada homilética continua 100% operacional.

---

## 🎯 5. Conclusão
O Pregador Pro passa a contar com o mesmo nível de blindagem e proteção contra inspeção e clonagem adotado nas aplicações web corporativas da TI do Hospital São Francisco na Providência de Deus (HSF).
