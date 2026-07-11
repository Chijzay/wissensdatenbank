import { Router } from 'express';
import { supabase } from '../supabase.js';
import { requireAuth } from '../middleware/auth.js';

const router = Router();
router.use(requireAuth);

const AUTO_COLORS = ['#6366f1','#22c55e','#f59e0b','#ec4899','#14b8a6','#f97316','#8b5cf6','#06b6d4'];

router.get('/', async (req, res) => {
  try {
    const { data: boxes, error: bErr } = await supabase.from('boxes').select('*').order('sort_order').order('created_at');
    if (bErr) throw bErr;
    const { data: cards, error: cErr } = await supabase.from('cards').select('id, box_id');
    if (cErr) throw cErr;

    const result = boxes.map(b => {
      const directCount = cards.filter(c => c.box_id === b.id).length;
      const childIds = boxes.filter(c => c.parent_id === b.id).map(c => c.id);
      const childEntryCount = cards.filter(c => childIds.includes(c.box_id)).length;
      const childrenCount = childIds.length;
      return {
        ...b,
        direct_count: directCount,
        children_entry_count: childEntryCount,
        children_count: childrenCount,
        card_count: directCount + (b.parent_id ? 0 : childEntryCount),
      };
    });

    result.sort((a, b) => {
      if ((a.parent_id || 0) !== (b.parent_id || 0)) return (a.parent_id || 0) - (b.parent_id || 0);
      if (a.sort_order !== b.sort_order) return a.sort_order - b.sort_order;
      return new Date(a.created_at) - new Date(b.created_at);
    });

    res.json(result);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/', async (req, res) => {
  const { name, description = '', color = '#6366f1', icon = '📦', parent_id = null } = req.body;
  if (!name) return res.status(400).json({ error: 'Name erforderlich' });
  try {
    const { data, error } = await supabase.from('boxes')
      .insert({ name, description, color, icon, parent_id: parent_id || null })
      .select().single();
    if (error) throw error;
    res.status(201).json(data);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.put('/:id', async (req, res) => {
  const { name, description, color, icon, parent_id } = req.body;
  const updates = {};
  if (name !== undefined) updates.name = name;
  if (description !== undefined) updates.description = description;
  if (color !== undefined) updates.color = color;
  if (icon !== undefined) updates.icon = icon;
  if (parent_id !== undefined) updates.parent_id = parent_id;
  try {
    const { data, error } = await supabase.from('boxes').update(updates).eq('id', req.params.id).select().single();
    if (error) throw error;
    res.json(data);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.delete('/:id', async (req, res) => {
  try {
    await supabase.from('boxes').delete().eq('parent_id', req.params.id);
    await supabase.from('boxes').delete().eq('id', req.params.id);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.patch('/sort', async (req, res) => {
  const { orders } = req.body;
  if (!Array.isArray(orders)) return res.status(400).json({ error: 'orders array required' });
  try {
    await Promise.all(orders.map(({ id, sort_order }) =>
      supabase.from('boxes').update({ sort_order }).eq('id', id)
    ));
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/find-or-create', async (req, res) => {
  const { name, parent_id } = req.body;
  if (!name?.trim()) return res.status(400).json({ error: 'Name erforderlich' });
  try {
    let query = supabase.from('boxes').select('*').ilike('name', name.trim());
    if (parent_id) query = query.eq('parent_id', parent_id);
    else query = query.is('parent_id', null);

    const { data: existing } = await query.maybeSingle();
    if (existing) return res.json(existing);

    const { data: all } = await supabase.from('boxes').select('id');
    const color = AUTO_COLORS[(all?.length || 0) % AUTO_COLORS.length];
    const { data, error } = await supabase.from('boxes')
      .insert({ name: name.trim(), color, icon: '📁', parent_id: parent_id || null })
      .select().single();
    if (error) throw error;
    res.json(data);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

export default router;
