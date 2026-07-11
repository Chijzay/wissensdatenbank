import { useState, useRef, useEffect } from 'react';
import { ArrowLeft, Mic, MicOff, Sparkles, Link2, Trash2, Brain, Plus, X, Info, ChevronDown, ChevronUp, Tag, Folder, Eye, PencilLine } from 'lucide-react';
import { api } from '../api/client.js';
import ContentRenderer from './ContentRenderer.jsx';
import ConfirmModal from './ConfirmModal.jsx';

function applyFormat(ta, value, onChange, type) {
  const start = ta.selectionStart;
  const end = ta.selectionEnd;
  const before = value.slice(0, start);
  const selected = value.slice(start, end);
  const after = value.slice(end);

  const wrap = (pre, suf, def = '') => {
    const inner = selected || def;
    const newVal = before + pre + inner + suf + after;
    onChange(newVal);
    setTimeout(() => {
      ta.focus();
      ta.setSelectionRange(before.length + pre.length, before.length + pre.length + inner.length);
    }, 0);
  };

  const prefixLines = (prefix) => {
    const lineStart = before.lastIndexOf('\n') + 1;
    const afterFromEnd = value.indexOf('\n', end);
    const lineEnd = afterFromEnd === -1 ? value.length : afterFromEnd;
    const block = value.slice(lineStart, lineEnd);
    const lines = block.split('\n');
    const allPrefixed = lines.every(l => l.startsWith(prefix));
    const newBlock = lines.map(l => allPrefixed ? l.slice(prefix.length) : prefix + l).join('\n');
    const newVal = value.slice(0, lineStart) + newBlock + value.slice(lineEnd);
    onChange(newVal);
    setTimeout(() => { ta.focus(); ta.setSelectionRange(lineStart, lineStart + newBlock.length); }, 0);
  };

  switch (type) {
    case 'bold':      return wrap('**', '**', 'Fett');
    case 'italic':    return wrap('*', '*', 'Kursiv');
    case 'underline': return wrap('<u>', '</u>', 'Unterstrichen');
    case 'h1':        return prefixLines('# ');
    case 'h2':        return prefixLines('## ');
    case 'h3':        return prefixLines('### ');
    case 'center':    return wrap('<div style="text-align:center">', '</div>', 'Zentriert');
    case 'right':     return wrap('<div style="text-align:right">', '</div>', 'Rechtsbündig');
    case 'ul':        return prefixLines('- ');
    case 'ol':        return prefixLines('1. ');
    case 'bigger':    return wrap('<big>', '</big>', 'Größer');
    case 'smaller':   return wrap('<small>', '</small>', 'Kleiner');
    case 'code':      return selected.includes('\n') ? wrap('```\n', '\n```', 'Code') : wrap('`', '`', 'code');
  }
}

function FormattingToolbar({ taRef, value, onChange }) {
  const f = (type) => { if (taRef.current) applyFormat(taRef.current, value, onChange, type); };
  return (
    <div className="fmt-toolbar">
      <button onClick={() => f('bold')} title="Fett"><b>B</b></button>
      <button onClick={() => f('italic')} title="Kursiv"><i>I</i></button>
      <button onClick={() => f('underline')} title="Unterstrichen"><u>U</u></button>
      <div className="fmt-sep" />
      <button onClick={() => f('h1')} title="Überschrift 1" style={{ fontSize: 13 }}>H1</button>
      <button onClick={() => f('h2')} title="Überschrift 2" style={{ fontSize: 12 }}>H2</button>
      <button onClick={() => f('h3')} title="Überschrift 3" style={{ fontSize: 11 }}>H3</button>
      <div className="fmt-sep" />
      <button onClick={() => f('center')} title="Zentriert" style={{ fontSize: 14 }}>≡</button>
      <button onClick={() => f('right')} title="Rechtsbündig" style={{ fontSize: 14 }}>⇥</button>
      <div className="fmt-sep" />
      <button onClick={() => f('ul')} title="Aufzählung">• —</button>
      <button onClick={() => f('ol')} title="Nummerierte Liste">1. —</button>
      <div className="fmt-sep" />
      <button onClick={() => f('bigger')} title="Größer">A⁺</button>
      <button onClick={() => f('smaller')} title="Kleiner">A⁻</button>
      <div className="fmt-sep" />
      <button onClick={() => f('code')} title="Code" style={{ fontFamily: 'monospace' }}>&lt;/&gt;</button>
    </div>
  );
}

function parseAiError(err) {
  const msg = err?.message || '';
  if (msg.includes('credit balance') || msg.includes('credits')) {
    return 'Kein Guthaben — bitte unter console.anthropic.com/settings/billing aufladen.';
  }
  if (msg.includes('HIER_DEINEN') || msg.includes('invalid x-api-key') || msg.includes('authentication')) {
    return 'Kein gültiger API-Key — bitte in backend/.env eintragen.';
  }
  return 'KI-Fehler: ' + (msg.slice(0, 120) || 'Unbekannter Fehler');
}

export default function EntryDetail({ entry, onClose, onStartQuiz, onNavigate }) {
  const [title, setTitle] = useState(entry.title || '');
  const [content, setContent] = useState(entry.content || '');
  const [tags, setTags] = useState([]);
  const [tagInput, setTagInput] = useState('');
  const [category, setCategory] = useState(entry.category || '');
  const [questions, setQuestions] = useState([]);
  const [links, setLinks] = useState([]);
  const [linkSuggestions, setLinkSuggestions] = useState([]);
  const [topics, setTopics] = useState([]);
  const [currentTopic, setCurrentTopic] = useState({ id: entry.box_id, name: entry.box_name, color: entry.box_color });
  const [showTopicPicker, setShowTopicPicker] = useState(false);
  const [recording, setRecording] = useState(false);
  const [aiLoading, setAiLoading] = useState(false);
  const [categoryLoading, setCategoryLoading] = useState(false);
  const [linkLoading, setLinkLoading] = useState(false);
  const [tagsLoading, setTagsLoading] = useState(false);
  const [showKI, setShowKI] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [showMeta, setShowMeta] = useState(false);
  const [saved, setSaved] = useState(true);
  const [error, setError] = useState('');
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [fontSize, setFontSize] = useState(() => parseInt(localStorage.getItem('cr-font-size') || '13'));
  const recognitionRef = useRef(null);
  const taRef = useRef(null);

  const changeFontSize = (delta) => {
    const s = Math.min(22, Math.max(10, fontSize + delta));
    setFontSize(s);
    localStorage.setItem('cr-font-size', s);
  };

  // Vollständigen Eintrag + Themen laden
  useEffect(() => {
    api.cards.get(entry.id).then(full => {
      setTags(full.tags || []);
      setQuestions(full.questions || []);
      setLinks(full.links || []);
      setCategory(full.category || '');
    }).catch(() => {});
    api.boxes.list().then(setTopics).catch(() => {});
  }, [entry.id]);

  const save = async () => {
    try {
      await api.cards.update(entry.id, {
        title, content, tags,
        category,
        box_id: currentTopic.id
      });
      setSaved(true);
      setError('');
    } catch {
      setError('Speichern fehlgeschlagen — Backend läuft?');
    }
  };

  const del = () => setConfirmDelete(true);

  const confirmAndDelete = async () => {
    setConfirmDelete(false);
    try {
      await api.cards.delete(entry.id);
      onClose();
    } catch {
      setError('Löschen fehlgeschlagen.');
    }
  };

  const generateQuestions = async () => {
    setAiLoading(true);
    try {
      const { questions: qs } = await api.ai.generateQuestions({ card_id: entry.id, title, content });
      setQuestions(qs);
    } catch (err) { setError(parseAiError(err)); }
    finally { setAiLoading(false); }
  };

  const suggestLinks = async () => {
    setLinkLoading(true);
    try {
      const { suggestions } = await api.ai.suggestLinks({ card_id: entry.id, box_id: currentTopic.id, title, content });
      setLinkSuggestions(suggestions.filter(s => !links.find(l => l.id === s.id)));
    } catch (err) { setError(parseAiError(err)); }
    finally { setLinkLoading(false); }
  };

  const addLink = async (s) => {
    await api.cards.link(entry.id, s.id);
    setLinks(prev => [...prev, s]);
    setLinkSuggestions(prev => prev.filter(x => x.id !== s.id));
  };

  const removeLink = async (linkedId) => {
    await api.cards.unlink(entry.id, linkedId);
    setLinks(prev => prev.filter(l => l.id !== linkedId));
  };

  const navigateToLinkedCard = async (link) => {
    if (!onNavigate) return;
    try {
      const card = await api.cards.get(link.id);
      const box = topics.find(t => t.id === card.box_id) || {};
      onNavigate({ ...card, box_name: box.name || '', box_color: box.color || '', box_icon: box.icon || '', box_parent_id: box.parent_id || null });
    } catch {}
  };

  const suggestCategory = async () => {
    setCategoryLoading(true);
    try {
      const { category: cat } = await api.ai.suggestCategory({ title, content });
      setCategory(cat);
      setSaved(false);
    } catch (err) { setError(parseAiError(err)); }
    finally { setCategoryLoading(false); }
  };

  const suggestTagsAI = async () => {
    setTagsLoading(true);
    try {
      const { tags: suggested } = await api.ai.suggestTags({ title, content });
      const toAdd = suggested.filter(t => !tags.includes(t));
      if (toAdd.length) {
        const newTags = [...tags, ...toAdd];
        setTags(newTags);
        await api.cards.update(entry.id, { title, content, tags: newTags, category, box_id: currentTopic.id });
        setSaved(true);
      }
    } catch (err) { setError(parseAiError(err)); }
    finally { setTagsLoading(false); }
  };

  const addTag = () => {
    const t = tagInput.trim();
    if (t && !tags.includes(t)) { setTags(prev => [...prev, t]); setSaved(false); }
    setTagInput('');
  };

  const toggleRecording = () => {
    if (!('webkitSpeechRecognition' in window || 'SpeechRecognition' in window)) {
      setError('Spracherkennung nur in Chrome/Edge verfügbar — nicht im eingebetteten Vorschaufenster');
      return;
    }
    if (recording) { recognitionRef.current?.stop(); setRecording(false); return; }
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
    const rec = new SR();
    rec.lang = 'de-DE'; rec.continuous = true; rec.interimResults = false;
    rec.onresult = (e) => {
      const t = Array.from(e.results).map(r => r[0].transcript).join(' ');
      setContent(prev => prev ? prev + ' ' + t : t);
      setSaved(false);
    };
    rec.onerror = () => setError('Mikrofon-Zugriff verweigert.');
    rec.onend = () => setRecording(false);
    rec.start(); recognitionRef.current = rec; setRecording(true);
  };

  const handleClose = async () => {
    if (!saved) await save();
    onClose();
  };

  return (
    <div style={{ maxWidth: 760, margin: '0 auto', padding: '24px 20px' }}>

      {/* Top-Bar */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 24 }}>
        <button onClick={handleClose}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '7px 14px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14, fontWeight: 500 }}>
          <ArrowLeft size={15} /> Zurück
        </button>
        <div style={{ flex: 1 }} />
        <div style={{ display: 'flex', alignItems: 'center', border: '1px solid var(--border)', borderRadius: 8, overflow: 'hidden' }}>
          <button onClick={() => changeFontSize(-1)} title="Kleiner"
            style={{ padding: '7px 10px', color: 'var(--text-muted)', fontSize: 13, fontWeight: 700, borderRight: '1px solid var(--border)' }}>A−</button>
          <button onClick={() => changeFontSize(1)} title="Größer"
            style={{ padding: '7px 10px', color: 'var(--text-muted)', fontSize: 15, fontWeight: 700 }}>A+</button>
        </div>
        <button onClick={() => setShowMeta(m => !m)}
          style={{ padding: 8, borderRadius: 8, border: '1px solid var(--border)', color: showMeta ? 'var(--accent)' : 'var(--text-muted)' }}>
          <Info size={15} />
        </button>
        <button onClick={del}
          style={{ padding: 8, borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)' }}
          onMouseEnter={e => e.currentTarget.style.color = 'var(--danger)'}
          onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}>
          <Trash2 size={15} />
        </button>
      </div>

      {/* Fehlermeldung */}
      {error && (
        <div style={{ background: '#ef444411', border: '1px solid #ef444444', borderRadius: 8, padding: '10px 14px', marginBottom: 16, fontSize: 13, color: '#ef4444', display: 'flex', justifyContent: 'space-between' }}>
          {error}
          <button onClick={() => setError('')}><X size={13} /></button>
        </div>
      )}

      {/* Metadaten */}
      {showMeta && (
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '12px 16px', marginBottom: 16, fontSize: 13, color: 'var(--text-muted)', display: 'flex', gap: 24, flexWrap: 'wrap' }}>
          <span>Erstellt: {new Date(entry.created_at).toLocaleString('de-DE')}</span>
          <span>Geändert: {new Date(entry.updated_at).toLocaleString('de-DE')}</span>
        </div>
      )}

      {/* Titel */}
      <input value={title} onChange={e => { setTitle(e.target.value); setSaved(false); }}
        style={{ width: '100%', fontSize: 26, fontWeight: 700, letterSpacing: '-0.3px', marginBottom: 16, background: 'transparent', borderBottom: '2px solid var(--border)', paddingBottom: 12 }}
        placeholder="Titel…" />

      {/* Inhalt: Lesen oder Bearbeiten */}
      <div style={{ marginBottom: 20 }}>
        {editMode ? (
          <div>
            <FormattingToolbar taRef={taRef} value={content}
              onChange={v => { setContent(v); setSaved(false); }} />
            <div style={{ position: 'relative' }}>
              <textarea ref={taRef} value={content}
                onChange={e => { setContent(e.target.value); setSaved(false); }}
                placeholder={'Inhalt… Markdown: **fett**, *kursiv*, # H1\nLaTeX: $E=mc^2$ oder $$\\int f\\,dx$$'} rows={14} autoFocus
                style={{ width: '100%', background: 'var(--surface)', border: '1px solid var(--accent)', borderTop: 'none', borderRadius: '0 0 12px 12px', padding: '14px 16px 48px', fontSize: 15, lineHeight: 1.75 }} />
              <button onClick={toggleRecording}
                style={{ position: 'absolute', bottom: 12, right: 12, padding: '6px 10px', borderRadius: 7, background: recording ? '#ef444422' : 'var(--surface2)', color: recording ? 'var(--danger)' : 'var(--text-muted)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 5, fontSize: 12 }}>
                {recording ? <><MicOff size={13} /> Stopp</> : <><Mic size={13} /> Diktieren</>}
              </button>
            </div>
          </div>
        ) : (
          <div onClick={() => setEditMode(true)}
            style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '14px 16px', minHeight: 120, cursor: 'text' }}
            title="Klicken zum Bearbeiten">
            {content ? (
              <ContentRenderer text={content} style={{ fontSize }} />
            ) : (
              <span style={{ color: 'var(--text-muted)', fontSize: 14 }}>Klicken zum Schreiben…</span>
            )}
          </div>
        )}
      </div>

      {/* Bearbeiten / Speichern */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 28 }}>
        {editMode ? (
          <>
            <button onClick={() => { save(); setEditMode(false); }}
              style={{ padding: '8px 18px', borderRadius: 8, background: 'var(--accent)', color: 'white', fontSize: 14, fontWeight: 600 }}>
              Speichern
            </button>
            <button onClick={() => setEditMode(false)}
              style={{ padding: '8px 14px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14 }}>
              Vorschau
            </button>
          </>
        ) : (
          <button onClick={() => setEditMode(true)}
            style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 16px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14 }}>
            <PencilLine size={14} /> Bearbeiten
            {!saved && <span style={{ color: 'var(--accent)', fontSize: 12 }}>· ungespeichert</span>}
          </button>
        )}
      </div>

      {/* ── EINORDNEN ── */}
      <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 14, padding: '18px 20px', marginBottom: 16 }}>
        <p style={{ fontSize: 11, fontWeight: 700, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.08em', marginBottom: 16 }}>Einordnen</p>

        {/* Thema */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <Folder size={14} style={{ color: 'var(--text-muted)', flexShrink: 0 }} />
          <span style={{ fontSize: 13, color: 'var(--text-muted)', width: 70, flexShrink: 0 }}>Box</span>
          <div style={{ position: 'relative' }}>
            <button onClick={() => setShowTopicPicker(p => !p)}
              style={{ padding: '4px 12px', borderRadius: 20, fontSize: 13, fontWeight: 600, background: (currentTopic.color || '#6366f1') + '22', color: currentTopic.color || '#6366f1', border: `1px solid ${currentTopic.color || '#6366f1'}44` }}>
              {currentTopic.name || 'Kein Thema'} ▾
            </button>
            {showTopicPicker && (
              <div style={{ position: 'absolute', top: '110%', left: 0, background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: 10, padding: 8, zIndex: 10, minWidth: 160, boxShadow: '0 8px 24px #00000044' }}>
                {topics.map(t => (
                  <button key={t.id} onClick={() => { setCurrentTopic(t); setShowTopicPicker(false); setSaved(false); }}
                    style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%', padding: '7px 10px', borderRadius: 7, fontSize: 13, textAlign: 'left', background: currentTopic.id === t.id ? 'var(--surface)' : 'none' }}>
                    <span style={{ width: 10, height: 10, borderRadius: '50%', background: t.color, flexShrink: 0 }} />
                    {t.name}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Kategorie */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <Folder size={14} style={{ color: 'var(--text-muted)', flexShrink: 0, opacity: 0 }} />
          <span style={{ fontSize: 13, color: 'var(--text-muted)', width: 70, flexShrink: 0 }}>Kategorie</span>
          <input value={category} onChange={e => { setCategory(e.target.value); setSaved(false); }}
            placeholder="z.B. Botanik, Rezept…"
            style={{ fontSize: 13, background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: 8, padding: '4px 10px', color: 'var(--text)', flex: 1 }} />
          <button onClick={suggestCategory} disabled={categoryLoading || !content.trim()}
            title="KI-Vorschlag"
            style={{ padding: '4px 8px', borderRadius: 7, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13, opacity: !content.trim() ? 0.4 : 1, flexShrink: 0 }}>
            {categoryLoading ? '…' : '✨'}
          </button>
        </div>

        {/* Tags */}
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
          <Tag size={14} style={{ color: 'var(--text-muted)', flexShrink: 0, marginTop: 6 }} />
          <span style={{ fontSize: 13, color: 'var(--text-muted)', width: 70, flexShrink: 0, marginTop: 5 }}>Tags</span>
          <div style={{ flex: 1 }}>
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginBottom: 8 }}>
              {tags.map(t => (
                <span key={t} style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '3px 10px', borderRadius: 20, fontSize: 12, background: 'var(--surface2)', border: '1px solid var(--border)' }}>
                  {t} <button onClick={() => { setTags(prev => prev.filter(x => x !== t)); setSaved(false); }} style={{ lineHeight: 1 }}><X size={10} /></button>
                </span>
              ))}
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, background: 'var(--surface2)', border: '1px solid var(--border)', borderRadius: 20, padding: '3px 10px' }}>
                <input value={tagInput} onChange={e => setTagInput(e.target.value)}
                  onKeyDown={e => { if (e.key === 'Enter' || e.key === ',') { e.preventDefault(); addTag(); } }}
                  placeholder="Tag…" style={{ fontSize: 12, width: 80 }} />
                <button onClick={addTag}><Plus size={11} style={{ color: 'var(--text-muted)' }} /></button>
              </div>
              <button onClick={suggestTagsAI} disabled={tagsLoading || !content.trim()} title="KI-Tags vorschlagen"
                style={{ padding: '3px 9px', borderRadius: 20, fontSize: 12, border: '1px solid var(--border)', color: 'var(--text-muted)', opacity: !content.trim() ? 0.4 : 1, display: 'flex', alignItems: 'center', gap: 4 }}>
                {tagsLoading ? '…' : '✨ Vorschlagen'}
              </button>
            </div>
          </div>
        </div>

        {/* Verknüpfungen */}
        {links.length > 0 && (
          <div style={{ marginTop: 14, paddingTop: 14, borderTop: '1px solid var(--border)' }}>
            <p style={{ fontSize: 12, color: 'var(--text-muted)', marginBottom: 8 }}>Verknüpfte Einträge</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
              {links.map(l => (
                <div key={l.id} style={{ display: 'flex', alignItems: 'center', background: 'var(--surface2)', borderRadius: 8, overflow: 'hidden' }}>
                  <button
                    onClick={() => navigateToLinkedCard(l)}
                    title="Karte öffnen"
                    style={{ flex: 1, textAlign: 'left', padding: '8px 10px', fontSize: 13, display: 'flex', alignItems: 'center', gap: 7, transition: 'background 0.15s' }}
                    onMouseEnter={e => e.currentTarget.style.background = 'var(--surface)'}
                    onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
                    <Link2 size={12} style={{ color: 'var(--accent)', flexShrink: 0 }} />
                    <span style={{ fontWeight: 500 }}>{l.title}</span>
                    <ChevronDown size={11} style={{ color: 'var(--text-muted)', marginLeft: 'auto', transform: 'rotate(-90deg)', flexShrink: 0 }} />
                  </button>
                  <button onClick={() => removeLink(l.id)} title="Verknüpfung entfernen"
                    style={{ padding: '8px 10px', color: 'var(--text-muted)', borderLeft: '1px solid var(--border)', flexShrink: 0 }}
                    onMouseEnter={e => e.currentTarget.style.color = 'var(--danger)'}
                    onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}>
                    <X size={12} />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
        {linkSuggestions.length > 0 && (
          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 5 }}>
            {linkSuggestions.map(s => (
              <div key={s.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '6px 10px', background: 'var(--surface2)', borderRadius: 8, border: '1px dashed var(--border)' }}>
                <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>💡 {s.title}</span>
                <button onClick={() => addLink(s)} style={{ fontSize: 12, padding: '3px 10px', borderRadius: 6, background: 'var(--accent)', color: 'white' }}>Verknüpfen</button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* ── KI-FUNKTIONEN ── einklappbar */}
      <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 14, overflow: 'hidden' }}>
        <button onClick={() => setShowKI(k => !k)}
          style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%', padding: '14px 20px', fontSize: 14, color: 'var(--text-muted)' }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <Sparkles size={15} /> KI-Funktionen
          </span>
          {showKI ? <ChevronUp size={15} /> : <ChevronDown size={15} />}
        </button>

        {showKI && (
          <div style={{ padding: '0 20px 18px', borderTop: '1px solid var(--border)' }}>
            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 14, marginBottom: questions.length > 0 ? 14 : 0 }}>
              <button onClick={generateQuestions} disabled={aiLoading || !content.trim()}
                style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13, opacity: !content.trim() ? 0.5 : 1 }}>
                <Sparkles size={14} /> {aiLoading ? 'Generiere…' : 'Lernfragen generieren'}
              </button>
              {questions.length > 0 && (
                <button onClick={() => onStartQuiz({ ...entry, title, content, questions })}
                  style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
                  <Brain size={14} /> Quiz starten ({questions.length} Fragen)
                </button>
              )}
              <button onClick={suggestLinks} disabled={linkLoading || !content.trim()}
                style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13, opacity: !content.trim() ? 0.5 : 1 }}>
                <Link2 size={14} /> {linkLoading ? 'Suche…' : 'Verknüpfungen vorschlagen'}
              </button>
            </div>

            {questions.length > 0 && (
              <div style={{ background: 'var(--surface2)', borderRadius: 10, padding: '12px 14px' }}>
                <p style={{ fontSize: 12, color: 'var(--text-muted)', marginBottom: 8 }}>Lernfragen</p>
                <ol style={{ paddingLeft: 18, display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {questions.map((q, i) => <li key={i} style={{ fontSize: 14 }}>{q}</li>)}
                </ol>
              </div>
            )}
          </div>
        )}
      </div>
      {confirmDelete && (
        <ConfirmModal
          message={`Eintrag „${title}" unwiderruflich löschen?`}
          onConfirm={confirmAndDelete}
          onCancel={() => setConfirmDelete(false)}
        />
      )}
    </div>
  );
}
