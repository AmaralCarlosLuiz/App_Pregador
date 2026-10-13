# 🛡️ Diretiva & Documentação Técnica: Módulo de Proteção de Código Fonte (Defense-in-Depth)

Esta documentação detalha a implementação do **Módulo de Segurança e Trava Anti-Inspeção** padronizado para as aplicações web do **Hospital São Francisco na Providência de Deus (HSF)**.

---

## 🎯 1. Objetivo e Conformidade
- **Propósito**: Impedir a engenharia reversa superficial, inspeção não autorizada do DOM/códigos, extração indevida de mídias e cópia de regras de negócio em ambientes corporativos e hospitalares.
- **Conformidade**: Adequação a normas de segurança da informação, integridade de sistemas internos e conformidade com a LGPD.

---

## 🧱 2. As 5 Camadas de Proteção Implementadas

| Camada | Mecanismo | Comportamento / Efeito |
| :--- | :--- | :--- |
| **1. Menu de Contexto** | `contextmenu` (Botão Direito) | Bloqueia o clique direito em qualquer área da aplicação, exibindo Toast de aviso institucional. **Permite clique direito apenas em campos de texto (`input`, `textarea`) e elementos com a classe `.allow-context-menu`**. |
| **2. Atalhos de Desenvolvedor** | `keydown` (Captura Global) | Bloqueia `F12`, `Ctrl+Shift+I`, `Ctrl+Shift+J`, `Ctrl+Shift+C`, `Ctrl+U` (Exibir Código Fonte), `Ctrl+S` (Salvar Página), `Ctrl+P` (Imprimir DOM) e combinações de Mac (`Cmd+Opt+I/J/C/U/S`). Exibe Toast de *Acesso Restrito*. |
| **3. Proteção de Ativos** | `dragstart` | Bloqueia arrastar e soltar (drag & drop) de `<img>`, `<video>` e `<svg>`, protegendo marcas, monogramas e imagens institucionais. |
| **4. Anti-Debugger** | Loop `new Function("debugger")` | Disparado em modo de produção a cada 1.5s. Caso um usuário tente forçar a abertura do Developer Tools, o navegador trava o fluxo de execução na aba *Sources*. |
| **5. Sanitização de Console** | Override de Métodos `console.*` | Em produção, limpa o console e exibe um banner de segurança LGPD, anulando métodos como `console.log`, `console.debug`, `console.info`, `console.dir` e `console.table` para evitar sniffing de dados sensíveis. |

---

## 💻 3. Código Fonte Completo (`sourceProtection.ts`)

Crie o arquivo em `src/lib/sourceProtection.ts`:

```typescript
/**
 * 🔒 Módulo de Trava de Segurança e Proteção do Código Fonte
 * Hospital São Francisco (TI HSF) - Nível de Segurança Enterprise (Defense-in-Depth)
 */

import { toast } from "sonner";

export interface SourceProtectionConfig {
  blockRightClick?: boolean;
  blockDevToolsShortcuts?: boolean;
  blockSelect?: boolean;
  blockDragAndDrop?: boolean;
  showConsoleWarning?: boolean;
  enableAntiDebugger?: boolean;
  enableConsoleSanitize?: boolean;
}

const DEFAULT_CONFIG: SourceProtectionConfig = {
  blockRightClick: true,
  blockDevToolsShortcuts: true,
  blockSelect: false, // Preserva seleção em formulários
  blockDragAndDrop: true,
  showConsoleWarning: true,
  enableAntiDebugger: true,
  enableConsoleSanitize: true,
};

let initialized = false;
let antiDebuggerInterval: number | null = null;

const isProduction = (): boolean => {
  try {
    return Boolean(import.meta.env.PROD) || process.env.NODE_ENV === "production";
  } catch {
    return false;
  }
};

/**
 * Utilitário para verificar se o elemento clicado é editável (formulário)
 */
const isEditableElement = (target: HTMLElement | null): boolean => {
  if (!target) return false;
  const tagName = target.tagName.toUpperCase();
  return (
    tagName === "INPUT" ||
    tagName === "TEXTAREA" ||
    target.isContentEditable ||
    target.closest("[contenteditable='true']") !== null ||
    target.closest(".allow-context-menu") !== null
  );
};

export function initSourceProtection(config: SourceProtectionConfig = DEFAULT_CONFIG) {
  if (initialized) return;
  initialized = true;

  const activeConfig = { ...DEFAULT_CONFIG, ...config };
  const inProd = isProduction();

  // 1. Bloqueio de Menu de Contexto (Botão Direito)
  if (activeConfig.blockRightClick) {
    document.addEventListener(
      "contextmenu",
      (e: MouseEvent) => {
        const target = e.target as HTMLElement | null;
        if (!isEditableElement(target)) {
          e.preventDefault();
          toast.warning("Proteção de Código Ativa", {
            description:
              "A inspeção e cópia do código fonte do Sistema são restritas por políticas de segurança corporativa.",
            duration: 3000,
          });
        }
      },
      { capture: true }
    );
  }

  // 2. Bloqueio de Atalhos de Inspeção (Windows & macOS)
  if (activeConfig.blockDevToolsShortcuts) {
    const handleKeyDown = (e: KeyboardEvent) => {
      const isCtrl = e.ctrlKey;
      const isCmd = e.metaKey;
      const isCtrlOrCmd = isCtrl || isCmd;
      const isShift = e.shiftKey;
      const isAlt = e.altKey;
      const key = e.key.toLowerCase();
      const code = e.code;

      const isF12 = e.keyCode === 123 || key === "f12" || code === "F12";
      const isCtrlU = isCtrlOrCmd && key === "u"; // Código-fonte
      const isCtrlS = isCtrlOrCmd && key === "s"; // Salvar Página
      const isCtrlP = isCtrlOrCmd && key === "p"; // Imprimir DOM
      const isShiftF10 = isShift && (key === "f10" || code === "F10");

      const isInspect =
        (isCtrlOrCmd && isShift && (key === "i" || key === "j" || key === "c" || key === "k" || key === "e")) ||
        (isCmd && isAlt && (key === "i" || key === "j" || key === "c" || key === "u" || key === "s"));

      if (isF12 || isCtrlU || isCtrlS || isCtrlP || isShiftF10 || isInspect) {
        e.preventDefault();
        e.stopPropagation();
        toast.error("Acesso Restrito", {
          description: "Os atalhos de desenvolvedor e inspeção de código fonte estão desabilitados neste ambiente.",
          duration: 3500,
        });
      }
    };

    window.addEventListener("keydown", handleKeyDown, { capture: true });
  }

  // 3. Prevenção de Drag & Drop de Mídias
  if (activeConfig.blockDragAndDrop) {
    document.addEventListener("dragstart", (e: DragEvent) => {
      const target = e.target as HTMLElement | null;
      if (target && (target.tagName === "IMG" || target.tagName === "VIDEO" || target.tagName === "SVG")) {
        e.preventDefault();
      }
    });
  }

  // 4. Armadilha Anti-Debugger em Produção
  if (activeConfig.enableAntiDebugger && inProd) {
    const startAntiDebugger = () => {
      try {
        const antiDebug = function () {
          const fn = new Function("debugger");
          fn();
        };
        antiDebuggerInterval = window.setInterval(antiDebug, 1500);
      } catch {}
    };
    startAntiDebugger();
  }

  // 5. Sanitização de Console & Alerta Institucional LGPD
  if (activeConfig.showConsoleWarning) {
    try {
      console.clear();
      console.log(
        "%c 🛡️ SEGURANÇA ENTERPRISE ATIVADA - SISTEMA TI HSF ",
        "background: #dc2626; color: #ffffff; font-size: 16px; font-weight: bold; padding: 6px 12px; border-radius: 6px;"
      );
      console.log(
        "%c ⚠️ ATENÇÃO: Esta é uma área restrita destinada exclusivamente a usuários autorizados do Hospital São Francisco.\nA execução indevida de scripts ou extração não autorizada do código fonte viola as diretrizes de conformidade e LGPD.",
        "color: #f59e0b; font-size: 12px; font-weight: 500; margin-top: 6px;"
      );

      if (activeConfig.enableConsoleSanitize && inProd) {
        const noop = () => {};
        console.log = noop;
        console.debug = noop;
        console.info = noop;
        console.dir = noop;
        console.table = noop;
      }
    } catch {}
  }
}

export function stopSourceProtection() {
  if (antiDebuggerInterval !== null) {
    clearInterval(antiDebuggerInterval);
    antiDebuggerInterval = null;
  }
}
```

---

## 🚀 4. Como Integrar nos Próximos Projetos

No arquivo raiz da aplicação (ex: `src/App.tsx` ou `src/main.tsx`):

```tsx
import { useEffect } from "react";
import { initSourceProtection } from "@/lib/sourceProtection";

export function App() {
  useEffect(() => {
    // Inicializa a proteção logo no carregamento inicial
    initSourceProtection();
  }, []);

  return (
    // ... restante da aplicação
  );
}
```

---

## ⚙️ 5. Personalizações Opcionais

Caso algum sistema necessite desativar ou alterar o comportamento de alguma trava, basta passar os parâmetros:

```typescript
initSourceProtection({
  blockRightClick: true,        // Bloquear botão direito
  blockDevToolsShortcuts: true, // Bloquear F12 e atalhos de inspeção
  blockDragAndDrop: true,       // Bloquear arrastar imagens
  enableAntiDebugger: false,    // Desativar anti-debugger temporariamente
  enableConsoleSanitize: false  // Manter logs no console
});
```
