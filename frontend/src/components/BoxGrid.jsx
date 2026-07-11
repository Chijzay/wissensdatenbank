import { useState } from 'react';
import { Plus, X, Check } from 'lucide-react';
import { api } from '../api/client.js';

const COLORS = ['#6366f1','#22c55e','#f59e0b','#ec4899','#14b8a6','#f97316','#8b5cf6','#06b6d4'];
const ICONS  = ['📦','📚','🧬','🏠','💼','🎨','🔬','🍕','💡','🎯','🧠','⚡'];

export default function BoxGrid({ boxes, onSelectBox, onRefresh }) {
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState({ name: '', description: '', color: COLORS[0], icon: ICONS[0] });

  const save = async () => {
    if (!form.name.trim()) return;
    await api.boxes.create(form);
    setForm({ name: '', description: '', color: COLORS[0], icon: ICONS[0] });
    setCreating(false);
    onRefresh();
  };

  const deleteBox = async (e, id) => {
    e.stopPropagation();
    if (!confirm('Box und alle Karten löschen?')) return;
    await api.boxes.delete(id);
    onRefresh();
  };

  return (
    <div style={{ maxWidth: 1100, margin: '0 auto', padding: '48px 24px' }}>
      <div style={{ marginBottom: 40 }}>
        <h1 style={{ fontSize: 32, fontWeight: 700, letterSpacing: '-0.5px' }}>Mein Wissen</h1>
        <p style={{ color: 'var(--text-muted)', marginTop: 6 }}>Wähle eine Box oder erstelle eine neue</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: 16 }}>
        {boxes.map(box => (
          <div key={box.id} onClick={() => onSelectBox(box)}
            style={{
              background: 'var(--surface)', border: '1px solid var(--border)',
              borderRadius: 'var(--radius)', padding: '24px 20px',
              cursor: 'pointer', position: 'relative',
              borderTop: `3px solid ${box.color}`,
              transition: 'transform 0.15s, box-shadow 0.15s',
            }}
            onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = `0 8px 24px ${box.color}22`; }}
            onMouseLeave={e => { e.currentTarget.style.transform = ''; e.currentTarget.style.boxShadow = ''; }}
          >
            <button onClick={e => deleteBox(e, box.id)}
              style={{ position: 'absolute', top: 12, right: 12, color: 'var(--text-muted)', padding: 4, borderRadius: 6 }}
              onMouseEnter={e => e.currentTarget.style.color = 'var(--danger)'}
              onMouseLeave={e => e.currentTarget.style.color = 'var(--text-muted)'}
            >
              <X size={14} />
            </button>
            <div style={{ fontSize: 32, marginBottom: 12 }}>{box.icon}</div>
            <div style={{ fontWeight: 600, fontSize: 17 }}>{box.name}</div>
            {box.description && <div style={{ color: 'var(--text-muted)', fontSize: 13, marginTop: 4 }}>{box.description}</div>}
            <div style={{ marginTop: 16, color: 'var(--text-muted)', fontSize: 13 }}>
              {box.card_count} {box.card_count === 1 ? 'Karte' : 'Karten'}
            </div>
          </div>
        ))}

        {creating ? (
          <div style={{ background: 'var(--surface)', border: '1px solid var(--accent)', borderRadius: 'var(--radius)', padding: '20px' }}>
            <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexWrap: 'wrap' }}>
              {ICONS.map(ic => (
                <button key={ic} onClick={() => setForm(f => ({ ...f, icon: ic }))}
                  style={{ fontSize: 20, padding: 4, borderRadius: 6, background: form.icon === ic ? 'var(--surface2)' : 'none', opacity: form.icon === ic ? 1 : 0.5 }}>
                  {ic}
                </button>
              ))}
            </div>
            <div style={{ display: 'flex', gap: 6, marginBottom: 12, flexWrap: 'wrap' }}>
              {COLORS.map(c => (
                <button key={c} onClick={() => setForm(f => ({ ...f, color: c }))}
                  style={{ width: 22, height: 22, borderRadius: '50%', background: c, border: form.color === c ? '2px solid white' : '2px solid transparent' }} />
              ))}
            </div>
            <input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))}
              placeholder="Box-Name" onKeyDown={e => e.key === 'Enter' && save()}
              style={{ width: '100%', background: 'var(--surface2)', padding: '8px 12px', borderRadius: 8, marginBottom: 8, border: '1px solid var(--border)' }} autoFocus />
            <input value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
              placeholder="Beschreibung (optional)"
              style={{ width: '100%', background: 'var(--surface2)', padding: '8px 12px', borderRadius: 8, border: '1px solid var(--border)' }} />
            <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              <button onClick={save} style={{ flex: 1, background: 'var(--accent)', color: 'white', padding: '8px', borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                <Check size={14} /> Erstellen
              </button>
              <button onClick={() => setCreating(false)} style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)' }}>
                Abbruch
              </button>
            </div>
          </div>
        ) : (
          <button onClick={() => setCreating(true)}
            style={{ background: 'var(--surface)', border: '1px dashed var(--border)', borderRadius: 'var(--radius)', padding: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 10, color: 'var(--text-muted)', minHeight: 140, transition: 'border-color 0.15s, color 0.15s' }}
            onMouseEnter={e => { e.currentTarget.style.borderColor = 'var(--accent)'; e.currentTarget.style.color = 'var(--accent)'; }}
            onMouseLeave={e => { e.currentTarget.style.borderColor = 'var(--border)'; e.currentTarget.style.color = 'var(--text-muted)'; }}
          >
            <Plus size={24} />
            <span style={{ fontSize: 14 }}>Neue Box</span>
          </button>
        )}
      </div>
    </div>
  );
}
