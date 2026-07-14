import { useState, useEffect, useMemo } from 'react';
import { ArrowLeft, RotateCcw, Trash2 } from 'lucide-react';
import { api } from '../api/client.js';

const TYPE_LABELS = { bereich: 'Bereich', box: 'Box', karte: 'Karte' };
const TYPE_COLORS = { bereich: '#7c6af7', box: '#06b6d4', karte: '#22c55e' };

export default function Papierkorb({ onClose }) {
  const [boxes, setBoxes] = useState([]);
  const [cards, setCards] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('alle'); // 'alle' | 'bereiche' | 'boxen' | 'karten'
  const [confirmItem, setConfirmItem] = useState(null); // item to permanently delete
  const [confirmAll, setConfirmAll] = useState(false);
  const [busy, setBusy] = useState(null);

  const load = async () => {
    setLoading(true);
    try {
      const [b, c] = await Promise.all([api.boxes.trash(), api.cards.trash()]);
      setBoxes(b);
      setCards(c);
    } finally { setLoading(false); }
  };

  useEffect(() => { load(); }, []);

  // Combine into unified item list with type info
  const allItems = useMemo(() => {
    const boxItems = boxes.map(b => ({
      ...b,
      _type: b.parent_id ? 'box' : 'bereich',
      _label: b.name,
      _sub: b.parent_id ? `Sub-Box` : `Bereich`,
    }));
    const cardItems = cards.map(c => ({
      ...c,
      _type: 'karte',
      _label: c.title,
      _sub: c.box_name || '',
    }));
    return [...boxItems, ...cardItems].sort((a, b) => new Date(b.deleted_at) - new Date(a.deleted_at));
  }, [boxes, cards]);

  const counts = useMemo(() => ({
    alle: allItems.length,
    bereiche: allItems.filter(i => i._type === 'bereich').length,
    boxen: allItems.filter(i => i._type === 'box').length,
    karten: allItems.filter(i => i._type === 'karte').length,
  }), [allItems]);

  const visible = useMemo(() => {
    if (filter === 'alle') return allItems;
    if (filter === 'bereiche') return allItems.filter(i => i._type === 'bereich');
    if (filter === 'boxen') return allItems.filter(i => i._type === 'box');
    return allItems.filter(i => i._type === 'karte');
  }, [allItems, filter]);

  const restore = async (item) => {
    setBusy(item.id + item._type);
    try {
      if (item._type === 'karte') {
        await api.cards.restore(item.id);
        setCards(prev => prev.filter(c => c.id !== item.id));
      } else {
        await api.boxes.restore(item.id);
        // Remove box + any cards that were in it from local state
        setBoxes(prev => prev.filter(b => b.id !== item.id && b.parent_id !== item.id));
        setCards(prev => prev.filter(c => c.box_id !== item.id));
      }
    } finally { setBusy(null); }
  };

  const deletePermanently = async (item) => {
    setBusy(item.id + item._type);
    try {
      if (item._type === 'karte') {
        await api.cards.deletePermanently(item.id);
        setCards(prev => prev.filter(c => c.id !== item.id));
      } else {
        await api.boxes.deletePermanently(item.id);
        setBoxes(prev => prev.filter(b => b.id !== item.id && b.parent_id !== item.id));
        setCards(prev => prev.filter(c => c.box_id !== item.id));
      }
      setConfirmItem(null);
    } finally { setBusy(null); }
  };

  const deleteAll = async () => {
    setBusy('all');
    try {
      await Promise.all([
        api.boxes.deleteAllTrashed(),
        api.cards.deleteAllTrashed(),
      ]);
      setBoxes([]);
      setCards([]);
      setConfirmAll(false);
    } finally { setBusy(null); }
  };

  const formatDate = iso => new Date(iso).toLocaleDateString('de-DE', { day: 'numeric', month: 'short', year: 'numeric' });

  const FILTERS = [
    { key: 'alle', label: 'Alle' },
    { key: 'bereiche', label: 'Bereiche' },
    { key: 'boxen', label: 'Boxen' },
    { key: 'karten', label: 'Karten' },
  ];

  return (
    <div style={{ maxWidth: 780, margin: '0 auto', padding: '28px 20px' }}>

      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 24 }}>
        <button onClick={onClose}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '6px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
          <ArrowLeft size={14} /> Zurück
        </button>
        <div style={{ flex: 1 }}>
          <h1 style={{ fontSize: 22, fontWeight: 700 }}>Papierkorb</h1>
          <p style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>
            Gelöschte Einträge, Boxen und Bereiche
          </p>
        </div>
        {allItems.length > 0 && (
          <button onClick={() => setConfirmAll(true)} disabled={busy === 'all'}
            style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '7px 14px', borderRadius: 8, border: '1px solid var(--danger)', color: 'var(--danger)', fontSize: 13, background: '#ef444411' }}>
            <Trash2 size={13} /> Alle löschen
          </button>
        )}
      </div>

      {/* Filter-Tabs */}
      {!loading && allItems.length > 0 && (
        <div style={{ display: 'flex', gap: 6, marginBottom: 16, flexWrap: 'wrap' }}>
          {FILTERS.map(f => (
            <button key={f.key} onClick={() => setFilter(f.key)}
              style={{
                padding: '5px 14px', borderRadius: 20, fontSize: 13, fontWeight: filter === f.key ? 700 : 400,
                border: `1px solid ${filter === f.key ? 'var(--accent)' : 'var(--border)'}`,
                background: filter === f.key ? 'var(--accent)' : 'var(--surface)',
                color: filter === f.key ? 'white' : 'var(--text-muted)',
                transition: 'all 0.15s',
              }}>
              {f.label}
              <span style={{ marginLeft: 6, fontSize: 11, opacity: 0.8 }}>({counts[f.key]})</span>
            </button>
          ))}
        </div>
      )}

      {/* Content */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px 0', color: 'var(--text-muted)' }}>Laden…</div>
      ) : visible.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-muted)' }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>🗑️</div>
          <div style={{ fontSize: 16 }}>{allItems.length === 0 ? 'Papierkorb ist leer' : 'Keine Einträge in diesem Filter'}</div>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {visible.map(item => {
            const key = item.id + item._type;
            const typeColor = TYPE_COLORS[item._type];
            return (
              <div key={key}
                style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '14px 16px', display: 'flex', alignItems: 'flex-start', gap: 12, opacity: busy === key ? 0.5 : 1, transition: 'opacity 0.2s', borderLeft: `3px solid ${typeColor}` }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  {/* Typ-Badge */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                    <span style={{ fontSize: 11, fontWeight: 700, padding: '1px 8px', borderRadius: 10, background: typeColor + '22', color: typeColor, textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                      {item._type === 'bereich' ? `${item.icon || '📁'} ${TYPE_LABELS[item._type]}` : item._type === 'box' ? `${item.icon || '📦'} ${TYPE_LABELS[item._type]}` : '📄 Karte'}
                    </span>
                    {item._sub && item._type !== 'bereich' && (
                      <span style={{ fontSize: 11, color: 'var(--text-muted)' }}>
                        {item._type === 'karte' ? `in ${item._sub}` : ''}
                      </span>
                    )}
                  </div>

                  <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 3 }}>{item._label}</div>

                  {item._type === 'karte' && item.content && (
                    <div style={{ color: 'var(--text-muted)', fontSize: 13, lineHeight: 1.5, overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>
                      {item.content.replace(/\$\$?[^$]+\$\$?/g, '[Formel]')}
                    </div>
                  )}

                  {(item._type === 'bereich' || item._type === 'box') && (
                    <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>
                      {item._type === 'bereich' ? 'Enthält Sub-Boxen und Einträge' : 'Enthält Einträge'}
                    </div>
                  )}

                  <div style={{ marginTop: 6, fontSize: 11, color: 'var(--text-muted)' }}>
                    Gelöscht: {formatDate(item.deleted_at)}
                  </div>
                </div>

                <div style={{ display: 'flex', gap: 6, flexShrink: 0 }}>
                  <button onClick={() => restore(item)} disabled={!!busy} title="Wiederherstellen"
                    style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '6px 12px', borderRadius: 8, border: '1px solid #22c55e44', color: '#22c55e', background: '#22c55e11', fontSize: 12, fontWeight: 600 }}>
                    <RotateCcw size={12} /> Wiederherstellen
                  </button>
                  <button onClick={() => setConfirmItem(item)} disabled={!!busy} title="Endgültig löschen"
                    style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '6px 10px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--danger)', fontSize: 12 }}>
                    <Trash2 size={12} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Confirm: einzeln löschen */}
      {confirmItem && (
        <Modal
          title="Endgültig löschen?"
          body={`„${confirmItem._label}" wird dauerhaft gelöscht und kann nicht wiederhergestellt werden.${confirmItem._type !== 'karte' ? ' Alle enthaltenen Einträge werden ebenfalls gelöscht.' : ''}`}
          confirmLabel="Endgültig löschen"
          onConfirm={() => deletePermanently(confirmItem)}
          onCancel={() => setConfirmItem(null)}
          busy={!!busy}
        />
      )}

      {/* Confirm: alles löschen */}
      {confirmAll && (
        <Modal
          title="Papierkorb leeren?"
          body={`Alle ${allItems.length} Elemente (Bereiche, Boxen und Karten) werden dauerhaft gelöscht. Dies kann nicht rückgängig gemacht werden.`}
          confirmLabel="Papierkorb leeren"
          onConfirm={deleteAll}
          onCancel={() => setConfirmAll(false)}
          busy={busy === 'all'}
        />
      )}
    </div>
  );
}

function Modal({ title, body, confirmLabel, onConfirm, onCancel, busy }) {
  return (
    <div style={{ position: 'fixed', inset: 0, background: '#00000066', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
      <div style={{ background: 'var(--surface)', borderRadius: 16, padding: '24px 28px', maxWidth: 420, width: '100%', border: '1px solid var(--border)' }}>
        <div style={{ fontWeight: 700, fontSize: 17, marginBottom: 10 }}>{title}</div>
        <div style={{ color: 'var(--text-muted)', fontSize: 14, marginBottom: 20 }}>{body}</div>
        <div style={{ display: 'flex', gap: 10 }}>
          <button onClick={onConfirm} disabled={busy}
            style={{ flex: 1, padding: '10px', borderRadius: 10, background: 'var(--danger)', color: 'white', fontWeight: 700, fontSize: 14, opacity: busy ? 0.6 : 1 }}>
            {busy ? 'Lösche…' : confirmLabel}
          </button>
          <button onClick={onCancel} disabled={busy}
            style={{ padding: '10px 16px', borderRadius: 10, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14 }}>
            Abbrechen
          </button>
        </div>
      </div>
    </div>
  );
}
