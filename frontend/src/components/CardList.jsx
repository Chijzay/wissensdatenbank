import { Tag } from 'lucide-react';

export default function CardList({ cards, onSelect }) {
  if (cards.length === 0) return (
    <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-muted)' }}>
      <div style={{ fontSize: 40, marginBottom: 12 }}>📭</div>
      <p>Noch keine Karten vorhanden.</p>
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {cards.map(card => (
        <button key={card.id} onClick={() => onSelect(card)}
          style={{
            background: 'var(--surface)', border: '1px solid var(--border)',
            borderRadius: 'var(--radius)', padding: '16px 20px',
            textAlign: 'left', width: '100%', transition: 'border-color 0.15s, background 0.15s'
          }}
          onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--accent)'; e.currentTarget.style.background = 'var(--surface2)'; }}
          onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.background = 'var(--surface)'; }}
        >
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontWeight: 600, fontSize: 16, marginBottom: 6 }}>{card.title}</div>
              {card.content && (
                <div style={{ color: 'var(--text-muted)', fontSize: 13, lineHeight: 1.5, overflow: 'hidden', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>
                  {card.content}
                </div>
              )}
              {card.tags.length > 0 && (
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginTop: 10 }}>
                  {card.tags.map(t => (
                    <span key={t} style={{ padding: '2px 10px', borderRadius: 20, fontSize: 12, background: 'var(--surface2)', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Tag size={10} /> {t}
                    </span>
                  ))}
                </div>
              )}
            </div>
            {card.questions?.length > 0 && (
              <span style={{ fontSize: 11, color: 'var(--text-muted)', whiteSpace: 'nowrap', marginTop: 2, flexShrink: 0 }}>
                🧠 {card.questions.length} Fragen
              </span>
            )}
          </div>
        </button>
      ))}
    </div>
  );
}
