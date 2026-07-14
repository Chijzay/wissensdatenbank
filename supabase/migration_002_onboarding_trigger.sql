-- ================================================================
-- Migration 002: Onboarding-Trigger für neue Nutzer
-- Neue Nutzer bekommen automatisch einen Willkommens-Bereich
-- mit einer Einführungskarte.
--
-- WICHTIG: Erst migration_001_user_isolation.sql ausführen!
-- ================================================================

-- Funktion: wird aufgerufen sobald ein neuer Nutzer sich registriert
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_box_id integer;
BEGIN
  -- Willkommens-Bereich anlegen
  INSERT INTO public.boxes (name, icon, color, parent_id, user_id, sort_order)
  VALUES ('Erste Schritte', '🚀', '#ef4444', NULL, NEW.id, 1)
  RETURNING id INTO v_box_id;

  -- Einführungskarte anlegen
  INSERT INTO public.cards (box_id, user_id, title, content, tags, category)
  VALUES (
    v_box_id,
    NEW.id,
    'Willkommen in deiner Wissensdatenbank',
    E'**Willkommen! \U0001F9E0**\n\nDas hier ist deine persönliche Wissensdatenbank — ein Ort um alles festzuhalten was du lernst, verstehst und behalten möchtest.\n\n## Wie es funktioniert\n\n**Bereiche & Boxen**\nDein Wissen ist in *Bereiche* (z.B. Informatik, Sprachen, Gesundheit) und *Boxen* (Unterthemen) gegliedert. Du kannst sie frei anlegen und benennen.\n\n**Einträge erstellen**\nKlicke auf eine Box und dann auf \"+ Eintrag\" um eine neue Wissenskarte anzulegen. Du kannst **fett**, *kursiv*, Listen, Code und sogar Formeln verwenden.\n\n**KI-Funktionen**\nÖffne einen Eintrag und klicke auf den ✨-Button:\n\n- Lernfragen automatisch generieren lassen\n- Tags und Kategorie vorschlagen\n- Verwandte Einträge finden\n- Neue Einträge zu einem Thema generieren\n\n**Quizmodus**\nTeste dein Wissen direkt in der App — die KI bewertet deine Antworten.\n\n**Verknüpfungen**\nVerbinde Einträge die thematisch zusammenhängen — ideal um Zusammenhänge sichtbar zu machen.\n\n## Erste Schritte\n\n1. Lege deinen ersten Bereich an (z.B. \"Arbeit\" oder \"Studium\")\n2. Erstelle deine erste Box darin\n3. Schreibe deinen ersten Eintrag\n4. Lass die KI Lernfragen dazu generieren\n\nDiese Karte kannst du jederzeit löschen wenn du sie nicht mehr brauchst.',
    '["Anleitung","Start"]',
    'Einführung'
  );

  RETURN NEW;
END;
$$;

-- Trigger auf auth.users: bei jedem neuen Nutzer ausführen
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
