-- Wissens-App: Supabase PostgreSQL Schema
-- Dieses SQL in den Supabase SQL Editor einfügen und ausführen

-- Tabellen anlegen
CREATE TABLE IF NOT EXISTS boxes (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  color TEXT DEFAULT '#6366f1',
  icon TEXT DEFAULT '📦',
  parent_id INTEGER REFERENCES boxes(id) ON DELETE CASCADE DEFAULT NULL,
  sort_order INTEGER DEFAULT 999,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cards (
  id SERIAL PRIMARY KEY,
  box_id INTEGER NOT NULL REFERENCES boxes(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT DEFAULT '',
  tags TEXT DEFAULT '[]',
  category TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS card_questions (
  id SERIAL PRIMARY KEY,
  card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS card_links (
  id SERIAL PRIMARY KEY,
  card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  linked_card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(card_id, linked_card_id)
);

-- Row Level Security (RLS) aktivieren
-- Nur der angemeldete Benutzer kann seine eigenen Daten sehen
ALTER TABLE boxes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE card_links ENABLE ROW LEVEL SECURITY;

-- Policies: Zugriff nur für eingeloggten Benutzer
CREATE POLICY "Eigener Zugriff auf boxes" ON boxes FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Eigener Zugriff auf cards" ON cards FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Eigener Zugriff auf card_questions" ON card_questions FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Eigener Zugriff auf card_links" ON card_links FOR ALL USING (auth.uid() IS NOT NULL);

-- Hilfsfunktion: updated_at automatisch setzen
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER boxes_updated_at BEFORE UPDATE ON boxes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER cards_updated_at BEFORE UPDATE ON cards FOR EACH ROW EXECUTE FUNCTION update_updated_at();
