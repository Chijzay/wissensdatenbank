import { useState, useEffect, useRef, useCallback } from 'react';
import { Mic, MicOff, Send, Search, X, Plus, ArrowLeft, ChevronRight, ChevronDown, Trash2, Sparkles, Shuffle, GraduationCap, GripVertical, LogOut } from 'lucide-react';
import { api } from '../api/client.js';
import { DndContext, closestCenter, PointerSensor, TouchSensor, useSensor, useSensors } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy, rectSortingStrategy, useSortable, arrayMove } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import ThemePicker from './ThemePicker.jsx';
import ConfirmModal from './ConfirmModal.jsx';
import { supabase } from '../supabase.js';

const EMOJIS = [
  '🧬','🔬','🌿','🌊','⚗️','🌱','🦋','🌍','🌙','❄️',
  '📚','📖','🎓','✏️','🔭','🧪','💡','📐','🗒️','📝',
  '💼','💻','🔧','⚡','🚀','📊','🖥️','📱','🔑','🛠️',
  '🏠','🍕','🍳','🧹','🛒','☕','🎵','🍀','🏡','🧺',
  '🎨','✍️','🎯','🧠','💭','⭐','🔮','🎭','🎬','🎸',
  '📦','📁','🗂️','📋','🏆','❤️','💰','🎲','🧩','🌈',
  '☁️','🐳','⚙️','🛡️','🔗','🗄️','📡','🤖','🔐','🌐',
];
const AUTO_COLORS = ['#6366f1','#22c55e','#f59e0b','#ec4899','#14b8a6','#f97316','#8b5cf6','#06b6d4','#ef4444','#84cc16'];

function buildTree(boxes) {
  const top = boxes.filter(b => !b.parent_id);
  return top.map(b => ({ ...b, children: boxes.filter(c => c.parent_id === b.id) }));
}

function SortableBereichItem({ id, children }) {
  const { setNodeRef, transform, transition, setActivatorNodeRef, listeners, attributes, isDragging } = useSortable({ id });
  return (
    <div ref={setNodeRef} style={{ transform: CSS.Transform.toString(transform), transition, opacity: isDragging ? 0.5 : 1, zIndex: isDragging ? 10 : 'auto', position: 'relative' }}>
      {children({ gripRef: setActivatorNodeRef, gripProps: { ...listeners, ...attributes } })}
    </div>
  );
}

function SortableBoxCard({ id, children }) {
  const { setNodeRef, transform, transition, setActivatorNodeRef, listeners, attributes, isDragging } = useSortable({ id });
  return (
    <div ref={setNodeRef} style={{ transform: CSS.Transform.toString(transform), transition, opacity: isDragging ? 0.4 : 1 }}>
      {children({ gripRef: setActivatorNodeRef, gripProps: { ...listeners, ...attributes } })}
    </div>
  );
}

export default function Home({ onOpenEntry, onStartReview, onShowImpressum }) {
  const [allBoxes, setAllBoxes] = useState([]);
  const [tree, setTree] = useState([]);
  const [entries, setEntries] = useState([]);
  const [search, setSearch] = useState('');

  // Navigation
  const [activeBereich, setActiveBereich] = useState(null);
  const [activeBox, setActiveBox] = useState(null);
  const [expanded, setExpanded] = useState(new Set());
  const navRestored = useRef(false);

  // Capture
  const [content, setContent] = useState('');
  const [saveToBox, setSaveToBox] = useState(null);
  const [recording, setRecording] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState('');
  const [focused, setFocused] = useState(false);

  // KI-Wissensgenerierung
  const [showAiGen, setShowAiGen] = useState(false);
  const [aiTopic, setAiTopic] = useState('');
  const [aiDepth, setAiDepth] = useState('mittel');
  const [aiGenBox, setAiGenBox] = useState(null);
  const [aiLoading, setAiLoading] = useState(false);
  const [aiPreview, setAiPreview] = useState(null); // generierter Eintrag zur Vorschau
  const [aiError, setAiError] = useState('');

  const [showAll, setShowAll] = useState(false);
  const FEED_LIMIT = 6;

  const [confirmPending, setConfirmPending] = useState(null); // { message, onConfirm }

  // Neue Box / Bereich erstellen
  const [creating, setCreating] = useState(null); // null | { parentId: null|number }
  const [newName, setNewName] = useState('');
  const [newIcon, setNewIcon] = useState('📁');
  const [newColor, setNewColor] = useState(AUTO_COLORS[0]);

  const textareaRef = useRef(null);
  const recognitionRef = useRef(null);
  const recordingRef = useRef(false);
  const bereichTouchTimers = useRef({});
  const bereichLongPressed = useRef({});
  const bereichClickTimers = useRef({});
  const isMobile = 'ontouchstart' in window;

  const dndSensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 6 } }),
    useSensor(TouchSensor, { activationConstraint: { delay: 200, tolerance: 8 } })
  );

  const handleDragEnd = async ({ active, over }) => {
    if (!over || active.id === over.id) return;
    const oldIdx = tree.findIndex(b => b.id === active.id);
    const newIdx = tree.findIndex(b => b.id === over.id);
    const newTree = arrayMove(tree, oldIdx, newIdx);
    setTree(newTree);
    await fetch('/api/boxes/sort', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ orders: newTree.map((b, i) => ({ id: b.id, sort_order: i + 1 })) }),
    });
  };

  const loadBoxes = useCallback(async () => {
    const boxes = await api.boxes.list();
    setAllBoxes(boxes);
    setTree(buildTree(boxes));
  }, []);

  const loadEntries = useCallback(async () => {
    const params = {};
    if (search) params.search = search;
    let data;
    if (activeBox) {
      data = await api.cards.all({ topic: activeBox.id, ...params });
    } else if (activeBereich) {
      data = await api.cards.all({ bereich: activeBereich.id, ...params });
    } else {
      data = await api.cards.all(params);
    }
    setEntries(data);
  }, [activeBox, activeBereich, search]);

  useEffect(() => { loadBoxes(); }, [loadBoxes]);

  // Navigation nach Reload wiederherstellen (einmalig nach dem ersten Box-Laden)
  useEffect(() => {
    if (!allBoxes.length || navRestored.current) return;
    navRestored.current = true;
    const bereichId = Number(localStorage.getItem('nav-bereich-id'));
    const boxId = Number(localStorage.getItem('nav-box-id'));
    if (bereichId) {
      const bereich = allBoxes.find(b => b.id === bereichId);
      if (bereich) {
        setActiveBereich(bereich);
        setExpanded(prev => new Set([...prev, bereich.id]));
        if (boxId) {
          const box = allBoxes.find(b => b.id === boxId);
          if (box) { setActiveBox(box); setSaveToBox(box); }
        }
      }
    }
  }, [allBoxes]);

  // Bereich/Box-Position speichern
  useEffect(() => {
    if (activeBereich) localStorage.setItem('nav-bereich-id', activeBereich.id);
    else localStorage.removeItem('nav-bereich-id');
  }, [activeBereich]);
  useEffect(() => {
    if (activeBox) localStorage.setItem('nav-box-id', activeBox.id);
    else localStorage.removeItem('nav-box-id');
  }, [activeBox]);

  useEffect(() => { loadEntries(); }, [loadEntries]);
  useEffect(() => { const t = setTimeout(loadEntries, 280); return () => clearTimeout(t); }, [search]);

  const save = async () => {
    if (!content.trim()) return;
    const hasSubBoxes = (b) => b && allBoxes.some(x => x.parent_id === b.id);
    const box = saveToBox || activeBox || (!hasSubBoxes(activeBereich) ? activeBereich : null);
    if (!box) {
      setSaveError('Bitte zuerst einen Bereich oder eine Box auswählen ↓');
      return;
    }
    setSaveError('');
    setSaving(true);
    try {
      const lines = content.trim().split('\n');
      const title = lines[0].slice(0, 80) || 'Ohne Titel';
      const body = lines.slice(1).join('\n').trim();
      const newCard = await api.cards.create({ box_id: box.id, title, content: body });
      const fullCard = { ...newCard, box_name: box.name, box_color: box.color, box_icon: box.icon, box_parent_id: box.parent_id };
      setContent('');
      setSaveToBox(null);
      onOpenEntry(fullCard);
      textareaRef.current?.focus();
    } finally { setSaving(false); }
  };

  const createBox = async () => {
    if (!newName.trim()) return;
    await api.boxes.create({ name: newName.trim(), icon: newIcon, color: newColor, parent_id: creating?.parentId || null });
    await loadBoxes();
    setCreating(null); setNewName(''); setNewIcon('📁'); setNewColor(AUTO_COLORS[0]);
    if (creating?.parentId) setExpanded(prev => new Set([...prev, creating.parentId]));
  };

  const deleteBox = (e, box) => {
    e.stopPropagation();
    const hasChildren = allBoxes.some(b => b.parent_id === box.id);
    const msg = hasChildren
      ? `Bereich „${box.name}" und alle darin enthaltenen Boxen und Einträge unwiderruflich löschen?`
      : `Box „${box.name}" und alle ${box.card_count ?? 0} Einträge unwiderruflich löschen?`;
    setConfirmPending({
      message: msg,
      onConfirm: async () => {
        setConfirmPending(null);
        await api.boxes.delete(box.id);
        if (activeBereich?.id === box.id) setActiveBereich(null);
        if (activeBox?.id === box.id) setActiveBox(null);
        await loadBoxes();
        await loadEntries();
      },
    });
  };

  const handleSubBoxDragEnd = async ({ active, over }, parentId) => {
    if (!over || active.id === over.id) return;
    const siblings = allBoxes.filter(b => b.parent_id === parentId);
    const oldIdx = siblings.findIndex(b => b.id === active.id);
    const newIdx = siblings.findIndex(b => b.id === over.id);
    const newOrder = arrayMove(siblings, oldIdx, newIdx);
    await fetch('/api/boxes/sort', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ orders: newOrder.map((b, i) => ({ id: b.id, sort_order: i + 1 })) }),
    });
    await loadBoxes();
  };

  const toggleExpand = (id) => setExpanded(prev => {
    const n = new Set(prev);
    n.has(id) ? n.delete(id) : n.add(id);
    return n;
  });

  // Doppelklick-Timer für Bereiche: erster Klick wartet 380ms.
  // Zweiter Klick innerhalb 380ms → navigieren. Timer abgelaufen → expand.
  const handleBereichClick = (bereich) => {
    if (bereichClickTimers.current[bereich.id]) {
      clearTimeout(bereichClickTimers.current[bereich.id]);
      delete bereichClickTimers.current[bereich.id];
      navigateToBereich(bereich);
    } else {
      bereichClickTimers.current[bereich.id] = setTimeout(() => {
        delete bereichClickTimers.current[bereich.id];
        toggleExpand(bereich.id);
      }, 380);
    }
  };

  const [micError, setMicError] = useState('');

  const startRecording = async (e) => {
    e.preventDefault();
    if (recordingRef.current) { stopRecording(); return; }
    if (!('webkitSpeechRecognition' in window || 'SpeechRecognition' in window)) {
      setMicError('Spracherkennung nur in Chrome verfügbar'); return;
    }

    // Kein HTTPS → Mikrofon auf Mobilgeräten nicht möglich
    if (!window.isSecureContext) {
      setMicError('Diktieren erfordert HTTPS. Für lokalen Test: ngrok oder chrome://flags → "Insecure origins treated as secure" → IP:Port eintragen und Chrome neu starten.');
      return;
    }

    // Mikrofon-Berechtigung explizit anfragen → löst Browser-Popup aus
    if (navigator.mediaDevices?.getUserMedia) {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
        stream.getTracks().forEach(t => t.stop());
        setMicError('');
      } catch (err) {
        setMicError(
          err.name === 'NotAllowedError'
            ? 'Mikrofon-Zugriff verweigert – bitte im Popup "Erlauben" klicken'
            : err.name === 'NotFoundError'
            ? 'Kein Mikrofon gefunden'
            : `Mikrofon-Fehler: ${err.message}`
        );
        return;
      }
    }

    const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
    const rec = new SR();
    rec.lang = 'de-DE'; rec.continuous = true; rec.interimResults = false;
    rec.onresult = e => {
      const t = Array.from(e.results).map(r => r[0].transcript).join(' ');
      setContent(p => p ? p + ' ' + t : t);
    };
    rec.onerror = (ev) => {
      const msg = ev.error === 'not-allowed'
        ? 'Mikrofon-Zugriff verweigert'
        : ev.error === 'network'
        ? 'Netzwerkfehler – auf dem Handy ist HTTPS erforderlich'
        : `Fehler: ${ev.error}`;
      setMicError(msg);
      recordingRef.current = false;
      setRecording(false);
    };
    rec.onend = () => {
      if (recordingRef.current) {
        try { rec.start(); } catch { recordingRef.current = false; setRecording(false); }
      } else {
        setRecording(false);
      }
    };
    try {
      rec.start();
      recognitionRef.current = rec;
      recordingRef.current = true;
      setRecording(true);
    } catch (err) {
      setMicError(`Konnte nicht starten: ${err.message}`);
    }
  };

  const stopRecording = () => {
    if (!recordingRef.current) return;
    recognitionRef.current?.stop();
  };

  const generateWithAI = async () => {
    if (!aiTopic.trim()) return;
    setAiLoading(true); setAiError(''); setAiPreview(null);
    try {
      const targetBox = aiGenBox || activeBox || (activeBereich?.children?.[0]) || allBoxes[0];
      const result = await api.ai.generateEntry({ topic: aiTopic, depth: aiDepth });
      setAiPreview({ ...result, _targetBox: targetBox });
    } catch (err) {
      const msg = err?.message || '';
      if (msg.includes('credit balance') || msg.includes('credits')) {
        setAiError('Kein Guthaben — bitte unter console.anthropic.com/settings/billing aufladen.');
      } else if (msg.includes('HIER_DEINEN') || msg.includes('invalid x-api-key')) {
        setAiError('Kein gültiger API-Key — bitte in backend/.env eintragen.');
      } else {
        setAiError('KI-Fehler: ' + (msg.slice(0, 120) || 'Unbekannter Fehler'));
      }
    } finally { setAiLoading(false); }
  };

  const saveAiEntry = async () => {
    if (!aiPreview) return;
    const box = aiPreview._targetBox || allBoxes[0];
    if (!box) return;
    await api.cards.create({ box_id: box.id, title: aiPreview.title, content: aiPreview.content, tags: aiPreview.tags || [], category: aiPreview.category || '' });
    setAiPreview(null); setAiTopic(''); setShowAiGen(false);
    await loadEntries();
  };

  const formatDate = iso => {
    const d = new Date(iso), now = new Date(), diff = (now - d) / 1000;
    if (diff < 60) return 'Gerade eben';
    if (diff < 3600) return `vor ${Math.floor(diff / 60)} Min.`;
    if (diff < 86400) return `vor ${Math.floor(diff / 3600)} Std.`;
    if (diff < 172800) return 'Gestern';
    return d.toLocaleDateString('de-DE', { day: 'numeric', month: 'short' });
  };

  const navigateToBereich = (b) => {
    setActiveBereich(b); setActiveBox(null);
    if (!expanded.has(b.id)) setExpanded(prev => new Set([...prev, b.id]));
  };
  const navigateToBox = (box, bereich) => {
    setActiveBox(box); setActiveBereich(bereich); setSaveToBox(box);
  };
  const goHome = () => { setActiveBereich(null); setActiveBox(null); setSaveToBox(null); };

  const openRandom = () => {
    if (!entries.length) return;
    onOpenEntry(entries[Math.floor(Math.random() * entries.length)]);
  };

  // Breadcrumb Label
  const crumbLabel = activeBox
    ? `${activeBereich?.icon || ''} ${activeBereich?.name} › ${activeBox.icon} ${activeBox.name}`
    : activeBereich ? `${activeBereich.icon} ${activeBereich.name}` : null;

  const accentColor = activeBox?.color || activeBereich?.color || tree[0]?.color || 'var(--accent)';

  // Welche Boxen im Capture-Picker zeigen?
  const captureCandidates = activeBereich
    ? allBoxes.filter(b => b.parent_id === activeBereich.id)
    : allBoxes.filter(b => !b.parent_id);

  return (
    <div className="main-wrap" style={{ maxWidth: 780, margin: '0 auto', padding: '28px 20px' }}>

      {/* HEADER / BREADCRUMB */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 22 }}>
        {crumbLabel ? (
          <>
            <button onClick={goHome}
              style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '6px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
              <ArrowLeft size={14} /> Alle Bereiche
            </button>
            {activeBox && activeBereich && (
              <button onClick={() => { setActiveBox(null); setSaveToBox(null); }}
                style={{ padding: '6px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
                {activeBereich.icon} {activeBereich.name}
              </button>
            )}
            <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>›</span>
            <span style={{ fontSize: 15, fontWeight: 700 }}>
              {activeBox ? `${activeBox.icon} ${activeBox.name}` : `${activeBereich.icon} ${activeBereich.name}`}
            </span>
            <span style={{ fontSize: 13, color: 'var(--text-muted)', marginLeft: 4 }}>
              {entries.length} {entries.length === 1 ? 'Eintrag' : 'Einträge'}
            </span>
          </>
        ) : (
          <>
            <div style={{ flex: 1 }}>
              <h1 style={{ fontSize: 26, fontWeight: 700, letterSpacing: '-0.3px', lineHeight: 1.2 }}>Mein Wissen</h1>
              <p style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 3, fontStyle: 'italic', letterSpacing: '0.04em' }}>Lernen. Verstehen. Behalten.</p>
            </div>
            <ThemePicker />
            <button
              onClick={() => supabase.auth.signOut()}
              title="Abmelden"
              style={{
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                width: 34, height: 34, borderRadius: '50%',
                border: '1px solid var(--border)', background: 'var(--surface)',
                color: 'var(--text-muted)', transition: 'all 0.15s', fontSize: 15,
              }}
              onMouseEnter={e => { e.currentTarget.style.background = 'var(--surface2)'; e.currentTarget.style.borderColor = '#ef4444'; e.currentTarget.style.color = '#ef4444'; }}
              onMouseLeave={e => { e.currentTarget.style.background = 'var(--surface)'; e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; }}
            >
              <LogOut size={16} />
            </button>
          </>
        )}
      </div>

      {/* SCHNELLEINGABE */}
      <div style={{
        background: 'var(--surface)', borderRadius: 16, marginBottom: 28,
        border: `1.5px solid ${focused ? accentColor : 'var(--border)'}`,
        boxShadow: focused ? `0 0 0 3px ${accentColor}18` : 'none',
        transition: 'border-color 0.2s, box-shadow 0.2s', overflow: 'hidden',
      }}>
        <div style={{ height: 4, background: accentColor, transition: 'background 0.3s' }} />
        <div className="capture-box" style={{ padding: '18px 20px' }}>
          <textarea ref={textareaRef} value={content}
            onChange={e => { setContent(e.target.value); if (saveError) setSaveError(''); }}
            onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
            onKeyDown={e => { if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) save(); }}
            placeholder="Was möchtest du festhalten?&#10;(erste Zeile wird Titel)"
            rows={5}
            style={{ width: '100%', fontSize: 16, lineHeight: 1.7, background: 'transparent', marginBottom: 14 }} />

          {/* Ziel-Box Statuszeile — feste Mindesthöhe verhindert Layout-Shift beim Klicken */}
          {(() => {
            const hasSubBoxes = (b) => b && allBoxes.some(x => x.parent_id === b.id);
            const effectiveBox = saveToBox || activeBox || (!hasSubBoxes(activeBereich) ? activeBereich : null);
            const showRow = effectiveBox || saveError || content.trim();
            if (!showRow) return null;
            return (
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, minHeight: 36, marginBottom: 14, paddingBottom: 14, borderBottom: '1px solid var(--border)' }}>
                {effectiveBox ? (
                  <>
                    <span style={{ fontSize: 12, color: 'var(--text-muted)', flexShrink: 0 }}>Speichert in:</span>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '3px 10px', borderRadius: 20, fontSize: 13, fontWeight: 600,
                      background: (effectiveBox.color || 'var(--accent)') + '22', color: effectiveBox.color || 'var(--accent)',
                      border: `1px solid ${(effectiveBox.color || 'var(--accent)') + '44'}` }}>
                      {effectiveBox.icon} {effectiveBox.name}
                    </span>
                    {saveToBox && (
                      <button onClick={() => setSaveToBox(null)} title="Auswahl aufheben"
                        style={{ fontSize: 12, color: 'var(--text-muted)', padding: '2px 6px', borderRadius: 4 }}>✕</button>
                    )}
                  </>
                ) : saveError ? (
                  <span style={{ fontSize: 13, color: 'var(--danger)', fontWeight: 500 }}>{saveError}</span>
                ) : (
                  <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>↓ Bereich oder Box unten auswählen</span>
                )}
              </div>
            );
          })()}

          {micError && (
            <div style={{ fontSize: 12, color: 'var(--danger)', marginBottom: 6, padding: '6px 10px', background: '#ef444418', borderRadius: 8 }}>
              {micError}
            </div>
          )}
          <div className="capture-actions" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <button
              className={recording ? 'mic-recording' : ''}
              onMouseDown={startRecording}
              onMouseUp={stopRecording}
              onMouseLeave={stopRecording}
              onTouchStart={startRecording}
              onTouchEnd={stopRecording}
              style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '7px 13px', borderRadius: 8, border: '1px solid var(--border)', fontSize: 13, color: 'var(--text-muted)', userSelect: 'none', WebkitUserSelect: 'none' }}>
              {recording ? <><MicOff size={14} /> Sprechen…</> : <><Mic size={14} /> Diktieren</>}
            </button>
            <button className="capture-save-btn" onClick={save} disabled={!content.trim() || saving}
              style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 20px', borderRadius: 10, fontWeight: 700, fontSize: 15, transition: 'all 0.15s',
                background: content.trim() ? (saveToBox?.color || 'var(--accent)') : 'var(--surface2)',
                color: content.trim() ? 'white' : 'var(--text-muted)' }}>
              <Send size={15} />
              {saving ? 'Speichert…' : 'Speichern'}
            </button>
          </div>
          {content.trim() && (
            <p style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 8 }}>
              Strg+Enter zum Speichern
            </p>
          )}
        </div>
      </div>

      {/* KI-WISSENSGENERIERUNG */}
      <div style={{ marginBottom: 28 }}>
        <button onClick={() => { setShowAiGen(v => !v); setAiPreview(null); setAiError(''); }}
          style={{ display: 'flex', alignItems: 'center', gap: 12, width: '100%', padding: '11px 16px', borderRadius: 12, border: `1px solid ${showAiGen ? 'var(--accent)' : 'var(--border)'}`, background: showAiGen ? 'var(--accent)11' : 'var(--surface)', color: showAiGen ? 'var(--accent)' : 'var(--text-muted)', fontSize: 14, fontWeight: 600, transition: 'all 0.15s', textAlign: 'left' }}>
          <Sparkles size={15} style={{ flexShrink: 0 }} />
          <span>
            <span style={{ display: 'block' }}>KI-Wissen generieren</span>
            <span style={{ display: 'block', fontSize: 12, fontWeight: 400, opacity: 0.7, marginTop: 2 }}>Thema eingeben → KI schreibt den Eintrag</span>
          </span>
        </button>

        {showAiGen && (
          <div style={{ background: 'var(--surface)', border: '1px solid var(--accent)', borderRadius: 12, padding: '18px 20px', marginTop: 6 }}>
            {aiError && (
              <div style={{ background: '#ef444411', border: '1px solid #ef444444', borderRadius: 8, padding: '8px 12px', marginBottom: 12, fontSize: 13, color: '#ef4444' }}>
                {aiError}
              </div>
            )}

            {!aiPreview ? (
              <>
                <input value={aiTopic} onChange={e => setAiTopic(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && generateWithAI()}
                  placeholder='Thema eingeben, z.B. DNS-Auflösung, Fotosynthese, Budgetplanung...'
                  autoFocus
                  style={{ width: '100%', background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: 8, padding: '10px 14px', fontSize: 14, marginBottom: 12 }} />

                <div style={{ display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap', marginBottom: 14 }}>
                  <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>Länge:</span>
                  {['kurz', 'mittel', 'ausführlich'].map(d => (
                    <button key={d} onClick={() => setAiDepth(d)}
                      style={{ padding: '4px 12px', borderRadius: 20, fontSize: 13, border: '1px solid var(--border)', fontWeight: aiDepth === d ? 700 : 400, background: aiDepth === d ? 'var(--accent)' : 'var(--surface2)', color: aiDepth === d ? 'white' : 'var(--text-muted)', transition: 'all 0.15s' }}>
                      {d === 'kurz' ? '⚡ Kurz' : d === 'mittel' ? '📄 Mittel' : '📚 Ausführlich'}
                    </button>
                  ))}

                  <span style={{ fontSize: 13, color: 'var(--text-muted)', marginLeft: 8 }}>In:</span>
                  <select value={aiGenBox?.id || ''} onChange={e => setAiGenBox(allBoxes.find(b => b.id === Number(e.target.value)) || null)}
                    style={{ padding: '4px 10px', borderRadius: 8, border: '1px solid var(--border)', background: 'var(--surface2)', color: 'var(--text)', fontSize: 13 }}>
                    <option value="">— aktive Box —</option>
                    {allBoxes.filter(b => b.parent_id).map(b => (
                      <option key={b.id} value={b.id}>{b.icon} {b.name}</option>
                    ))}
                    {allBoxes.filter(b => !b.parent_id).map(b => (
                      <option key={b.id} value={b.id}>{b.icon} {b.name} (Bereich)</option>
                    ))}
                  </select>
                </div>

                <button onClick={generateWithAI} disabled={aiLoading || !aiTopic.trim()}
                  style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 20px', borderRadius: 10, background: aiTopic.trim() ? 'var(--accent)' : 'var(--surface2)', color: aiTopic.trim() ? 'white' : 'var(--text-muted)', fontWeight: 700, fontSize: 14, transition: 'all 0.15s' }}>
                  <Sparkles size={15} /> {aiLoading ? 'KI denkt nach…' : 'Eintrag generieren'}
                </button>
              </>
            ) : (
              /* Vorschau des generierten Eintrags */
              <div>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 12 }}>
                  <span style={{ fontSize: 12, fontWeight: 700, color: 'var(--accent)', textTransform: 'uppercase', letterSpacing: '0.06em' }}>Vorschau</span>
                  {aiPreview._targetBox && (
                    <span style={{ fontSize: 12, padding: '2px 8px', borderRadius: 10, background: (aiPreview._targetBox.color || '#6366f1') + '22', color: aiPreview._targetBox.color || '#6366f1', fontWeight: 600 }}>
                      {aiPreview._targetBox.icon} {aiPreview._targetBox.name}
                    </span>
                  )}
                  {aiPreview.category && (
                    <span style={{ fontSize: 12, color: 'var(--text-muted)' }}>{aiPreview.category}</span>
                  )}
                </div>

                <div style={{ background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: 10, padding: '14px 16px', marginBottom: 12 }}>
                  <div style={{ fontWeight: 700, fontSize: 17, marginBottom: 8 }}>{aiPreview.title}</div>
                  <div style={{ fontSize: 13, color: 'var(--text-muted)', lineHeight: 1.6, whiteSpace: 'pre-wrap', maxHeight: 220, overflow: 'auto' }}>
                    {aiPreview.content}
                  </div>
                  {aiPreview.tags?.length > 0 && (
                    <div style={{ display: 'flex', gap: 5, flexWrap: 'wrap', marginTop: 10 }}>
                      {aiPreview.tags.map(t => (
                        <span key={t} style={{ fontSize: 11, padding: '2px 8px', borderRadius: 10, background: 'var(--surface)', border: '1px solid var(--border)' }}>{t}</span>
                      ))}
                    </div>
                  )}
                </div>

                <div style={{ display: 'flex', gap: 8 }}>
                  <button onClick={saveAiEntry}
                    style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 18px', borderRadius: 10, background: 'var(--accent)', color: 'white', fontWeight: 700, fontSize: 14 }}>
                    <Send size={14} /> Speichern
                  </button>
                  <button onClick={() => { setAiPreview(null); }}
                    style={{ padding: '9px 14px', borderRadius: 10, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14 }}>
                    Neu generieren
                  </button>
                  <button onClick={() => { setAiPreview(null); setAiTopic(''); setShowAiGen(false); }}
                    style={{ padding: '9px 14px', borderRadius: 10, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14 }}>
                    Abbrechen
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* BEREICH / BOX NAVIGATION — nur auf Startseite und Bereich-Ebene */}
      {!activeBox && (
        <div style={{ marginBottom: 28 }}>
          <p style={{ fontSize: 11, fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: 14 }}>
            {activeBereich ? 'Boxen in diesem Bereich' : 'Wissensbereiche'}
          </p>

          {activeBereich ? (
            /* Sub-Box-Grid innerhalb eines Bereichs */
            <DndContext sensors={dndSensors} collisionDetection={closestCenter} onDragEnd={e => handleSubBoxDragEnd(e, activeBereich.id)}>
              <SortableContext items={allBoxes.filter(b => b.parent_id === activeBereich.id).map(b => b.id)} strategy={rectSortingStrategy}>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(148px, 1fr))', gap: 10 }}>
                  {allBoxes.filter(b => b.parent_id === activeBereich.id).map(box => (
                    <SortableBoxCard key={box.id} id={box.id}>
                      {({ gripRef, gripProps }) => (
                        <BoxCard box={box}
                          selected={saveToBox?.id === box.id}
                          onSelect={() => setSaveToBox(saveToBox?.id === box.id ? null : box)}
                          onNavigate={() => navigateToBox(box, activeBereich)}
                          onDelete={deleteBox}
                          gripRef={gripRef}
                          gripProps={gripProps} />
                      )}
                    </SortableBoxCard>
                  ))}
                  <NewBoxButton onClick={() => setCreating({ parentId: activeBereich.id })} />
                  {creating?.parentId === activeBereich.id && (
                    <NewBoxForm name={newName} setName={setNewName} icon={newIcon} setIcon={setNewIcon} color={newColor} setColor={setNewColor} onCreate={createBox} onCancel={() => setCreating(null)} />
                  )}
                </div>
              </SortableContext>
            </DndContext>
          ) : (<>
            {/* Bereich-Accordion mit Drag-and-Drop */}
            <DndContext sensors={dndSensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
              <SortableContext items={tree.map(b => b.id)} strategy={verticalListSortingStrategy}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {tree.map(bereich => {
                const isExpanded = expanded.has(bereich.id);
                const isActive = activeBereich?.id === bereich.id;
                const hasChildren = bereich.children?.length > 0;
                const isSelected = !hasChildren && saveToBox?.id === bereich.id;
                return (
                  <SortableBereichItem key={bereich.id} id={bereich.id}>
                    {({ gripRef, gripProps }) => (
                  <div style={{ background: isSelected ? bereich.color + '11' : 'var(--surface)', border: `1px solid ${isActive || isSelected ? bereich.color : 'var(--border)'}`, borderRadius: 14, overflow: 'hidden', transition: 'all 0.2s', transform: isSelected ? 'translateY(-1px)' : 'none', boxShadow: isSelected ? `0 0 0 2px ${bereich.color}33` : 'none' }}>
                    {/* Bereich-Header */}
                    <div style={{ display: 'flex', alignItems: 'center', padding: '12px 16px', borderLeft: `4px solid ${bereich.color}` }}>
                      <button
                        onClick={() => handleBereichClick(bereich)}
                        onTouchStart={() => {
                          bereichLongPressed.current[bereich.id] = false;
                          bereichTouchTimers.current[bereich.id] = setTimeout(() => {
                            bereichLongPressed.current[bereich.id] = true;
                            navigateToBereich(bereich);
                          }, 600);
                        }}
                        onTouchEnd={(e) => {
                          clearTimeout(bereichTouchTimers.current[bereich.id]);
                          if (bereichLongPressed.current[bereich.id]) e.preventDefault();
                        }}
                        onContextMenu={e => e.preventDefault()}
                        style={{ display: 'flex', alignItems: 'center', gap: 10, flex: 1, textAlign: 'left', userSelect: 'none', WebkitUserSelect: 'none', WebkitTouchCallout: 'none' }}>
                        <span style={{ fontSize: 22 }}>{bereich.icon}</span>
                        <div>
                          <div style={{ fontWeight: 700, fontSize: 15 }}>{bereich.name}</div>
                          <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>
                            {isSelected ? '✓ ausgewählt' : `${bereich.card_count ?? 0} ${bereich.card_count === 1 ? 'Eintrag' : 'Einträge'}${hasChildren ? ` · ${bereich.children.length} Boxen` : ''}`}
                            <span style={{ opacity: 0.5 }}>{isMobile ? ' · Halten für Ansicht' : ' · 2× für Ansicht'}</span>
                          </div>
                        </div>
                      </button>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <button ref={gripRef} {...gripProps}
                          style={{ padding: 6, borderRadius: 6, color: 'var(--text-muted)', opacity: 0.35, cursor: 'grab', touchAction: 'none' }}
                          title="Halten und ziehen zum Sortieren"
                          onMouseEnter={e => e.currentTarget.style.opacity = '0.8'}
                          onMouseLeave={e => e.currentTarget.style.opacity = '0.35'}>
                          <GripVertical size={15} />
                        </button>
                        <button onClick={e => deleteBox(e, bereich)}
                          style={{ padding: 6, borderRadius: 6, color: 'var(--text-muted)', opacity: 0.4, transition: 'all 0.15s' }}
                          onMouseEnter={e => { e.currentTarget.style.color = 'var(--danger)'; e.currentTarget.style.opacity = '1'; }}
                          onMouseLeave={e => { e.currentTarget.style.color = 'var(--text-muted)'; e.currentTarget.style.opacity = '0.4'; }}>
                          <Trash2 size={13} />
                        </button>
                        <button onClick={e => { e.stopPropagation(); toggleExpand(bereich.id); }}
                          style={{ padding: 6, borderRadius: 6, color: 'var(--text-muted)', transition: 'transform 0.2s', transform: isExpanded ? 'rotate(90deg)' : 'none' }}>
                          <ChevronRight size={16} />
                        </button>
                      </div>
                    </div>

                    {/* Sub-Boxen — immer sichtbar wenn aufgeklappt, auch wenn leer */}
                    {isExpanded && (
                      <DndContext sensors={dndSensors} collisionDetection={closestCenter} onDragEnd={e => handleSubBoxDragEnd(e, bereich.id)}>
                        <SortableContext items={(bereich.children || []).map(b => b.id)} strategy={rectSortingStrategy}>
                          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(130px, 1fr))', gap: 8, padding: '0 12px 12px' }}>
                            {(bereich.children || []).map(box => (
                              <SortableBoxCard key={box.id} id={box.id}>
                                {({ gripRef, gripProps }) => (
                                  <BoxCard box={box} small
                                    selected={saveToBox?.id === box.id}
                                    onSelect={() => setSaveToBox(saveToBox?.id === box.id ? null : box)}
                                    onNavigate={() => navigateToBox(box, bereich)}
                                    onDelete={deleteBox}
                                    gripRef={gripRef}
                                    gripProps={gripProps} />
                                )}
                              </SortableBoxCard>
                            ))}
                            <NewBoxButton small onClick={() => setCreating({ parentId: bereich.id })} />
                            {creating?.parentId === bereich.id && (
                              <NewBoxForm name={newName} setName={setNewName} icon={newIcon} setIcon={setNewIcon} color={newColor} setColor={setNewColor} onCreate={createBox} onCancel={() => setCreating(null)} />
                            )}
                          </div>
                        </SortableContext>
                      </DndContext>
                    )}
                  </div>
                  )}
                  </SortableBereichItem>
                );
              })}
                </div>
              </SortableContext>
            </DndContext>
              {/* Neuen Bereich anlegen */}
              <div style={{ marginTop: 16 }}>
                {creating?.parentId === null ? (
                  <div style={{ background: 'var(--surface)', border: '1px solid var(--accent)', borderRadius: 12, padding: '14px 16px' }}>
                    <NewBoxForm name={newName} setName={setNewName} icon={newIcon} setIcon={setNewIcon} color={newColor} setColor={setNewColor} onCreate={createBox} onCancel={() => setCreating(null)} label="Neuer Bereich" />
                  </div>
                ) : (
                  <button onClick={() => setCreating({ parentId: null })}
                    style={{ display: 'flex', alignItems: 'center', gap: 12, width: '100%', padding: '11px 16px', borderRadius: 12, border: '1px dashed var(--border)', background: 'var(--surface)', color: 'var(--text-muted)', fontSize: 14, fontWeight: 600, transition: 'all 0.15s', textAlign: 'left' }}
                    onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--accent)'; e.currentTarget.style.color = 'var(--accent)'; e.currentTarget.style.background = 'var(--surface2)'; }}
                    onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; e.currentTarget.style.background = 'var(--surface)'; }}>
                    <Plus size={16} style={{ flexShrink: 0 }} />
                    <span>
                      <span style={{ display: 'block' }}>Neuen Bereich anlegen</span>
                      <span style={{ display: 'block', fontSize: 12, fontWeight: 400, opacity: 0.7, marginTop: 2 }}>Bereich für ein neues Wissensgebiet erstellen</span>
                    </span>
                  </button>
                )}
              </div>
          </>)}
        </div>
      )}

      {/* SUCHE + ZUFALL */}
      <div className="search-row" style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
        <div className="search-input-wrap" style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '0 12px' }}>
          <Search size={14} style={{ color: 'var(--text-muted)', flexShrink: 0 }} />
          <input value={search} onChange={e => { setSearch(e.target.value); setShowAll(false); }} placeholder="Suchen…"
            style={{ flex: 1, padding: '9px 0', fontSize: 14 }} />
          {search && <button onClick={() => setSearch('')}><X size={13} style={{ color: 'var(--text-muted)' }} /></button>}
        </div>
        <button className="search-btn" onClick={openRandom} disabled={!entries.length} title="Zufällige Notiz öffnen"
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 14px', borderRadius: 10, border: '1px solid var(--border)', background: 'var(--surface)', color: 'var(--text-muted)', fontSize: 13, fontWeight: 500, whiteSpace: 'nowrap', transition: 'all 0.15s' }}
          onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--accent)'; e.currentTarget.style.color = 'var(--accent)'; }}
          onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; }}>
          <Shuffle size={14} /> Zufall
        </button>
        <button className="search-btn" onClick={() => entries.length && onStartReview(entries)} disabled={!entries.length} title="Alle Einträge wiederholen"
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 14px', borderRadius: 10, border: '1px solid var(--border)', background: 'var(--surface)', color: 'var(--text-muted)', fontSize: 13, fontWeight: 500, whiteSpace: 'nowrap', transition: 'all 0.15s' }}
          onMouseEnter={e => { e.currentTarget.style.borderColor = '#22c55e'; e.currentTarget.style.color = '#22c55e'; }}
          onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; }}>
          <GraduationCap size={14} /> Wiederholen
        </button>
      </div>

      {/* FEED */}
      {entries.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px 0', color: 'var(--text-muted)' }}>
          {search ? 'Keine Einträge gefunden.' : 'Noch keine Einträge — fang oben an!'}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {(showAll || search ? entries : entries.slice(0, FEED_LIMIT)).map(entry => (
            <button key={entry.id} onClick={() => onOpenEntry(entry)}
              style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '13px 16px', textAlign: 'left', width: '100%', transition: 'border-color 0.15s' }}
              onMouseEnter={e => e.currentTarget.style.borderColor = entry.box_color || 'var(--accent)'}
              onMouseLeave={e => e.currentTarget.style.borderColor = 'var(--border)'}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 3 }}>{entry.title}</div>
                  {entry.content && (
                    <div style={{ color: 'var(--text-muted)', fontSize: 13, lineHeight: 1.5, overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>
                      {entry.content.replace(/\$\$?[^$]+\$\$?/g, '[Formel]')}
                    </div>
                  )}
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4, flexShrink: 0 }}>
                  <span style={{ fontSize: 12, padding: '2px 8px', borderRadius: 10, fontWeight: 600, whiteSpace: 'nowrap',
                    background: (entry.box_color || '#6366f1') + '22', color: entry.box_color || '#6366f1' }}>
                    {entry.box_icon} {entry.box_name}
                  </span>
                  <span style={{ fontSize: 11, color: 'var(--text-muted)' }}>{formatDate(entry.updated_at)}</span>
                </div>
              </div>
            </button>
          ))}
          {!search && entries.length > FEED_LIMIT && (
            <button onClick={() => setShowAll(v => !v)}
              style={{ padding: '10px', borderRadius: 10, border: '1px dashed var(--border)', color: 'var(--text-muted)', fontSize: 13, transition: 'all 0.15s' }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--accent)'; e.currentTarget.style.color = 'var(--accent)'; }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; }}>
              {showAll ? `↑ Weniger anzeigen` : `↓ Alle ${entries.length} Einträge anzeigen`}
            </button>
          )}
        </div>
      )}

      {confirmPending && (
        <ConfirmModal
          message={confirmPending.message}
          onConfirm={confirmPending.onConfirm}
          onCancel={() => setConfirmPending(null)}
        />
      )}

      <div style={{ marginTop: 40, paddingTop: 16, borderTop: '1px solid var(--border)', textAlign: 'center' }}>
        <button
          onClick={onShowImpressum}
          style={{ fontSize: 12, color: 'var(--text-muted)', background: 'none', border: 'none', cursor: 'pointer', padding: '4px 8px' }}
          onMouseEnter={e => e.currentTarget.style.color = 'var(--accent)'}
          onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}
        >
          Impressum
        </button>
      </div>
    </div>
  );
}

function BoxCard({ box, small, selected, onSelect, onNavigate, onDelete, gripRef, gripProps }) {
  const [hovered, setHovered] = useState(false);
  const touchTimer = useRef(null);
  const longPressed = useRef(false);
  const clickTimer = useRef(null);

  // Doppelklick per Timer: erster Klick wartet 380ms auf zweiten.
  // Zweiter Klick innerhalb 380ms → navigieren (ohne Layout-Shift dazwischen).
  const handleClick = () => {
    if (clickTimer.current) {
      clearTimeout(clickTimer.current);
      clickTimer.current = null;
      onNavigate();
    } else {
      clickTimer.current = setTimeout(() => {
        clickTimer.current = null;
        onSelect();
      }, 380);
    }
  };

  return (
    <div style={{ position: 'relative' }} onMouseEnter={() => setHovered(true)} onMouseLeave={() => setHovered(false)}>
      {/* Drag-Handle (nur wenn DnD aktiv) */}
      {gripRef && (
        <button ref={gripRef} {...gripProps}
          style={{ position: 'absolute', top: 5, left: 5, zIndex: 2,
            padding: 3, borderRadius: 4, color: 'var(--text-muted)',
            opacity: hovered ? 0.65 : 0.2, cursor: 'grab', touchAction: 'none', transition: 'opacity 0.15s' }}
          title="Halten zum Sortieren">
          <GripVertical size={12} />
        </button>
      )}
      <button
        onClick={handleClick}
        onTouchStart={() => {
          longPressed.current = false;
          touchTimer.current = setTimeout(() => { longPressed.current = true; onNavigate(); }, 600);
        }}
        onTouchEnd={(e) => {
          clearTimeout(touchTimer.current);
          if (longPressed.current) e.preventDefault();
        }}
        onContextMenu={e => e.preventDefault()}
        style={{ userSelect: 'none', width: '100%', textAlign: 'left', transition: 'all 0.15s',
          borderRadius: 10, padding: small ? '10px 12px' : '14px 16px',
          borderTop: `3px solid ${box.color}`,
          borderLeft: `1px solid ${selected ? box.color : 'var(--border)'}`,
          borderRight: `1px solid ${selected ? box.color : 'var(--border)'}`,
          borderBottom: `1px solid ${selected ? box.color : 'var(--border)'}`,
          background: selected ? box.color + '22' : hovered ? 'var(--surface)' : 'var(--surface2)',
          transform: selected ? 'translateY(-2px)' : hovered ? 'translateY(-1px)' : '',
          boxShadow: selected ? `0 0 0 2px ${box.color}44` : 'none' }}>
        <div style={{ fontSize: small ? 18 : 22, marginBottom: 4 }}>{box.icon}</div>
        <div style={{ fontWeight: 600, fontSize: small ? 13 : 14, paddingRight: 16 }}>{box.name}</div>
        <div style={{ fontSize: 11, color: 'var(--text-muted)', marginTop: 2 }}>
          {selected ? '✓ ausgewählt' : `${box.card_count ?? 0} Einträge`}
        </div>
      </button>
      {/* Löschen-Button (nur beim Hovern) */}
      {hovered && (
        <button onClick={e => onDelete(e, box)} title="Löschen"
          style={{ position: 'absolute', top: 6, right: 6, zIndex: 2, padding: 3, borderRadius: 5, color: 'var(--text-muted)' }}
          onMouseEnter={e => e.currentTarget.style.color = 'var(--danger)'}
          onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}>
          <Trash2 size={11} />
        </button>
      )}
      {/* Öffnen-Button — immer sichtbar, beim Hovern hervorgehoben */}
      <button
        onClick={e => { e.stopPropagation(); onNavigate(); }}
        title="Box öffnen"
        style={{ position: 'absolute', bottom: 6, right: 6, zIndex: 2,
          padding: '2px 7px', borderRadius: 6, display: 'flex', alignItems: 'center', gap: 2,
          background: box.color + '22', color: box.color, border: `1px solid ${box.color}44`,
          fontSize: 11, fontWeight: 600,
          opacity: hovered ? 1 : 0.45, transition: 'opacity 0.15s' }}>
        <ChevronRight size={11} />
      </button>
    </div>
  );
}

function NewBoxButton({ small, onClick }) {
  return (
    <button onClick={onClick}
      style={{ background: 'none', border: '1px dashed var(--border)', borderRadius: 10, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 5, color: 'var(--text-muted)', minHeight: small ? 80 : 100, transition: 'all 0.15s', fontSize: 13 }}
      onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--accent)'; e.currentTarget.style.color = 'var(--accent)'; }}
      onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; }}>
      <Plus size={18} /> Box
    </button>
  );
}

function NewBoxForm({ name, setName, icon, setIcon, color, setColor, onCreate, onCancel, label = 'Box erstellen' }) {
  return (
    <div style={{ background: 'var(--surface2)', border: '1px solid var(--accent)', borderRadius: 10, padding: '12px' }}>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 3, marginBottom: 8, maxHeight: 96, overflowY: 'auto' }}>
        {EMOJIS.map(em => (
          <button key={em} onClick={() => setIcon(em)}
            style={{ fontSize: 16, padding: 2, borderRadius: 5, background: icon === em ? 'var(--surface)' : 'none', border: icon === em ? '1px solid var(--accent)' : '1px solid transparent' }}>
            {em}
          </button>
        ))}
      </div>
      <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap', marginBottom: 8 }}>
        {AUTO_COLORS.map(c => (
          <button key={c} onClick={() => setColor(c)}
            style={{ width: 18, height: 18, borderRadius: '50%', background: c, border: color === c ? '2px solid white' : '2px solid transparent', outline: color === c ? `2px solid ${c}` : 'none' }} />
        ))}
      </div>
      <input value={name} onChange={e => setName(e.target.value)}
        onKeyDown={e => { if (e.key === 'Enter') onCreate(); if (e.key === 'Escape') onCancel(); }}
        placeholder="Name…" autoFocus
        style={{ width: '100%', background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 7, padding: '6px 9px', fontSize: 13, marginBottom: 8 }} />
      <div style={{ display: 'flex', gap: 6 }}>
        <button onClick={onCreate} style={{ flex: 1, padding: '6px', borderRadius: 7, background: 'var(--accent)', color: 'white', fontSize: 13, fontWeight: 600 }}>{label}</button>
        <button onClick={onCancel} style={{ padding: '6px 10px', borderRadius: 7, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>✕</button>
      </div>
    </div>
  );
}
