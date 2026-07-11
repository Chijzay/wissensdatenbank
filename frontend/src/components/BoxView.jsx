import { useState, useEffect, useCallback } from 'react';
import { ArrowLeft, Plus, Search, Shuffle, Brain, Tag } from 'lucide-react';
import { api } from '../api/client.js';
import CardEditor from './CardEditor.jsx';
import CardList from './CardList.jsx';
import QuizMode from './QuizMode.jsx';

export default function BoxView({ box, onBack }) {
  const [cards, setCards] = useState([]);
  const [search, setSearch] = useState('');
  const [activeCard, setActiveCard] = useState(null);
  const [creating, setCreating] = useState(false);
  const [quizCard, setQuizCard] = useState(null);
  const [loading, setLoading] = useState(true);
  const [allTags, setAllTags] = useState([]);
  const [activeTag, setActiveTag] = useState('');

  const loadCards = useCallback(async () => {
    const params = {};
    if (search) params.search = search;
    if (activeTag) params.tag = activeTag;
    const data = await api.cards.list(box.id, params);
    setCards(data);
    const tags = [...new Set(data.flatMap(c => c.tags))];
    setAllTags(tags);
    setLoading(false);
  }, [box.id, search, activeTag]);

  useEffect(() => { loadCards(); }, [loadCards]);

  const openRandom = async () => {
    try {
      const card = await api.cards.random(box.id);
      const full = await api.cards.get(card.id);
      setActiveCard(full);
    } catch {}
  };

  if (quizCard) return (
    <QuizMode card={quizCard} onClose={() => setQuizCard(null)} />
  );

  if (activeCard) return (
    <CardEditor
      card={activeCard}
      box={box}
      onClose={() => { setActiveCard(null); loadCards(); }}
      onStartQuiz={() => { setQuizCard(activeCard); setActiveCard(null); }}
    />
  );

  if (creating) return (
    <CardEditor
      card={null}
      box={box}
      onClose={() => { setCreating(false); loadCards(); }}
      onStartQuiz={null}
    />
  );

  return (
    <div style={{ maxWidth: 900, margin: '0 auto', padding: '32px 24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 32 }}>
        <button onClick={onBack} style={{ color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 6, padding: '8px 12px', borderRadius: 8, border: '1px solid var(--border)' }}
          onMouseEnter={e => e.currentTarget.style.color = 'var(--text)'}
          onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}
        >
          <ArrowLeft size={16} /> Zurück
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ fontSize: 26 }}>{box.icon}</span>
            <h2 style={{ fontSize: 22, fontWeight: 700 }}>{box.name}</h2>
          </div>
          {box.description && <p style={{ color: 'var(--text-muted)', fontSize: 13, marginTop: 2 }}>{box.description}</p>}
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <button onClick={openRandom}
            title="Zufällige Karte"
            style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 6 }}
            onMouseEnter={e => { e.currentTarget.style.color = 'var(--text)'; e.currentTarget.style.borderColor = 'var(--text-muted)'; }}
            onMouseLeave={e => { e.currentTarget.style.color = 'var(--text-muted)'; e.currentTarget.style.borderColor = 'var(--border)'; }}
          >
            <Shuffle size={16} />
          </button>
          <button onClick={() => setCreating(true)}
            style={{ padding: '8px 16px', borderRadius: 8, background: 'var(--accent)', color: 'white', display: 'flex', alignItems: 'center', gap: 6, fontWeight: 500 }}>
            <Plus size={16} /> Neue Karte
          </button>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 10, marginBottom: 16 }}>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 10, background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '0 14px' }}>
          <Search size={15} style={{ color: 'var(--text-muted)', flexShrink: 0 }} />
          <input value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Suchen…"
            style={{ flex: 1, padding: '11px 0', fontSize: 14 }} />
        </div>
      </div>

      {allTags.length > 0 && (
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 20 }}>
          <button onClick={() => setActiveTag('')}
            style={{ padding: '4px 12px', borderRadius: 20, fontSize: 13, border: '1px solid var(--border)', background: !activeTag ? 'var(--accent)' : 'none', color: !activeTag ? 'white' : 'var(--text-muted)' }}>
            Alle
          </button>
          {allTags.map(tag => (
            <button key={tag} onClick={() => setActiveTag(activeTag === tag ? '' : tag)}
              style={{ padding: '4px 12px', borderRadius: 20, fontSize: 13, border: '1px solid var(--border)', background: activeTag === tag ? 'var(--accent)' : 'none', color: activeTag === tag ? 'white' : 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 5 }}>
              <Tag size={11} /> {tag}
            </button>
          ))}
        </div>
      )}

      {loading ? (
        <p style={{ color: 'var(--text-muted)' }}>Laden…</p>
      ) : (
        <CardList
          cards={cards}
          onSelect={async (card) => {
            const full = await api.cards.get(card.id);
            setActiveCard(full);
          }}
        />
      )}
    </div>
  );
}
