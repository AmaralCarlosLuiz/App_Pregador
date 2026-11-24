(() => {
  'use strict';

  // =========================================================================
  // CONFIGURAÇÃO SUPABASE & CONSTANTES
  // =========================================================================
  const SUPABASE_URL = 'https://yahvhltbfpebaievpumg.supabase.co';
  const SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhaHZobHRiZnBlYmFpZXZwdW1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4NTczOTUsImV4cCI6MjEwNzQzMzM5NX0.JoosKRUGOPWq4DzGt9oNObzdoAOnZXi0Va1YHsfUUuU';

  const KEYS = {
    PROFILE: 'pp_web_profile_v1',
    SERMONS_DELTA: 'pp_web_sermons_delta_v1',
    DELETED_IDS: 'pp_web_deleted_ids_v1',
    SETTINGS: 'pp_web_settings_v1',
    BOOKMARKS: 'pp_web_bookmarks_v1',
    CLOUD_AUTH: 'pp_web_cloud_auth_v1',
    TEMPLATES_CACHE: 'pp_web_templates_cache_v1',
    PENDING_SYNC: 'pp_web_pending_sync_v1',
    SESSION_AUTH: 'pp_web_session_auth_v2',
    ADMIN_AUTH: 'pp_web_admin_auth_v1',
    USERS: 'pp_web_users_v2',
    AUDIT_LOGS: 'pp_web_audit_logs_v1',
  };

  const SERMON_CATEGORIES = [
    'Geral', 'Expositivo', 'Evangelismo', 'Família', 'Oração', 'Fé',
    'Graça & Redenção', 'Escatologia', 'Discipulado', 'Avivamento', 'Liderança'
  ];

  const SERMON_TYPES = ['Expositivo', 'Temático', 'Textual', 'Evangelístico', 'Devocional'];

  const BIBLE_VERSIONS = [
    { id: 'ARC', label: 'ARC (Almeida Revista e Corrigida)', file: 'assets/bible/pt_arc.json' },
    { id: 'ARA', label: 'ARA (Almeida Revista e Atualizada)', file: 'assets/bible/pt_ara.json' },
    { id: 'NAA', label: 'NAA (Nova Almeida Atualizada)', file: 'assets/bible/pt_naa.json' },
    { id: 'NVI', label: 'NVI (Nova Versão Internacional)', file: 'assets/bible/pt_nvi.json' },
    { id: 'ACF', label: 'ACF (Almeida Corrigida Fiel)', file: 'assets/bible/pt_acf.json' },
    { id: 'BKJ', label: 'BKJ 1611 (King James Fiel)', file: 'assets/bible/pt_bkj.json' },
  ];

  const CANONICAL_BOOKS = [
    { id: 'gn', name: 'Gênesis', t: 'AT' }, { id: 'ex', name: 'Êxodo', t: 'AT' },
    { id: 'lv', name: 'Levítico', t: 'AT' }, { id: 'nm', name: 'Números', t: 'AT' },
    { id: 'dt', name: 'Deuteronômio', t: 'AT' }, { id: 'js', name: 'Josué', t: 'AT' },
    { id: 'jz', name: 'Juízes', t: 'AT' }, { id: 'rt', name: 'Rute', t: 'AT' },
    { id: '1sm', name: '1 Samuel', t: 'AT' }, { id: '2sm', name: '2 Samuel', t: 'AT' },
    { id: '1rs', name: '1 Reis', t: 'AT' }, { id: '2rs', name: '2 Reis', t: 'AT' },
    { id: '1cr', name: '1 Crônicas', t: 'AT' }, { id: '2cr', name: '2 Crônicas', t: 'AT' },
    { id: 'ed', name: 'Esdras', t: 'AT' }, { id: 'ne', name: 'Neemias', t: 'AT' },
    { id: 'et', name: 'Ester', t: 'AT' }, { id: 'jó', name: 'Jó', t: 'AT' },
    { id: 'sl', name: 'Salmos', t: 'AT' }, { id: 'pv', name: 'Provérbios', t: 'AT' },
    { id: 'ec', name: 'Eclesiastes', t: 'AT' }, { id: 'ct', name: 'Cantares', t: 'AT' },
    { id: 'is', name: 'Isaías', t: 'AT' }, { id: 'jr', name: 'Jeremias', t: 'AT' },
    { id: 'lm', name: 'Lamentações', t: 'AT' }, { id: 'ez', name: 'Ezequiel', t: 'AT' },
    { id: 'dn', name: 'Daniel', t: 'AT' }, { id: 'os', name: 'Oseias', t: 'AT' },
    { id: 'jl', name: 'Joel', t: 'AT' }, { id: 'am', name: 'Amós', t: 'AT' },
    { id: 'ob', name: 'Obadias', t: 'AT' }, { id: 'jn', name: 'Jonas', t: 'AT' },
    { id: 'mq', name: 'Miqueias', t: 'AT' }, { id: 'na', name: 'Naum', t: 'AT' },
    { id: 'hc', name: 'Habacuque', t: 'AT' }, { id: 'sf', name: 'Sofonias', t: 'AT' },
    { id: 'ag', name: 'Ageu', t: 'AT' }, { id: 'zc', name: 'Zacarias', t: 'AT' },
    { id: 'ml', name: 'Malaquias', t: 'AT' },
    { id: 'mt', name: 'Mateus', t: 'NT' }, { id: 'mc', name: 'Marcos', t: 'NT' },
    { id: 'lc', name: 'Lucas', t: 'NT' }, { id: 'jo', name: 'João', t: 'NT' },
    { id: 'atos', name: 'Atos', t: 'NT' }, { id: 'rm', name: 'Romanos', t: 'NT' },
    { id: '1co', name: '1 Coríntios', t: 'NT' }, { id: '2co', name: '2 Coríntios', t: 'NT' },
    { id: 'gl', name: 'Gálatas', t: 'NT' }, { id: 'ef', name: 'Efésios', t: 'NT' },
    { id: 'fp', name: 'Filipenses', t: 'NT' }, { id: 'cl', name: 'Colossenses', t: 'NT' },
    { id: '1ts', name: '1 Tessalonicenses', t: 'NT' }, { id: '2ts', name: '2 Tessalonicenses', t: 'NT' },
    { id: '1tm', name: '1 Timóteo', t: 'NT' }, { id: '2tm', name: '2 Timóteo', t: 'NT' },
    { id: 'tt', name: 'Tito', t: 'NT' }, { id: 'fm', name: 'Filemom', t: 'NT' },
    { id: 'hb', name: 'Hebreus', t: 'NT' }, { id: 'tg', name: 'Tiago', t: 'NT' },
    { id: '1pe', name: '1 Pedro', t: 'NT' }, { id: '2pe', name: '2 Pedro', t: 'NT' },
    { id: '1jo', name: '1 João', t: 'NT' }, { id: '2jo', name: '2 João', t: 'NT' },
    { id: '3jo', name: '3 João', t: 'NT' }, { id: 'jd', name: 'Judas', t: 'NT' },
    { id: 'ap', name: 'Apocalipse', t: 'NT' },
  ];

  // =========================================================================
  // UTILITÁRIOS SEGUROS
  // =========================================================================
  const esc = (s) =>
    String(s ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');

  const uuid = () => {
    if (window.crypto && typeof window.crypto.randomUUID === 'function') {
      return window.crypto.randomUUID();
    }
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      const v = c === 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  };

  const toCloudUuid = (id) => {
    if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id)) {
      return id;
    }
    // Mapeia IDs legados (ex: sermon-tpl-12) para UUID determinístico válido no PostgreSQL
    let h1 = 0x811c9dc5;
    let h2 = 0x1000193;
    for (let i = 0; i < id.length; i++) {
      const ch = id.charCodeAt(i);
      h1 = Math.imul(h1 ^ ch, 0x01000193) >>> 0;
      h2 = Math.imul(h2 ^ (ch + i), 0x01000193) >>> 0;
    }
    const hex1 = h1.toString(16).padStart(8, '0');
    const hex2 = h2.toString(16).padStart(8, '0');
    return `${hex1}-${hex2.slice(0, 4)}-4${hex2.slice(5, 8)}-8000-${hex1}${hex2.slice(0, 4)}`;
  };

  const formatPtDate = () => {
    try {
      const str = new Date().toLocaleDateString('pt-BR', {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
      });
      return str.charAt(0).toUpperCase() + str.slice(1);
    } catch {
      return 'Hoje';
    }
  };

  const statusLabel = (s) =>
    s === 'ready' ? 'Pronto p/ Púlpito' : s === 'in_review' ? 'Em Revisão' : 'Rascunho';

  // =========================================================================
  // CAMADA DE ARMAZENAMENTO HÍBRIDO (localStorage SÍNCRONO + IndexedDB)
  // =========================================================================
  const DB_NAME = 'PregadorProDB';
  const DB_STORE = 'kv';
  let _idbPromise = null;

  function openIdb() {
    if (_idbPromise) return _idbPromise;
    _idbPromise = new Promise((resolve) => {
      if (!('indexedDB' in window)) return resolve(null);
      try {
        const req = indexedDB.open(DB_NAME, 1);
        req.onupgradeneeded = () => {
          const db = req.result;
          if (!db.objectStoreNames.contains(DB_STORE)) {
            db.createObjectStore(DB_STORE);
          }
        };
        req.onsuccess = () => resolve(req.result);
        req.onerror = () => resolve(null);
      } catch {
        resolve(null);
      }
    });
    return _idbPromise;
  }

  function writeStore(key, obj) {
    const json = JSON.stringify(obj);
    try {
      localStorage.setItem(key, json);
    } catch (e) {
      console.warn('[Storage] localStorage error:', key, e);
    }
    openIdb().then((db) => {
      if (!db) return;
      try {
        const tx = db.transaction(DB_STORE, 'readwrite');
        tx.objectStore(DB_STORE).put(json, key);
      } catch (_) {}
    });
  }

  function readStoreSync(key, fallback = null) {
    try {
      const raw = localStorage.getItem(key);
      if (raw) return JSON.parse(raw);
    } catch (_) {}
    return fallback;
  }

  async function readIdbFallback(key) {
    const db = await openIdb();
    if (!db) return null;
    return new Promise((resolve) => {
      try {
        const tx = db.transaction(DB_STORE, 'readonly');
        const req = tx.objectStore(DB_STORE).get(key);
        req.onsuccess = () => {
          try {
            resolve(req.result ? JSON.parse(req.result) : null);
          } catch {
            resolve(null);
          }
        };
        req.onerror = () => resolve(null);
      } catch {
        resolve(null);
      }
    });
  }

  // Solicita persistência durável no iOS/Safari para evitar despejo de cache
  if (navigator.storage && navigator.storage.persist) {
    navigator.storage.persist().catch(() => {});
  }

  // =========================================================================
  // ESTADO DA APLICAÇÃO
  // =========================================================================
  const DEFAULT_PROFILE = {
    id: 'admin-master-01',
    email: 'carlosluizamaral@gmail.com',
    fullName: 'Pr. Carlos Luiz Amaral',
    ministryTitle: 'Pastor Titular',
    churchName: 'Igreja Batista',
    role: 'admin',
  };

  const DEFAULT_ADMIN_AUTH = {
    email: 'carlosluizamaral@gmail.com',
    role: 'admin',
    password: '123',
    mustChangePassword: true,
    updatedAt: null,
  };

  const USER_ROLES = [
    {
      id: 'admin',
      name: 'Administrador Master',
      badge: 'ADMIN',
      icon: '🛡️',
      color: '#f59e0b',
      desc: 'Acesso irrestrito a usuários, auditoria, configurações, acervo e púlpito.',
    },
    {
      id: 'pastor',
      name: 'Pastor / Ministro',
      badge: 'PASTOR',
      icon: '📖',
      color: '#3b82f6',
      desc: 'Gestão completa de sermões, IA Gemini Pro, modo púlpito e estúdio bíblico.',
    },
    {
      id: 'obreiro',
      name: 'Evangelista / Obreiro',
      badge: 'OBREIRO',
      icon: '✝️',
      color: '#10b981',
      desc: 'Criação e edição de esboços homiléticos, leitura bíblica e notas.',
    },
    {
      id: 'leitor',
      name: 'Seminarista / Leitor',
      badge: 'LEITOR',
      icon: '🎓',
      color: '#8b5cf6',
      desc: 'Acesso de consulta, leitura bíblica e modo púlpito sem permissão de exclusão.',
    },
  ];

  const DEFAULT_USERS_SEED = [
    {
      id: '00000000-0000-4000-8000-000000000001',
      fullName: 'Pr. Carlos Luiz Amaral',
      email: 'carlosluizamaral@gmail.com',
      role: 'admin',
      ministryTitle: 'Pastor Titular',
      churchName: 'Igreja Batista',
      status: 'active',
      password: '123',
      mustChangePassword: true,
      createdAt: '2026-11-20T00:00:00.000Z',
      updatedAt: '2026-11-20T00:00:00.000Z',
      lastLoginAt: '2026-11-20T01:30:00.000Z',
      isMaster: true,
    },
    {
      id: '00000000-0000-4000-8000-000000000002',
      fullName: 'Pr. Marcos Vinicius Oliveira',
      email: 'pr.marcos@igreja.com',
      role: 'pastor',
      ministryTitle: 'Pastor Auxiliar',
      churchName: 'Igreja Batista Central',
      status: 'active',
      password: '123',
      mustChangePassword: true,
      createdAt: '2026-11-19T14:20:00.000Z',
      updatedAt: '2026-11-19T14:20:00.000Z',
      lastLoginAt: '2026-11-19T18:45:00.000Z',
      isMaster: false,
    },
    {
      id: '00000000-0000-4000-8000-000000000003',
      fullName: 'Ev. Lucas Santana Ribeiro',
      email: 'ev.lucas@igreja.com',
      role: 'obreiro',
      ministryTitle: 'Evangelista & Pregador',
      churchName: 'Igreja Batista Memorial',
      status: 'active',
      password: '123',
      mustChangePassword: true,
      createdAt: '2026-11-18T10:15:00.000Z',
      updatedAt: '2026-11-18T10:15:00.000Z',
      lastLoginAt: null,
      isMaster: false,
    },
  ];

  const DEFAULT_AUDIT_SEED = [
    {
      id: 'aud-001',
      timestamp: '2026-11-20T01:30:00.000Z',
      action: 'LOGIN_SUCCESS',
      actionLabel: 'Autenticação no Sistema',
      severity: 'success',
      actorEmail: 'carlosluizamaral@gmail.com',
      actorName: 'Pr. Carlos Luiz Amaral',
      target: 'Painel Geral',
      details: 'Sessão administrativa iniciada com sucesso.',
    },
    {
      id: 'aud-002',
      timestamp: '2026-11-20T01:25:00.000Z',
      action: 'SETTINGS_UPDATE',
      actionLabel: 'Alteração de Configurações',
      severity: 'info',
      actorEmail: 'carlosluizamaral@gmail.com',
      actorName: 'Pr. Carlos Luiz Amaral',
      target: 'Paleta & Tema',
      details: 'Paleta Azul Real & Ouro sincronizada com a nuvem.',
    },
    {
      id: 'aud-003',
      timestamp: '2026-11-20T01:20:00.000Z',
      action: 'CLOUD_SYNC',
      actionLabel: 'Sincronização em Nuvem',
      severity: 'success',
      actorEmail: 'carlosluizamaral@gmail.com',
      actorName: 'Pr. Carlos Luiz Amaral',
      target: 'Supabase PostgreSQL',
      details: 'Sincronização bidirecional do acervo de sermões concluída.',
    },
  ];

  const COLOR_PALETTES = [
    {
      id: 'royal-gold',
      name: 'Azul Real & Ouro (Padrão)',
      desc: 'Equilíbrio executivo entre Azul Safira e Ouro Ministerial.',
      primary: '#3b82f6',
      primaryHover: '#2563eb',
      primaryLight: '#1d4ed8',
      gold: '#f59e0b',
      goldSoft: 'rgba(245, 158, 11, 0.14)',
      bgDark: '#070b14',
      elevatedDark: '#0f172a',
      surfaceDark: '#131c31',
      surface2Dark: '#1b2742',
    },
    {
      id: 'emerald-grace',
      name: 'Esmeralda Pastoral & Ouro',
      desc: 'Verde Esmeralda profundo com destaques dourados.',
      primary: '#10b981',
      primaryHover: '#059669',
      primaryLight: '#047857',
      gold: '#f59e0b',
      goldSoft: 'rgba(245, 158, 11, 0.14)',
      bgDark: '#05110d',
      elevatedDark: '#0a1e17',
      surfaceDark: '#0f2920',
      surface2Dark: '#16382c',
    },
    {
      id: 'imperial-purple',
      name: 'Roxo Imperial & Âmbar',
      desc: 'Nobreza litúrgica em Violeta Imperial e Âmbar.',
      primary: '#8b5cf6',
      primaryHover: '#7c3aed',
      primaryLight: '#6d28d9',
      gold: '#f59e0b',
      goldSoft: 'rgba(245, 158, 11, 0.15)',
      bgDark: '#0b0716',
      elevatedDark: '#140e26',
      surfaceDark: '#1c1433',
      surface2Dark: '#271c47',
    },
    {
      id: 'crimson-covenant',
      name: 'Carmesim Aliança & Ouro',
      desc: 'Vermelho Rubi teológico com contraste dourado.',
      primary: '#f43f5e',
      primaryHover: '#e11d48',
      primaryLight: '#be123c',
      gold: '#f59e0b',
      goldSoft: 'rgba(245, 158, 11, 0.15)',
      bgDark: '#14060a',
      elevatedDark: '#210b12',
      surfaceDark: '#2c1019',
      surface2Dark: '#3d1623',
    },
    {
      id: 'ocean-teal',
      name: 'Oceano Turquesa & Safira',
      desc: 'Leitura serena em Ciano Oceânico e Azul Celeste.',
      primary: '#06b6d4',
      primaryHover: '#0891b2',
      primaryLight: '#0e7490',
      gold: '#38bdf8',
      goldSoft: 'rgba(56, 189, 248, 0.15)',
      bgDark: '#041016',
      elevatedDark: '#081c26',
      surfaceDark: '#0d2633',
      surface2Dark: '#143547',
    },
    {
      id: 'amber-parchment',
      name: 'Âmbar Clássico & Bronze',
      desc: 'Inspirado em pergaminhos clássicos e madeira de púlpito.',
      primary: '#f59e0b',
      primaryHover: '#d97706',
      primaryLight: '#b45309',
      gold: '#fbbf24',
      goldSoft: 'rgba(251, 191, 36, 0.16)',
      bgDark: '#120d06',
      elevatedDark: '#1f160a',
      surfaceDark: '#2b1f0f',
      surface2Dark: '#3b2b15',
    },
    {
      id: 'olive-zion',
      name: 'Verde Oliveira Sião & Ouro',
      desc: 'Tom orgânico Monte das Oliveiras com dourado.',
      primary: '#84cc16',
      primaryHover: '#65a30d',
      primaryLight: '#4d7c0f',
      gold: '#eab308',
      goldSoft: 'rgba(234, 179, 8, 0.15)',
      bgDark: '#091006',
      elevatedDark: '#121e0b',
      surfaceDark: '#1a2a10',
      surface2Dark: '#243a17',
    },
    {
      id: 'slate-executive',
      name: 'Grafite Executivo & Índigo',
      desc: 'Minimalismo moderno em Grafite Neutro e Índigo.',
      primary: '#6366f1',
      primaryHover: '#4f46e5',
      primaryLight: '#4338ca',
      gold: '#38bdf8',
      goldSoft: 'rgba(56, 189, 248, 0.14)',
      bgDark: '#090b10',
      elevatedDark: '#11151f',
      surfaceDark: '#181d2a',
      surface2Dark: '#22293a',
    },
    {
      id: 'burgundy-rose',
      name: 'Vinho Litúrgico & Ouro Rosé',
      desc: 'Vinho cálice nobre com reflexos dourados rosados.',
      primary: '#e11d48',
      primaryHover: '#be123c',
      primaryLight: '#9f1239',
      gold: '#fb7185',
      goldSoft: 'rgba(251, 113, 133, 0.15)',
      bgDark: '#15050a',
      elevatedDark: '#220912',
      surfaceDark: '#2d0d19',
      surface2Dark: '#3d1222',
    },
    {
      id: 'midnight-cyan',
      name: 'Meia-Noite & Ciano Cósmico',
      desc: 'Profundidade cósmica com alta legibilidade em Ciano.',
      primary: '#0284c7',
      primaryHover: '#0369a1',
      primaryLight: '#075985',
      gold: '#38bdf8',
      goldSoft: 'rgba(56, 189, 248, 0.15)',
      bgDark: '#030712',
      elevatedDark: '#0b1329',
      surfaceDark: '#111d3d',
      surface2Dark: '#172752',
    },
    {
      id: 'copper-flame',
      name: 'Cobre Pentecostal & Âmbar Puro',
      desc: 'Inspirado na sarça ardente e lâmpadas de bronze do tabernáculo.',
      primary: '#ea580c',
      primaryHover: '#c2410c',
      primaryLight: '#9a3412',
      gold: '#f59e0b',
      goldSoft: 'rgba(245, 158, 11, 0.16)',
      bgDark: '#140904',
      elevatedDark: '#221008',
      surfaceDark: '#2e170c',
      surface2Dark: '#3f1f11',
    },
    {
      id: 'onyx-pure-gold',
      name: 'Ônix Soberano & Ouro 24k',
      desc: 'Preto absoluto OLED de alto contraste com Ouro 24k.',
      primary: '#d97706',
      primaryHover: '#b45309',
      primaryLight: '#92400e',
      gold: '#fbbf24',
      goldSoft: 'rgba(251, 191, 36, 0.18)',
      bgDark: '#040404',
      elevatedDark: '#0c0c0c',
      surfaceDark: '#141414',
      surface2Dark: '#1e1e1e',
    },
    {
      id: 'amethyst-majesty',
      name: 'Ametista Celestial & Lilás Real',
      desc: 'Pedra preciosa do peitoral sacerdotal em Violeta e Lilás.',
      primary: '#a855f7',
      primaryHover: '#9333ea',
      primaryLight: '#7e22ce',
      gold: '#c084fc',
      goldSoft: 'rgba(192, 132, 252, 0.15)',
      bgDark: '#0d0617',
      elevatedDark: '#170b28',
      surfaceDark: '#201037',
      surface2Dark: '#2d174d',
    },
    {
      id: 'jerusalem-terracotta',
      name: 'Terracota Jerusalém & Areia Dourada',
      desc: 'Pedra de Jerusalém e tons solares do Oriente.',
      primary: '#b45309',
      primaryHover: '#92400e',
      primaryLight: '#78350f',
      gold: '#f59e0b',
      goldSoft: 'rgba(245, 158, 11, 0.15)',
      bgDark: '#130b06',
      elevatedDark: '#20130b',
      surfaceDark: '#2b1a10',
      surface2Dark: '#3a2418',
    },
    {
      id: 'forest-pine',
      name: 'Monte Carmelo & Esmeralda Pinho',
      desc: 'Verde pinheiro denso e bíblico com dourado radiante.',
      primary: '#16a34a',
      primaryHover: '#15803d',
      primaryLight: '#166534',
      gold: '#fbbf24',
      goldSoft: 'rgba(251, 191, 36, 0.15)',
      bgDark: '#040f09',
      elevatedDark: '#091a11',
      surfaceDark: '#0e2619',
      surface2Dark: '#143624',
    },
    {
      id: 'cobalt-modern',
      name: 'Cobalto Ministerial & Platina',
      desc: 'Azul ultramarino moderno de alta precisão tipográfica.',
      primary: '#2563eb',
      primaryHover: '#1d4ed8',
      primaryLight: '#1e40af',
      gold: '#60a5fa',
      goldSoft: 'rgba(96, 165, 250, 0.15)',
      bgDark: '#060b17',
      elevatedDark: '#0d172e',
      surfaceDark: '#13203f',
      surface2Dark: '#1b2c56',
    },
  ];

  const DEFAULT_SETTINGS = {
    theme: 'dark', // 'dark' | 'light'
    palette: 'royal-gold',
    pulpitTheme: 'oled', // 'oled' | 'amber' | 'light'
    pulpitWidth: 'fluid', // 'fluid' | 'focus' | 'full'
    pulpitFont: 22,
    bibleFont: 18,
    bibleVersion: 'ARC',
    bibleBook: 'sl',
    bibleChapter: 23,
    bibleCompareVersions: ['ARC', 'NVI'],
    voiceGender: 'male', // 'male' | 'female'
    voiceRate: 1.0,
    voiceId: '',
    useNeuralAudio: true, // Voz Neural Gemini HD com timbre humano real
    geminiKey: '',
    geminiModel: 'gemini-3.5-flash-lite',
    geminiDiscoveredModels: {},
    geminiLastModelSync: null,
  };

  function applyThemeAndPalette() {
    const isLight = state.settings.theme === 'light';
    document.body.className = `theme-${isLight ? 'light' : 'dark'}`;
    const pal = COLOR_PALETTES.find((p) => p.id === state.settings.palette) || COLOR_PALETTES[0];
    const rootStyle = document.documentElement.style;

    rootStyle.setProperty('--primary', isLight ? pal.primaryLight : pal.primary);
    rootStyle.setProperty('--primary-hover', pal.primaryHover);
    rootStyle.setProperty('--gold', pal.gold);
    rootStyle.setProperty('--gold-soft', pal.goldSoft);

    if (isLight) {
      rootStyle.setProperty('--bg', '#f1f5f9');
      rootStyle.setProperty('--bg-elevated', '#ffffff');
      rootStyle.setProperty('--surface', '#ffffff');
      rootStyle.setProperty('--surface-2', '#f8fafc');
    } else {
      rootStyle.setProperty('--bg', pal.bgDark);
      rootStyle.setProperty('--bg-elevated', pal.elevatedDark);
      rootStyle.setProperty('--surface', pal.surfaceDark);
      rootStyle.setProperty('--surface-2', pal.surface2Dark);
    }
  }

  const state = {
    tab: 'dashboard', // dashboard | library | editor | bible | templates | profile | settings
    settingsSubTab: 'palettes', // 'palettes' | 'users' | 'audit' | 'pulpit'
    profile: { ...DEFAULT_PROFILE },
    adminAuth: { ...DEFAULT_ADMIN_AUTH },
    users: [],
    auditLogs: [],
    userFilterQuery: '',
    userFilterRole: 'all',
    auditFilterSeverity: 'all',
    settings: { ...DEFAULT_SETTINGS },
    cloudAuth: null, // { accessToken, refreshToken, userId, email }
    templates: [],
    sermonsDelta: {}, // { [id]: Sermon }
    deletedIds: new Set(),
    pendingSync: { upsertIds: [], deleteIds: [] },
    allSermons: [],
    selectedSermonId: null,
    editingSermon: null,
    libraryFilters: {
      query: '',
      category: 'Todas',
      status: '',
      onlyFavorites: false,
      onlyPreached: false,
    },
    templateFilters: {
      query: '',
      type: 'Todos',
      tag: null,
      expandedIds: new Set(),
    },
    bible: {
      cache: {}, // { ARC: books[] }
      loading: false,
      searchQuery: '',
      searchResults: [],
      isComparing: false,
      bookmarks: [],
      showSearch: false,
      showVoiceBar: true,
    },
    tts: {
      isPlaying: false,
      isPaused: false,
      isSelectionMode: false,
      selectedVerses: new Set(),
      queue: [],
      index: 0,
      voices: [],
      activeLabel: 'Masculina (Brasil • RJ)',
      isCloudNeural: false,
    },
    ai: {
      activeTab: 'outline',
      isLoading: false,
      outline: null,
      illustrations: [],
      lexical: [],
      theme: 'Entre Salmo 22 e a Crucificação de Jesus',
      ref: 'Salmos 22 / Mateus 27:35-50',
      sermonType: 'Expositivo',
    },
    pulpit: {
      sermon: null,
      timerSeconds: 0,
      timerRunning: false,
      timerInterval: null,
      wakeLock: null,
      autoScroll: false,
      autoScrollInterval: null,
      autoScrollSpeed: 1,
      keyHandler: null,
    },
  };

  // =========================================================================
  // MIGRAÇÃO AUTOMÁTICA DE DADOS ANTERIORES (FLUTTER WEB -> WEBAPP NATIVO)
  // =========================================================================
  function migrateLegacyFlutterStorage() {
    try {
      // Se já houver dados nativos salvos, não sobrescreve
      if (!localStorage.getItem(KEYS.SERMONS_DELTA)) {
        const legacyDeltaRaw =
          localStorage.getItem('pp_sync_pregador_pro_user_sermons_delta_v1') ||
          localStorage.getItem('flutter.pregador_pro_user_sermons_delta_v1');
        if (legacyDeltaRaw) {
          const parsed = typeof legacyDeltaRaw === 'string' ? JSON.parse(legacyDeltaRaw) : legacyDeltaRaw;
          const list = Array.isArray(parsed)
            ? parsed
            : typeof parsed === 'string'
              ? JSON.parse(parsed)
              : [];
          if (Array.isArray(list) && list.length > 0) {
            const map = {};
            for (const s of list) {
              if (s && s.id) map[s.id] = normalizeSermon(s);
            }
            writeStore(KEYS.SERMONS_DELTA, map);
          }
        }
      }

      if (!localStorage.getItem(KEYS.SETTINGS)) {
        const legacyKey =
          localStorage.getItem('pp_sync_gemini_api_key_custom') ||
          (localStorage.getItem('flutter.gemini_api_key_custom') || '').replace(/^"|"$/g, '');
        if (legacyKey) {
          const next = { ...DEFAULT_SETTINGS, geminiKey: legacyKey.trim() };
          writeStore(KEYS.SETTINGS, next);
        }
      }
    } catch (_) {}
  }

  function normalizeSermon(raw) {
    const content = raw.content || {};
    const blocks = Array.isArray(raw.blocks)
      ? raw.blocks
      : Array.isArray(content.blocks)
        ? content.blocks
        : [];
    return {
      id: raw.id || uuid(),
      userId: raw.userId || raw.user_id || state.profile.id,
      title: raw.title || 'Sem Título',
      biblicalReference: raw.biblicalReference || raw.biblical_reference || '',
      category: raw.category || 'Geral',
      sermonType: raw.sermonType || raw.sermon_type || 'Expositivo',
      introduction: raw.introduction ?? content.introduction ?? '',
      blocks: blocks.map((b, i) => ({
        id: b.id || `${raw.id}_b${i + 1}`,
        title: b.title || `Ponto ${i + 1}`,
        biblicalReference: b.biblicalReference || '',
        explanation: b.explanation || '',
        illustration: b.illustration || '',
        application: b.application || '',
        orderIndex: b.orderIndex ?? i,
      })),
      conclusion: raw.conclusion ?? content.conclusion ?? '',
      appeal: raw.appeal ?? content.appeal ?? '',
      isFavorite: Boolean(raw.isFavorite ?? raw.is_favorite),
      status: raw.status || 'draft',
      preachCount: Number(raw.preachCount ?? raw.preach_count ?? 0),
      lastPreachedAt: raw.lastPreachedAt || raw.last_preached_at || null,
      estimatedDurationMinutes: Number(raw.estimatedDurationMinutes ?? raw.estimated_duration_minutes ?? 40),
      createdAt: raw.createdAt || raw.created_at || new Date().toISOString(),
      updatedAt: raw.updatedAt || raw.updated_at || new Date().toISOString(),
    };
  }

  function sermonToSupabaseRow(sermon, uid) {
    return {
      id: toCloudUuid(sermon.id),
      user_id: uid,
      title: sermon.title || 'Novo Sermão',
      biblical_reference: sermon.biblicalReference || 'Salmos 23:1',
      category: sermon.category || 'Geral',
      sermon_type: SERMON_TYPES.includes(sermon.sermonType) ? sermon.sermonType : 'Expositivo',
      content: {
        introduction: sermon.introduction || '',
        blocks: sermon.blocks || [],
        conclusion: sermon.conclusion || '',
        appeal: sermon.appeal || '',
        local_id: sermon.id,
      },
      is_favorite: Boolean(sermon.isFavorite),
      status: ['draft', 'ready', 'archived'].includes(sermon.status) ? sermon.status : 'draft',
      preach_count: Number(sermon.preachCount || 0),
      last_preached_at: sermon.lastPreachedAt || null,
      estimated_duration_minutes: Number(sermon.estimatedDurationMinutes || 40),
      created_at: sermon.createdAt || new Date().toISOString(),
      updated_at: sermon.updatedAt || new Date().toISOString(),
    };
  }

  // =========================================================================
  // RECONCILIAÇÃO DO ACERVO + ALTERAÇÕES DO USUÁRIO
  // =========================================================================
  function buildStarterSermon(tpl, index) {
    const baseMs = Date.UTC(2026, 0, 15, 12, 0, 0);
    const createdMs = baseMs - (30 - (index % 25)) * 86400000;
    const updatedMs = baseMs - (index % 10) * 86400000 - index * 60000;
    const content = tpl.content || {};
    return normalizeSermon({
      id: `sermon-${tpl.id}`,
      userId: 'pastor-local-01',
      title: tpl.title,
      biblicalReference: tpl.keyVerse,
      category: Array.isArray(tpl.tags) && tpl.tags.length ? tpl.tags[0] : 'Geral',
      sermonType: tpl.sermonType || 'Expositivo',
      introduction: content.introduction || '',
      blocks: content.blocks || [],
      conclusion: content.conclusion || '',
      appeal: content.appeal || '',
      status: 'ready',
      isFavorite: index < 5,
      preachCount: index === 0 ? 3 : index === 1 ? 1 : 0,
      estimatedDurationMinutes: 40,
      createdAt: new Date(createdMs).toISOString(),
      updatedAt: new Date(updatedMs).toISOString(),
    });
  }

  function rebuildSermonsList() {
    const map = new Map();
    state.templates.forEach((tpl, idx) => {
      const id = `sermon-${tpl.id}`;
      if (!state.deletedIds.has(id) && !state.deletedIds.has(tpl.id)) {
        map.set(id, buildStarterSermon(tpl, idx));
      }
    });
    for (const [id, s] of Object.entries(state.sermonsDelta)) {
      if (!state.deletedIds.has(id)) {
        map.set(id, normalizeSermon(s));
      }
    }
    state.allSermons = Array.from(map.values()).sort(
      (a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
    );
  }

  function saveSermon(sermon, { markUpdated = true } = {}) {
    const updated = normalizeSermon({
      ...sermon,
      updatedAt: markUpdated ? new Date().toISOString() : sermon.updatedAt,
    });
    state.deletedIds.delete(updated.id);
    state.sermonsDelta[updated.id] = updated;
    writeStore(KEYS.DELETED_IDS, Array.from(state.deletedIds));
    writeStore(KEYS.SERMONS_DELTA, state.sermonsDelta);
    rebuildSermonsList();
    queueCloudUpsert(updated.id);
    return updated;
  }

  function deleteSermonById(id) {
    const existing = state.allSermons.find((s) => s.id === id);
    if (!existing) return null;
    state.deletedIds.add(id);
    delete state.sermonsDelta[id];
    writeStore(KEYS.DELETED_IDS, Array.from(state.deletedIds));
    writeStore(KEYS.SERMONS_DELTA, state.sermonsDelta);
    rebuildSermonsList();
    queueCloudDelete(id);
    return existing;
  }

  function restoreSermonObj(sermon) {
    state.deletedIds.delete(sermon.id);
    state.sermonsDelta[sermon.id] = sermon;
    writeStore(KEYS.DELETED_IDS, Array.from(state.deletedIds));
    writeStore(KEYS.SERMONS_DELTA, state.sermonsDelta);
    rebuildSermonsList();
    queueCloudUpsert(sermon.id);
  }

  function deleteTemplateById(tplId) {
    state.deletedIds.add(tplId);
    state.deletedIds.add(`sermon-${tplId}`);
    delete state.sermonsDelta[`sermon-${tplId}`];
    writeStore(KEYS.DELETED_IDS, Array.from(state.deletedIds));
    writeStore(KEYS.SERMONS_DELTA, state.sermonsDelta);
    rebuildSermonsList();
  }

  function restoreTemplateById(tplId) {
    state.deletedIds.delete(tplId);
    state.deletedIds.delete(`sermon-${tplId}`);
    writeStore(KEYS.DELETED_IDS, Array.from(state.deletedIds));
    rebuildSermonsList();
  }

  // =========================================================================
  // SINCRONIZAÇÃO COM SUPABASE (REST REAL)
  // =========================================================================
  function queueCloudUpsert(id) {
    if (!state.pendingSync.upsertIds.includes(id)) {
      state.pendingSync.upsertIds.push(id);
    }
    state.pendingSync.deleteIds = state.pendingSync.deleteIds.filter((x) => x !== id);
    writeStore(KEYS.PENDING_SYNC, state.pendingSync);
    syncCloudNow({ silent: true });
  }

  function queueCloudDelete(id) {
    if (!state.pendingSync.deleteIds.includes(id)) {
      state.pendingSync.deleteIds.push(id);
    }
    state.pendingSync.upsertIds = state.pendingSync.upsertIds.filter((x) => x !== id);
    writeStore(KEYS.PENDING_SYNC, state.pendingSync);
    syncCloudNow({ silent: true });
  }

  async function supabaseAuthRequest(path, body) {
    const res = await fetch(`${SUPABASE_URL}/auth/v1/${path}`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_ANON_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) {
      throw new Error(data.msg || data.error_description || data.message || `Erro HTTP ${res.status}`);
    }
    return data;
  }

  async function ensureFreshToken() {
    if (!state.cloudAuth || !state.cloudAuth.accessToken) return null;
    const now = Math.floor(Date.now() / 1000);
    if (state.cloudAuth.expiresAt && state.cloudAuth.expiresAt - 60 > now) {
      return state.cloudAuth.accessToken;
    }
    if (!state.cloudAuth.refreshToken) return state.cloudAuth.accessToken;
    try {
      const data = await supabaseAuthRequest('token?grant_type=refresh_token', {
        refresh_token: state.cloudAuth.refreshToken,
      });
      state.cloudAuth = {
        accessToken: data.access_token,
        refreshToken: data.refresh_token || state.cloudAuth.refreshToken,
        userId: data.user?.id || state.cloudAuth.userId,
        email: data.user?.email || state.cloudAuth.email,
        expiresAt: Math.floor(Date.now() / 1000) + (data.expires_in || 3600),
      };
      writeStore(KEYS.CLOUD_AUTH, state.cloudAuth);
      return state.cloudAuth.accessToken;
    } catch {
      return state.cloudAuth.accessToken;
    }
  }

  const MASTER_CLOUD_USER_ID = '00000000-0000-4000-8000-000000000001';

  async function cloudFetch(path, options = {}) {
    const token = (await ensureFreshToken()) || SUPABASE_ANON_KEY;
    const headers = {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    };
    return fetch(`${SUPABASE_URL}/rest/v1/${path}`, { ...options, headers });
  }

  async function signInCloud(email, password) {
    const data = await supabaseAuthRequest('token?grant_type=password', {
      email: email.trim().toLowerCase(),
      password: password.trim(),
    });
    state.cloudAuth = {
      accessToken: data.access_token,
      refreshToken: data.refresh_token,
      userId: data.user.id,
      email: data.user.email,
      expiresAt: Math.floor(Date.now() / 1000) + (data.expires_in || 3600),
    };
    writeStore(KEYS.CLOUD_AUTH, state.cloudAuth);
    state.profile.email = data.user.email;
    writeStore(KEYS.PROFILE, state.profile);
    await syncCloudNow({ silent: false, pullAll: true });
  }

  async function signUpCloud(email, password) {
    const data = await supabaseAuthRequest('signup', {
      email: email.trim().toLowerCase(),
      password: password.trim(),
      data: {
        full_name: state.profile.fullName,
        ministry_title: state.profile.ministryTitle,
        church_name: state.profile.churchName,
      },
    });
    if (data.access_token) {
      state.cloudAuth = {
        accessToken: data.access_token,
        refreshToken: data.refresh_token,
        userId: data.user.id,
        email: data.user.email,
        expiresAt: Math.floor(Date.now() / 1000) + (data.expires_in || 3600),
      };
      writeStore(KEYS.CLOUD_AUTH, state.cloudAuth);
      await syncCloudNow({ silent: false, pullAll: true });
      return { needsConfirm: false };
    }
    return { needsConfirm: true };
  }

  let _cloudDbReady = false;

  function syncMasterUserWithProfile() {
    if (!Array.isArray(state.users) || !state.profile) return;
    const master = state.users.find(
      (u) => u.isMaster || u.email === (state.profile.email || 'carlosluizamaral@gmail.com') || u.role === 'admin'
    );
    if (master) {
      let changed = false;
      if (state.profile.fullName && master.fullName !== state.profile.fullName) {
        master.fullName = state.profile.fullName;
        changed = true;
      }
      if (state.profile.ministryTitle && master.ministryTitle !== state.profile.ministryTitle) {
        master.ministryTitle = state.profile.ministryTitle;
        changed = true;
      }
      if (state.profile.churchName !== undefined && master.churchName !== state.profile.churchName) {
        master.churchName = state.profile.churchName;
        changed = true;
      }
      if (state.profile.email && master.email !== state.profile.email) {
        master.email = state.profile.email;
        changed = true;
      }
      if (changed) {
        writeStore(KEYS.USERS, state.users);
      }
    }
  }

  function markProfileUpdated() {
    state.profile.updatedAt = new Date().toISOString();
    writeStore(KEYS.PROFILE, state.profile);
    syncMasterUserWithProfile();
  }

  async function syncCloudNow({ silent = true, pullAll = false, pushProfile = false } = {}) {
    updateSyncIndicators();
    if (!navigator.onLine) return;

    try {
      const uid = state.cloudAuth?.userId || MASTER_CLOUD_USER_ID;

      // 1. Perfil + Configurações + Exclusões (remoto <-> local por timestamp)
      let shouldPushProfile = pushProfile;
      const profRes = await cloudFetch(`profiles?id=eq.${encodeURIComponent(uid)}&select=*`);
      if (profRes.ok) {
        _cloudDbReady = true;
        const profRows = await profRes.json();
        if (Array.isArray(profRows) && profRows.length > 0) {
          const remoteProf = profRows[0];
          const remoteTs = new Date(remoteProf.updated_at || 0).getTime();
          const localTs = new Date(state.profile.updatedAt || 0).getTime();

          if (!pushProfile && (!localStorage.getItem(KEYS.PROFILE) || remoteTs > localTs)) {
            state.profile = {
              ...state.profile,
              fullName: remoteProf.full_name || state.profile.fullName,
              ministryTitle: remoteProf.ministry_title || state.profile.ministryTitle,
              churchName: remoteProf.church_name ?? state.profile.churchName,
              updatedAt: remoteProf.updated_at || new Date().toISOString(),
            };
            writeStore(KEYS.PROFILE, state.profile);

            if (remoteProf.settings && typeof remoteProf.settings === 'object') {
              const { _deletedIds, _adminAuth, ...cleanSettings } = remoteProf.settings;
              if (Object.keys(cleanSettings).length > 0) {
                state.settings = { ...state.settings, ...cleanSettings };
                applyThemeAndPalette();
                writeStore(KEYS.SETTINGS, state.settings);
              }
              if (_adminAuth && typeof _adminAuth === 'object') {
                const localAuthTs = new Date(state.adminAuth.updatedAt || 0).getTime();
                const remoteAuthTs = new Date(_adminAuth.updatedAt || 0).getTime();
                if (!localStorage.getItem(KEYS.ADMIN_AUTH) || remoteAuthTs >= localAuthTs) {
                  state.adminAuth = { ...DEFAULT_ADMIN_AUTH, ..._adminAuth };
                  writeStore(KEYS.ADMIN_AUTH, state.adminAuth);
                }
              }
              if (Array.isArray(_deletedIds)) {
                _deletedIds.forEach((d) => state.deletedIds.add(d));
                writeStore(KEYS.DELETED_IDS, Array.from(state.deletedIds));
              }
            }
            renderChrome();
          } else if (localTs > remoteTs) {
            shouldPushProfile = true;
          }
        } else {
          shouldPushProfile = true;
        }
      }

      if (shouldPushProfile) {
        const nowIso = state.profile.updatedAt || new Date().toISOString();
        const profUpsert = await cloudFetch('profiles', {
          method: 'POST',
          headers: { Prefer: 'resolution=merge-duplicates' },
          body: JSON.stringify({
            id: uid,
            full_name: state.profile.fullName,
            ministry_title: state.profile.ministryTitle,
            church_name: state.profile.churchName,
            settings: {
              ...state.settings,
              _adminAuth: state.adminAuth,
              _deletedIds: Array.from(state.deletedIds),
            },
            updated_at: nowIso,
          }),
        });
        _cloudDbReady = profUpsert.ok;
      }

      // 2. Enviar exclusões pendentes
      for (const delId of [...state.pendingSync.deleteIds]) {
        const res = await cloudFetch(`sermons?id=eq.${encodeURIComponent(toCloudUuid(delId))}`, {
          method: 'DELETE',
        });
        if (res.ok) {
          state.pendingSync.deleteIds = state.pendingSync.deleteIds.filter((x) => x !== delId);
        }
      }

      // 3. Enviar sermões modificados pendentes
      const toPush = new Set(state.pendingSync.upsertIds);
      if (pullAll) {
        Object.keys(state.sermonsDelta).forEach((id) => toPush.add(id));
      }
      for (const id of toPush) {
        const sermon = state.sermonsDelta[id];
        if (!sermon) {
          state.pendingSync.upsertIds = state.pendingSync.upsertIds.filter((x) => x !== id);
          continue;
        }
        const row = sermonToSupabaseRow(sermon, uid);
        const res = await cloudFetch('sermons', {
          method: 'POST',
          headers: { Prefer: 'resolution=merge-duplicates' },
          body: JSON.stringify(row),
        });
        if (res.ok) {
          _cloudDbReady = true;
          state.pendingSync.upsertIds = state.pendingSync.upsertIds.filter((x) => x !== id);
        }
      }
      writeStore(KEYS.PENDING_SYNC, state.pendingSync);

      // 4. Buscar sermões da nuvem e mesclar por updatedAt
      const pullRes = await cloudFetch(`sermons?user_id=eq.${encodeURIComponent(uid)}&select=*&order=updated_at.desc`);
      if (pullRes.ok) {
        const remoteRows = await pullRes.json();
        let changed = false;
        for (const r of remoteRows) {
          const localId = (r.content && r.content.local_id) || r.id;
          if (state.deletedIds.has(localId) || state.deletedIds.has(r.id)) continue;
          const mapped = normalizeSermon({ ...r, id: localId });
          const existing = state.sermonsDelta[localId];
          if (!existing || new Date(mapped.updatedAt) > new Date(existing.updatedAt)) {
            state.sermonsDelta[localId] = mapped;
            changed = true;
          }
        }
        if (changed) {
          writeStore(KEYS.SERMONS_DELTA, state.sermonsDelta);
          rebuildSermonsList();
          renderChrome();
          if (state.tab === 'dashboard' || state.tab === 'library') renderMain();
        }
      }

      if (!silent) {
        if (_cloudDbReady) {
          showToast('Sincronização com o banco Supabase concluída!', 'success');
        } else {
          showToast('Execute o script SQL de liberação RLS no Supabase para gravar na nuvem.', 'info');
        }
      }
    } catch (e) {
      if (!silent) showToast(`Sincronização offline mantida (${e.message})`, 'info');
    } finally {
      updateSyncIndicators();
    }
  }

  // =========================================================================
  // MOTOR DE VOZES DA BÍBLIA (CLASSIFICAÇÃO REAL PT-BR • SEM PRESETS ARTIFICIAIS)
  // =========================================================================
  const TTS_MALE_KW = [
    'daniel', 'antonio', 'antônio', 'felipe', 'fabio', 'fábio', 'ricardo',
    'tiago', 'marcos', 'paulo', 'carlos', 'humberto', 'julio', 'júlio',
    'valerio', 'valério', 'nicolau', 'eddy', 'reed', 'rocko', 'grandpa',
    'donato', 'luca', 'jorge', 'male', 'homem', 'pt-br-x-yfd', 'pt-br-x-afs'
  ];
  const TTS_FEMALE_KW = [
    'maria', 'luciana', 'francisca', 'thalita', 'leticia', 'letícia', 'heloisa',
    'heloísa', 'camila', 'fernanda', 'yara', 'vitoria', 'vitória', 'brenda',
    'giovanna', 'leila', 'manuela', 'raquel', 'ana', 'julia', 'júlia', 'flo',
    'sandy', 'shelley', 'grandma', 'google português', 'google portugues',
    'female', 'mulher', 'pt-br-x-sfg', 'pt-br-x-jfc'
  ];
  const TTS_PT_EXCLUDE = ['pt-pt', 'pt_pt', 'portugal', 'cristiano', 'inês', 'ines', 'duarte', 'joana'];

  let _ttsToken = 0;
  let _ttsAudioEl = null;
  let _ttsKeepAlive = null;

  function refreshBrowserVoices() {
    if (!('speechSynthesis' in window)) return;
    const all = window.speechSynthesis.getVoices() || [];
    const isPtExclude = (v) => {
      const lang = (v.lang || '').toLowerCase().replace('_', '-');
      const n = (v.name || '').toLowerCase();
      if (lang.startsWith('pt-pt')) return true;
      return TTS_PT_EXCLUDE.some((k) => n.includes(k)) && !lang.startsWith('pt-br');
    };
    const score = (v) => {
      const n = (v.name || '').toLowerCase();
      const l = (v.lang || '').toLowerCase().replace('_', '-');
      let s = l.startsWith('pt-br') ? 5 : 0;
      if (/natural|neural|online|premium|enhanced/.test(n)) s += 20; // Alta fidelidade online/neural
      if (/google/.test(n)) s += 15; // Google TTS natural
      if (/antonio|francisca|thalita|felipe|luciana/.test(n)) s += 10;
      if (/daniel|maria/.test(n)) s += 5; // Vozes padrão do Windows
      return s;
    };

    const ptBr = all
      .filter((v) => {
        const l = (v.lang || '').toLowerCase().replace('_', '-');
        const n = (v.name || '').toLowerCase();
        if (!l.startsWith('pt')) return false;
        if (isPtExclude(v)) return false;
        // Exclusão apenas de sintetizadores emuladores antigos (espeak, zira em inglês, etc.)
        if (/espeak|desktop sapi/i.test(n)) return false;
        return true;
      })
      .sort((a, b) => score(b) - score(a));

    state.tts.voices = ptBr.map((v) => {
      const lower = (v.name || '').toLowerCase();
      const isM = TTS_MALE_KW.some((k) => lower.includes(k));
      const isF = TTS_FEMALE_KW.some((k) => lower.includes(k));
      const isNat = /natural|neural|online|premium|enhanced/i.test(lower);
      const isGoo = /google/i.test(lower);

      // Determinação de gênero rigorosa
      let gender = 'neutral';
      if (isM && !isF) gender = 'male';
      else if (isF && !isM) gender = 'female';
      else if (isGoo) gender = 'female'; // Google português do Brasil é feminina
      else if (/daniel/i.test(lower)) gender = 'male';
      else if (/maria/i.test(lower)) gender = 'female';

      return {
        raw: v,
        id: v.voiceURI || v.name,
        name: v.name || 'Voz Brasil',
        lang: v.lang || 'pt-BR',
        isMale: gender === 'male',
        isFemale: gender === 'female',
        isNatural: isNat,
        isGoogle: isGoo,
      };
    });
    updateActiveVoiceLabel();
  }

  // =========================================================================
  // MOTOR DE ÁUDIO BÍBLICO DUPLO: NEURAL GEMINI HD (ESTÚDIO) + FALLBACK NATIVO
  // =========================================================================
  const _neuralAudioCache = new Map();

  function pcmToWavBlob(pcmData, sampleRate = 24000) {
    const pcmBytes = typeof pcmData === 'string'
      ? Uint8Array.from(atob(pcmData), (c) => c.charCodeAt(0))
      : pcmData;
    const numChannels = 1;
    const bitsPerSample = 16;
    const byteRate = (sampleRate * numChannels * bitsPerSample) / 8;
    const blockAlign = (numChannels * bitsPerSample) / 8;
    const wavHeader = new ArrayBuffer(44);
    const view = new DataView(wavHeader);

    // "RIFF"
    view.setUint8(0, 0x52); view.setUint8(1, 0x49); view.setUint8(2, 0x46); view.setUint8(3, 0x46);
    view.setUint32(4, 36 + pcmBytes.byteLength, true);
    // "WAVE"
    view.setUint8(8, 0x57); view.setUint8(9, 0x41); view.setUint8(10, 0x56); view.setUint8(11, 0x45);
    // "fmt "
    view.setUint8(12, 0x66); view.setUint8(13, 0x6d); view.setUint8(14, 0x74); view.setUint8(15, 0x20);
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true); // PCM
    view.setUint16(22, numChannels, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, byteRate, true);
    view.setUint16(32, blockAlign, true);
    view.setUint16(34, bitsPerSample, true);
    // "data"
    view.setUint8(36, 0x64); view.setUint8(37, 0x61); view.setUint8(38, 0x74); view.setUint8(39, 0x61);
    view.setUint32(40, pcmBytes.byteLength, true);

    return new Blob([wavHeader, pcmBytes], { type: 'audio/wav' });
  }

  async function fetchGeminiNeuralAudio(text, preferMale, apiKey) {
    if (!apiKey) return null;
    const cacheKey = `${preferMale ? 'm' : 'f'}|${text}`;
    if (_neuralAudioCache.has(cacheKey)) {
      return _neuralAudioCache.get(cacheKey);
    }

    const voiceName = preferMale ? 'Charon' : 'Aoede';
    const direction = preferMale
      ? 'Leia em voz alta em Português do Brasil com dicção bíblica solene, voz masculina grave, calorosa e calma de pastor, ritmo devocional sereno. Leia apenas o texto bíblico sem comentários:\n\n'
      : 'Leia em voz alta em Português do Brasil com dicção bíblica suave, voz feminina doce, clara e acolhedora de narradora, ritmo devocional sereno. Leia apenas o texto bíblico sem comentários:\n\n';

    const ttsModels = ['gemini-2.5-flash-preview-tts', 'gemini-2.0-flash'];

    for (const model of ttsModels) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(apiKey)}`;
        const res = await fetchGeminiWithRetry(
          url,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{ parts: [{ text: `${direction}${text}` }] }],
              generationConfig: {
                responseModalities: ['AUDIO'],
                speechConfig: {
                  voiceConfig: {
                    prebuiltVoiceConfig: {
                      voiceName: voiceName,
                    },
                  },
                },
              },
            }),
          },
          0,
          10000
        );

        if (res.ok) {
          const data = await res.json();
          const parts = data?.candidates?.[0]?.content?.parts || [];
          let inline = null;
          for (const p of parts) {
            if (p.inlineData && p.inlineData.data) {
              inline = p.inlineData;
              break;
            }
          }
          if (inline) {
            const mime = inline.mimeType || '';
            const rateMatch = mime.match(/rate=(\d+)/);
            const rate = rateMatch ? parseInt(rateMatch[1], 10) : 24000;
            const blob = pcmToWavBlob(inline.data, rate);
            const audioUrl = URL.createObjectURL(blob);
            _neuralAudioCache.set(cacheKey, audioUrl);
            return audioUrl;
          }
        }
      } catch (err) {
        console.warn(`[Gemini Neural TTS] Falha no modelo ${model}:`, err);
      }
    }
    return null;
  }

  function pickBestBrowserVoice(preferMale, specificId) {
    const list = state.tts.voices;
    if (!list.length) return null;

    // 1. Se o usuário fixou uma voz específica na lista do aparelho
    if (specificId) {
      const exact = list.find((v) => v.id === specificId || v.name === specificId);
      if (exact) return exact;
    }

    // 2. Busca estrita por gênero (GARANTE que Masculino nunca toque feminino e vice-versa)
    const genderMatches = list.filter((v) => (preferMale ? v.isMale : v.isFemale));

    if (genderMatches.length > 0) {
      // Prioridade: voz Natural / Neural (ex: Antonio Natural / Francisca Natural do Edge)
      const natural = genderMatches.find((v) => v.isNatural);
      if (natural) return natural;

      // Se for feminino e tiver Google Português
      if (!preferMale) {
        const google = genderMatches.find((v) => v.isGoogle);
        if (google) return google;
      }

      return genderMatches[0];
    }

    // 3. Fallback inteligente sem inversão de gênero:
    if (preferMale) {
      const nonFemale = list.filter((v) => !v.isFemale);
      if (nonFemale.length > 0) return nonFemale[0];
    } else {
      const nonMale = list.filter((v) => !v.isMale);
      if (nonMale.length > 0) return nonMale[0];
    }

    return list[0];
  }

  function updateActiveVoiceLabel() {
    const isMale = state.settings.voiceGender === 'male';
    const apiKey = state.settings.geminiKey?.trim();
    const useNeural = state.settings.useNeuralAudio !== false && apiKey;

    if (useNeural) {
      state.tts.activeLabel = isMale
        ? '✨ Voz Neural Gemini HD • Charon (Púlpito Masculino)'
        : '✨ Voz Neural Gemini HD • Aoede (Narradora Feminina)';
      return;
    }

    const picked = pickBestBrowserVoice(isMale, state.settings.voiceId);
    if (picked) {
      const genderTxt = picked.isMale ? 'Masculina' : picked.isFemale ? 'Feminina' : (isMale ? 'Masculina' : 'Feminina');
      state.tts.activeLabel = `Voz ${genderTxt} (${picked.name})`;
    } else {
      state.tts.activeLabel = isMale ? 'Voz Masculina (Padrão pt-BR)' : 'Voz Feminina (Padrão pt-BR)';
    }
  }

  async function sampleVoice(voiceId) {
    const isMale = state.settings.voiceGender === 'male';
    const apiKey = state.settings.geminiKey?.trim();
    const useNeural = state.settings.useNeuralAudio !== false && apiKey && !voiceId;

    if (useNeural) {
      showToast('Gerando amostra da Voz Neural Gemini HD...', 'info');
      const audioUrl = await fetchGeminiNeuralAudio('O Senhor é o meu pastor; nada me faltará.', isMale, apiKey);
      if (audioUrl) {
        if (!_ttsAudioEl) _ttsAudioEl = new Audio();
        _ttsAudioEl.src = audioUrl;
        _ttsAudioEl.playbackRate = state.settings.voiceRate || 1.0;
        _ttsAudioEl.play().catch(() => {});
        return;
      }
    }

    if (!('speechSynthesis' in window)) return;
    try { window.speechSynthesis.cancel(); } catch (_) {}
    const v = state.tts.voices.find((x) => x.id === voiceId || x.name === voiceId);
    const utt = new SpeechSynthesisUtterance('O Senhor é o meu pastor; nada me faltará.');
    utt.lang = 'pt-BR';
    if (v) utt.voice = v.raw;
    utt.rate = state.settings.voiceRate || 1.0;
    utt.pitch = 1.0;
    window.speechSynthesis.speak(utt);
  }

  function formatSpokenVerse(v, includeHeader, isSingle) {
    const clean = String(v.text || '')
      .replace(/\[([^\]]+)\]/g, '$1')
      .replace(/—/g, ', ')
      .replace(/;/g, ', ')
      .replace(/:/g, ', ')
      .replace(/\s+/g, ' ')
      .trim();
    let book = v.bookName || '';
    if (book.startsWith('1 ')) {
      const r = book.slice(2);
      book = /^(Pedro|João|Timóteo|Tessalonicenses|Coríntios)/.test(r) ? `Primeira ${r}` : `Primeiro ${r}`;
    } else if (book.startsWith('2 ')) {
      const r = book.slice(2);
      book = /^(Pedro|João|Timóteo|Tessalonicenses|Coríntios)/.test(r) ? `Segunda ${r}` : `Segundo ${r}`;
    } else if (book.startsWith('3 ')) {
      book = `Terceira ${book.slice(2)}`;
    }
    if (includeHeader) {
      return isSingle
        ? `${book}, capítulo ${v.chapter}, versículo ${v.verse}. ${clean}`
        : `${book}, capítulo ${v.chapter}. Versículo ${v.verse}: ${clean}`;
    }
    // Leitura fluida contínua sem quebras artificiais nem lentidão
    return `${v.verse}. ${clean}`;
  }

  function fallbackToBrowserSpeech(text, preferMale, token) {
    if (!('speechSynthesis' in window)) {
      showToast('Navegador sem suporte a leitura em voz.', 'error');
      return stopBibleSpeech();
    }
    const utt = new SpeechSynthesisUtterance(text);
    utt.lang = 'pt-BR';
    const picked = pickBestBrowserVoice(preferMale, state.settings.voiceId);
    if (picked) utt.voice = picked.raw;
    utt.rate = Math.min(2.0, Math.max(0.5, state.settings.voiceRate || 1.0));
    utt.pitch = 1.0;

    utt.onend = () => {
      clearInterval(_ttsKeepAlive);
      if (token === _ttsToken) advanceTtsQueue();
    };
    utt.onerror = (ev) => {
      clearInterval(_ttsKeepAlive);
      if (token !== _ttsToken) return;
      if (ev.error === 'canceled' || ev.error === 'interrupted') return;
      stopBibleSpeech();
    };
    window.speechSynthesis.speak(utt);

    _ttsKeepAlive = setInterval(() => {
      if (token !== _ttsToken) return clearInterval(_ttsKeepAlive);
      if (window.speechSynthesis.speaking && !window.speechSynthesis.paused) {
        window.speechSynthesis.pause();
        window.speechSynthesis.resume();
      }
    }, 8000);
  }

  async function speakQueueItem(includeHeader = true, interruptPrev = true) {
    const item = state.tts.queue[state.tts.index];
    if (!item) return stopBibleSpeech();
    const token = ++_ttsToken;
    clearInterval(_ttsKeepAlive);

    if (interruptPrev) {
      try { window.speechSynthesis?.cancel(); } catch (_) {}
      if (_ttsAudioEl) {
        try { _ttsAudioEl.pause(); } catch (_) {}
      }
    }

    const preferMale = state.settings.voiceGender === 'male';
    const text = formatSpokenVerse(item, includeHeader && state.tts.index === 0, state.tts.queue.length === 1);
    updateActiveVoiceLabel();
    if (state.tab === 'bible') renderMain();

    const apiKey = state.settings.geminiKey?.trim();
    const useNeural = state.settings.useNeuralAudio !== false && Boolean(apiKey) && navigator.onLine && !state.settings.voiceId;

    if (useNeural) {
      try {
        const audioUrl = await fetchGeminiNeuralAudio(text, preferMale, apiKey);
        if (token !== _ttsToken) return;
        if (audioUrl) {
          if (!_ttsAudioEl) _ttsAudioEl = new Audio();
          _ttsAudioEl.src = audioUrl;
          _ttsAudioEl.playbackRate = Math.min(2.0, Math.max(0.5, state.settings.voiceRate || 1.0));
          _ttsAudioEl.onended = () => {
            if (token === _ttsToken) advanceTtsQueue();
          };
          _ttsAudioEl.onerror = () => {
            console.warn('[Audio Player] Erro no player neural; alternando para sintetizador nativo.');
            fallbackToBrowserSpeech(text, preferMale, token);
          };
          await _ttsAudioEl.play();

          // Pré-busca do próximo versículo em segundo plano para eliminar latência
          if (state.tts.index + 1 < state.tts.queue.length) {
            const nextItem = state.tts.queue[state.tts.index + 1];
            const nextText = formatSpokenVerse(nextItem, false, false);
            fetchGeminiNeuralAudio(nextText, preferMale, apiKey).catch(() => {});
          }
          return;
        }
      } catch (neuralErr) {
        console.warn('[Gemini Neural TTS] Recorrendo ao sintetizador local do aparelho:', neuralErr);
      }
    }

    // Fallback para o sintetizador do aparelho
    if (interruptPrev) {
      await new Promise((r) => setTimeout(r, 20));
    }
    if (token !== _ttsToken) return;
    fallbackToBrowserSpeech(text, preferMale, token);
  }

  function advanceTtsQueue() {
    if (state.tts.index + 1 < state.tts.queue.length) {
      state.tts.index++;
      // Avança imediatamente para o próximo versículo sem pausar a esteira
      speakQueueItem(false, false);
    } else {
      stopBibleSpeech();
      showToast('Leitura bíblica concluída.', 'success');
    }
  }

  function startBibleSpeech(verses) {
    if (!verses || !verses.length) return;
    state.tts.queue = verses;
    state.tts.index = 0;
    state.tts.isPlaying = true;
    state.tts.isPaused = false;
    speakQueueItem(true, true);
  }

  function stopBibleSpeech() {
    _ttsToken++;
    clearInterval(_ttsKeepAlive);
    try { window.speechSynthesis?.cancel(); } catch (_) {}
    if (_ttsAudioEl) {
      try {
        _ttsAudioEl.pause();
        _ttsAudioEl.currentTime = 0;
      } catch (_) {}
    }
    state.tts.isPlaying = false;
    state.tts.isPaused = false;
    state.tts.queue = [];
    state.tts.index = 0;
    if (state.tab === 'bible') renderMain();
  }

  // =========================================================================
  // =========================================================================
  // MOTOR DE IA GEMINI PRO • RESILIÊNCIA ENTERPRISE & ALTA DISPONIBILIDADE
  // =========================================================================
  const OFFICIAL_DEFAULT_MODELS = {
    'gemini-3.5-flash-lite': 'Gemini 3.5 Flash Lite (Recomendado Oficial Google AI • Alta Disponibilidade)',
    'gemini-3.1-flash-lite-preview': 'Gemini 3.1 Flash Lite Preview (Oficial Google AI • Rápido & Estável)',
    'gemini-3.8-flash': 'Gemini 3.8 Flash (Nova Geração Google AI)',
    'gemini-3.1-pro-preview': 'Gemini 3.1 Pro Preview (Exegese Bíblica Profunda & Raciocínio Oficial)',
  };

  // Modelos descontinuados ou com quota zero no Free Tier que devem ser expurgados
  const BLACKLISTED_GEMINI_PATTERNS = [
    /omni/i,                // Quota zero no tier gratuito (Erro 429 quota limit 0)
    /flash-lite-latest/i,   // Alias que aponta para 2.5-flash-lite descontinuado pelo Google
    /2\.5-flash-lite/i,     // Descontinuado pelo Google (Erro 404/400)
    /2\.5-pro/i,            // Descontinuado pelo Google (Erro 404)
    /2\.0/i,                // Toda família 2.0 descontinuada pelo Google (Erro 404)
    /1\.5/i,                // Toda família 1.5 descontinuada pelo Google na v1beta (Erro 404)
    /vision/i,              // Modelos legados de visão sem chat estruturado
    /embedding/i,           // Apenas vetores
    /aqa/i,                 // Atribuição de perguntas
    /realtime/i,            // WebRTC streaming
    /tts/i,                 // Áudio puro
    /imagen/i,              // Geração de imagem
  ];

  const _runtimeBlacklistedModels = new Set();

  function isGeminiModelBlacklisted(modelName) {
    if (!modelName) return true;
    const clean = String(modelName).replace(/^models\//, '').trim().toLowerCase();
    if (_runtimeBlacklistedModels.has(clean)) return true;
    return BLACKLISTED_GEMINI_PATTERNS.some((pattern) => pattern.test(clean));
  }

  function sanitizeActiveGeminiModel() {
    const cur = String(state.settings.geminiModel || '').replace(/^models\//, '').trim();
    if (!cur || isGeminiModelBlacklisted(cur)) {
      state.settings.geminiModel = 'gemini-3.5-flash-lite';
      writeStore(KEYS.SETTINGS, state.settings);
      return 'gemini-3.5-flash-lite';
    }
    return cur;
  }

  function sleepMs(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  function scoreGeminiModel(cleanId) {
    let score = 0;
    const lower = (cleanId || '').toLowerCase();

    // Modelos banidos recebem pontuação negativa extrema
    if (isGeminiModelBlacklisted(lower)) return -999999;

    // Prioridade máxima para os modelos oficiais modernos da Google AI
    if (lower === 'gemini-3.5-flash-lite') score += 2600;
    else if (lower === 'gemini-3.1-flash-lite-preview') score += 2500;
    else if (lower === 'gemini-3.8-flash') score += 2400;
    else if (lower === 'gemini-3.1-pro-preview') score += 2300;
    else if (lower.includes('3.5')) score += 2000;
    else if (lower.includes('3.1')) score += 1800;
    else if (lower.includes('3.8')) score += 1600;
    else if (lower.includes('flash-lite')) score += 1400;
    else if (lower.includes('flash')) score += 800;
    else if (lower.includes('pro')) score += 500;
    else score += 100;

    return score;
  }

  function getAvailableGeminiModels() {
    const custom = state.settings.geminiDiscoveredModels;
    if (custom && Object.keys(custom).length > 0) {
      // Filtra dinamicamente para garantir que nenhum modelo banido permaneça
      const cleanCustom = {};
      Object.entries(custom).forEach(([k, v]) => {
        if (!isGeminiModelBlacklisted(k)) {
          cleanCustom[k] = v;
        }
      });
      if (Object.keys(cleanCustom).length > 0) {
        return cleanCustom;
      }
    }
    return { ...OFFICIAL_DEFAULT_MODELS };
  }

  async function fetchGeminiWithRetry(url, fetchOptions, maxRetries = 1, timeoutMs = 12000) {
    let lastError = null;
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeoutMs);
      try {
        const mergedOptions = {
          ...fetchOptions,
          signal: controller.signal,
        };
        const res = await fetch(url, mergedOptions);
        clearTimeout(timeoutId);
        // Códigos transitórios da Google Cloud: 503 (High Demand), 429 (Rate Limit), 502/504 (Gateway)
        if ((res.status === 503 || res.status === 429 || res.status === 502 || res.status === 504) && attempt < maxRetries) {
          const backoff = (attempt + 1) * 500 + Math.floor(Math.random() * 200);
          console.warn(`[Gemini Resiliência] HTTP ${res.status} (Carga alta no Google). Tentativa ${attempt + 1}/${maxRetries} em ${backoff}ms...`);
          await sleepMs(backoff);
          continue;
        }
        return res;
      } catch (err) {
        clearTimeout(timeoutId);
        lastError = err;
        if (err.name === 'AbortError') {
          console.warn(`[Gemini Resiliência] Timeout de ${timeoutMs}ms atingido para requisição.`);
          throw new Error(`Tempo limite de ${timeoutMs / 1000}s esgotado no modelo.`);
        }
        if (attempt < maxRetries) {
          const backoff = 500 + Math.floor(Math.random() * 200);
          await sleepMs(backoff);
          continue;
        }
        throw err;
      }
    }
    throw lastError || new Error('Falha de rede com Google AI.');
  }

  async function syncGeminiModelsFromGoogle(keyToUse = null, { silent = false } = {}) {
    const key = (keyToUse || state.settings.geminiKey || '').trim();
    if (!key) {
      if (!silent) showToast('Informe uma Chave Gemini válida para sincronizar modelos.', 'warning');
      return { success: false, reason: 'Chave não informada' };
    }
    if (!navigator.onLine) {
      if (!silent) showToast('Sem conexão à internet para sincronizar modelos do Google.', 'warning');
      return { success: false, reason: 'Sem internet' };
    }
    try {
      const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${encodeURIComponent(key)}`;
      const res = await fetchGeminiWithRetry(url, {}, 2);
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        const msg = err?.error?.message || `HTTP ${res.status}`;
        if (!silent) showToast(`Falha ao sincronizar modelos: ${msg}`, 'error');
        return { success: false, reason: msg };
      }
      const data = await res.json();
      const rawList = Array.isArray(data?.models) ? data.models : [];
      const generationModels = rawList.filter((m) => {
        const methods = m.supportedGenerationMethods || [];
        const name = (m.name || '').toLowerCase();
        return (
          methods.includes('generateContent') &&
          name.includes('gemini') &&
          !isGeminiModelBlacklisted(name)
        );
      });

      if (!generationModels.length) {
        if (!silent) showToast('Nenhum modelo de geração retornado pela Google AI.', 'info');
        return { success: true, count: 0, newModels: [] };
      }

      // Ordena por pontuação de estabilidade e disponibilidade
      generationModels.sort((a, b) => {
        const idA = (a.name || '').replace(/^models\//, '');
        const idB = (b.name || '').replace(/^models\//, '');
        return scoreGeminiModel(idB) - scoreGeminiModel(idA);
      });

      const currentGoogleModels = {};
      const newModels = [];

      generationModels.forEach((m) => {
        const cleanId = (m.name || '').replace(/^models\//, '');
        let label = m.displayName
          ? `${m.displayName} (${cleanId})`
          : `${cleanId} (Google AI Oficial)`;
        if (cleanId === 'gemini-3.1-flash-lite-preview') {
          label = 'Gemini 3.1 Flash Lite (Recomendado • Alta Disponibilidade)';
        } else if (cleanId === 'gemini-3.1-pro-preview') {
          label = 'Gemini 3.1 Pro Preview (Exegese Bíblica Profunda & Raciocínio)';
        } else if (cleanId === 'gemini-3.8-flash') {
          label = 'Gemini 3.8 Flash (Nova Geração Google AI)';
        } else if (cleanId === 'gemini-2.5-flash') {
          label = 'Gemini 2.5 Flash (Ultra-Rápido & Estável)';
        }

        if (!state.settings.geminiDiscoveredModels?.[cleanId]) {
          newModels.push(cleanId);
        }
        currentGoogleModels[cleanId] = label;
      });

      // Se nenhum modelo foi retornado, utiliza os padrões oficiais como fallback
      if (Object.keys(currentGoogleModels).length === 0) {
        Object.entries(OFFICIAL_DEFAULT_MODELS).forEach(([k, v]) => {
          if (!isGeminiModelBlacklisted(k)) {
            currentGoogleModels[k] = v;
          }
        });
      }

      state.settings.geminiDiscoveredModels = currentGoogleModels;
      state.settings.geminiLastModelSync = new Date().toISOString();

      // Sanitiza modelo ativo caso seja nulo, banido ou descontinuado
      const curMod = (state.settings.geminiModel || '').replace(/^models\//, '');
      if (!currentGoogleModels[curMod] || isGeminiModelBlacklisted(curMod)) {
        state.settings.geminiModel = Object.keys(currentGoogleModels)[0] || 'gemini-3.1-flash-lite-preview';
      }
      writeStore(KEYS.SETTINGS, state.settings);

      if (newModels.length > 0) {
        showToast(`🎉 ${newModels.length} modelo(s) atual(is) conectado(s): ${newModels.slice(0, 2).join(', ')}!`, 'success');
      } else if (!silent) {
        showToast(`✓ Catálogo atualizado: ${Object.keys(currentGoogleModels).length} modelos ativos operacionais para sua chave.`, 'success');
      }
      return { success: true, count: Object.keys(currentGoogleModels).length, newModels };
    } catch (e) {
      if (!silent) showToast(`Erro ao sincronizar modelos: ${e.message}`, 'error');
      return { success: false, reason: e.message };
    }
  }

  // Cascata Resiliente de Chamadas JSON ao Gemini
  // Cascata Resiliente de Chamadas JSON ao Gemini
  async function callGeminiJsonWithCascade(prompt, preferredModel, apiKey) {
    const verifiedModels = [
      'gemini-3.5-flash-lite',
      'gemini-3.1-flash-lite-preview',
      'gemini-3.8-flash',
      'gemini-3.1-pro-preview',
    ];

    let cleanPref = sanitizeActiveGeminiModel();
    if (preferredModel && !isGeminiModelBlacklisted(preferredModel)) {
      cleanPref = preferredModel.replace(/^models\//, '').trim();
    }

    const avail = getAvailableGeminiModels();
    const otherDiscovered = Object.keys(avail)
      .filter((m) => !verifiedModels.includes(m) && !isGeminiModelBlacklisted(m))
      .sort((a, b) => scoreGeminiModel(b) - scoreGeminiModel(a));

    const pool = [cleanPref, ...verifiedModels, ...otherDiscovered];

    const candidateSet = new Set();
    const uniqueCandidates = [];
    pool.forEach((m) => {
      const clean = (m || '').replace(/^models\//, '').trim();
      if (clean && !isGeminiModelBlacklisted(clean) && !candidateSet.has(clean) && uniqueCandidates.length < 5) {
        candidateSet.add(clean);
        uniqueCandidates.push(clean);
      }
    });

    let lastErrorMsg = '';

    for (let i = 0; i < uniqueCandidates.length; i++) {
      const model = uniqueCandidates[i];
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(apiKey)}`;
        const res = await fetchGeminiWithRetry(
          url,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
              generationConfig: {
                temperature: 0.35,
                responseMimeType: 'application/json',
              },
            }),
          },
          0, // 0 retries na esteira interativa: falha em um modelo -> salta IMEDIATAMENTE para o próximo
          12000 // Timeout rigoroso de 12 segundos por modelo
        );

        if (res.ok) {
          const data = await res.json();
          let txt = data?.candidates?.[0]?.content?.parts?.[0]?.text || '';
          txt = txt.trim().replace(/^```json\s*/i, '').replace(/^```/, '').replace(/```$/, '').trim();
          if (txt) {
            try {
              const parsed = JSON.parse(txt);
              if (parsed && typeof parsed === 'object') {
                if (state.settings.geminiModel !== model) {
                  state.settings.geminiModel = model;
                  writeStore(KEYS.SETTINGS, state.settings);
                }
                return { success: true, data: parsed, usedModel: model };
              }
            } catch (pErr) {
              console.warn(`[Gemini Cascade] JSON inválido de ${model}:`, pErr);
            }
          }
        } else {
          const errData = await res.json().catch(() => ({}));
          lastErrorMsg = errData?.error?.message || `HTTP ${res.status}`;
          console.warn(`[Gemini Cascade] ${model} retornou ${res.status}: ${lastErrorMsg}`);
          _runtimeBlacklistedModels.add(model);
          if (state.settings.geminiDiscoveredModels?.[model]) {
            delete state.settings.geminiDiscoveredModels[model];
            writeStore(KEYS.SETTINGS, state.settings);
          }
        }
      } catch (err) {
        lastErrorMsg = err.message || String(err);
        console.warn(`[Gemini Cascade] Falha no modelo ${model}:`, err);
      }
    }

    return { success: false, error: lastErrorMsg, usedModel: cleanPref };
  }

  // Compatibilidade legada chamando a cascata
  async function callGeminiJson(prompt, modelId, apiKey) {
    const res = await callGeminiJsonWithCascade(prompt, modelId, apiKey);
    if (!res.success) throw new Error(res.error || 'Falha ao processar solicitação no Gemini');
    return res.data;
  }

  async function generateOutlineWithAi(theme, ref, sermonType) {
    const cleanTheme = theme.trim() || 'Salmo 22 e a Crucificação de Jesus';
    const cleanRef = ref.trim() || 'Salmos 22 / Mateus 27:35-50';
    const cleanType = sermonType || 'Expositivo';
    const apiKey = state.settings.geminiKey?.trim();
    let chosenModel = sanitizeActiveGeminiModel();
    let lastApiError = '';

    const prompt = `Você é um renomado Teólogo e Doutor em Homilética Bíblica Cristã (ortodoxa, bíblica e conservadora).
Sua missão é construir um esboço homilético completo, bíblico e exegético, rigorosamente fiel ao texto sagrado fornecido:

- TEMA CENTRAL: "${cleanTheme}"
- TEXTO BÍBLICO BASE: "${cleanRef}"
- TIPO HOMILÉTICO: "${cleanType}"

DIRETRIZES DE EXEGESE E HOMILÉTICA OBRIGATÓRIAS:
1. FIDELIDADE TEXTUAL TOTAL: Todos os 5 pontos, explicações, ilustrações e aplicações devem brotar DIRETAMENTE do texto bíblico "${cleanRef}" e do tema "${cleanTheme}". Se o texto for uma parábola (ex: Mateus 25 talentos), aborde especificamente seus personagens, ações, ensinamentos e advertências. Não use generalismos padronizados.
2. ESTRUTURA: Forneça exatamente 5 divisões lógicas, sequenciais e progressivas que esgotem a passagem com profunda riqueza bíblica.
3. CADA PONTO DEVE CONTER:
   - title: Título homilético marcante numerado (ex: "1. A Soberana Concessão de Talentos e Recursos").
   - biblicalReference: Os versículos específicos da passagem que sustentam este ponto.
   - explanation: Exegese bíblica rica do texto, explicando o sentido histórico-gramatical, contexto original e verdade doutrinária.
   - illustration: Uma ilustração vívida, contemporânea ou histórica, altamente conectada com o ponto.
   - application: Aplicação prática, desafiadora e pastoral para a vida cristã diária.
4. INTRODUÇÃO E CONCLUSÃO: Introdução envolvente com gancho contextual da passagem; Conclusão que sintetize e recapitule os 5 pontos; Apelo pastoral ministerial ardente.
5. CONTEXTO HISTÓRICO E REFERÊNCIAS: Forneça o contexto histórico do livro/passagem e 5 referências bíblicas cruzadas relevantes.

Retorne ESTRITAMENTE um JSON válido sem nenhum caractere fora do bloco JSON:
{
  "title": "Título marcante para o sermão",
  "biblicalReference": "${cleanRef}",
  "sermonType": "${cleanType}",
  "historicalContext": "Contexto histórico, autor, data e público-alvo.",
  "crossReferences": ["Ref 1", "Ref 2", "Ref 3", "Ref 4", "Ref 5"],
  "introduction": "Introdução homilética impactante.",
  "blocks": [
    {"title": "1. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "2. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "3. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "4. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "5. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."}
  ],
  "conclusion": "Conclusão sintetizando as 5 divisões.",
  "appeal": "Apelo pastoral e ministerial."
}`;

    if (apiKey && navigator.onLine) {
      const cascadeRes = await callGeminiJsonWithCascade(prompt, chosenModel, apiKey);
      if (cascadeRes.success && cascadeRes.data && Array.isArray(cascadeRes.data.blocks) && cascadeRes.data.blocks.length >= 3) {
        const parsed = cascadeRes.data;
        return {
          title: parsed.title || cleanTheme,
          biblicalReference: parsed.biblicalReference || cleanRef,
          sermonType: parsed.sermonType || cleanType,
          historicalContext: parsed.historicalContext || '',
          crossReferences: Array.isArray(parsed.crossReferences) ? parsed.crossReferences : [],
          introduction: parsed.introduction || '',
          blocks: (parsed.blocks || []).map((b, idx) => ({
            id: uuid(),
            title: b.title || `${idx + 1}. Ponto`,
            biblicalReference: b.biblicalReference || cleanRef,
            explanation: b.explanation || '',
            illustration: b.illustration || '',
            application: b.application || '',
            orderIndex: idx,
          })),
          conclusion: parsed.conclusion || '',
          appeal: parsed.appeal || '',
          usedModel: `${cascadeRes.usedModel} (Google AI Oficial)`,
          isCloud: true,
        };
      }
      if (!cascadeRes.success && cascadeRes.error) {
        lastApiError = cascadeRes.error;
        showToast(`Google AI: ${cascadeRes.error}. Exibindo contingência local estruturada.`, 'warning');
      }
    } else if (!apiKey) {
      showToast('Chave Gemini Pro não configurada. Exibindo estrutura de contingência local.', 'warning');
    }

    // Fallback offline inteligente com consciência temática e bíblica
    const isTalents = /talento|mateus\s*25|mt\s*25/i.test(`${cleanTheme} ${cleanRef}`);
    let contingencyBlocks;
    let contingencyIntro;
    let contingencyHistorical;
    let contingencyConcl;
    let contingencyAppeal;

    if (isTalents) {
      contingencyHistorical = 'Evangelho de Mateus, capítulo 25. Inserido no Sermão Escatológico proferido por Jesus no Monte das Oliveiras, instruindo os discípulos sobre a vigilância ativa, mordomia e prestação de contas antes do Juízo Final.';
      contingencyIntro = `Na Parábola dos Talentos (Mateus 25.14-30), Jesus confronta a inércia e nos convoca a uma mordomia ativa, fiel e diligente, advertindo que o que recebemos da graça divina deve ser investido para a glória do Reino até a Sua volta.`;
      contingencyBlocks = [
        { id: uuid(), title: '1. A Soberana Concessão de Recursos Conforme a Capacidade', biblicalReference: 'Mateus 25:14-15', explanation: 'O Senhor distribui Seus dons e bens com soberania e profundo conhecimento da capacidade de cada servo. Nada nos pertence por mérito; tudo nos é confiado pela graça para ser administrado com diligência.', illustration: 'O proprietário que confia fundos a administradores esperando responsabilidade e visão de Reino.', application: 'Reconheça seus dons, tempo e recursos como concessões divinas que exigem gestão santa e consagrada.', orderIndex: 0 },
        { id: uuid(), title: '2. A Diligência e Produtividade dos Servos Fiéis', biblicalReference: 'Mateus 25:16-17', explanation: 'Os servos que receberam cinco e dois talentos negociaram imediatamente. A fidelidade do evangelho não é estática ou passiva, mas corajosa, proativa e geradora de frutos espirituais.', illustration: 'O agricultor que não guarda os grãos em saco fechado, mas os semeia com fé na certeza da colheita.', application: 'Não enterre seus dons por comodismo; tome iniciativas práticas para servir na igreja e abençoar vidas.', orderIndex: 1 },
        { id: uuid(), title: '3. O Perigo do Medo Paralisante e da Distorção de Deus', biblicalReference: 'Mateus 25:18, 24-25', explanation: 'O servo mau escondeu seu talento por medo e acusou o senhor de ser injusto e duro. Uma visão legalista e distorcida do caráter bondoso de Deus gera paralisia ministerial e negligência espiritual.', illustration: 'A bússola guardada no bolso que impede o marinheiro de navegar rumo ao porto seguro.', application: 'Renuncie ao espírito de covardia e ao medo de errar; Deus acolhe corações que se dispõem a arriscar pela fé.', orderIndex: 2 },
        { id: uuid(), title: '4. A Alegria da Prestação de Contas e a Entrada no Gozo do Senhor', biblicalReference: 'Mateus 25:19-23', explanation: 'O retorno do Senhor é certo. A recompensa divina ("Foste fiel no pouco, sobre o muito te colocarei") não avalia volume absoluto, mas fidelidade e zelo integral em relação ao que foi recebido.', illustration: 'A condecoração solene do soldado leal que guardou seu posto com firmeza durante toda a vigília.', application: 'Viva cada dia com a perspectiva da eternidade: a maior alegria do cristão é ouvir a aprovação de Cristo.', orderIndex: 3 },
        { id: uuid(), title: '5. A Solene Advertência contra a Omissão e Negligência', biblicalReference: 'Mateus 25:26-30', explanation: 'No Reino de Deus, a inação deliberada é classificada como pecado de infidelidade. A negligência acarreta a perda do que se recebeu e a solene exclusão da comunhão eterna do Mestre.', illustration: 'A ferramenta esquecida no pátio que enferruja e perde sua utilidade no projeto da edificação.', application: 'Examine seu coração: você está multiplicando o evangelho ou enterrando o chamado que Deus lhe entregou?', orderIndex: 4 },
      ];
      contingencyConcl = 'A Parábola dos Talentos nos ensina que a salvação pela graça se manifesta em uma vida de responsabilidade e fruto. No grande Dia, o Senhor não aceitará desculpas, mas buscará fidelidade.';
      contingencyAppeal = 'Não enterre o que Deus colocou em suas mãos. Arrependa-se da omissão e consagre hoje sua vida, talentos e ministério totalmente a Jesus Cristo.';
    } else {
      contingencyHistorical = `Passagem sagrada inserida no contexto canônico de ${cleanRef}, revelando a soberania de Deus e o chamado pactual do evangelho.`;
      contingencyIntro = `Ao examinarmos ${cleanRef} sob o tema "${cleanTheme}", contemplamos a revelação das Escrituras para restaurar a fé, consolar a alma e alinhar a igreja ao propósito de Cristo.`;
      contingencyBlocks = [
        { id: uuid(), title: `1. O Cenário Revelado em ${cleanRef}`, biblicalReference: `${cleanRef} (Parte 1)`, explanation: `A revelação bíblica parte da realidade humana concreta, mostrando que Deus intervém na história com graça e soberania.`, illustration: 'O arquiteto que analisa o terreno antes de erguer os pilares de sustentação.', application: 'Apresente suas preocupações e lutas diante do Senhor com sinceridade.', orderIndex: 0 },
        { id: uuid(), title: '2. O Fundamento Imutável da Aliança', biblicalReference: `${cleanRef} (Parte 2)`, explanation: `As promessas do Senhor não oscilam com as circunstâncias; estão ancoradas no Seu próprio caráter fiel.`, illustration: 'A rocha firme no litoral que resiste intacta às marés da tempestade.', application: 'Tome decisões apoiado na Palavra de Deus e não na instabilidade dos sentimentos.', orderIndex: 1 },
        { id: uuid(), title: '3. A Centralidade Redentora de Cristo', biblicalReference: 'João 14:6 • Colossenses 1:19-20', explanation: `Toda a Escritura aponta para Jesus. Na cruz e ressurreição encontramos perdão pleno e reconciliação.`, illustration: 'A chave-mestra que abre a cela do prisioneiro e lhe devolve a liberdade.', application: 'Descanse na obra consumada de Cristo e abandone o peso da culpa.', orderIndex: 2 },
        { id: uuid(), title: '4. A Renovação pelo Espírito Santo', biblicalReference: 'Gálatas 5:22-25 • Romanos 12:1-2', explanation: `O evangelho transforma mente, afeições e conduta de dentro para fora pelo poder do Espírito.`, illustration: 'A seiva viva que percorre a árvore e faz brotar frutos saudáveis na estação certa.', application: 'Permita que o Espírito trate áreas secretas e produza arrependimento genuíno.', orderIndex: 3 },
        { id: uuid(), title: '5. Testemunho e Obediência Prática', biblicalReference: 'Mateus 5:14-16 • Tiago 1:22', explanation: `A proclamação pastoral conduz à ação prática no lar, no trabalho e na comunhão da igreja.`, illustration: 'A candeia colocada no alto para iluminar todo o ambiente ao redor.', application: 'Viva esta mensagem nesta semana através do perdão, serviço e testemunho cristão.', orderIndex: 4 },
      ];
      contingencyConcl = `A mensagem de ${cleanRef} assegura que a Palavra de Deus nunca volta vazia e cumpre o propósito soberano em Cristo.`;
      contingencyAppeal = 'Se você deseja renovar sua aliança com Deus hoje, entregue seu coração a Cristo em oração.';
    }

    return {
      title: cleanTheme,
      biblicalReference: cleanRef,
      sermonType: cleanType,
      historicalContext: contingencyHistorical,
      crossReferences: isTalents
        ? ['Lucas 19:11-27', 'Romanos 14:12', '1 Coríntios 4:1-2', '2 Timóteo 4:7-8', '1 Pedro 4:10']
        : ['Salmos 119:105', 'Romanos 8:31-39', 'Isaías 40:28-31', 'Hebreus 4:14-16', '2 Coríntios 12:9-10'],
      introduction: contingencyIntro,
      blocks: contingencyBlocks,
      conclusion: contingencyConcl,
      appeal: contingencyAppeal,
      usedModel: lastApiError
        ? `Contingência Offline Local (Falha Google AI: ${lastApiError})`
        : 'Contingência Offline Local (Configure a Chave Pro)',
      isCloud: false,
      hasError: Boolean(lastApiError),
      errorMessage: lastApiError || '',
    };
  }

  // =========================================================================
  // BÍBLIA SAGRADA — CARREGAMENTO E BUSCA
  // =========================================================================
  async function loadBibleVersion(versionId) {
    const v = (versionId || 'ARC').toUpperCase();
    if (state.bible.cache[v]) return state.bible.cache[v];
    const meta = BIBLE_VERSIONS.find((x) => x.id === v) || BIBLE_VERSIONS[0];
    state.bible.loading = true;
    try {
      const res = await fetch(meta.file);
      const data = await res.json();
      state.bible.cache[v] = data;
      return data;
    } finally {
      state.bible.loading = false;
    }
  }

  function getBookData(booksArr, bookId) {
    const target = (bookId || 'sl').toLowerCase();
    return booksArr.find((b) => (b.abbrev || '').toLowerCase() === target) || booksArr[0];
  }

  function getChapterVerses(booksArr, bookId, chapterNum) {
    const bMeta = CANONICAL_BOOKS.find((b) => b.id === bookId) || CANONICAL_BOOKS[18];
    const bData = getBookData(booksArr, bookId);
    if (!bData || !Array.isArray(bData.chapters)) return [];
    const chIdx = Math.max(0, Math.min(bData.chapters.length - 1, chapterNum - 1));
    const versesArr = bData.chapters[chIdx] || [];
    return versesArr.map((txt, i) => ({
      bookId: bMeta.id,
      bookName: bMeta.name,
      chapter: chIdx + 1,
      verse: i + 1,
      text: txt,
      version: state.settings.bibleVersion,
      reference: `${bMeta.name} ${chIdx + 1}:${i + 1}`,
    }));
  }

  // =========================================================================
  // UI HELPERS: TOAST, MODAL, PRINT, WHATSAPP
  // =========================================================================
  function showToast(message, type = 'info', undoCallback = null) {
    const container = document.getElementById('toast-container');
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.innerHTML = `<span>${esc(message)}</span>`;
    if (undoCallback) {
      const btn = document.createElement('button');
      btn.className = 'btn btn-xs btn-gold';
      btn.textContent = 'Desfazer';
      btn.onclick = () => {
        undoCallback();
        el.remove();
      };
      el.appendChild(btn);
    }
    container.appendChild(el);
    setTimeout(() => el.remove(), undoCallback ? 5500 : 3200);
  }

  function openModal(html, onBind) {
    const backdrop = document.getElementById('modal-backdrop');
    const sheet = document.getElementById('modal-sheet');
    sheet.innerHTML = html;
    backdrop.classList.remove('hidden');
    if (onBind) onBind(sheet);
  }

  function closeModal() {
    document.getElementById('modal-backdrop').classList.add('hidden');
    document.getElementById('modal-sheet').innerHTML = '';
  }

  function confirmDeleteSermon(sermon, onAfterDelete) {
    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title" style="color:var(--danger)">🗑️ Excluir Sermão?</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <p style="margin:0 0 8px;">Tem certeza que deseja excluir <strong>"${esc(sermon.title)}"</strong>?</p>
      <p style="margin:0 0 18px;font-size:13px;color:var(--text-muted);">Você poderá desfazer esta ação logo em seguida se excluir por engano.</p>
      <div style="display:flex;gap:10px;justify-content:flex-end;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-danger-solid" id="confirm-del-btn">Excluir</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#confirm-del-btn').onclick = () => {
          const removed = deleteSermonById(sermon.id);
          closeModal();
          if (onAfterDelete) onAfterDelete();
          else renderMain();
          if (removed) {
            showToast(`Sermão "${removed.title}" excluído.`, 'info', () => {
              restoreSermonObj(removed);
              renderMain();
              showToast('Sermão restaurado!', 'success');
            });
          }
        };
      }
    );
  }

  function confirmDeleteTemplate(tpl) {
    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title" style="color:var(--danger)">🗑️ Excluir Modelo?</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <p style="margin:0 0 8px;">Deseja excluir o modelo <strong>"${esc(tpl.title)}"</strong>?</p>
      <p style="margin:0 0 18px;font-size:13px;color:var(--text-muted);">O modelo será removido do Acervo de Modelos e da lista inicial.</p>
      <div style="display:flex;gap:10px;justify-content:flex-end;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-danger-solid" id="confirm-del-tpl">Excluir</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#confirm-del-tpl').onclick = () => {
          deleteTemplateById(tpl.id);
          closeModal();
          renderMain();
          showToast(`Modelo "${tpl.title}" excluído.`, 'info', () => {
            restoreTemplateById(tpl.id);
            renderMain();
            showToast('Modelo restaurado!', 'success');
          });
        };
      }
    );
  }

  function shareSermonWhatsApp(sermon) {
    const lines = [
      `📖 *${sermon.title}*`,
      `📌 *Texto-Base:* ${sermon.biblicalReference} | *Tipo:* ${sermon.sermonType}`,
      '',
    ];
    if (sermon.introduction) lines.push(`*Introdução:*\n${sermon.introduction}\n`);
    sermon.blocks.forEach((b, i) => {
      lines.push(`*${b.title || `Ponto ${i + 1}`}* (${b.biblicalReference || ''})`);
      if (b.explanation) lines.push(b.explanation);
      if (b.illustration) lines.push(`💡 _Ilustração:_ ${b.illustration}`);
      if (b.application) lines.push(`🎯 _Aplicação:_ ${b.application}`);
      lines.push('');
    });
    if (sermon.conclusion) lines.push(`*Conclusão:*\n${sermon.conclusion}\n`);
    if (sermon.appeal) lines.push(`*Apelo:*\n${sermon.appeal}`);
    const url = `https://wa.me/?text=${encodeURIComponent(lines.join('\n'))}`;
    window.open(url, '_blank');
  }

  function printSermonPdf(sermon) {
    const area = document.getElementById('print-area');
    area.innerHTML = `
      <div style="font-size:11px;color:#64748b;margin-bottom:6px;">PREGADOR PRO — ESBOÇO HOMILÉTICO • ${sermon.estimatedDurationMinutes} min</div>
      <h1 style="margin:0 0 6px;font-size:22px;">${esc(sermon.title)}</h1>
      <div style="margin-bottom:14px;font-weight:bold;color:#1e3a8a;">Texto Base: ${esc(sermon.biblicalReference)} | ${esc(sermon.sermonType)} | ${esc(sermon.category)}</div>
      <hr>
      ${sermon.introduction ? `<h3>1. Introdução</h3><p>${esc(sermon.introduction)}</p>` : ''}
      <h3>2. Desenvolvimento (${sermon.blocks.length} Pontos)</h3>
      ${sermon.blocks.map((b, i) => `
        <div style="margin:12px 0;padding:10px;border-left:3px solid #1e3a8a;background:#f8fafc;">
          <strong>${esc(b.title || `Ponto ${i + 1}`)}</strong> <em>(${esc(b.biblicalReference)})</em>
          ${b.explanation ? `<p><strong>Explanação:</strong> ${esc(b.explanation)}</p>` : ''}
          ${b.illustration ? `<p><strong>Ilustração:</strong> ${esc(b.illustration)}</p>` : ''}
          ${b.application ? `<p><strong>Aplicação:</strong> ${esc(b.application)}</p>` : ''}
        </div>
      `).join('')}
      ${sermon.conclusion ? `<h3>3. Conclusão</h3><p>${esc(sermon.conclusion)}</p>` : ''}
      ${sermon.appeal ? `<h3>4. Apelo</h3><p><em>${esc(sermon.appeal)}</em></p>` : ''}
    `;
    window.print();
  }

  // =========================================================================
  // MODO PÚLPITO FULLSCREEN (COM WAKELOCK + CRONÔMETRO)
  // =========================================================================
  async function openPulpitMode(sermon) {
    state.pulpit.sermon = sermon;
    state.pulpit.timerSeconds = 0;
    state.pulpit.timerRunning = true;
    state.pulpit.autoScroll = false;
    state.pulpit.autoScrollSpeed = 1;
    clearInterval(state.pulpit.timerInterval);
    clearInterval(state.pulpit.autoScrollInterval);

    state.pulpit.timerInterval = setInterval(() => {
      if (state.pulpit.timerRunning) {
        state.pulpit.timerSeconds++;
        const el = document.getElementById('pulpit-timer-display');
        if (el) {
          el.textContent = formatTimer(state.pulpit.timerSeconds);
          if (state.pulpit.timerSeconds >= 2700) {
            el.className = 'pulpit-timer timer-danger';
          } else if (state.pulpit.timerSeconds >= 2100) {
            el.className = 'pulpit-timer timer-warning';
          } else {
            el.className = 'pulpit-timer';
          }
        }
      }
    }, 1000);

    try {
      if ('wakeLock' in navigator) {
        state.pulpit.wakeLock = await navigator.wakeLock.request('screen');
      }
    } catch (_) {}

    const overlay = document.getElementById('pulpit-overlay');
    overlay.classList.remove('hidden');

    // Registrar atalhos de teclado para navegação fluida no púlpito
    if (state.pulpit.keyHandler) {
      window.removeEventListener('keydown', state.pulpit.keyHandler);
    }
    state.pulpit.keyHandler = (e) => {
      if (overlay.classList.contains('hidden')) return;
      const scrollEl = document.getElementById('pulpit-scroll-container');
      if (e.key === 'Escape') {
        e.preventDefault();
        closePulpitMode();
      } else if (e.code === 'Space' && (e.target === document.body || e.target === scrollEl)) {
        e.preventDefault();
        togglePulpitAutoScroll();
      } else if (e.key === 'ArrowDown' || e.key === 'PageDown') {
        if (scrollEl) scrollEl.scrollBy({ top: 260, behavior: 'smooth' });
      } else if (e.key === 'ArrowUp' || e.key === 'PageUp') {
        if (scrollEl) scrollEl.scrollBy({ top: -260, behavior: 'smooth' });
      } else if (e.key === 'Home') {
        if (scrollEl) scrollEl.scrollTo({ top: 0, behavior: 'smooth' });
      } else if (e.key === 'End') {
        if (scrollEl) scrollEl.scrollTo({ top: scrollEl.scrollHeight, behavior: 'smooth' });
      } else if (e.key.toLowerCase() === 't') {
        state.pulpit.timerRunning = !state.pulpit.timerRunning;
        const btn = document.getElementById('pulpit-timer-toggle');
        if (btn) btn.textContent = state.pulpit.timerRunning ? '⏸' : '▶';
      }
    };
    window.addEventListener('keydown', state.pulpit.keyHandler);

    renderPulpit();
  }

  function closePulpitMode() {
    clearInterval(state.pulpit.timerInterval);
    clearInterval(state.pulpit.autoScrollInterval);
    state.pulpit.autoScroll = false;
    if (state.pulpit.keyHandler) {
      window.removeEventListener('keydown', state.pulpit.keyHandler);
      state.pulpit.keyHandler = null;
    }
    if (state.pulpit.wakeLock) {
      state.pulpit.wakeLock.release().catch(() => {});
      state.pulpit.wakeLock = null;
    }
    state.pulpit.sermon = null;
    document.getElementById('pulpit-overlay').classList.add('hidden');
  }

  function formatTimer(sec) {
    const m = String(Math.floor(sec / 60)).padStart(2, '0');
    const s = String(sec % 60).padStart(2, '0');
    return `${m}:${s}`;
  }

  function togglePulpitAutoScroll() {
    state.pulpit.autoScroll = !state.pulpit.autoScroll;
    const btn = document.getElementById('pulpit-btn-autoscroll');
    const scrollEl = document.getElementById('pulpit-scroll-container');
    clearInterval(state.pulpit.autoScrollInterval);

    if (state.pulpit.autoScroll) {
      if (btn) {
        btn.innerHTML = '⏸ Pausar';
        btn.classList.add('active');
      }
      const speed = state.pulpit.autoScrollSpeed || 1;
      const step = speed === 1 ? 1 : speed === 1.5 ? 2 : 3.2;
      state.pulpit.autoScrollInterval = setInterval(() => {
        if (!state.pulpit.autoScroll) {
          clearInterval(state.pulpit.autoScrollInterval);
          return;
        }
        if (scrollEl) {
          scrollEl.scrollTop += step;
          if (scrollEl.scrollTop + scrollEl.clientHeight >= scrollEl.scrollHeight - 4) {
            togglePulpitAutoScroll();
          }
        }
      }, 30);
    } else {
      if (btn) {
        btn.innerHTML = '▶ Auto-Rolagem';
        btn.classList.remove('active');
      }
    }
  }

  function renderPulpit() {
    const s = state.pulpit.sermon;
    if (!s) return;
    const overlay = document.getElementById('pulpit-overlay');
    const modeClass =
      state.settings.pulpitTheme === 'amber'
        ? 'pulpit-amber'
        : state.settings.pulpitTheme === 'light'
          ? 'pulpit-light'
          : '';
    overlay.className = `pulpit-overlay ${modeClass}`;
    const fs = state.settings.pulpitFont || 22;

    overlay.innerHTML = `
      <!-- Topbar Fixa e Elegante com 2 Camadas Perfeitamente Alinhadas no Mobile -->
      <header class="pulpit-topbar">
        <div class="pulpit-topbar-main">
          <button class="btn btn-sm btn-outline" id="pulpit-exit-btn" title="Atalho: Esc">← Sair</button>
          
          <div class="pulpit-timer-badge">
            <span style="font-size:16px;">⏱</span>
            <span id="pulpit-timer-display" class="pulpit-timer">${formatTimer(state.pulpit.timerSeconds)}</span>
            <button class="btn btn-xs btn-outline" id="pulpit-timer-toggle" style="padding:2px 8px;min-height:28px;" title="Atalho: T">${state.pulpit.timerRunning ? '⏸' : '▶'}</button>
            <button class="btn btn-xs btn-outline" id="pulpit-timer-reset" style="padding:2px 8px;min-height:28px;" title="Reiniciar cronômetro">↺</button>
          </div>

          <button class="btn btn-sm btn-emerald" id="pulpit-finish-btn" style="min-height:34px;">✓ Concluir</button>
        </div>

        <div class="pulpit-topbar-strip">
          <!-- Teleprompter Auto-Scroll -->
          <div style="display:inline-flex;align-items:center;gap:4px;flex-shrink:0;">
            <button class="pulpit-autoscroll-btn ${state.pulpit.autoScroll ? 'active' : ''}" id="pulpit-btn-autoscroll" title="Atalho: Espaço">
              ${state.pulpit.autoScroll ? '⏸ Pausar' : '▶ Auto-Rolagem'}
            </button>
            <button class="btn btn-xs btn-outline" id="pulpit-speed-btn" title="Alterar velocidade de rolagem" style="min-height:34px;padding:4px 10px;">
              ${state.pulpit.autoScrollSpeed || 1}x
            </button>
          </div>

          <!-- Ajuste de Fonte Sem Perder o Ponto de Leitura -->
          <div class="pulpit-font-box" style="flex-shrink:0;">
            <button class="btn btn-xs btn-outline" id="pulpit-font-dec" style="min-height:30px;padding:2px 8px;">A-</button>
            <span id="pulpit-font-indicator" style="font-size:13px;font-weight:800;min-width:38px;text-align:center;">${fs}px</span>
            <button class="btn btn-xs btn-outline" id="pulpit-font-inc" style="min-height:30px;padding:2px 8px;">A+</button>
          </div>

          <!-- Tema Visual -->
          <button class="btn btn-xs btn-outline" id="pulpit-theme-cycle" style="min-height:34px;flex-shrink:0;">
            ${state.settings.pulpitTheme === 'amber' ? '📜 Sépia' : state.settings.pulpitTheme === 'light' ? '☀️ Claro' : '🌙 OLED'}
          </button>

          <!-- Largura Adaptativa Automática / Foco -->
          <button class="btn btn-xs btn-outline" id="pulpit-width-toggle" title="Alternar largura (Fluida / Foco / Tela Cheia)" style="min-height:34px;flex-shrink:0;">
            ${state.settings.pulpitWidth === 'focus' ? '↔ Foco' : state.settings.pulpitWidth === 'full' ? '↔ 100%' : '↔ Fluida'}
          </button>
        </div>
      </header>

      <!-- Barra de Progresso Homilético Fina -->
      <div class="pulpit-progress-track">
        <div id="pulpit-progress-bar" class="pulpit-progress-bar"></div>
      </div>

      <!-- Container com ZERO Scrollbar (100% de Rolagem Fluida) -->
      <div id="pulpit-scroll-container" class="pulpit-scroll-container">
        <main id="pulpit-body" class="pulpit-body width-${state.settings.pulpitWidth || 'fluid'}" style="font-size:${fs}px;">
          <!-- Card de Cabeçalho do Sermão -->
          <section id="pulpit-sec-header" class="pulpit-card pulpit-header-card">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:12px;flex-wrap:wrap;">
              <span class="gold-pill" style="font-size:12px;padding:4px 10px;">${esc(s.biblicalReference || 'Texto Bíblico')}</span>
              <span class="tag tag-blue" style="font-size:12px;">${esc(s.sermonType || 'Expositivo')}</span>
              ${s.durationMinutes ? `<span class="tag tag-muted" style="font-size:12px;">⏱ ~${s.durationMinutes} min</span>` : ''}
              <span class="tag tag-muted" style="font-size:12px;">📅 ${esc(formatPtDate())}</span>
            </div>
            <h1 style="margin:0;font-size:1.8em;font-weight:900;line-height:1.25;letter-spacing:-0.5px;">${esc(s.title)}</h1>
          </section>

          <!-- Introdução -->
          ${s.introduction ? `
            <section id="pulpit-sec-intro" class="pulpit-card pulpit-intro-card">
              <div style="display:flex;align-items:center;gap:8px;font-size:0.85em;font-weight:800;color:#60a5fa;letter-spacing:0.5px;text-transform:uppercase;margin-bottom:12px;">
                <span>📖</span> Introdução Homilética
              </div>
              <p style="margin:0;line-height:1.75;">${esc(s.introduction)}</p>
            </section>
          ` : ''}

          <!-- Pontos Principais (Blocos Exegéticos) -->
          ${(s.blocks || []).map((b, i) => `
            <section id="pulpit-sec-point-${i}" class="pulpit-card pulpit-block-card">
              <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:14px;flex-wrap:wrap;">
                <span class="point-pill" style="font-size:13px;padding:4px 12px;">PONTO ${i + 1}</span>
                ${b.biblicalReference ? `<span style="font-size:0.85em;color:var(--gold);font-weight:700;font-style:italic;">📖 ${esc(b.biblicalReference)}</span>` : ''}
              </div>

              <h2 style="margin:0 0 16px;font-size:1.3em;font-weight:800;color:var(--gold);line-height:1.3;">
                ${esc(b.title || `Ponto ${i + 1}`)}
              </h2>

              ${b.explanation ? `
                <div style="margin-bottom:18px;line-height:1.75;opacity:0.96;">
                  ${esc(b.explanation)}
                </div>
              ` : ''}

              ${(b.illustration || b.application) ? `
                <div class="pulpit-callouts-grid">
                  ${b.illustration ? `
                    <div class="pulpit-callout illustration">
                      <div class="pulpit-callout-head">
                        <span>💡</span> Ilustração Prática
                      </div>
                      <div style="line-height:1.65;opacity:0.95;">
                        ${esc(b.illustration)}
                      </div>
                    </div>
                  ` : ''}

                  ${b.application ? `
                    <div class="pulpit-callout application">
                      <div class="pulpit-callout-head">
                        <span>🎯</span> Aplicação Ministerial
                      </div>
                      <div style="line-height:1.65;opacity:0.95;">
                        ${esc(b.application)}
                      </div>
                    </div>
                  ` : ''}
                </div>
              ` : ''}
            </section>
          `).join('')}

          <!-- Conclusão -->
          ${s.conclusion ? `
            <section id="pulpit-sec-conclusion" class="pulpit-card pulpit-conclusion-card">
              <div style="display:flex;align-items:center;gap:8px;font-size:0.85em;font-weight:800;color:#22d3ee;letter-spacing:0.5px;text-transform:uppercase;margin-bottom:12px;">
                <span>🏁</span> Conclusão & Síntese
              </div>
              <p style="margin:0;line-height:1.75;">${esc(s.conclusion)}</p>
            </section>
          ` : ''}

          <!-- Apelo Ministerial -->
          ${s.appeal ? `
            <section id="pulpit-sec-appeal" class="pulpit-card pulpit-appeal-card">
              <div style="display:flex;align-items:center;gap:8px;font-size:0.9em;font-weight:900;color:var(--gold);letter-spacing:0.5px;text-transform:uppercase;margin-bottom:12px;">
                <span>🔥</span> Apelo Ministerial & Decisão
              </div>
              <p style="margin:0;line-height:1.75;font-weight:500;">${esc(s.appeal)}</p>
            </section>
          ` : ''}
        </main>
      </div>

      <!-- Barra Flutuante de Atalhos Rápidos (Jump Navigation) -->
      <nav class="pulpit-floating-nav" aria-label="Navegação do Púlpito">
        <button class="pulpit-nav-chip" data-jump="#pulpit-sec-header">Topo</button>
        ${s.introduction ? `<button class="pulpit-nav-chip" data-jump="#pulpit-sec-intro">Intro</button>` : ''}
        ${(s.blocks || []).map((_, i) => `<button class="pulpit-nav-chip" data-jump="#pulpit-sec-point-${i}">P${i + 1}</button>`).join('')}
        ${s.conclusion ? `<button class="pulpit-nav-chip" data-jump="#pulpit-sec-conclusion">Conclusão</button>` : ''}
        ${s.appeal ? `<button class="pulpit-nav-chip" data-jump="#pulpit-sec-appeal">Apelo</button>` : ''}
      </nav>
    `;

    // Vincular Eventos
    const scrollContainer = overlay.querySelector('#pulpit-scroll-container');
    const progressBar = overlay.querySelector('#pulpit-progress-bar');

    // Atualização em tempo real da barra de progresso no scroll
    if (scrollContainer && progressBar) {
      scrollContainer.addEventListener('scroll', () => {
        const max = scrollContainer.scrollHeight - scrollContainer.clientHeight;
        if (max > 0) {
          const pct = Math.min(100, Math.max(0, (scrollContainer.scrollTop / max) * 100));
          progressBar.style.width = pct + '%';
        }
      }, { passive: true });
    }

    // Navegação rápida pelos chips flutuantes
    overlay.querySelectorAll('.pulpit-nav-chip[data-jump]').forEach((chip) => {
      chip.onclick = (e) => {
        e.preventDefault();
        const targetId = chip.getAttribute('data-jump');
        const targetEl = overlay.querySelector(targetId);
        if (targetEl) {
          targetEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      };
    });

    overlay.querySelector('#pulpit-exit-btn').onclick = closePulpitMode;

    overlay.querySelector('#pulpit-timer-toggle').onclick = () => {
      state.pulpit.timerRunning = !state.pulpit.timerRunning;
      const btn = overlay.querySelector('#pulpit-timer-toggle');
      if (btn) btn.textContent = state.pulpit.timerRunning ? '⏸' : '▶';
    };

    overlay.querySelector('#pulpit-timer-reset').onclick = () => {
      state.pulpit.timerSeconds = 0;
      const el = overlay.querySelector('#pulpit-timer-display');
      if (el) {
        el.textContent = '00:00';
        el.className = 'pulpit-timer';
      }
    };

    overlay.querySelector('#pulpit-btn-autoscroll').onclick = togglePulpitAutoScroll;

    overlay.querySelector('#pulpit-speed-btn').onclick = () => {
      const speeds = [1, 1.5, 2];
      const cur = state.pulpit.autoScrollSpeed || 1;
      const next = speeds[(speeds.indexOf(cur) + 1) % speeds.length];
      state.pulpit.autoScrollSpeed = next;
      const btn = overlay.querySelector('#pulpit-speed-btn');
      if (btn) btn.textContent = `${next}x`;
      if (state.pulpit.autoScroll) {
        togglePulpitAutoScroll();
        togglePulpitAutoScroll();
      }
    };

    // Ajuste de fonte dinâmico sem recarregar a tela (mantém o scroll onde está)
    overlay.querySelector('#pulpit-font-dec').onclick = () => {
      state.settings.pulpitFont = Math.max(16, (state.settings.pulpitFont || 22) - 2);
      writeStore(KEYS.SETTINGS, state.settings);
      const b = overlay.querySelector('#pulpit-body');
      const ind = overlay.querySelector('#pulpit-font-indicator');
      if (b) b.style.fontSize = `${state.settings.pulpitFont}px`;
      if (ind) ind.textContent = `${state.settings.pulpitFont}px`;
    };

    overlay.querySelector('#pulpit-font-inc').onclick = () => {
      state.settings.pulpitFont = Math.min(38, (state.settings.pulpitFont || 22) + 2);
      writeStore(KEYS.SETTINGS, state.settings);
      const b = overlay.querySelector('#pulpit-body');
      const ind = overlay.querySelector('#pulpit-font-indicator');
      if (b) b.style.fontSize = `${state.settings.pulpitFont}px`;
      if (ind) ind.textContent = `${state.settings.pulpitFont}px`;
    };

    // Alternar tema sem perder a posição do sermão
    overlay.querySelector('#pulpit-theme-cycle').onclick = () => {
      const order = ['oled', 'amber', 'light'];
      const next = order[(order.indexOf(state.settings.pulpitTheme) + 1) % order.length];
      state.settings.pulpitTheme = next;
      writeStore(KEYS.SETTINGS, state.settings);
      overlay.className = `pulpit-overlay ${next === 'amber' ? 'pulpit-amber' : next === 'light' ? 'pulpit-light' : ''}`;
      const btn = overlay.querySelector('#pulpit-theme-cycle');
      if (btn) {
        btn.textContent = next === 'amber' ? '📜 Sépia' : next === 'light' ? '☀️ Claro' : '🌙 OLED';
      }
    };

    // Alternar largura (Fluida / Foco / Tela Cheia) sem recarregar a tela
    overlay.querySelector('#pulpit-width-toggle').onclick = () => {
      const modes = ['fluid', 'focus', 'full'];
      const cur = state.settings.pulpitWidth || 'fluid';
      const next = modes[(modes.indexOf(cur) + 1) % modes.length];
      state.settings.pulpitWidth = next;
      writeStore(KEYS.SETTINGS, state.settings);
      const b = overlay.querySelector('#pulpit-body');
      if (b) {
        b.className = `pulpit-body width-${next}`;
      }
      const btn = overlay.querySelector('#pulpit-width-toggle');
      if (btn) {
        btn.textContent = next === 'focus' ? '↔ Foco' : next === 'full' ? '↔ 100%' : '↔ Fluida';
      }
    };

    overlay.querySelector('#pulpit-finish-btn').onclick = () => {
      saveSermon({
        ...s,
        preachCount: (s.preachCount || 0) + 1,
        lastPreachedAt: new Date().toISOString(),
        status: 'ready',
      });
      closePulpitMode();
      renderMain();
      showToast('Ministração registrada com sucesso no histórico!', 'success');
    };
  }

  // =========================================================================
  // ASSISTENTE IA GEMINI PRO (MODAL)
  // =========================================================================
  function openAiModal(onApplyToEditor = null) {
    const modelName = sanitizeActiveGeminiModel();
    const hasKey = Boolean(state.settings.geminiKey?.trim());
    const outline = state.ai.outline;

    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;min-width:0;">
          <span style="font-size:22px;">✨</span>
          <div>
            <h3 class="modal-title">Assistente Homilético IA</h3>
            <span class="mini-badge ${hasKey ? '' : 'offline'}" id="ai-key-badge">
              ${hasKey ? `${esc(modelName)} Ativo` : 'Configurar Gemini Pro'}
            </span>
          </div>
        </div>
        <div style="display:flex;gap:6px;">
          <button class="btn btn-sm btn-outline" id="ai-config-btn">⚙ Chave Pro</button>
          <button class="icon-btn-ghost" data-close-modal>✕</button>
        </div>
      </div>

      <div class="segmented">
        <button class="seg-btn ${state.ai.activeTab === 'outline' ? 'active' : ''}" data-ai-tab="outline">Esboço (5 Pontos)</button>
        <button class="seg-btn ${state.ai.activeTab === 'illustrations' ? 'active' : ''}" data-ai-tab="illustrations">Ilustrações</button>
        <button class="seg-btn ${state.ai.activeTab === 'lexical' ? 'active' : ''}" data-ai-tab="lexical">Grego & Hebraico</button>
      </div>

      <div id="ai-tab-body">
        ${state.ai.activeTab === 'outline' ? `
          <div class="chips-scroll" style="margin-bottom:10px;">
            <button class="chip" data-preset="A Parábola dos Talentos: Fidelidade e Mordomia no Reino|Mateus 25:14-30|Expositivo">Mt 25 Talentos</button>
            <button class="chip" data-preset="Entre Salmo 22 e a Crucificação de Jesus|Salmos 22 / Mateus 27:35-50|Expositivo">Sl 22 & Cruz</button>
            <button class="chip" data-preset="Salvos pelo Mérito de Cristo|Efésios 2:1-10|Expositivo">Efésios 2</button>
            <button class="chip" data-preset="Mais que Vencedores em Cristo|Romanos 8:31-39|Expositivo">Romanos 8</button>
            <button class="chip" data-preset="O Senhor é o Meu Pastor|Salmos 23:1-6|Expositivo">Salmos 23</button>
          </div>
          <label class="editor-section-label">Tema ou Ideia Central</label>
          <input id="ai-theme-input" class="input-field" value="${esc(state.ai.theme)}" style="margin-bottom:10px;">
          <div class="form-grid-2" style="margin-bottom:12px;">
            <div>
              <label class="editor-section-label">Texto Bíblico</label>
              <input id="ai-ref-input" class="input-field" value="${esc(state.ai.ref)}">
            </div>
            <div>
              <label class="editor-section-label">Tipo Homilético</label>
              <select id="ai-type-select" class="select-field">
                ${SERMON_TYPES.map((t) => `<option ${state.ai.sermonType === t ? 'selected' : ''}>${esc(t)}</option>`).join('')}
              </select>
            </div>
          </div>
          <button id="ai-generate-btn" class="btn btn-purple btn-block" ${state.ai.isLoading ? 'disabled' : ''}>
            ${state.ai.isLoading ? '⏳ Conectando à Nuvem Google AI e Gerando Esboço...' : `✨ Gerar Esboço com ${esc(modelName)} (5 Tópicos)`}
          </button>
          ${state.ai.isLoading ? `
            <div style="background:rgba(139,92,246,0.08);border:1px dashed var(--primary);border-radius:12px;padding:26px 16px;text-align:center;margin-top:16px;">
              <div class="spinner" style="margin:0 auto 12px;width:32px;height:32px;border-width:3px;border-top-color:var(--primary);"></div>
              <strong style="color:var(--primary);font-size:15px;display:block;">Elaborando Esboço com IA Google em Tempo Real...</strong>
              <span style="font-size:12.5px;color:var(--text-muted);margin-top:6px;display:block;">
                Construindo exegese histórica, 5 tópicos bíblicos detalhados, ilustrações e apelo pastoral.
              </span>
            </div>
          ` : outline ? `
            <div class="card" style="margin-top:16px;border-color:rgba(139,92,246,0.4);">
              ${!outline.isCloud ? `
                <div style="background:rgba(245,158,11,0.12);border:1px solid rgba(245,158,11,0.35);padding:10px 14px;border-radius:12px;margin-bottom:12px;display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;">
                  <div style="font-size:13px;color:var(--gold);">
                    <strong>⚠️ Modo Contingência Local:</strong>
                    ${outline.errorMessage ? `Falha na Google AI (${esc(outline.errorMessage)}).` : 'Chave Pro não configurada.'}
                  </div>
                  <button class="btn btn-xs btn-gold" id="ai-fix-key-btn">⚙️ Configurar Chave Pro</button>
                </div>
              ` : ''}
              <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:8px;">
                <span class="tag ${outline.isCloud ? 'tag-green' : 'tag-gold'}">✨ ${esc(outline.usedModel)}</span>
                <span class="tag tag-blue">${esc(outline.sermonType)}</span>
              </div>
              <h4 style="margin:0 0 6px;font-size:18px;">${esc(outline.title)}</h4>
              <div style="color:var(--primary);font-weight:700;font-size:13px;margin-bottom:10px;">📖 ${esc(outline.biblicalReference)}</div>
              ${outline.historicalContext ? `<p style="font-size:13px;color:var(--text-muted);margin:0 0 10px;">${esc(outline.historicalContext)}</p>` : ''}
              <p style="font-size:14px;"><strong>Introdução:</strong> ${esc(outline.introduction)}</p>
              ${outline.blocks.map((b) => `
                <div style="padding:10px;border-radius:10px;background:var(--surface-2);margin-bottom:8px;">
                  <strong>${esc(b.title)}</strong> <span style="font-size:12px;color:var(--primary);">(${esc(b.biblicalReference)})</span>
                  <div style="font-size:13px;margin-top:4px;">${esc(b.explanation)}</div>
                  ${b.illustration ? `<div style="font-size:12.5px;margin-top:4px;color:#c4b5fd;">💡 ${esc(b.illustration)}</div>` : ''}
                  ${b.application ? `<div style="font-size:12.5px;margin-top:4px;color:var(--gold);">🎯 ${esc(b.application)}</div>` : ''}
                </div>
              `).join('')}
              <p style="font-size:13.5px;"><strong>Conclusão:</strong> ${esc(outline.conclusion)}</p>
              <p style="font-size:13.5px;"><strong>Apelo:</strong> ${esc(outline.appeal)}</p>
              <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:12px;">
                ${onApplyToEditor ? `<button class="btn btn-sm btn-emerald" id="ai-apply-btn">✓ Inserir no Editor</button>` : ''}
                <button class="btn btn-sm btn-purple" id="ai-save-btn">💾 Salvar em Meus Sermões</button>
                <button class="btn btn-sm btn-primary" id="ai-edit-btn">✏️ Abrir no Editor</button>
              </div>
            </div>
          ` : ''}
        ` : state.ai.activeTab === 'illustrations' ? `
          <label class="editor-section-label">Contexto ou Ponto do Sermão</label>
          <input id="ai-ill-input" class="input-field" value="${esc(state.ai.theme)}" style="margin-bottom:12px;">
          <button id="ai-ill-btn" class="btn btn-purple btn-block" ${state.ai.isLoading ? 'disabled' : ''}>
            ${state.ai.isLoading ? '⏳ Gerando Ilustrações...' : '💡 Sugerir 3 Ilustrações Práticas'}
          </button>
          <div style="margin-top:14px;display:flex;flex-direction:column;gap:10px;">
            ${state.ai.illustrations.map((txt, i) => `<div class="card"><strong>Ilustração ${i + 1}</strong><p style="margin:6px 0 0;font-size:14px;">${esc(txt)}</p></div>`).join('')}
          </div>
        ` : `
          <label class="editor-section-label">Passagem Bíblica para Análise Original</label>
          <input id="ai-lex-input" class="input-field" value="${esc(state.ai.ref)}" style="margin-bottom:12px;">
          <button id="ai-lex-btn" class="btn btn-purple btn-block" ${state.ai.isLoading ? 'disabled' : ''}>
            ${state.ai.isLoading ? '⏳ Analisando Originais...' : '📜 Consultar Léxico Grego / Hebraico'}
          </button>
          <div style="margin-top:14px;display:flex;flex-direction:column;gap:10px;">
            ${state.ai.lexical.map((l) => `
              <div class="card">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                  <strong style="color:#a78bfa;font-size:17px;">${esc(l.word)} (${esc(l.transliteration)})</strong>
                  <span class="tag tag-gold">${esc(l.strongNumber)}</span>
                </div>
                <div style="font-size:12px;color:var(--text-muted);margin:3px 0 6px;">${esc(l.language)}</div>
                <div style="font-size:14px;font-weight:700;">${esc(l.meaning)}</div>
                <p style="font-size:13.5px;margin:6px 0 0;color:var(--text-muted);">${esc(l.theologicalInsight)}</p>
              </div>
            `).join('')}
          </div>
        `}
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#ai-config-btn').onclick = () => openGeminiConfigModal(() => openAiModal(onApplyToEditor));
        const fixKeyBtn = sheet.querySelector('#ai-fix-key-btn');
        if (fixKeyBtn) {
          fixKeyBtn.onclick = () => openGeminiConfigModal(() => openAiModal(onApplyToEditor));
        }
        sheet.querySelectorAll('[data-ai-tab]').forEach((btn) => {
          btn.onclick = () => {
            state.ai.activeTab = btn.dataset.aiTab;
            openAiModal(onApplyToEditor);
          };
        });
        sheet.querySelectorAll('[data-preset]').forEach((btn) => {
          btn.onclick = () => {
            const [t, r, tp] = btn.dataset.preset.split('|');
            state.ai.theme = t;
            state.ai.ref = r;
            state.ai.sermonType = tp;
            openAiModal(onApplyToEditor);
          };
        });
        const genBtn = sheet.querySelector('#ai-generate-btn');
        if (genBtn) {
          genBtn.onclick = async () => {
            state.ai.theme = sheet.querySelector('#ai-theme-input').value;
            state.ai.ref = sheet.querySelector('#ai-ref-input').value;
            state.ai.sermonType = sheet.querySelector('#ai-type-select').value;
            state.ai.isLoading = true;
            state.ai.outline = null; // Limpa para exibir o feedback visual imediato de carregamento
            openAiModal(onApplyToEditor);
            try {
              state.ai.outline = await generateOutlineWithAi(state.ai.theme, state.ai.ref, state.ai.sermonType);
            } catch (err) {
              console.error('[IA Homilética] Erro ao gerar esboço:', err);
            } finally {
              state.ai.isLoading = false;
              openAiModal(onApplyToEditor);
            }
          };
        }
        const saveAiSermon = () =>
          saveSermon({
            id: uuid(),
            userId: state.profile.id,
            title: outline.title,
            biblicalReference: outline.biblicalReference,
            category: 'Graça & Redenção',
            sermonType: outline.sermonType,
            introduction: outline.introduction,
            blocks: outline.blocks,
            conclusion: outline.conclusion,
            appeal: outline.appeal,
            status: 'ready',
            estimatedDurationMinutes: 42,
          });
        const saveBtn = sheet.querySelector('#ai-save-btn');
        if (saveBtn) {
          saveBtn.onclick = () => {
            const saved = saveAiSermon();
            closeModal();
            renderMain();
            showToast(`Sermão "${saved.title}" salvo!`, 'success');
          };
        }
        const editBtn = sheet.querySelector('#ai-edit-btn');
        if (editBtn) {
          editBtn.onclick = () => {
            const saved = saveAiSermon();
            closeModal();
            openSermonEditor(saved);
          };
        }
        const applyBtn = sheet.querySelector('#ai-apply-btn');
        if (applyBtn && onApplyToEditor) {
          applyBtn.onclick = () => {
            onApplyToEditor(outline);
            closeModal();
          };
        }

        const illBtn = sheet.querySelector('#ai-ill-btn');
        if (illBtn) {
          illBtn.onclick = async () => {
            const ctx = sheet.querySelector('#ai-ill-input').value;
            state.ai.isLoading = true;
            openAiModal(onApplyToEditor);
            try {
              const apiKey = state.settings.geminiKey?.trim();
              const chosenMod = (state.settings.geminiModel || 'gemini-3.8-flash').replace(/^models\//, '');
              if (apiKey && navigator.onLine) {
                const res = await callGeminiJsonWithCascade(
                  `Crie 3 ilustrações práticas em Português para o tema "${ctx}". Retorne JSON: {"illustrations": ["...", "...", "..."]}`,
                  chosenMod,
                  apiKey
                );
                if (res.success && res.data?.illustrations) {
                  state.ai.illustrations = res.data.illustrations;
                } else {
                  throw new Error(res.error || 'Falha nas ilustrações');
                }
              } else {
                state.ai.illustrations = [
                  'O Relógio do Mestre: O relojoeiro desmonta as engrenagens não para destruir, mas para restaurar a precisão do tempo.',
                  'O Ouro no Cadinho: O ourives mantém o ouro na fornalha até enxergar seu próprio reflexo brilhando no metal purificado.',
                  'A Semente no Solo: O que parece sepultamento na terra escura é o início invisível de uma árvore frutífera.',
                ];
              }
            } catch {
              showToast('Não foi possível conectar ao Gemini; exibindo sugestões locais.', 'info');
            } finally {
              state.ai.isLoading = false;
              openAiModal(onApplyToEditor);
            }
          };
        }

        const lexBtn = sheet.querySelector('#ai-lex-btn');
        if (lexBtn) {
          lexBtn.onclick = async () => {
            const pas = sheet.querySelector('#ai-lex-input').value;
            state.ai.isLoading = true;
            openAiModal(onApplyToEditor);
            try {
              const apiKey = state.settings.geminiKey?.trim();
              const chosenMod = (state.settings.geminiModel || 'gemini-3.8-flash').replace(/^models\//, '');
              if (apiKey && navigator.onLine) {
                const res = await callGeminiJsonWithCascade(
                  `Analise 3 palavras-chave em Grego ou Hebraico de "${pas}". Retorne JSON: {"insights":[{"word":"","transliteration":"","language":"","strongNumber":"","meaning":"","theologicalInsight":""}]}`,
                  chosenMod,
                  apiKey
                );
                if (res.success && res.data?.insights) {
                  state.ai.lexical = res.data.insights;
                } else {
                  throw new Error(res.error || 'Falha na análise lexical');
                }
              } else {
                state.ai.lexical = [
                  { word: 'χάρις', transliteration: 'charis', language: 'Grego (NT)', strongNumber: 'G5485', meaning: 'Graça, favor imerecido e gratuito de Deus.', theologicalInsight: 'Amor ativo de Deus concedido ao pecador sem mérito humano.' },
                  { word: 'חֶסֶד', transliteration: 'chesed', language: 'Hebraico (AT)', strongNumber: 'H2617', meaning: 'Amor leal pactual, misericórdia infalível.', theologicalInsight: 'Fidelidade juramentada de Yahweh com Seu povo.' },
                ];
              }
            } finally {
              state.ai.isLoading = false;
              openAiModal(onApplyToEditor);
            }
          };
        }
      }
    );
  }

  async function testGeminiConnectionSmart(key, selectedModel, statusEl, selEl) {
    if (!key) {
      statusEl.innerHTML = '<span style="color:var(--danger);font-weight:700;">Informe uma chave válida do Google AI Studio.</span>';
      return;
    }

    statusEl.innerHTML = '<span style="color:var(--primary);font-weight:600;">Verificando conectividade e integridade com Google AI...</span>';

    const avail = getAvailableGeminiModels();
    let cleanMod = (selectedModel || state.settings.geminiModel || 'gemini-3.1-flash-lite-preview').replace(/^models\//, '');
    if (isGeminiModelBlacklisted(cleanMod)) {
      cleanMod = 'gemini-3.1-flash-lite-preview';
    }

    const officialFallbacks = [
      'gemini-3.1-flash-lite-preview',
      'gemini-3.1-pro-preview',
      'gemini-3.8-flash',
      'gemini-2.5-flash',
    ];

    const discoveredList = Object.keys(avail).sort((a, b) => scoreGeminiModel(b) - scoreGeminiModel(a));
    const pool = [cleanMod, ...discoveredList, ...officialFallbacks];

    const candidateSet = new Set();
    const candidates = [];
    pool.forEach((m) => {
      const clean = (m || '').replace(/^models\//, '').trim();
      if (clean && !isGeminiModelBlacklisted(clean) && !candidateSet.has(clean) && candidates.length < 5) {
        candidateSet.add(clean);
        candidates.push(clean);
      }
    });

    let lastErr = '';
    let hadErrorOnInitial = false;
    let initialErrorMsg = '';

    for (let i = 0; i < candidates.length; i++) {
      const modToTest = candidates[i];
      const startTime = performance.now();
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${modToTest}:generateContent?key=${encodeURIComponent(key)}`;
        const res = await fetchGeminiWithRetry(
          url,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ contents: [{ parts: [{ text: 'Ping' }] }], generationConfig: { maxOutputTokens: 2 } }),
          },
          1
        );

        if (res.ok) {
          const latency = Math.round(performance.now() - startTime);
          if (modToTest !== cleanMod) {
            // O modelo selecionado inicialmente falhou (503 / 404 / 429), mas a migração automática encontrou um modelo operacional
            state.settings.geminiModel = modToTest;
            writeStore(KEYS.SETTINGS, state.settings);
            if (selEl) {
              selEl.value = modToTest;
            }
            statusEl.innerHTML = `
              <div style="background:rgba(34,197,94,0.12);border:1px solid rgba(34,197,94,0.4);border-radius:8px;padding:9px 12px;color:var(--green);font-size:12.5px;line-height:1.45;">
                <strong>✓ Conexão Ativa & Migração Automática Realizada!</strong><br>
                O modelo <code>${cleanMod}</code> retornou instabilidade na Google AI (${esc(initialErrorMsg || 'Carga Alta 503')}).<br>
                O sistema migrou e ativou automaticamente <strong>${modToTest}</strong> (${latency}ms) para garantir funcionamento 100% contínuo!
              </div>`;
          } else {
            statusEl.innerHTML = `
              <div style="background:rgba(34,197,94,0.12);border:1px solid rgba(34,197,94,0.4);border-radius:8px;padding:9px 12px;color:var(--green);font-size:12.5px;line-height:1.45;">
                <strong>✓ Conexão confirmada com ${esc(modToTest)}!</strong><br>
                Latência de resposta: ${latency}ms • Motor Homilético 100% operacional.
              </div>`;
          }
          syncGeminiModelsFromGoogle(key, { silent: true });
          return;
        } else {
          const errData = await res.json().catch(() => ({}));
          lastErr = errData?.error?.message || `HTTP ${res.status}`;
          if (res.status === 404 || res.status === 400 || (res.status === 429 && lastErr.includes('limit: 0'))) {
            _runtimeBlacklistedModels.add(modToTest);
            if (state.settings.geminiDiscoveredModels?.[modToTest]) {
              delete state.settings.geminiDiscoveredModels[modToTest];
              writeStore(KEYS.SETTINGS, state.settings);
            }
          }
          if (i === 0) {
            hadErrorOnInitial = true;
            initialErrorMsg = lastErr;
          }
          statusEl.innerHTML = `<span style="color:var(--gold);font-size:12px;">⚠️ ${modToTest} indisponível (${res.status}). Testando modelo alternativo de alta disponibilidade...</span>`;
        }
      } catch (e) {
        lastErr = e.message;
        if (i === 0) {
          hadErrorOnInitial = true;
          initialErrorMsg = lastErr;
        }
      }
    }

    // Se nenhum modelo respondeu (geralmente chave errada ou rede)
    statusEl.innerHTML = `
      <div style="background:rgba(239,68,68,0.12);border:1px solid rgba(239,68,68,0.4);border-radius:8px;padding:9px 12px;color:var(--danger);font-size:12.5px;line-height:1.45;">
        <strong>Falha ao conectar com a Google AI Studio:</strong><br>
        ${esc(lastErr || 'Verifique se a chave de API está correta e com faturamento/permissões ativas.')}
      </div>`;
  }

  function openGeminiConfigModal(onDone = null) {
    const curMod = sanitizeActiveGeminiModel();
    const avail = getAvailableGeminiModels();

    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title">✨ Motor Gemini Pro • Modelos Ativos Google AI</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <p style="font-size:13.5px;color:var(--text-muted);margin:0 0 12px;">
        Exibindo apenas modelos oficiais suportados e ativos para a sua chave. Obtenha sua chave em <strong>aistudio.google.com/apikey</strong>.
      </p>
      <label class="editor-section-label">Modelo Homilético Ativo</label>
      <div style="display:flex;gap:8px;margin-bottom:12px;">
        <select id="gem-model-sel" class="select-field" style="flex:1;">
          ${Object.entries(avail).filter(([k]) => !isGeminiModelBlacklisted(k)).map(([k, v]) => `<option value="${k}" ${curMod === k ? 'selected' : ''}>${esc(v)}</option>`).join('')}
        </select>
        <button class="btn btn-outline" id="gem-sync-btn" title="Consultar modelos ativos da sua chave na Google AI em tempo real" style="white-space:nowrap;padding:0 12px;">
          🔄 Sincronizar
        </button>
      </div>
      <label class="editor-section-label">Gemini API Key (AIza...)</label>
      <input id="gem-key-inp" type="password" class="input-field" placeholder="Cole sua chave aqui..." value="${esc(state.settings.geminiKey || '')}" style="margin-bottom:10px;">
      <div id="gem-test-status" style="font-size:13px;margin-bottom:12px;"></div>
      <div style="display:flex;gap:8px;justify-content:space-between;flex-wrap:wrap;align-items:center;">
        <span style="font-size:11.5px;color:var(--text-muted);" id="gem-last-sync-label">
          ${state.settings.geminiLastModelSync ? `Sincronizado: ${new Date(state.settings.geminiLastModelSync).toLocaleDateString('pt-BR')} ${new Date(state.settings.geminiLastModelSync).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}` : 'Catálogo ativo'}
        </span>
        <div style="display:flex;gap:8px;">
          <button class="btn btn-outline" id="gem-test-btn">📡 Testar Conexão</button>
          <button class="btn btn-purple" id="gem-save-btn">Salvar</button>
        </div>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));

        sheet.querySelector('#gem-sync-btn').onclick = async () => {
          const key = sheet.querySelector('#gem-key-inp').value.trim();
          const out = sheet.querySelector('#gem-test-status');
          out.innerHTML = '<span style="color:var(--primary);">Consultando e priorizando modelos ativos na Google AI...</span>';
          const res = await syncGeminiModelsFromGoogle(key, { silent: false });
          if (res.success) {
            const updated = getAvailableGeminiModels();
            const sel = sheet.querySelector('#gem-model-sel');
            sel.innerHTML = Object.entries(updated).map(([k, v]) => `<option value="${k}" ${state.settings.geminiModel === k ? 'selected' : ''}>${esc(v)}</option>`).join('');
            out.innerHTML = `<span style="color:var(--green);font-weight:700;">✓ Exibindo ${res.count || Object.keys(updated).length} modelos ativos e priorizados para sua chave!</span>`;
            const lbl = sheet.querySelector('#gem-last-sync-label');
            if (lbl) lbl.textContent = 'Sincronizado agora';
          } else {
            out.innerHTML = `<span style="color:var(--danger);">Falha ao sincronizar: ${esc(res.reason)}</span>`;
          }
        };

        sheet.querySelector('#gem-test-btn').onclick = async () => {
          const key = sheet.querySelector('#gem-key-inp').value.trim();
          const mod = sheet.querySelector('#gem-model-sel').value;
          const out = sheet.querySelector('#gem-test-status');
          const sel = sheet.querySelector('#gem-model-sel');
          await testGeminiConnectionSmart(key, mod, out, sel);
        };

        sheet.querySelector('#gem-save-btn').onclick = () => {
          state.settings.geminiKey = sheet.querySelector('#gem-key-inp').value.trim();
          state.settings.geminiModel = sheet.querySelector('#gem-model-sel').value;
          writeStore(KEYS.SETTINGS, state.settings);
          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });
          updateActiveVoiceLabel();
          closeModal();
          showToast('Configurações do Gemini Pro salvas!', 'success');
          if (onDone) onDone();
          else renderMain();
        };
      }
    );
  }

  // =========================================================================
  // RENDERIZAÇÃO DAS TELAS
  // =========================================================================
  const NAV_ITEMS = [
    { id: 'dashboard', icon: '📊', label: 'Dashboard' },
    { id: 'library', icon: '📚', label: 'Meus Sermões' },
    { id: 'bible', icon: '📖', label: 'Bíblia' },
    { id: 'templates', icon: '✨', label: 'Modelos' },
    { id: 'profile', icon: '👤', label: 'Perfil' },
    { id: 'settings', icon: '⚙️', label: 'Configurações' },
  ];

  function closeSidebarUserMenu() {
    const menuEl = document.getElementById('sidebar-user-menu');
    const cardEl = document.getElementById('sidebar-user-card');
    if (menuEl) menuEl.classList.add('hidden');
    if (cardEl) cardEl.classList.remove('menu-open');
  }

  function renderChrome() {
    // Sidebar nav
    const sNav = document.getElementById('sidebar-nav');
    sNav.innerHTML = NAV_ITEMS.map((n) => `
      <button class="sidebar-nav-btn ${state.tab === n.id ? 'active' : ''}" data-nav="${n.id}">
        <span>${n.icon}</span>
        <span>${n.label}</span>
      </button>
    `).join('');
    sNav.querySelectorAll('[data-nav]').forEach((b) => {
      b.onclick = () => {
        closeSidebarUserMenu();
        switchTab(b.dataset.nav);
      };
    });

    // Bottom nav mobile
    const bNav = document.getElementById('bottom-nav');
    bNav.innerHTML = NAV_ITEMS.map((n) => `
      <button class="bottom-nav-btn ${state.tab === n.id ? 'active' : ''}" data-nav="${n.id}">
        <span class="nav-ico">${n.icon}</span>
        <span>${n.id === 'settings' ? 'Config.' : n.label}</span>
      </button>
    `).join('');
    bNav.querySelectorAll('[data-nav]').forEach((b) => {
      b.onclick = () => switchTab(b.dataset.nav);
    });

    // Sidebar user card com menu de Logoff integrado no próprio nome do usuário
    const initials = (state.profile.fullName || 'P')
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((w) => w[0].toUpperCase())
      .join('');
    const userCard = document.getElementById('sidebar-user-card');
    const userMenu = document.getElementById('sidebar-user-menu');

    userCard.innerHTML = `
      <div class="user-avatar">${esc(initials)}</div>
      <div class="user-meta" style="min-width:0;flex:1;">
        <div class="user-name" style="display:flex;align-items:center;gap:6px;">
          <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${esc(state.profile.fullName)}</span>
        </div>
        <div class="user-role" style="display:flex;align-items:center;gap:5px;">
          <span class="gold-pill" style="font-size:9px;padding:1px 5px;">ADMIN</span>
          <span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${esc(state.profile.ministryTitle)}</span>
        </div>
      </div>
      <span class="sidebar-user-chevron">▾</span>
    `;

    if (userMenu) {
      userMenu.innerHTML = `
        <div class="user-menu-header">
          <div style="font-size:13.5px;font-weight:800;color:var(--text);">${esc(state.profile.fullName)}</div>
          <div style="font-size:11.5px;color:var(--text-muted);">${esc(state.profile.email)} • Perfil Admin</div>
        </div>
        <button class="user-menu-item" id="um-profile"><span>👤</span><span>Meu Perfil Ministerial</span></button>
        <button class="user-menu-item" id="um-settings"><span>🎨</span><span>Configurações & Paleta de Cores</span></button>
        <button class="user-menu-item" id="um-pass"><span>🔑</span><span>Alterar Senha Admin</span></button>
        <button class="user-menu-item danger" id="um-logout"><span>🚪</span><span>Fazer Logoff (Sair da Conta)</span></button>
      `;

      userMenu.querySelector('#um-profile').onclick = (e) => {
        e.stopPropagation();
        closeSidebarUserMenu();
        switchTab('profile');
      };
      userMenu.querySelector('#um-settings').onclick = (e) => {
        e.stopPropagation();
        closeSidebarUserMenu();
        switchTab('settings');
      };
      userMenu.querySelector('#um-pass').onclick = (e) => {
        e.stopPropagation();
        closeSidebarUserMenu();
        openForcePasswordChangeModal({ mandatory: false });
      };
      userMenu.querySelector('#um-logout').onclick = (e) => {
        e.stopPropagation();
        closeSidebarUserMenu();
        performLogout();
      };
    }

    userCard.onclick = (e) => {
      e.stopPropagation();
      if (!userMenu) return;
      const isHidden = userMenu.classList.contains('hidden');
      if (isHidden) {
        userMenu.classList.remove('hidden');
        userCard.classList.add('menu-open');
      } else {
        closeSidebarUserMenu();
      }
    };

    // Topbar title
    const activeNav = NAV_ITEMS.find((n) => n.id === state.tab);
    document.getElementById('topbar-title').textContent =
      state.tab === 'editor' ? 'Editor de Sermão' : activeNav ? activeNav.label : 'Pregador Pro';

    updateSyncIndicators();
  }

  function updateSyncIndicators() {
    const isCloud = Boolean(state.cloudAuth?.accessToken) || _cloudDbReady;
    const online = navigator.onLine;
    const mobileBadge = document.getElementById('mobile-sync-badge');
    const cls = !online ? 'offline' : isCloud ? 'cloud' : '';

    if (mobileBadge) {
      mobileBadge.className = `mini-badge ${cls}`;
      mobileBadge.textContent = !online ? 'Offline OK' : isCloud ? 'Nuvem ✓' : 'Online';
    }
  }

  function flushActiveEditorIfNeeded() {
    if (state.tab !== 'editor' || !state.editingSermon) return;
    const root = document.getElementById('main-content');
    if (!root) return;
    const titleEl = root.querySelector('#ed-title');
    if (!titleEl) return;

    state.editingSermon.title = titleEl.value || 'Novo Sermão';
    const refEl = root.querySelector('#ed-ref');
    if (refEl) state.editingSermon.biblicalReference = refEl.value;
    const catEl = root.querySelector('#ed-cat');
    if (catEl) state.editingSermon.category = catEl.value;
    const typeEl = root.querySelector('#ed-type');
    if (typeEl) state.editingSermon.sermonType = typeEl.value;
    const statusEl = root.querySelector('#ed-status');
    if (statusEl) state.editingSermon.status = statusEl.value;
    const durEl = root.querySelector('#ed-dur');
    if (durEl) state.editingSermon.estimatedDurationMinutes = Number(durEl.value || 40);
    const introEl = root.querySelector('#ed-intro');
    if (introEl) state.editingSermon.introduction = introEl.value;
    const concEl = root.querySelector('#ed-conc');
    if (concEl) state.editingSermon.conclusion = concEl.value;
    const appealEl = root.querySelector('#ed-appeal');
    if (appealEl) state.editingSermon.appeal = appealEl.value;

    root.querySelectorAll('.block-card').forEach((card) => {
      const idx = Number(card.dataset.blockIdx);
      if (!state.editingSermon.blocks[idx]) return;
      card.querySelectorAll('[data-bfield]').forEach((inp) => {
        state.editingSermon.blocks[idx][inp.dataset.bfield] = inp.value;
      });
    });

    state.editingSermon = saveSermon(state.editingSermon);
  }

  function switchTab(tabId) {
    if (state.tab === 'editor' && tabId !== 'editor') flushActiveEditorIfNeeded();
    if (state.tab === 'bible' && tabId !== 'bible') stopBibleSpeech();
    state.tab = tabId;
    renderChrome();
    renderMain();
    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  function createNewSermonAndOpen() {
    const now = new Date().toISOString();
    const sermon = saveSermon({
      id: uuid(),
      userId: state.profile.id,
      title: 'Novo Sermão',
      biblicalReference: 'Salmos 23:1',
      category: 'Geral',
      sermonType: 'Expositivo',
      introduction: '',
      blocks: [
        { id: uuid(), title: 'Ponto 1', biblicalReference: '', explanation: '', illustration: '', application: '', orderIndex: 0 },
      ],
      conclusion: '',
      appeal: '',
      status: 'draft',
      isFavorite: false,
      preachCount: 0,
      estimatedDurationMinutes: 40,
      createdAt: now,
      updatedAt: now,
    });
    openSermonEditor(sermon);
  }

  function openSermonEditor(sermon) {
    const fresh = state.allSermons.find((s) => s.id === sermon.id) || sermon;
    state.editingSermon = JSON.parse(JSON.stringify(fresh));
    state.tab = 'editor';
    renderChrome();
    renderMain();
    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  function renderSermonCardHtml(s, { selected = false } = {}) {
    const isReady = s.status === 'ready';
    return `
      <article class="sermon-card ${selected ? 'selected' : ''}" data-sermon-id="${esc(s.id)}">
        <div class="sermon-card-top">
          <h3 class="sermon-title" data-open-sermon="${esc(s.id)}" style="cursor:pointer;">${esc(s.title)}</h3>
          <div class="sermon-top-icons">
            <button class="icon-btn-ghost" title="Favoritar" data-fav-sermon="${esc(s.id)}">
              ${s.isFavorite ? '⭐' : '☆'}
            </button>
            <button class="icon-btn-ghost" title="Excluir Sermão" style="color:var(--danger);" data-del-sermon="${esc(s.id)}">
              🗑️
            </button>
          </div>
        </div>
        <div class="tags-row">
          <span class="tag tag-blue">📖 ${esc(s.biblicalReference || 'Sem referência')}</span>
          <span class="tag tag-gold">${esc(s.category)}</span>
          <span class="tag ${isReady ? 'tag-green' : 'tag-muted'}">${statusLabel(s.status)}</span>
          ${s.preachCount > 0 ? `<span class="tag tag-green">🎤 ${s.preachCount}x</span>` : ''}
        </div>
        ${s.introduction ? `<p class="sermon-intro-preview">${esc(s.introduction)}</p>` : ''}
        <div class="card-actions">
          <button class="btn btn-sm btn-outline" data-edit-sermon="${esc(s.id)}">✏️ Editar</button>
          <button class="btn btn-sm btn-whatsapp" data-wa-sermon="${esc(s.id)}">💬 WhatsApp</button>
          <button class="btn btn-sm btn-danger" data-del-sermon="${esc(s.id)}">🗑️ Excluir</button>
          <button class="btn btn-sm btn-gold" data-pulpit-sermon="${esc(s.id)}">🎤 Púlpito</button>
        </div>
      </article>
    `;
  }

  function bindSermonCardEvents(container) {
    container.querySelectorAll('[data-open-sermon], [data-edit-sermon]').forEach((el) => {
      el.onclick = () => {
        const id = el.dataset.openSermon || el.dataset.editSermon;
        const s = state.allSermons.find((x) => x.id === id);
        if (s) openSermonEditor(s);
      };
    });
    container.querySelectorAll('[data-fav-sermon]').forEach((el) => {
      el.onclick = (ev) => {
        ev.stopPropagation();
        const s = state.allSermons.find((x) => x.id === el.dataset.favSermon);
        if (s) {
          saveSermon({ ...s, isFavorite: !s.isFavorite });
          renderMain();
        }
      };
    });
    container.querySelectorAll('[data-del-sermon]').forEach((el) => {
      el.onclick = (ev) => {
        ev.stopPropagation();
        const s = state.allSermons.find((x) => x.id === el.dataset.delSermon);
        if (s) confirmDeleteSermon(s);
      };
    });
    container.querySelectorAll('[data-wa-sermon]').forEach((el) => {
      el.onclick = (ev) => {
        ev.stopPropagation();
        const s = state.allSermons.find((x) => x.id === el.dataset.waSermon);
        if (s) shareSermonWhatsApp(s);
      };
    });
    container.querySelectorAll('[data-pulpit-sermon]').forEach((el) => {
      el.onclick = (ev) => {
        ev.stopPropagation();
        const s = state.allSermons.find((x) => x.id === el.dataset.pulpitSermon);
        if (s) openPulpitMode(s);
      };
    });
  }

  // ---- TELA 1: DASHBOARD ----
  function renderDashboard(root) {
    const all = state.allSermons;
    const total = all.length;
    const preachedCount = all.filter((s) => s.preachCount > 0).length;
    const totalPreaches = all.reduce((acc, s) => acc + (s.preachCount || 0), 0);
    const readyCount = all.filter((s) => s.status === 'ready').length;
    const favCount = all.filter((s) => s.isFavorite).length;
    const recent = all.slice(0, 6);

    root.innerHTML = `
      <section class="hero-banner">
        <div class="hero-top">
          <span class="date-chip">📅 ${esc(formatPtDate())}</span>
          <span class="gold-pill">PREGADOR PRO</span>
        </div>
        <h1 class="hero-greeting">Paz do Senhor, ${esc(state.profile.fullName)}</h1>
        <p class="hero-desc">${esc(state.profile.ministryTitle)} • ${esc(state.profile.churchName || 'Ministério Local')}</p>
        <div class="hero-verse">
          "Procura apresentar-te a Deus aprovado, como obreiro que não tem de que se envergonhar, que maneja bem a palavra da verdade." — <strong>2 Timóteo 2:15</strong>
        </div>
      </section>

      <div class="section-header">
        <h2 class="section-title">Visão Geral Ministerial</h2>
        <span class="section-subtitle">Toque nos cards para filtrar</span>
      </div>

      <div class="kpi-grid">
        <button class="kpi-card" id="kpi-total">
          <div class="kpi-head"><span class="kpi-icon" style="background:rgba(59,130,246,0.16);color:#60a5fa;">📚</span><span class="kpi-value" style="color:#60a5fa;">${total}</span></div>
          <div class="kpi-label">Total de Sermões</div>
          <div class="kpi-sub">Acervo completo salvo</div>
        </button>
        <button class="kpi-card" id="kpi-preached">
          <div class="kpi-head"><span class="kpi-icon" style="background:var(--green-soft);color:var(--green);">🎤</span><span class="kpi-value" style="color:var(--green);">${preachedCount}</span></div>
          <div class="kpi-label">Ministrados</div>
          <div class="kpi-sub">${totalPreaches} ministrações</div>
        </button>
        <button class="kpi-card" id="kpi-ready">
          <div class="kpi-head"><span class="kpi-icon" style="background:var(--gold-soft);color:var(--gold);">✓</span><span class="kpi-value" style="color:var(--gold);">${readyCount}</span></div>
          <div class="kpi-label">Prontos p/ Púlpito</div>
          <div class="kpi-sub">Estruturados</div>
        </button>
        <button class="kpi-card" id="kpi-fav">
          <div class="kpi-head"><span class="kpi-icon" style="background:rgba(236,72,153,0.16);color:#f472b6;">⭐</span><span class="kpi-value" style="color:#f472b6;">${favCount}</span></div>
          <div class="kpi-label">Favoritos</div>
          <div class="kpi-sub">Destaques</div>
        </button>
      </div>

      <div class="section-header">
        <h2 class="section-title">Ações Rápidas</h2>
      </div>
      <div class="quick-actions">
        <button class="btn btn-primary" id="qa-new">＋ Novo Sermão</button>
        <button class="btn btn-purple" id="qa-ai">✨ Gerar com Gemini Pro</button>
        <button class="btn btn-gold" id="qa-pulpit">🎤 Modo Púlpito</button>
        <button class="btn btn-emerald" id="qa-tpl">📁 Modelos (150)</button>
      </div>

      <div class="section-header">
        <h2 class="section-title">Sermões Recentes</h2>
        <button class="btn btn-xs btn-outline" id="dash-see-all">Ver Todos (${total})</button>
      </div>
      <div class="sermon-list" id="dash-recent-list">
        ${recent.map((s) => renderSermonCardHtml(s)).join('')}
      </div>
    `;

    root.querySelector('#kpi-total').onclick = () => {
      state.libraryFilters = { query: '', category: 'Todas', status: '', onlyFavorites: false, onlyPreached: false };
      switchTab('library');
    };
    root.querySelector('#kpi-preached').onclick = () => {
      state.libraryFilters = { query: '', category: 'Todas', status: '', onlyFavorites: false, onlyPreached: true };
      switchTab('library');
    };
    root.querySelector('#kpi-ready').onclick = () => {
      state.libraryFilters = { query: '', category: 'Todas', status: 'ready', onlyFavorites: false, onlyPreached: false };
      switchTab('library');
    };
    root.querySelector('#kpi-fav').onclick = () => {
      state.libraryFilters = { query: '', category: 'Todas', status: '', onlyFavorites: true, onlyPreached: false };
      switchTab('library');
    };

    root.querySelector('#qa-new').onclick = createNewSermonAndOpen;
    root.querySelector('#qa-ai').onclick = () => openAiModal();
    root.querySelector('#qa-pulpit').onclick = () => {
      if (state.allSermons.length) openPulpitMode(state.allSermons[0]);
      else showToast('Crie um sermão primeiro.', 'info');
    };
    root.querySelector('#qa-tpl').onclick = () => switchTab('templates');
    root.querySelector('#dash-see-all').onclick = () => switchTab('library');

    bindSermonCardEvents(root.querySelector('#dash-recent-list'));
  }

  // ---- TELA 2: MEUS SERMÕES ----
  function getFilteredSermons() {
    const f = state.libraryFilters;
    const q = f.query.trim().toLowerCase();
    return state.allSermons.filter((s) => {
      if (f.category !== 'Todas' && s.category.toLowerCase() !== f.category.toLowerCase()) return false;
      if (f.status && s.status !== f.status) return false;
      if (f.onlyFavorites && !s.isFavorite) return false;
      if (f.onlyPreached && !(s.preachCount > 0)) return false;
      if (q) {
        const hay = `${s.title} ${s.biblicalReference} ${s.category} ${s.introduction}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }

  function renderLibrary(root) {
    const filtered = getFilteredSermons();
    const f = state.libraryFilters;
    if (!state.selectedSermonId || !filtered.some((s) => s.id === state.selectedSermonId)) {
      state.selectedSermonId = filtered[0]?.id || null;
    }
    const selected = filtered.find((s) => s.id === state.selectedSermonId) || null;

    root.innerHTML = `
      <div class="section-header" style="margin-top:0;">
        <div>
          <h1 class="section-title" style="font-size:22px;">Meus Sermões</h1>
          <span class="section-subtitle">${state.allSermons.length} mensagens salvas • ${filtered.length} exibidas</span>
        </div>
        <button class="btn btn-primary" id="lib-new-btn">＋ Novo Sermão</button>
      </div>

      <div class="toolbar-card">
        <input id="lib-search" class="input-field" placeholder="Buscar por título, texto bíblico ou tema..." value="${esc(f.query)}">
        <div class="chips-scroll">
          <button class="chip ${f.category === 'Todas' ? 'active' : ''}" id="lib-cat-btn">📁 ${f.category === 'Todas' ? 'Todas Categorias' : esc(f.category)}</button>
          <button class="chip ${f.status === 'ready' ? 'active' : ''}" data-status="ready">✓ Prontos</button>
          <button class="chip ${f.status === 'draft' ? 'active' : ''}" data-status="draft">📝 Rascunhos</button>
          <button class="chip ${f.onlyFavorites ? 'active' : ''}" id="lib-fav-chip">⭐ Favoritos</button>
          <button class="chip ${f.onlyPreached ? 'active' : ''}" id="lib-preach-chip">🎤 Ministrados</button>
          ${f.query || f.category !== 'Todas' || f.status || f.onlyFavorites || f.onlyPreached ? `<button class="chip" style="color:var(--danger);" id="lib-clear-chip">✕ Limpar</button>` : ''}
        </div>
      </div>

      ${filtered.length === 0 ? `
        <div class="card" style="text-align:center;padding:36px 20px;">
          <p style="margin:0 0 12px;color:var(--text-muted);">Nenhum sermão encontrado com os filtros atuais.</p>
          <button class="btn btn-outline" id="lib-empty-reset">Limpar Filtros</button>
        </div>
      ` : `
        <div class="library-split">
          <div class="sermon-list" id="lib-cards">
            ${filtered.map((s) => renderSermonCardHtml(s, { selected: s.id === selected?.id })).join('')}
          </div>
          ${selected ? `
            <div class="card library-detail-pane" id="lib-detail" style="display:none;">
              <h2 style="margin:0 0 6px;font-size:20px;">${esc(selected.title)}</h2>
              <div style="font-size:13px;color:var(--primary);font-weight:700;margin-bottom:12px;">📖 ${esc(selected.biblicalReference)} • ${esc(selected.category)} • ${esc(selected.sermonType)}</div>
              <div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:16px;padding-bottom:14px;border-bottom:1px solid var(--border);">
                <button class="btn btn-sm btn-primary" id="det-edit">✏️ Editar</button>
                <button class="btn btn-sm btn-gold" id="det-pulpit">🎤 Púlpito</button>
                <button class="btn btn-sm btn-whatsapp" id="det-wa">💬 WhatsApp</button>
                <button class="btn btn-sm btn-outline" id="det-pdf">🖨️ PDF</button>
                <button class="btn btn-sm btn-danger" id="det-del">🗑️ Excluir</button>
              </div>
              ${selected.introduction ? `<h4>Introdução</h4><p>${esc(selected.introduction)}</p>` : ''}
              ${selected.blocks.map((b, i) => `
                <div style="margin:12px 0;padding:12px;border-radius:12px;background:var(--surface-2);">
                  <strong>${esc(b.title || `Ponto ${i + 1}`)}</strong>
                  ${b.biblicalReference ? `<div style="font-size:12px;color:var(--primary);margin:2px 0 6px;">${esc(b.biblicalReference)}</div>` : ''}
                  ${b.explanation ? `<p style="font-size:14px;margin:4px 0;">${esc(b.explanation)}</p>` : ''}
                  ${b.illustration ? `<p style="font-size:13px;margin:4px 0;color:#c4b5fd;">💡 ${esc(b.illustration)}</p>` : ''}
                  ${b.application ? `<p style="font-size:13px;margin:4px 0;color:var(--gold);">🎯 ${esc(b.application)}</p>` : ''}
                </div>
              `).join('')}
              ${selected.conclusion ? `<h4>Conclusão</h4><p>${esc(selected.conclusion)}</p>` : ''}
              ${selected.appeal ? `<h4>Apelo</h4><p>${esc(selected.appeal)}</p>` : ''}
            </div>
          ` : ''}
        </div>
      `}
    `;

    // Exibe detail pane apenas em telas >= 960px
    const detEl = root.querySelector('#lib-detail');
    if (detEl && window.innerWidth >= 960) detEl.style.display = 'block';

    root.querySelector('#lib-new-btn').onclick = createNewSermonAndOpen;
    const searchEl = root.querySelector('#lib-search');
    searchEl.oninput = () => {
      state.libraryFilters.query = searchEl.value;
      const listEl = root.querySelector('#lib-cards');
      if (listEl) {
        const nextList = getFilteredSermons();
        listEl.innerHTML = nextList.map((s) => renderSermonCardHtml(s)).join('');
        bindSermonCardEvents(listEl);
      }
    };

    root.querySelector('#lib-cat-btn').onclick = () => {
      const cats = new Map();
      state.allSermons.forEach((s) => cats.set(s.category, (cats.get(s.category) || 0) + 1));
      openModal(
        `
        <div class="modal-header">
          <h3 class="modal-title">Filtrar por Categoria</h3>
          <button class="icon-btn-ghost" data-close-modal>✕</button>
        </div>
        <div style="display:flex;flex-direction:column;gap:6px;">
          <button class="btn btn-outline" style="justify-content:space-between;" data-pick-cat="Todas"><span>Todas as Categorias</span><span>${state.allSermons.length}</span></button>
          ${Array.from(cats.entries()).sort((a, b) => a[0].localeCompare(b[0])).map(([c, cnt]) =>
            `<button class="btn btn-outline" style="justify-content:space-between;" data-pick-cat="${esc(c)}"><span>${esc(c)}</span><span>${cnt}</span></button>`
          ).join('')}
        </div>
        `,
        (sheet) => {
          sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
          sheet.querySelectorAll('[data-pick-cat]').forEach((b) => {
            b.onclick = () => {
              state.libraryFilters.category = b.dataset.pickCat;
              closeModal();
              renderMain();
            };
          });
        }
      );
    };

    root.querySelectorAll('[data-status]').forEach((b) => {
      b.onclick = () => {
        state.libraryFilters.status = state.libraryFilters.status === b.dataset.status ? '' : b.dataset.status;
        renderMain();
      };
    });
    root.querySelector('#lib-fav-chip').onclick = () => {
      state.libraryFilters.onlyFavorites = !state.libraryFilters.onlyFavorites;
      renderMain();
    };
    root.querySelector('#lib-preach-chip').onclick = () => {
      state.libraryFilters.onlyPreached = !state.libraryFilters.onlyPreached;
      renderMain();
    };
    const clearChip = root.querySelector('#lib-clear-chip');
    if (clearChip) {
      clearChip.onclick = () => {
        state.libraryFilters = { query: '', category: 'Todas', status: '', onlyFavorites: false, onlyPreached: false };
        renderMain();
      };
    }
    const emptyReset = root.querySelector('#lib-empty-reset');
    if (emptyReset) {
      emptyReset.onclick = () => {
        state.libraryFilters = { query: '', category: 'Todas', status: '', onlyFavorites: false, onlyPreached: false };
        renderMain();
      };
    }

    const cardsEl = root.querySelector('#lib-cards');
    if (cardsEl) {
      bindSermonCardEvents(cardsEl);
      if (window.innerWidth >= 960) {
        cardsEl.querySelectorAll('.sermon-card').forEach((card) => {
          card.addEventListener('click', (e) => {
            if (e.target.closest('button')) return;
            state.selectedSermonId = card.dataset.sermonId;
            renderMain();
          });
        });
      }
    }

    if (selected && detEl) {
      detEl.querySelector('#det-edit').onclick = () => openSermonEditor(selected);
      detEl.querySelector('#det-pulpit').onclick = () => openPulpitMode(selected);
      detEl.querySelector('#det-wa').onclick = () => shareSermonWhatsApp(selected);
      detEl.querySelector('#det-pdf').onclick = () => printSermonPdf(selected);
      detEl.querySelector('#det-del').onclick = () => confirmDeleteSermon(selected);
    }
  }

  // ---- TELA 3: EDITOR HOMILÉTICO (AUTO-SAVE INSTANTÂNEO SEM PERDER FOCO) ----
  function renderEditor(root) {
    const s = state.editingSermon;
    if (!s) return switchTab('library');

    root.innerHTML = `
      <div class="editor-topbar">
        <div class="editor-topbar-left">
          <button class="btn btn-sm btn-outline" id="ed-back-btn">← Voltar</button>
          <div class="editor-title-group">
            <div id="ed-header-title" class="editor-header-title">${esc(s.title)}</div>
            <div id="ed-save-status" class="editor-status">✓ Salvo automaticamente</div>
          </div>
        </div>
        <div class="editor-topbar-actions">
          <button class="btn btn-sm btn-emerald" id="ed-save-top-btn" title="Salvar Sermão">💾 Salvar</button>
          <button class="icon-btn" id="ed-bible-btn" title="Consultar Bíblia">📖</button>
          <button class="icon-btn" id="ed-ai-btn" title="Assistente Gemini">✨</button>
          <button class="icon-btn" id="ed-del-top-btn" title="Excluir Sermão" style="color:var(--danger);border-color:rgba(239,68,68,0.4);">🗑️</button>
          <button class="btn btn-sm btn-gold" id="ed-pulpit-btn">🎤 Púlpito</button>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px;">
        <label class="editor-section-label">Título do Sermão</label>
        <input id="ed-title" class="input-field" style="font-weight:700;font-size:18px;margin-bottom:12px;" value="${esc(s.title)}">

        <label class="editor-section-label">Texto-Base Bíblico</label>
        <div style="display:flex;gap:8px;margin-bottom:12px;">
          <input id="ed-ref" class="input-field" value="${esc(s.biblicalReference)}" placeholder="Ex: Romanos 8:28-39">
          <button class="btn btn-outline" id="ed-pick-book-btn" title="Escolher Livro">📚</button>
        </div>

        <div class="form-grid-2" style="margin-bottom:12px;">
          <div>
            <label class="editor-section-label">Categoria</label>
            <select id="ed-cat" class="select-field">
              ${SERMON_CATEGORIES.map((c) => `<option ${s.category === c ? 'selected' : ''}>${esc(c)}</option>`).join('')}
            </select>
          </div>
          <div>
            <label class="editor-section-label">Tipo Homilético</label>
            <select id="ed-type" class="select-field">
              ${SERMON_TYPES.map((t) => `<option ${s.sermonType === t ? 'selected' : ''}>${esc(t)}</option>`).join('')}
            </select>
          </div>
        </div>

        <div class="form-grid-2">
          <div>
            <label class="editor-section-label">Status</label>
            <select id="ed-status" class="select-field">
              <option value="draft" ${s.status === 'draft' ? 'selected' : ''}>Rascunho</option>
              <option value="in_review" ${s.status === 'in_review' ? 'selected' : ''}>Em Revisão</option>
              <option value="ready" ${s.status === 'ready' ? 'selected' : ''}>Pronto para Púlpito</option>
            </select>
          </div>
          <div>
            <label class="editor-section-label">Duração Estimada (min)</label>
            <input id="ed-dur" type="number" class="input-field" value="${esc(s.estimatedDurationMinutes)}">
          </div>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px;">
        <label class="editor-section-label">📖 Introdução da Mensagem</label>
        <textarea id="ed-intro" class="textarea-field" rows="4" placeholder="Captação de atenção e introdução...">${esc(s.introduction)}</textarea>
      </div>

      <div class="section-header">
        <h2 class="section-title">Pontos Principais (${s.blocks.length})</h2>
        <button class="btn btn-sm btn-primary" id="ed-add-block">＋ Adicionar Ponto</button>
      </div>

      <div id="ed-blocks-wrap">
        ${s.blocks.map((b, i) => `
          <div class="block-card" data-block-idx="${i}">
            <div class="block-head">
              <span class="point-pill">Ponto ${i + 1}</span>
              <button class="btn btn-xs btn-danger" data-remove-block="${i}">🗑️ Remover</button>
            </div>
            <input class="input-field" data-bfield="title" value="${esc(b.title)}" placeholder="Título do ponto">
            <input class="input-field" data-bfield="biblicalReference" value="${esc(b.biblicalReference)}" placeholder="Versículo específico (Ex: v. 6)">
            <textarea class="textarea-field" rows="3" data-bfield="explanation" placeholder="Explanação Teológica / Exegese">${esc(b.explanation)}</textarea>
            <textarea class="textarea-field" rows="2" data-bfield="illustration" placeholder="💡 Ilustração Prática">${esc(b.illustration)}</textarea>
            <textarea class="textarea-field" rows="2" data-bfield="application" placeholder="🎯 Aplicação para a Vida">${esc(b.application)}</textarea>
          </div>
        `).join('')}
      </div>

      <div class="card" style="margin-bottom:16px;">
        <label class="editor-section-label">🏁 Conclusão</label>
        <textarea id="ed-conc" class="textarea-field" rows="3" placeholder="Recapitulação e desfecho..." style="margin-bottom:14px;">${esc(s.conclusion)}</textarea>
        <label class="editor-section-label">🔥 Apelo & Oração Ministerial</label>
        <textarea id="ed-appeal" class="textarea-field" rows="3" placeholder="Chamada à decisão...">${esc(s.appeal)}</textarea>
      </div>

      <div style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:14px;">
        <button class="btn btn-emerald" id="ed-save-bottom-btn" style="flex:1;">💾 Salvar Sermão</button>
        <button class="btn btn-whatsapp" id="ed-wa-btn" style="flex:1;">💬 Compartilhar WhatsApp</button>
        <button class="btn btn-outline" id="ed-pdf-btn" style="flex:1;">🖨️ Exportar PDF A4</button>
      </div>

      <button class="btn btn-danger btn-block" id="ed-del-bottom-btn">🗑️ Excluir este Sermão</button>
    `;

    const persistEditorLive = () => {
      flushActiveEditorIfNeeded();
      const updated = state.editingSermon;
      const stEl = document.getElementById('ed-save-status');
      const htEl = document.getElementById('ed-header-title');
      if (stEl) stEl.textContent = '✓ Salvo agora no aparelho';
      if (htEl && updated) htEl.textContent = updated.title || 'Novo Sermão';
    };

    const bindInput = (sel, field, isNum = false) => {
      const el = root.querySelector(sel);
      if (!el) return;
      const handler = () => {
        state.editingSermon[field] = isNum ? Number(el.value || 40) : el.value;
        persistEditorLive();
      };
      el.addEventListener('input', handler);
      el.addEventListener('change', handler);
    };

    const handleExplicitSave = () => {
      persistEditorLive();
      showToast(`Sermão "${state.editingSermon?.title || 'Novo Sermão'}" salvo com sucesso!`, 'success');
    };
    root.querySelector('#ed-save-top-btn').onclick = handleExplicitSave;
    root.querySelector('#ed-save-bottom-btn').onclick = handleExplicitSave;

    bindInput('#ed-title', 'title');
    bindInput('#ed-ref', 'biblicalReference');
    bindInput('#ed-cat', 'category');
    bindInput('#ed-type', 'sermonType');
    bindInput('#ed-status', 'status');
    bindInput('#ed-dur', 'estimatedDurationMinutes', true);
    bindInput('#ed-intro', 'introduction');
    bindInput('#ed-conc', 'conclusion');
    bindInput('#ed-appeal', 'appeal');

    root.querySelectorAll('.block-card').forEach((card) => {
      const idx = Number(card.dataset.blockIdx);
      card.querySelectorAll('[data-bfield]').forEach((inp) => {
        inp.addEventListener('input', () => {
          state.editingSermon.blocks[idx][inp.dataset.bfield] = inp.value;
          persistEditorLive();
        });
      });
    });

    root.querySelectorAll('[data-remove-block]').forEach((btn) => {
      btn.onclick = () => {
        const idx = Number(btn.dataset.removeBlock);
        state.editingSermon.blocks.splice(idx, 1);
        persistEditorLive();
        renderMain();
      };
    });

    root.querySelector('#ed-add-block').onclick = () => {
      const idx = state.editingSermon.blocks.length;
      state.editingSermon.blocks.push({
        id: uuid(),
        title: `Ponto ${idx + 1}`,
        biblicalReference: '',
        explanation: '',
        illustration: '',
        application: '',
        orderIndex: idx,
      });
      persistEditorLive();
      renderMain();
    };

    root.querySelector('#ed-back-btn').onclick = () => switchTab('library');
    root.querySelector('#ed-pulpit-btn').onclick = () => openPulpitMode(state.editingSermon);
    root.querySelector('#ed-wa-btn').onclick = () => shareSermonWhatsApp(state.editingSermon);
    root.querySelector('#ed-pdf-btn').onclick = () => printSermonPdf(state.editingSermon);
    root.querySelector('#ed-bible-btn').onclick = () => switchTab('bible');
    root.querySelector('#ed-ai-btn').onclick = () => {
      state.ai.theme = state.editingSermon.title;
      state.ai.ref = state.editingSermon.biblicalReference;
      openAiModal((outline) => {
        state.editingSermon = {
          ...state.editingSermon,
          title: outline.title,
          biblicalReference: outline.biblicalReference,
          sermonType: outline.sermonType,
          introduction: outline.introduction,
          blocks: outline.blocks,
          conclusion: outline.conclusion,
          appeal: outline.appeal,
        };
        persistEditorLive();
        renderMain();
        showToast('Esboço inserido no sermão!', 'success');
      });
    };

    root.querySelector('#ed-pick-book-btn').onclick = () => {
      openBibleSelectorModal((bookId) => {
        const meta = CANONICAL_BOOKS.find((b) => b.id === bookId);
        if (meta) {
          state.editingSermon.biblicalReference = `${meta.name} 1:1`;
          persistEditorLive();
          renderMain();
        }
      });
    };

    const doDelete = () =>
      confirmDeleteSermon(state.editingSermon, () => {
        state.editingSermon = null;
        switchTab('library');
      });
    root.querySelector('#ed-del-top-btn').onclick = doDelete;
    root.querySelector('#ed-del-bottom-btn').onclick = doDelete;
  }

  // ---- TELA 4: BÍBLIA SAGRADA + VOZES BRASIL RJ ----
  function openBibleSelectorModal(onPick) {
    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title">📚 Selecionar Livro Bíblico</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <div style="font-size:12px;font-weight:800;color:var(--text-muted);margin:6px 0;">ANTIGO TESTAMENTO (39)</div>
      <div class="books-grid" style="margin-bottom:14px;">
        ${CANONICAL_BOOKS.filter((b) => b.t === 'AT').map((b) =>
          `<button class="book-tile ${state.settings.bibleBook === b.id ? 'active' : ''}" data-book="${b.id}">${esc(b.name)}</button>`
        ).join('')}
      </div>
      <div style="font-size:12px;font-weight:800;color:var(--text-muted);margin:6px 0;">NOVO TESTAMENTO (27)</div>
      <div class="books-grid">
        ${CANONICAL_BOOKS.filter((b) => b.t === 'NT').map((b) =>
          `<button class="book-tile ${state.settings.bibleBook === b.id ? 'active' : ''}" data-book="${b.id}">${esc(b.name)}</button>`
        ).join('')}
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelectorAll('[data-book]').forEach((b) => {
          b.onclick = () => {
            closeModal();
            onPick(b.dataset.book);
          };
        });
      }
    );
  }

  function openVoiceStudioModal() {
    refreshBrowserVoices();
    const isMale = state.settings.voiceGender === 'male';
    const hasKey = Boolean(state.settings.geminiKey?.trim());
    const useNeural = state.settings.useNeuralAudio !== false && hasKey;

    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title">🎙️ Configuração de Áudio Bíblico (pt-BR)</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>

      <div style="background:rgba(37,99,235,0.08);border:1px solid rgba(37,99,235,0.25);border-radius:10px;padding:10px 14px;margin-bottom:12px;">
        <div style="font-size:11px;font-weight:800;color:var(--text-muted);text-transform:uppercase;letter-spacing:0.5px;margin-bottom:2px;">Motor de Áudio Ativo no Momento:</div>
        <div style="font-size:14px;font-weight:800;color:var(--primary);display:flex;align-items:center;gap:6px;">
          <span>${isMale ? '👨' : '👩'}</span>
          <span>${esc(state.tts.activeLabel)}</span>
        </div>
      </div>

      <div style="background:rgba(139,92,246,0.08);border:1px solid rgba(139,92,246,0.3);border-radius:10px;padding:12px;margin-bottom:14px;">
        <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;">
          <div>
            <strong style="font-size:13px;display:flex;align-items:center;gap:5px;">
              <span>💎</span> Voz Neural Gemini HD (Qualidade de Estúdio)
            </strong>
            <div style="font-size:11.5px;color:var(--text-muted);margin-top:2px;">
              ${hasKey ? 'Chave Pro ativa. Áudio humano real com dicção solene de púlpito (Charon / Aoede).' : 'Configure uma Chave Pro para desbloquear voz humana de estúdio.'}
            </div>
          </div>
          <label style="display:flex;align-items:center;gap:6px;cursor:pointer;font-size:12.5px;font-weight:700;">
            <input type="checkbox" id="vs-neural-toggle" ${useNeural ? 'checked' : ''} ${!hasKey ? 'disabled' : ''} style="width:18px;height:18px;">
            Ativada
          </label>
        </div>
      </div>

      <div style="font-size:12px;font-weight:800;color:var(--text-muted);margin-bottom:8px;text-transform:uppercase;letter-spacing:0.5px;">
        Escolha o Gênero da Leitura:
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:14px;">
        <button class="btn ${isMale && !state.settings.voiceId ? 'btn-primary' : 'btn-outline'}" id="vs-male" style="padding:12px;font-weight:800;display:flex;align-items:center;justify-content:center;gap:6px;">
          👨 Voz Masculina
        </button>
        <button class="btn ${!isMale && !state.settings.voiceId ? 'btn-purple' : 'btn-outline'}" id="vs-female" style="padding:12px;font-weight:800;display:flex;align-items:center;justify-content:center;gap:6px;">
          👩 Voz Feminina
        </button>
      </div>

      <div style="background:rgba(245,158,11,0.08);border:1px solid rgba(245,158,11,0.3);border-radius:10px;padding:10px 12px;margin-bottom:14px;font-size:12px;line-height:1.45;color:var(--text);">
        <strong>💡 Por que o som do Google Chrome parece mecânico/robótico?</strong><br>
        O Chrome no Windows só acessa os sintetizadores de 2006 do sistema (<em>Microsoft Daniel e Maria</em>).<br>
        <strong>Como ter áudio 100% humano:</strong><br>
        1. <strong>Opção 1 (Grátis sem IA)</strong>: Abra o Pregador Pro no <strong>Microsoft Edge</strong>. O Edge já inclui de fábrica as vozes neurais de rádio <em>Antonio Natural</em> e <em>Francisca Natural</em>.<br>
        2. <strong>Opção 2</strong>: Mantenha ativada a <strong>Voz Neural Gemini HD</strong> acima.
      </div>

      <div style="font-size:12px;font-weight:800;color:var(--text-muted);margin-bottom:8px;text-transform:uppercase;letter-spacing:0.5px;">
        Sintetizadores Instalados no seu Dispositivo (${state.tts.voices.length}):
      </div>
      ${state.tts.voices.length > 0 ? `
        <div style="display:flex;flex-direction:column;gap:8px;max-height:160px;overflow-y:auto;margin-bottom:14px;">
          ${state.tts.voices.map((v) => {
            const isCur = state.settings.voiceId === v.id;
            return `
              <div style="display:flex;align-items:center;justify-content:space-between;padding:9px 12px;border-radius:8px;background:var(--card-bg);border:1px solid ${isCur ? 'var(--primary)' : 'var(--border)'};gap:8px;">
                <div style="display:flex;flex-direction:column;gap:2px;flex:1;min-width:0;">
                  <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
                    <strong style="font-size:12.5px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${esc(v.name)}</strong>
                    <span class="tag ${v.isMale ? 'tag-blue' : 'tag-pink'}" style="font-size:10px;padding:1px 6px;">${v.isMale ? 'Masculina' : v.isFemale ? 'Feminina' : 'Neutra'}</span>
                    ${v.isNatural ? `<span class="tag tag-gold" style="font-size:10px;padding:1px 6px;">Natural HD</span>` : ''}
                  </div>
                  <span style="font-size:11px;color:var(--text-muted);">${esc(v.lang)}</span>
                </div>
                <div style="display:flex;align-items:center;gap:6px;">
                  <button class="btn btn-xs btn-outline" data-sample-voice="${esc(v.id)}" title="Ouvir amostra">▶ Ouvir</button>
                  <button class="btn btn-xs ${isCur ? 'btn-primary' : 'btn-outline'}" data-pick-voice="${esc(v.id)}" title="Selecionar">
                    ${isCur ? '✓ Ativa' : 'Selecionar'}
                  </button>
                </div>
              </div>
            `;
          }).join('')}
        </div>
      ` : `
        <p style="font-size:12.5px;color:var(--text-muted);margin-bottom:14px;">Nenhum sintetizador adicional detectado.</p>
      `}

      <button class="btn btn-gold btn-block" id="vs-test-btn" style="padding:12px;font-weight:800;">
        ▶ Testar Áudio Bíblico Agora (Salmos 23:1)
      </button>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));

        const neuralTgl = sheet.querySelector('#vs-neural-toggle');
        if (neuralTgl) {
          neuralTgl.onchange = (e) => {
            state.settings.useNeuralAudio = e.target.checked;
            if (e.target.checked) state.settings.voiceId = '';
            writeStore(KEYS.SETTINGS, state.settings);
            updateActiveVoiceLabel();
            openVoiceStudioModal();
          };
        }

        sheet.querySelector('#vs-male').onclick = () => {
          state.settings.voiceGender = 'male';
          state.settings.voiceId = '';
          writeStore(KEYS.SETTINGS, state.settings);
          updateActiveVoiceLabel();
          openVoiceStudioModal();
        };

        sheet.querySelector('#vs-female').onclick = () => {
          state.settings.voiceGender = 'female';
          state.settings.voiceId = '';
          writeStore(KEYS.SETTINGS, state.settings);
          updateActiveVoiceLabel();
          openVoiceStudioModal();
        };

        sheet.querySelectorAll('[data-sample-voice]').forEach((b) => {
          b.onclick = () => {
            sampleVoice(b.dataset.sampleVoice);
          };
        });

        sheet.querySelectorAll('[data-pick-voice]').forEach((b) => {
          b.onclick = () => {
            const vId = b.dataset.pickVoice;
            const found = state.tts.voices.find((x) => x.id === vId);
            state.settings.voiceId = vId;
            state.settings.useNeuralAudio = false; // Desativa neural se o usuário escolher explicitamente uma voz do aparelho
            if (found) {
              state.settings.voiceGender = found.isMale ? 'male' : 'female';
            }
            writeStore(KEYS.SETTINGS, state.settings);
            updateActiveVoiceLabel();
            openVoiceStudioModal();
          };
        });

        sheet.querySelector('#vs-test-btn').onclick = () => {
          startBibleSpeech([{
            bookId: 'sl', bookName: 'Salmos', chapter: 23, verse: 1,
            text: 'O Senhor é o meu pastor; nada me faltará.',
          }]);
        };
      }
    );
  }

  async function renderBible(root) {
    const ver = state.settings.bibleVersion || 'ARC';
    const bId = state.settings.bibleBook || 'sl';
    const ch = state.settings.bibleChapter || 23;
    const bMeta = CANONICAL_BOOKS.find((b) => b.id === bId) || CANONICAL_BOOKS[18];

    if (!state.bible.cache[ver]) {
      root.innerHTML = `<div class="boot-skeleton"><div class="spinner"></div><p>Carregando Bíblia ${esc(ver)}...</p></div>`;
      await loadBibleVersion(ver);
    }

    const booksData = state.bible.cache[ver] || [];
    const bookObj = getBookData(booksData, bId);
    const totalChapters = bookObj?.chapters?.length || 1;
    const verses = getChapterVerses(booksData, bId, ch);

    let compareData = null;
    if (state.bible.isComparing) {
      const compVers = state.settings.bibleCompareVersions || ['ARC', 'NVI'];
      await Promise.all(compVers.map((v) => loadBibleVersion(v)));
      compareData = compVers.map((v) => ({
        version: v,
        verses: getChapterVerses(state.bible.cache[v] || [], bId, ch),
      }));
    }

    const isMale = state.settings.voiceGender === 'male';
    const curSpoken = state.tts.queue[state.tts.index];

    root.innerHTML = `
      <div class="bible-header-bar">
        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
          <button class="btn btn-sm btn-outline" id="bib-book-btn">📖 ${esc(bMeta.name)} ${ch} ▾</button>
          <select id="bib-ch-sel" class="select-field" style="width:auto;padding:7px 12px;">
            ${Array.from({ length: totalChapters }, (_, i) => `<option value="${i + 1}" ${i + 1 === ch ? 'selected' : ''}>Cap. ${i + 1}</option>`).join('')}
          </select>
          <select id="bib-ver-sel" class="select-field" style="width:auto;padding:7px 12px;font-weight:700;color:var(--primary);">
            ${BIBLE_VERSIONS.map((v) => `<option value="${v.id}" ${v.id === ver ? 'selected' : ''}>${v.id}</option>`).join('')}
          </select>
        </div>
        <div style="display:flex;align-items:center;gap:6px;">
          <button class="btn btn-sm ${state.bible.isComparing ? 'btn-gold' : 'btn-outline'}" id="bib-cmp-btn" title="Comparar Versões">⇄</button>
          <button class="btn btn-sm ${state.bible.showSearch ? 'btn-primary' : 'btn-outline'}" id="bib-search-toggle">🔍</button>
          <button class="btn btn-sm btn-outline" id="bib-font-dec">A-</button>
          <button class="btn btn-sm btn-outline" id="bib-font-inc">A+</button>
        </div>
      </div>

      ${state.bible.showSearch ? `
        <div class="toolbar-card">
          <div style="display:flex;gap:8px;">
            <input id="bib-search-inp" class="input-field" placeholder="Buscar palavra ou frase (ex: todas as coisas)..." value="${esc(state.bible.searchQuery)}">
            <button class="btn btn-primary" id="bib-search-go">Buscar</button>
          </div>
          ${state.bible.searchResults.length ? `
            <div style="max-height:260px;overflow-y:auto;display:flex;flex-direction:column;gap:8px;">
              ${state.bible.searchResults.slice(0, 60).map((r) => `
                <button class="card" style="text-align:left;padding:10px 12px;" data-jump-verse="${esc(r.bookId)}|${r.chapter}">
                  <strong style="color:var(--gold);font-size:13px;">${esc(r.reference)}</strong>
                  <div style="font-size:13.5px;margin-top:3px;">${esc(r.text)}</div>
                </button>
              `).join('')}
            </div>
          ` : state.bible.searchQuery ? `<span style="font-size:13px;color:var(--text-muted);">Nenhum resultado encontrado.</span>` : ''}
        </div>
      ` : ''}

      <div class="voice-studio-card">
        <div class="voice-studio-row">
          <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
            <span style="font-size:12px;font-weight:800;">🎙️ Voz:</span>
            <button class="chip ${isMale ? 'active' : ''}" id="tts-male-btn">👨 Masculina</button>
            <button class="chip ${!isMale ? 'active' : ''}" id="tts-female-btn">👩 Feminina</button>
            <button class="chip" id="tts-voices-btn">⚙️ Vozes do Aparelho</button>
          </div>
          <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
            <select id="tts-rate-sel" class="select-field" style="width:auto;padding:5px 10px;font-size:13px;">
              <option value="0.75" ${Math.abs(state.settings.voiceRate - 0.75) < 0.05 ? 'selected' : ''}>0.75x Solene</option>
              <option value="0.85" ${Math.abs(state.settings.voiceRate - 0.85) < 0.05 ? 'selected' : ''}>0.85x Calma</option>
              <option value="1.00" ${Math.abs(state.settings.voiceRate - 1.00) < 0.05 ? 'selected' : ''}>1.0x Padrão</option>
              <option value="1.15" ${Math.abs(state.settings.voiceRate - 1.15) < 0.05 ? 'selected' : ''}>1.15x Fluida RJ</option>
              <option value="1.25" ${Math.abs(state.settings.voiceRate - 1.25) < 0.05 ? 'selected' : ''}>1.25x Dinâmica</option>
              <option value="1.50" ${Math.abs(state.settings.voiceRate - 1.50) < 0.05 ? 'selected' : ''}>1.5x Acelerada</option>
              <option value="1.75" ${Math.abs(state.settings.voiceRate - 1.75) < 0.05 ? 'selected' : ''}>1.75x Rápida</option>
              <option value="2.00" ${Math.abs(state.settings.voiceRate - 2.00) < 0.05 ? 'selected' : ''}>2.0x Máxima</option>
            </select>
            <button class="btn btn-xs ${state.tts.isSelectionMode ? 'btn-gold' : 'btn-outline'}" id="tts-sel-btn">
              ☑ ${state.tts.selectedVerses.size > 0 ? `Trecho (${state.tts.selectedVerses.size})` : 'Trecho'}
            </button>
            ${!state.tts.isPlaying ? `
              <button class="btn btn-sm btn-gold" id="tts-play-btn">▶ ${state.tts.selectedVerses.size > 0 ? 'Ouvir Trecho' : 'Ouvir Capítulo'}</button>
            ` : `
              <button class="btn btn-xs btn-outline" id="tts-prev-btn">⏮</button>
              <button class="btn btn-xs btn-gold" id="tts-pause-btn">${state.tts.isPaused ? '▶' : '⏸'}</button>
              <button class="btn btn-xs btn-outline" id="tts-next-btn">⏭</button>
              <button class="btn btn-xs btn-danger" id="tts-stop-btn">⏹</button>
            `}
          </div>
        </div>
        <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;font-size:12px;color:var(--text-muted);">
          <span>${state.tts.isPlaying && curSpoken ? `🔊 Lendo ${esc(curSpoken.reference)} • ${esc(state.tts.activeLabel)}` : `Motor ativo: ${esc(state.tts.activeLabel)}`}</span>
          ${!state.tts.isPlaying ? `<button class="btn btn-xs btn-outline" id="tts-sample-btn">Testar voz</button>` : ''}
        </div>
      </div>

      ${compareData ? `
        <div class="card">
          ${verses.map((v, idx) => `
            <div style="padding:12px 0;border-bottom:1px solid var(--border);">
              <strong style="color:var(--gold);">Versículo ${v.verse}</strong>
              ${compareData.map((col) => `
                <div style="margin-top:6px;font-size:${state.settings.bibleFont}px;">
                  <span class="tag tag-blue" style="margin-right:6px;">${esc(col.version)}</span>
                  ${esc(col.verses[idx]?.text || '')}
                </div>
              `).join('')}
            </div>
          `).join('')}
        </div>
      ` : `
        <div class="card" style="font-size:${state.settings.bibleFont}px;line-height:1.65;">
          ${verses.map((v) => {
            const isSpeaking = state.tts.isPlaying && curSpoken && curSpoken.verse === v.verse && curSpoken.chapter === v.chapter;
            const isSel = state.tts.selectedVerses.has(v.verse);
            return `
              <div class="verse-item ${isSpeaking ? 'speaking' : ''} ${isSel ? 'selected-verse' : ''}" data-verse-num="${v.verse}">
                <span class="verse-num">${v.verse}</span>
                <span>${esc(v.text)}</span>
              </div>
            `;
          }).join('')}
        </div>
      `}

      <div class="chapter-nav">
        <button class="btn btn-outline" id="bib-prev-ch" ${ch <= 1 ? 'disabled' : ''}>← Capítulo Anterior</button>
        <span style="font-weight:700;font-size:14px;">${esc(bMeta.name)} ${ch}</span>
        <button class="btn btn-outline" id="bib-next-ch" ${ch >= totalChapters ? 'disabled' : ''}>Próximo Capítulo →</button>
      </div>
    `;

    root.querySelector('#bib-book-btn').onclick = () => {
      openBibleSelectorModal((pickedId) => {
        stopBibleSpeech();
        state.settings.bibleBook = pickedId;
        state.settings.bibleChapter = 1;
        state.tts.selectedVerses.clear();
        writeStore(KEYS.SETTINGS, state.settings);
        renderMain();
      });
    };

    root.querySelector('#bib-ch-sel').onchange = (e) => {
      stopBibleSpeech();
      state.settings.bibleChapter = Number(e.target.value);
      state.tts.selectedVerses.clear();
      writeStore(KEYS.SETTINGS, state.settings);
      renderMain();
    };

    root.querySelector('#bib-ver-sel').onchange = (e) => {
      state.settings.bibleVersion = e.target.value;
      writeStore(KEYS.SETTINGS, state.settings);
      renderMain();
    };

    root.querySelector('#bib-cmp-btn').onclick = () => {
      state.bible.isComparing = !state.bible.isComparing;
      renderMain();
    };
    root.querySelector('#bib-search-toggle').onclick = () => {
      state.bible.showSearch = !state.bible.showSearch;
      renderMain();
    };
    root.querySelector('#bib-font-dec').onclick = () => {
      state.settings.bibleFont = Math.max(14, state.settings.bibleFont - 2);
      writeStore(KEYS.SETTINGS, state.settings);
      renderMain();
    };
    root.querySelector('#bib-font-inc').onclick = () => {
      state.settings.bibleFont = Math.min(32, state.settings.bibleFont + 2);
      writeStore(KEYS.SETTINGS, state.settings);
      renderMain();
    };

    const runBibleSearch = () => {
      const q = (root.querySelector('#bib-search-inp')?.value || '').trim().toLowerCase();
      state.bible.searchQuery = q;
      const found = [];
      if (q.length >= 2) {
        for (const bk of booksData) {
          const bName = CANONICAL_BOOKS.find((x) => x.id === bk.abbrev)?.name || bk.name;
          (bk.chapters || []).forEach((chArr, ci) => {
            chArr.forEach((txt, vi) => {
              if (txt.toLowerCase().includes(q)) {
                found.push({
                  bookId: bk.abbrev,
                  chapter: ci + 1,
                  verse: vi + 1,
                  text: txt,
                  reference: `${bName} ${ci + 1}:${vi + 1}`,
                });
              }
            });
          });
          if (found.length >= 80) break;
        }
      }
      state.bible.searchResults = found;
      renderMain();
    };

    const goBtn = root.querySelector('#bib-search-go');
    if (goBtn) goBtn.onclick = runBibleSearch;
    const inpSearch = root.querySelector('#bib-search-inp');
    if (inpSearch) inpSearch.onkeydown = (e) => { if (e.key === 'Enter') runBibleSearch(); };
    root.querySelectorAll('[data-jump-verse]').forEach((b) => {
      b.onclick = () => {
        const [jb, jc] = b.dataset.jumpVerse.split('|');
        state.settings.bibleBook = jb;
        state.settings.bibleChapter = Number(jc);
        state.bible.showSearch = false;
        writeStore(KEYS.SETTINGS, state.settings);
        renderMain();
      };
    });

    // Controles de Voz
    root.querySelector('#tts-male-btn').onclick = () => {
      state.settings.voiceGender = 'male';
      state.settings.voiceId = '';
      writeStore(KEYS.SETTINGS, state.settings);
      updateActiveVoiceLabel();
      if (state.tts.isPlaying) speakQueueItem(false, true);
      else renderMain();
    };
    root.querySelector('#tts-female-btn').onclick = () => {
      state.settings.voiceGender = 'female';
      state.settings.voiceId = '';
      writeStore(KEYS.SETTINGS, state.settings);
      updateActiveVoiceLabel();
      if (state.tts.isPlaying) speakQueueItem(false, true);
      else renderMain();
    };
    root.querySelector('#tts-voices-btn').onclick = openVoiceStudioModal;
    root.querySelector('#tts-rate-sel').onchange = (e) => {
      state.settings.voiceRate = Number(e.target.value);
      writeStore(KEYS.SETTINGS, state.settings);
      if (state.tts.isPlaying) speakQueueItem(false, true);
    };
    root.querySelector('#tts-sel-btn').onclick = () => {
      state.tts.isSelectionMode = !state.tts.isSelectionMode;
      if (!state.tts.isSelectionMode) state.tts.selectedVerses.clear();
      renderMain();
    };

    const playBtn = root.querySelector('#tts-play-btn');
    if (playBtn) {
      playBtn.onclick = () => {
        if (state.tts.selectedVerses.size > 0) {
          const picked = verses.filter((v) => state.tts.selectedVerses.has(v.verse));
          startBibleSpeech(picked);
        } else {
          startBibleSpeech(verses);
        }
      };
    }
    const sampleBtn = root.querySelector('#tts-sample-btn');
    if (sampleBtn) {
      sampleBtn.onclick = () =>
        startBibleSpeech([{ bookId: 'sl', bookName: 'Salmos', chapter: 23, verse: 1, text: 'O Senhor é o meu pastor; nada me faltará.' }]);
    }
    const pauseBtn = root.querySelector('#tts-pause-btn');
    if (pauseBtn) {
      pauseBtn.onclick = () => {
        if (state.tts.isPaused) {
          state.tts.isPaused = false;
          speakQueueItem(false, true);
        } else {
          _ttsToken++;
          try { _ttsAudioEl?.pause(); } catch (_) {}
          try { window.speechSynthesis?.cancel(); } catch (_) {}
          state.tts.isPaused = true;
          renderMain();
        }
      };
    }
    const prevBtn = root.querySelector('#tts-prev-btn');
    if (prevBtn) {
      prevBtn.onclick = () => {
        if (state.tts.index > 0) {
          state.tts.index--;
          speakQueueItem(false, true);
        }
      };
    }
    const nextBtn = root.querySelector('#tts-next-btn');
    if (nextBtn) {
      nextBtn.onclick = () => {
        if (state.tts.index + 1 < state.tts.queue.length) {
          state.tts.index++;
          speakQueueItem(false, true);
        }
      };
    }
    const stopBtn = root.querySelector('#tts-stop-btn');
    if (stopBtn) stopBtn.onclick = stopBibleSpeech;

    root.querySelectorAll('.verse-item').forEach((el) => {
      el.onclick = () => {
        const vNum = Number(el.dataset.verseNum);
        const verseObj = verses.find((v) => v.verse === vNum);
        if (!verseObj) return;
        if (state.tts.isSelectionMode) {
          if (state.tts.selectedVerses.has(vNum)) state.tts.selectedVerses.delete(vNum);
          else state.tts.selectedVerses.add(vNum);
          renderMain();
          return;
        }
        openModal(
          `
          <div class="modal-header">
            <h3 class="modal-title">${esc(verseObj.reference)} (${esc(ver)})</h3>
            <button class="icon-btn-ghost" data-close-modal>✕</button>
          </div>
          <p style="font-size:16px;line-height:1.55;margin:0 0 16px;">"${esc(verseObj.text)}"</p>
          <div style="display:flex;flex-direction:column;gap:8px;">
            <button class="btn btn-gold" id="va-speak">🔊 Ouvir a partir deste versículo</button>
            <button class="btn btn-primary" id="va-insert">＋ Inserir em Novo Sermão / Esboço</button>
            <button class="btn btn-whatsapp" id="va-wa">💬 Enviar no WhatsApp</button>
            <button class="btn btn-outline" id="va-copy">📋 Copiar Versículo</button>
          </div>
          `,
          (sheet) => {
            sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
            sheet.querySelector('#va-speak').onclick = () => {
              closeModal();
              startBibleSpeech(verses.filter((v) => v.verse >= vNum));
            };
            sheet.querySelector('#va-insert').onclick = () => {
              closeModal();
              const sermon = saveSermon({
                id: uuid(),
                userId: state.profile.id,
                title: `Meditação em ${verseObj.reference}`,
                biblicalReference: verseObj.reference,
                category: 'Expositivo',
                sermonType: 'Expositivo',
                introduction: `"${verseObj.text}" (${ver})`,
                blocks: [{ id: uuid(), title: `1. ${verseObj.reference}`, biblicalReference: verseObj.reference, explanation: verseObj.text, orderIndex: 0 }],
                status: 'draft',
              });
              openSermonEditor(sermon);
            };
            sheet.querySelector('#va-wa').onclick = () => {
              window.open(`https://wa.me/?text=${encodeURIComponent(`📖 *${verseObj.reference} (${ver}):*\n"${verseObj.text}"`)}`, '_blank');
            };
            sheet.querySelector('#va-copy').onclick = () => {
              navigator.clipboard?.writeText(`${verseObj.reference} (${ver}): "${verseObj.text}"`);
              closeModal();
              showToast('Versículo copiado!', 'success');
            };
          }
        );
      };
    });

    root.querySelector('#bib-prev-ch').onclick = () => {
      if (ch > 1) {
        stopBibleSpeech();
        state.settings.bibleChapter = ch - 1;
        writeStore(KEYS.SETTINGS, state.settings);
        renderMain();
      }
    };
    root.querySelector('#bib-next-ch').onclick = () => {
      if (ch < totalChapters) {
        stopBibleSpeech();
        state.settings.bibleChapter = ch + 1;
        writeStore(KEYS.SETTINGS, state.settings);
        renderMain();
      }
    };
  }

  // ---- TELA 5: ACERVO DE MODELOS (150) ----
  function renderTemplates(root) {
    const visible = state.templates.filter((t) => !state.deletedIds.has(t.id));
    const f = state.templateFilters;
    const q = f.query.trim().toLowerCase();

    const filtered = visible.filter((t) => {
      if (f.type !== 'Todos' && (t.sermonType || '').toLowerCase() !== f.type.toLowerCase()) return false;
      if (f.tag && !(t.tags || []).some((tg) => tg.toLowerCase() === f.tag.toLowerCase())) return false;
      if (q) {
        const hay = `${t.title} ${t.theme} ${t.keyVerse} ${(t.tags || []).join(' ')}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });

    const tagsSet = new Set();
    visible.forEach((t) => (t.tags || []).forEach((tg) => tagsSet.add(tg)));
    const topTags = Array.from(tagsSet).slice(0, 12);

    root.innerHTML = `
      <div class="section-header" style="margin-top:0;">
        <div>
          <h1 class="section-title" style="font-size:22px;">Acervo de Modelos Homiléticos</h1>
          <span class="section-subtitle">${visible.length} esboços completos com 5 divisões para clonar ou excluir</span>
        </div>
      </div>

      <div class="toolbar-card">
        <input id="tpl-search" class="input-field" placeholder="Buscar por título, tema ou versículo..." value="${esc(f.query)}">
        <div class="chips-scroll">
          ${['Todos', 'Expositivo', 'Temático', 'Textual'].map((tp) =>
            `<button class="chip ${f.type === tp ? 'active' : ''}" data-tpl-type="${tp}">${tp}</button>`
          ).join('')}
          ${topTags.map((tg) =>
            `<button class="chip ${f.tag === tg ? 'active' : ''}" data-tpl-tag="${esc(tg)}">${esc(tg)}</button>`
          ).join('')}
        </div>
      </div>

      <div class="sermon-list" id="tpl-list">
        ${filtered.map((t) => {
          const isExp = f.expandedIds.has(t.id);
          const blocks = t.content?.blocks || [];
          return `
            <article class="sermon-card">
              <div class="sermon-card-top">
                <h3 class="sermon-title">${esc(t.title)}</h3>
                <div class="sermon-top-icons">
                  <span class="tag tag-blue">${esc(t.sermonType)}</span>
                  <button class="icon-btn-ghost" title="Excluir Modelo" style="color:var(--danger);" data-del-tpl="${esc(t.id)}">🗑️</button>
                </div>
              </div>
              <div style="font-size:13.5px;color:var(--text-muted);margin:6px 0;">${esc(t.theme)}</div>
              <div class="tags-row">
                <span class="tag tag-gold">🔖 ${esc(t.keyVerse)}</span>
                ${(t.tags || []).map((tg) => `<span class="tag tag-muted">${esc(tg)}</span>`).join('')}
              </div>
              ${isExp ? `
                <div style="margin:10px 0;padding:12px;border-radius:12px;background:var(--surface-2);">
                  <p style="font-size:13.5px;margin:0 0 10px;"><strong>Introdução:</strong> ${esc(t.content?.introduction || '')}</p>
                  ${blocks.map((b, i) => `
                    <div style="margin-bottom:8px;font-size:13.5px;">
                      <strong>${esc(b.title || `Ponto ${i + 1}`)}</strong> (${esc(b.biblicalReference)})
                      <div style="color:var(--text-muted);">${esc(b.explanation)}</div>
                    </div>
                  `).join('')}
                </div>
              ` : ''}
              <div class="card-actions">
                <button class="btn btn-sm btn-outline" data-exp-tpl="${esc(t.id)}">${isExp ? '▲ Recolher' : `▼ Ver Estrutura (${blocks.length} pontos)`}</button>
                <button class="btn btn-sm btn-danger" data-del-tpl="${esc(t.id)}">🗑️ Excluir</button>
                <button class="btn btn-sm btn-primary" data-use-tpl="${esc(t.id)}">📋 Usar este Modelo</button>
              </div>
            </article>
          `;
        }).join('')}
      </div>
    `;

    root.querySelector('#tpl-search').oninput = (e) => {
      state.templateFilters.query = e.target.value;
      renderMain();
      const el = document.getElementById('tpl-search');
      if (el) { el.focus(); el.setSelectionRange(el.value.length, el.value.length); }
    };
    root.querySelectorAll('[data-tpl-type]').forEach((b) => {
      b.onclick = () => { state.templateFilters.type = b.dataset.tplType; renderMain(); };
    });
    root.querySelectorAll('[data-tpl-tag]').forEach((b) => {
      b.onclick = () => {
        state.templateFilters.tag = state.templateFilters.tag === b.dataset.tplTag ? null : b.dataset.tplTag;
        renderMain();
      };
    });
    root.querySelectorAll('[data-exp-tpl]').forEach((b) => {
      b.onclick = () => {
        const id = b.dataset.expTpl;
        if (state.templateFilters.expandedIds.has(id)) state.templateFilters.expandedIds.delete(id);
        else state.templateFilters.expandedIds.add(id);
        renderMain();
      };
    });
    root.querySelectorAll('[data-del-tpl]').forEach((b) => {
      b.onclick = () => {
        const tpl = state.templates.find((t) => t.id === b.dataset.delTpl);
        if (tpl) confirmDeleteTemplate(tpl);
      };
    });
    root.querySelectorAll('[data-use-tpl]').forEach((b) => {
      b.onclick = () => {
        const tpl = state.templates.find((t) => t.id === b.dataset.useTpl);
        if (!tpl) return;
        const cloned = saveSermon({
          id: uuid(),
          userId: state.profile.id,
          title: tpl.title,
          biblicalReference: tpl.keyVerse,
          sermonType: tpl.sermonType,
          category: (tpl.tags && tpl.tags[0]) || 'Geral',
          introduction: tpl.content?.introduction || '',
          blocks: (tpl.content?.blocks || []).map((blk, i) => ({ ...blk, id: uuid(), orderIndex: i })),
          conclusion: tpl.content?.conclusion || '',
          appeal: tpl.content?.appeal || '',
          status: 'draft',
        });
        showToast('Modelo clonado para edição!', 'success');
        openSermonEditor(cloned);
      };
    });
  }

  // ---- TELA 6: PERFIL, SINCRONIZAÇÃO SUPABASE REAL & BACKUP ----
  function renderProfile(root) {
    const p = state.profile;
    const isCloud = Boolean(state.cloudAuth?.accessToken);

    root.innerHTML = `
      <div class="hero-banner" style="margin-bottom:18px;">
        <div style="display:flex;align-items:center;gap:14px;flex-wrap:wrap;">
          <div class="user-avatar" style="width:60px;height:60px;font-size:24px;">${esc((p.fullName || 'P')[0].toUpperCase())}</div>
          <div style="min-width:0;flex:1;">
            <h1 style="margin:0 0 4px;font-size:21px;">${esc(p.fullName)}</h1>
            <div style="font-size:14px;opacity:0.85;">${esc(p.ministryTitle)} • ${esc(p.churchName || 'Ministério Local')}</div>
            <div style="font-size:12.5px;color:#93c5fd;margin-top:2px;">${esc(p.email)}</div>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <button class="btn btn-sm btn-gold" id="prof-edit-btn">✏️ Editar Perfil</button>
            <button class="btn btn-sm btn-danger" id="prof-logout-btn">🚪 Sair (Logoff)</button>
          </div>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px;">
        <h3 style="margin:0 0 6px;">☁️ Sincronização em Nuvem Supabase (Trabalho ↔ Casa ↔ iPhone)</h3>
        <p style="font-size:13.5px;color:var(--text-muted);margin:0 0 12px;">
          ${isCloud || _cloudDbReady
            ? `Banco PostgreSQL Supabase (<strong>yahvhltbfpebaievpumg</strong>) conectado para <strong>${esc(state.cloudAuth?.email || state.profile.email)}</strong>. Todos os sermões, perfil e preferências sincronizam automaticamente.`
            : 'Projeto Supabase <strong>yahvhltbfpebaievpumg</strong> configurado. Clique em Sincronizar Agora após executar o script SQL de liberação RLS no painel do Supabase.'}
        </p>
        <div style="display:flex;flex-wrap:wrap;gap:8px;">
          <button class="btn btn-sm btn-emerald" id="prof-sync-now">🔄 Sincronizar Agora</button>
          ${isCloud ? `
            <button class="btn btn-sm btn-outline" id="prof-cloud-logout">Desconectar Conta</button>
          ` : `
            <button class="btn btn-sm btn-outline" id="prof-cloud-login">🔑 Login por Senha (Opcional)</button>
          `}
        </div>
      </div>

      <div class="card" style="margin-bottom:16px;">
        <h3 style="margin:0 0 12px;">✨ Inteligência Artificial & Vozes</h3>
        <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;">
          <div>
            <div style="font-weight:700;">Gemini 2.5 Pro (Google AI)</div>
            <div style="font-size:13px;color:var(--text-muted);">${state.settings.geminiKey ? `Chave configurada • Modelo ${esc(state.settings.geminiModel)}` : 'Sem API Key configurada (usando motor local)'}</div>
          </div>
          <button class="btn btn-sm btn-purple" id="prof-gem-btn">⚙ Configurar Gemini Pro</button>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px;">
        <h3 style="margin:0 0 12px;">🎨 Aparência</h3>
        <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;">
          <div>
            <div style="font-weight:700;">Tema da Interface</div>
            <div style="font-size:13px;color:var(--text-muted);">Atual: ${state.settings.theme === 'dark' ? 'Escuro Executivo' : 'Claro Limpo'}</div>
          </div>
          <button class="btn btn-sm btn-outline" id="prof-theme-btn">🌓 Alternar Tema</button>
        </div>
      </div>

      <div class="card">
        <h3 style="margin:0 0 12px;">🛡️ Backup & Restauração</h3>
        <div style="display:flex;flex-wrap:wrap;gap:10px;">
          <button class="btn btn-sm btn-primary" id="prof-backup-export">⬇ Baixar Backup JSON</button>
          <label class="btn btn-sm btn-outline" style="cursor:pointer;">
            ⬆ Restaurar Backup JSON
            <input type="file" id="prof-backup-import" accept=".json" style="display:none;">
          </label>
        </div>
      </div>
    `;

    root.querySelector('#prof-edit-btn').onclick = () => {
      openModal(
        `
        <div class="modal-header">
          <h3 class="modal-title">Editar Perfil Ministerial</h3>
          <button class="icon-btn-ghost" data-close-modal>✕</button>
        </div>
        <label class="editor-section-label">Nome Completo</label>
        <input id="pf-name" class="input-field" value="${esc(p.fullName)}" style="margin-bottom:10px;">
        <label class="editor-section-label">Título Ministerial</label>
        <input id="pf-title" class="input-field" value="${esc(p.ministryTitle)}" style="margin-bottom:10px;">
        <label class="editor-section-label">Igreja / Ministério</label>
        <input id="pf-church" class="input-field" value="${esc(p.churchName || '')}" style="margin-bottom:16px;">
        <div style="display:flex;gap:8px;justify-content:flex-end;">
          <button class="btn btn-outline" data-close-modal>Cancelar</button>
          <button class="btn btn-primary" id="pf-save">Salvar Alterações</button>
        </div>
        `,
        (sheet) => {
          sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
          sheet.querySelector('#pf-save').onclick = () => {
            state.profile = {
              ...state.profile,
              fullName: sheet.querySelector('#pf-name').value.trim() || state.profile.fullName,
              ministryTitle: sheet.querySelector('#pf-title').value.trim() || state.profile.ministryTitle,
              churchName: sheet.querySelector('#pf-church').value.trim(),
            };
            markProfileUpdated();
            syncCloudNow({ silent: true, pushProfile: true });
            closeModal();
            renderChrome();
            renderMain();
            showToast('Perfil atualizado e salvo na nuvem!', 'success');
          };
        }
      );
    };

    const loginBtn = root.querySelector('#prof-cloud-login');
    if (loginBtn) {
      loginBtn.onclick = () => {
        openModal(
          `
          <div class="modal-header">
            <h3 class="modal-title">☁️ Conta Nuvem Supabase</h3>
            <button class="icon-btn-ghost" data-close-modal>✕</button>
          </div>
          <p style="font-size:13px;color:var(--text-muted);margin:0 0 12px;">
            Entre com sua conta Supabase ou cadastre uma nova com o mesmo e-mail para sincronizar tudo entre PC e iPhone.
          </p>
          <label class="editor-section-label">E-mail</label>
          <input id="cl-email" type="email" class="input-field" value="${esc(state.profile.email)}" style="margin-bottom:10px;">
          <label class="editor-section-label">Senha (mín. 6 caracteres)</label>
          <input id="cl-pass" type="password" class="input-field" placeholder="Sua senha" style="margin-bottom:12px;">
          <div id="cl-err" style="font-size:13px;color:var(--danger);margin-bottom:10px;"></div>
          <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end;">
            <button class="btn btn-outline" id="cl-signup">Criar Conta</button>
            <button class="btn btn-primary" id="cl-signin">Entrar</button>
          </div>
          `,
          (sheet) => {
            sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
            const errEl = sheet.querySelector('#cl-err');
            sheet.querySelector('#cl-signin').onclick = async () => {
              errEl.textContent = '';
              try {
                await signInCloud(sheet.querySelector('#cl-email').value, sheet.querySelector('#cl-pass').value);
                closeModal();
                await runAuthTransitionModal({
                  mode: 'login',
                  durationMs: 3500,
                  userName: state.profile.fullName,
                });
                renderChrome();
                renderMain();
              } catch (e) {
                errEl.textContent = e.message;
              }
            };
            sheet.querySelector('#cl-signup').onclick = async () => {
              errEl.textContent = '';
              try {
                const res = await signUpCloud(sheet.querySelector('#cl-email').value, sheet.querySelector('#cl-pass').value);
                closeModal();
                await runAuthTransitionModal({
                  mode: 'login',
                  durationMs: 3500,
                  userName: state.profile.fullName,
                });
                renderChrome();
                renderMain();
                showToast(
                  res.needsConfirm
                    ? 'Conta criada! Confirme o link enviado no seu e-mail e depois clique em Entrar.'
                    : 'Conta criada e sincronizada!',
                  'success'
                );
              } catch (e) {
                errEl.textContent = e.message;
              }
            };
          }
        );
      };
    }

    const syncBtn = root.querySelector('#prof-sync-now');
    if (syncBtn) syncBtn.onclick = () => syncCloudNow({ silent: false, pullAll: true });

    const profLogoutBtn = root.querySelector('#prof-logout-btn');
    if (profLogoutBtn) profLogoutBtn.onclick = performLogout;

    const outBtn = root.querySelector('#prof-cloud-logout');
    if (outBtn) {
      outBtn.onclick = async () => {
        await runAuthTransitionModal({
          mode: 'logout',
          durationMs: 3500,
          userName: state.profile.fullName,
        });
        state.cloudAuth = null;
        localStorage.removeItem(KEYS.CLOUD_AUTH);
        renderChrome();
        renderMain();
        showToast('Desconectado da conta nuvem (dados locais preservados).', 'info');
      };
    }

    root.querySelector('#prof-gem-btn').onclick = () => openGeminiConfigModal();
    root.querySelector('#prof-theme-btn').onclick = toggleTheme;

    root.querySelector('#prof-backup-export').onclick = () => {
      const payload = {
        app: 'Pregador Pro',
        exportedAt: new Date().toISOString(),
        profile: state.profile,
        sermons: state.allSermons,
      };
      const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = `backup_pregador_pro_${new Date().toISOString().slice(0, 10)}.json`;
      a.click();
      showToast('Backup JSON exportado!', 'success');
    };

    root.querySelector('#prof-backup-import').onchange = async (e) => {
      const file = e.target.files?.[0];
      if (!file) return;
      try {
        const parsed = JSON.parse(await file.text());
        const list = parsed.sermons || [];
        let count = 0;
        for (const item of list) {
          if (item && item.id) {
            saveSermon(item, { markUpdated: false });
            count++;
          }
        }
        renderMain();
        showToast(`${count} sermões restaurados do backup!`, 'success');
      } catch {
        showToast('Arquivo de backup inválido.', 'error');
      }
    };
  }

  function toggleTheme() {
    state.settings.theme = state.settings.theme === 'dark' ? 'light' : 'dark';
    applyThemeAndPalette();
    writeStore(KEYS.SETTINGS, state.settings);
    markProfileUpdated();
    syncCloudNow({ silent: true, pushProfile: true });
    if (state.tab === 'profile' || state.tab === 'settings') renderMain();
  }

  // =========================================================================
  // SISTEMA DE AUDITORIA & GESTÃO ENTERPRISE DE USUÁRIOS
  // =========================================================================
  function logAuditEvent({
    action,
    actionLabel,
    severity = 'info',
    target = 'Sistema',
    details = '',
    actorEmail = null,
    actorName = null,
  } = {}) {
    const entry = {
      id: 'aud-' + uuid().slice(0, 8),
      timestamp: new Date().toISOString(),
      action: action || 'AUDIT_EVENT',
      actionLabel: actionLabel || action || 'Operação do Sistema',
      severity, // 'info' | 'success' | 'warning' | 'danger'
      actorEmail: actorEmail || state.profile.email || 'carlosluizamaral@gmail.com',
      actorName: actorName || state.profile.fullName || 'Pr. Carlos Luiz Amaral',
      target,
      details,
    };
    state.auditLogs = [entry, ...(state.auditLogs || [])].slice(0, 200);
    writeStore(KEYS.AUDIT_LOGS, state.auditLogs);
    return entry;
  }

  function getRoleInfo(roleId) {
    return (
      USER_ROLES.find((r) => r.id === roleId) || {
        id: roleId,
        name: 'Usuário',
        badge: (roleId || 'USER').toUpperCase(),
        icon: '👤',
        color: '#94a3b8',
        desc: 'Acesso padrão',
      }
    );
  }

  function openCreateUserModal() {
    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <div class="modal-header-icon" style="background:rgba(59,130,246,0.15);color:#60a5fa;font-size:20px;padding:8px;border-radius:10px;">👤+</div>
          <div>
            <h3 class="modal-title">Cadastrar Novo Usuário</h3>
            <span class="modal-subtitle">Defina as credenciais, perfil de permissão e dados ministeriais</span>
          </div>
        </div>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>

      <div id="cum-err" class="auth-error-box hidden" style="margin:12px 0;"></div>

      <div class="form-grid-2" style="margin-top:14px;">
        <div>
          <label class="editor-section-label">Nome Completo *</label>
          <input id="cum-name" class="input-field" placeholder="Ex: Pr. João da Silva" autofocus>
        </div>
        <div>
          <label class="editor-section-label">E-mail de Acesso *</label>
          <input id="cum-email" type="email" class="input-field" placeholder="joao@igreja.com">
        </div>
      </div>

      <div class="form-grid-2" style="margin-top:12px;">
        <div>
          <label class="editor-section-label">Perfil de Acesso & Permissões *</label>
          <select id="cum-role" class="select-field">
            ${USER_ROLES.map((r) => `<option value="${r.id}">${r.icon} ${r.name} (${r.badge})</option>`).join('')}
          </select>
        </div>
        <div>
          <label class="editor-section-label">Cargo / Título Ministerial</label>
          <input id="cum-title" class="input-field" placeholder="Ex: Pastor Titular, Diácono, Pregador">
        </div>
      </div>

      <div class="form-grid-2" style="margin-top:12px;">
        <div>
          <label class="editor-section-label">Igreja / Congregação</label>
          <input id="cum-church" class="input-field" placeholder="Ex: Igreja Batista Memorial">
        </div>
        <div>
          <label class="editor-section-label">Senha Inicial de Acesso</label>
          <div style="display:flex;gap:6px;">
            <input id="cum-pass" type="text" class="input-field" value="123" style="font-family:monospace;letter-spacing:1px;">
            <button type="button" class="btn btn-outline" id="cum-gen-pass" title="Gerar Senha Segura">🎲</button>
          </div>
        </div>
      </div>

      <div style="margin-top:14px;padding:12px;background:var(--surface-2);border-radius:10px;border:1px solid var(--border);">
        <label style="display:flex;align-items:center;gap:8px;font-size:13px;cursor:pointer;margin:0;">
          <input id="cum-must-change" type="checkbox" checked style="width:17px;height:17px;accent-color:var(--primary);">
          <span><strong>Exigir troca obrigatória de senha no primeiro login</strong> (Recomendado para segurança)</span>
        </label>
      </div>

      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-primary" id="cum-submit-btn">💾 Salvar e Criar Usuário</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        const errEl = sheet.querySelector('#cum-err');
        const nameInp = sheet.querySelector('#cum-name');
        const emailInp = sheet.querySelector('#cum-email');
        const roleSel = sheet.querySelector('#cum-role');
        const titleInp = sheet.querySelector('#cum-title');
        const churchInp = sheet.querySelector('#cum-church');
        const passInp = sheet.querySelector('#cum-pass');
        const mustChBox = sheet.querySelector('#cum-must-change');

        sheet.querySelector('#cum-gen-pass').onclick = () => {
          const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$';
          let gen = '';
          for (let i = 0; i < 8; i++) gen += chars.charAt(Math.floor(Math.random() * chars.length));
          passInp.value = gen;
        };

        sheet.querySelector('#cum-submit-btn').onclick = () => {
          errEl.classList.add('hidden');
          const fullName = nameInp.value.trim();
          const email = emailInp.value.trim().toLowerCase();
          const role = roleSel.value;
          const ministryTitle = titleInp.value.trim() || getRoleInfo(role).name;
          const churchName = churchInp.value.trim() || 'Igreja Local';
          const password = passInp.value.trim() || '123';
          const mustChangePassword = mustChBox.checked;

          if (!fullName) {
            errEl.textContent = 'Informe o nome completo do usuário.';
            errEl.classList.remove('hidden');
            nameInp.focus();
            return;
          }
          if (!email || !email.includes('@') || !email.includes('.')) {
            errEl.textContent = 'Informe um endereço de e-mail válido.';
            errEl.classList.remove('hidden');
            emailInp.focus();
            return;
          }
          if (state.users.some((u) => u.email.toLowerCase() === email)) {
            errEl.textContent = 'Já existe um usuário cadastrado com este e-mail.';
            errEl.classList.remove('hidden');
            emailInp.focus();
            return;
          }

          const newUser = {
            id: uuid(),
            fullName,
            email,
            role,
            ministryTitle,
            churchName,
            status: 'active',
            password,
            mustChangePassword,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            lastLoginAt: null,
            isMaster: false,
          };

          state.users.unshift(newUser);
          writeStore(KEYS.USERS, state.users);

          logAuditEvent({
            action: 'USER_CREATE',
            actionLabel: 'Criação de Usuário',
            severity: 'success',
            target: email,
            details: `Usuário "${fullName}" cadastrado com perfil ${role.toUpperCase()} e cargo "${ministryTitle}".`,
          });

          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });

          closeModal();
          renderMain();
          showToast(`Usuário "${fullName}" cadastrado com sucesso!`, 'success');
        };
      }
    );
  }

  function openEditUserModal(userId) {
    const user = state.users.find((u) => u.id === userId);
    if (!user) return;

    const isMaster = user.isMaster || user.email === 'carlosluizamaral@gmail.com';

    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <div class="modal-header-icon" style="background:rgba(245,158,11,0.15);color:#fbbf24;font-size:20px;padding:8px;border-radius:10px;">✏️</div>
          <div>
            <h3 class="modal-title">Editar Usuário</h3>
            <span class="modal-subtitle">${esc(user.fullName)} • ${esc(user.email)}</span>
          </div>
        </div>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>

      <div id="eum-err" class="auth-error-box hidden" style="margin:12px 0;"></div>

      <div class="form-grid-2" style="margin-top:14px;">
        <div>
          <label class="editor-section-label">Nome Completo *</label>
          <input id="eum-name" class="input-field" value="${esc(user.fullName)}">
        </div>
        <div>
          <label class="editor-section-label">E-mail de Acesso ${isMaster ? '(Master Fixo)' : '*'}</label>
          <input id="eum-email" type="email" class="input-field" value="${esc(user.email)}" ${isMaster ? 'disabled' : ''}>
        </div>
      </div>

      <div class="form-grid-2" style="margin-top:12px;">
        <div>
          <label class="editor-section-label">Perfil de Acesso *</label>
          <select id="eum-role" class="select-field" ${isMaster ? 'disabled' : ''}>
            ${USER_ROLES.map(
              (r) => `<option value="${r.id}" ${user.role === r.id ? 'selected' : ''}>${r.icon} ${r.name} (${r.badge})</option>`
            ).join('')}
          </select>
        </div>
        <div>
          <label class="editor-section-label">Status da Conta</label>
          <select id="eum-status" class="select-field" ${isMaster ? 'disabled' : ''}>
            <option value="active" ${user.status === 'active' ? 'selected' : ''}>🟢 Ativo / Liberado</option>
            <option value="suspended" ${user.status === 'suspended' ? 'selected' : ''}>🔴 Suspenso / Bloqueado</option>
          </select>
        </div>
      </div>

      <div class="form-grid-2" style="margin-top:12px;">
        <div>
          <label class="editor-section-label">Cargo / Título Ministerial</label>
          <input id="eum-title" class="input-field" value="${esc(user.ministryTitle || '')}">
        </div>
        <div>
          <label class="editor-section-label">Igreja / Congregação</label>
          <input id="eum-church" class="input-field" value="${esc(user.churchName || '')}">
        </div>
      </div>

      <div style="margin-top:14px;padding:12px;background:var(--surface-2);border-radius:10px;border:1px solid var(--border);">
        <label style="display:flex;align-items:center;gap:8px;font-size:13px;cursor:pointer;margin:0;">
          <input id="eum-must-change" type="checkbox" ${user.mustChangePassword ? 'checked' : ''} style="width:17px;height:17px;accent-color:var(--primary);">
          <span>Exigir troca obrigatória de senha no próximo login</span>
        </label>
      </div>

      <div style="display:flex;gap:10px;justify-content:flex-end;margin-top:20px;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-primary" id="eum-submit-btn">💾 Salvar Alterações</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        const errEl = sheet.querySelector('#eum-err');
        const nameInp = sheet.querySelector('#eum-name');
        const emailInp = sheet.querySelector('#eum-email');
        const roleSel = sheet.querySelector('#eum-role');
        const statusSel = sheet.querySelector('#eum-status');
        const titleInp = sheet.querySelector('#eum-title');
        const churchInp = sheet.querySelector('#eum-church');
        const mustChBox = sheet.querySelector('#eum-must-change');

        sheet.querySelector('#eum-submit-btn').onclick = () => {
          errEl.classList.add('hidden');
          const fullName = nameInp.value.trim();
          const email = isMaster ? user.email : emailInp.value.trim().toLowerCase();
          const role = isMaster ? 'admin' : roleSel.value;
          const status = isMaster ? 'active' : statusSel.value;
          const ministryTitle = titleInp.value.trim() || user.ministryTitle;
          const churchName = churchInp.value.trim() || user.churchName;
          const mustChangePassword = mustChBox.checked;

          if (!fullName) {
            errEl.textContent = 'Informe o nome completo.';
            errEl.classList.remove('hidden');
            return;
          }
          if (!email || !email.includes('@')) {
            errEl.textContent = 'Informe um e-mail válido.';
            errEl.classList.remove('hidden');
            return;
          }
          if (!isMaster && state.users.some((u) => u.id !== user.id && u.email.toLowerCase() === email)) {
            errEl.textContent = 'Já existe outro usuário com este e-mail.';
            errEl.classList.remove('hidden');
            return;
          }

          user.fullName = fullName;
          user.email = email;
          user.role = role;
          user.status = status;
          user.ministryTitle = ministryTitle;
          user.churchName = churchName;
          user.mustChangePassword = mustChangePassword;
          user.updatedAt = new Date().toISOString();

          // Se for o master admin, mantém o perfil principal atualizado
          if (isMaster) {
            state.profile.fullName = fullName;
            state.profile.ministryTitle = ministryTitle;
            state.profile.churchName = churchName;
            writeStore(KEYS.PROFILE, state.profile);
          }

          writeStore(KEYS.USERS, state.users);

          logAuditEvent({
            action: 'USER_UPDATE',
            actionLabel: 'Edição de Usuário',
            severity: 'info',
            target: email,
            details: `Dados do usuário "${fullName}" atualizados (Perfil: ${role.toUpperCase()}, Status: ${status}).`,
          });

          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });

          closeModal();
          renderChrome();
          renderMain();
          showToast(`Usuário "${fullName}" atualizado!`, 'success');
        };
      }
    );
  }

  function openResetUserPasswordModal(userId) {
    const user = state.users.find((u) => u.id === userId);
    if (!user) return;

    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <div class="modal-header-icon" style="background:rgba(239,68,68,0.15);color:#f87171;font-size:20px;padding:8px;border-radius:10px;">🔑</div>
          <div>
            <h3 class="modal-title">Redefinir Senha de Acesso</h3>
            <span class="modal-subtitle">${esc(user.fullName)} (${esc(user.email)})</span>
          </div>
        </div>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>

      <div style="margin:14px 0 16px;font-size:13.5px;color:var(--text-muted);line-height:1.45;">
        Defina uma nova senha temporária para este usuário. Por padrão, recomendamos definir como <strong>"123"</strong> e marcar a troca obrigatória no próximo acesso.
      </div>

      <label class="editor-section-label">Nova Senha Temporária</label>
      <div class="auth-input-wrap" style="margin-bottom:14px;">
        <input id="rup-pass" type="text" class="input-field" value="123" style="font-family:monospace;letter-spacing:1px;" autofocus>
      </div>

      <label style="display:flex;align-items:center;gap:8px;font-size:13px;cursor:pointer;margin-bottom:20px;">
        <input id="rup-must-change" type="checkbox" checked style="width:17px;height:17px;accent-color:var(--primary);">
        <span><strong>Exigir que o usuário altere a senha imediatamente ao entrar</strong></span>
      </label>

      <div style="display:flex;gap:10px;justify-content:flex-end;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-gold" id="rup-submit-btn">🔐 Gravar Nova Senha</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#rup-submit-btn').onclick = () => {
          const newPass = sheet.querySelector('#rup-pass').value.trim();
          if (!newPass) {
            showToast('Informe a nova senha.', 'error');
            return;
          }
          const mustChange = sheet.querySelector('#rup-must-change').checked;

          user.password = newPass;
          user.mustChangePassword = mustChange;
          user.updatedAt = new Date().toISOString();

          if (user.isMaster || user.email === 'carlosluizamaral@gmail.com') {
            state.adminAuth.password = newPass;
            state.adminAuth.mustChangePassword = mustChange;
            state.adminAuth.updatedAt = new Date().toISOString();
            writeStore(KEYS.ADMIN_AUTH, state.adminAuth);
          }

          writeStore(KEYS.USERS, state.users);

          logAuditEvent({
            action: 'USER_PASSWORD_RESET',
            actionLabel: 'Redefinição de Senha',
            severity: 'warning',
            target: user.email,
            details: `Senha do usuário "${user.fullName}" redefinida. Troca obrigatória: ${mustChange ? 'Sim' : 'Não'}.`,
          });

          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });

          closeModal();
          renderMain();
          showToast(`Senha de "${user.fullName}" redefinida com sucesso!`, 'success');
        };
      }
    );
  }

  function toggleUserStatus(userId) {
    const user = state.users.find((u) => u.id === userId);
    if (!user) return;
    if (user.isMaster || user.email === 'carlosluizamaral@gmail.com') {
      showToast('O Administrador Master não pode ter sua conta desativada.', 'warning');
      return;
    }

    user.status = user.status === 'active' ? 'suspended' : 'active';
    user.updatedAt = new Date().toISOString();
    writeStore(KEYS.USERS, state.users);

    const isNowActive = user.status === 'active';
    logAuditEvent({
      action: 'USER_STATUS_CHANGE',
      actionLabel: 'Alteração de Status',
      severity: isNowActive ? 'success' : 'danger',
      target: user.email,
      details: `Conta do usuário "${user.fullName}" alterada para: ${isNowActive ? 'Ativo' : 'Suspenso'}.`,
    });

    markProfileUpdated();
    syncCloudNow({ silent: true, pushProfile: true });
    renderMain();
    showToast(`Usuário "${user.fullName}" agora está ${isNowActive ? 'ATIVO' : 'SUSPENSO'}!`, 'info');
  }

  function confirmDeleteUser(userId) {
    const user = state.users.find((u) => u.id === userId);
    if (!user) return;
    if (user.isMaster || user.email === 'carlosluizamaral@gmail.com') {
      showToast('O Administrador Master da plataforma não pode ser excluído.', 'error');
      return;
    }

    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <div class="modal-header-icon" style="background:rgba(239,68,68,0.15);color:#f87171;font-size:20px;padding:8px;border-radius:10px;">🗑️</div>
          <div>
            <h3 class="modal-title">Excluir Usuário</h3>
            <span class="modal-subtitle">Confirmação de exclusão definitiva</span>
          </div>
        </div>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>

      <p style="margin:16px 0;font-size:14px;color:var(--text);line-height:1.5;">
        Tem certeza que deseja excluir o usuário <strong>"${esc(user.fullName)}"</strong> (<code>${esc(user.email)}</code>)?
      </p>
      <div style="padding:12px;background:rgba(239,68,68,0.08);border-left:4px solid #ef4444;border-radius:8px;margin-bottom:18px;font-size:12.5px;color:#fecaca;">
        ⚠️ Esta ação removerá os acessos do usuário permanentemente. A ação será registrada na trilha de auditoria.
      </div>

      <div style="display:flex;gap:10px;justify-content:flex-end;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-danger" id="cdu-confirm-btn">🗑️ Sim, Excluir Definitivamente</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#cdu-confirm-btn').onclick = () => {
          state.users = state.users.filter((u) => u.id !== userId);
          writeStore(KEYS.USERS, state.users);

          logAuditEvent({
            action: 'USER_DELETE',
            actionLabel: 'Exclusão de Usuário',
            severity: 'danger',
            target: user.email,
            details: `Usuário "${user.fullName}" (${user.email}) excluído permanentemente da plataforma.`,
          });

          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });

          closeModal();
          renderMain();
          showToast(`Usuário "${user.fullName}" removido!`, 'info');
        };
      }
    );
  }

  function exportAuditLogs() {
    try {
      const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(state.auditLogs, null, 2));
      const downloadAnchor = document.createElement('a');
      downloadAnchor.setAttribute('href', dataStr);
      downloadAnchor.setAttribute('download', `auditoria_pregador_pro_${new Date().toISOString().slice(0, 10)}.json`);
      document.body.appendChild(downloadAnchor);
      downloadAnchor.click();
      downloadAnchor.remove();
      showToast('Relatório de auditoria exportado em JSON!', 'success');
    } catch {
      showToast('Falha ao exportar auditoria.', 'error');
    }
  }

  function clearAuditLogs() {
    if (!confirm('Deseja realmente limpar o histórico de auditoria local? Um evento inicial de limpeza será registrado.')) {
      return;
    }
    state.auditLogs = [];
    logAuditEvent({
      action: 'AUDIT_CLEARED',
      actionLabel: 'Auditoria Reiniciada',
      severity: 'warning',
      target: 'Logs de Auditoria',
      details: 'Histórico de auditoria limpo pelo Administrador.',
    });
    renderMain();
    showToast('Histórico de auditoria limpo com sucesso!', 'info');
  }

  // ---- TELA 7: CONFIGURAÇÕES, GESTÃO DE USUÁRIOS, AUDITORIA & PALETAS ----
  function renderSettings(root) {
    syncMasterUserWithProfile();
    const curPalette = state.settings.palette || 'royal-gold';
    const isDark = state.settings.theme !== 'light';
    const subTab = state.settingsSubTab || 'palettes';

    // Contadores para estatísticas
    const totalUsers = state.users.length;
    const adminCount = state.users.filter((u) => u.role === 'admin').length;
    const pastorCount = state.users.filter((u) => u.role === 'pastor').length;
    const activeCount = state.users.filter((u) => u.status === 'active').length;

    // Filtros de Usuários
    const uQuery = (state.userFilterQuery || '').toLowerCase();
    const uRole = state.userFilterRole || 'all';
    const filteredUsers = state.users.filter((u) => {
      const matchQuery =
        !uQuery ||
        (u.fullName || '').toLowerCase().includes(uQuery) ||
        (u.email || '').toLowerCase().includes(uQuery) ||
        (u.churchName || '').toLowerCase().includes(uQuery) ||
        (u.ministryTitle || '').toLowerCase().includes(uQuery);
      const matchRole = uRole === 'all' || u.role === uRole;
      return matchQuery && matchRole;
    });

    // Filtros de Auditoria
    const aSev = state.auditFilterSeverity || 'all';
    const filteredAudit = state.auditLogs.filter((a) => {
      return aSev === 'all' || a.severity === aSev;
    });

    root.innerHTML = `
      <div class="section-header" style="margin-top:0;">
        <div>
          <h1 class="section-title" style="font-size:22px;">⚙️ Configurações & Governança</h1>
          <span class="section-subtitle">Gestão de Usuários, Trilha de Auditoria, 16 Paletas de Cores e Preferências do Púlpito</span>
        </div>
      </div>

      <!-- Barra de Sub-Abas de Navegação -->
      <div class="settings-subtab-bar">
        <button class="settings-subtab-btn ${subTab === 'palettes' ? 'active' : ''}" data-subtab="palettes">
          <span>🎨 Paleta de Cores & Visual</span>
          <span class="settings-subtab-badge">${COLOR_PALETTES.length}</span>
        </button>
        <button class="settings-subtab-btn ${subTab === 'users' ? 'active' : ''}" data-subtab="users">
          <span>👥 Gestão de Usuários</span>
          <span class="settings-subtab-badge">${totalUsers}</span>
        </button>
        <button class="settings-subtab-btn ${subTab === 'audit' ? 'active' : ''}" data-subtab="audit">
          <span>📜 Trilha de Auditoria</span>
          <span class="settings-subtab-badge">${state.auditLogs.length}</span>
        </button>
        <button class="settings-subtab-btn ${subTab === 'pulpit' ? 'active' : ''}" data-subtab="pulpit">
          <span>🛡️ Segurança & Púlpito</span>
        </button>
      </div>

      <!-- ================================================================== -->
      <!-- ABA 1: PALETA DE CORES (16 OPÇÕES) & TEMA LUMINOSO                 -->
      <!-- ================================================================== -->
      ${
        subTab === 'palettes'
          ? `
        <div class="card" style="margin-bottom:18px;">
          <div style="display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;margin-bottom:14px;">
            <div>
              <h3 style="margin:0 0 4px;">🎨 Paletas Prontas de Cores da Interface (${COLOR_PALETTES.length} Opções Exclusivas)</h3>
              <div style="font-size:13px;color:var(--text-muted);">
                Escolha uma paleta executiva pronta para aplicar instantaneamente na bancada, púlpito e estúdio bíblico.
              </div>
            </div>
            <span class="tag tag-gold">Sincronizado na Nuvem Supabase ✓</span>
          </div>

          <div class="palette-grid">
            ${COLOR_PALETTES.map((pal) => {
              const active = pal.id === curPalette;
              return `
                <button class="palette-card ${active ? 'active' : ''}" data-pick-palette="${esc(pal.id)}">
                  <div style="display:flex;align-items:center;justify-content:space-between;width:100%;">
                    <div class="palette-swatches">
                      <span class="palette-dot" style="background:${pal.primary};" title="Cor Primária"></span>
                      <span class="palette-dot" style="background:${pal.gold};" title="Destaque Ministerial"></span>
                      <span class="palette-dot" style="background:${pal.surfaceDark};" title="Superfície"></span>
                    </div>
                    ${active ? `<span class="tag tag-gold" style="font-size:11px;">✓ Ativa</span>` : ''}
                  </div>
                  <div class="palette-name">${esc(pal.name)}</div>
                  <div class="palette-desc">${esc(pal.desc)}</div>
                </button>
              `;
            }).join('')}
          </div>
        </div>

        <div class="card" style="margin-bottom:18px;">
          <h3 style="margin:0 0 6px;">🌓 Modo de Luminosidade da Aplicação</h3>
          <p style="font-size:13px;color:var(--text-muted);margin:0 0 12px;">
            Alterne entre o Modo Escuro Executivo e o Modo Claro Limpo (todas as 16 paletas se adaptam dinamicamente).
          </p>
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:10px;">
            <button class="btn ${isDark ? 'btn-primary' : 'btn-outline'}" id="set-mode-dark" style="justify-content:center;">
              🌙 Modo Escuro Executivo ${isDark ? '✓' : ''}
            </button>
            <button class="btn ${!isDark ? 'btn-primary' : 'btn-outline'}" id="set-mode-light" style="justify-content:center;">
              ☀️ Modo Claro Limpo ${!isDark ? '✓' : ''}
            </button>
          </div>
        </div>
        `
          : ''
      }

      <!-- ================================================================== -->
      <!-- ABA 2: GESTÃO COMPLETA DE USUÁRIOS & PERFIS                        -->
      <!-- ================================================================== -->
      ${
        subTab === 'users'
          ? `
        <!-- Mini Stats de Usuários -->
        <div class="stat-card-grid">
          <div class="stat-mini-card">
            <div class="stat-mini-icon">👥</div>
            <div>
              <div class="stat-mini-num">${totalUsers}</div>
              <div class="stat-mini-label">Total de Usuários</div>
            </div>
          </div>
          <div class="stat-mini-card">
            <div class="stat-mini-icon" style="color:#fbbf24;">🛡️</div>
            <div>
              <div class="stat-mini-num">${adminCount}</div>
              <div class="stat-mini-label">Administradores</div>
            </div>
          </div>
          <div class="stat-mini-card">
            <div class="stat-mini-icon" style="color:#60a5fa;">📖</div>
            <div>
              <div class="stat-mini-num">${pastorCount}</div>
              <div class="stat-mini-label">Pastores / Ministros</div>
            </div>
          </div>
          <div class="stat-mini-card">
            <div class="stat-mini-icon" style="color:#34d399;">🟢</div>
            <div>
              <div class="stat-mini-num">${activeCount}</div>
              <div class="stat-mini-label">Usuários Ativos</div>
            </div>
          </div>
        </div>

        <div class="card" style="margin-bottom:18px;">
          <!-- Barra de Ferramentas / Ações -->
          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:16px;">
            <div style="display:flex;align-items:center;gap:10px;flex:1;min-width:280px;flex-wrap:wrap;">
              <input id="usr-search-input" class="input-field" placeholder="🔍 Buscar por nome, e-mail, igreja ou cargo..." value="${esc(state.userFilterQuery || '')}" style="flex:1;min-width:220px;height:42px;">
              <select id="usr-role-filter" class="select-field" style="width:auto;min-width:160px;height:42px;">
                <option value="all" ${uRole === 'all' ? 'selected' : ''}>Todos os Perfis</option>
                <option value="admin" ${uRole === 'admin' ? 'selected' : ''}>🛡️ Administrador (ADMIN)</option>
                <option value="pastor" ${uRole === 'pastor' ? 'selected' : ''}>📖 Pastor (PASTOR)</option>
                <option value="obreiro" ${uRole === 'obreiro' ? 'selected' : ''}>✝️ Obreiro (OBREIRO)</option>
                <option value="leitor" ${uRole === 'leitor' ? 'selected' : ''}>🎓 Leitor (LEITOR)</option>
              </select>
            </div>
            <button class="btn btn-primary" id="usr-create-btn" style="height:42px;font-weight:800;">
              ➕ Cadastrar Novo Usuário
            </button>
          </div>

          <!-- Tabela Responsiva de Usuários -->
          <div class="users-table-container">
            <table class="users-table">
              <thead>
                <tr>
                  <th>Usuário</th>
                  <th>Perfil de Acesso</th>
                  <th>Cargo Ministerial</th>
                  <th>Igreja / Congregação</th>
                  <th>Status</th>
                  <th>Último Acesso</th>
                  <th style="text-align:right;">Ações</th>
                </tr>
              </thead>
              <tbody>
                ${
                  filteredUsers.length === 0
                    ? `
                  <tr>
                    <td colspan="7" style="text-align:center;padding:36px;color:var(--text-muted);">
                      Nenhum usuário encontrado com os filtros atuais.
                    </td>
                  </tr>
                  `
                    : filteredUsers
                        .map((u) => {
                          const rInfo = getRoleInfo(u.role);
                          const initials = (u.fullName || 'U')
                            .split(' ')
                            .map((p) => p[0])
                            .slice(0, 2)
                            .join('')
                            .toUpperCase();
                          const isMaster = u.isMaster || u.email === 'carlosluizamaral@gmail.com';
                          const lastLoginFormatted = u.lastLoginAt
                            ? new Date(u.lastLoginAt).toLocaleDateString('pt-BR', {
                                day: '2-digit',
                                month: '2-digit',
                                hour: '2-digit',
                                minute: '2-digit',
                              })
                            : 'Nunca acessou';

                          return `
                        <tr>
                          <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                              <div class="user-avatar-circle">${esc(initials)}</div>
                              <div>
                                <div style="font-weight:800;color:var(--text);display:flex;align-items:center;gap:6px;">
                                  ${esc(u.fullName)}
                                  ${isMaster ? `<span class="tag tag-gold" style="font-size:10px;padding:2px 6px;">MASTER</span>` : ''}
                                </div>
                                <div style="font-size:12px;color:var(--text-muted);">${esc(u.email)}</div>
                              </div>
                            </div>
                          </td>
                          <td>
                            <span class="role-badge ${esc(u.role)}">
                              <span>${rInfo.icon}</span>
                              <span>${rInfo.badge}</span>
                            </span>
                          </td>
                          <td style="font-size:13px;font-weight:600;">${esc(u.ministryTitle || 'Membro')}</td>
                          <td style="font-size:12.5px;color:var(--text-muted);">${esc(u.churchName || 'Igreja Local')}</td>
                          <td>
                            <div class="status-pill">
                              <span class="status-dot ${u.status === 'active' ? (u.mustChangePassword ? 'pending' : 'active') : 'suspended'}"></span>
                              <span>${u.status === 'active' ? (u.mustChangePassword ? 'Senha Inicial (123)' : 'Ativo') : 'Suspenso'}</span>
                            </div>
                          </td>
                          <td style="font-size:12px;color:var(--text-muted);">${esc(lastLoginFormatted)}</td>
                          <td style="text-align:right;">
                            <div style="display:inline-flex;gap:5px;align-items:center;">
                              <button class="icon-btn-ghost" data-user-edit="${esc(u.id)}" title="Editar dados e perfil">✏️</button>
                              <button class="icon-btn-ghost" data-user-reset="${esc(u.id)}" title="Redefinir senha">🔑</button>
                              ${
                                !isMaster
                                  ? `
                                <button class="icon-btn-ghost" data-user-toggle="${esc(u.id)}" title="${u.status === 'active' ? 'Suspender usuário' : 'Ativar usuário'}">
                                  ${u.status === 'active' ? '🚫' : '✅'}
                                </button>
                                <button class="icon-btn-ghost" data-user-delete="${esc(u.id)}" title="Excluir usuário" style="color:#f87171;">🗑️</button>
                                `
                                  : ''
                              }
                            </div>
                          </td>
                        </tr>
                      `;
                        })
                        .join('')
                }
              </tbody>
            </table>
          </div>
        </div>
        `
          : ''
      }

      <!-- ================================================================== -->
      <!-- ABA 3: TRILHA DE AUDITORIA & REGISTROS DE SEGURANÇA               -->
      <!-- ================================================================== -->
      ${
        subTab === 'audit'
          ? `
        <div class="card" style="margin-bottom:18px;">
          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:16px;">
            <div>
              <h3 style="margin:0 0 4px;">📜 Trilha de Auditoria & Segurança Ministerial</h3>
              <div style="font-size:13px;color:var(--text-muted);">
                Registro inviolável de login, criação, edição e exclusão de contas e alterações críticas no sistema.
              </div>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
              <select id="aud-filter-sev" class="select-field" style="width:auto;height:38px;">
                <option value="all" ${aSev === 'all' ? 'selected' : ''}>Todas as Severidades</option>
                <option value="success" ${aSev === 'success' ? 'selected' : ''}>🟢 Sucesso</option>
                <option value="info" ${aSev === 'info' ? 'selected' : ''}>🔵 Informação</option>
                <option value="warning" ${aSev === 'warning' ? 'selected' : ''}>🟡 Alerta</option>
                <option value="danger" ${aSev === 'danger' ? 'selected' : ''}>🔴 Crítico / Perigo</option>
              </select>
              <button class="btn btn-sm btn-outline" id="aud-export-btn">📥 Exportar Relatório (JSON)</button>
              <button class="btn btn-sm btn-outline" id="aud-clear-btn" style="color:#f87171;border-color:rgba(239,68,68,0.4);">🧹 Limpar Histórico</button>
            </div>
          </div>

          <div class="audit-list">
            ${
              filteredAudit.length === 0
                ? `
              <div style="text-align:center;padding:36px;color:var(--text-muted);">
                Nenhum evento registrado nesta severidade.
              </div>
              `
                : filteredAudit
                    .map((item) => {
                      const iconMap = {
                        success: '✅',
                        info: 'ℹ️',
                        warning: '⚠️',
                        danger: '🚨',
                      };
                      const dateObj = new Date(item.timestamp);
                      const timeStr = dateObj.toLocaleDateString('pt-BR', {
                        day: '2-digit',
                        month: 'short',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                        second: '2-digit',
                      });

                      return `
                    <div class="audit-card">
                      <div class="audit-icon-box">
                        <span>${iconMap[item.severity] || '📌'}</span>
                      </div>
                      <div class="audit-content">
                        <div class="audit-header-row">
                          <div style="display:flex;align-items:center;gap:8px;">
                            <span class="audit-title">${esc(item.actionLabel)}</span>
                            <span class="tag ${item.severity === 'success' ? 'tag-green' : item.severity === 'warning' ? 'tag-gold' : item.severity === 'danger' ? 'tag-danger' : 'tag-muted'}" style="font-size:10.5px;padding:2px 6px;">
                              ${esc((item.action || '').toUpperCase())}
                            </span>
                          </div>
                          <span class="audit-time">🕒 ${esc(timeStr)}</span>
                        </div>
                        <div class="audit-details-text">${esc(item.details || 'Sem detalhes adicionais.')}</div>
                        <div class="audit-meta-row">
                          <span>👤 <strong>Operador:</strong> ${esc(item.actorName)} (${esc(item.actorEmail)})</span>
                          <span>🎯 <strong>Alvo:</strong> ${esc(item.target)}</span>
                        </div>
                      </div>
                    </div>
                  `;
                    })
                    .join('')
            }
          </div>
        </div>
        `
          : ''
      }

      <!-- ================================================================== -->
      <!-- ABA 4: PREFERÊNCIAS DE PÚLPITO, IA & SEGURANÇA ADMIN              -->
      <!-- ================================================================== -->
      ${
        subTab === 'pulpit'
          ? `
        <!-- Segurança & Credenciais Admin -->
        <div class="card" style="margin-bottom:18px;">
          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:10px;">
            <div>
              <h3 style="margin:0 0 4px;">🔐 Credenciais do Administrador Master</h3>
              <div style="font-size:13px;color:var(--text-muted);">
                Conta: <strong>${esc(state.adminAuth.email)}</strong> • Perfil: <span class="gold-pill">ADMIN MASTER</span>
                • Status: <strong>${state.adminAuth.mustChangePassword ? 'Senha Temporária (123)' : 'Senha Pessoal Definida'}</strong>
              </div>
            </div>
          </div>
          <div style="display:flex;flex-wrap:wrap;gap:10px;">
            <button class="btn btn-sm btn-primary" id="set-change-pass-btn">🔑 Alterar Minha Senha Agora</button>
            <button class="btn btn-sm btn-outline" id="set-reset-pass-123-btn">↺ Redefinir para Senha "123" (Exigir Troca)</button>
            <button class="btn btn-sm btn-danger" id="set-logout-btn">🚪 Fazer Logoff Agora</button>
          </div>
        </div>

        <!-- Preferências do Modo Púlpito & IA -->
        <div class="card">
          <h3 style="margin:0 0 12px;">🎤 Preferências Padrão do Púlpito & Inteligência Artificial</h3>
          <div class="form-grid-2" style="margin-bottom:14px;">
            <div>
              <label class="editor-section-label">Tema Padrão do Púlpito</label>
              <select id="set-pulpit-theme" class="select-field">
                <option value="oled" ${state.settings.pulpitTheme === 'oled' ? 'selected' : ''}>🌙 OLED Alto Contraste</option>
                <option value="amber" ${state.settings.pulpitTheme === 'amber' ? 'selected' : ''}>📜 Sépia / Âmbar Leitura</option>
                <option value="light" ${state.settings.pulpitTheme === 'light' ? 'selected' : ''}>☀️ Claro Editorial</option>
              </select>
            </div>
            <div>
              <label class="editor-section-label">Largura Padrão do Púlpito</label>
              <select id="set-pulpit-width" class="select-field">
                <option value="fluid" ${state.settings.pulpitWidth === 'fluid' ? 'selected' : ''}>↔ Fluida Adaptativa</option>
                <option value="focus" ${state.settings.pulpitWidth === 'focus' ? 'selected' : ''}>↔ Foco Centralizado</option>
                <option value="full" ${state.settings.pulpitWidth === 'full' ? 'selected' : ''}>↔ Tela Cheia (100%)</option>
              </select>
            </div>
          </div>
          <div style="display:flex;flex-wrap:wrap;gap:10px;">
            <button class="btn btn-sm btn-purple" id="set-gemini-btn">✨ Configurar Chave Gemini 2.5 Pro</button>
            <button class="btn btn-sm btn-gold" id="set-voice-btn">🎙️ Configurar Vozes Bíblicas (RJ)</button>
          </div>
        </div>
        `
          : ''
      }
    `;

    // Listeners das Sub-Abas
    root.querySelectorAll('[data-subtab]').forEach((btn) => {
      btn.onclick = () => {
        state.settingsSubTab = btn.dataset.subtab;
        renderSettings(root);
      };
    });

    // Listeners da Aba Paletas
    if (subTab === 'palettes') {
      root.querySelectorAll('[data-pick-palette]').forEach((btn) => {
        btn.onclick = () => {
          const palId = btn.dataset.pickPalette;
          state.settings.palette = palId;
          applyThemeAndPalette();
          writeStore(KEYS.SETTINGS, state.settings);
          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });

          const palObj = COLOR_PALETTES.find((p) => p.id === palId);
          logAuditEvent({
            action: 'PALETTE_CHANGE',
            actionLabel: 'Alteração de Paleta de Cores',
            severity: 'info',
            target: palObj?.name || palId,
            details: `Paleta "${palObj?.name || palId}" aplicada na interface e sincronizada com a nuvem.`,
          });

          renderChrome();
          renderMain();
          showToast(`Paleta "${palObj?.name || 'Nova'}" aplicada!`, 'success');
        };
      });

      root.querySelector('#set-mode-dark').onclick = () => {
        if (state.settings.theme !== 'dark') toggleTheme();
      };
      root.querySelector('#set-mode-light').onclick = () => {
        if (state.settings.theme !== 'light') toggleTheme();
      };
    }

    // Listeners da Aba Usuários
    if (subTab === 'users') {
      const searchInp = root.querySelector('#usr-search-input');
      searchInp.oninput = (e) => {
        state.userFilterQuery = e.target.value;
        renderSettings(root);
        const newInp = root.querySelector('#usr-search-input');
        if (newInp) {
          newInp.focus();
          newInp.selectionStart = newInp.selectionEnd = newInp.value.length;
        }
      };

      root.querySelector('#usr-role-filter').onchange = (e) => {
        state.userFilterRole = e.target.value;
        renderSettings(root);
      };

      root.querySelector('#usr-create-btn').onclick = openCreateUserModal;

      root.querySelectorAll('[data-user-edit]').forEach((b) => {
        b.onclick = () => openEditUserModal(b.dataset.userEdit);
      });
      root.querySelectorAll('[data-user-reset]').forEach((b) => {
        b.onclick = () => openResetUserPasswordModal(b.dataset.userReset);
      });
      root.querySelectorAll('[data-user-toggle]').forEach((b) => {
        b.onclick = () => toggleUserStatus(b.dataset.userToggle);
      });
      root.querySelectorAll('[data-user-delete]').forEach((b) => {
        b.onclick = () => confirmDeleteUser(b.dataset.userDelete);
      });
    }

    // Listeners da Aba Auditoria
    if (subTab === 'audit') {
      root.querySelector('#aud-filter-sev').onchange = (e) => {
        state.auditFilterSeverity = e.target.value;
        renderSettings(root);
      };
      root.querySelector('#aud-export-btn').onclick = exportAuditLogs;
      root.querySelector('#aud-clear-btn').onclick = clearAuditLogs;
    }

    // Listeners da Aba Púlpito & Segurança
    if (subTab === 'pulpit') {
      root.querySelector('#set-change-pass-btn').onclick = () =>
        openForcePasswordChangeModal({ mandatory: false });

      root.querySelector('#set-reset-pass-123-btn').onclick = () => {
        state.adminAuth = {
          ...DEFAULT_ADMIN_AUTH,
          password: '123',
          mustChangePassword: true,
          updatedAt: new Date().toISOString(),
        };
        writeStore(KEYS.ADMIN_AUTH, state.adminAuth);
        markProfileUpdated();
        syncCloudNow({ silent: true, pushProfile: true });

        logAuditEvent({
          action: 'MASTER_PASSWORD_RESET',
          actionLabel: 'Redefinição de Senha Master',
          severity: 'warning',
          target: state.adminAuth.email,
          details: 'Senha do Administrador Master redefinida para "123" com troca obrigatória no próximo login.',
        });

        renderMain();
        showToast('Senha redefinida para "123" com troca obrigatória no próximo login!', 'info');
      };

      root.querySelector('#set-logout-btn').onclick = performLogout;

      root.querySelector('#set-pulpit-theme').onchange = (e) => {
        state.settings.pulpitTheme = e.target.value;
        writeStore(KEYS.SETTINGS, state.settings);
        markProfileUpdated();
        syncCloudNow({ silent: true, pushProfile: true });
        showToast('Tema padrão do púlpito salvo!', 'success');
      };

      root.querySelector('#set-pulpit-width').onchange = (e) => {
        state.settings.pulpitWidth = e.target.value;
        writeStore(KEYS.SETTINGS, state.settings);
        markProfileUpdated();
        syncCloudNow({ silent: true, pushProfile: true });
        showToast('Largura padrão do púlpito salva!', 'success');
      };

      root.querySelector('#set-gemini-btn').onclick = () => openGeminiConfigModal(() => renderMain());
      root.querySelector('#set-voice-btn').onclick = openVoiceStudioModal;
    }
  }

  function openForcePasswordChangeModal({ mandatory = true } = {}) {
    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;">
          <span style="font-size:22px;">🔐</span>
          <div>
            <h3 class="modal-title">${mandatory ? 'Troca Obrigatória de Senha no 1º Login' : 'Alterar Senha de Administrador'}</h3>
            <span class="gold-pill">PERFIL ADMIN • ${esc(state.adminAuth.email)}</span>
          </div>
        </div>
        ${mandatory ? '' : `<button class="icon-btn-ghost" data-close-modal>✕</button>`}
      </div>
      <p style="font-size:13.5px;color:var(--text-muted);margin:10px 0 14px;line-height:1.45;">
        ${mandatory
          ? 'Você autenticou com a senha temporária inicial (<strong>123</strong>). Por política de segurança, defina agora a sua nova senha pessoal de Administrador.'
          : 'Defina uma nova senha para o usuário Administrador (carlosluizamaral@gmail.com).'}
      </p>
      <div id="fp-err" class="auth-error-box hidden"></div>
      <label class="editor-section-label">Nova Senha</label>
      <div class="auth-input-wrap" style="margin-bottom:12px;">
        <input id="fp-new-pass" type="password" class="input-field" placeholder="Digite sua nova senha" autofocus>
        <button type="button" id="fp-eye-1" class="auth-eye-btn">👁️</button>
      </div>
      <label class="editor-section-label">Confirmar Nova Senha</label>
      <div class="auth-input-wrap" style="margin-bottom:16px;">
        <input id="fp-confirm-pass" type="password" class="input-field" placeholder="Repita a nova senha">
      </div>
      <div style="display:flex;gap:8px;justify-content:flex-end;">
        ${mandatory ? '' : `<button class="btn btn-outline" data-close-modal>Cancelar</button>`}
        <button class="btn btn-primary" id="fp-save-btn">💾 Salvar Nova Senha</button>
      </div>
      `,
      (sheet) => {
        if (!mandatory) {
          sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        }
        const p1 = sheet.querySelector('#fp-new-pass');
        const p2 = sheet.querySelector('#fp-confirm-pass');
        const eye = sheet.querySelector('#fp-eye-1');
        const errEl = sheet.querySelector('#fp-err');

        eye.onclick = () => {
          const isPass = p1.type === 'password';
          p1.type = isPass ? 'text' : 'password';
          p2.type = isPass ? 'text' : 'password';
          eye.textContent = isPass ? '🙈' : '👁️';
        };

        const doSavePass = () => {
          errEl.classList.add('hidden');
          const v1 = p1.value.trim();
          const v2 = p2.value.trim();
          if (!v1) {
            errEl.textContent = 'Informe a nova senha.';
            errEl.classList.remove('hidden');
            return;
          }
          if (mandatory && v1 === '123') {
            errEl.textContent = 'A nova senha deve ser diferente da senha temporária "123".';
            errEl.classList.remove('hidden');
            return;
          }
          if (v1 !== v2) {
            errEl.textContent = 'A confirmação de senha não confere.';
            errEl.classList.remove('hidden');
            return;
          }

          state.adminAuth = {
            ...state.adminAuth,
            email: 'carlosluizamaral@gmail.com',
            role: 'admin',
            password: v1,
            mustChangePassword: false,
            updatedAt: new Date().toISOString(),
          };
          writeStore(KEYS.ADMIN_AUTH, state.adminAuth);
          markProfileUpdated();
          syncCloudNow({ silent: true, pushProfile: true });
          closeModal();
          renderChrome();
          renderMain();
          showToast('Nova senha do Administrador gravada e sincronizada!', 'success');
        };

        sheet.querySelector('#fp-save-btn').onclick = doSavePass;
        p2.onkeydown = (e) => {
          if (e.key === 'Enter') doSavePass();
        };
      }
    );
  }

  function renderMain() {
    const root = document.getElementById('main-content');
    if (state.tab === 'dashboard') renderDashboard(root);
    else if (state.tab === 'library') renderLibrary(root);
    else if (state.tab === 'editor') renderEditor(root);
    else if (state.tab === 'bible') renderBible(root);
    else if (state.tab === 'templates') renderTemplates(root);
    else if (state.tab === 'profile') renderProfile(root);
    else if (state.tab === 'settings') renderSettings(root);
  }

  // =========================================================================
  // MODAL DE TRANSIÇÃO / AUTENTICAÇÃO (3,5 SEGUNDOS) + LOGIN & LOGOFF
  // =========================================================================
  function runAuthTransitionModal({ mode = 'login', durationMs = 3500, userName = '' } = {}) {
    return new Promise((resolve) => {
      const modal = document.getElementById('auth-transition-modal');
      const iconEl = document.getElementById('auth-transition-icon');
      const badgeEl = document.getElementById('auth-transition-badge');
      const titleEl = document.getElementById('auth-transition-title');
      const stepEl = document.getElementById('auth-transition-step');
      const barEl = document.getElementById('auth-transition-progress-bar');
      const tagEl = document.getElementById('auth-transition-status-tag');
      const pctEl = document.getElementById('auth-transition-pct');

      if (!modal) return resolve();

      const isLogin = mode === 'login';
      const displayUser = userName || state.profile.fullName || 'Pr. Carlos Luiz Amaral';

      const steps = isLogin
        ? [
            { at: 0, text: 'Validando credenciais e permissões ministeriais...', tag: 'Verificando Identidade', icon: '🔐' },
            { at: 0.34, text: 'Sincronizando acervo homilético com nuvem Supabase...', tag: 'Conexão PostgreSQL Segura', icon: '☁️' },
            { at: 0.70, text: `Acesso autorizado • Bem-vindo, ${displayUser}!`, tag: 'Sessão Autenticada ✓', icon: '✅' },
          ]
        : [
            { at: 0, text: 'Salvando alterações e sincronizando com o banco Supabase...', tag: 'Persistência em Nuvem', icon: '💾' },
            { at: 0.36, text: 'Blindando cache offline e encerrando credenciais...', tag: 'Proteção HSF Ativa', icon: '🛡️' },
            { at: 0.72, text: 'Sessão encerrada com segurança • A Paz do Senhor!', tag: 'Logoff Concluído ✓', icon: '🚪' },
          ];

      badgeEl.textContent = isLogin ? 'AUTENTICAÇÃO SEGURA • 3,5s' : 'ENCERRAMENTO SEGURO • 3,5s';
      titleEl.textContent = isLogin ? 'Autenticando Acesso Ministerial' : 'Encerrando Sessão da Plataforma';
      iconEl.textContent = steps[0].icon;
      stepEl.textContent = steps[0].text;
      tagEl.textContent = steps[0].tag;
      barEl.style.width = '0%';
      pctEl.textContent = '0%';
      modal.classList.remove('hidden');

      const start = performance.now();
      const tick = (now) => {
        const elapsed = now - start;
        const ratio = Math.min(1, elapsed / durationMs);
        const pct = Math.round(ratio * 100);

        barEl.style.width = `${pct}%`;
        pctEl.textContent = `${pct}%`;

        for (let i = steps.length - 1; i >= 0; i--) {
          if (ratio >= steps[i].at) {
            if (stepEl.textContent !== steps[i].text) stepEl.textContent = steps[i].text;
            if (tagEl.textContent !== steps[i].tag) tagEl.textContent = steps[i].tag;
            if (iconEl.textContent !== steps[i].icon) iconEl.textContent = steps[i].icon;
            break;
          }
        }

        if (ratio < 1) {
          requestAnimationFrame(tick);
        } else {
          setTimeout(() => {
            modal.classList.add('hidden');
            resolve();
          }, 80);
        }
      };

      requestAnimationFrame(tick);
    });
  }

  function openRequestAccessModal() {
    const roles = [
      'Pastor Titular',
      'Pastor Auxiliar',
      'Evangelista',
      'Presbítero',
      'Missionário(a)',
      'Diácono / Obreiro',
      'Professor(a) de EBD / Teologia',
      'Seminarista',
      'Líder de Ministério',
    ];
    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title">📩 Solicitar Criação de Usuário</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <p style="font-size:13px;color:var(--text-muted);margin:0 0 12px;">
        Preencha seus dados ministeriais para enviar a solicitação de credenciais ao Administrador (<strong>carlosluizamaral@gmail.com</strong>).
      </p>
      <label class="editor-section-label">Nome Completo</label>
      <input id="req-name" class="input-field" placeholder="Ex: Pr. João da Silva" style="margin-bottom:10px;">
      <label class="editor-section-label">Seu E-mail</label>
      <input id="req-email" type="email" class="input-field" placeholder="seuemail@exemplo.com" style="margin-bottom:10px;">
      <div class="form-grid-2" style="margin-bottom:10px;">
        <div>
          <label class="editor-section-label">Cargo / Função</label>
          <select id="req-role" class="select-field">
            ${roles.map((r) => `<option>${esc(r)}</option>`).join('')}
          </select>
        </div>
        <div>
          <label class="editor-section-label">Igreja / Denominação</label>
          <input id="req-church" class="input-field" placeholder="Ex: Igreja Batista">
        </div>
      </div>
      <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:14px;">
        <button class="btn btn-outline" data-close-modal>Cancelar</button>
        <button class="btn btn-gold" id="req-send-btn">Enviar Solicitação por E-mail</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#req-send-btn').onclick = () => {
          const name = sheet.querySelector('#req-name').value.trim();
          const email = sheet.querySelector('#req-email').value.trim();
          const role = sheet.querySelector('#req-role').value;
          const church = sheet.querySelector('#req-church').value.trim();
          if (!name || !email) {
            showToast('Preencha seu nome e e-mail.', 'error');
            return;
          }
          const subject = encodeURIComponent(`[Pregador Pro] Solicitação de Acesso - ${name}`);
          const body = encodeURIComponent(
            `Paz do Senhor, Pr. Carlos Luiz Amaral!\n\nSolicito a criação de usuário na plataforma Pregador Pro:\n\n• Nome: ${name}\n• E-mail: ${email}\n• Cargo Ministerial: ${role}\n• Igreja: ${church || 'Não informada'}\n`
          );
          window.open(`mailto:carlosluizamaral@gmail.com?subject=${subject}&body=${body}`, '_blank');
          closeModal();
          showToast('Cliente de e-mail aberto com sua solicitação!', 'success');
        };
      }
    );
  }

  function renderAuthScreen() {
    const authEl = document.getElementById('auth-screen');
    if (!authEl) return;
    authEl.classList.remove('hidden');

    authEl.innerHTML = `
      <div class="auth-container">
        <!-- Coluna Esquerda (Showcase Desktop) -->
        <div class="auth-showcase">
          <div class="auth-badge-pill">🛡️ AMBIENTE EXCLUSIVO PARA MINISTROS & OBREIROS</div>
          <div class="auth-brand-row">
            <div class="auth-logo-box">📖</div>
            <div>
              <div style="display:flex;align-items:center;gap:8px;">
                <span style="font-size:32px;font-weight:900;letter-spacing:-0.8px;">Pregador</span>
                <span class="gold-pill" style="font-size:13px;padding:3px 9px;">PRO</span>
              </div>
              <div style="font-size:14px;color:#94a3b8;">Bancada Homilética & Bíblica Offline-First</div>
            </div>
          </div>
          <h2 style="margin:4px 0;font-size:24px;font-weight:800;line-height:1.3;">
            Prepare, estruture e ministre sermões com excelência teológica.
          </h2>
          <div class="auth-feature-item">
            <div class="auth-feature-ico">📚</div>
            <div>
              <strong style="font-size:14.5px;">6 Traduções Bíblicas 100% Offline</strong>
              <div style="font-size:13px;color:#94a3b8;">ARC, ARA, NAA, NVI, ACF e King James 1611 com comparador simultâneo e vozes RJ.</div>
            </div>
          </div>
          <div class="auth-feature-item">
            <div class="auth-feature-ico">✨</div>
            <div>
              <strong style="font-size:14.5px;">Assistente Homilético Gemini Pro & 150 Modelos</strong>
              <div style="font-size:13px;color:#94a3b8;">Esboços completos de 5 tópicos com exegese, léxico grego/hebraico e aplicação.</div>
            </div>
          </div>
          <div class="auth-feature-item">
            <div class="auth-feature-ico">🎤</div>
            <div>
              <strong style="font-size:14.5px;">Modo Púlpito com Sincronização em Nuvem Supabase</strong>
              <div style="font-size:13px;color:#94a3b8;">Teleprompter inteligente, alto contraste e sincronização Trabalho ↔ Casa ↔ iPhone.</div>
            </div>
          </div>
          <div class="auth-quote-box">
            <em>"Procura apresentar-te a Deus aprovado, como obreiro que não tem de que se envergonhar, que maneja bem a palavra da verdade."</em>
            <div style="margin-top:6px;font-weight:800;color:#fbbf24;font-size:12.5px;">— 2 Timóteo 2:15</div>
          </div>
        </div>

        <!-- Card de Login -->
        <div>
          <div class="auth-mobile-header">
            <div class="auth-logo-box" style="margin-bottom:12px;">📖</div>
            <div style="display:flex;align-items:center;gap:8px;justify-content:center;">
              <span style="font-size:26px;font-weight:900;">Pregador</span>
              <span class="gold-pill">PRO</span>
            </div>
            <div style="font-size:13px;color:#94a3b8;margin-top:4px;">Plataforma Homilética & Exegética de Alta Performance</div>
          </div>

          <form id="auth-login-form" class="auth-card" autocomplete="on">
            <h1 style="margin:0 0 6px;font-size:22px;font-weight:800;">Acesso à Plataforma</h1>
            <p style="margin:0 0 20px;font-size:13.5px;color:#94a3b8;">Entre com suas credenciais para acessar seu acervo homilético</p>

            <div id="auth-error-msg" class="auth-error-box hidden"></div>

            <label class="editor-section-label" style="color:#cbd5e1;">E-mail de Acesso</label>
            <div class="auth-input-wrap" style="margin-bottom:16px;">
              <input id="auth-email" type="email" class="input-field" placeholder="seuemail@exemplo.com" value="${esc(state.profile.email || 'carlosluizamaral@gmail.com')}" required>
            </div>

            <label class="editor-section-label" style="color:#cbd5e1;">Senha</label>
            <div class="auth-input-wrap" style="margin-bottom:14px;">
              <input id="auth-password" type="password" class="input-field" placeholder="Digite sua senha" required>
              <button type="button" id="auth-toggle-pass" class="auth-eye-btn" title="Mostrar/Ocultar senha">👁️</button>
            </div>

            <label style="display:flex;align-items:center;gap:8px;font-size:13px;color:#cbd5e1;cursor:pointer;margin-bottom:20px;">
              <input id="auth-remember" type="checkbox" checked style="width:18px;height:18px;accent-color:#3b82f6;">
              <span>Manter conectado neste dispositivo</span>
            </label>

            <button type="submit" id="auth-submit-btn" class="btn btn-primary btn-block" style="min-height:50px;font-size:15.5px;font-weight:800;">
              🔐 Entrar na Plataforma
            </button>
          </form>
        </div>
      </div>
    `;

    const passInp = authEl.querySelector('#auth-password');
    const toggleBtn = authEl.querySelector('#auth-toggle-pass');
    toggleBtn.onclick = () => {
      const isPass = passInp.type === 'password';
      passInp.type = isPass ? 'text' : 'password';
      toggleBtn.textContent = isPass ? '🙈' : '👁️';
    };

    const form = authEl.querySelector('#auth-login-form');
    const errBox = authEl.querySelector('#auth-error-msg');
    const submitBtn = authEl.querySelector('#auth-submit-btn');

    form.onsubmit = async (e) => {
      e.preventDefault();
      errBox.classList.add('hidden');
      const email = authEl.querySelector('#auth-email').value.trim().toLowerCase();
      const pass = passInp.value.trim();
      const remember = authEl.querySelector('#auth-remember').checked;

      if (!email || !pass) {
        errBox.textContent = 'Informe seu e-mail e senha de acesso.';
        errBox.classList.remove('hidden');
        return;
      }

      // 1. Procura se é o Administrador Master ou um usuário gerenciado cadastrado
      const matchedUser = state.users.find((u) => (u.email || '').trim().toLowerCase() === email);
      const currentAdminPass = state.adminAuth?.password || '123';
      const isMasterAdmin =
        email === 'carlosluizamaral@gmail.com' &&
        (pass === currentAdminPass || (!state.adminAuth?.updatedAt && pass === '123'));

      let isAuthenticated = false;
      let authenticatedUser = null;

      if (isMasterAdmin) {
        isAuthenticated = true;
        authenticatedUser = {
          fullName: state.profile.fullName || 'Pr. Carlos Luiz Amaral',
          email: 'carlosluizamaral@gmail.com',
          role: 'admin',
          mustChangePassword: state.adminAuth.mustChangePassword || pass === '123',
        };
      } else if (matchedUser) {
        if (matchedUser.status === 'suspended') {
          submitBtn.disabled = false;
          errBox.textContent = 'Esta conta de usuário está temporariamente suspensa/bloqueada. Contate o Administrador.';
          errBox.classList.remove('hidden');
          logAuditEvent({
            action: 'LOGIN_BLOCKED',
            actionLabel: 'Acesso Bloqueado',
            severity: 'danger',
            target: email,
            details: `Tentativa de login em conta suspensa/inativa: ${matchedUser.fullName}.`,
            actorEmail: email,
            actorName: matchedUser.fullName,
          });
          return;
        }

        if (pass === matchedUser.password || (matchedUser.mustChangePassword && pass === '123')) {
          isAuthenticated = true;
          authenticatedUser = matchedUser;
          matchedUser.lastLoginAt = new Date().toISOString();
          writeStore(KEYS.USERS, state.users);
        }
      }

      if (!isAuthenticated) {
        try {
          await signInCloud(email, pass);
          isAuthenticated = true;
          authenticatedUser = {
            fullName: email.split('@')[0],
            email,
            role: 'pastor',
            mustChangePassword: false,
          };
        } catch (err) {
          submitBtn.disabled = false;
          errBox.textContent = 'Credenciais inválidas. Verifique seu e-mail e senha de acesso.';
          errBox.classList.remove('hidden');
          logAuditEvent({
            action: 'LOGIN_FAILED',
            actionLabel: 'Falha de Autenticação',
            severity: 'warning',
            target: email,
            details: `Tentativa de autenticação com senha incorreta para: ${email}.`,
            actorEmail: email,
            actorName: 'Usuário Não Autenticado',
          });
          return;
        }
      }

      submitBtn.disabled = true;

      // Dispara sincronização com Supabase em paralelo ao modal de transição de 3,5 segundos
      if (navigator.onLine) {
        syncCloudNow({ silent: true, pullAll: true });
      }

      const displayUserName = authenticatedUser?.fullName || state.profile.fullName || 'Pr. Carlos Luiz Amaral';

      await runAuthTransitionModal({
        mode: 'login',
        durationMs: 3500,
        userName: displayUserName,
      });

      const sessionObj = {
        authenticated: true,
        email,
        role: authenticatedUser?.role || 'admin',
        userName: displayUserName,
        remember,
        loggedAt: new Date().toISOString(),
      };
      if (remember) {
        writeStore(KEYS.SESSION_AUTH, sessionObj);
      } else {
        sessionStorage.setItem(KEYS.SESSION_AUTH, JSON.stringify(sessionObj));
      }

      logAuditEvent({
        action: 'LOGIN_SUCCESS',
        actionLabel: 'Autenticação Bem-Sucedida',
        severity: 'success',
        target: 'Painel da Plataforma',
        details: `Sessão iniciada por ${displayUserName} (${sessionObj.role.toUpperCase()}).`,
        actorEmail: email,
        actorName: displayUserName,
      });

      authEl.classList.add('hidden');
      authEl.innerHTML = '';
      renderChrome();
      renderMain();

      // Se o usuário logou com a senha temporária (mustChangePassword === true), exige a troca imediata
      if (isMasterAdmin && (state.adminAuth.mustChangePassword || pass === '123')) {
        openForcePasswordChangeModal({ mandatory: true });
      } else if (authenticatedUser && authenticatedUser.mustChangePassword) {
        openResetUserPasswordModal(authenticatedUser.id);
      } else {
        showToast(`Bem-vindo, ${displayUserName}!`, 'success');
      }
    };
  }

  async function performLogout() {
    flushActiveEditorIfNeeded();
    if (state.tab === 'bible') stopBibleSpeech();
    if (!document.getElementById('pulpit-overlay').classList.contains('hidden')) {
      closePulpitMode();
    }

    logAuditEvent({
      action: 'LOGOUT',
      actionLabel: 'Encerramento de Sessão',
      severity: 'info',
      target: 'Sessão da Plataforma',
      details: `Logoff efetuado por ${state.profile.fullName} (${state.profile.email}).`,
    });

    // Sincroniza alterações pendentes com o banco Supabase durante os 3,5s do modal de logoff
    if (navigator.onLine) {
      syncCloudNow({ silent: true, pushProfile: true });
    }

    await runAuthTransitionModal({
      mode: 'logout',
      durationMs: 3500,
      userName: state.profile.fullName,
    });

    localStorage.removeItem(KEYS.SESSION_AUTH);
    sessionStorage.removeItem(KEYS.SESSION_AUTH);
    openIdb().then((db) => {
      if (!db) return;
      try {
        db.transaction(DB_STORE, 'readwrite').objectStore(DB_STORE).delete(KEYS.SESSION_AUTH);
      } catch (_) {}
    });

    state.tab = 'dashboard';
    renderAuthScreen();
  }

  // =========================================================================
  // BOOT ULTRARRÁPIDO (< 50ms)
  // =========================================================================
  async function boot() {
    migrateLegacyFlutterStorage();

    state.profile = { ...DEFAULT_PROFILE, ...(readStoreSync(KEYS.PROFILE) || {}) };
    state.adminAuth = { ...DEFAULT_ADMIN_AUTH, ...(readStoreSync(KEYS.ADMIN_AUTH) || {}) };
    state.settings = { ...DEFAULT_SETTINGS, ...(readStoreSync(KEYS.SETTINGS) || {}) };
    state.cloudAuth = readStoreSync(KEYS.CLOUD_AUTH);
    state.sermonsDelta = readStoreSync(KEYS.SERMONS_DELTA) || {};
    state.deletedIds = new Set(readStoreSync(KEYS.DELETED_IDS) || []);
    state.pendingSync = readStoreSync(KEYS.PENDING_SYNC) || { upsertIds: [], deleteIds: [] };

    // Carrega Usuários e Trilha de Auditoria
    const storedUsers = readStoreSync(KEYS.USERS);
    if (Array.isArray(storedUsers) && storedUsers.length > 0) {
      state.users = storedUsers;
    } else {
      state.users = JSON.parse(JSON.stringify(DEFAULT_USERS_SEED));
      writeStore(KEYS.USERS, state.users);
    }

    const storedAudit = readStoreSync(KEYS.AUDIT_LOGS);
    if (Array.isArray(storedAudit) && storedAudit.length > 0) {
      state.auditLogs = storedAudit;
    } else {
      state.auditLogs = JSON.parse(JSON.stringify(DEFAULT_AUDIT_SEED));
      writeStore(KEYS.AUDIT_LOGS, state.auditLogs);
    }

    // Sincroniza Administrador Master em state.users com o perfil ativo e adminAuth
    syncMasterUserWithProfile();
    const masterInUsers = state.users.find(
      (u) => u.email === 'carlosluizamaral@gmail.com' || u.isMaster
    );
    if (masterInUsers && state.adminAuth.password) {
      masterInUsers.password = state.adminAuth.password;
      masterInUsers.mustChangePassword = state.adminAuth.mustChangePassword;
      writeStore(KEYS.USERS, state.users);
    }

    if (!localStorage.getItem(KEYS.ADMIN_AUTH)) {
      const idbAdmin = await readIdbFallback(KEYS.ADMIN_AUTH);
      if (idbAdmin) {
        state.adminAuth = { ...DEFAULT_ADMIN_AUTH, ...idbAdmin };
        writeStore(KEYS.ADMIN_AUTH, state.adminAuth);
      } else {
        writeStore(KEYS.ADMIN_AUTH, state.adminAuth);
      }
    }

    // Fallback IndexedDB caso o iOS tenha limpado localStorage
    if (!localStorage.getItem(KEYS.PROFILE)) {
      const idbProfile = await readIdbFallback(KEYS.PROFILE);
      if (idbProfile) {
        state.profile = { ...DEFAULT_PROFILE, ...idbProfile };
        writeStore(KEYS.PROFILE, state.profile);
      }
    }
    if (!localStorage.getItem(KEYS.SETTINGS)) {
      const idbSettings = await readIdbFallback(KEYS.SETTINGS);
      if (idbSettings) {
        state.settings = { ...DEFAULT_SETTINGS, ...idbSettings };
        writeStore(KEYS.SETTINGS, state.settings);
      }
    }

    // Sanitização e migração de modelos Gemini legados para a nova geração
    sanitizeActiveGeminiModel();

    // Auto-sincronização periódica em background de novos modelos lançados pelo Google
    if (state.settings.geminiKey && navigator.onLine) {
      setTimeout(() => {
        const lastSync = state.settings.geminiLastModelSync
          ? new Date(state.settings.geminiLastModelSync).getTime()
          : 0;
        const twelveHoursMs = 12 * 60 * 60 * 1000;
        if (Date.now() - lastSync > twelveHoursMs) {
          syncGeminiModelsFromGoogle(state.settings.geminiKey, { silent: true });
        }
      }, 2500);
    }
    if (!localStorage.getItem(KEYS.DELETED_IDS)) {
      const idbDeleted = await readIdbFallback(KEYS.DELETED_IDS);
      if (Array.isArray(idbDeleted) && idbDeleted.length) {
        state.deletedIds = new Set(idbDeleted);
        writeStore(KEYS.DELETED_IDS, idbDeleted);
      }
    }
    if (!Object.keys(state.sermonsDelta).length) {
      const idbDelta = await readIdbFallback(KEYS.SERMONS_DELTA);
      if (idbDelta && Object.keys(idbDelta).length) {
        state.sermonsDelta = idbDelta;
        writeStore(KEYS.SERMONS_DELTA, idbDelta);
      }
    }

    // Garante gravação imediata ao fechar a aba ou minimizar o app no iPhone
    window.addEventListener('pagehide', flushActiveEditorIfNeeded);
    window.addEventListener('beforeunload', flushActiveEditorIfNeeded);
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'hidden') flushActiveEditorIfNeeded();
    });

    applyThemeAndPalette();

    // Fecha o menu do nome do usuário na sidebar ao clicar fora
    document.addEventListener('click', (e) => {
      if (!e.target.closest('.sidebar-user-wrap')) {
        closeSidebarUserMenu();
      }
    });

    // Impede fechar o modal clicando fora caso seja troca obrigatória de senha
    document.getElementById('modal-backdrop').onclick = (e) => {
      if (e.target.id === 'modal-backdrop') {
        const hasCloseBtn = document.querySelector('#modal-sheet [data-close-modal]');
        if (hasCloseBtn) closeModal();
      }
    };

    // Carrega os 150 modelos do IndexedDB (preservando cota de localStorage) ou fetch rápido
    const cachedTpls = await readIdbFallback(KEYS.TEMPLATES_CACHE);
    if (Array.isArray(cachedTpls) && cachedTpls.length) {
      state.templates = cachedTpls;
    } else {
      try {
        const res = await fetch('data/templates_150.json');
        state.templates = await res.json();
        openIdb().then((db) => {
          if (!db) return;
          try {
            const tx = db.transaction(DB_STORE, 'readwrite');
            tx.objectStore(DB_STORE).put(JSON.stringify(state.templates), KEYS.TEMPLATES_CACHE);
          } catch (_) {}
        });
      } catch {
        state.templates = [];
      }
    }

    rebuildSermonsList();
    renderChrome();
    renderMain();

    function toggleSidebar(forceState = null) {
      const sidebar = document.getElementById('sidebar');
      const expandBtn = document.getElementById('desktop-sidebar-expand-btn');
      if (!sidebar) return;

      const shouldCollapse = forceState !== null ? forceState : !sidebar.classList.contains('collapsed');
      if (shouldCollapse) {
        sidebar.classList.add('collapsed');
        if (expandBtn) expandBtn.classList.remove('hidden');
      } else {
        sidebar.classList.remove('collapsed');
        if (expandBtn) expandBtn.classList.add('hidden');
      }

      state.settings.sidebarCollapsed = shouldCollapse;
      writeStore(KEYS.SETTINGS, state.settings);
    }

    const sidebarToggleBtn = document.getElementById('sidebar-toggle-btn');
    if (sidebarToggleBtn) sidebarToggleBtn.onclick = () => toggleSidebar(true);

    const desktopExpandBtn = document.getElementById('desktop-sidebar-expand-btn');
    if (desktopExpandBtn) desktopExpandBtn.onclick = () => toggleSidebar(false);

    window.addEventListener('keydown', (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'b' && !e.altKey) {
        e.preventDefault();
        toggleSidebar();
      }
    });

    if (state.settings.sidebarCollapsed && window.innerWidth >= 860) {
      toggleSidebar(true);
    }

    document.getElementById('sidebar-new-sermon-btn').onclick = createNewSermonAndOpen;
    document.getElementById('topbar-theme-btn').onclick = toggleTheme;
    const topbarLogout = document.getElementById('topbar-logout-btn');
    if (topbarLogout) topbarLogout.onclick = performLogout;

    // Verifica sessão autenticada (exibe Tela de Login se não houver sessão ativa)
    let activeSession = readStoreSync(KEYS.SESSION_AUTH);
    if (!activeSession) {
      try {
        const rawSess = sessionStorage.getItem(KEYS.SESSION_AUTH);
        if (rawSess) activeSession = JSON.parse(rawSess);
      } catch (_) {}
    }
    if (!activeSession) {
      activeSession = await readIdbFallback(KEYS.SESSION_AUTH);
    }
    if (!activeSession || !activeSession.authenticated) {
      renderAuthScreen();
    }

    window.addEventListener('online', () => syncCloudNow({ silent: true }));
    window.addEventListener('offline', updateSyncIndicators);

    if ('speechSynthesis' in window) {
      refreshBrowserVoices();
      window.speechSynthesis.addEventListener('voiceschanged', refreshBrowserVoices);
    }

    if (navigator.onLine) {
      syncCloudNow({ silent: true, pullAll: true });
    }
  }

  document.addEventListener('DOMContentLoaded', boot);
})();
