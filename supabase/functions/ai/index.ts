import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Anthropic from "npm:@anthropic-ai/sdk";
import { createClient } from "npm:@supabase/supabase-js";

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// deno-lint-ignore no-explicit-any
type Any = any;

function json(data: Any, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
}

function parseJSON(text: string): Any {
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  const cleaned = (fenced ? fenced[1] : text).trim();
  try { return JSON.parse(cleaned); } catch { /* */ }
  const found = cleaned.match(/\[[\s\S]*\]/) || cleaned.match(/\{[\s\S]*\}/);
  if (found) return JSON.parse(found[0]);
  throw new Error('Kein gültiges JSON: ' + cleaned.slice(0, 80));
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const token = (req.headers.get('Authorization') || '').replace('Bearer ', '');
    const { data: { user }, error: authErr } = await supabase.auth.getUser(token);
    if (authErr || !user) return json({ error: 'Nicht angemeldet' }, 401);

    const { action, ...data } = await req.json();
    const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY') });

    async function callAI(messages: Array<{ role: string; content: string }>, maxTokens = 1024) {
      const res = await anthropic.messages.create({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: maxTokens,
        messages,
      });
      if (res.stop_reason === 'max_tokens') {
        throw new Error('Antwort wurde abgeschnitten – bitte kürzeren Inhalt versuchen.');
      }
      return (res.content[0] as { text: string }).text.trim();
    }

    switch (action) {
      case 'generate-questions': {
        const { card_id, title, content } = data;
        const text = await callAI([{ role: 'user', content: `Generiere 3 prägnante Lernfragen zu folgendem Notizzettel. Die Fragen sollen das Verständnis prüfen, nicht nur das Auswendiglernen. Antworte NUR mit einem JSON-Array von Strings, z.B. ["Frage 1?", "Frage 2?", "Frage 3?"].\n\nTitel: ${title}\nInhalt: ${content}` }]);
        const questions = parseJSON(text);
        if (card_id) {
          await supabase.from('card_questions').delete().eq('card_id', card_id);
          await supabase.from('card_questions').insert(questions.map((q: string) => ({ card_id: Number(card_id), question: q })));
        }
        return json({ questions });
      }

      case 'suggest-tags': {
        const { title, content } = data;
        const text = await callAI([{ role: 'user', content: `Schlage 3-5 präzise Tags (einzelne Wörter oder kurze Phrasen, Deutsch oder Englisch je nach Fachgebiet) für diesen Eintrag vor. Antworte NUR mit einem JSON-Array: ["Tag1","Tag2","Tag3"].\n\nTitel: ${title}\nInhalt: ${(content || '').slice(0, 400)}` }], 128);
        return json({ tags: parseJSON(text) });
      }

      case 'suggest-links': {
        const { card_id, title, content } = data;
        const { data: allCards } = await supabase.from('cards')
          .select('id, title, content, boxes!inner(name)')
          .neq('id', card_id || 0).is('deleted_at', null).order('updated_at', { ascending: false }).limit(60);
        if (!allCards?.length) return json({ suggestions: [] });
        const cardList = (allCards as Any[]).map(c =>
          `ID ${c.id} [${c.boxes.name}]: ${c.title} – ${c.content.slice(0, 80)}`
        ).join('\n');
        const text = await callAI([{ role: 'user', content: `Welche der folgenden Einträge sind thematisch verwandt mit dem aktuellen Eintrag? Antworte NUR mit einem JSON-Array der IDs, z.B. [2, 5]. Maximal 4 Vorschläge. Wenn keine passen, antworte mit [].\n\nAktueller Eintrag:\nTitel: ${title}\nInhalt: ${content.slice(0, 300)}\n\nVerfügbare Einträge:\n${cardList}` }], 512);
        const ids = parseJSON(text);
        return json({
          suggestions: (allCards as Any[]).filter(c => ids.includes(c.id)).map(c => ({ id: c.id, title: c.title, box_name: c.boxes.name })),
        });
      }

      case 'quiz': {
        const { card_id } = data;
        const { data: card, error } = await supabase.from('cards').select('*').eq('id', card_id).single();
        if (error || !card) return json({ error: 'Karte nicht gefunden' }, 404);
        const { data: existing } = await supabase.from('card_questions').select('question').eq('card_id', card_id);
        let questions;
        if (existing?.length) {
          questions = (existing as Any[]).map(q => q.question);
        } else {
          const text = await callAI([{ role: 'user', content: `Generiere 3 Lernfragen zu diesem Notizzettel. Antworte NUR mit einem JSON-Array: ["Frage 1?", "Frage 2?", "Frage 3?"].\n\nTitel: ${card.title}\nInhalt: ${card.content}` }]);
          questions = parseJSON(text);
          await supabase.from('card_questions').insert(questions.map((q: string) => ({ card_id: Number(card_id), question: q })));
        }
        return json({ card_id, title: card.title, questions });
      }

      case 'check-answer': {
        const { question, answer, card_content } = data;
        const text = await callAI([{ role: 'user', content: `Bewerte diese Antwort auf die Frage anhand des Inhalts der Notiz. Antworte mit einem JSON-Objekt: {"correct": true/false, "feedback": "kurzes Feedback auf Deutsch"}.\n\nFrage: ${question}\nAntwort des Nutzers: ${answer}\nInhalt der Notiz: ${card_content}` }], 512);
        return json(parseJSON(text));
      }

      case 'suggest-category': {
        const { title, content } = data;
        const text = await callAI([{ role: 'user', content: `Schlage eine kurze, präzise Kategorie (1-3 Wörter, Deutsch) für diesen Eintrag vor. Antworte NUR mit der Kategorie, kein Satz, keine Erklärung.\n\nTitel: ${title}\nInhalt: ${(content || '').slice(0, 300)}` }], 64);
        return json({ category: text });
      }

      case 'generate-entry': {
        const { topic, box_id, depth = 'mittel' } = data;
        if (!topic?.trim()) return json({ error: 'Thema erforderlich' }, 400);
        const depthInstr = depth === 'kurz'
          ? 'Schreibe einen kurzen, prägnanten Eintrag (ca. 100-150 Wörter).'
          : depth === 'ausführlich'
          ? 'Schreibe einen ausführlichen, strukturierten Eintrag (ca. 400-600 Wörter) mit Unterpunkten, Beispielen und ggf. Formeln.'
          : 'Schreibe einen mittelangen, gut strukturierten Eintrag (ca. 200-300 Wörter).';
        const maxTok = depth === 'ausführlich' ? 4096 : depth === 'mittel' ? 2048 : 1024;
        const text = await callAI([{ role: 'user', content: `Erstelle einen Wissenseintrag für eine persönliche Wissensdatenbank zum Thema: "${topic}"\n\n${depthInstr}\n\nNutze Markdown-Formatierung (fett, Listen, Codeblöcke wenn sinnvoll). Für Formeln nutze LaTeX: $inline$ oder $$display$$.\n\nAntworte NUR mit einem JSON-Objekt:\n{\n  "title": "Präziser Titel (max 80 Zeichen)",\n  "content": "Vollständiger Inhalt in Markdown",\n  "category": "Kurze Kategorie (1-3 Wörter)",\n  "tags": ["Tag1", "Tag2", "Tag3"]\n}` }], maxTok);
        const entry = parseJSON(text);
        if (box_id) {
          const { data: created } = await supabase.from('cards')
            .insert({ box_id, title: entry.title, content: entry.content, tags: JSON.stringify(entry.tags || []), category: entry.category || '' })
            .select().single();
          if (created) { entry.id = created.id; entry.box_id = box_id; }
        }
        return json(entry);
      }

      default:
        return json({ error: `Unbekannte Aktion: ${action}` }, 400);
    }
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
