import { useState, useEffect, useRef } from 'react';
import { api } from './api/client.js';
import Home from './components/Home.jsx';
import EntryDetail from './components/EntryDetail.jsx';
import QuizMode from './components/QuizMode.jsx';
import ReviewMode from './components/ReviewMode.jsx';
import Impressum from './components/Impressum.jsx';
import Papierkorb from './components/Papierkorb.jsx';
import Login from './components/Login.jsx';
import { useTheme } from './components/ThemePicker.jsx';
import { supabase } from './supabase.js';

export default function App() {
  useTheme();
  const [session, setSession] = useState(undefined); // undefined = Laden, null = nicht angemeldet
  const [view, setView] = useState('home');
  const [activeEntry, setActiveEntry] = useState(null);
  const [quizEntry, setQuizEntry] = useState(null);
  const [reviewCards, setReviewCards] = useState(null);
  const [restoring, setRestoring] = useState(() => !!localStorage.getItem('nav-entry-id'));
  const navRestored = useRef(false);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => setSession(session));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });
    return () => subscription.unsubscribe();
  }, []);

  // Letzten offenen Eintrag nach Login wiederherstellen (ohne Startseiten-Flash)
  useEffect(() => {
    if (!session || navRestored.current) return;
    navRestored.current = true;
    const savedId = localStorage.getItem('nav-entry-id');
    if (!savedId) return;
    setRestoring(true);
    Promise.all([api.cards.get(Number(savedId)), api.boxes.list()])
      .then(([card, boxes]) => {
        const box = boxes.find(b => b.id === card.box_id) || {};
        setActiveEntry({ ...card, box_name: box.name || '', box_color: box.color || '', box_icon: box.icon || '', box_parent_id: box.parent_id || null });
        setView('entry');
      })
      .catch(() => localStorage.removeItem('nav-entry-id'))
      .finally(() => setRestoring(false));
  }, [session]);

  // Eintragszustand speichern
  useEffect(() => {
    if (!session) return;
    if (view === 'entry' && activeEntry) localStorage.setItem('nav-entry-id', activeEntry.id);
    else localStorage.removeItem('nav-entry-id');
  }, [view, activeEntry, session]);

  // Laden (Verbindung wird aufgebaut)
  if (session === undefined) return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ color: 'var(--text-muted)', fontSize: 14 }}>Laden…</div>
    </div>
  );

  // Nicht angemeldet
  if (!session) return <Login />;

  // Letzten Eintrag wiederherstellen
  if (restoring) return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ color: 'var(--text-muted)', fontSize: 14 }}>Laden…</div>
    </div>
  );

  // Angemeldet
  if (quizEntry) return <QuizMode card={quizEntry} onClose={() => setQuizEntry(null)} />;
  if (reviewCards) return <ReviewMode cards={reviewCards} onClose={() => setReviewCards(null)} />;
  if (view === 'impressum') return <Impressum onClose={() => setView('home')} />;
  if (view === 'papierkorb') return <Papierkorb onClose={() => setView('home')} />;

  if (view === 'entry' && activeEntry) return (
    <EntryDetail
      key={activeEntry.id}
      entry={activeEntry}
      onClose={() => { setActiveEntry(null); setView('home'); }}
      onStartQuiz={(entry) => { setQuizEntry(entry); setView('home'); }}
      onNavigate={(entry) => { setActiveEntry(entry); }}
    />
  );

  return (
    <Home
      onOpenEntry={(entry) => { setActiveEntry(entry); setView('entry'); }}
      onStartReview={(cards) => setReviewCards(cards)}
      onShowImpressum={() => setView('impressum')}
      onShowPapierkorb={() => setView('papierkorb')}
    />
  );
}
