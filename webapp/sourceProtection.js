/**
 * 🛡️ Módulo de Trava de Segurança e Proteção do Código Fonte (Defense-in-Depth)
 * Hospital São Francisco (TI HSF) - Aplicado ao Pregador Pro
 * Classificação: Segurança Enterprise & Proteção de Propriedade Intelectual
 */

(function () {
  'use strict';

  const DEFAULT_CONFIG = {
    blockRightClick: true,
    blockDevToolsShortcuts: true,
    blockSelect: false, // Preserva seleção natural em formulários e leitura bíblica
    blockDragAndDrop: true,
    showConsoleWarning: true,
    enableAntiDebugger: true,
    enableConsoleSanitize: true,
  };

  let initialized = false;
  let antiDebuggerInterval = null;

  function showSecurityToast(title, description, type = 'warning') {
    // Tenta usar a função nativa do app se disponível
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

    // 1. Bloqueio de Menu de Contexto (Botão Direito) exceto em inputs e leitura
    if (config.blockRightClick) {
      document.addEventListener(
        'contextmenu',
        function (e) {
          const target = e.target;
          if (!isEditableElement(target)) {
            e.preventDefault();
            showSecurityToast(
              'Proteção de Código Ativa',
              'A inspeção e cópia do código fonte são restritas por políticas de segurança corporativa TI HSF.',
              'warning'
            );
          }
        },
        { capture: true }
      );
    }

    // 2. Bloqueio de Atalhos de Desenvolvedor e Inspeção (Windows & macOS)
    if (config.blockDevToolsShortcuts) {
      window.addEventListener(
        'keydown',
        function (e) {
          const isCtrl = e.ctrlKey;
          const isCmd = e.metaKey;
          const isCtrlOrCmd = isCtrl || isCmd;
          const isShift = e.shiftKey;
          const isAlt = e.altKey;
          const key = (e.key || '').toLowerCase();
          const code = e.code || '';

          const isF12 = e.keyCode === 123 || key === 'f12' || code === 'F12';
          const isCtrlU = isCtrlOrCmd && key === 'u'; // Exibir Código Fonte
          const isCtrlS = isCtrlOrCmd && key === 's'; // Salvar Página Completa
          const isShiftF10 = isShift && (key === 'f10' || code === 'F10');

          // Atalhos de Inspeção DevTools
          const isInspect =
            (isCtrlOrCmd && isShift && (key === 'i' || key === 'j' || key === 'c' || key === 'k' || key === 'e')) ||
            (isCmd && isAlt && (key === 'i' || key === 'j' || key === 'c' || key === 'u' || key === 's'));

          if (isF12 || isCtrlU || isCtrlS || isShiftF10 || isInspect) {
            e.preventDefault();
            e.stopPropagation();
            showSecurityToast(
              'Acesso Restrito',
              'Os atalhos de desenvolvedor e inspeção de código fonte estão desabilitados neste ambiente.',
              'error'
            );
          }
        },
        { capture: true }
      );
    }

    // 3. Prevenção de Drag & Drop de Mídias Institucionais
    if (config.blockDragAndDrop) {
      document.addEventListener('dragstart', function (e) {
        const target = e.target;
        if (target && (target.tagName === 'IMG' || target.tagName === 'VIDEO' || target.tagName === 'SVG')) {
          e.preventDefault();
        }
      });
    }

    // 4. Armadilha Anti-Debugger em Produção
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

    // 5. Sanitização de Console & Alerta Institucional LGPD / TI HSF
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
          // Preserva warn e error para diagnósticos de rede e sanitiza logs verbosos
          console.log = noop;
          console.debug = noop;
          console.dir = noop;
          console.table = noop;
        }
      } catch (_) {}
    }
  }

  // Inicialização automática imediata ao carregar o script
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      initSourceProtection();
    });
  } else {
    initSourceProtection();
  }

  window.initSourceProtection = initSourceProtection;
})();

