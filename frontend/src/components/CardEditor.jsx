import { useState, useRef } from 'react';
import { ArrowLeft, Mic, MicOff, Sparkles, Link, Trash2, Brain, Plus, X, Info } from 'lucide-react';
import { api } from '../api/client.js';
import ConfirmModal from './ConfirmModal.jsx';

export default function CardEditor({ card, box, onClose, onStartQuiz }) {
  const isNew = !card;
  const [title, setTitle] = useState(card?.title || '');
  const [content, setContent] = useState(card?.content || '');
  const [tags, setTags] = useState(card?.tags || []);
  const [tagInput, setTagInput] = useState('');
  const [category, setCategory] = useState(card?.category || '');
  const [questions, setQuestions] = useState(card?.questions || []);
  const [links, setLinks] = useState(card?.links || []);
  const [linkSuggestions, setLinkSuggestions] = useState([]);
  const [recording, setRecording] = useState(false);
  const [aiLoading, setAiLoading] = useState(false);
  const [linkLoading, setLinkLoading] = useState(false);
  const [showMeta, setShowMeta] = useState(false);
  const [saved, setSaved] = useState(!isNew);
  const [currentCardId, setCurrentCardId] = useState(card?.id || null);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const recognitionRef = useRef(null);

  const save = async () => {
    if (!title.trim()) return;
    if (isNew || !currentCardId) {
      const created = await api.cards.create({ box_id: box.id, title, content, tags, category });
      setCurrentCardId(created.id);
      setSaved(true);
      return created;
    } else {
      await api.cards.update(currentCardId, { title, content, tags, category });
      setSaved(true);
    }
  };

  const generateQuestions = async () => {
    setAiLoading(true);
    try {
      let id = currentCardId;
      if (!id) { const c = await save(); id = c?.id; }
      const { questions: qs } = await api.ai.generateQuestions({ card_id: id, title, content });
      setQuestions(qs);
    } finally { setAiLoading(false); }
  };

  const suggestLinks = async () => {
    setLinkLoading(true);
    try {
      let id = currentCardId;
      if (!id) { const c = await save(); id = c?.id; }
      const { suggestions } = await api.ai.suggestLinks({ card_id: id, box_id: box.id, title, content });
      setLinkSuggestions(suggestions.filter(s => !links.find(l => l.id === s.id)));
    } finally { setLinkLoading(false); }
  };

  const addLink = async (suggestion) => {
    if (!currentCardId) return;
    await api.cards.link(currentCardId, suggestion.id);
    setLinks(prev => [...prev, suggestion]);
    setLinkSuggestions(prev => prev.filter(s => s.id !== suggestion.id));
  };

  const removeLink = async (linkedId) => {
    await api.cards.unlink(currentCardId, linkedId);
    setLinks(prev => prev.filter(l => l.id !== linkedId));
  };

  const deleteCard = () => {
    if (!currentCardId) { onClose(); return; }
    setConfirmDelete(true);
  };

  const toggleRecording = () => {
    if (!('webkitSpeechRecognition' in window || 'SpeechRecognition' in window)) {
      alert('Spracherkennung nicht verfügbar (nur Chrome/Edge)');
      return;
    }
    if (recording) {
      recognitionRef.current?.stop();
      setRecording(false);
      return;
    }
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
    const rec = new SR();
    rec.lang = 'de-DE';
    rec.continuous = true;
    rec.interimResults = false;
    rec.onresult = (e) => {
      const transcript = Array.from(e.results).map(r => r[0].transcript).join(' ');
      setContent(prev => prev ? prev + ' ' + transcript : transcript);
      setSaved(false);
    };
    rec.onend = () => setRecording(false);
    rec.start();
    recognitionRef.current = rec;
    setRecording(true);
  };

  const addTag = () => {
    const t = tagInput.trim();
    if (t && !tags.includes(t)) { setTags(prev => [...prev, t]); setSaved(false); }
    setTagInput('');
  };

  const handleClose = async () => {
    if (!saved && (title.trim() || content.trim())) await save();
    onClose();
  };

  return (
    <div style={{ maxWidth: 780, margin: '0 auto', padding: '32px 24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 28 }}>
        <button onClick={handleClose} style={{ color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 6, padding: '8px 12px', borderRadius: 8, border: '1px solid var(--border)' }}>
          <ArrowLeft size={16} /> {box.icon} {box.name}
        </button>
        <div style={{ flex: 1 }} />
        {card && (
          <button onClick={() => setShowMeta(m => !m)} title="Metadaten"
            style={{ color: 'var(--text-muted)', padding: 8, borderRadius: 8, border: '1px solid var(--border)' }}>
            <Info size={16} />
          </button>
        )}
        {onStartQuiz && currentCardId && (
          <button onClick={onStartQuiz}
            style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontWeight: 500 }}>
            <Brain size={16} /> Quiz
          </button>
        )}
        <button onClick={deleteCard} style={{ color: 'var(--text-muted)', padding: 8, borderRadius: 8, border: '1px solid var(--border)' }}
          onMouseEnter={e => e.currentTarget.style.color = 'var(--danger)'}
          onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}>
          <Trash2 size={16} />
        </button>
      </div>

      {showMeta && card && (
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '14px 18px', marginBottom: 20, fontSize: 13, color: 'var(--text-muted)', display: 'flex', gap: 24 }}>
          <span>Erstellt: {new Date(card.created_at).toLocaleString('de-DE')}</span>
          <span>Geändert: {new Date(card.updated_at).toLocaleString('de-DE')}</span>
          {category && <span>Kategorie: {category}</span>}
        </div>
      )}

      <input value={title} onChange={e => { setTitle(e.target.value); setSaved(false); }}
        placeholder="Titel der Karte…"
        style={{ width: '100%', fontSize: 26, fontWeight: 700, marginBottom: 20, letterSpacing: '-0.3px', background: 'transparent', borderBottom: '1px solid var(--border)', paddingBottom: 12 }} />

      <div style={{ position: 'relative' }}>
        <textarea value={content} onChange={e => { setContent(e.target.value); setSaved(false); }}
          placeholder="Inhalt eingeben… oder per Mikrofon sprechen"
          rows={10}
          style={{ width: '100%', background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '16px', fontSize: 15, lineHeight: 1.7 }} />
        <button onClick={toggleRecording}
          title={recording ? 'Aufnahme stoppen' : 'Spracherkennung starten'}
          style={{ position: 'absolute', bottom: 12, right: 12, padding: '8px', borderRadius: 8, background: recording ? '#ef444422' : 'var(--surface2)', color: recording ? 'var(--danger)' : 'var(--text-muted)', border: '1px solid var(--border)' }}>
          {recording ? <MicOff size={16} /> : <Mic size={16} />}
        </button>
      </div>

      <div style={{ display: 'flex', gap: 8, marginTop: 16, flexWrap: 'wrap', alignItems: 'center' }}>
        {tags.map(t => (
          <span key={t} style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 10px', borderRadius: 20, fontSize: 13, background: 'var(--surface2)', border: '1px solid var(--border)' }}>
            {t}
            <button onClick={() => { setTags(prev => prev.filter(x => x !== t)); setSaved(false); }}><X size={11} /></button>
          </span>
        ))}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 20, padding: '4px 10px' }}>
          <input value={tagInput} onChange={e => setTagInput(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' || e.key === ',') { e.preventDefault(); addTag(); } }}
            placeholder="Tag hinzufügen…"
            style={{ fontSize: 13, width: 120 }} />
          <button onClick={addTag}><Plus size={13} style={{ color: 'var(--text-muted)' }} /></button>
        </div>
        <input value={category} onChange={e => { setCategory(e.target.value); setSaved(false); }}
          placeholder="Kategorie"
          style={{ fontSize: 13, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 20, padding: '4px 12px', color: 'var(--text-muted)', width: 130 }} />
      </div>

      <div style={{ display: 'flex', gap: 10, marginTop: 24, flexWrap: 'wrap' }}>
        <button onClick={save}
          style={{ padding: '9px 20px', borderRadius: 8, background: saved ? 'var(--surface2)' : 'var(--accent)', color: saved ? 'var(--text-muted)' : 'white', fontSize: 14, fontWeight: 500, transition: 'background 0.2s' }}>
          {saved ? 'Gespeichert ✓' : 'Speichern'}
        </button>
        <button onClick={generateQuestions} disabled={aiLoading || !content.trim()}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 16px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14, opacity: (!content.trim()) ? 0.5 : 1 }}>
          <Sparkles size={15} /> {aiLoading ? 'Generiere…' : 'Fragen generieren'}
        </button>
        <button onClick={suggestLinks} disabled={linkLoading || !content.trim()}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 16px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14, opacity: (!content.trim()) ? 0.5 : 1 }}>
          <Link size={15} /> {linkLoading ? 'Suche…' : 'Verknüpfungen finden'}
        </button>
      </div>

      {questions.length > 0 && (
        <div style={{ marginTop: 28, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '18px' }}>
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 12, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Lernfragen</h3>
          <ol style={{ paddingLeft: 20, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {questions.map((q, i) => <li key={i} style={{ fontSize: 14, lineHeight: 1.5 }}>{q}</li>)}
          </ol>
        </div>
      )}

      {confirmDelete && (
        <ConfirmModal
          message={`Karte „${title}" unwiderruflich löschen?`}
          onConfirm={async () => {
            await api.cards.delete(currentCardId);
            onClose();
          }}
          onCancel={() => setConfirmDelete(false)}
        />
      )}

      {(links.length > 0 || linkSuggestions.length > 0) && (
        <div style={{ marginTop: 20, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '18px' }}>
          <h3 style={{ fontSize: 14, fontWeight: 600, marginBottom: 12, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Verknüpfungen</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {links.map(l => (
              <div key={l.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 12px', background: 'var(--surface2)', borderRadius: 8 }}>
                <span style={{ fontSize: 14 }}>🔗 {l.title}</span>
                <button onClick={() => removeLink(l.id)} style={{ color: 'var(--text-muted)' }}><X size={13} /></button>
              </div>
            ))}
            {linkSuggestions.map(s => (
              <div key={s.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 12px', background: 'var(--surface2)', borderRadius: 8, border: '1px dashed var(--border)' }}>
                <span style={{ fontSize: 14, color: 'var(--text-muted)' }}>💡 {s.title}</span>
                <button onClick={() => addLink(s)} style={{ fontSize: 12, padding: '4px 10px', borderRadius: 6, background: 'var(--accent)', color: 'white' }}>Verknüpfen</button>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
