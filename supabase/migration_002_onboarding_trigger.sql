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
  VALUES ('Wissen', '📚', '#7c6af7', NULL, NEW.id, 1)
  RETURNING id INTO v_box_id;

  -- Einführungskarte anlegen
  INSERT INTO public.cards (box_id, user_id, title, content, tags, category)
  VALUES (
    v_box_id,
    NEW.id,
    'Willkommen in deiner Wissens-App!',
    E'## Deine persönliche Wissensdatenbank\n\nHier kannst du dein Wissen strukturiert festhalten und jederzeit darauf zugreifen.\n\n**So funktioniert es:**\n\n1. **Bereiche** sind deine übergeordneten Wissensgebiete (z.\xa0B. „Informatik", „Sprachen")\n2. **Boxen** sind Unterthemen innerhalb eines Bereichs\n3. **Karten** sind einzelne Einträge mit Wissen, Notizen oder Lernstoff\n\n**Erste Schritte:**\n- Schreibe dein erstes Wissen in das Eingabefeld oben\n- Erstelle neue Bereiche über das **Grid-Symbol** rechts oben\n- Nutze die **KI-Funktion** für automatisch generierte Einträge\n- Mit **Diktieren** kannst du Einträge per Sprache erfassen\n\nViel Spaß beim Lernen! 🚀',
    '[]',
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
