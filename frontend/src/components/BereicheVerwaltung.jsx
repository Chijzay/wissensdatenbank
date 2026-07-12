import { useState, useEffect, useCallback } from 'react';
import { ArrowLeft, Plus, Trash2, GripVertical, ChevronRight, Check, X } from 'lucide-react';
import {
  DndContext, closestCenter, PointerSensor, TouchSensor,
  useSensor, useSensors,
} from '@dnd-kit/core';
import {
  SortableContext, verticalListSortingStrategy,
  useSortable, arrayMove,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { api } from '../api/client.js';

const COLORS = [
  '#6366f1','#8b5cf6','#ec4899','#ef4444','#f97316',
  '#f59e0b','#22c55e','#14b8a6','#06b6d4','#3b82f6',
  '#64748b','#a855f7','#10b981','#e11d48','#0ea5e9',
];

const ICONS = [
  '📁','📂','📚','📖','📝','✏️','🗒️','📋','📌','📍',
  '🔬','🔭','🧪','🧬','💡','🔧','⚙️','🖥️','📱','💻',
  '🎓','🏫','🎯','🏆','🌟','⭐','🚀','🎨','🎵','🎮',
  '💼','📊','💰','🏦','📈','🌍','🌿','❤️','🧠','🔑',
  '📷','🎬','🔐','⚡','🌈','🦋','🐉','🏔️','🌊','🔥',
];

function ColorPicker({ selected, onChange, onClose }) {
  return (
    <div style={{ position: 'absolute', top: 'calc(100% + 6px)', left: 0, zIndex: 300,
      background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10,
      padding: 10, boxShadow: '0 8px 24px #00000066', display: 'grid',
      gridTemplateColumns: 'repeat(5, 24px)', gap: 6 }}
      onMouseDown={e => e.stopPropagation()}>
      {COLORS.map(c => (
        <button key={c} onClick={() => { onChange(c); onClose(); }}
          style={{ width: 24, height: 24, borderRadius: 6, background: c,
            border: selected === c ? '2px solid white' : '2px solid transparent',
            boxShadow: selected === c ? `0 0 0 2px ${c}` : 'none' }} />
      ))}
    </div>
  );
}

function IconPicker({ onChange, onClose }) {
  return (
    <div style={{ position: 'absolute', top: 'calc(100% + 6px)', left: 0, zIndex: 300,
      background: 'var(--surface)', border: '1px solid var(--border)', borderRadius: 10,
      padding: 10, boxShadow: '0 8px 24px #00000066',
      display: 'grid', gridTemplateColumns: 'repeat(10, 28px)', gap: 4, maxWidth: 340 }}
      onMouseDown={e => e.stopPropagation()}>
      {ICONS.map(ic => (
        <button key={ic} onClick={() => { onChange(ic); onClose(); }}
          style={{ fontSize: 18, width: 28, height: 28, borderRadius: 6,
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}
          onMouseEnter={e => e.currentTarget.style.background = 'var(--surface2)'}
          onMouseLeave={e => e.currentTarget.style.background = 'transparent'}>
          {ic}
        </button>
      ))}
    </div>
  );
}

function SortableRow({ id, children }) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id });
  return (
    <div ref={setNodeRef}
      style={{ transform: CSS.Transform.toString(transform), transition, opacity: isDragging ? 0.5 : 1 }}>
      {children({ gripRef: setNodeRef, gripProps: { ...attributes, ...listeners } })}
    </div>
  );
}

export default function BereicheVerwaltung({ onClose }) {
  const [bereiche, setBereiche] = useState([]);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState(new Set());
  const [editingId, setEditingId] = useState(null);
  const [editName, setEditName] = useState('');
  const [colorPickerId, setColorPickerId] = useState(null);
  const [iconPickerId, setIconPickerId] = useState(null);
  const [confirm, setConfirm] = useState(null);
  const [saving, setSaving] = useState(null);
  const [newBoxParentId, setNewBoxParentId] = useState(null);
  const [newBoxName, setNewBoxName] = useState('');
  const [newBoxIcon, setNewBoxIcon] = useState('📁');
  const [newBoxColor, setNewBoxColor] = useState(COLORS[0]);

  const load = useCallback(async () => {
    const boxes = await api.boxes.list();
    const top = boxes.filter(b => !b.parent_id).map(b => ({
      ...b,
      children: boxes.filter(c => c.parent_id === b.id),
    }));
    setBereiche(top);
    setLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  // Close pickers on outside click
  useEffect(() => {
    if (!colorPickerId && !iconPickerId) return;
    const h = () => { setColorPickerId(null); setIconPickerId(null); };
    document.addEventListener('mousedown', h);
    return () => document.removeEventListener('mousedown', h);
  }, [colorPickerId, iconPickerId]);

  const dndSensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 6 } }),
    useSensor(TouchSensor, { activationConstraint: { delay: 200, tolerance: 8 } }),
  );

  const saveField = async (id, field, value) => {
    setSaving(id);
    await api.boxes.update(id, { [field]: value });
    await load();
    setSaving(null);
  };

  const commitRename = async (id) => {
    if (editName.trim()) await saveField(id, 'name', editName.trim());
    setEditingId(null);
  };

  const handleBereichDragEnd = async ({ active, over }) => {
    if (!over || active.id === over.id) return;
    const oldIdx = bereiche.findIndex(b => b.id === active.id);
    const newIdx = bereiche.findIndex(b => b.id === over.id);
    const reordered = arrayMove(bereiche, oldIdx, newIdx);
    setBereiche(reordered);
    await api.boxes.sort(reordered.map((b, i) => ({ id: b.id, sort_order: i + 1 })));
  };

  const handleSubDragEnd = async ({ active, over }, parentId) => {
    if (!over || active.id === over.id) return;
    setBereiche(prev => prev.map(b => {
      if (b.id !== parentId) return b;
      const oldIdx = b.children.findIndex(c => c.id === active.id);
      const newIdx = b.children.findIndex(c => c.id === over.id);
      return { ...b, children: arrayMove(b.children, oldIdx, newIdx) };
    }));
    const bereich = bereiche.find(b => b.id === parentId);
    if (!bereich) return;
    const oldIdx = bereich.children.findIndex(c => c.id === active.id);
    const newIdx = bereich.children.findIndex(c => c.id === over.id);
    const reordered = arrayMove(bereich.children, oldIdx, newIdx);
    await api.boxes.sort(reordered.map((b, i) => ({ id: b.id, sort_order: i + 1 })));
  };

  const deleteBox = async (box) => {
    await api.boxes.delete(box.id);
    setConfirm(null);
    await load();
  };

  const createSubBox = async (parentId) => {
    if (!newBoxName.trim()) return;
    await api.boxes.create({ name: newBoxName.trim(), icon: newBoxIcon, color: newBoxColor, parent_id: parentId });
    setNewBoxParentId(null);
    setNewBoxName('');
    setNewBoxIcon('📁');
    setNewBoxColor(COLORS[0]);
    await load();
  };

  const createBereich = async () => {
    await api.boxes.create({ name: 'Neuer Bereich', icon: '📁', color: COLORS[bereiche.length % COLORS.length], parent_id: null });
    await load();
  };

  const totalEntries = bereiche.reduce((s, b) => s + (b.card_count ?? 0), 0);

  if (loading) return (
    <div style={{ maxWidth: 780, margin: '0 auto', padding: '40px 20px', textAlign: 'center', color: 'var(--text-muted)' }}>
      Laden…
    </div>
  );

  return (
    <div style={{ maxWidth: 780, margin: '0 auto', padding: '28px 20px 60px' }}>

      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 28 }}>
        <button onClick={onClose}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '7px 14px', borderRadius: 8,
            border: '1px solid var(--border)', color: 'var(--text-muted)', fontSize: 13 }}>
          <ArrowLeft size={14} /> Zurück
        </button>
        <div style={{ flex: 1 }}>
          <h1 style={{ fontSize: 22, fontWeight: 700 }}>Bereiche verwalten</h1>
          <p style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>
            {bereiche.length} Bereiche · {totalEntries} Einträge gesamt
          </p>
        </div>
        <button onClick={createBereich}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 16px', borderRadius: 10,
            background: 'var(--accent)', color: 'white', fontWeight: 600, fontSize: 14 }}>
          <Plus size={14} /> Neuer Bereich
        </button>
      </div>

      {/* Bereiche-Liste */}
      <DndContext sensors={dndSensors} collisionDetection={closestCenter} onDragEnd={handleBereichDragEnd}>
        <SortableContext items={bereiche.map(b => b.id)} strategy={verticalListSortingStrategy}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {bereiche.map(bereich => {
              const isExpanded = expanded.has(bereich.id);
              const isEditing = editingId === bereich.id;
              const isSaving = saving === bereich.id;

              return (
                <SortableRow key={bereich.id} id={bereich.id}>
                  {({ gripProps }) => (
                    <div style={{ background: 'var(--surface)', border: `2px solid ${bereich.color}44`,
                      borderRadius: 14, overflow: 'visible' }}>

                      {/* Bereich-Zeile */}
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                        borderLeft: `4px solid ${bereich.color}` }}>

                        {/* Grip */}
                        <button {...gripProps} style={{ color: 'var(--text-muted)', opacity: 0.35, cursor: 'grab',
                          padding: 4, touchAction: 'none', flexShrink: 0 }}
                          onMouseEnter={e => e.currentTarget.style.opacity = '0.8'}
                          onMouseLeave={e => e.currentTarget.style.opacity = '0.35'}>
                          <GripVertical size={16} />
                        </button>

                        {/* Icon-Picker */}
                        <div style={{ position: 'relative', flexShrink: 0 }}>
                          <button onClick={() => setIconPickerId(prev => prev === bereich.id ? null : bereich.id)}
                            style={{ fontSize: 22, width: 38, height: 38, borderRadius: 10,
                              background: bereich.color + '22', border: `1px solid ${bereich.color}44`,
                              display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                            {bereich.icon}
                          </button>
                          {iconPickerId === bereich.id && (
                            <IconPicker
                              onChange={ic => saveField(bereich.id, 'icon', ic)}
                              onClose={() => setIconPickerId(null)} />
                          )}
                        </div>

                        {/* Color-Picker */}
                        <div style={{ position: 'relative', flexShrink: 0 }}>
                          <button onClick={() => setColorPickerId(prev => prev === bereich.id ? null : bereich.id)}
                            style={{ width: 22, height: 22, borderRadius: 6, background: bereich.color,
                              border: '2px solid var(--border)' }}
                            title="Farbe ändern" />
                          {colorPickerId === bereich.id && (
                            <ColorPicker
                              selected={bereich.color}
                              onChange={c => saveField(bereich.id, 'color', c)}
                              onClose={() => setColorPickerId(null)} />
                          )}
                        </div>

                        {/* Name */}
                        <div style={{ flex: 1, minWidth: 0 }}>
                          {isEditing ? (
                            <div style={{ display: 'flex', gap: 6 }}>
                              <input autoFocus value={editName}
                                onChange={e => setEditName(e.target.value)}
                                onKeyDown={e => { if (e.key === 'Enter') commitRename(bereich.id); if (e.key === 'Escape') setEditingId(null); }}
                                style={{ flex: 1, padding: '4px 8px', borderRadius: 6, border: `1px solid ${bereich.color}`,
                                  background: 'var(--bg)', color: 'var(--text)', fontSize: 15, fontWeight: 700 }} />
                              <button onClick={() => commitRename(bereich.id)}
                                style={{ padding: '4px 8px', borderRadius: 6, background: bereich.color, color: 'white' }}>
                                <Check size={14} />
                              </button>
                              <button onClick={() => setEditingId(null)}
                                style={{ padding: '4px 8px', borderRadius: 6, border: '1px solid var(--border)', color: 'var(--text-muted)' }}>
                                <X size={14} />
                              </button>
                            </div>
                          ) : (
                            <button onClick={() => { setEditingId(bereich.id); setEditName(bereich.name); }}
                              style={{ textAlign: 'left', fontWeight: 700, fontSize: 15, color: 'var(--text)',
                                opacity: isSaving ? 0.5 : 1 }}
                              title="Klicken zum Umbenennen">
                              {bereich.name}
                            </button>
                          )}
                          <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>
                            {bereich.card_count ?? 0} Einträge
                            {bereich.children.length > 0 && ` · ${bereich.children.length} Boxen`}
                          </div>
                        </div>

                        {/* Expand sub-boxes */}
                        {bereich.children.length > 0 && (
                          <button onClick={() => setExpanded(prev => { const n = new Set(prev); n.has(bereich.id) ? n.delete(bereich.id) : n.add(bereich.id); return n; })}
                            style={{ padding: 6, borderRadius: 6, color: 'var(--text-muted)',
                              transition: 'transform 0.2s', transform: isExpanded ? 'rotate(90deg)' : 'none' }}
                            title="Boxen anzeigen">
                            <ChevronRight size={15} />
                          </button>
                        )}

                        {/* Box hinzufügen */}
                        <button onClick={() => { setNewBoxParentId(bereich.id); setExpanded(prev => new Set([...prev, bereich.id])); setNewBoxName(''); setNewBoxIcon('📁'); setNewBoxColor(bereich.color); }}
                          style={{ padding: 6, borderRadius: 6, color: 'var(--text-muted)', fontSize: 13 }}
                          title="Box hinzufügen"
                          onMouseEnter={e => { e.currentTarget.style.color = bereich.color; e.currentTarget.style.background = bereich.color + '22'; }}
                          onMouseLeave={e => { e.currentTarget.style.color = 'var(--text-muted)'; e.currentTarget.style.background = 'transparent'; }}>
                          <Plus size={15} />
                        </button>

                        {/* Löschen */}
                        <button onClick={() => setConfirm({ type: 'bereich', item: bereich })}
                          style={{ padding: 6, borderRadius: 6, color: 'var(--text-muted)' }}
                          onMouseEnter={e => { e.currentTarget.style.color = 'var(--danger)'; e.currentTarget.style.background = '#ef444422'; }}
                          onMouseLeave={e => { e.currentTarget.style.color = 'var(--text-muted)'; e.currentTarget.style.background = 'transparent'; }}>
                          <Trash2 size={15} />
                        </button>
                      </div>

                      {/* Sub-Boxen */}
                      {isExpanded && (
                        <div style={{ borderTop: `1px solid ${bereich.color}22`, padding: '8px 12px 12px' }}>
                          <DndContext sensors={dndSensors} collisionDetection={closestCenter}
                            onDragEnd={e => handleSubDragEnd(e, bereich.id)}>
                            <SortableContext items={bereich.children.map(c => c.id)} strategy={verticalListSortingStrategy}>
                              <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                                {bereich.children.map(box => (
                                  <SortableRow key={box.id} id={box.id}>
                                    {({ gripProps: subGripProps }) => (
                                      <div style={{ display: 'flex', alignItems: 'center', gap: 8,
                                        padding: '8px 10px', borderRadius: 10, background: 'var(--surface2)',
                                        border: `1px solid ${box.color}33` }}>
                                        <button {...subGripProps} style={{ color: 'var(--text-muted)', opacity: 0.3,
                                          cursor: 'grab', padding: 2, touchAction: 'none' }}>
                                          <GripVertical size={14} />
                                        </button>

                                        {/* Icon */}
                                        <div style={{ position: 'relative' }}>
                                          <button onClick={() => setIconPickerId(prev => prev === `sub-${box.id}` ? null : `sub-${box.id}`)}
                                            style={{ fontSize: 16 }}>
                                            {box.icon}
                                          </button>
                                          {iconPickerId === `sub-${box.id}` && (
                                            <IconPicker onChange={ic => saveField(box.id, 'icon', ic)}
                                              onClose={() => setIconPickerId(null)} />
                                          )}
                                        </div>

                                        {/* Color dot */}
                                        <div style={{ position: 'relative' }}>
                                          <button onClick={() => setColorPickerId(prev => prev === `sub-${box.id}` ? null : `sub-${box.id}`)}
                                            style={{ width: 14, height: 14, borderRadius: 4, background: box.color, border: '2px solid var(--border)' }} />
                                          {colorPickerId === `sub-${box.id}` && (
                                            <ColorPicker selected={box.color}
                                              onChange={c => saveField(box.id, 'color', c)}
                                              onClose={() => setColorPickerId(null)} />
                                          )}
                                        </div>

                                        {/* Name */}
                                        {editingId === box.id ? (
                                          <div style={{ display: 'flex', gap: 4, flex: 1 }}>
                                            <input autoFocus value={editName}
                                              onChange={e => setEditName(e.target.value)}
                                              onKeyDown={e => { if (e.key === 'Enter') commitRename(box.id); if (e.key === 'Escape') setEditingId(null); }}
                                              style={{ flex: 1, padding: '3px 7px', borderRadius: 6, border: `1px solid ${box.color}`,
                                                background: 'var(--bg)', color: 'var(--text)', fontSize: 13 }} />
                                            <button onClick={() => commitRename(box.id)}
                                              style={{ padding: '3px 7px', borderRadius: 6, background: box.color, color: 'white' }}>
                                              <Check size={12} />
                                            </button>
                                            <button onClick={() => setEditingId(null)}
                                              style={{ padding: '3px 7px', borderRadius: 6, border: '1px solid var(--border)', color: 'var(--text-muted)' }}>
                                              <X size={12} />
                                            </button>
                                          </div>
                                        ) : (
                                          <button onClick={() => { setEditingId(box.id); setEditName(box.name); }}
                                            style={{ flex: 1, textAlign: 'left', fontSize: 13, fontWeight: 500, color: 'var(--text)' }}
                                            title="Klicken zum Umbenennen">
                                            {box.name}
                                          </button>
                                        )}

                                        <span style={{ fontSize: 11, color: 'var(--text-muted)', flexShrink: 0 }}>
                                          {box.card_count ?? 0} Eintr.
                                        </span>

                                        <button onClick={() => setConfirm({ type: 'box', item: box })}
                                          style={{ padding: 4, borderRadius: 6, color: 'var(--text-muted)', flexShrink: 0 }}
                                          onMouseEnter={e => { e.currentTarget.style.color = 'var(--danger)'; }}
                                          onMouseLeave={e => { e.currentTarget.style.color = 'var(--text-muted)'; }}>
                                          <Trash2 size={13} />
                                        </button>
                                      </div>
                                    )}
                                  </SortableRow>
                                ))}
                              </div>
                            </SortableContext>
                          </DndContext>

                          {/* Neue Sub-Box */}
                          {newBoxParentId === bereich.id ? (
                            <div style={{ display: 'flex', gap: 6, marginTop: 8, alignItems: 'center' }}>
                              <div style={{ position: 'relative' }}>
                                <button onClick={() => setIconPickerId(prev => prev === 'new' ? null : 'new')}
                                  style={{ fontSize: 18, padding: 4 }}>{newBoxIcon}</button>
                                {iconPickerId === 'new' && (
                                  <IconPicker onChange={ic => { setNewBoxIcon(ic); setIconPickerId(null); }}
                                    onClose={() => setIconPickerId(null)} />
                                )}
                              </div>
                              <input autoFocus value={newBoxName} onChange={e => setNewBoxName(e.target.value)}
                                onKeyDown={e => { if (e.key === 'Enter') createSubBox(bereich.id); if (e.key === 'Escape') setNewBoxParentId(null); }}
                                placeholder="Box-Name…"
                                style={{ flex: 1, padding: '6px 10px', borderRadius: 8, border: `1px solid ${bereich.color}`,
                                  background: 'var(--bg)', color: 'var(--text)', fontSize: 13 }} />
                              <button onClick={() => createSubBox(bereich.id)}
                                style={{ padding: '6px 14px', borderRadius: 8, background: bereich.color, color: 'white', fontWeight: 600, fontSize: 13 }}>
                                Erstellen
                              </button>
                              <button onClick={() => setNewBoxParentId(null)}
                                style={{ padding: '6px 10px', borderRadius: 8, border: '1px solid var(--border)', color: 'var(--text-muted)' }}>
                                <X size={14} />
                              </button>
                            </div>
                          ) : (
                            <button onClick={() => { setNewBoxParentId(bereich.id); setNewBoxName(''); setNewBoxColor(bereich.color); }}
                              style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 8,
                                padding: '6px 12px', borderRadius: 8, border: `1px dashed ${bereich.color}66`,
                                color: bereich.color, fontSize: 12, width: '100%' }}>
                              <Plus size={13} /> Box hinzufügen
                            </button>
                          )}
                        </div>
                      )}
                    </div>
                  )}
                </SortableRow>
              );
            })}
          </div>
        </SortableContext>
      </DndContext>

      {bereiche.length === 0 && (
        <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-muted)' }}>
          <div style={{ fontSize: 40, marginBottom: 12 }}>📂</div>
          <div>Noch keine Bereiche vorhanden.</div>
          <button onClick={createBereich}
            style={{ marginTop: 16, padding: '10px 20px', borderRadius: 10,
              background: 'var(--accent)', color: 'white', fontWeight: 600 }}>
            Ersten Bereich erstellen
          </button>
        </div>
      )}

      {/* Löschen-Bestätigung */}
      {confirm && (
        <div style={{ position: 'fixed', inset: 0, background: '#00000077', zIndex: 500,
          display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20 }}>
          <div style={{ background: 'var(--surface)', borderRadius: 16, padding: '24px 28px',
            maxWidth: 420, width: '100%', border: '1px solid var(--border)' }}>
            <div style={{ fontWeight: 700, fontSize: 17, marginBottom: 10 }}>
              {confirm.type === 'bereich' ? 'Bereich löschen?' : 'Box löschen?'}
            </div>
            <div style={{ color: 'var(--text-muted)', fontSize: 14, marginBottom: 20 }}>
              {confirm.type === 'bereich'
                ? <>„{confirm.item.name}" und alle enthaltenen Boxen werden gelöscht. <strong style={{ color: 'var(--danger)' }}>Einträge bleiben erhalten.</strong></>
                : <>„{confirm.item.name}" wird gelöscht. <strong style={{ color: 'var(--danger)' }}>Einträge in dieser Box bleiben erhalten.</strong></>}
            </div>
            <div style={{ display: 'flex', gap: 10 }}>
              <button onClick={() => deleteBox(confirm.item)}
                style={{ flex: 1, padding: 10, borderRadius: 10, background: 'var(--danger)',
                  color: 'white', fontWeight: 700, fontSize: 14 }}>
                Löschen
              </button>
              <button onClick={() => setConfirm(null)}
                style={{ padding: '10px 16px', borderRadius: 10, border: '1px solid var(--border)',
                  color: 'var(--text-muted)', fontSize: 14 }}>
                Abbrechen
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
