import { useState } from 'react';
import { X, Check, AlertCircle, ChevronRight } from 'lucide-react';
import { api } from '../api/client.js';

export default function QuizMode({ card, onClose }) {
  const [questions] = useState(card.questions || []);
  const [index, setIndex] = useState(0);
  const [answer, setAnswer] = useState('');
  const [feedback, setFeedback] = useState(null);
  const [checking, setChecking] = useState(false);
  const [results, setResults] = useState([]);
  const [done, setDone] = useState(false);

  const check = async () => {
    if (!answer.trim()) return;
    setChecking(true);
    const result = await api.ai.checkAnswer({ question: questions[index], answer, card_content: card.content });
    const entry = { question: questions[index], answer, ...result };
    setFeedback(result);
    setResults(prev => [...prev, entry]);
    setChecking(false);
  };

  const next = () => {
    if (index + 1 >= questions.length) { setDone(true); return; }
    setIndex(i => i + 1);
    setAnswer('');
    setFeedback(null);
  };

  if (questions.length === 0) return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100vh', gap: 16 }}>
      <p style={{ color: 'var(--text-muted)' }}>Keine Fragen vorhanden. Generiere zuerst Fragen in der Karte.</p>
      <button onClick={onClose} style={{ padding: '10px 20px', borderRadius: 8, background: 'var(--accent)', color: 'white' }}>Zurück</button>
    </div>
  );

  if (done) {
    const correct = results.filter(r => r.correct).length;
    return (
      <div style={{ maxWidth: 600, margin: '0 auto', padding: '60px 24px', textAlign: 'center' }}>
        <div style={{ fontSize: 60, marginBottom: 20 }}>{correct === questions.length ? '🎉' : correct > questions.length / 2 ? '👍' : '💪'}</div>
        <h2 style={{ fontSize: 28, fontWeight: 700, marginBottom: 8 }}>{correct} von {questions.length} richtig</h2>
        <p style={{ color: 'var(--text-muted)', marginBottom: 40 }}>Karte: {card.title}</p>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, textAlign: 'left', marginBottom: 40 }}>
          {results.map((r, i) => (
            <div key={i} style={{ background: 'var(--surface)', border: `1px solid ${r.correct ? '#22c55e44' : '#ef444444'}`, borderRadius: 10, padding: '14px 16px' }}>
              <div style={{ display: 'flex', gap: 10, marginBottom: 6 }}>
                {r.correct ? <Check size={15} style={{ color: 'var(--success)', flexShrink: 0, marginTop: 2 }} /> : <AlertCircle size={15} style={{ color: 'var(--danger)', flexShrink: 0, marginTop: 2 }} />}
                <span style={{ fontSize: 14, fontWeight: 500 }}>{r.question}</span>
              </div>
              <div style={{ fontSize: 13, color: 'var(--text-muted)', marginLeft: 25 }}>{r.feedback}</div>
            </div>
          ))}
        </div>
        <button onClick={onClose} style={{ padding: '12px 28px', borderRadius: 10, background: 'var(--accent)', color: 'white', fontWeight: 600 }}>Fertig</button>
      </div>
    );
  }

  return (
    <div style={{ maxWidth: 640, margin: '0 auto', padding: '60px 24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 48 }}>
        <span style={{ color: 'var(--text-muted)', fontSize: 14 }}>Frage {index + 1} / {questions.length} — {card.title}</span>
        <button onClick={onClose} style={{ color: 'var(--text-muted)', padding: 6, borderRadius: 6 }}><X size={18} /></button>
      </div>

      <div style={{ display: 'flex', gap: 4, marginBottom: 36 }}>
        {questions.map((_, i) => (
          <div key={i} style={{ flex: 1, height: 4, borderRadius: 2, background: i < index ? 'var(--success)' : i === index ? 'var(--accent)' : 'var(--border)' }} />
        ))}
      </div>

      <h2 style={{ fontSize: 22, fontWeight: 600, lineHeight: 1.4, marginBottom: 32 }}>{questions[index]}</h2>

      <textarea value={answer} onChange={e => setAnswer(e.target.value)}
        placeholder="Deine Antwort…" rows={5} disabled={!!feedback}
        style={{ width: '100%', background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10, padding: '14px 16px', fontSize: 15, lineHeight: 1.6, opacity: feedback ? 0.7 : 1 }} />

      {feedback && (
        <div style={{ marginTop: 16, padding: '14px 16px', borderRadius: 10, background: feedback.correct ? '#22c55e11' : '#ef444411', border: `1px solid ${feedback.correct ? '#22c55e44' : '#ef444444'}` }}>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 6 }}>
            {feedback.correct ? <Check size={16} style={{ color: 'var(--success)' }} /> : <AlertCircle size={16} style={{ color: 'var(--danger)' }} />}
            <span style={{ fontWeight: 600, color: feedback.correct ? 'var(--success)' : 'var(--danger)' }}>
              {feedback.correct ? 'Richtig!' : 'Nicht ganz…'}
            </span>
          </div>
          <p style={{ fontSize: 14, color: 'var(--text-muted)', marginLeft: 24 }}>{feedback.feedback}</p>
        </div>
      )}

      <div style={{ marginTop: 20, display: 'flex', gap: 10 }}>
        {!feedback ? (
          <button onClick={check} disabled={checking || !answer.trim()}
            style={{ flex: 1, padding: '12px', borderRadius: 10, background: 'var(--accent)', color: 'white', fontWeight: 600, opacity: !answer.trim() ? 0.5 : 1 }}>
            {checking ? 'Prüfe…' : 'Antwort prüfen'}
          </button>
        ) : (
          <button onClick={next} style={{ flex: 1, padding: '12px', borderRadius: 10, background: 'var(--accent)', color: 'white', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
            {index + 1 >= questions.length ? 'Auswertung' : 'Weiter'} <ChevronRight size={18} />
          </button>
        )}
      </div>
    </div>
  );
}
