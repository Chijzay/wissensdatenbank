-- ================================================================
-- Migration 001: User-Isolation + Box-Papierkorb
-- Im Supabase SQL-Editor ausführen (Dashboard → SQL Editor → New query)
-- ================================================================

-- 1. user_id zu boxes hinzufügen
ALTER TABLE boxes ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

-- 2. deleted_at zu boxes hinzufügen
ALTER TABLE boxes ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- 3. Vorhandene Boxen dem ersten/einzigen Nutzer zuweisen
UPDATE boxes
SET user_id = (SELECT id FROM auth.users ORDER BY created_at LIMIT 1)
WHERE user_id IS NULL;

-- 4. DEFAULT für neue Zeilen setzen
ALTER TABLE boxes ALTER COLUMN user_id SET DEFAULT auth.uid();

-- 5. user_id zu cards hinzufügen (über box ableiten)
ALTER TABLE cards ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

UPDATE cards c
SET user_id = b.user_id
FROM boxes b
WHERE c.box_id = b.id AND c.user_id IS NULL;

ALTER TABLE cards ALTER COLUMN user_id SET DEFAULT auth.uid();

-- 6. deleted_at zu cards — falls noch nicht vorhanden (Schema hatte es noch nicht explizit)
ALTER TABLE cards ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- 7. RLS-Policies aktualisieren: Nur eigene Daten sichtbar
DROP POLICY IF EXISTS "Eigener Zugriff auf boxes" ON boxes;
CREATE POLICY "Eigener Zugriff auf boxes" ON boxes
  FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Eigener Zugriff auf cards" ON cards;
CREATE POLICY "Eigener Zugriff auf cards" ON cards
  FOR ALL USING (auth.uid() = user_id);

-- 8. card_questions und card_links via JOIN absichern
DROP POLICY IF EXISTS "Eigener Zugriff auf card_questions" ON card_questions;
CREATE POLICY "Eigener Zugriff auf card_questions" ON card_questions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM cards WHERE cards.id = card_questions.card_id AND cards.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Eigener Zugriff auf card_links" ON card_links;
CREATE POLICY "Eigener Zugriff auf card_links" ON card_links
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM cards WHERE cards.id = card_links.card_id AND cards.user_id = auth.uid()
    )
  );
