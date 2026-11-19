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

  const DEFAULT_SETTINGS = {
    theme: 'dark', // 'dark' | 'light'
    pulpitTheme: 'oled', // 'oled' | 'amber' | 'light'
    pulpitWidth: 'fluid', // 'fluid' | 'focus' | 'full'
    pulpitFont: 22,
    bibleFont: 18,
    bibleVersion: 'ARC',
    bibleBook: 'sl',
    bibleChapter: 23,
    bibleCompareVersions: ['ARC', 'NVI'],
    voiceGender: 'male', // 'male' | 'female'
    voiceRate: 0.96,
    voiceId: '',
    geminiKey: '',
    geminiModel: 'gemini-2.5-pro',
  };

  const state = {
    tab: 'dashboard', // dashboard | library | editor | bible | templates | profile
    profile: { ...DEFAULT_PROFILE },
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

  async function cloudFetch(path, options = {}) {
    const token = await ensureFreshToken();
    if (!token) throw new Error('Conta nuvem não conectada.');
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

  async function syncCloudNow({ silent = true, pullAll = false } = {}) {
    updateSyncIndicators();
    if (!navigator.onLine || !state.cloudAuth?.accessToken) return;

    try {
      const uid = state.cloudAuth.userId;

      // 1. Perfil remoto <-> local
      await cloudFetch('profiles', {
        method: 'POST',
        headers: { Prefer: 'resolution=merge-duplicates' },
        body: JSON.stringify({
          id: uid,
          full_name: state.profile.fullName,
          ministry_title: state.profile.ministryTitle,
          church_name: state.profile.churchName,
          updated_at: new Date().toISOString(),
        }),
      }).catch(() => {});

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
          state.pendingSync.upsertIds = state.pendingSync.upsertIds.filter((x) => x !== id);
        }
      }
      writeStore(KEYS.PENDING_SYNC, state.pendingSync);

      // 4. Buscar sermões da nuvem e mesclar por updatedAt
      const pullRes = await cloudFetch('sermons?select=*&order=updated_at.desc');
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
          if (state.tab === 'dashboard' || state.tab === 'library') renderMain();
        }
      }

      if (!silent) showToast('Sincronização com a nuvem concluída!', 'success');
    } catch (e) {
      if (!silent) showToast(`Sincronização offline mantida (${e.message})`, 'info');
    } finally {
      updateSyncIndicators();
    }
  }

  // =========================================================================
  // MOTOR DE VOZES DA BÍBLIA (GEMINI NEURAL RJ + WEB SPEECH pt-BR)
  // =========================================================================
  const TTS_MALE_KW = [
    'felipe', 'eddy', 'reed', 'rocko', 'grandpa', 'antonio', 'antônio', 'donato',
    'fabio', 'fábio', 'humberto', 'julio', 'júlio', 'nicolau', 'valerio', 'valério',
    'daniel', 'ricardo', 'tiago', 'marcos', 'paulo', 'carlos', 'luca', 'jorge', 'male', 'homem'
  ];
  const TTS_FEMALE_KW = [
    'luciana', 'flo', 'sandy', 'shelley', 'grandma', 'francisca', 'thalita', 'maria',
    'brenda', 'giovanna', 'leila', 'manuela', 'yara', 'heloisa', 'heloísa', 'vitoria',
    'vitória', 'camila', 'fernanda', 'leticia', 'raquel', 'ana', 'julia', 'google português',
    'google portugues', 'female', 'mulher'
  ];
  const TTS_PT_EXCLUDE = ['pt-pt', 'pt_pt', 'portugal', 'cristiano', 'inês', 'ines', 'duarte', 'joana'];

  let _ttsToken = 0;
  let _ttsAudioEl = null;
  let _ttsUnlocked = false;
  const _ttsBlobCache = new Map();
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
      if (/premium|enhanced|aprimorad|natural|neural|online/.test(n)) s += 4;
      if (/francisca|antonio|thalita|felipe|luciana/.test(n)) s += 3;
      if (n.includes('google')) s += 2;
      return s;
    };
    const ptBr = all
      .filter((v) => {
        const l = (v.lang || '').toLowerCase().replace('_', '-');
        return l.startsWith('pt') && !isPtExclude(v);
      })
      .sort((a, b) => score(b) - score(a));

    state.tts.voices = ptBr.map((v) => {
      const lower = (v.name || '').toLowerCase();
      return {
        raw: v,
        id: v.voiceURI || v.name,
        name: v.name || 'Voz Brasil',
        lang: v.lang || 'pt-BR',
        isMale: TTS_MALE_KW.some((k) => lower.includes(k)),
        isFemale: TTS_FEMALE_KW.some((k) => lower.includes(k)),
      };
    });
    updateActiveVoiceLabel();
  }

  function pickBestBrowserVoice(preferMale, specificId) {
    const list = state.tts.voices;
    if (!list.length) return null;
    if (specificId) {
      const exact = list.find((v) => v.id === specificId || v.name === specificId);
      if (exact) return exact;
    }
    const matches = list.filter((v) => (preferMale ? v.isMale : v.isFemale));
    if (matches.length) return matches[0];
    if (preferMale) {
      const nonFemale = list.filter((v) => !v.isFemale);
      if (nonFemale.length) return nonFemale[0];
    } else {
      const nonMale = list.filter((v) => !v.isMale);
      if (nonMale.length) return nonMale[0];
    }
    return list[0];
  }

  function updateActiveVoiceLabel() {
    const preferMale = state.settings.voiceGender === 'male';
    const hasKey = Boolean(state.settings.geminiKey?.trim());
    state.tts.isCloudNeural = hasKey && !state.settings.voiceId && navigator.onLine;
    if (state.tts.isCloudNeural) {
      state.tts.activeLabel = preferMale
        ? 'Neural Carioca RJ • Charon (Masculina)'
        : 'Neural Carioca RJ • Aoede (Feminina)';
      return;
    }
    const picked = pickBestBrowserVoice(preferMale, state.settings.voiceId);
    if (!picked) {
      state.tts.activeLabel = preferMale ? 'Masculina (Brasil • RJ)' : 'Feminina (Brasil • RJ)';
      return;
    }
    if (preferMale && !picked.isMale) {
      state.tts.activeLabel = `${picked.name} (Timbre Masculino Grave • pt-BR)`;
    } else if (!preferMale && !picked.isFemale) {
      state.tts.activeLabel = `${picked.name} (Timbre Feminino • pt-BR)`;
    } else {
      state.tts.activeLabel = `${picked.name} (pt-BR)`;
    }
  }

  function pcmToWavBytes(base64Pcm, sampleRate = 24000) {
    const bin = atob(base64Pcm);
    const pcmLen = bin.length;
    const buf = new ArrayBuffer(44 + pcmLen);
    const view = new DataView(buf);
    const writeStr = (off, s) => {
      for (let i = 0; i < s.length; i++) view.setUint8(off + i, s.charCodeAt(i));
    };
    writeStr(0, 'RIFF');
    view.setUint32(4, 36 + pcmLen, true);
    writeStr(8, 'WAVE');
    writeStr(12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true);
    view.setUint16(22, 1, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, sampleRate * 2, true);
    view.setUint16(32, 2, true);
    view.setUint16(34, 16, true);
    writeStr(36, 'data');
    view.setUint32(40, pcmLen, true);
    const u8 = new Uint8Array(buf, 44);
    for (let i = 0; i < pcmLen; i++) u8[i] = bin.charCodeAt(i);
    return new Blob([buf], { type: 'audio/wav' });
  }

  function unlockIosAudio() {
    if (_ttsUnlocked) return;
    try {
      if (!_ttsAudioEl) _ttsAudioEl = new Audio();
      const empty = pcmToWavBytes(btoa('\x00'.repeat(1200)), 24000);
      _ttsAudioEl.src = URL.createObjectURL(empty);
      _ttsAudioEl.play().then(() => {
        _ttsAudioEl.pause();
        _ttsUnlocked = true;
      }).catch(() => {});
    } catch (_) {}
  }

  async function fetchGeminiTtsUrl(text, preferMale) {
    const apiKey = state.settings.geminiKey?.trim();
    if (!apiKey || !navigator.onLine) return null;
    const key = `${preferMale ? 'm' : 'f'}|${text}`;
    if (_ttsBlobCache.has(key)) return _ttsBlobCache.get(key);

    const voiceName = preferMale ? 'Charon' : 'Aoede';
    const dir = preferMale
      ? 'Read aloud in Brazilian Portuguese with an authentic Rio de Janeiro (carioca) accent, warm deep calm male pastor voice. Read ONLY the Bible text below:\n\n'
      : 'Read aloud in Brazilian Portuguese with an authentic Rio de Janeiro (carioca) accent, warm gentle clear female narrator voice. Read ONLY the Bible text below:\n\n';

    try {
      const res = await fetch(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent',
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'x-goog-api-key': apiKey },
          body: JSON.stringify({
            contents: [{ parts: [{ text: `${dir}${text}` }] }],
            generationConfig: {
              responseModalities: ['AUDIO'],
              speechConfig: {
                voiceConfig: { prebuiltVoiceConfig: { voiceName } },
              },
            },
          }),
        }
      );
      if (!res.ok) return null;
      const json = await res.json();
      const parts = json?.candidates?.[0]?.content?.parts || [];
      const inline = parts.find((p) => p.inlineData)?.inlineData;
      if (!inline) return null;
      const rateMatch = /rate=(\d+)/.exec(inline.mimeType || '');
      const blob = pcmToWavBytes(inline.data, rateMatch ? Number(rateMatch[1]) : 24000);
      const url = URL.createObjectURL(blob);
      _ttsBlobCache.set(key, url);
      if (_ttsBlobCache.size > 10) {
        const firstKey = _ttsBlobCache.keys().next().value;
        URL.revokeObjectURL(_ttsBlobCache.get(firstKey));
        _ttsBlobCache.delete(firstKey);
      }
      return url;
    } catch {
      return null;
    }
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
        : `${book}, capítulo ${v.chapter}. Versículo ${v.verse}. ${clean}`;
    }
    return `Versículo ${v.verse}. ${clean}`;
  }

  async function speakQueueItem(includeHeader = true, interruptPrev = true) {
    const item = state.tts.queue[state.tts.index];
    if (!item) return stopBibleSpeech();
    const token = ++_ttsToken;
    clearInterval(_ttsKeepAlive);

    if (interruptPrev) {
      try { _ttsAudioEl?.pause(); } catch (_) {}
      try { window.speechSynthesis?.cancel(); } catch (_) {}
    }

    const preferMale = state.settings.voiceGender === 'male';
    const text = formatSpokenVerse(item, includeHeader && state.tts.index === 0, state.tts.queue.length === 1);
    const nextItem = state.tts.queue[state.tts.index + 1];
    updateActiveVoiceLabel();
    if (state.tab === 'bible') renderMain();

    // 1. Tenta Gemini Neural Carioca se houver chave configurada e modo automático
    if (state.tts.isCloudNeural) {
      const url = await fetchGeminiTtsUrl(text, preferMale);
      if (token !== _ttsToken) return;
      if (url) {
        if (!_ttsAudioEl) _ttsAudioEl = new Audio();
        _ttsAudioEl.onended = () => {
          if (token === _ttsToken) advanceTtsQueue();
        };
        _ttsAudioEl.onerror = () => {
          if (token === _ttsToken) advanceTtsQueue();
        };
        _ttsAudioEl.src = url;
        _ttsAudioEl.playbackRate = Math.min(2, Math.max(0.5, state.settings.voiceRate));
        try {
          await _ttsAudioEl.play();
          if (nextItem) {
            fetchGeminiTtsUrl(formatSpokenVerse(nextItem, false, false), preferMale);
          }
          return;
        } catch (_) {}
      }
    }

    // 2. Web Speech API local (pt-BR com diferenciação acústica real)
    if (!('speechSynthesis' in window)) {
      showToast('Navegador sem suporte a leitura em voz.', 'error');
      return stopBibleSpeech();
    }

    await new Promise((r) => setTimeout(r, interruptPrev ? 60 : 15));
    if (token !== _ttsToken) return;

    const utt = new SpeechSynthesisUtterance(text);
    utt.lang = 'pt-BR';
    const picked = pickBestBrowserVoice(preferMale, state.settings.voiceId);
    let rate = state.settings.voiceRate;
    let pitch = 1.0;

    if (picked) {
      utt.voice = picked.raw;
      if (preferMale && picked.isMale) {
        pitch = 0.94;
        rate = rate * 0.98;
      } else if (!preferMale && picked.isFemale) {
        pitch = 1.08;
      } else if (preferMale && !picked.isMale) {
        pitch = 0.62;
        rate = rate * 0.92;
      } else {
        pitch = 1.32;
        rate = rate * 1.03;
      }
    } else {
      pitch = preferMale ? 0.65 : 1.12;
    }

    utt.rate = Math.min(2, Math.max(0.5, rate));
    utt.pitch = Math.min(2, Math.max(0.5, pitch));
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
    }, 10000);
  }

  function advanceTtsQueue() {
    if (state.tts.index + 1 < state.tts.queue.length) {
      state.tts.index++;
      speakQueueItem(false, false);
    } else {
      stopBibleSpeech();
    }
  }

  function startBibleSpeech(verses) {
    if (!verses || !verses.length) return;
    if (state.settings.geminiKey) unlockIosAudio();
    state.tts.queue = verses;
    state.tts.index = 0;
    state.tts.isPlaying = true;
    state.tts.isPaused = false;
    speakQueueItem(true, true);
  }

  function stopBibleSpeech() {
    _ttsToken++;
    clearInterval(_ttsKeepAlive);
    try { _ttsAudioEl?.pause(); } catch (_) {}
    try { window.speechSynthesis?.cancel(); } catch (_) {}
    state.tts.isPlaying = false;
    state.tts.isPaused = false;
    state.tts.queue = [];
    state.tts.index = 0;
    if (state.tab === 'bible') renderMain();
  }

  // =========================================================================
  // MOTOR DE IA GEMINI PRO + CONTINGÊNCIA EXEGÉTICA
  // =========================================================================
  const GEMINI_MODELS = {
    'gemini-2.5-pro': 'Gemini 2.5 Pro (Padrão • Máxima Exegese)',
    'gemini-3-pro-preview': 'Gemini 3 Pro Preview (Raciocínio Avançado)',
    'gemini-2.5-flash': 'Gemini 2.5 Flash (Resposta Ultrarrápida)',
  };

  async function callGeminiJson(prompt, modelId, apiKey) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelId}:generateContent?key=${encodeURIComponent(apiKey)}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.35, responseMimeType: 'application/json' },
      }),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    let txt = data?.candidates?.[0]?.content?.parts?.[0]?.text || '';
    txt = txt.trim().replace(/^```json\s*/i, '').replace(/^```/, '').replace(/```$/, '').trim();
    return JSON.parse(txt);
  }

  async function generateOutlineWithAi(theme, ref, sermonType) {
    const cleanTheme = theme.trim() || 'Salmo 22 e a Crucificação de Jesus';
    const cleanRef = ref.trim() || 'Salmos 22 / Mateus 27';
    const cleanType = sermonType || 'Expositivo';
    const apiKey = state.settings.geminiKey?.trim();
    const chosenModel = state.settings.geminiModel || 'gemini-2.5-pro';

    const prompt = `Você é um Teólogo e Doutor em Homilética Bíblica Cristã Conservadora.
Construa um esboço homilético completo com base em:
- TEMA: "${cleanTheme}"
- TEXTO BÍBLICO: "${cleanRef}"
- TIPO DE SERMÃO: "${cleanType}"
Crie EXATAMENTE 5 divisões homiléticas. Retorne ESTRITAMENTE um JSON válido:
{
  "title": "Título marcante",
  "biblicalReference": "${cleanRef}",
  "sermonType": "${cleanType}",
  "historicalContext": "Contexto histórico, autor e público.",
  "crossReferences": ["Ref 1", "Ref 2", "Ref 3", "Ref 4", "Ref 5"],
  "introduction": "Introdução impactante.",
  "blocks": [
    {"title": "1. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "2. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "3. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "4. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."},
    {"title": "5. ...", "biblicalReference": "...", "explanation": "...", "illustration": "...", "application": "..."}
  ],
  "conclusion": "Conclusão sintetizando as 5 divisões.",
  "appeal": "Apelo pastoral."
}`;

    if (apiKey && navigator.onLine) {
      const modelsToTry = chosenModel === 'gemini-2.5-flash'
        ? ['gemini-2.5-flash']
        : [chosenModel, 'gemini-2.5-flash'];
      for (const m of modelsToTry) {
        try {
          const parsed = await callGeminiJson(prompt, m, apiKey);
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
            usedModel: `${GEMINI_MODELS[m] ? m.replace(/-/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()) : m} (Google AI)`,
            isCloud: true,
          };
        } catch (e) {
          console.warn('[Gemini]', m, e);
        }
      }
    }

    // Fallback offline contextual rico
    return {
      title: cleanTheme,
      biblicalReference: cleanRef,
      sermonType: cleanType,
      historicalContext: `Passagem sagrada inserida no contexto canônico de ${cleanRef}, revelando a soberania de Deus e o chamado pactual do evangelho.`,
      crossReferences: [
        'Salmos 119:105', 'Romanos 8:31-39', 'Isaías 40:28-31', 'Hebreus 4:14-16', '2 Coríntios 12:9-10'
      ],
      introduction: `Ao examinarmos ${cleanRef} sob o tema "${cleanTheme}", contemplamos a relevância eterna das Escrituras para restaurar a fé, consolar a alma e alinhar a igreja ao propósito de Cristo.`,
      blocks: [
        { id: uuid(), title: `1. O Cenário Revelado em ${cleanRef}`, biblicalReference: `${cleanRef} (Parte 1)`, explanation: `A revelação bíblica parte da realidade humana concreta, mostrando que Deus intervém na história com graça e soberania.`, illustration: 'O arquiteto que analisa o terreno antes de erguer os pilares de sustentação.', application: 'Apresente suas preocupações e lutas diante do Senhor com sinceridade.', orderIndex: 0 },
        { id: uuid(), title: '2. O Fundamento Imutável da Aliança', biblicalReference: `${cleanRef} (Parte 2)`, explanation: `As promessas do Senhor não oscilam com as circunstâncias; estão ancoradas no Seu próprio caráter fiel.`, illustration: 'A rocha firme no litoral que resiste intacta às marés da tempestade.', application: 'Tome decisões apoiado na Palavra de Deus e não na instabilidade dos sentimentos.', orderIndex: 1 },
        { id: uuid(), title: '3. A Centralidade Redentora de Cristo', biblicalReference: 'João 14:6 • Colossenses 1:19-20', explanation: `Toda a Escritura aponta para Jesus. Na cruz e ressurreição encontramos perdão pleno e reconciliação.`, illustration: 'A chave-mestra que abre a cela do prisioneiro e lhe devolve a liberdade.', application: 'Descanse na obra consumada de Cristo e abandone o peso da culpa.', orderIndex: 2 },
        { id: uuid(), title: '4. A Renovação pelo Espírito Santo', biblicalReference: 'Gálatas 5:22-25 • Romanos 12:1-2', explanation: `O evangelho transforma mente, afeições e conduta de dentro para fora pelo poder do Espírito.`, illustration: 'A seiva viva que percorre a árvore e faz brotar frutos saudáveis na estação certa.', application: 'Permita que o Espírito trate áreas secretas e produza arrependimento genuíno.', orderIndex: 3 },
        { id: uuid(), title: '5. Testemunho e Obediência Prática', biblicalReference: 'Mateus 5:14-16 • Tiago 1:22', explanation: `A proclamação pastoral conduz à ação prática no lar, no trabalho e na comunhão da igreja.`, illustration: 'A candeia colocada no alto para iluminar todo o ambiente ao redor.', application: 'Viva esta mensagem nesta semana através do perdão, serviço e testemunho cristão.', orderIndex: 4 },
      ],
      conclusion: `A mensagem de ${cleanRef} assegura que a Palavra de Deus nunca volta vazia e cumpre o propósito soberano em Cristo.`,
      appeal: 'Se você deseja renovar sua aliança com Deus hoje, entregue seu coração a Cristo em oração.',
      usedModel: apiKey ? 'Motor Contextual Integrado (Contingência Offline)' : 'Motor Contextual Integrado (Configure sua Chave Gemini Pro)',
      isCloud: false,
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
      <!-- Topbar Fixa e Elegante -->
      <header class="pulpit-topbar">
        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
          <button class="btn btn-sm btn-outline" id="pulpit-exit-btn" title="Atalho: Esc">← Sair</button>
          
          <div class="pulpit-timer-badge">
            <span style="font-size:16px;">⏱</span>
            <span id="pulpit-timer-display" class="pulpit-timer">${formatTimer(state.pulpit.timerSeconds)}</span>
            <button class="btn btn-xs btn-outline" id="pulpit-timer-toggle" style="padding:2px 8px;min-height:28px;" title="Atalho: T">${state.pulpit.timerRunning ? '⏸' : '▶'}</button>
            <button class="btn btn-xs btn-outline" id="pulpit-timer-reset" style="padding:2px 8px;min-height:28px;" title="Reiniciar cronômetro">↺</button>
          </div>
        </div>

        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
          <!-- Teleprompter Auto-Scroll -->
          <button class="pulpit-autoscroll-btn ${state.pulpit.autoScroll ? 'active' : ''}" id="pulpit-btn-autoscroll" title="Atalho: Espaço">
            ${state.pulpit.autoScroll ? '⏸ Pausar' : '▶ Auto-Rolagem'}
          </button>
          <button class="btn btn-xs btn-outline" id="pulpit-speed-btn" title="Alterar velocidade de rolagem" style="min-height:34px;padding:4px 10px;">
            ${state.pulpit.autoScrollSpeed || 1}x
          </button>

          <!-- Ajuste de Fonte Sem Perder o Ponto de Leitura -->
          <div style="display:inline-flex;align-items:center;gap:4px;background:rgba(255,255,255,0.06);border:1px solid rgba(255,255,255,0.12);padding:2px 6px;border-radius:10px;">
            <button class="btn btn-xs btn-outline" id="pulpit-font-dec" style="min-height:30px;padding:2px 8px;">A-</button>
            <span id="pulpit-font-indicator" style="font-size:13px;font-weight:800;min-width:38px;text-align:center;">${fs}px</span>
            <button class="btn btn-xs btn-outline" id="pulpit-font-inc" style="min-height:30px;padding:2px 8px;">A+</button>
          </div>

          <!-- Tema Visual -->
          <button class="btn btn-xs btn-outline" id="pulpit-theme-cycle" style="min-height:34px;">
            ${state.settings.pulpitTheme === 'amber' ? '📜 Sépia' : state.settings.pulpitTheme === 'light' ? '☀️ Claro' : '🌙 OLED'}
          </button>

          <!-- Largura Adaptativa Automática / Foco -->
          <button class="btn btn-xs btn-outline" id="pulpit-width-toggle" title="Alternar largura (Fluida / Foco / Tela Cheia)" style="min-height:34px;">
            ${state.settings.pulpitWidth === 'focus' ? '↔ Foco' : state.settings.pulpitWidth === 'full' ? '↔ 100%' : '↔ Fluida'}
          </button>

          <!-- Concluir Ministração -->
          <button class="btn btn-xs btn-emerald" id="pulpit-finish-btn" style="min-height:34px;">✓ Concluir</button>
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
    const hasKey = Boolean(state.settings.geminiKey?.trim());
    const modelName = state.settings.geminiModel || 'gemini-2.5-pro';
    const outline = state.ai.outline;

    openModal(
      `
      <div class="modal-header">
        <div style="display:flex;align-items:center;gap:10px;min-width:0;">
          <span style="font-size:22px;">✨</span>
          <div>
            <h3 class="modal-title">Assistente Homilético IA</h3>
            <span class="mini-badge ${hasKey ? '' : 'offline'}" id="ai-key-badge">
              ${hasKey ? `${esc(modelName)} Ativo` : 'Configurar Gemini 2.5 Pro'}
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
            ${state.ai.isLoading ? '⏳ Gemini Construindo Esboço (5 Tópicos)...' : '✨ Gerar Esboço com Gemini Pro (5 Tópicos)'}
          </button>
          ${outline ? `
            <div class="card" style="margin-top:16px;border-color:rgba(139,92,246,0.4);">
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
            openAiModal(onApplyToEditor);
            try {
              state.ai.outline = await generateOutlineWithAi(state.ai.theme, state.ai.ref, state.ai.sermonType);
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
              if (apiKey && navigator.onLine) {
                const res = await callGeminiJson(
                  `Crie 3 ilustrações práticas em Português para o tema "${ctx}". Retorne JSON: {"illustrations": ["...", "...", "..."]}`,
                  state.settings.geminiModel || 'gemini-2.5-pro',
                  apiKey
                );
                state.ai.illustrations = res.illustrations || [];
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
              if (apiKey && navigator.onLine) {
                const res = await callGeminiJson(
                  `Analise 3 palavras-chave em Grego ou Hebraico de "${pas}". Retorne JSON: {"insights":[{"word":"","transliteration":"","language":"","strongNumber":"","meaning":"","theologicalInsight":""}]}`,
                  state.settings.geminiModel || 'gemini-2.5-pro',
                  apiKey
                );
                state.ai.lexical = res.insights || [];
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

  function openGeminiConfigModal(onDone = null) {
    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title">✨ Motor Gemini 2.5 Pro • Configuração</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <p style="font-size:13.5px;color:var(--text-muted);margin:0 0 12px;">
        Base configurada: <strong>Gemini 2.5 Pro</strong>. Cole sua API Key do <strong>aistudio.google.com/apikey</strong> (ela fica salva com segurança no aparelho).
      </p>
      <label class="editor-section-label">Modelo Base</label>
      <select id="gem-model-sel" class="select-field" style="margin-bottom:12px;">
        ${Object.entries(GEMINI_MODELS).map(([k, v]) => `<option value="${k}" ${state.settings.geminiModel === k ? 'selected' : ''}>${esc(v)}</option>`).join('')}
      </select>
      <label class="editor-section-label">Gemini API Key (AIza...)</label>
      <input id="gem-key-inp" type="password" class="input-field" placeholder="Cole sua chave aqui..." value="${esc(state.settings.geminiKey || '')}" style="margin-bottom:10px;">
      <div id="gem-test-status" style="font-size:13px;margin-bottom:12px;"></div>
      <div style="display:flex;gap:8px;justify-content:flex-end;flex-wrap:wrap;">
        <button class="btn btn-outline" id="gem-test-btn">📡 Testar Chave</button>
        <button class="btn btn-purple" id="gem-save-btn">Salvar</button>
      </div>
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
        sheet.querySelector('#gem-test-btn').onclick = async () => {
          const key = sheet.querySelector('#gem-key-inp').value.trim();
          const mod = sheet.querySelector('#gem-model-sel').value;
          const out = sheet.querySelector('#gem-test-status');
          if (!key) {
            out.innerHTML = '<span style="color:var(--danger);">Informe uma chave válida.</span>';
            return;
          }
          out.innerHTML = 'Testando conexão com Google AI...';
          try {
            const res = await fetch(
              `https://generativelanguage.googleapis.com/v1beta/models/${mod}:generateContent?key=${encodeURIComponent(key)}`,
              {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ contents: [{ parts: [{ text: 'OK' }] }], generationConfig: { maxOutputTokens: 5 } }),
              }
            );
            if (res.ok) {
              out.innerHTML = `<span style="color:var(--green);font-weight:700;">✓ Conexão confirmada com ${esc(mod)}!</span>`;
            } else {
              const err = await res.json().catch(() => ({}));
              out.innerHTML = `<span style="color:var(--danger);">Erro ${res.status}: ${esc(err?.error?.message || 'Chave inválida')}</span>`;
            }
          } catch (e) {
            out.innerHTML = `<span style="color:var(--danger);">Erro de rede: ${esc(e.message)}</span>`;
          }
        };
        sheet.querySelector('#gem-save-btn').onclick = () => {
          state.settings.geminiKey = sheet.querySelector('#gem-key-inp').value.trim();
          state.settings.geminiModel = sheet.querySelector('#gem-model-sel').value;
          writeStore(KEYS.SETTINGS, state.settings);
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
  ];

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
      b.onclick = () => switchTab(b.dataset.nav);
    });

    // Bottom nav mobile
    const bNav = document.getElementById('bottom-nav');
    bNav.innerHTML = NAV_ITEMS.map((n) => `
      <button class="bottom-nav-btn ${state.tab === n.id ? 'active' : ''}" data-nav="${n.id}">
        <span class="nav-ico">${n.icon}</span>
        <span>${n.label}</span>
      </button>
    `).join('');
    bNav.querySelectorAll('[data-nav]').forEach((b) => {
      b.onclick = () => switchTab(b.dataset.nav);
    });

    // Sidebar user card
    const initials = (state.profile.fullName || 'P')
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map((w) => w[0].toUpperCase())
      .join('');
    document.getElementById('sidebar-user-card').innerHTML = `
      <div class="user-avatar">${esc(initials)}</div>
      <div class="user-meta">
        <div class="user-name">${esc(state.profile.fullName)}</div>
        <div class="user-role">${esc(state.profile.churchName || state.profile.ministryTitle)}</div>
      </div>
    `;

    // Topbar title
    const activeNav = NAV_ITEMS.find((n) => n.id === state.tab);
    document.getElementById('topbar-title').textContent =
      state.tab === 'editor' ? 'Editor de Sermão' : activeNav ? activeNav.label : 'Pregador Pro';

    updateSyncIndicators();
  }

  function updateSyncIndicators() {
    const isCloud = Boolean(state.cloudAuth?.accessToken);
    const online = navigator.onLine;
    const pill = document.getElementById('sync-status-pill');
    const mobileBadge = document.getElementById('mobile-sync-badge');

    let text = 'Salvo no Aparelho';
    let cls = '';
    if (!online) {
      text = 'Modo Offline (Púlpito OK)';
      cls = 'offline';
    } else if (isCloud) {
      text = 'Nuvem Supabase Conectada';
      cls = 'cloud';
    }

    if (pill) {
      pill.className = `sync-pill ${cls}`;
      pill.querySelector('.sync-label').textContent = text;
    }
    if (mobileBadge) {
      mobileBadge.className = `mini-badge ${cls}`;
      mobileBadge.textContent = !online ? 'Offline OK' : isCloud ? 'Nuvem ✓' : 'Salvo ✓';
    }
  }

  function switchTab(tabId) {
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
        <div style="display:flex;align-items:center;gap:8px;min-width:0;flex:1;">
          <button class="btn btn-xs btn-outline" id="ed-back-btn">← Voltar</button>
          <div style="min-width:0;">
            <div id="ed-header-title" style="font-size:14px;font-weight:800;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${esc(s.title)}</div>
            <div id="ed-save-status" class="editor-status">✓ Salvo automaticamente</div>
          </div>
        </div>
        <div style="display:flex;align-items:center;gap:6px;flex-shrink:0;">
          <button class="icon-btn" id="ed-bible-btn" title="Consultar Bíblia">📖</button>
          <button class="icon-btn" id="ed-ai-btn" title="Assistente Gemini Pro">✨</button>
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
        <button class="btn btn-whatsapp" id="ed-wa-btn" style="flex:1;">💬 Compartilhar WhatsApp</button>
        <button class="btn btn-outline" id="ed-pdf-btn" style="flex:1;">🖨️ Exportar PDF A4</button>
      </div>

      <button class="btn btn-danger btn-block" id="ed-del-bottom-btn">🗑️ Excluir este Sermão</button>
    `;

    const persistEditorLive = () => {
      const updated = saveSermon(state.editingSermon);
      state.editingSermon = updated;
      const stEl = document.getElementById('ed-save-status');
      const htEl = document.getElementById('ed-header-title');
      if (stEl) stEl.textContent = '✓ Salvo agora';
      if (htEl) htEl.textContent = updated.title || 'Novo Sermão';
    };

    const bindInput = (sel, field, isNum = false) => {
      const el = root.querySelector(sel);
      if (!el) return;
      el.addEventListener('input', () => {
        state.editingSermon[field] = isNum ? Number(el.value || 40) : el.value;
        persistEditorLive();
      });
    };

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
    const hasNativeMale = state.tts.voices.some((v) => v.isMale);
    openModal(
      `
      <div class="modal-header">
        <h3 class="modal-title">🎙️ Vozes Bíblicas (Brasil • Rio de Janeiro)</h3>
        <button class="icon-btn-ghost" data-close-modal>✕</button>
      </div>
      <p style="font-size:13px;color:var(--gold);font-weight:700;margin:0 0 12px;">Motor ativo: ${esc(state.tts.activeLabel)}</p>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:12px;">
        <button class="btn ${state.settings.voiceGender === 'male' ? 'btn-primary' : 'btn-outline'}" id="vs-male">👨 Masculina (RJ)</button>
        <button class="btn ${state.settings.voiceGender === 'female' ? 'btn-purple' : 'btn-outline'}" id="vs-female">👩 Feminina (RJ)</button>
      </div>
      <button class="btn btn-gold btn-block" id="vs-test-btn" style="margin-bottom:14px;">▶ Testar Voz Agora (Salmos 23:1)</button>
      <div style="font-size:12px;font-weight:800;color:var(--text-muted);margin-bottom:8px;">VOZES DETECTADAS NO APARELHO (pt-BR):</div>
      <div style="display:flex;flex-direction:column;gap:6px;max-height:220px;overflow-y:auto;">
        <button class="btn btn-sm ${!state.settings.voiceId ? 'btn-primary' : 'btn-outline'}" style="justify-content:flex-start;" data-pick-voice="">
          Automático (Brasil • RJ ${state.settings.geminiKey ? '/ Neural Gemini' : ''})
        </button>
        ${state.tts.voices.map((v) => `
          <button class="btn btn-sm ${state.settings.voiceId === v.id ? 'btn-primary' : 'btn-outline'}" style="justify-content:space-between;" data-pick-voice="${esc(v.id)}">
            <span>${esc(v.name)}</span>
            <span style="font-size:11px;opacity:0.8;">${v.isMale ? 'Masculina' : v.isFemale ? 'Feminina' : v.lang}</span>
          </button>
        `).join('')}
      </div>
      ${!hasNativeMale && !state.settings.geminiKey ? `
        <div style="margin-top:12px;padding:10px;border-radius:10px;background:rgba(59,130,246,0.1);font-size:12px;line-height:1.4;">
          💡 No iPhone, o iOS traz por padrão apenas a voz feminina (Luciana). Aplicamos ajuste acústico grave no modo Masculino, ou você pode baixar <strong>"Felipe / Eddy"</strong> em <em>Ajustes &gt; Acessibilidade &gt; Conteúdo Falado &gt; Vozes &gt; Português (Brasil)</em>, ou ativar sua chave Gemini Pro.
        </div>
      ` : ''}
      `,
      (sheet) => {
        sheet.querySelectorAll('[data-close-modal]').forEach((b) => (b.onclick = closeModal));
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
        sheet.querySelector('#vs-test-btn').onclick = () => {
          startBibleSpeech([{
            bookId: 'sl', bookName: 'Salmos', chapter: 23, verse: 1,
            text: 'O Senhor é o meu pastor; nada me faltará.',
          }]);
        };
        sheet.querySelectorAll('[data-pick-voice]').forEach((b) => {
          b.onclick = () => {
            state.settings.voiceId = b.dataset.pickVoice;
            writeStore(KEYS.SETTINGS, state.settings);
            updateActiveVoiceLabel();
            openVoiceStudioModal();
          };
        });
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
            <span style="font-size:12px;font-weight:800;">🎙️ Voz (RJ):</span>
            <button class="chip ${isMale ? 'active' : ''}" id="tts-male-btn">👨 Masculina (RJ)</button>
            <button class="chip ${!isMale ? 'active' : ''}" id="tts-female-btn">👩 Feminina (RJ)</button>
            <button class="chip" id="tts-voices-btn">⚙ Vozes RJ</button>
          </div>
          <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;">
            <select id="tts-rate-sel" class="select-field" style="width:auto;padding:5px 10px;font-size:13px;">
              <option value="0.86" ${state.settings.voiceRate < 0.9 ? 'selected' : ''}>0.85x Lenta</option>
              <option value="0.96" ${state.settings.voiceRate >= 0.9 && state.settings.voiceRate <= 1.02 ? 'selected' : ''}>1.0x RJ</option>
              <option value="1.10" ${state.settings.voiceRate > 1.02 ? 'selected' : ''}>1.15x Rápida</option>
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
          <button class="btn btn-sm btn-gold" id="prof-edit-btn">✏️ Editar Perfil</button>
        </div>
      </div>

      <div class="card" style="margin-bottom:16px;">
        <h3 style="margin:0 0 6px;">☁️ Sincronização em Nuvem (Trabalho ↔ Casa ↔ iPhone)</h3>
        <p style="font-size:13.5px;color:var(--text-muted);margin:0 0 12px;">
          ${isCloud
            ? `Conectado como <strong>${esc(state.cloudAuth.email)}</strong>. Todos os sermões e edições sincronizam automaticamente com o banco PostgreSQL Supabase.`
            : 'Atualmente seus dados estão salvos com segurança apenas neste aparelho. Conecte ou crie sua conta na nuvem Supabase para sincronizar entre Trabalho, Casa e iPhone.'}
        </p>
        <div style="display:flex;flex-wrap:wrap;gap:8px;">
          ${isCloud ? `
            <button class="btn btn-sm btn-emerald" id="prof-sync-now">🔄 Sincronizar Agora</button>
            <button class="btn btn-sm btn-outline" id="prof-cloud-logout">Desconectar Nuvem</button>
          ` : `
            <button class="btn btn-sm btn-primary" id="prof-cloud-login">☁️ Conectar / Criar Conta Nuvem</button>
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
            writeStore(KEYS.PROFILE, state.profile);
            syncCloudNow({ silent: true });
            closeModal();
            renderChrome();
            renderMain();
            showToast('Perfil atualizado e salvo!', 'success');
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

    const outBtn = root.querySelector('#prof-cloud-logout');
    if (outBtn) {
      outBtn.onclick = () => {
        state.cloudAuth = null;
        localStorage.removeItem(KEYS.CLOUD_AUTH);
        renderChrome();
        renderMain();
        showToast('Desconectado da nuvem (dados locais preservados).', 'info');
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
    document.body.className = `theme-${state.settings.theme}`;
    writeStore(KEYS.SETTINGS, state.settings);
    if (state.tab === 'profile') renderMain();
  }

  function renderMain() {
    const root = document.getElementById('main-content');
    if (state.tab === 'dashboard') renderDashboard(root);
    else if (state.tab === 'library') renderLibrary(root);
    else if (state.tab === 'editor') renderEditor(root);
    else if (state.tab === 'bible') renderBible(root);
    else if (state.tab === 'templates') renderTemplates(root);
    else if (state.tab === 'profile') renderProfile(root);
  }

  // =========================================================================
  // BOOT ULTRARRÁPIDO (< 50ms)
  // =========================================================================
  async function boot() {
    migrateLegacyFlutterStorage();

    state.profile = { ...DEFAULT_PROFILE, ...(readStoreSync(KEYS.PROFILE) || {}) };
    state.settings = { ...DEFAULT_SETTINGS, ...(readStoreSync(KEYS.SETTINGS) || {}) };
    state.cloudAuth = readStoreSync(KEYS.CLOUD_AUTH);
    state.sermonsDelta = readStoreSync(KEYS.SERMONS_DELTA) || {};
    state.deletedIds = new Set(readStoreSync(KEYS.DELETED_IDS) || []);
    state.pendingSync = readStoreSync(KEYS.PENDING_SYNC) || { upsertIds: [], deleteIds: [] };

    // Fallback IndexedDB caso o iOS tenha limpado localStorage
    if (!Object.keys(state.sermonsDelta).length) {
      const idbDelta = await readIdbFallback(KEYS.SERMONS_DELTA);
      if (idbDelta) state.sermonsDelta = idbDelta;
    }

    document.body.className = `theme-${state.settings.theme || 'dark'}`;

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

    document.getElementById('sidebar-new-sermon-btn').onclick = createNewSermonAndOpen;
    document.getElementById('topbar-theme-btn').onclick = toggleTheme;
    document.getElementById('modal-backdrop').onclick = (e) => {
      if (e.target.id === 'modal-backdrop') closeModal();
    };

    window.addEventListener('online', () => syncCloudNow({ silent: true }));
    window.addEventListener('offline', updateSyncIndicators);

    if ('speechSynthesis' in window) {
      refreshBrowserVoices();
      window.speechSynthesis.addEventListener('voiceschanged', refreshBrowserVoices);
    }

    if (state.cloudAuth?.accessToken && navigator.onLine) {
      syncCloudNow({ silent: true, pullAll: true });
    }
  }

  document.addEventListener('DOMContentLoaded', boot);
})();
