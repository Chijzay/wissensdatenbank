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
    VALUES ('Erste Schritte', '🚀', '#ef4444', NULL, r.id, 1)
    RETURNING id INTO v_box_id;

    INSERT INTO public.cards (box_id, user_id, title, content, tags, category)
    VALUES (
      v_box_id,
      r.id,
      'Willkommen in deiner Wissensdatenbank',
      E'**Willkommen! \U0001F9E0**\n\nDas hier ist deine persönliche Wissensdatenbank — ein Ort um alles festzuhalten was du lernst, verstehst und behalten möchtest.\n\n## Wie es funktioniert\n\n**Bereiche & Boxen**\nDein Wissen ist in *Bereiche* (z.B. Informatik, Sprachen, Gesundheit) und *Boxen* (Azure, Englisch) gegliedert. Du kannst sie frei anlegen und benennen.\n\n**Einträge erstellen**\nKlicke auf eine Box und dann auf \"+ Eintrag\" um eine neue Wissenskarte anzulegen. Du kannst **fett**, *kursiv*, Listen, `Code` und sogar Formeln wie $E=mc^2$ verwenden.\n\n**KI-Funktionen**\nÖffne einen Eintrag und klicke auf den ✨-Button:\n\n- Lernfragen automatisch generieren lassen\n- Tags und Kategorie vorschlagen\n- Verwandte Einträge finden\n- Neue Einträge zu einem Thema generieren\n\n**Quizmodus**\nTeste dein Wissen direkt in der App — die KI bewertet deine Antworten.\n\n**Verknüpfungen**\nVerbinde Einträge die thematisch zusammenhängen — ideal um Zusammenhänge sichtbar zu machen.\n\n## Erste Schritte\n\n1. Lege deinen ersten Bereich an (z.B. \"Arbeit\" oder \"Studium\")\n2. Erstelle deine erste Box darin\n3. Schreibe deinen ersten Eintrag\n4. Lass die KI Lernfragen dazu generieren\n\nDiese Karte kannst du jederzeit löschen wenn du sie nicht mehr brauchst.',
      '["Anleitung","Start"]',
      'Einführung'
    );

    RAISE NOTICE 'Willkommens-Box für Nutzer % erstellt.', r.id;
  END LOOP;
END;
$BACKFILL$ LANGUAGE plpgsql;
