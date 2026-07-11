import { useState, useEffect } from 'react';
import { Palette } from 'lucide-react';

// Jedes Theme hat eine klar unterscheidbare Persönlichkeit
export const THEMES = [
  // Neutral schwarz — cleaner als VS Code, weniger grell als reines Schwarz
  { id: 'dunkel', label: 'Dunkel', desc: 'Neutral & fokussiert', tag: 'Standard',
    accent: '#818cf8', hover: '#a5b4fc',
    bg: '#111111', surface: '#1a1a1a', surface2: '#252525', border: '#333333',
    text: '#e8e8e8', textMuted: '#707070' },

  // Klares Tageslichtweiß — inspiriert von Apple / Figma
  { id: 'hell', label: 'Hell', desc: 'Sonnenklar & scharf', tag: 'Standard',
    accent: '#0071e3', hover: '#409cff',
    bg: '#f2f2f7', surface: '#ffffff', surface2: '#e8e8ed', border: '#c8c8cc',
    text: '#1c1c1e', textMuted: '#636366' },

  // Tiefes Nachtblau — Studieren bei Nacht
  { id: 'nacht', label: 'Nacht', desc: 'Tiefblau & ruhig',
    accent: '#4da6ff', hover: '#70bcff',
    bg: '#040c18', surface: '#091424', surface2: '#102038', border: '#1a3060',
    text: '#b8d0f8', textMuted: '#406898' },

  // Sattes Lila — kreativ & lebendig
  { id: 'violett', label: 'Violett', desc: 'Lebendig & kreativ',
    accent: '#c060ff', hover: '#d888ff',
    bg: '#120820', surface: '#1c1030', surface2: '#281840', border: '#402860',
    text: '#e8d0ff', textMuted: '#7850a0' },

  // Warmes Bernstein — gemütlich wie Lampenlicht
  { id: 'bernstein', label: 'Bernstein', desc: 'Warm & gemütlich',
    accent: '#f0a030', hover: '#ffcc60',
    bg: '#1a1000', surface: '#271800', surface2: '#362200', border: '#503010',
    text: '#f8e8c0', textMuted: '#907040' },

  // Sattgrünes Dunkel — Natur, Ruhe, Fokus
  { id: 'wald', label: 'Wald', desc: 'Natürlich & ruhig',
    accent: '#40c070', hover: '#60d888',
    bg: '#0a1a0d', surface: '#122018', surface2: '#1a2e20', border: '#253828',
    text: '#c0e8c8', textMuted: '#487858' },
];

function applyTheme(theme) {
  const r = document.documentElement.style;
  r.setProperty('--accent', theme.accent);
  r.setProperty('--accent-hover', theme.hover);
  r.setProperty('--bg', theme.bg);
  r.setProperty('--surface', theme.surface);
  r.setProperty('--surface2', theme.surface2);
  r.setProperty('--border', theme.border);
  r.setProperty('--text', theme.text);
  r.setProperty('--text-muted', theme.textMuted);
}

export function useTheme() {
  useEffect(() => {
    const saved = localStorage.getItem('wissen-theme') || 'dunkel';
    const t = THEMES.find(t => t.id === saved) || THEMES[0];
    applyTheme(t);
  }, []);
}

export default function ThemePicker() {
  const [open, setOpen] = useState(false);
  const [current, setCurrent] = useState(localStorage.getItem('wissen-theme') || 'dunkel');

  const pick = (theme) => {
    setCurrent(theme.id);
    localStorage.setItem('wissen-theme', theme.id);
    applyTheme(theme);
    setOpen(false);
  };

  return (
    <div style={{ position: 'relative' }}>
      <button
        onClick={() => setOpen(v => !v)}
        title="Farbschema wählen"
        style={{
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          width: 34, height: 34, borderRadius: '50%',
          border: '1px solid var(--border)', background: 'var(--surface)',
          color: 'var(--accent)', transition: 'all 0.15s',
        }}
        onMouseEnter={e => e.currentTarget.style.background = 'var(--surface2)'}
        onMouseLeave={e => e.currentTarget.style.background = 'var(--surface)'}
      >
        <Palette size={15} />
      </button>

      {open && (
        <>
          <div onClick={() => setOpen(false)} style={{ position: 'fixed', inset: 0, zIndex: 99 }} />
          <div style={{
            position: 'absolute', top: 42, right: 0, zIndex: 100,
            background: 'var(--surface)', border: '1px solid var(--border)',
            borderRadius: 14, padding: '10px', boxShadow: '0 16px 48px #00000080',
            width: 230,
          }}>
            <div style={{ fontSize: 11, color: 'var(--text-muted)', marginBottom: 8, fontWeight: 600, letterSpacing: '0.06em', textTransform: 'uppercase', padding: '0 4px' }}>
              Farbschema
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
              {THEMES.map((t) => (
                <button
                  key={t.id}
                  onClick={() => pick(t)}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 10,
                    padding: '8px 8px', borderRadius: 9,
                    background: current === t.id ? t.accent + '18' : 'transparent',
                    border: current === t.id ? `1px solid ${t.accent}50` : '1px solid transparent',
                    textAlign: 'left', transition: 'all 0.12s', width: '100%',
                  }}
                  onMouseEnter={e => { if (current !== t.id) e.currentTarget.style.background = 'var(--surface2)'; }}
                  onMouseLeave={e => { if (current !== t.id) e.currentTarget.style.background = 'transparent'; }}
                >
                  {/* Mini-Vorschau: zeigt bg, surface und accent */}
                  <span style={{
                    width: 38, height: 26, borderRadius: 6, flexShrink: 0,
                    background: t.bg,
                    border: `2px solid ${current === t.id ? t.accent : t.border}`,
                    position: 'relative', overflow: 'hidden',
                    boxShadow: current === t.id ? `0 0 0 2px ${t.accent}40` : 'none',
                  }}>
                    {/* Surface-Streifen */}
                    <span style={{ position: 'absolute', bottom: 0, left: 0, right: 0, height: '45%', background: t.surface }} />
                    {/* Accent-Punkt */}
                    <span style={{ position: 'absolute', top: 4, right: 5, width: 6, height: 6, borderRadius: '50%', background: t.accent }} />
                  </span>
                  <span style={{ flex: 1, minWidth: 0 }}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                      <span style={{ fontSize: 13, fontWeight: current === t.id ? 700 : 500, color: current === t.id ? t.accent : 'var(--text)' }}>
                        {t.label}
                      </span>
                      {t.tag && (
                        <span style={{ fontSize: 9, padding: '1px 5px', borderRadius: 4, background: t.accent + '28', color: t.accent, fontWeight: 700, letterSpacing: '0.04em' }}>
                          {t.tag}
                        </span>
                      )}
                    </span>
                    <span style={{ display: 'block', fontSize: 11, color: 'var(--text-muted)', marginTop: 1 }}>{t.desc}</span>
                  </span>
                  {current === t.id && (
                    <span style={{ fontSize: 13, color: t.accent, flexShrink: 0 }}>✓</span>
                  )}
                </button>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
