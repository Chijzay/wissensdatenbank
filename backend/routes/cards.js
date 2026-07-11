import { Router } from 'express';
import { supabase } from '../supabase.js';
import { requireAuth } from '../middleware/auth.js';

const router = Router();
router.use(requireAuth);

router.get('/all', async (req, res) => {
  try {
    const { search, topic, bereich } = req.query;
    let query = supabase.from('cards').select('*, boxes!inner(name, color, icon, parent_id)').order('updated_at', { ascending: false });

    if (search) {
      query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%,tags.ilike.%${search}%`);
    }
    if (topic) {
      query = query.eq('box_id', topic);
    } else if (bereich) {
      const { data: children } = await supabase.from('boxes').select('id').eq('parent_id', bereich);
      const childIds = (children || []).map(b => b.id);
      const ids = [bereich, ...childIds];
      query = query.in('box_id', ids);
    }

    const { data, error } = await query;
    if (error) throw error;

    const cards = data.map(c => ({
      ...c,
      box_name: c.boxes.name,
      box_color: c.boxes.color,
      box_icon: c.boxes.icon,
      box_parent_id: c.boxes.parent_id,
      boxes: undefined,
      tags: JSON.parse(c.tags || '[]'),
    }));
    res.json(cards);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.get('/box/:boxId', async (req, res) => {
  try {
    const { search, tag, category } = req.query;
    let query = supabase.from('cards').select('*').eq('box_id', req.params.boxId).order('updated_at', { ascending: false });

    if (search) query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%,tags.ilike.%${search}%`);
    if (tag) query = query.ilike('tags', `%${tag}%`);
    if (category) query = query.eq('category', category);

    const { data: cards, error } = await query;
    if (error) throw error;

    const cardIds = cards.map(c => c.id);
    const { data: questions } = await supabase.from('card_questions').select('card_id, question').in('card_id', cardIds);

    const result = cards.map(c => ({
      ...c,
      tags: JSON.parse(c.tags || '[]'),
      questions: (questions || []).filter(q => q.card_id === c.id).map(q => q.question),
    }));
    res.json(result);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.get('/random/:boxId', async (req, res) => {
  try {
    const { data: cards } = await supabase.from('cards').select('id').eq('box_id', req.params.boxId);
    if (!cards?.length) return res.status(404).json({ error: 'Keine Karten vorhanden' });
    const randomId = cards[Math.floor(Math.random() * cards.length)].id;

    const { data: card, error } = await supabase.from('cards').select('*').eq('id', randomId).single();
    if (error) throw error;
    const { data: questions } = await supabase.from('card_questions').select('question').eq('card_id', card.id);
    card.tags = JSON.parse(card.tags || '[]');
    card.questions = (questions || []).map(q => q.question);
    res.json(card);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.get('/:id', async (req, res) => {
  try {
    const { data: card, error } = await supabase.from('cards').select('*').eq('id', req.params.id).single();
    if (error) return res.status(404).json({ error: 'Karte nicht gefunden' });

    const { data: questions } = await supabase.from('card_questions').select('question').eq('card_id', card.id);

    // Bidirektionale Links via UNION (beide Richtungen)
    const { data: linksA } = await supabase.from('card_links')
      .select('linked_card_id, cards!card_links_linked_card_id_fkey(id, title, category)')
      .eq('card_id', req.params.id);
    const { data: linksB } = await supabase.from('card_links')
      .select('card_id, cards!card_links_card_id_fkey(id, title, category)')
      .eq('linked_card_id', req.params.id);

    const seen = new Set();
    const links = [];
    for (const l of (linksA || [])) {
      const c = l.cards;
      if (c && !seen.has(c.id)) { seen.add(c.id); links.push(c); }
    }
    for (const l of (linksB || [])) {
      const c = l.cards;
      if (c && !seen.has(c.id)) { seen.add(c.id); links.push(c); }
    }

    card.tags = JSON.parse(card.tags || '[]');
    card.questions = (questions || []).map(q => q.question);
    card.links = links;
    res.json(card);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/', async (req, res) => {
  const { box_id, title, content = '', tags = [], category = '' } = req.body;
  if (!box_id || !title) return res.status(400).json({ error: 'box_id und title erforderlich' });
  try {
    const { data, error } = await supabase.from('cards')
      .insert({ box_id, title, content, tags: JSON.stringify(tags), category })
      .select().single();
    if (error) throw error;
    data.tags = JSON.parse(data.tags);
    data.questions = [];
    data.links = [];
    res.status(201).json(data);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.put('/:id', async (req, res) => {
  const { title, content, tags, category, box_id } = req.body;
  const updates = {};
  if (title !== undefined) updates.title = title;
  if (content !== undefined) updates.content = content;
  if (tags !== undefined) updates.tags = JSON.stringify(tags);
  if (category !== undefined) updates.category = category;
  if (box_id !== undefined) updates.box_id = box_id;
  try {
    const { data, error } = await supabase.from('cards').update(updates).eq('id', req.params.id).select().single();
    if (error) throw error;
    data.tags = JSON.parse(data.tags || '[]');
    res.json(data);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.delete('/:id', async (req, res) => {
  try {
    await supabase.from('cards').delete().eq('id', req.params.id);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/:id/questions', async (req, res) => {
  const { questions } = req.body;
  try {
    await supabase.from('card_questions').delete().eq('card_id', req.params.id);
    if (questions?.length) {
      await supabase.from('card_questions').insert(questions.map(q => ({ card_id: Number(req.params.id), question: q })));
    }
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

router.post('/link', async (req, res) => {
  const { card_id, linked_card_id } = req.body;
  try {
    await supabase.from('card_links').upsert({ card_id, linked_card_id }, { onConflict: 'card_id,linked_card_id', ignoreDuplicates: true });
    res.json({ ok: true });
  } catch (e) { res.status(400).json({ error: 'Link konnte nicht erstellt werden' }); }
});

router.delete('/link/:cardId/:linkedId', async (req, res) => {
  try {
    await supabase.from('card_links').delete()
      .or(`and(card_id.eq.${req.params.cardId},linked_card_id.eq.${req.params.linkedId}),and(card_id.eq.${req.params.linkedId},linked_card_id.eq.${req.params.cardId})`);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

export default router;
