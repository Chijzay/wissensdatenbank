import { Router } from 'express';
import db from '../database.js';

const router = Router();

router.get('/', (req, res) => {
  const boxes = db.prepare(`
    SELECT b.*,
      (SELECT COUNT(*) FROM cards c WHERE c.box_id = b.id) as direct_count,
      (SELECT COUNT(*) FROM cards c JOIN boxes sub ON sub.id = c.box_id WHERE sub.parent_id = b.id) as children_entry_count,
      (SELECT COUNT(*) FROM boxes child WHERE child.parent_id = b.id) as children_count
    FROM boxes b ORDER BY b.parent_id ASC, b.sort_order ASC, b.created_at ASC
  `).all().map(b => ({
    ...b,
    card_count: b.direct_count + (b.parent_id ? 0 : b.children_entry_count)
  }));
  res.json(boxes);
});

router.post('/', (req, res) => {
  const { name, description = '', color = '#6366f1', icon = '📦', parent_id = null } = req.body;
  if (!name) return res.status(400).json({ error: 'Name erforderlich' });
  const result = db.prepare(
    `INSERT INTO boxes (name, description, color, icon, parent_id) VALUES (?, ?, ?, ?, ?)`
  ).run(name, description, color, icon, parent_id || null);
  const box = db.prepare('SELECT * FROM boxes WHERE id = ?').get(result.lastInsertRowid);
  res.status(201).json(box);
});

router.put('/:id', (req, res) => {
  const { name, description, color, icon, parent_id } = req.body;
  db.prepare(
    `UPDATE boxes SET name = COALESCE(?, name), description = COALESCE(?, description),
     color = COALESCE(?, color), icon = COALESCE(?, icon),
     parent_id = CASE WHEN ? IS NOT NULL THEN ? ELSE parent_id END,
     updated_at = CURRENT_TIMESTAMP WHERE id = ?`
  ).run(name, description, color, icon, parent_id, parent_id, req.params.id);
  const box = db.prepare('SELECT * FROM boxes WHERE id = ?').get(req.params.id);
  res.json(box);
});

router.delete('/:id', (req, res) => {
  db.prepare('DELETE FROM boxes WHERE parent_id = ?').run(req.params.id);
  db.prepare('DELETE FROM boxes WHERE id = ?').run(req.params.id);
  res.json({ ok: true });
});

router.patch('/sort', (req, res) => {
  const { orders } = req.body; // [{ id, sort_order }]
  if (!Array.isArray(orders)) return res.status(400).json({ error: 'orders array required' });
  const stmt = db.prepare('UPDATE boxes SET sort_order = ? WHERE id = ?');
  for (const { id, sort_order } of orders) stmt.run(sort_order, id);
  res.json({ ok: true });
});

const AUTO_COLORS = ['#6366f1','#22c55e','#f59e0b','#ec4899','#14b8a6','#f97316','#8b5cf6','#06b6d4'];

router.post('/find-or-create', (req, res) => {
  const { name, parent_id } = req.body;
  if (!name?.trim()) return res.status(400).json({ error: 'Name erforderlich' });
  let box = db.prepare('SELECT * FROM boxes WHERE LOWER(name) = LOWER(?) AND (parent_id IS ? OR parent_id = ?)').get(name.trim(), parent_id || null, parent_id || null);
  if (!box) {
    const count = db.prepare('SELECT COUNT(*) as c FROM boxes').get().c;
    const color = AUTO_COLORS[count % AUTO_COLORS.length];
    const result = db.prepare('INSERT INTO boxes (name, color, icon, parent_id) VALUES (?, ?, ?, ?)').run(name.trim(), color, '📁', parent_id || null);
    box = db.prepare('SELECT * FROM boxes WHERE id = ?').get(result.lastInsertRowid);
  }
  res.json(box);
});

export default router;
