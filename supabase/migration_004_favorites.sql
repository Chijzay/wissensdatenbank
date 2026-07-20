-- ================================================================
-- Migration 004: Favoriten mit Priorität
-- favorite: 0 = kein Favorit, 1 = ★ Niedrig, 2 = ★★ Mittel, 3 = ★★★ Hoch
-- Im Supabase SQL-Editor ausführen.
-- ================================================================

ALTER TABLE cards ADD COLUMN IF NOT EXISTS favorite SMALLINT NOT NULL DEFAULT 0;

-- Sicherstellen, dass nur gültige Werte gespeichert werden
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'cards_favorite_range'
  ) THEN
    ALTER TABLE cards ADD CONSTRAINT cards_favorite_range CHECK (favorite BETWEEN 0 AND 3);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_cards_favorite ON cards(favorite) WHERE favorite > 0;
