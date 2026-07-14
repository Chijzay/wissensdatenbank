-- ================================================================
-- Migration 003: Willkommens-Box für bestehende Nutzer ohne Boxen
-- Für Nutzer, die sich vor der Erstellung des Triggers registriert
-- haben. Im Supabase SQL-Editor ausführen — NACH migration_002.
-- ================================================================

DO $BACKFILL$
DECLARE
  r        record;
  v_box_id integer;
BEGIN
  FOR r IN
    SELECT id FROM auth.users
    WHERE id NOT IN (
      SELECT DISTINCT user_id FROM public.boxes WHERE user_id IS NOT NULL
    )
  LOOP
    INSERT INTO public.boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('Wissen', '📚', '#7c6af7', NULL, r.id, 1)
    RETURNING id INTO v_box_id;

    INSERT INTO public.cards (box_id, user_id, title, content, tags, category)
    VALUES (
      v_box_id,
      r.id,
      'Willkommen in deiner Wissens-App!',
      E'## Deine persönliche Wissensdatenbank\n\nHier kannst du dein Wissen strukturiert festhalten und jederzeit darauf zugreifen.\n\n**So funktioniert es:**\n\n1. **Bereiche** sind deine übergeordneten Wissensgebiete (z. B. Informatik, Sprachen)\n2. **Boxen** sind Unterthemen innerhalb eines Bereichs\n3. **Karten** sind einzelne Einträge mit Wissen, Notizen oder Lernstoff\n\n**Erste Schritte:**\n- Schreibe dein erstes Wissen in das Eingabefeld oben\n- Erstelle neue Bereiche über das **Grid-Symbol** rechts oben\n- Nutze die **KI-Funktion** für automatisch generierte Einträge\n- Mit **Diktieren** kannst du Einträge per Sprache erfassen\n\nViel Spaß beim Lernen!',
      '[]',
      'Einführung'
    );

    RAISE NOTICE 'Willkommens-Box für Nutzer % erstellt.', r.id;
  END LOOP;
END;
$BACKFILL$ LANGUAGE plpgsql;
