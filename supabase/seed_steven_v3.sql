-- ================================================================
-- Seed v3: Karten aus den Lernleitfäden (PDFs)
--   * DevOps Foundation (DOFD) Lernunterlage
--   * AZ-900 Lernhandbuch + Kursleitfaden
--   * Lernheft Azure/Docker/Kubernetes/DevOps
-- Fügt NUR Karten ein, legt KEINE neuen Boxen an.
-- Im Supabase SQL-Editor ausführen — NACH seed_steven.sql
-- ================================================================

DO $SEED3$
DECLARE
  v_uid        uuid;
  v_azure      integer;
  v_kubernetes integer;
  v_docker     integer;
  v_devops     integer;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = 'steven.illg.it@outlook.com';
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Nutzer nicht gefunden'; END IF;

  SELECT id INTO v_azure      FROM public.boxes WHERE user_id = v_uid AND name = 'Azure';
  SELECT id INTO v_kubernetes FROM public.boxes WHERE user_id = v_uid AND name = 'Kubernetes';
  SELECT id INTO v_docker     FROM public.boxes WHERE user_id = v_uid AND name = 'Docker';
  SELECT id INTO v_devops     FROM public.boxes WHERE user_id = v_uid AND name = 'DevOps';

  IF v_azure      IS NULL THEN RAISE EXCEPTION 'Box "Azure" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;
  IF v_kubernetes IS NULL THEN RAISE EXCEPTION 'Box "Kubernetes" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;
  IF v_docker     IS NULL THEN RAISE EXCEPTION 'Box "Docker" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;
  IF v_devops     IS NULL THEN RAISE EXCEPTION 'Box "DevOps" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;

  -- ════════════════════════════════════════════════════════════════
  -- DEVOPS — DOFD-Prüfungsstoff (Three Ways, CALMS, Kultur, Lean)
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_devops, v_uid, 'First Way: Flow — Arbeit fließt von links nach rechts',
$C$Die **Three Ways** (Gene Kim, "The Phoenix Project" / "DevOps Handbook") sind das Fundament von DevOps. Der **First Way** optimiert den **Fluss der Arbeit von Entwicklung (links) zu Betrieb und Kunde (rechts)**.

## Kernprinzipien
- **Arbeit sichtbar machen** — Kanban-Board: unsichtbare IT-Arbeit wird wie Fabrikware sichtbar
- **Kleine Batches** — kleine Änderungen fließen schneller und risikoärmer als Riesenreleases
- **WIP-Limits** — Work in Progress begrenzen; Multitasking zerstört Durchsatz
- **Handoffs reduzieren** — jede Übergabe kostet Wissen, Zeit und Wartezeit
- **Engpässe optimieren** — Theory of Constraints: nur am Engpass lohnt Verbesserung
- **Waste eliminieren** — Lean-Verschwendung entfernen
- **Keine bekannten Defekte weitergeben** — Qualität wird nicht "später" geprüft

## Praktiken
Continuous Integration, Deployment-Pipeline, kleine häufige Releases, Umgebungen auf Knopfdruck.

## Prüfungs-Eselsbrücke
| Signalwort in der Frage | Way |
|------------------------|-----|
| WIP, Kanban, Engpass, Batch, Handoff | **First Way (Flow)** |
| Telemetrie, Andon, Tests je Commit | Second Way |
| Post-Mortem, Game Day, Kaizen | Third Way |

**Merke:** First Way = FLOW links→rechts: sichtbar machen, kleine Batches, WIP begrenzen, Engpass optimieren$C$,
   '["DevOps","Three Ways","Flow","Kanban","DOFD"]', 'Three Ways'),

  (v_devops, v_uid, 'Second Way: Feedback — Rückkopplung von rechts nach links',
$C$Der **Second Way** schafft **schnelle, ständige Feedback-Schleifen von rechts (Betrieb/Kunde) nach links (Entwicklung)** — Probleme werden sofort sichtbar, nicht erst Wochen später.

## Kernprinzipien
- **Probleme sofort sehen und beheben** — je früher ein Fehler auffällt, desto billiger die Korrektur
- **Qualität an die Quelle** — nicht auf nachgelagerte QA-Abteilung verlassen

## Praktiken
- **Telemetrie überall** — Metriken, Logs, Traces aus Produktion für alle sichtbar
- **Andon Cord ("Stop the line")** — aus dem Toyota-Produktionssystem: Bei einem Problem darf/soll JEDER die Pipeline anhalten, das Team schwärmt zur Lösung
- **Automatisierte Tests bei jedem Commit** — Feedback in Minuten statt Monaten
- **Peer Reviews / Pair Programming** — Feedback auf Code-Ebene
- **A/B-Tests** — Feedback vom Kunden über Hypothesen
- **Shift Left** — Tests und Security früher im Prozess

## Warum wichtig?
Ohne Feedback fließt Arbeit schnell in die falsche Richtung. First Way beschleunigt, Second Way lenkt.

**Merke:** Second Way = FEEDBACK rechts→links: Telemetrie, Andon Cord, Tests je Commit, Shift Left$C$,
   '["DevOps","Three Ways","Feedback","Andon","Telemetrie","DOFD"]', 'Three Ways'),

  (v_devops, v_uid, 'Third Way: Kontinuierliches Experimentieren & Lernen',
$C$Der **Third Way** schafft eine Kultur aus **ständigem Experimentieren, Risikobereitschaft und Lernen aus Fehlern** — plus Wiederholung/Übung, die zur Meisterschaft führt.

## Kernprinzipien
- **Experimentieren gehört zur Arbeit** — Verbesserung der täglichen Arbeit ist wichtiger als die tägliche Arbeit selbst
- **Aus Fehlern lernen statt bestrafen** — Fehler sind Systemprobleme, keine Personenprobleme
- **Übung schafft Meisterschaft** — Wiederholung (Deployments, Failover-Übungen) macht Außergewöhnliches zur Routine

## Praktiken
- **Kaizen** — kontinuierliche Verbesserung in kleinen Schritten, fest eingeplante Verbesserungszeit
- **Blameless Post-Mortems** — nach Incidents: Was geschah? Warum ergab das Handeln damals Sinn? Wie verhindern wir es systemisch?
- **Chaos Engineering / Game Days** — absichtlich kontrolliert Fehler injizieren, um Schwächen VOR dem Ernstfall zu finden (z.B. Netflix Chaos Monkey)
- **Innovationszeit** — z.B. 20%-Zeit, Hackathons

## Zusammenspiel der Three Ways
```
First Way:  Dev ────────────▶ Ops   (Flow)
Second Way: Dev ◀──────────── Ops   (Feedback)
Third Way:  ↻ Lernen & Experimentieren (Kultur, beide Richtungen)
```

**Merke:** Third Way = LERNEN: Kaizen, blameless Post-Mortems, Chaos Engineering, Game Days$C$,
   '["DevOps","Three Ways","Lernen","Kaizen","Post-Mortem","DOFD"]', 'Three Ways'),

  (v_devops, v_uid, 'CALMS-Modell — die 5 Dimensionen von DevOps',
$C$**CALMS** beschreibt die fünf Dimensionen, die eine DevOps-Transformation abdecken muss. Ursprünglich **CAMS** (Damon Edwards & John Willis), das **L** ergänzte **Jez Humble**.

## Die 5 Buchstaben
| Buchstabe | Dimension | Beispiele |
|-----------|-----------|-----------|
| **C** | **Culture** | Blameless Post-Mortems, psychologische Sicherheit, gemeinsame Verantwortung Dev+Ops |
| **A** | **Automation** | CI/CD-Pipeline, Infrastructure as Code, automatisierte Tests |
| **L** | **Lean** | Kleine Batches, WIP-Limits, Waste eliminieren, Wertstrom optimieren |
| **M** | **Measurement** | DORA-Metriken, Telemetrie, alles messen was fließt |
| **S** | **Sharing** | Communities of Practice, Wikis, Pairing, ChatOps, Wissen teilen |

## Wozu dient CALMS?
Als **Diagnose-Werkzeug**: Wo steht die Organisation je Dimension? Wo hakt die Transformation?

## Klassische Prüfungsfalle
> "Ein Unternehmen kauft CI/CD-Tools und nennt ein Team 'DevOps-Team', aber nichts verbessert sich."

Welche Dimension fehlt? → **Culture** (Tools ohne Kulturwandel scheitern). Automatisierung allein ist kein DevOps.

**Merke:** CALMS = Culture, Automation, Lean, Measurement, Sharing — Culture zuerst, Tools zuletzt$C$,
   '["DevOps","CALMS","Kultur","Lean","DOFD"]', 'Grundlagen'),

  (v_devops, v_uid, 'Theory of Constraints & Five Focusing Steps',
$C$Die **Theory of Constraints (ToC)** von **Eliyahu Goldratt** ("The Goal") besagt: **Der Durchsatz eines Systems wird allein vom Engpass (Constraint) bestimmt.** Verbesserungen abseits des Engpasses sind Illusion.

## Five Focusing Steps
1. **Identify** — den Engpass finden (wo staut sich Arbeit?)
2. **Exploit** — den Engpass maximal ausnutzen (keine Leerlaufzeit, nur wertvolle Arbeit dort)
3. **Subordinate** — alles andere dem Engpass unterordnen (nicht schneller produzieren als der Engpass verarbeiten kann)
4. **Elevate** — den Engpass erweitern (investieren: Automatisierung, mehr Kapazität)
5. **Repeat** — der Engpass wandert weiter → von vorn beginnen

## Typische Engpässe in der IT
- **Umgebungserstellung** — Wochen warten auf Test-/Dev-Umgebungen
- **Deployments** — manuell, riskant, selten
- **Test-Setup und -Durchführung** — manuelle Regressionstests
- **Überenge Architektur** — alles hängt an einem System
- **Spezialisten-Engpass** — "Brent" aus The Phoenix Project: eine Person, durch die alles laufen muss

## DevOps-Bezug
First Way (Flow): Engpässe identifizieren und optimieren ist Kernpraktik. Automatisierung (Umgebungen per Knopfdruck, Pipeline) beseitigt die klassischen IT-Engpässe.

**Merke:** Durchsatz = Engpass; Five Focusing Steps: Identify → Exploit → Subordinate → Elevate → Repeat$C$,
   '["DevOps","Theory of Constraints","Goldratt","Engpass","DOFD"]', 'Lean & Flow'),

  (v_devops, v_uid, 'Westrum-Typologie — drei Organisationskulturen',
$C$Die **Westrum-Typologie** (Soziologe Ron Westrum) unterscheidet drei Kulturtypen danach, **wie Informationen durch die Organisation fließen**. Die DORA-Forschung ("Accelerate") zeigt: **generative Kultur korreliert mit besserer Software-Delivery-Performance**.

## Die drei Typen
| Merkmal | Pathologisch | Bürokratisch | Generativ |
|---------|--------------|--------------|-----------|
| Orientierung | **Macht** | **Regeln** | **Leistung/Mission** |
| Kooperation | gering | tolerierbar | hoch |
| Überbringer schlechter Nachrichten | wird "erschossen" | wird ignoriert | wird **trainiert/belohnt** |
| Verantwortung | wird vermieden | eng begrenzt ("nicht mein Revier") | geteilt |
| Brückenbau zw. Teams | entmutigt | geduldet | **gefördert** |
| Reaktion auf Fehler | Schuldigen suchen | Gerechtigkeit/Verfahren | **Ursachenanalyse** |
| Neues/Innovation | zerschlagen | führt zu Problemen | wird umgesetzt |

## Erkennungsmerkmale in Prüfungsfragen
- "Shoot the messenger", Angst, Informationen zurückhalten → **pathologisch**
- Zuständigkeitsdenken, Silos, Dienst nach Vorschrift → **bürokratisch**
- Offener Informationsfluss, Lernen aus Fehlern, teamübergreifend → **generativ**

## Warum relevant für DevOps?
Guter Informationsfluss = schnelles Feedback (Second Way) + Lernen (Third Way). Kulturwandel Richtung generativ ist Kernziel jeder DevOps-Transformation.

**Merke:** Pathologisch = Macht, Bürokratisch = Regeln, Generativ = Leistung — generativ gewinnt$C$,
   '["DevOps","Westrum","Kultur","Accelerate","DOFD"]', 'Kultur'),

  (v_devops, v_uid, 'Psychologische Sicherheit & Just Culture',
$C$**Psychologische Sicherheit** = Teammitglieder können Risiken eingehen, Fragen stellen, Fehler zugeben und Bedenken äußern, **ohne Angst vor Bloßstellung oder Bestrafung**.

## Project Aristotle (Google)
Googles Studie über erfolgreiche Teams fand: **Psychologische Sicherheit ist der wichtigste Faktor** für Team-Performance — wichtiger als Zusammensetzung oder Seniorität.

## Just Culture
Grundhaltung: **Menschen machen Fehler wegen schlechter Systeme, nicht aus Bosheit.**
- Fokus: "Warum ergab die Entscheidung damals Sinn?" statt "Wer war es?"
- Konsequenz: Systeme verbessern (Absicherungen, Automatisierung) statt Personen bestrafen
- Grenze: grobe Fahrlässigkeit/Vorsatz bleibt sanktionierbar — "just", nicht "blame-free anarchy"

## Blameless Post-Mortem — Regeln
1. Zeitleiste rekonstruieren (Fakten, keine Schuldzuweisung)
2. Beitragende Ursachen sammeln (meist mehrere!)
3. Systemische Gegenmaßnahmen ableiten, mit Ownern und Terminen
4. Erkenntnisse **teilen** (Sharing!)

## Cultural Debt
Analog zu technischer Schuld: **nicht angegangene Kulturprobleme verzinsen sich**.
Symptome: Silos, Change Fatigue (Wandel-Müdigkeit), Einzel- statt Teamanreize, Angstschweigen.

**Merke:** Psychologische Sicherheit = wichtigster Teamfaktor (Project Aristotle); Just Culture = System schuld, nicht Person$C$,
   '["DevOps","Psychologische Sicherheit","Just Culture","Post-Mortem","DOFD"]', 'Kultur'),

  (v_devops, v_uid, 'Team Topologies & Conways Gesetz',
$C$**Team Topologies** (Matthew Skelton & Manuel Pais) ist das Standardmodell für Teamschnitt in DevOps-Organisationen.

## Conways Gesetz
> "Organisationen entwerfen Systeme, die ihre Kommunikationsstrukturen abbilden."

Silo-Organisation → Silo-Architektur. **Inverse Conway Maneuver:** Organisiere die Teams so, wie die Ziel-Architektur aussehen soll — die Architektur folgt.

## Die 4 Teamtypen
| Teamtyp | Aufgabe |
|---------|---------|
| **Stream-aligned** | Ende-zu-Ende verantwortlich für einen Wertstrom/Produkt (der Normalfall!) |
| **Platform** | Baut interne Plattform, damit Stream-Teams selbstständig arbeiten können |
| **Enabling** | Coacht Teams zeitlich begrenzt in neuen Fähigkeiten (z.B. Test-Automatisierung) |
| **Complicated-Subsystem** | Kapselt Spezialwissen (z.B. Machine-Learning-Kern, Video-Codec) |

## Die 3 Interaktionsmodi
- **Collaboration** — eng zusammenarbeiten (zeitlich begrenzt, zum Entdecken)
- **X-as-a-Service** — klar definierte Schnittstelle, minimale Abstimmung (Plattform!)
- **Facilitating** — befähigen/coachen (Enabling Teams)

## Ziel
**Kognitive Last begrenzen**: Ein Team soll seinen Bereich vollständig verstehen und besitzen können ("You build it, you run it").

**Merke:** Stream-aligned = Standard; Platform = Service; Enabling = Coach auf Zeit; Conway: Architektur spiegelt Organisation$C$,
   '["DevOps","Team Topologies","Conway","Organisation","DOFD"]', 'Organisation'),

  (v_devops, v_uid, 'Change Management: ADKAR & Kotters 8 Schritte',
$C$DevOps-Transformationen scheitern selten an Technik, meist an **Menschen und Wandel**. Zwei Standard-Frameworks:

## ADKAR (Prosci) — individuelle Ebene
Jeder Mensch durchläuft 5 Stufen; die Transformation hakt an der **ersten nicht erfüllten** Stufe:

| Stufe | Frage |
|-------|-------|
| **A**wareness | Weiß ich, WARUM Wandel nötig ist? |
| **D**esire | WILL ich den Wandel mittragen? |
| **K**nowledge | Weiß ich, WIE es geht (Training)? |
| **A**bility | KANN ich es praktisch (Übung, Zeit)? |
| **R**einforcement | Wird es VERANKERT (Anreize, Anerkennung)? |

Diagnose-Beispiel: Team kennt CI/CD-Theorie, wendet sie aber nicht an → **Ability** fehlt (Übung/Freiraum), nicht Knowledge.

## Kotters 8 Schritte — organisationale Ebene
1. **Dringlichkeit** erzeugen (Sense of Urgency)
2. **Führungskoalition** aufbauen
3. **Vision & Strategie** entwickeln
4. Vision **kommunizieren**
5. **Hindernisse beseitigen** / Mitarbeiter befähigen
6. **Quick Wins** erzeugen und sichtbar machen
7. Erfolge **konsolidieren**, weiter treiben
8. Neues in der **Kultur verankern**

**Merke:** ADKAR = Individuum (Awareness→Desire→Knowledge→Ability→Reinforcement); Kotter = Organisation (8 Schritte, beginnt mit Dringlichkeit)$C$,
   '["DevOps","ADKAR","Kotter","Change Management","DOFD"]', 'Transformation'),

  (v_devops, v_uid, 'Value Stream Mapping & Flow Metrics',
$C$**Value Stream Mapping (VSM)** macht den gesamten Wertstrom sichtbar — vom Kundenauftrag/Idee bis zum gelieferten Nutzen — und deckt Wartezeiten und Nacharbeit auf.

## Kennzahlen je Prozessschritt
- **Prozesszeit (Process Time)** — Zeit aktiver Arbeit
- **Wartezeit (Wait/Lead Time)** — Liegezeit zwischen Schritten (oft > 80 % der Gesamtzeit!)
- **%C/A (Percent Complete and Accurate)** — Anteil der Arbeit, den der nächste Schritt **ohne Nacharbeit** verwenden kann

```
[Idee] →(3d warten)→ [Entwicklung 2d, %C/A 90%] →(10d warten)→ [Test 1d, %C/A 60%] → [Deploy]
                                                       ↑ größter Hebel: Wartezeit + Rework
```

## Flow Metrics (Flow Framework, Mik Kersten)
| Metrik | Bedeutung |
|--------|-----------|
| **Flow Time** | Dauer von Arbeitsbeginn bis Lieferung |
| **Flow Velocity** | Erledigte Arbeitselemente pro Zeit |
| **Flow Efficiency** | Prozesszeit ÷ Gesamtzeit (aktiv vs. warten) |
| **Flow Load** | Menge Arbeit im System (≈ WIP) |

## Vorgehen
1. Ist-Wertstrom mit allen Beteiligten mappen (Gemba: dorthin gehen, wo Arbeit passiert)
2. Wartezeiten & niedrige %C/A markieren
3. Soll-Wertstrom entwerfen, größte Blocker zuerst beseitigen

**Merke:** Meist wartet Arbeit statt zu fließen — VSM findet Wartezeiten; %C/A findet Nacharbeit$C$,
   '["DevOps","Value Stream","VSM","Flow Metrics","Lean","DOFD"]', 'Lean & Flow'),

  (v_devops, v_uid, 'Lean-Verschwendungsarten in der IT',
$C$**Lean** identifiziert Verschwendung (japanisch **Muda**) — Arbeit, die keinen Kundennutzen erzeugt. Übertragen auf IT/Software:

## Die Verschwendungsarten mit IT-Beispielen
| Verschwendung | IT-Beispiel |
|---------------|-------------|
| **Wartezeit** | Auf Freigaben, Umgebungen, andere Teams warten |
| **Überproduktion** | Features bauen, die niemand nutzt; Gold Plating |
| **Zusätzliche Prozesse** | Unnötige Doku, Genehmigungsschleifen, Meetings ohne Ergebnis |
| **Teilerledigte Arbeit** | Angefangenes, nicht Deploytes (hoher WIP, halbe Branches) |
| **Taskwechsel / Multitasking** | Mitarbeiter auf 5 Projekten — Rüstzeiten im Kopf |
| **Handoffs** | Ticket-Pingpong zwischen Dev, QA, Ops — Wissensverlust je Übergabe |
| **Defekte / Nacharbeit** | Bugs, Hotfixes, Rollbacks — je später entdeckt, desto teurer |
| **Ungenutztes Talent** | Experten machen Routinearbeit; Ideen der Mitarbeiter ignoriert |

## Gegenmittel in DevOps
- Wartezeit → Self-Service-Umgebungen, Automatisierung
- Teilerledigte Arbeit → WIP-Limits, kleine Batches, häufig deployen
- Handoffs → cross-funktionale Teams ("you build it, you run it")
- Defekte → Tests je Commit, Shift Left, keine bekannten Defekte weitergeben

**Merke:** Größte IT-Verschwendung ist meist WARTEN; teilerledigte Arbeit = Lagerbestand der Softwareentwicklung$C$,
   '["DevOps","Lean","Verschwendung","Muda","Waste","DOFD"]', 'Lean & Flow'),

  (v_devops, v_uid, 'CI vs. Continuous Delivery vs. Continuous Deployment',
$C$Drei Begriffe, die in Prüfungen gern verwechselt werden:

## Die Abgrenzung
| Praktik | Bedeutung |
|---------|-----------|
| **Continuous Integration (CI)** | Entwickler integrieren **mehrmals täglich** in den Hauptzweig; jeder Commit löst automatisch **Build + Tests** aus |
| **Continuous Delivery** | Software ist **jederzeit releasefähig**; der Produktivgang ist eine **manuelle Geschäftsentscheidung** (Knopfdruck) |
| **Continuous Deployment** | Jede Änderung, die alle Prüfungen besteht, geht **automatisch in Produktion** — kein manueller Schritt |

```
Commit → Build → Tests → Staging → [MANUELL] → Prod   = Continuous Delivery
Commit → Build → Tests → Staging → [AUTO]    → Prod   = Continuous Deployment
```

## Deployment ≠ Release
- **Deployment** = technisches Ausbringen der Software auf die Umgebung
- **Release** = Freischalten der Funktion für Nutzer

Entkopplung z.B. per **Feature Flag**: Code ist deployt, aber abgeschaltet (**Dark Launch**). Deployment wird risikoarm und häufig, Release bleibt steuerbar.

## Grundregeln der Deployment-Pipeline
1. **Build once, deploy many** — EIN Artefakt durchläuft alle Stufen (nicht je Stufe neu bauen!)
2. **Stopp bei Rot** — schlägt ein Schritt fehl, stoppt die Pipeline; Fix hat Vorrang
3. **Alles versioniert** — Code, Konfiguration, Infrastruktur, Pipeline selbst (Single Source of Truth)

**Merke:** Delivery = KANN jederzeit (manuelles Go); Deployment = GEHT automatisch; Release ≠ Deployment (Feature Flags)$C$,
   '["DevOps","CI/CD","Continuous Delivery","Deployment","Release","DOFD"]', 'CI/CD'),

  (v_devops, v_uid, 'Trunk-Based Development & Testpyramide',
$C$## Trunk-Based Development
Alle Entwickler arbeiten auf dem **Hauptzweig (trunk/main)** — direkt oder über **kurzlebige Branches (< 1–2 Tage)**.

**Warum?** Langlebige Feature-Branches führen zu **"Integration Hell"**: riesige Merge-Konflikte, späte Fehlerentdeckung, seltene Releases.

**Wie geht Unfertiges?** Hinter **Feature Flags** verstecken — Code ist integriert, aber inaktiv.

**Voraussetzungen:** starke Testautomatisierung, CI bei jedem Commit, kleine Batches.

## Testpyramide
```
        ▲  E2E / UI-Tests      (wenige — langsam, teuer, fragil)
       ▲▲  Integrationstests   (mittel — Komponenten zusammen)
    ▲▲▲▲▲  Unit-Tests          (viele — schnell, billig, präzise)
```
- **Unten breit:** Tausende Unit-Tests laufen in Sekunden → schnelles Feedback (Second Way)
- **Oben schmal:** wenige E2E-Tests für kritische Nutzerpfade
- **Anti-Pattern "Eistüte":** viele manuelle UI-Tests, kaum Unit-Tests → langsam und instabil

## Ergänzende Praktiken
- **Shift Left:** Tests (und Security) so früh wie möglich
- **TDD:** Test zuerst schreiben (Red) → Code bis Test grün (Green) → aufräumen (Refactor)

**Merke:** Trunk-based + Feature Flags = ständige Integration ohne Integration Hell; Pyramide: viele Unit, wenige E2E$C$,
   '["DevOps","Trunk-Based","Testpyramide","TDD","Shift Left","DOFD"]', 'CI/CD'),

  (v_devops, v_uid, 'Error Budget & Toil (SRE vertieft)',
$C$Zwei zentrale SRE-Konzepte (Site Reliability Engineering, Google/Ben Treynor):

## Error Budget
$$\text{Error Budget} = 100\,\% - \text{SLO}$$

Beispiel: SLO 99,9 % Verfügbarkeit → Error Budget = **0,1 %** ≈ **43,8 Minuten Ausfall pro Monat**.

**Die Logik:**
- Budget **vorhanden** → Team darf riskieren: Features, Deployments, Experimente
- Budget **aufgebraucht** → Feature-Stopp, Fokus auf Stabilisierung

**Warum genial?** Löst den ewigen Konflikt "Dev will Tempo, Ops will Stabilität" **datenbasiert** statt politisch. 100 % Verfügbarkeit ist explizit NICHT das Ziel — sie wäre unbezahlbar und verhindert Innovation.

## Toil
**Toil** = Arbeit, die ist: **manuell, wiederkehrend, automatisierbar, reaktiv, ohne dauerhaften Wert, linear mitwachsend** mit dem Service.

Beispiele: Tickets abarbeiten, Server manuell neustarten, Zertifikate von Hand erneuern.

- **Google-Faustregel:** Toil < **50 %** der SRE-Zeit — der Rest gehört Engineering (Automatisierung)
- Gegenmittel: Automatisieren, Self-Service, Ursachen beheben statt Symptome

## Resilience Engineering
Systeme so bauen, dass sie Ausfälle **überstehen**: Redundanz, **Graceful Degradation** (eingeschränkt weiterlaufen statt Totalausfall), **Circuit Breaker** (defekte Abhängigkeit abklemmen, bevor sie alles mitreißt).

**Merke:** Error Budget = 100 % − SLO → reguliert Tempo vs. Stabilität; Toil < 50 % — automatisiere es weg$C$,
   '["DevOps","SRE","Error Budget","Toil","Resilience","DOFD"]', 'SRE'),

  (v_devops, v_uid, 'Goodharts Gesetz & Metrik-Fallen',
$C$> **Goodharts Gesetz:** "Sobald eine Kennzahl zum Ziel wird, ist sie keine gute Kennzahl mehr."

Menschen optimieren auf die Messung, nicht auf den Zweck dahinter.

## Klassische Beispiele
- **Lines of Code** als Produktivitätsmaß → aufgeblähter Code
- **Anzahl geschlossener Tickets** → Tickets künstlich klein schneiden
- **Testabdeckung 90 %** als Pflicht → sinnlose Tests ohne Assertions
- **Velocity als Ziel** → Story-Point-Inflation

## Wichtige Unterscheidungen
| Begriff | Bedeutung |
|---------|-----------|
| **Vanity Metrics** | Sehen gut aus, ändern nichts (z.B. Downloads gesamt) |
| **Actionable Metrics** | Führen zu Entscheidungen (z.B. Change Failure Rate je Service) |
| **Lead-Indikatoren** | Vorlaufend, beeinflussbar (Testabdeckung, Deploy-Frequenz) |
| **Lag-Indikatoren** | Nachlaufend, Ergebnis (Kundenzufriedenheit, Umsatz, Ausfälle) |

## Regeln für gesunde Metriken
1. **Outcomes vor Output** — Wirkung beim Kunden zählt, nicht Fleiß
2. **System- statt Individualmetriken** — DORA-Metriken bewerten den Wertstrom, NIEMALS einzelne Personen
3. Metriken **im Set** betrachten (Tempo UND Stabilität) — sonst wird eine auf Kosten der anderen optimiert
4. Metriken regelmäßig hinterfragen und austauschen

**Merke:** Kennzahl als Ziel = Kennzahl kaputt (Goodhart); Outcomes > Output; nie Einzelpersonen an DORA messen$C$,
   '["DevOps","Goodhart","Metriken","Vanity Metrics","Measurement","DOFD"]', 'Metriken'),

  (v_devops, v_uid, 'ChatOps & Sharing-Praktiken',
$C$**Sharing** ist das S in CALMS — Wissen und Erfahrung fließen frei durch die Organisation.

## ChatOps
**Bots führen Betriebs-Kommandos direkt im Team-Chat aus** (Slack/Teams, historisch GitHubs Hubot):
```
/deploy web-app to production
→ Bot deployt, postet Status + Logs in den Kanal
```
**Nutzen:**
- **Transparenz** — alle sehen, wer was wann getan hat
- **Lernen durch Zusehen** — Neue lernen Abläufe im Kanal mit
- **Automatische Dokumentation** — Chat-Verlauf = Audit-Log
- Zugriff ohne VPN/Server-Login, mit Berechtigungsprüfung im Bot

## Weitere Sharing-Praktiken
| Praktik | Beschreibung |
|---------|-------------|
| **Communities of Practice / Gilden** | Freiwillige themenbezogene Gruppen quer über Teams (z.B. Testing-Gilde) |
| **InnerSource** | Open-Source-Prinzipien intern: jeder darf in fremde Repos Pull Requests stellen |
| **Brown-Bag-Sessions** | Informelle Lern-Sessions (in der Mittagspause) |
| **Pair Programming / Mob Programming** | Wissen fließt beim gemeinsamen Arbeiten |
| **Shadowing** | On-Call/Ops begleiten → Empathie zwischen Dev und Ops, T-shaped Skills |
| **Interne Wikis / Doku als Code** | Wissen auffindbar statt in Köpfen |

**Merke:** ChatOps = Kommandos im Chat → Transparenz + Auto-Doku; InnerSource = intern wie Open Source$C$,
   '["DevOps","ChatOps","Sharing","InnerSource","CALMS","DOFD"]', 'Kultur'),

  (v_devops, v_uid, 'ITIL 4 & DevOps — Freunde, nicht Feinde',
$C$**ITIL** (IT Service Management) und **DevOps** gelten oft als Gegensätze — **ITIL 4 (2019)** hat sich aber Lean/Agile stark angenähert. Beide sind **komplementär**.

## Der klassische Konflikt
Altes Change Management: Jede Änderung durchs **CAB** (Change Advisory Board), wochenlange Genehmigungen → tötet Deployment-Frequenz.

## Die Lösung: Change-Typen richtig nutzen
| Change-Typ | Merkmal | DevOps-Umgang |
|-----------|---------|---------------|
| **Standard Change** | **Vorab genehmigt**, risikoarm, wiederholbar | **Automatisiert per Pipeline deployen** — kein CAB nötig! |
| **Normal Change** | Individuelle Bewertung nötig | Leichtgewichtig, Peer Review als Genehmigung |
| **Emergency Change** | Incident-Behebung | Beschleunigter Prozess, Doku nachher |

**Kernidee:** Routinedeployments als Standard Changes deklarieren → die Pipeline selbst (Tests, Gates) IST die Kontrolle. CAB nur noch für echte Hochrisiko-Änderungen.

## ITIL 4 Guiding Principles (Auswahl, DevOps-nah)
- "Progress iteratively with feedback" (= kleine Batches + Feedback)
- "Optimize and automate"
- "Collaborate and promote visibility"
- "Focus on value"

**Merke:** Standard Change = vorab genehmigt → perfekt für automatisierte Deployments; CAB nur für Hochrisiko$C$,
   '["DevOps","ITIL","Change Management","Standard Change","DOFD"]', 'Organisation'),

  (v_devops, v_uid, 'Project to Product & Continuous Funding',
$C$**"Project to Product"** (Mik Kersten): Software sollte als **langlebiges Produkt** finanziert und organisiert werden, nicht als temporäres **Projekt**.

## Projekt- vs. Produktmodell
| | Projekt | Produkt |
|--|---------|---------|
| Dauer | Temporär (Ende definiert) | Langlebig (Lebenszyklus) |
| Team | Wird zusammengestellt und **aufgelöst** | **Stabil**, wächst mit dem Produkt |
| Budget | Einmalig je Projekt beantragt | **Kapazitätsbasiert**, rollierend |
| Erfolg | Im Plan (Zeit, Budget, Scope) = **Output** | Geschäftswirkung = **Outcome** |
| Wissen | Geht bei Auflösung verloren | Bleibt im Team |

## Probleme des Projektmodells für DevOps
- "You build it, you run it" unmöglich, wenn das Team nach Go-Live verschwindet
- Wartung/Betrieb ist chronisch unterfinanziert ("Projekt ist ja fertig")
- Jahresbudget-Wasserfall widerspricht iterativem Lernen

## Continuous Funding
- **Stabile Teams/Wertströme finanzieren**, nicht Einzelvorhaben
- **Rollierende, inkrementelle Budgets** (z.B. quartalsweise nachsteuern statt Jahresplan)
- Entscheidungen anhand **Outcomes** (Nutzung, Kundennutzen, DORA-Trends)

**Merke:** Produkte statt Projekte: stabile Teams, kapazitätsbasierte Budgets, Outcomes statt Output$C$,
   '["DevOps","Project to Product","Funding","Kersten","DOFD"]', 'Organisation'),

  (v_devops, v_uid, 'AIOps — KI im IT-Betrieb',
$C$**AIOps** (Artificial Intelligence for IT Operations) = **Machine Learning auf Betriebsdaten** (Metriken, Logs, Traces, Events), um den Betrieb zu automatisieren und zu beschleunigen.

## Kernfähigkeiten
| Fähigkeit | Beschreibung |
|-----------|-------------|
| **Anomalieerkennung** | Abweichungen vom gelernten Normalverhalten erkennen — statt starrer Schwellwerte |
| **Alarm-Korrelation & Deduplizierung** | Hunderte zusammenhängende Alerts zu EINEM Incident bündeln → gegen **Alert Fatigue** |
| **Ursachenanalyse (RCA)** | Events über Systeme hinweg korrelieren: Was war der Auslöser? |
| **Prognosen** | Kapazität/Ausfälle vorhersagen (z.B. "Disk voll in 3 Tagen") |
| **Automatisierte Remediation** | Bekannte Probleme automatisch beheben (Runbook-Automation, Neustart, Scale-out) |

## Nutzen für DevOps
- Weniger Toil, schnellere MTTR (Time to Restore)
- Verstärkt den **Second Way** (schnelleres, klügeres Feedback aus Produktion)

## Grenzen
- Braucht **gute Datenqualität** und Historie zum Lernen
- ML-Empfehlungen brauchen anfangs menschliche Prüfung (Vertrauen aufbauen)
- Kein Ersatz für Observability-Grundlagen — Müll rein, Müll raus

**Merke:** AIOps = ML auf Ops-Daten: Anomalien erkennen, Alarme bündeln, Ursachen finden, automatisch beheben$C$,
   '["DevOps","AIOps","Machine Learning","Monitoring","Alert Fatigue","DOFD"]', 'Betrieb'),

  (v_devops, v_uid, 'DevOps-Transformation: Einstieg & Antipatterns',
$C$## Antipatterns (Prüfungsklassiker!)
| Antipattern | Warum falsch |
|-------------|--------------|
| **Separates "DevOps-Team"** | Wird zum **dritten Silo** zwischen Dev und Ops — Gegenteil des Ziels |
| **Umbenennen statt verändern** | Ops-Team heißt jetzt "DevOps-Team", arbeitet aber wie vorher |
| **Nur Tools kaufen** | CALMS: ohne Culture keine Transformation |
| **Big Bang** | Alles auf einmal umstellen → Chaos, Widerstand, Rollback |
| **DevOps-Metriken für Einzelbewertung** | Goodhart + zerstört psychologische Sicherheit |

(Ausnahme: ein zeitlich begrenztes **Enabling-Team**, das Teams befähigt und sich überflüssig macht, ist okay.)

## Empfohlener Einstieg
1. **Pilot-Wertstrom wählen** — ein Produkt/Team mit Motivation und überschaubarem Risiko
2. **Basislinie messen** — DORA-Metriken + VSM des Ist-Zustands
3. **Quick Wins liefern** — sichtbare Verbesserungen (z.B. Deployment automatisieren)
4. **Lernen & ausweiten** — Erfahrungen teilen (CoP), nächsten Wertstrom anschließen
5. **Inkrementell, nicht Big Bang**

## Führung
- **Transformationale Führung**: Vision, Vorbild, intellektuelle Anregung, individuelle Unterstützung
- **Servant Leadership**: Hindernisse beseitigen statt Kommandieren
- **"Autonomie mit Alignment"**: Richtung zentral, Entscheidungen dezentral

**Merke:** Kein separates DevOps-Silo, kein Big Bang — Pilot, Basislinie (DORA), Quick Wins, inkrementell$C$,
   '["DevOps","Transformation","Antipattern","Leadership","DOFD"]', 'Transformation'),

  (v_devops, v_uid, 'Immutable Infrastructure & Configuration Drift',
$C$## Das Problem: Snowflake-Server
Ein **Snowflake-Server** wurde über Jahre von Hand gepflegt — einzigartig wie eine Schneeflocke, **nicht reproduzierbar**, Doku veraltet. Fällt er aus, beginnt die Archäologie.

**Configuration Drift** = Umgebungen (Dev/Test/Prod), die identisch sein sollten, driften durch manuelle Eingriffe auseinander → "Works on my machine", Prod-Überraschungen.

## Die Lösung: Immutable Infrastructure
Server/Container werden **nie verändert, sondern ersetzt**:
```
Änderung nötig? → neues Image bauen → neue Instanz deployen → alte wegwerfen
NICHT: per SSH auf den Server und patchen!
```
Container sind von Natur aus immutable — jedes Deployment ist ein frisches Image.

## Wichtige Begriffe
| Begriff | Bedeutung |
|---------|-----------|
| **Deklarativ** | Beschreibt WAS (Zielzustand) — Terraform, Bicep, Kubernetes-YAML |
| **Imperativ** | Beschreibt WIE (Schrittfolge) — Skripte, CLI-Befehle |
| **Idempotenz** | Mehrfaches Anwenden = gleiches Ergebnis (2. Lauf ändert nichts mehr) |
| **GitOps** | Git = einzige Quelle der Wahrheit; ein Operator gleicht Ist ↔ Soll automatisch ab |

## Zusammenspiel
IaC (deklarativ, versioniert) + Immutable Images + GitOps-Abgleich = kein Drift, jede Umgebung reproduzierbar auf Knopfdruck.

**Merke:** Snowflake = handgepflegt & einzigartig (schlecht); Immutable = ersetzen statt ändern; Idempotenz = mehrfach anwenden, gleiches Ergebnis$C$,
   '["DevOps","IaC","Immutable","Configuration Drift","Snowflake","GitOps","DOFD"]', 'Infrastruktur'),

  (v_devops, v_uid, 'Die Lernende Organisation (Senge)',
$C$**Peter Senge** ("The Fifth Discipline") beschreibt, wie Organisationen dauerhaft lernen — die theoretische Basis des **Third Way**.

## Die 5 Disziplinen
| Disziplin | Bedeutung |
|-----------|-----------|
| **Personal Mastery** | Individuen streben nach ständiger persönlicher Weiterentwicklung |
| **Mental Models** | Verborgene Grundannahmen aufdecken und hinterfragen ("So haben wir das immer gemacht") |
| **Shared Vision** | Echtes gemeinsames Zielbild statt verordneter Mission |
| **Team Learning** | Teams lernen im Dialog — Wissen des Teams > Summe der Einzelnen |
| **Systems Thinking** | Die **verbindende 5. Disziplin**: Zusammenhänge und Rückkopplungen sehen statt Einzelereignisse |

## Systems Thinking in DevOps
- Der Wertstrom ist EIN System — lokale Optimierung (z.B. nur Dev schneller) bringt nichts (Theory of Constraints!)
- Ursachen statt Symptome: Warum passieren Fehler immer wieder? → Systemstruktur ändern
- First Way = Systemdenken angewandt auf den Fluss

## Verbindung zu DevOps-Praktiken
- Mental Models ↔ Blameless Post-Mortems (Annahmen sichtbar machen)
- Team Learning ↔ Pairing, CoP, Game Days
- Shared Vision ↔ gemeinsame Ziele für Dev+Ops statt Silo-KPIs

**Merke:** 5 Disziplinen: Personal Mastery, Mental Models, Shared Vision, Team Learning + Systems Thinking als Klammer$C$,
   '["DevOps","Senge","Lernende Organisation","Systems Thinking","DOFD"]', 'Kultur');

  -- ════════════════════════════════════════════════════════════════
  -- KUBERNETES — Praxis aus dem Lernheft
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_kubernetes, v_uid, 'Labels & Selectors — wie alles zusammenfindet',
$C$**Labels** sind Key-Value-Paare an Objekten. **Selectors** finden Objekte anhand ihrer Labels. Das ist der Klebstoff zwischen Deployment, Pod und Service.

## Das Zusammenspiel
```yaml
# Deployment: erzeugt Pods MIT Label
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: todo-api        # "verwalte Pods mit diesem Label"
  template:
    metadata:
      labels:
        app: todo-api      # Pods BEKOMMEN dieses Label
    spec:
      containers:
      - name: todo-api
        image: todo-api:latest
---
# Service: findet dieselben Pods ÜBER das Label
apiVersion: v1
kind: Service
metadata:
  name: todo-api
spec:
  selector:
    app: todo-api          # Traffic an alle Pods mit app=todo-api
  ports:
  - port: 80               # Service lauscht auf 80 ...
    targetPort: 3000       # ... leitet an Container-Port 3000
```

## Warum so indirekt?
Pod-IPs sind **kurzlebig** — Pods sterben und starten mit neuer IP. Der Service bietet eine **stabile Adresse** und findet die aktuellen Pods dynamisch per Label. Neuer Pod mit passendem Label → automatisch im Load Balancing.

## Nützliche Befehle
```bash
kubectl get pods -l app=todo-api        # nach Label filtern
kubectl get pods --show-labels
kubectl describe service todo-api       # zeigt "Endpoints" = gefundene Pod-IPs
```

**Merke:** matchLabels (Deployment) und selector (Service) müssen zu den Pod-Labels passen — Tippfehler = 0 Endpoints$C$,
   '["Kubernetes","Labels","Selector","Service","Deployment"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'minikube — Kubernetes lokal betreiben',
$C$**minikube** startet einen kompletten **1-Node-Kubernetes-Cluster lokal** (in VM oder Container) — ideal zum Lernen und Testen ohne Cloud-Kosten.

## Typischer Workflow
```bash
# 1. Cluster starten
minikube start

# 2. Lokal gebautes Image in den Cluster laden
#    (minikube sieht NICHT automatisch lokale Docker-Images!)
docker build -t todo-api:latest .
minikube image load todo-api:latest

# 3. Manifeste anwenden
kubectl apply -f k8s/

# 4. Service im Browser öffnen (Tunnel + URL)
minikube service todo-api

# 5. Dashboard (Web-UI)
minikube dashboard

# Aufräumen
minikube stop      # anhalten
minikube delete    # Cluster löschen
```

## Wichtige Stolperfalle
Ein `LoadBalancer`-Service bekommt lokal **keine externe IP** (keine Cloud!) — `minikube service <name>` oder `minikube tunnel` schafft den Zugang.

Bei lokalen Images außerdem `imagePullPolicy: Never` oder `IfNotPresent` setzen, sonst versucht Kubernetes, das Image aus einer Registry zu ziehen.

## Alternativen
- **kind** (Kubernetes in Docker) — schnell, gut für CI
- **k3s/k3d** — abgespecktes Kubernetes
- **Docker Desktop** — eingebauter K8s-Cluster

**Merke:** minikube start → image load → kubectl apply → minikube service; lokale Images müssen explizit geladen werden$C$,
   '["Kubernetes","minikube","lokal","kind","Lernen"]', 'Praxis');

  -- ════════════════════════════════════════════════════════════════
  -- DOCKER — Praxis aus dem Lernheft
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_docker, v_uid, 'EXPOSE & Port-Mapping — die Doku-Falle',
$C$## Die Prüfungsfalle
```dockerfile
EXPOSE 3000
```
**`EXPOSE` öffnet KEINEN Port!** Es ist **reine Dokumentation**: "Diese Anwendung lauscht auf Port 3000." Ohne weiteres bleibt der Container von außen unerreichbar.

## Ports wirklich veröffentlichen
```bash
# -p HOST:CONTAINER
docker run -p 8080:3000 todo-api
# → http://localhost:8080 erreicht Port 3000 im Container

# -P (groß): ALLE per EXPOSE deklarierten Ports
# auf zufällige Host-Ports mappen
docker run -P todo-api
docker port <container>     # zeigt die Zuordnung
```

## In docker-compose.yml
```yaml
services:
  api:
    build: .
    ports:
      - "8080:3000"        # Host:Container
```

## Wann ist KEIN Mapping nötig?
Container im **selben Docker-Netzwerk** erreichen sich direkt über den Servicenamen und Container-Port:
```
api ──▶ http://db:5432     # kein -p nötig, nur intern
```
Port-Mapping braucht nur, wer **von außen (Host/Internet)** erreichbar sein soll.

**Merke:** EXPOSE = nur Doku; wirklich öffnen mit -p Host:Container; intern reicht das Docker-Netzwerk$C$,
   '["Docker","EXPOSE","Ports","Port-Mapping","Netzwerk"]', 'Grundlagen'),

  (v_docker, v_uid, 'Konfiguration über Umgebungsvariablen (12-Factor)',
$C$**Gleicher Code, jede Umgebung** — Konfiguration gehört ins Environment, nicht in den Code (Prinzip III der **12-Factor App**).

## Im Code: Fallback-Muster
```javascript
// Node.js: Umgebungsvariable ODER Default
const port = process.env.PORT || 3000;
const dbUrl = process.env.DATABASE_URL || 'postgres://localhost:5432/dev';
```

## Werte setzen
```bash
# docker run
docker run -e PORT=4000 -e NODE_ENV=production todo-api

# docker-compose.yml
services:
  api:
    environment:
      - PORT=4000
      - NODE_ENV=production
    env_file:
      - .env               # Variablen aus Datei (nicht committen!)
```

```yaml
# Kubernetes: aus ConfigMap/Secret
env:
- name: PORT
  value: "3000"
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

## Warum so?
- **Ein Image für alle Umgebungen** — Dev/Test/Prod unterscheiden sich nur in Variablen (Build once, deploy many!)
- **Keine Secrets im Image** — Passwörter niemals ins Dockerfile oder den Code einbacken
- Konfig ändern ohne Rebuild

**Merke:** process.env.X || Default im Code; Werte via -e / environment / ConfigMap — nie Secrets ins Image$C$,
   '["Docker","Umgebungsvariablen","12-Factor","Konfiguration","Secrets"]', 'Praxis');

  -- ════════════════════════════════════════════════════════════════
  -- AZURE — AZ-900-Prüfungsstoff
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_azure, v_uid, 'Shared Responsibility Model',
$C$Das **Modell der gemeinsamen Verantwortung** regelt, wer wofür zuständig ist — Kunde oder Microsoft. AZ-900-Kernthema!

## Die Verteilung
| Verantwortung | On-Prem | IaaS | PaaS | SaaS |
|---------------|---------|------|------|------|
| Daten & Informationen | Kunde | **Kunde** | **Kunde** | **Kunde** |
| Konten & Identitäten | Kunde | **Kunde** | **Kunde** | **Kunde** |
| Endgeräte | Kunde | **Kunde** | **Kunde** | **Kunde** |
| Anwendungen | Kunde | Kunde | geteilt | Microsoft |
| Betriebssystem | Kunde | **Kunde** | Microsoft | Microsoft |
| Netzwerk-Steuerung | Kunde | geteilt | geteilt | Microsoft |
| Physische Hosts/Netz/RZ | Kunde | **Microsoft** | **Microsoft** | **Microsoft** |

## Die drei Merksätze
1. **IMMER beim Kunden:** Daten, Identitäten/Konten, Endgeräte, Zugriffsverwaltung
2. **IMMER bei Microsoft:** physisches Rechenzentrum, physisches Netzwerk, physische Hosts
3. **Verschiebt sich mit dem Modell:** OS, Middleware, Anwendungen — je mehr "as a Service", desto mehr trägt Microsoft

## Typische Prüfungsfragen
- "Wer patcht das Betriebssystem einer Azure-VM?" → **Kunde** (IaaS!)
- "Wer patcht das OS bei Azure App Service?" → **Microsoft** (PaaS)
- "Wer ist für die Daten in Microsoft 365 verantwortlich?" → **Kunde** (immer!)

**Merke:** Daten + Identitäten = immer Kunde; Physik = immer Microsoft; OS = beim Kunden nur bei IaaS$C$,
   '["Azure","AZ-900","Shared Responsibility","Cloud","Sicherheit"]', 'Cloud-Konzepte'),

  (v_azure, v_uid, 'IaaS, PaaS & SaaS',
$C$Die drei **Cloud-Dienstmodelle** unterscheiden sich darin, wie viel du selbst verwaltest.

## Die Wohn-Analogie
| Modell | Analogie | Du kümmerst dich um ... |
|--------|----------|------------------------|
| **IaaS** | Grundstück mit Anschlüssen | Alles ab OS aufwärts (OS, Patches, Runtime, App) |
| **PaaS** | Rohbau/fertige Wohnung | Nur deine Anwendung & Daten |
| **SaaS** | Möbliertes Apartment mit Service | Nur Nutzung, Daten, Zugänge |

## Azure-Beispiele
| Modell | Azure-Dienste |
|--------|---------------|
| **IaaS** | Virtual Machines, VNet, Managed Disks |
| **PaaS** | App Service, Azure SQL Database, Azure Functions, AKS (Control Plane) |
| **SaaS** | Microsoft 365, Dynamics 365, Outlook.com |

## Trade-off
```
IaaS  ◀── mehr Kontrolle & Flexibilität ── mehr Verwaltungsaufwand
SaaS  ◀── weniger Aufwand ─────────────── weniger Kontrolle
```

## Prüfungssignale
- "Lift & Shift einer bestehenden VM" → IaaS
- "Nur Code deployen, kein OS-Management" → PaaS
- "Fertige Anwendung einfach nutzen (E-Mail, CRM)" → SaaS
- Serverless (Functions) = Extremform von PaaS: nicht mal Instanzen verwalten, Abrechnung pro Ausführung, **Skalierung bis auf null**

**Merke:** IaaS = Miete Infrastruktur (OS selbst patchen!); PaaS = Miete Plattform (nur App+Daten); SaaS = Miete Software$C$,
   '["Azure","AZ-900","IaaS","PaaS","SaaS","Cloud"]', 'Cloud-Konzepte'),

  (v_azure, v_uid, 'Public, Private & Hybrid Cloud + Azure Arc',
$C$Die **Bereitstellungsmodelle** beschreiben, WO die Cloud läuft und wem sie gehört.

## Die Modelle
| Modell | Beschreibung | Typisch für |
|--------|-------------|-------------|
| **Public Cloud** | Ressourcen beim Cloud-Anbieter, von allen Kunden geteilt (mandantenfähig) | Standard; keine Hardware-Investition, schnelle Skalierung |
| **Private Cloud** | Cloud-Technologie exklusiv für EINE Organisation (eigenes RZ oder gehostet) | Strenge Compliance, volle Kontrolle, teuer |
| **Hybrid Cloud** | Kombination: Private/On-Prem + Public, verbunden | Migrationsphasen, Datenhaltung lokal + Skalierung in der Cloud |
| **Multi-Cloud** | Mehrere Public-Cloud-Anbieter parallel (Azure + AWS) | Vendor-Lock-in vermeiden, Best-of-Breed |

## Cloud Bursting
Hybrid-Muster: Grundlast läuft privat/on-prem, **Lastspitzen "platzen" in die Public Cloud** (nur dann zahlen).

## Azure-Dienste für Hybrid/Multi-Cloud
- **Azure Arc:** Ressourcen **außerhalb** Azures (On-Prem-Server, Kubernetes, andere Clouds) in Azure **verwalten** — Policies, RBAC, Monitoring wie für Azure-Ressourcen
- **Azure Stack (HCI):** Azure-Dienste **im eigenen Rechenzentrum** betreiben

## Prüfungssignale
- "On-Prem-Server mit Azure Policy verwalten" → **Azure Arc**
- "Azure-Dienste lokal ausführen" → **Azure Stack**
- "Lastspitzen in die Cloud auslagern" → **Hybrid / Cloud Bursting**

**Merke:** Public = geteilt beim Anbieter; Private = exklusiv; Hybrid = beides verbunden; Arc = fremde Ressourcen in Azure verwalten$C$,
   '["Azure","AZ-900","Hybrid Cloud","Azure Arc","Cloud-Modelle"]', 'Cloud-Konzepte'),

  (v_azure, v_uid, 'CapEx vs. OpEx & die drei Kostenwerkzeuge',
$C$## CapEx vs. OpEx
| | **CapEx** (Capital Expenditure) | **OpEx** (Operational Expenditure) |
|--|-------------------------------|-----------------------------------|
| Was | **Vorab-Investition** in eigene Hardware/RZ | **Laufende Kosten** nach Verbrauch |
| Abrechnung | Einmalig, wird über Jahre abgeschrieben | Monatlich, sofort absetzbar |
| Risiko | Über-/Unterdimensionierung | Kosten skalieren mit Nutzung |
| Cloud? | On-Premises-Modell | **Cloud-Modell** (Pay-as-you-go) |

Cloud verschiebt IT-Kosten von CapEx zu OpEx — **verbrauchsbasiertes Modell**: zahle nur, was du nutzt; keine Vorabkosten; jederzeit kündbar.

## Die drei Kostenwerkzeuge (Verwechslungsgefahr!)
| Werkzeug | Frage | Zeitpunkt |
|----------|-------|-----------|
| **Preisrechner (Pricing Calculator)** | "Was KOSTET mich diese Azure-Konfiguration?" | **Vor** dem Deployment (Zukunft) |
| **TCO-Rechner** | "Was SPARE ich gegenüber On-Premises?" (inkl. Strom, Personal, Hardware über Jahre) | Vor der Migration (Vergleich) |
| **Cost Management + Billing** | "Was GEBE ich gerade aus?" — Analyse, Budgets, Warnungen | **Nach** dem Deployment (laufend) |

## Weitere Kostenfakten (AZ-900)
- **Eingehender Traffic (Ingress) kostenlos, ausgehender (Egress) kostet**
- Preise **unterscheiden sich je Region**
- Sparen: **Reservierungen** (1/3 Jahre, bis ~72 %), **Spot-VMs** (entziehbar!), **Hybrid Benefit** (eigene Lizenzen mitbringen)

**Merke:** Cloud = CapEx→OpEx; Preisrechner = künftige Azure-Kosten, TCO = Vergleich mit On-Prem, Cost Management = Ist-Kosten$C$,
   '["Azure","AZ-900","CapEx","OpEx","TCO","Kosten"]', 'Cloud-Konzepte'),

  (v_azure, v_uid, 'Skalierung, Elastizität & Cloud-Vorteile',
$C$## Vertikal vs. Horizontal (Prüfungsklassiker)
| | **Vertikal** (Scale **up/down**) | **Horizontal** (Scale **out/in**) |
|--|--------------------------------|----------------------------------|
| Prinzip | **Größere** Maschine (mehr CPU/RAM) | **Mehr** Instanzen derselben Maschine |
| Grenze | Hardware-Maximum, oft Neustart | Nahezu unbegrenzt |
| Beispiel | VM von D2s auf D8s ändern | Von 2 auf 10 VMs hinter Load Balancer |

**Elastizität** = das System passt die Ressourcen **automatisch** an die Last an (Autoscaling: bei Lastspitze ausskalieren, danach wieder ein).

## Die Cloud-Vorteile (AZ-900-Vokabular)
| Vorteil | Bedeutung |
|---------|-----------|
| **Hochverfügbarkeit** | Maximale Betriebszeit, per SLA zugesichert (99,9 % ...) |
| **Skalierbarkeit** | Ressourcen können mitwachsen (manuell oder automatisch) |
| **Elastizität** | Automatisches Anpassen an Lastschwankungen |
| **Zuverlässigkeit** | System übersteht Ausfälle (Redundanz, Regionen) |
| **Vorhersehbarkeit** | Performance (Autoscaling) und Kosten (Tools) planbar |
| **Agilität** | Ressourcen in Minuten bereitstellen statt Wochen |
| **Sicherheit & Governance** | Zentrale Richtlinien, Updates, professionelle Abwehr |
| **Verwaltbarkeit** | Automatisierung, Vorlagen, zentrale Überwachung |

## Prüfungssignale
- "Mehr RAM für die Datenbank-VM" → vertikal
- "Webshop zum Black Friday automatisch mehr Instanzen" → horizontal + Elastizität

**Merke:** Vertikal = größer; horizontal = mehr; Elastizität = automatisch rauf UND runter$C$,
   '["Azure","AZ-900","Skalierung","Elastizität","Hochverfügbarkeit"]', 'Cloud-Konzepte'),

  (v_azure, v_uid, 'Azure-Ressourcenhierarchie & Ressourcengruppen',
$C$Azure organisiert alles in einer **4-stufigen Hierarchie** — Einstellungen **vererben sich nach unten**.

## Die Hierarchie
```
Verwaltungsgruppe (Management Group)
   └── Abonnement (Subscription)
         └── Ressourcengruppe (Resource Group)
               └── Ressource (VM, Storage, DB ...)
```

| Ebene | Zweck |
|-------|-------|
| **Verwaltungsgruppe** | Bündelt mehrere Abonnements (Konzern: je Abteilung/Umgebung); Policies/RBAC zentral vererben; bis zu 6 Ebenen verschachtelbar |
| **Abonnement** | Abrechnungs- und Zugriffsgrenze; ein Konto kann mehrere haben (Dev/Prod trennen) |
| **Ressourcengruppe (RG)** | Logischer Container zusammengehöriger Ressourcen (z.B. eine App) |
| **Ressource** | Einzelner Dienst |

## Ressourcengruppen-Regeln (Prüfung!)
- Jede Ressource liegt in **genau einer** RG
- RGs sind **nicht verschachtelbar**
- Ressourcen können zwischen RGs **verschoben** werden
- **RG löschen = ALLE enthaltenen Ressourcen werden gelöscht** — praktisch zum Aufräumen:
```bash
az group delete --name rg-learn --yes
```
- RBAC/Policies auf RG gelten für alle Ressourcen darin (Vererbung)

## Gute Praxis
Ressourcen mit gleichem Lebenszyklus in eine RG (App + DB + Storage einer Umgebung) → gemeinsam deployen, überwachen, löschen.

**Merke:** Verwaltungsgruppe → Abonnement → RG → Ressource; Vererbung nach unten; RG löschen räumt alles ab$C$,
   '["Azure","AZ-900","Ressourcengruppe","Abonnement","Hierarchie","Governance"]', 'Verwaltung'),

  (v_azure, v_uid, 'Storage: Zugriffsebenen & Redundanz',
$C$## Zugriffsebenen (Access Tiers) für Blob Storage
Je "kälter", desto **billiger speichern, aber teurer/langsamer zugreifen**:

| Tier | Mindestdauer | Zugriff | Für |
|------|--------------|---------|-----|
| **Hot** | — | sofort | Häufig genutzte Daten |
| **Cool** | ≥ 30 Tage | sofort | Selten genutzt (Backups) |
| **Cold** | ≥ 90 Tage | sofort | Sehr selten genutzt |
| **Archive** | ≥ 180 Tage | **offline** — Stunden Rehydrierung! | Langzeitarchiv, Compliance |

Vorzeitiges Löschen/Verschieben → Gebühr für die Restlaufzeit. **Archive** ist die einzige Offline-Stufe.

## Redundanzoptionen (die Leiter)
| Option | Kopien | Schützt vor |
|--------|--------|-------------|
| **LRS** (lokal redundant) | 3 Kopien in EINEM Rechenzentrum | Disk-/Rack-Ausfall |
| **ZRS** (zonenredundant) | 3 Kopien über 3 **Verfügbarkeitszonen** | RZ-/Zonen-Ausfall |
| **GRS** (georedundant) | LRS + 3 Kopien in **Partnerregion** | Regions-Ausfall |
| **GZRS** | ZRS + Kopien in Partnerregion | Zonen- UND Regions-Ausfall (max. Schutz) |
| **RA-GRS / RA-GZRS** | wie oben + **Lesezugriff** auf die Sekundärregion | + Lesen auch ohne Failover |

```
LRS < ZRS < GRS < GZRS      (Schutz & Preis steigen)
RA- = Read Access auf Sekundärregion
```

## Prüfungssignale
- "Daten müssen Regionsausfall überstehen" → GRS/GZRS
- "Sekundärregion auch lesend nutzen" → RA-
- "Stunden Wartezeit beim Abruf ok, minimale Kosten" → Archive

**Merke:** Tiers: Hot→Cool(30)→Cold(90)→Archive(180, offline); Redundanz: LRS→ZRS→GRS→GZRS, RA- = lesbar$C$,
   '["Azure","AZ-900","Storage","Redundanz","LRS","GRS","Tiers"]', 'Storage'),

  (v_azure, v_uid, 'Datenmigration: AzCopy, Data Box & Co.',
$C$Azure bietet je nach Datenmenge und Szenario verschiedene **Werkzeuge zur Datenverschiebung**:

## Die Werkzeuge
| Werkzeug | Was es ist | Wann |
|----------|-----------|------|
| **AzCopy** | Kommandozeilen-Tool zum Kopieren von Blobs/Files (auch zwischen Cloud-Anbietern) | Skripte, Automatisierung |
| **Azure Storage Explorer** | Grafische Desktop-App (nutzt intern AzCopy) | Manuell, visuell arbeiten |
| **Azure File Sync** | Hält On-Prem-Windows-Fileserver mit Azure Files **synchron**; Cloud Tiering (kalte Dateien nur in der Cloud) | Fileserver behalten + Cloud-Backup/Zentrale |
| **Azure Migrate** | Zentraler **Migrations-Hub**: On-Prem-Umgebung erkunden (Discovery), bewerten (Assessment), migrieren (Server, DBs, Web-Apps) | Geplante Migration ganzer Workloads |
| **Azure Data Box** | **Physisches Gerät** (~80 TB), das Microsoft zuschickt; Daten lokal draufkopieren, zurückschicken | Riesige Datenmengen / schwaches Netzwerk |

## Entscheidungshilfe
```
Wenige GB, regelmäßig, skriptbar  → AzCopy
Gelegentlich, per Hand            → Storage Explorer
Fileserver dauerhaft koppeln      → File Sync
Ganze Server/DBs in die Cloud     → Azure Migrate
Viele TB, Upload würde Wochen dauern → Data Box (offline!)
```

## Prüfungssignale
- "100 TB, Standort mit langsamer Leitung" → **Data Box**
- "Bestandsaufnahme vor der Migration" → **Azure Migrate**
- "Lokaler Fileserver + Cloud-Kopie" → **File Sync**

**Merke:** AzCopy = CLI; Storage Explorer = GUI; File Sync = dauerhaft synchron; Migrate = Migrations-Hub; Data Box = Offline-Transport$C$,
   '["Azure","AZ-900","AzCopy","Data Box","Azure Migrate","File Sync"]', 'Storage'),

  (v_azure, v_uid, 'VPN Gateway vs. ExpressRoute & Private Endpoint',
$C$Drei Wege, On-Premises und Azure **privat** zu verbinden — Verwechslungsgefahr in der Prüfung!

## VPN Gateway
**Verschlüsselter Tunnel über das öffentliche Internet.**
- **Site-to-Site (S2S):** Firmennetz ↔ Azure VNet (Router zu Gateway)
- **Point-to-Site (P2S):** einzelnes Gerät (Homeoffice-Laptop) ↔ VNet
- Günstiger, schnell eingerichtet; Bandbreite/Latenz vom Internet abhängig

## ExpressRoute
**Private, dedizierte Leitung** über einen Konnektivitätsanbieter — **läuft NICHT über das öffentliche Internet**.
- Höhere Bandbreite (bis 100 Gbit/s), stabile Latenz, höhere Zuverlässigkeit (SLA)
- Teurer, längere Bereitstellung
- Kombination üblich: ExpressRoute + VPN als Failover

## Private Endpoint (Privater Endpunkt)
Gibt einem **PaaS-Dienst** (Storage Account, Azure SQL, Key Vault ...) eine **private IP-Adresse in DEINEM VNet** — Zugriff läuft privat, der öffentliche Endpunkt kann deaktiviert werden.

## VNet-Grundlagen dazu
- **VNet Peering:** verbindet zwei VNets — Traffic bleibt auf dem **privaten Microsoft-Backbone** (nie öffentliches Internet), auch regionsübergreifend (Global Peering)

## Entscheidungsmatrix
| Anforderung | Lösung |
|-------------|--------|
| Schnell & günstig verbinden | VPN (S2S) |
| Homeoffice-Einzelgeräte | VPN (P2S) |
| Maximale Bandbreite/Zuverlässigkeit, kein Internet | **ExpressRoute** |
| PaaS-Dienst nur privat erreichbar | **Private Endpoint** |
| VNet ↔ VNet | Peering |

**Merke:** VPN = verschlüsselt ÜBERS Internet; ExpressRoute = private Leitung OHNE Internet; Private Endpoint = private IP für PaaS im VNet$C$,
   '["Azure","AZ-900","VPN","ExpressRoute","Private Endpoint","Netzwerk"]', 'Netzwerk'),

  (v_azure, v_uid, 'Zero Trust & Defense in Depth',
$C$Zwei Sicherheitsmodelle, die in AZ-900 sicher drankommen:

## Zero Trust
> **"Niemals vertrauen, immer überprüfen"** — auch Zugriffe aus dem eigenen Firmennetz sind nicht automatisch vertrauenswürdig.

Die 3 Prinzipien:
1. **Explizit verifizieren** — jede Anfrage anhand aller Signale prüfen (Identität, Gerät, Standort, Risiko)
2. **Least Privilege** — minimal nötige Rechte, just-in-time und zeitlich begrenzt (JIT/JEA)
3. **Assume Breach** — davon ausgehen, dass Angreifer schon drin sind: segmentieren, verschlüsseln, überwachen

Altes Modell: "Burg mit Graben" (innen = sicher). Zero Trust: **Identität ist der neue Perimeter.**

## Defense in Depth — die 7 Schichten
Mehrere Verteidigungslinien; fällt eine, greift die nächste:
```
1. Physische Sicherheit   (Rechenzentrum-Zugang)
2. Identität & Zugriff    (Entra ID, MFA, RBAC)
3. Perimeter              (DDoS Protection, Firewall)
4. Netzwerk               (NSG, Segmentierung, kein Default-Zugriff)
5. Compute                (VM-Härtung, Patches, Endpoint Protection)
6. Anwendung              (sichere Entwicklung, keine Secrets im Code)
7. Daten  ← das Innerste  (Verschlüsselung, Klassifizierung)
```

## Microsoft Defender for Cloud
Zentrales Tool für **Cloud Security Posture Management**:
- **Secure Score** — Prozentwert der Sicherheitslage + priorisierte Empfehlungen
- Bedrohungserkennung für Azure-, Hybrid- und Multi-Cloud-Ressourcen

**Merke:** Zero Trust: verifizieren, Least Privilege, assume breach; Defense in Depth: 7 Schichten, Daten im Kern; Secure Score = Defender for Cloud$C$,
   '["Azure","AZ-900","Zero Trust","Defense in Depth","Defender","Sicherheit"]', 'Sicherheit'),

  (v_azure, v_uid, 'NSG, Azure Firewall, DDoS & Bastion',
$C$Vier Netzwerk-Schutzdienste und ihre Abgrenzung (beliebte Prüfungsfrage):

## Network Security Group (NSG)
**Regelwerk nahe an der Ressource** — an Subnetz oder Netzwerkkarte (NIC):
- Regeln: Quelle, Ziel, Port, Protokoll → **Allow/Deny**, mit **Priorität** (kleinere Zahl gewinnt)
- Kostenlos, dezentral, Basis-Segmentierung
```
Beispiel: Erlaube TCP 443 aus Internet → Web-Subnetz; verweigere alles andere
```

## Azure Firewall
**Zentraler, verwalteter Firewall-Dienst** für ganze VNets (typisch im Hub-VNet):
- Zustandsbehaftet, hochverfügbar, skaliert automatisch
- FQDN-Filterung (z.B. nur \*.windowsupdate.com erlauben), Threat Intelligence
- Kostenpflichtig — Zentrale Kontrolle vs. NSG = lokale Regeln (beides kombinieren!)

## DDoS Protection
Schutz vor **Distributed-Denial-of-Service**-Angriffen (Überflutung):
- **Basic/Infrastructure:** automatisch und kostenlos für ganz Azure
- **Standard/Network Protection:** kostenpflichtig, abgestimmt auf DEINE VNets, Metriken + Kostenschutz

## Azure Bastion
**RDP/SSH direkt im Browser über das Portal** — die VM braucht **keine öffentliche IP** und Port 3389/22 bleibt zu → drastisch kleinere Angriffsfläche.

## Wann was?
| Bedarf | Dienst |
|--------|--------|
| Portregeln je Subnetz/NIC | NSG |
| Zentrale Firewall + FQDN-Regeln | Azure Firewall |
| Schutz vor Überflutungsangriffen | DDoS Protection |
| Sicher auf VM zugreifen ohne öffentliche IP | Bastion |

**Merke:** NSG = dezentrale Regeln (gratis); Firewall = zentral & intelligent; Bastion = RDP/SSH ohne öffentliche IP$C$,
   '["Azure","AZ-900","NSG","Firewall","Bastion","DDoS","Netzwerk"]', 'Sicherheit'),

  (v_azure, v_uid, 'MFA, SSO, kennwortlos & Conditional Access',
$C$Identitäts-Sicherheit in **Microsoft Entra ID** (früher Azure AD — neuer Name ist prüfungsrelevant!).

## MFA — Multi-Faktor-Authentifizierung
Mindestens **zwei verschiedene** Faktor-Kategorien:
| Faktor | Beispiel |
|--------|----------|
| **Wissen** | Passwort, PIN |
| **Besitz** | Smartphone (Authenticator-App), Hardware-Token |
| **Sein** (Biometrie) | Fingerabdruck, Gesicht |

## Kennwortlose Anmeldung (passwordless)
Sicherer UND bequemer — das Passwort entfällt komplett:
- **Windows Hello for Business** (Biometrie/PIN, an Gerät gebunden)
- **Microsoft Authenticator App** (Bestätigung + Biometrie am Handy)
- **FIDO2-Sicherheitsschlüssel** (USB/NFC-Stick)

## SSO — Single Sign-On
**Einmal anmelden, viele Anwendungen nutzen.** Weniger Passwörter = weniger Angriffsfläche + weniger Helpdesk-Tickets. Verlässt sich auf einen zentralen Identitätsanbieter (Entra ID).

## Conditional Access (bedingter Zugriff)
**"Wenn-dann"-Richtlinien** auf Basis von **Signalen**:
```
Signale:  Benutzer/Gruppe | Standort (IP) | Gerät (verwaltet?) | Anwendung | Risiko (erkannt)
   ↓
Entscheidung:  Zulassen | MFA verlangen | Blockieren
```
Beispiele:
- Anmeldung aus unbekanntem Land → **zusätzlich MFA**
- Nicht verwalteter PC → Zugriff auf Admin-Portal **blockieren**

**Merke:** MFA = Wissen + Besitz + Sein (min. 2); kennwortlos = Hello/Authenticator/FIDO2; Conditional Access = Signale → zulassen/MFA/blockieren$C$,
   '["Azure","AZ-900","MFA","SSO","Conditional Access","Entra ID"]', 'Sicherheit'),

  (v_azure, v_uid, 'Ressourcensperren, Tags & Purview',
$C$## Ressourcensperren (Resource Locks)
Schützen vor **versehentlichem Löschen oder Ändern** — wirken **auch für Besitzer (Owner)**!

| Sperrtyp | Wirkung |
|----------|---------|
| **CanNotDelete** (Löschen) | Lesen & Ändern ja, **Löschen nein** |
| **ReadOnly** (Schreibgeschützt) | Nur Lesen — **kein Ändern, kein Löschen** |

- Anwendbar auf: Abonnement, Ressourcengruppe, einzelne Ressource (vererbt nach unten)
- Zum Löschen muss die Sperre erst explizit **entfernt** werden (bewusster Zwei-Schritt)

## Das Governance-Trio (Abgrenzung — Prüfungsklassiker!)
| Werkzeug | Steuert |
|----------|---------|
| **RBAC** | **WER** darf **WAS** tun (Rollen auf Scopes) |
| **Azure Policy** | **WAS erlaubt ist** — Regeln erzwingen/auditieren (z.B. "nur Region Westeuropa", "Tags Pflicht") |
| **Locks** | Schutz vor versehentlichem **Löschen/Ändern** — unabhängig von Rechten |

## Tags
**Name-Wert-Paare** als Metadaten an Ressourcen/RGs/Abonnements:
```
Umgebung = Produktion | Kostenstelle = IT-4711 | Owner = steven
```
- Hauptzweck: **Kostenzuordnung** und Organisation (Filter in Cost Management)
- Werden **NICHT automatisch vererbt** (RG-Tag gilt nicht automatisch für Ressourcen darin) — per Policy erzwingbar

## Microsoft Purview
**Datengovernance**-Dienst: Datenbestände On-Prem/Azure/Multi-Cloud **katalogisieren**, **klassifizieren** (sensible Daten finden) und **Lineage** (Datenfluss) nachvollziehen.

**Merke:** CanNotDelete vs. ReadOnly — wirken auch für Owner; Policy = Regeln, RBAC = Zugriff, Lock = Löschschutz; Tags vererben sich nicht$C$,
   '["Azure","AZ-900","Locks","Tags","Purview","Governance"]', 'Verwaltung'),

  (v_azure, v_uid, 'Azure Advisor, Service Health & Azure Monitor',
$C$Drei Überwachungsdienste mit klarer Aufgabenteilung (Abgrenzungsfragen in AZ-900!):

## Azure Advisor
**Kostenloser Berater**: analysiert deine Ressourcen und gibt **personalisierte Empfehlungen** in **5 Kategorien**:
1. **Kosten** (ungenutzte Ressourcen, Right-Sizing)
2. **Sicherheit** (aus Defender for Cloud)
3. **Zuverlässigkeit** (Redundanz, Backups)
4. **Leistung** (Konfiguration, SKUs)
5. **Operative Exzellenz** (Best Practices, Limits)

## Azure Service Health
Informiert über **Azure-seitige Probleme, die DICH betreffen**:
- **Service Issues** — aktuelle Azure-Störungen mit Auswirkung auf deine Ressourcen
- **Planned Maintenance** — geplante Wartungen
- **Health Advisories** — z.B. anstehende Dienst-Abkündigungen
- Alerts konfigurierbar. (Abgrenzung: **Azure Status** = globale Übersicht für alle, Service Health = personalisiert)

## Azure Monitor
**Telemetrie DEINER Ressourcen**: sammelt **Metriken** (Zahlenwerte, Echtzeit) und **Logs** (Ereignisse):
- **Log Analytics** — Logs mit **KQL** (Kusto Query Language) abfragen
- **Alerts** — Schwellwerte/Abfragen → Benachrichtigung oder Aktion (Action Groups)
- **Application Insights** — APM: Anwendungs-Performance, Requests, Fehler, Abhängigkeiten

## Wer beantwortet welche Frage?
| Frage | Dienst |
|-------|--------|
| "Wie kann ich sparen/besser konfigurieren?" | **Advisor** |
| "Ist AZURE gerade gestört / Wartung geplant?" | **Service Health** |
| "Wie geht es MEINER App/VM (CPU, Fehler)?" | **Monitor** |

**Merke:** Advisor = Empfehlungen (5 Kategorien); Service Health = Azure-Störungen für dich; Monitor = deine Metriken & Logs (KQL)$C$,
   '["Azure","AZ-900","Advisor","Service Health","Monitor","KQL"]', 'Betrieb'),

  (v_azure, v_uid, 'Compute: VMSS, Availability Sets, ACI vs. AKS & AVD',
$C$Die Azure-Compute-Familie im Überblick — wichtig ist die **Abgrenzung**:

## VM Scale Sets (VMSS)
Gruppe **identischer VMs** mit **Autoskalierung** (nach Last oder Zeitplan) und integriertem Load Balancing. Für skalierbare Workloads auf VM-Basis.

## Availability Sets (Verfügbarkeitsgruppen)
Verteilen VMs **innerhalb EINES Rechenzentrums**:
- **Fehlerdomänen (Fault Domains):** getrennte Racks (Strom/Netzwerk) — Hardware-Ausfall trifft nicht alle
- **Updatedomänen (Update Domains):** VMs werden nacheinander gewartet, nie alle gleichzeitig

Schützt vor Rack-Ausfall, **nicht** vor RZ-Ausfall → dafür **Verfügbarkeitszonen** nutzen!

## Container: ACI vs. AKS
| | **ACI** (Container Instances) | **AKS** (Kubernetes Service) |
|--|------------------------------|------------------------------|
| Was | Einzelne Container, **serverless** | Vollständige **Orchestrierung** |
| Stärke | Schnellster Start, sekundengenau bezahlt, null Verwaltung | Skalierung, Self-Healing, komplexe Apps |
| Für | Einfache Jobs, Burst, Tests | Microservices in Produktion |

Bei AKS gilt: Microsoft betreibt die **Control Plane (kostenlos)** — du zahlst und verwaltest nur die **Worker Nodes**. Das meint "verwaltetes Kubernetes".

## Azure Virtual Desktop (AVD)
**Windows-Desktops und -Apps aus der Cloud streamen** — auf beliebige Geräte, Multi-Session Windows möglich.

## Entscheidungshilfe
```
Voller OS-Zugriff nötig?        → VM / VMSS
Nur Web-App deployen?           → App Service
Einzelner Container, simpel?    → ACI
Viele Container, Orchestrierung?→ AKS
Event-getriebener Code?         → Functions
Desktop aus der Cloud?          → AVD
```

**Merke:** VMSS = Autoskalierung identischer VMs; Availability Set = Fault/Update Domains im RZ; ACI = 1 Container serverless, AKS = Orchestrierung$C$,
   '["Azure","AZ-900","VMSS","Availability Set","ACI","AKS","AVD"]', 'Compute'),

  (v_azure, v_uid, 'Verwaltungstools: Portal, Cloud Shell, CLI & ARM',
$C$## Die Interaktionswege
| Tool | Beschreibung |
|------|-------------|
| **Azure Portal** | Grafische Web-Oberfläche — gut für Lernen, Einzelaktionen, Visualisierung |
| **Azure CLI** | Kommandozeile, Bash-freundlich: `az group create --name rg1 --location westeurope` |
| **Azure PowerShell** | Cmdlets im Verb-Nomen-Stil: `New-AzResourceGroup -Name rg1 -Location westeurope` |
| **Cloud Shell** | **Browser-Shell im Portal** — CLI UND PowerShell vorinstalliert, authentifiziert, kein lokales Setup |
| **Azure Mobile App** | Verwalten & überwachen unterwegs |

## Azure Resource Manager (ARM)
**Jede Anfrage — egal ob Portal, CLI, PowerShell, SDK oder API — läuft über ARM**, die zentrale Verwaltungsschicht:
```
Portal / CLI / PowerShell / SDK
            ↓
   Azure Resource Manager  ← Authentifizierung, RBAC, Policies, Locks
            ↓
        Ressourcen
```
Deshalb wirken RBAC, Policy und Locks überall konsistent.

## ARM-Templates vs. Bicep (IaC in Azure)
| | ARM-Template | Bicep |
|--|--------------|-------|
| Sprache | **JSON** (ausführlich) | Eigene, **lesbarere** Sprache |
| Beziehung | Das native Format | Wird zu ARM-JSON **transpiliert** |
| Eigenschaften | Beide: **deklarativ** (Zielzustand), **idempotent**, wiederholbar, versionierbar |

## Prüfungssignale
- "Shell ohne lokale Installation" → **Cloud Shell**
- "Alle Anfragen laufen über ...?" → **ARM**
- "Lesbare Alternative zu ARM-JSON" → **Bicep**

**Merke:** Cloud Shell = Browser-Terminal mit allem drin; ALLES läuft über ARM; Bicep → transpiliert zu ARM-JSON, beide deklarativ & idempotent$C$,
   '["Azure","AZ-900","Portal","Cloud Shell","CLI","ARM","Bicep"]', 'Verwaltung');

  RAISE NOTICE 'seed_steven_v3: 42 Karten eingefuegt (DevOps 22, Kubernetes 2, Docker 2, Azure 16)';
END;
$SEED3$ LANGUAGE plpgsql;
