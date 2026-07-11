import { Router } from 'express';
import db from '../database.js';

const router = Router();

router.get('/all', (req, res) => {
  const { search, topic, bereich } = req.query;
  let query = `SELECT c.*, b.name as box_name, b.color as box_color, b.icon as box_icon, b.parent_id as box_parent_id
               FROM cards c JOIN boxes b ON b.id = c.box_id WHERE 1=1`;
  const params = [];
  if (search) {
    query += ` AND (c.title LIKE ? OR c.content LIKE ? OR c.tags LIKE ?)`;
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  if (topic) {
    query += ` AND c.box_id = ?`;
    params.push(topic);
  } else if (bereich) {
    query += ` AND (c.box_id = ? OR b.parent_id = ?)`;
    params.push(bereich, bereich);
  }
  query += ` ORDER BY c.updated_at DESC`;
  const cards = db.prepare(query).all(...params).map(c => ({ ...c, tags: JSON.parse(c.tags || '[]') }));
  res.json(cards);
});

router.get('/box/:boxId', (req, res) => {
  const { search, tag, category } = req.query;
  let query = `SELECT c.*, GROUP_CONCAT(DISTINCT cq.question) as questions
               FROM cards c
               LEFT JOIN card_questions cq ON cq.card_id = c.id
               WHERE c.box_id = ?`;
  const params = [req.params.boxId];

  if (search) {
    query += ` AND (c.title LIKE ? OR c.content LIKE ? OR c.tags LIKE ?)`;
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  if (tag) {
    query += ` AND c.tags LIKE ?`;
    params.push(`%${tag}%`);
  }
  if (category) {
    query += ` AND c.category = ?`;
    params.push(category);
  }
  query += ` GROUP BY c.id ORDER BY c.updated_at DESC`;

  const cards = db.prepare(query).all(...params).map(c => ({
    ...c,
    tags: JSON.parse(c.tags || '[]'),
    questions: c.questions ? c.questions.split(',') : []
  }));
  res.json(cards);
});

router.get('/random/:boxId', (req, res) => {
  const card = db.prepare(
    `SELECT * FROM cards WHERE box_id = ? ORDER BY RANDOM() LIMIT 1`
  ).get(req.params.boxId);
  if (!card) return res.status(404).json({ error: 'Keine Karten vorhanden' });
  card.tags = JSON.parse(card.tags || '[]');
  const questions = db.prepare('SELECT question FROM card_questions WHERE card_id = ?').all(card.id);
  card.questions = questions.map(q => q.question);
  res.json(card);
});

router.get('/:id', (req, res) => {
  const card = db.prepare('SELECT * FROM cards WHERE id = ?').get(req.params.id);
  if (!card) return res.status(404).json({ error: 'Karte nicht gefunden' });
  card.tags = JSON.parse(card.tags || '[]');
  const questions = db.prepare('SELECT question FROM card_questions WHERE card_id = ?').all(card.id);
  card.questions = questions.map(q => q.question);
  const links = db.prepare(`
    SELECT c.id, c.title, c.category FROM card_links cl
    JOIN cards c ON c.id = cl.linked_card_id
    WHERE cl.card_id = ?
    UNION
    SELECT c.id, c.title, c.category FROM card_links cl
    JOIN cards c ON c.id = cl.card_id
    WHERE cl.linked_card_id = ?
  `).all(card.id, card.id);
  card.links = links;
  res.json(card);
});

router.post('/', (req, res) => {
  const { box_id, title, content = '', tags = [], category = '' } = req.body;
  if (!box_id || !title) return res.status(400).json({ error: 'box_id und title erforderlich' });
  const result = db.prepare(
    `INSERT INTO cards (box_id, title, content, tags, category) VALUES (?, ?, ?, ?, ?)`
  ).run(box_id, title, content, JSON.stringify(tags), category);
  const card = db.prepare('SELECT * FROM cards WHERE id = ?').get(result.lastInsertRowid);
  card.tags = JSON.parse(card.tags);
  card.questions = [];
  card.links = [];
  res.status(201).json(card);
});

router.put('/:id', (req, res) => {
  const { title, content, tags, category, box_id } = req.body;
  db.prepare(
    `UPDATE cards SET title = COALESCE(?, title), content = COALESCE(?, content),
     tags = COALESCE(?, tags), category = COALESCE(?, category),
     box_id = COALESCE(?, box_id),
     updated_at = CURRENT_TIMESTAMP WHERE id = ?`
  ).run(title, content, tags ? JSON.stringify(tags) : null, category, box_id || null, req.params.id);
  const card = db.prepare('SELECT * FROM cards WHERE id = ?').get(req.params.id);
  card.tags = JSON.parse(card.tags || '[]');
  res.json(card);
});

router.delete('/:id', (req, res) => {
  db.prepare('DELETE FROM cards WHERE id = ?').run(req.params.id);
  res.json({ ok: true });
});

router.post('/:id/questions', (req, res) => {
  const { questions } = req.body;
  db.prepare('DELETE FROM card_questions WHERE card_id = ?').run(req.params.id);
  const insert = db.prepare('INSERT INTO card_questions (card_id, question) VALUES (?, ?)');
  for (const q of questions) insert.run(req.params.id, q);
  res.json({ ok: true });
});

router.post('/link', (req, res) => {
  const { card_id, linked_card_id } = req.body;
  try {
    db.prepare('INSERT OR IGNORE INTO card_links (card_id, linked_card_id) VALUES (?, ?)').run(card_id, linked_card_id);
    res.json({ ok: true });
  } catch {
    res.status(400).json({ error: 'Link konnte nicht erstellt werden' });
  }
});

router.delete('/link/:cardId/:linkedId', (req, res) => {
  db.prepare(`DELETE FROM card_links WHERE (card_id = ? AND linked_card_id = ?) OR (card_id = ? AND linked_card_id = ?)`
  ).run(req.params.cardId, req.params.linkedId, req.params.linkedId, req.params.cardId);
  res.json({ ok: true });
});

export default router;
