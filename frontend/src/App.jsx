import { useState } from 'react';
import Home from './components/Home.jsx';
import EntryDetail from './components/EntryDetail.jsx';
import QuizMode from './components/QuizMode.jsx';
import ReviewMode from './components/ReviewMode.jsx';
import Impressum from './components/Impressum.jsx';
import { useTheme } from './components/ThemePicker.jsx';

export default function App() {
  useTheme();
  const [view, setView] = useState('home');
  const [activeEntry, setActiveEntry] = useState(null);
  const [quizEntry, setQuizEntry] = useState(null);
  const [reviewCards, setReviewCards] = useState(null);

  if (quizEntry) return (
    <QuizMode card={quizEntry} onClose={() => setQuizEntry(null)} />
  );

  if (reviewCards) return (
    <ReviewMode cards={reviewCards} onClose={() => setReviewCards(null)} />
  );

  if (view === 'impressum') return (
    <Impressum onClose={() => setView('home')} />
  );

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
