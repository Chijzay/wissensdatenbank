import { Router } from 'express';
import Anthropic from '@anthropic-ai/sdk';
import db from '../database.js';

const router = Router();

function getClient() {
  const key = process.env.ANTHROPIC_API_KEY;
  if (!key || key.includes('HIER_DEINEN')) {
    throw new Error('Kein gültiger ANTHROPIC_API_KEY in backend/.env eingetragen.');
  }
  return new Anthropic({ apiKey: key });
}

async function callAI(messages, maxTokens = 512) {
  const client = getClient();
  const response = await client.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: maxTokens,
    messages,
  });
  return response.content[0].text.trim();
}

function parseJSON(text) {
  // Strip markdown code fences
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  const cleaned = (fenced ? fenced[1] : text).trim();
  try {
    return JSON.parse(cleaned);
  } catch {
    // AI added trailing text after the JSON — extract first array or object
    const arr = cleaned.match(/\[[\s\S]*?\]/);
    const obj = cleaned.match(/\{[\s\S]*?\}/);
    const found = arr || obj;
    if (found) return JSON.parse(found[0]);
    throw new Error('Kein gültiges JSON in der KI-Antwort: ' + cleaned.slice(0, 80));
  }
}

router.post('/generate-questions', async (req, res) => {
  try {
    const { card_id, title, content } = req.body;
    const text = await callAI([{
      role: 'user',
      content: `Generiere 3 prägnante Lernfragen zu folgendem Notizzettel. Die Fragen sollen das Verständnis prüfen, nicht nur das Auswendiglernen. Antworte NUR mit einem JSON-Array von Strings, z.B. ["Frage 1?", "Frage 2?", "Frage 3?"].

Titel: ${title}
Inhalt: ${content}`
    }]);
    const questions = parseJSON(text);
    if (card_id) {
      db.prepare('DELETE FROM card_questions WHERE card_id = ?').run(card_id);
      const insert = db.prepare('INSERT INTO card_questions (card_id, question) VALUES (?, ?)');
      for (const q of questions) insert.run(card_id, q);
    }
    res.json({ questions });
  } catch (err) {
    console.error('[AI /generate-questions]', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/suggest-tags', async (req, res) => {
  try {
    const { title, content } = req.body;
    const text = await callAI([{
      role: 'user',
      content: `Schlage 3-5 präzise Tags (einzelne Wörter oder kurze Phrasen, Deutsch oder Englisch je nach Fachgebiet) für diesen Eintrag vor. Antworte NUR mit einem JSON-Array: ["Tag1","Tag2","Tag3"].

Titel: ${title}
Inhalt: ${content?.slice(0, 400) || ''}`
    }], 128);
    res.json({ tags: parseJSON(text) });
  } catch (err) {
    console.error('[AI /suggest-tags]', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/suggest-links', async (req, res) => {
  try {
    const { card_id, title, content } = req.body;
    const allCards = db.prepare(
      `SELECT c.id, c.title, c.content, b.name as box_name FROM cards c
       JOIN boxes b ON b.id = c.box_id
       WHERE c.id != ? ORDER BY c.updated_at DESC LIMIT 60`
    ).all(card_id || 0);

    if (allCards.length === 0) return res.json({ suggestions: [] });

    const cardList = allCards.map(c => `ID ${c.id} [${c.box_name}]: ${c.title} – ${c.content.slice(0, 80)}`).join('\n');
    const text = await callAI([{
      role: 'user',
      content: `Welche der folgenden Einträge sind thematisch verwandt mit dem aktuellen Eintrag? Antworte NUR mit einem JSON-Array der IDs, z.B. [2, 5]. Maximal 4 Vorschläge. Wenn keine passen, antworte mit [].

Aktueller Eintrag:
Titel: ${title}
Inhalt: ${content.slice(0, 300)}

Verfügbare Einträge:
${cardList}`
    }], 256);

    const ids = parseJSON(text);
    const suggestions = allCards.filter(c => ids.includes(c.id)).map(c => ({ id: c.id, title: c.title, box_name: c.box_name }));
    res.json({ suggestions });
  } catch (err) {
    console.error('[AI /suggest-links]', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/quiz', async (req, res) => {
  try {
    const { card_id } = req.body;
    const card = db.prepare('SELECT * FROM cards WHERE id = ?').get(card_id);
    if (!card) return res.status(404).json({ error: 'Karte nicht gefunden' });

    const existing = db.prepare('SELECT question FROM card_questions WHERE card_id = ?').all(card_id);
    let questions;
    if (existing.length > 0) {
      questions = existing.map(q => q.question);
    } else {
      const text = await callAI([{
        role: 'user',
        content: `Generiere 3 Lernfragen zu diesem Notizzettel. Antworte NUR mit einem JSON-Array: ["Frage 1?", "Frage 2?", "Frage 3?"].

Titel: ${card.title}
Inhalt: ${card.content}`
      }]);
      questions = parseJSON(text);
      const insert = db.prepare('INSERT INTO card_questions (card_id, question) VALUES (?, ?)');
      for (const q of questions) insert.run(card_id, q);
    }
    res.json({ card_id, title: card.title, questions });
  } catch (err) {
    console.error('[AI /quiz]', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/check-answer', async (req, res) => {
  try {
    const { question, answer, card_content } = req.body;
    const text = await callAI([{
      role: 'user',
      content: `Bewerte diese Antwort auf die Frage anhand des Inhalts der Notiz. Antworte mit einem JSON-Objekt: {"correct": true/false, "feedback": "kurzes Feedback auf Deutsch"}.

Frage: ${question}
Antwort des Nutzers: ${answer}
Inhalt der Notiz: ${card_content}`
    }], 256);
    res.json(parseJSON(text));
  } catch (err) {
    console.error('[AI /check-answer]', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/suggest-category', async (req, res) => {
  try {
    const { title, content } = req.body;
    const text = await callAI([{
      role: 'user',
      content: `Schlage eine kurze, präzise Kategorie (1-3 Wörter, Deutsch) für diesen Eintrag vor. Antworte NUR mit der Kategorie, kein Satz, keine Erklärung.

Titel: ${title}
Inhalt: ${content?.slice(0, 300) || ''}`
    }], 64);
    res.json({ category: text });
  } catch (err) {
    console.error('[AI /suggest-category]', err.message);
    res.status(500).json({ error: err.message });
  }
});

router.post('/generate-entry', async (req, res) => {
  try {
    const { topic, box_id, depth = 'mittel' } = req.body;
    if (!topic?.trim()) return res.status(400).json({ error: 'Thema erforderlich' });

    const depthInstr = depth === 'kurz'
      ? 'Schreibe einen kurzen, prägnanten Eintrag (ca. 100-150 Wörter).'
      : depth === 'ausführlich'
      ? 'Schreibe einen ausführlichen, strukturierten Eintrag (ca. 400-600 Wörter) mit Unterpunkten, Beispielen und ggf. Formeln.'
      : 'Schreibe einen mittelangen, gut strukturierten Eintrag (ca. 200-300 Wörter).';

    const text = await callAI([{
      role: 'user',
      content: `Erstelle einen Wissenseintrag für eine persönliche Wissensdatenbank zum Thema: "${topic}"

${depthInstr}

Nutze Markdown-Formatierung (fett, Listen, Codeblöcke wenn sinnvoll). Für Formeln nutze LaTeX: $inline$ oder $$display$$.

Antworte NUR mit einem JSON-Objekt:
{
  "title": "Präziser Titel (max 80 Zeichen)",
  "content": "Vollständiger Inhalt in Markdown",
  "category": "Kurze Kategorie (1-3 Wörter)",
  "tags": ["Tag1", "Tag2", "Tag3"]
}`
    }], 1024);

    const entry = parseJSON(text);

    if (box_id) {
      const result = db.prepare(
        `INSERT INTO cards (box_id, title, content, tags, category) VALUES (?, ?, ?, ?, ?)`
      ).run(box_id, entry.title, entry.content, JSON.stringify(entry.tags || []), entry.category || '');
      entry.id = result.lastInsertRowid;
      entry.box_id = box_id;
    }

    res.json(entry);
  } catch (err) {
    console.error('[AI /generate-entry]', err.message);
    res.status(500).json({ error: err.message });
  }
});

export default router;
