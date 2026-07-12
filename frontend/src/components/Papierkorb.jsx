import { useState, useEffect } from 'react';
import { ArrowLeft, RotateCcw, Trash2 } from 'lucide-react';
import { api } from '../api/client.js';

export default function Papierkorb({ onClose }) {
  const [cards, setCards] = useState([]);
  const [loading, setLoading] = useState(true);
  const [confirmPermanent, setConfirmPermanent] = useState(null);
  const [busy, setBusy] = useState(null);

  useEffect(() => {
    api.cards.trash()
      .then(setCards)
      .finally(() => setLoading(false));
  }, []);

  const restore = async (card) => {
    setBusy(card.id);
    try {
      await api.cards.restore(card.id);
      setCards(prev => prev.filter(c => c.id !== card.id));
    } finally { setBusy(null); }
  };

  const deletePermanently = async (card) => {
    setBusy(card.id);
    try {
      await api.cards.deletePermanently(card.id);
      setCards(prev => prev.filter(c => c.id !== card.id));
      setConfirmPermanent(null);
    } finally { setBusy(null); }
  };

  const formatDate = iso => new Date(iso).toLocaleDateString('de-DE', { day: 'numeric', month: 'short', year: 'numeric' });

  return (
    <div style={{ maxWidth: 780, margin: '0 auto', padding: '28px 20px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 24 }}>
        <button onClick={onClose}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '6px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
          <ArrowLeft size={14} /> Zurück
        </button>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700 }}>Papierkorb</h1>
          <p style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>Gelöschte Einträge wiederherstellen oder endgültig löschen</p>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px 0', color: 'var(--text-muted)' }}>Laden…</div>
      ) : cards.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-muted)' }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>🗑️</div>
          <div style={{ fontSize: 16 }}>Papierkorb ist leer</div>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {cards.map(card => (
            <div key={card.id}
              style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '14px 16px', display: 'flex', alignItems: 'flex-start', gap: 12, opacity: busy === card.id ? 0.5 : 1, transition: 'opacity 0.2s' }}>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontWeight: 600, fontSize: 15, marginBottom: 3 }}>{card.title}</div>
                {card.content && (
                  <div style={{ color: 'var(--text-muted)', fontSize: 13, lineHeight: 1.5, overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>
                    {card.content.replace(/\$\$?[^$]+\$\$?/g, '[Formel]')}
                  </div>
                )}
                <div style={{ display: 'flex', gap: 8, marginTop: 6, alignItems: 'center', flexWrap: 'wrap' }}>
                  {card.box_name && (
                    <span style={{ fontSize: 11, padding: '2px 8px', borderRadius: 10, background: (card.box_color || '#6366f1') + '22', color: card.box_color || '#6366f1', fontWeight: 600 }}>
                      {card.box_icon} {card.box_name}
                    </span>
                  )}
                  <span style={{ fontSize: 11, color: 'var(--text-muted)' }}>Gelöscht: {formatDate(card.deleted_at)}</span>
                </div>
              </div>
              <div style={{ display: 'flex', gap: 6, flexShrink: 0 }}>
                <button onClick={() => restore(card)} disabled={busy === card.id} title="Wiederherstellen"
                  style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '6px 12px', borderRadius: 8, border: '1px solid #22c55e44', color: '#22c55e', background: '#22c55e11', fontSize: 12, fontWeight: 600 }}>
                  <RotateCcw size={12} /> Wiederherstellen
                </button>
                <button onClick={() => setConfirmPermanent(card)} disabled={busy === card.id} title="Endgültig löschen"
                  style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '6px 10px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--danger)', fontSize: 12 }}>
                  <Trash2 size={12} />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {confirmPermanent && (
        <div style={{ position: 'fixed', inset: 0, background: '#00000066', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <div style={{ background: 'var(--surface)', borderRadius: 16, padding: '24px 28px', maxWidth: 400, width: '100%', border: '1px solid var(--border)' }}>
            <div style={{ fontWeight: 700, fontSize: 17, marginBottom: 10 }}>Endgültig löschen?</div>
            <div style={{ color: 'var(--text-muted)', fontSize: 14, marginBottom: 20 }}>
              „{confirmPermanent.title}" wird dauerhaft gelöscht und kann nicht wiederhergestellt werden.
            </div>
            <div style={{ display: 'flex', gap: 10 }}>
              <button onClick={() => deletePermanently(confirmPermanent)} disabled={!!busy}
                style={{ flex: 1, padding: '10px', borderRadius: 10, background: 'var(--danger)', color: 'white', fontWeight: 700, fontSize: 14 }}>
                Endgültig löschen
              </button>
              <button onClick={() => setConfirmPermanent(null)}
                style={{ padding: '10px 16px', borderRadius: 10, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 14 }}>
                Abbrechen
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
