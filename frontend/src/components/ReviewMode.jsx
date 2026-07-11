import { useState } from 'react';
import { ArrowLeft, Check, RotateCcw, Brain, Trophy } from 'lucide-react';
import ContentRenderer from './ContentRenderer.jsx';

export default function ReviewMode({ cards, onClose }) {
  const total = cards.length;

  const [queue, setQueue] = useState([...cards]);
  const [againQueue, setAgainQueue] = useState([]);
  const [current, setCurrent] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [knownCount, setKnownCount] = useState(0);
  const [round, setRound] = useState(1);
  const [done, setDone] = useState(false);

  const card = queue[current];

  const nextCard = (addAgain) => {
    const newAgain = addAgain ? [...againQueue, queue[current]] : [...againQueue];
    const nextIdx = current + 1;

    if (nextIdx >= queue.length) {
      if (newAgain.length > 0) {
        setQueue(newAgain);
        setAgainQueue([]);
        setCurrent(0);
        setFlipped(false);
        setRound(r => r + 1);
      } else {
        setDone(true);
      }
    } else {
      setAgainQueue(newAgain);
      setCurrent(nextIdx);
      setFlipped(false);
    }
  };

  const handleKnown = () => { setKnownCount(k => k + 1); nextCard(false); };
  const handleAgain = () => nextCard(true);

  const progress = total > 0 ? Math.round((knownCount / total) * 100) : 0;

  if (done) return (
    <div style={{ maxWidth: 580, margin: '0 auto', padding: '60px 20px', textAlign: 'center' }}>
      <div style={{ fontSize: 64, marginBottom: 16 }}>
        {progress === 100 ? '🏆' : progress >= 70 ? '🎯' : '💪'}
      </div>
      <h2 style={{ fontSize: 26, fontWeight: 700, marginBottom: 8 }}>
        {progress === 100 ? 'Alles gewusst!' : 'Wiederholung abgeschlossen'}
      </h2>
      <p style={{ color: 'var(--text-muted)', fontSize: 16, marginBottom: 32 }}>
        {knownCount} von {total} {total === 1 ? 'Karte' : 'Karten'} gewusst
        {round > 1 && ` · ${round} Runden`}
      </p>

      <div style={{ display: 'flex', gap: 12, justifyContent: 'center', marginBottom: 40 }}>
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '16px 24px', minWidth: 110 }}>
          <div style={{ fontSize: 28, fontWeight: 700, color: 'var(--success)' }}>{knownCount}</div>
          <div style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 4 }}>Gewusst</div>
        </div>
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '16px 24px', minWidth: 110 }}>
          <div style={{ fontSize: 28, fontWeight: 700, color: 'var(--danger)' }}>{total - knownCount}</div>
          <div style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 4 }}>Wiederholt</div>
        </div>
        <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 12, padding: '16px 24px', minWidth: 110 }}>
          <div style={{ fontSize: 28, fontWeight: 700 }}>{progress}%</div>
          <div style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 4 }}>Trefferquote</div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 10, justifyContent: 'center' }}>
        <button
          onClick={() => {
            setQueue([...cards]);
            setAgainQueue([]);
            setCurrent(0);
            setFlipped(false);
            setKnownCount(0);
            setRound(1);
            setDone(false);
          }}
          style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '11px 22px', borderRadius: 10, background: 'var(--accent)', color: 'white', fontWeight: 700, fontSize: 15 }}>
          <RotateCcw size={15} /> Nochmal
        </button>
        <button onClick={onClose}
          style={{ padding: '11px 22px', borderRadius: 10, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 15 }}>
          Fertig
        </button>
      </div>
    </div>
  );

  return (
    <div style={{ maxWidth: 640, margin: '0 auto', padding: '28px 20px' }}>

      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
        <button onClick={onClose}
          style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '6px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
          <ArrowLeft size={14} /> Beenden
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
            <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>
              Karte {current + 1} von {queue.length}
              {round > 1 && <span style={{ marginLeft: 8, color: 'var(--accent)', fontWeight: 600 }}>Runde {round}</span>}
            </span>
            <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--success)' }}>
              {knownCount} von {total} gewusst
            </span>
          </div>
          <div style={{ height: 6, background: 'var(--surface2)', borderRadius: 3, overflow: 'hidden' }}>
            <div style={{ height: '100%', background: 'var(--success)', borderRadius: 3, width: `${progress}%`, transition: 'width 0.4s ease' }} />
          </div>
        </div>
      </div>

      {/* Card */}
      <div style={{
        background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 20,
        minHeight: 320, display: 'flex', flexDirection: 'column',
        overflow: 'hidden', marginBottom: 16,
      }}>
        {/* Box label */}
        <div style={{ padding: '14px 20px 0', display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{
            fontSize: 12, padding: '3px 10px', borderRadius: 20, fontWeight: 600,
            background: (card.box_color || '#6366f1') + '22', color: card.box_color || '#6366f1',
          }}>
            {card.box_icon} {card.box_name}
          </span>
          {card.category && (
            <span style={{ fontSize: 12, color: 'var(--text-muted)' }}>{card.category}</span>
          )}
        </div>

        {/* Title */}
        <div style={{ padding: '20px 24px 16px', borderBottom: '1px solid var(--border)' }}>
          <h2 style={{ fontSize: 22, fontWeight: 700, lineHeight: 1.3 }}>{card.title}</h2>
          {card.tags?.length > 0 && (
            <div style={{ display: 'flex', gap: 5, flexWrap: 'wrap', marginTop: 10 }}>
              {card.tags.map(t => (
                <span key={t} style={{ fontSize: 11, padding: '2px 8px', borderRadius: 10, background: 'var(--surface2)', border: '1px solid var(--border)', color: 'var(--text-muted)' }}>{t}</span>
              ))}
            </div>
          )}
        </div>

        {/* Content / Flip */}
        <div style={{ flex: 1, padding: '20px 24px' }}>
          {flipped ? (
            <ContentRenderer text={card.content} />
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', gap: 16, paddingTop: 20 }}>
              <Brain size={36} style={{ color: 'var(--text-muted)', opacity: 0.4 }} />
              <p style={{ color: 'var(--text-muted)', fontSize: 14 }}>Was weißt du dazu?</p>
              <button
                onClick={() => setFlipped(true)}
                style={{ padding: '12px 28px', borderRadius: 12, background: 'var(--accent)', color: 'white', fontWeight: 700, fontSize: 15, transition: 'all 0.15s' }}
                onMouseEnter={e => e.currentTarget.style.background = 'var(--accent-hover)'}
                onMouseLeave={e => e.currentTarget.style.background = 'var(--accent)'}>
                Aufdecken
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Answer buttons — only after flip */}
      {flipped && (
        <div style={{ display: 'flex', gap: 12 }}>
          <button onClick={handleAgain}
            style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, padding: '14px', borderRadius: 12, border: '2px solid var(--danger)', color: 'var(--danger)', fontWeight: 700, fontSize: 15, background: '#ef444411', transition: 'all 0.15s' }}
            onMouseEnter={e => e.currentTarget.style.background = '#ef444422'}
            onMouseLeave={e => e.currentTarget.style.background = '#ef444411'}>
            <RotateCcw size={16} /> Nochmal
          </button>
          <button onClick={handleKnown}
            style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, padding: '14px', borderRadius: 12, border: '2px solid var(--success)', color: 'var(--success)', fontWeight: 700, fontSize: 15, background: '#22c55e11', transition: 'all 0.15s' }}
            onMouseEnter={e => e.currentTarget.style.background = '#22c55e22'}
            onMouseLeave={e => e.currentTarget.style.background = '#22c55e11'}>
            <Check size={16} /> Wusste ich
          </button>
        </div>
      )}

      {/* Keyboard hint */}
      {flipped && (
        <p style={{ textAlign: 'center', fontSize: 12, color: 'var(--text-muted)', marginTop: 10, opacity: 0.6 }}>
          ← Nochmal &nbsp;·&nbsp; Wusste ich →
        </p>
      )}
    </div>
  );
}
