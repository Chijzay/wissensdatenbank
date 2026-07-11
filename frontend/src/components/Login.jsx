import { useState } from 'react';
import { supabase } from '../supabase.js';

export default function Login() {
  const [mode, setMode] = useState('login'); // 'login' | 'register'
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirm, setPasswordConfirm] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const reset = (newMode) => {
    setMode(newMode);
    setError('');
    setSuccess('');
    setPassword('');
    setPasswordConfirm('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (mode === 'register') {
      if (password !== passwordConfirm) {
        setError('Passwörter stimmen nicht überein.');
        return;
      }
      if (password.length < 6) {
        setError('Passwort muss mindestens 6 Zeichen lang sein.');
        return;
      }
    }

    setLoading(true);

    if (mode === 'login') {
      const { error: err } = await supabase.auth.signInWithPassword({ email, password });
      if (err) setError('E-Mail oder Passwort falsch.');
    } else {
      const { error: err } = await supabase.auth.signUp({ email, password });
      if (err) {
        setError(err.message.includes('already registered')
          ? 'Diese E-Mail ist bereits registriert.'
          : 'Registrierung fehlgeschlagen. Bitte versuche es erneut.');
      } else {
        setSuccess('Konto erstellt! Bitte bestätige deine E-Mail-Adresse und melde dich dann an.');
        setMode('login');
        setEmail('');
        setPassword('');
        setPasswordConfirm('');
      }
    }

    setLoading(false);
  };

  return (
    <div style={{
      minHeight: '100vh', background: 'var(--bg)', display: 'flex',
      alignItems: 'center', justifyContent: 'center', padding: 24,
    }}>
      <div style={{ width: '100%', maxWidth: 360 }}>

        {/* Logo */}
        <div style={{ textAlign: 'center', marginBottom: 40 }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>🧠</div>
          <h1 style={{ fontSize: 26, fontWeight: 700, color: 'var(--text)', letterSpacing: '-0.3px' }}>
            Mein Wissen
          </h1>
          <p style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 4, fontStyle: 'italic' }}>
            Lernen. Verstehen. Behalten.
          </p>
        </div>

        {/* Tab-Toggle */}
        <div style={{
          display: 'flex', background: 'var(--surface)', borderRadius: 12,
          padding: 4, marginBottom: 24, border: '1px solid var(--border)',
        }}>
          {['login', 'register'].map(m => (
            <button
              key={m}
              onClick={() => reset(m)}
              style={{
                flex: 1, padding: '9px', borderRadius: 9, fontSize: 14, fontWeight: 600,
                background: mode === m ? 'var(--accent)' : 'transparent',
                color: mode === m ? 'white' : 'var(--text-muted)',
                transition: 'all 0.15s',
              }}
            >
              {m === 'login' ? 'Anmelden' : 'Registrieren'}
            </button>
          ))}
        </div>

        {/* Formular */}
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <input
            type="email"
            placeholder="E-Mail"
            value={email}
            onChange={e => setEmail(e.target.value)}
            required
            style={{
              padding: '12px 14px', borderRadius: 10, border: '1px solid var(--border)',
              background: 'var(--surface)', color: 'var(--text)', fontSize: 15,
            }}
          />
          <input
            type="password"
            placeholder="Passwort"
            value={password}
            onChange={e => setPassword(e.target.value)}
            required
            style={{
              padding: '12px 14px', borderRadius: 10, border: '1px solid var(--border)',
              background: 'var(--surface)', color: 'var(--text)', fontSize: 15,
            }}
          />
          {mode === 'register' && (
            <input
              type="password"
              placeholder="Passwort bestätigen"
              value={passwordConfirm}
              onChange={e => setPasswordConfirm(e.target.value)}
              required
              style={{
                padding: '12px 14px', borderRadius: 10, border: '1px solid var(--border)',
                background: 'var(--surface)', color: 'var(--text)', fontSize: 15,
              }}
            />
          )}

          {error && <p style={{ color: '#ef4444', fontSize: 13, margin: 0 }}>{error}</p>}
          {success && <p style={{ color: '#22c55e', fontSize: 13, margin: 0 }}>{success}</p>}

          <button
            type="submit"
            disabled={loading}
            style={{
              marginTop: 4, padding: '13px', borderRadius: 10,
              background: 'var(--accent)', color: 'white',
              fontSize: 15, fontWeight: 600,
              opacity: loading ? 0.6 : 1, transition: 'opacity 0.15s',
            }}
          >
            {loading
              ? (mode === 'login' ? 'Anmelden…' : 'Registrieren…')
              : (mode === 'login' ? 'Anmelden' : 'Konto erstellen')}
          </button>
        </form>

      </div>
    </div>
  );
}
