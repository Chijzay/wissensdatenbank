const BASE = '/api';

async function req(path, opts = {}) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...opts,
    body: opts.body ? JSON.stringify(opts.body) : undefined
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

export const api = {
  boxes: {
    list: () => req('/boxes'),
    create: (data) => req('/boxes', { method: 'POST', body: data }),
    findOrCreate: (name) => req('/boxes/find-or-create', { method: 'POST', body: { name } }),
    update: (id, data) => req(`/boxes/${id}`, { method: 'PUT', body: data }),
    delete: (id) => req(`/boxes/${id}`, { method: 'DELETE' }),
  },
  cards: {
    all: (params = {}) => {
      const qs = new URLSearchParams(params).toString();
      return req(`/cards/all${qs ? '?' + qs : ''}`);
    },
    allInBereich: (bereichId, extra = {}) => {
      const qs = new URLSearchParams({ bereich: bereichId, ...extra }).toString();
      return req(`/cards/all?${qs}`);
    },
    list: (boxId, params = {}) => {
      const qs = new URLSearchParams(params).toString();
      return req(`/cards/box/${boxId}${qs ? '?' + qs : ''}`);
    },
    get: (id) => req(`/cards/${id}`),
    random: (boxId) => req(`/cards/random/${boxId}`),
    create: (data) => req('/cards', { method: 'POST', body: data }),
    update: (id, data) => req(`/cards/${id}`, { method: 'PUT', body: data }),
    delete: (id) => req(`/cards/${id}`, { method: 'DELETE' }),
    link: (card_id, linked_card_id) => req('/cards/link', { method: 'POST', body: { card_id, linked_card_id } }),
    unlink: (cardId, linkedId) => req(`/cards/link/${cardId}/${linkedId}`, { method: 'DELETE' }),
  },
  ai: {
    generateQuestions: (data) => req('/ai/generate-questions', { method: 'POST', body: data }),
    suggestLinks: (data) => req('/ai/suggest-links', { method: 'POST', body: data }),
    quiz: (card_id) => req('/ai/quiz', { method: 'POST', body: { card_id } }),
    checkAnswer: (data) => req('/ai/check-answer', { method: 'POST', body: data }),
    suggestCategory: (data) => req('/ai/suggest-category', { method: 'POST', body: data }),
    suggestTags: (data) => req('/ai/suggest-tags', { method: 'POST', body: data }),
    generateEntry: (data) => req('/ai/generate-entry', { method: 'POST', body: data }),
  }
};
