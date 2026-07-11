import { useState } from 'react';
import { supabase } from '../supabase.js';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    const { error: err } = await supabase.auth.signInWithPassword({ email, password });
    if (err) setError('E-Mail oder Passwort falsch.');
    setLoading(false);
  };

  return (
    <div style={{
      minHeight: '100vh', background: 'var(--bg)', display: 'flex',
      alignItems: 'center', justifyContent: 'center', padding: 24,
    }}>
      <div style={{ width: '100%', maxWidth: 360 }}>
        <div style={{ textAlign: 'center', marginBottom: 40 }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>🧠</div>
          <h1 style={{ fontSize: 26, fontWeight: 700, color: 'var(--text)', letterSpacing: '-0.3px' }}>
            Mein Wissen
          </h1>
          <p style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 4, fontStyle: 'italic' }}>
            Lernen. Verstehen. Behalten.
          </p>
        </div>

        <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
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

          {error && (
            <p style={{ color: '#ef4444', fontSize: 13, margin: 0 }}>{error}</p>
          )}

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
            {loading ? 'Anmelden…' : 'Anmelden'}
          </button>
        </form>
      </div>
    </div>
  );
}
