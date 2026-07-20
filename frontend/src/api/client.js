import { supabase } from '../supabase.js';

const AUTO_COLORS = ['#6366f1','#22c55e','#f59e0b','#ec4899','#14b8a6','#f97316','#8b5cf6','#06b6d4'];

function parseTags(tags) {
  if (Array.isArray(tags)) return tags;
  try { return JSON.parse(tags || '[]'); } catch { return []; }
}

// Gewichteter Zufall: Favoriten erscheinen häufiger (Gewicht = 1 + Priorität 0–3)
export function pickWeightedRandom(cards) {
  if (!cards?.length) return null;
  const weight = c => 1 + (c.favorite || 0);
  const total = cards.reduce((s, c) => s + weight(c), 0);
  let r = Math.random() * total;
  for (const c of cards) {
    r -= weight(c);
    if (r <= 0) return c;
  }
  return cards[cards.length - 1];
}

async function ai(action, data = {}) {
  const { data: result, error } = await supabase.functions.invoke('ai', {
    body: { action, ...data },
  });
  if (error) {
    let msg = error.message || 'KI nicht verfügbar';
    try {
      const body = await error.context?.json?.();
      if (body?.error) msg = body.error;
    } catch { /* no context body */ }
    throw new Error(msg);
  }
  return result;
}

export const api = {
  boxes: {
    list: async () => {
      const { data: boxes, error: bErr } = await supabase.from('boxes').select('*').is('deleted_at', null).order('sort_order').order('created_at');
      if (bErr) throw bErr;
      const { data: cards, error: cErr } = await supabase.from('cards').select('id, box_id').is('deleted_at', null);
      if (cErr) throw cErr;

      const result = boxes.map(b => {
        const directCount = cards.filter(c => c.box_id === b.id).length;
        const childIds = boxes.filter(c => c.parent_id === b.id).map(c => c.id);
        const childEntryCount = cards.filter(c => childIds.includes(c.box_id)).length;
        return {
          ...b,
          direct_count: directCount,
          children_entry_count: childEntryCount,
          children_count: childIds.length,
          card_count: directCount + (b.parent_id ? 0 : childEntryCount),
        };
      });

      result.sort((a, b) => {
        if ((a.parent_id || 0) !== (b.parent_id || 0)) return (a.parent_id || 0) - (b.parent_id || 0);
        if (a.sort_order !== b.sort_order) return a.sort_order - b.sort_order;
        return new Date(a.created_at) - new Date(b.created_at);
      });

      return result;
    },

    create: async (data) => {
      const { name, description = '', color = '#6366f1', icon = '📦', parent_id = null } = data;
      const { data: box, error } = await supabase.from('boxes')
        .insert({ name, description, color, icon, parent_id: parent_id || null })
        .select().single();
      if (error) throw error;
      return box;
    },

    findOrCreate: async (name) => {
      const { data: existing } = await supabase.from('boxes').select('*')
        .ilike('name', name.trim()).is('parent_id', null).is('deleted_at', null).maybeSingle();
      if (existing) return existing;

      const { data: all } = await supabase.from('boxes').select('id').is('deleted_at', null);
      const color = AUTO_COLORS[(all?.length || 0) % AUTO_COLORS.length];
      const { data, error } = await supabase.from('boxes')
        .insert({ name: name.trim(), color, icon: '📁', parent_id: null })
        .select().single();
      if (error) throw error;
      return data;
    },

    update: async (id, data) => {
      const { data: box, error } = await supabase.from('boxes').update(data).eq('id', id).select().single();
      if (error) throw error;
      return box;
    },

    delete: async (id) => {
      const now = new Date().toISOString();
      // Kinder-Boxen finden
      const { data: children } = await supabase.from('boxes').select('id').eq('parent_id', id);
      const childIds = (children || []).map(c => c.id);
      const allBoxIds = [id, ...childIds];
      // Karten in allen Boxen soft-löschen
      await supabase.from('cards').update({ deleted_at: now }).in('box_id', allBoxIds).is('deleted_at', null);
      // Kinder-Boxen soft-löschen
      if (childIds.length) await supabase.from('boxes').update({ deleted_at: now }).in('id', childIds);
      // Box selbst soft-löschen
      await supabase.from('boxes').update({ deleted_at: now }).eq('id', id);
      return { ok: true };
    },

    trash: async () => {
      const { data, error } = await supabase.from('boxes').select('*').not('deleted_at', 'is', null).order('deleted_at', { ascending: false });
      if (error) throw error;
      return data || [];
    },

    restore: async (id) => {
      // Kinder-Boxen finden (auch gelöschte)
      const { data: children } = await supabase.from('boxes').select('id').eq('parent_id', id);
      const childIds = (children || []).map(c => c.id);
      const allBoxIds = [id, ...childIds];
      // Karten wiederherstellen
      await supabase.from('cards').update({ deleted_at: null }).in('box_id', allBoxIds);
      // Kinder-Boxen wiederherstellen
      if (childIds.length) await supabase.from('boxes').update({ deleted_at: null }).in('id', childIds);
      // Box selbst wiederherstellen
      await supabase.from('boxes').update({ deleted_at: null }).eq('id', id);
      return { ok: true };
    },

    deletePermanently: async (id) => {
      // Cascade löscht Kinder-Boxen und Karten automatisch (ON DELETE CASCADE im Schema)
      await supabase.from('boxes').delete().eq('id', id);
      return { ok: true };
    },

    deleteAllTrashed: async () => {
      const { data: trashed } = await supabase.from('boxes').select('id').not('deleted_at', 'is', null);
      const ids = (trashed || []).map(b => b.id);
      if (ids.length) await supabase.from('boxes').delete().in('id', ids);
      return { ok: true };
    },

    sort: async (orders) => {
      await Promise.all(orders.map(({ id, sort_order }) =>
        supabase.from('boxes').update({ sort_order }).eq('id', id)
      ));
      return { ok: true };
    },
  },

  cards: {
    all: async (params = {}) => {
      const { search, topic, bereich } = params;
      let query = supabase.from('cards')
        .select('*, boxes!inner(name, color, icon, parent_id)')
        .is('deleted_at', null)
        .order('updated_at', { ascending: false });

      if (search) query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%,tags.ilike.%${search}%`);
      if (topic) {
        query = query.eq('box_id', topic);
      } else if (bereich) {
        const { data: children } = await supabase.from('boxes').select('id').eq('parent_id', bereich);
        const ids = [bereich, ...(children || []).map(b => b.id)];
        query = query.in('box_id', ids);
      }

      const { data, error } = await query;
      if (error) throw error;
      return data.map(c => ({
        ...c,
        box_name: c.boxes.name,
        box_color: c.boxes.color,
        box_icon: c.boxes.icon,
        box_parent_id: c.boxes.parent_id,
        boxes: undefined,
        tags: parseTags(c.tags),
      }));
    },

    allInBereich: (bereichId, extra = {}) => api.cards.all({ bereich: bereichId, ...extra }),

    list: async (boxId, params = {}) => {
      const { search, tag, category } = params;
      let query = supabase.from('cards').select('*').eq('box_id', boxId).is('deleted_at', null).order('updated_at', { ascending: false });
      if (search) query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%,tags.ilike.%${search}%`);
      if (tag) query = query.ilike('tags', `%${tag}%`);
      if (category) query = query.eq('category', category);

      const { data: cards, error } = await query;
      if (error) throw error;

      const cardIds = cards.map(c => c.id);
      const { data: questions } = cardIds.length
        ? await supabase.from('card_questions').select('card_id, question').in('card_id', cardIds)
        : { data: [] };

      return cards.map(c => ({
        ...c,
        tags: parseTags(c.tags),
        questions: (questions || []).filter(q => q.card_id === c.id).map(q => q.question),
      }));
    },

    get: async (id) => {
      const { data: card, error } = await supabase.from('cards').select('*').eq('id', id).is('deleted_at', null).single();
      if (error) throw error;

      const [{ data: questions }, { data: linksA }, { data: linksB }] = await Promise.all([
        supabase.from('card_questions').select('question').eq('card_id', id),
        supabase.from('card_links').select('linked_card_id, cards!card_links_linked_card_id_fkey(id, title, category)').eq('card_id', id),
        supabase.from('card_links').select('card_id, cards!card_links_card_id_fkey(id, title, category)').eq('linked_card_id', id),
      ]);

      const seen = new Set();
      const links = [];
      for (const l of [...(linksA || []), ...(linksB || [])]) {
        const c = l.cards;
        if (c && !seen.has(c.id)) { seen.add(c.id); links.push(c); }
      }

      return { ...card, tags: parseTags(card.tags), questions: (questions || []).map(q => q.question), links };
    },

    // Zufällige Karte aus dem gesamten Bestand (gewichtet nach Favoriten-Priorität)
    randomAll: async (excludeId = null) => {
      const { data: cards, error } = await supabase.from('cards').select('id, favorite').is('deleted_at', null);
      if (error) throw error;
      let pool = (cards || []).filter(c => c.id !== excludeId);
      if (!pool.length) pool = cards || [];
      if (!pool.length) throw new Error('Keine Karten vorhanden');
      const chosen = pickWeightedRandom(pool);
      return api.cards.get(chosen.id);
    },

    random: async (boxId) => {
      const { data: cards } = await supabase.from('cards').select('id').eq('box_id', boxId).is('deleted_at', null);
      if (!cards?.length) throw new Error('Keine Karten vorhanden');
      const randomId = cards[Math.floor(Math.random() * cards.length)].id;
      const { data: card, error } = await supabase.from('cards').select('*').eq('id', randomId).single();
      if (error) throw error;
      const { data: questions } = await supabase.from('card_questions').select('question').eq('card_id', card.id);
      card.tags = parseTags(card.tags);
      card.questions = (questions || []).map(q => q.question);
      return card;
    },

    create: async (data) => {
      const { box_id, title, content = '', tags = [], category = '' } = data;
      const { data: card, error } = await supabase.from('cards')
        .insert({ box_id, title, content, tags: JSON.stringify(tags), category })
        .select().single();
      if (error) throw error;
      return { ...card, tags: parseTags(card.tags), questions: [], links: [] };
    },

    update: async (id, data) => {
      const updates = { ...data };
      if (data.tags !== undefined) updates.tags = JSON.stringify(data.tags);
      const { data: card, error } = await supabase.from('cards').update(updates).eq('id', id).select().single();
      if (error) throw error;
      return { ...card, tags: parseTags(card.tags) };
    },

    delete: async (id) => {
      const { error } = await supabase.from('cards')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id);
      if (error) throw error;
      return { ok: true };
    },

    trash: async () => {
      const { data, error } = await supabase.from('cards')
        .select('*, boxes(name, color, icon)')
        .not('deleted_at', 'is', null)
        .order('deleted_at', { ascending: false });
      if (error) throw error;
      return (data || []).map(c => ({
        ...c,
        box_name: c.boxes?.name || '',
        box_color: c.boxes?.color || '',
        box_icon: c.boxes?.icon || '',
        boxes: undefined,
        tags: parseTags(c.tags),
      }));
    },

    restore: async (id) => {
      const { error } = await supabase.from('cards').update({ deleted_at: null }).eq('id', id);
      if (error) throw error;
      return { ok: true };
    },

    deletePermanently: async (id) => {
      await supabase.from('cards').delete().eq('id', id);
      return { ok: true };
    },

    deleteAllTrashed: async () => {
      await supabase.from('cards').delete().not('deleted_at', 'is', null);
      return { ok: true };
    },

    link: async (card_id, linked_card_id) => {
      await supabase.from('card_links').upsert(
        { card_id, linked_card_id },
        { onConflict: 'card_id,linked_card_id', ignoreDuplicates: true }
      );
      return { ok: true };
    },

    unlink: async (cardId, linkedId) => {
      await supabase.from('card_links').delete().or(
        `and(card_id.eq.${cardId},linked_card_id.eq.${linkedId}),and(card_id.eq.${linkedId},linked_card_id.eq.${cardId})`
      );
      return { ok: true };
    },
  },

  ai: {
    generateQuestions: (data) => ai('generate-questions', data),
    suggestLinks:      (data) => ai('suggest-links', data),
    quiz:              (card_id) => ai('quiz', { card_id }),
    checkAnswer:       (data) => ai('check-answer', data),
    suggestCategory:   (data) => ai('suggest-category', data),
    suggestTags:       (data) => ai('suggest-tags', data),
    generateEntry:     (data) => ai('generate-entry', data),
  },
};
