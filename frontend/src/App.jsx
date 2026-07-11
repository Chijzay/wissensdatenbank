import { useState, useEffect } from 'react';
import Home from './components/Home.jsx';
import EntryDetail from './components/EntryDetail.jsx';
import QuizMode from './components/QuizMode.jsx';
import ReviewMode from './components/ReviewMode.jsx';
import Impressum from './components/Impressum.jsx';
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

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => setSession(session));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });
    return () => subscription.unsubscribe();
  }, []);

  // Laden
  if (session === undefined) return (
    <div style={{ minHeight: '100vh', background: 'var(--bg)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ color: 'var(--text-muted)', fontSize: 14 }}>Laden…</div>
    </div>
  );

  // Nicht angemeldet
  if (!session) return <Login />;

  // Angemeldet
  if (quizEntry) return <QuizMode card={quizEntry} onClose={() => setQuizEntry(null)} />;
  if (reviewCards) return <ReviewMode cards={reviewCards} onClose={() => setReviewCards(null)} />;
  if (view === 'impressum') return <Impressum onClose={() => setView('home')} />;

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
    />
  );
}
