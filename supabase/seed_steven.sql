-- ================================================================
-- Seed: Informatik + Scrum Lernkarten für steven.illg.it@outlook.com
-- Im Supabase SQL-Editor ausführen — NACH migration_001
-- ================================================================

DO $$
DECLARE
  v_uid          uuid;
  v_informatik   integer;
  v_itmathe      integer;
  v_azure        integer;
  v_kubernetes   integer;
  v_docker       integer;
  v_scrum        integer;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = 'steven.illg.it@outlook.com';
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Nutzer nicht gefunden'; END IF;

  -- ── Bereiche ──────────────────────────────────────────────────
  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('Informatik', '💻', '#06b6d4', NULL, v_uid, 10) RETURNING id INTO v_informatik;

  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('Scrum', '🏃', '#22c55e', NULL, v_uid, 11) RETURNING id INTO v_scrum;

  -- ── Sub-Boxen Informatik ──────────────────────────────────────
  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('IT Mathe', '📐', '#8b5cf6', v_informatik, v_uid, 1) RETURNING id INTO v_itmathe;
  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('Azure', '☁️', '#0078d4', v_informatik, v_uid, 2) RETURNING id INTO v_azure;
  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('Kubernetes', '⎈', '#326ce5', v_informatik, v_uid, 3) RETURNING id INTO v_kubernetes;
  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('Docker', '🐳', '#0db7ed', v_informatik, v_uid, 4) RETURNING id INTO v_docker;

  -- ════════════════════════════════════════════════════════════════
  -- IT MATHE
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_itmathe, v_uid, 'Big-O-Notation',
$$**Big-O** beschreibt das **Wachstumsverhalten** eines Algorithmus in Abhängigkeit von der Eingabegröße n — unabhängig von Hardware und Konstanten.

| Notation | Name | Beispiel |
|---|---|---|
| O(1) | Konstant | Array-Index-Zugriff |
| O(log n) | Logarithmisch | Binäre Suche |
| O(n) | Linear | Lineare Suche |
| O(n log n) | Quasilinear | Merge Sort |
| O(n²) | Quadratisch | Bubble Sort |
| O(2ⁿ) | Exponentiell | Alle Teilmengen |

**Regeln:**
- Konstanten werden ignoriert: O(3n) → O(n)
- Nur der dominante Term zählt: O(n² + n) → O(n²)
- Best / Average / Worst Case sind unterschiedlich — O beschreibt meist den Worst Case$$,
   '["Algorithmen","Komplexität","Laufzeit"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Binärzahlen',
$$Das **Binärsystem** ist ein Stellenwertsystem zur Basis 2 — Computer arbeiten intern ausschließlich damit.

**Umrechnung Dezimal → Binär:** Wiederholt durch 2 dividieren, Reste von unten lesen.
`13 → 1101₂` (13 = 8+4+1)

**Umrechnung Binär → Dezimal:** Jede Stelle mit der entsprechenden 2er-Potenz multiplizieren.
`1101₂ = 1×8 + 1×4 + 0×2 + 1×1 = 13`

**Wichtige Begriffe:**
- **Bit** = eine Binärstelle (0 oder 1)
- **Byte** = 8 Bit → Werte 0–255
- **MSB** = Most Significant Bit (ganz links)
- **LSB** = Least Significant Bit (ganz rechts)

**Addition:** Wie im Dezimalsystem, aber Übertrag bei 2:
`1 + 1 = 10₂` (0, Übertrag 1)$$,
   '["Binär","Zahlensysteme","Grundlagen"]', 'Zahlensysteme'),

  (v_itmathe, v_uid, 'Hexadezimalzahlen',
$$Das **Hexadezimalsystem** (Basis 16) wird in der IT für kompakte Darstellung von Binärwerten verwendet.

**Ziffern:** 0–9, dann A=10, B=11, C=12, D=13, E=14, F=15

**1 Hex-Stelle = 4 Bit (Nibble)**
→ `FF` = `1111 1111` = 255₁₀

**Umrechnung Hex → Dezimal:**
`2A` = 2×16 + 10 = 42

**Verwendung:**
- Farben in CSS: `#FF5733`
- Speicheradressen: `0x7fff5fbff8f0`
- Bytecodes, Hashwerte, MAC-Adressen
- IPv6-Adressen

**Präfixe:** `0x` (C/Java), `#` (CSS/Farben), `h` (Assembler)$$,
   '["Hexadezimal","Zahlensysteme","Darstellung"]', 'Zahlensysteme'),

  (v_itmathe, v_uid, 'Bitoperationen',
$$**Bitoperationen** arbeiten direkt auf den einzelnen Bits einer Ganzzahl.

| Op | Zeichen | Funktion | Beispiel |
|---|---|---|---|
| AND | `&` | Beide Bits 1 → 1 | `6 & 3 = 2` |
| OR | `\|` | Mind. ein Bit 1 → 1 | `6 \| 3 = 7` |
| XOR | `^` | Genau ein Bit 1 → 1 | `6 ^ 3 = 5` |
| NOT | `~` | Alle Bits umkehren | `~6 = -7` |
| Left Shift | `<<` | Bits nach links schieben | `1 << 3 = 8` |
| Right Shift | `>>` | Bits nach rechts schieben | `8 >> 2 = 2` |

**Typische Anwendungen:**
- Flags/Berechtigungen: `permissions & READ_FLAG`
- Schnelles Multiplizieren/Dividieren durch 2er-Potenzen: `n << 1` = n×2
- Prüfen ob Zahl gerade: `n & 1 == 0`
- Farb-Channels extrahieren: `color >> 16 & 0xFF`$$,
   '["Bitoperationen","Binär","Low-Level"]', 'Grundlagen'),

  (v_itmathe, v_uid, 'Aussagenlogik',
$$Die **Aussagenlogik** (Boolesche Logik) beschäftigt sich mit Aussagen, die wahr (W) oder falsch (F) sind.

**Grundoperatoren:**

| Op | Symbol | Name | W wenn… |
|---|---|---|---|
| NOT | ¬, `!` | Negation | Aussage falsch |
| AND | ∧, `&&` | Konjunktion | Beide wahr |
| OR | ∨, `\|\|` | Disjunktion | Mind. eine wahr |
| XOR | ⊕ | Exklusives Oder | Genau eine wahr |
| → | ⇒ | Implikation | Nicht (A wahr, B falsch) |
| ↔ | ⟺ | Äquivalenz | Beide gleich |

**Tautologie:** Immer wahr, z. B. `A ∨ ¬A`
**Kontradiktion:** Immer falsch, z. B. `A ∧ ¬A`
**De Morgan:** `¬(A ∧ B) = ¬A ∨ ¬B`$$,
   '["Logik","Boolesch","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Mengen und Mengenoperationen',
$$Eine **Menge** ist eine Sammlung eindeutiger Elemente: `M = {1, 2, 3}`

**Operationen:**
- **Vereinigung** A ∪ B: alle Elemente aus A oder B
- **Schnittmenge** A ∩ B: nur Elemente in beiden
- **Differenz** A \ B: Elemente in A, aber nicht B
- **Komplement** Ā: alle Elemente nicht in A
- **Potenzmenge** P(A): alle Teilmengen von A (2ⁿ Elemente)
- **Kartesisches Produkt** A × B: alle geordneten Paare (a,b)

**Relationen:**
- `∈` = Element von: `3 ∈ {1,2,3}`
- `⊆` = Teilmenge: `{1,2} ⊆ {1,2,3}`
- `⊂` = Echte Teilmenge: `{1,2} ⊂ {1,2,3}`
- `|A|` = Kardinalität (Anzahl Elemente)

**In der Informatik:** Datenbankoperationen (JOIN, UNION), Filterlogik, Graphentheorie$$,
   '["Mengen","Mathematik","Diskrete Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Graphen und Graphentheorie',
$$Ein **Graph** G = (V, E) besteht aus **Knoten** (Vertices V) und **Kanten** (Edges E).

**Typen:**
- **Ungerichtet:** Kanten ohne Richtung (A–B)
- **Gerichtet (Digraph):** Kanten mit Richtung (A→B)
- **Gewichtet:** Kanten haben Kosten/Gewichte

**Wichtige Begriffe:**
- **Grad** eines Knotens: Anzahl seiner Kanten
- **Pfad:** Folge von Knoten über Kanten
- **Zyklus:** Pfad der zum Startknoten zurückführt
- **Baum:** Zusammenhängender, zyklusfreier Graph
- **DAG** = Directed Acyclic Graph (z. B. Dependency-Graphen)

**Darstellung:**
- Adjazenzmatrix: 2D-Array, platzsparend bei dichten Graphen
- Adjazenzliste: Liste pro Knoten, gut für dünn besetzte Graphen

**Algorithmen:** BFS, DFS, Dijkstra (kürzester Weg), Kruskal/Prim (minimaler Spannbaum)$$,
   '["Graphen","Algorithmen","Datenstrukturen"]', 'Datenstrukturen'),

  (v_itmathe, v_uid, 'Rekursion',
$$**Rekursion** = eine Funktion ruft sich selbst auf. Jede Rekursion braucht:
1. **Basisfall** (Abbruchbedingung)
2. **Rekursiver Schritt** (Problem verkleinern)

**Klassisches Beispiel — Fakultät:**
```python
def fakultaet(n):
    if n <= 1: return 1          # Basisfall
    return n * fakultaet(n - 1)  # Rekursiver Schritt
```

**Call Stack:**
- Jeder Aufruf legt einen Frame auf den Stack
- Zu tiefe Rekursion → StackOverflow
- Tail-Rekursion kann vom Compiler optimiert werden

**Typische Anwendungen:**
- Traversierung von Bäumen und Graphen
- Divide & Conquer (Merge Sort, Quick Sort)
- Backtracking (Sudoku, N-Queens)
- Parsing verschachtelter Strukturen (JSON, XML)

**Memoization:** Ergebnisse cachen → vermeidet redundante Berechnungen (Dynamic Programming)$$,
   '["Rekursion","Algorithmen","Programmierung"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Vollständige Induktion',
$$Die **vollständige Induktion** beweist, dass eine Aussage für alle natürlichen Zahlen gilt.

**Schema:**
1. **Induktionsanfang (IA):** Aussage für n=0 (oder n=1) zeigen
2. **Induktionsvoraussetzung (IV):** Aussage gilt für n=k (angenommen)
3. **Induktionsschritt (IS):** Zeige, dass Aussage dann auch für n=k+1 gilt

**Beispiel:** Summe 1+2+…+n = n(n+1)/2

*IA:* n=1: 1 = 1·2/2 = 1 ✓
*IV:* Gilt für k: 1+…+k = k(k+1)/2
*IS:* 1+…+k+(k+1) = k(k+1)/2 + (k+1) = (k+1)(k+2)/2 ✓

**In der Informatik:** Korrektheitsbeweise für Algorithmen, Datenbanktheoreme, Laufzeitanalysen$$,
   '["Induktion","Beweise","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Modulo-Arithmetik',
$$Der **Modulo-Operator** (`%`) gibt den Rest einer ganzzahligen Division zurück.

`17 % 5 = 2` (da 17 = 3×5 + 2)

**Anwendungen:**
- **Gerade/ungerade:** `n % 2 == 0`
- **Zyklische Indizes:** `(i+1) % n` → Ringpuffer, Rundlauf
- **Hash-Funktionen:** `hash(key) % tableSize`
- **Kryptographie:** RSA, Diffie-Hellman basieren auf Modulo
- **Uhren/Kalender:** `(stunde + 3) % 24`

**Kongruenz:** `a ≡ b (mod n)` bedeutet, n teilt (a-b)
Beispiel: `17 ≡ 2 (mod 5)`

**Wichtige Eigenschaft:** `(a + b) % n = ((a % n) + (b % n)) % n`

**Negative Zahlen:** Achtung — Verhalten je nach Sprache unterschiedlich!
Python: `-7 % 3 = 2` | Java/C: `-7 % 3 = -1`$$,
   '["Modulo","Arithmetik","Kryptographie"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Hash-Funktionen',
$$Eine **Hash-Funktion** bildet Daten beliebiger Länge auf einen Wert fixer Länge ab (Hash/Digest).

**Eigenschaften einer kryptografischen Hash-Funktion:**
- **Deterministisch:** Gleiche Eingabe → immer gleicher Hash
- **Schnell berechenbar**
- **Einwegfunktion:** Hash → Original nicht möglich
- **Kollisionsresistenz:** Zwei Eingaben sollen nicht den gleichen Hash haben
- **Lawineneffekt:** Kleine Änderung → komplett anderer Hash

**Bekannte Algorithmen:**
- MD5 → 128 Bit (unsicher, veraltet)
- SHA-1 → 160 Bit (veraltet)
- SHA-256 → 256 Bit (sicher, Standard)
- bcrypt / Argon2 → für Passwörter (absichtlich langsam)

**Anwendungen:** Passwort-Speicherung, Dateiintegrität, Signaturen, Blockchain, Hash-Tables$$,
   '["Hash","Kryptographie","Sicherheit"]', 'Kryptographie'),

  (v_itmathe, v_uid, 'Kombinatorik',
$$Die **Kombinatorik** zählt Anordnungen und Auswahlen von Elementen.

**Grundformeln:**

**Permutationen** (Reihenfolge wichtig, alle Elemente):
$$n! = n \times (n-1) \times \ldots \times 1$$

**k-Permutationen** (k aus n, ohne Wiederholung):
$$P(n,k) = \frac{n!}{(n-k)!}$$

**Kombinationen** (k aus n, Reihenfolge egal, ohne Wiederholung):
$$\binom{n}{k} = \frac{n!}{k! \cdot (n-k)!}$$

**Mit Wiederholung** (k aus n, Reihenholung erlaubt):
$$\binom{n+k-1}{k}$$

**Beispiele:**
- Passwort (6 Stellen, 26 Buchstaben): 26⁶ ≈ 309 Mio
- Lotto 6 aus 49: C(49,6) = 13.983.816
- Anagramme von "ANNA": 4!/(2!·2!) = 6$$,
   '["Kombinatorik","Wahrscheinlichkeit","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Wahrscheinlichkeitsrechnung',
$$**Wahrscheinlichkeit** P(A) gibt an, wie wahrscheinlich Ereignis A eintritt.
`0 ≤ P(A) ≤ 1`

**Grundregeln:**
- **Komplementregel:** P(Ā) = 1 - P(A)
- **Additionsregel:** P(A ∪ B) = P(A) + P(B) - P(A ∩ B)
- **Multiplikationsregel (unabhängig):** P(A ∩ B) = P(A) · P(B)

**Bedingte Wahrscheinlichkeit:**
$$P(A|B) = \frac{P(A \cap B)}{P(B)}$$

**Bayes-Theorem:**
$$P(A|B) = \frac{P(B|A) \cdot P(A)}{P(B)}$$

**In der Informatik:**
- Spam-Filter (Naiver Bayes-Klassifikator)
- A/B-Tests (statistische Signifikanz)
- Maschinelles Lernen (probabilistische Modelle)
- Zufallsalgorithmen (Randomized Quicksort, Monte Carlo)$$,
   '["Wahrscheinlichkeit","Statistik","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'P vs. NP Problem',
$$Eines der größten ungelösten Probleme der Informatik.

**P** = Klasse der Probleme, die **polynomial lösbar** sind (O(nᵏ))
→ Effizient lösbar, z. B. Sortieren, kürzeste Wege

**NP** = Klasse der Probleme, deren **Lösung polynomial verifizierbar** ist
→ Nicht notwendig effizient lösbar, z. B. Travelling Salesman, Sudoku

**Frage: Gilt P = NP?**
- Wenn ja: Alle NP-Probleme wären effizient lösbar → Kryptographie würde zusammenbrechen
- Fast alle Experten glauben: P ≠ NP

**NP-vollständig:** Schwerste Probleme in NP — jedes NP-Problem lässt sich darauf reduzieren
Beispiele: SAT, Clique-Problem, Rucksackproblem

**Praxisrelevanz:**
- Kryptographie basiert auf der Annahme P≠NP
- NP-schwere Probleme werden mit Heuristiken / Approximation gelöst$$,
   '["Komplexität","Theorie","Informatik"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Endliche Automaten (DFA)',
$$Ein **deterministischer endlicher Automat (DFA)** erkennt reguläre Sprachen.

**Komponenten** M = (Q, Σ, δ, q₀, F):
- **Q** = endliche Menge von Zuständen
- **Σ** = Eingabealphabet
- **δ** = Übergangsfunktion δ: Q × Σ → Q
- **q₀** = Startzustand
- **F** = Menge akzeptierender Endzustände

**Wie es funktioniert:**
Automat liest Zeichen für Zeichen und wechselt den Zustand.
Eingabe akzeptiert wenn Endzustand nach letztem Zeichen erreicht.

**NFA vs. DFA:**
- NFA: Mehrere mögliche Übergänge pro Zeichen (nicht deterministisch)
- Jeder NFA lässt sich in äquivalenten DFA umwandeln

**Anwendungen:**
- Lexer/Parser (Compilerbau)
- Regex-Engines
- Protokollmodellierung
- Textsuchalgorithmen$$,
   '["Automaten","Theorie","Formale Sprachen"]', 'Theoretische Informatik');

  -- ════════════════════════════════════════════════════════════════
  -- AZURE
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_azure, v_uid, 'Microsoft Entra ID (Azure AD)',
$$**Microsoft Entra ID** (früher Azure Active Directory) ist der cloud-basierte Identity & Access Management Service von Microsoft.

**Kernfunktionen:**
- **Authentifizierung:** SSO (Single Sign-On), MFA, OAuth 2.0, OIDC
- **Autorisierung:** RBAC, bedingter Zugriff (Conditional Access)
- **Geräteverwaltung:** Azure AD Join, Hybrid Join
- **B2B/B2C:** Gastzugriff, externe Identitäten

**Wichtige Konzepte:**
- **Tenant:** Dedizierte Instanz für eine Organisation
- **Service Principal:** Identität für Anwendungen/Dienste
- **Managed Identity:** Automatische Identität für Azure-Ressourcen (kein Passwort nötig)
- **App Registration:** OAuth-App in Entra ID registrieren

**Protokolle:** OAuth 2.0, OIDC, SAML 2.0, WS-Federation

**Unterschied zu on-prem AD:** Entra ID ist cloud-native, kein LDAP/Kerberos, kein Gruppenrichtlinien-GPO$$,
   '["Azure","Identity","Sicherheit","EntraID"]', 'Azure Grundlagen'),

  (v_azure, v_uid, 'Azure Virtual Machines',
$$**Azure VMs** bieten IaaS (Infrastructure as a Service) — vollständige Kontrolle über OS, Software und Konfiguration.

**VM-Größen (Series):**
- **B-Serie:** Burst-fähig, für dev/test (günstig)
- **D-Serie:** Allgemein, ausgewogen CPU/RAM
- **E-Serie:** Memory-optimiert (Datenbanken, Caching)
- **F-Serie:** CPU-optimiert (Berechnungen)
- **N-Serie:** GPU (ML, Rendering)

**Kernkonzepte:**
- **VM Scale Sets (VMSS):** Auto-Scaling-Gruppe identischer VMs
- **Availability Set:** VMs auf verschiedene Fault/Update Domains verteilen
- **Availability Zone:** VM in physisch getrenntem Rechenzentrum
- **Managed Disk:** Azure-verwalteter persistenter Speicher (Standard HDD/SSD, Premium SSD)

**Wichtig:**
- VMs werden pro Stunde abgerechnet (auch gestoppte VMs zahlen Speicher!)
- **Deallocate** statt Stop → spart Compute-Kosten
- Images für schnelles Bereitstellen nutzen$$,
   '["Azure","IaaS","VM","Compute"]', 'Compute'),

  (v_azure, v_uid, 'Azure Blob Storage',
$$**Azure Blob Storage** ist Microsofts Object Storage für unstrukturierte Daten.

**Hierarchie:**
`Storage Account → Container → Blob`

**Blob-Typen:**
- **Block Blob:** Standard (Dateien, Backups, Videos) → bis 200 TB
- **Append Blob:** Optimiert für append-only (Logs)
- **Page Blob:** Zufallszugriff (VHD-Festplatten für VMs)

**Zugriffs-Tiers:**
| Tier | Kosten | Zugriff | Einsatz |
|---|---|---|---|
| Hot | Hoch | Sofort | Aktive Daten |
| Cool | Mittel | Sofort (Strafe für frühe Löschung) | Selten genutzt, 30+ Tage |
| Cold | Niedrig | Sofort | Sehr selten, 90+ Tage |
| Archive | Sehr niedrig | Stunden (Rehydrate) | Langzeit-Archiv |

**Zugriff:** SAS-Token, Storage Account Key, Azure AD (RBAC), Managed Identity

**Redundanz:** LRS → ZRS → GRS → GZRS (lokal bis geo-redundant)$$,
   '["Azure","Storage","Blob","Cloud"]', 'Storage'),

  (v_azure, v_uid, 'Azure App Service',
$$**Azure App Service** ist eine PaaS-Plattform für Web-Apps, REST-APIs und mobile Backends.

**Unterstützte Laufzeiten:** .NET, Node.js, Python, Java, PHP, Ruby, Container

**Deployment-Slots:**
- **Produktions-Slot** + bis zu 20 weitere Slots (Staging, Test)
- **Swap:** Traffic sofort zwischen Slots wechseln → zero-downtime Deploy
- Slot hat eigene URL: `https://app-staging.azurewebsites.net`

**App Service Plan = Hosting-Einheit:**
| Tier | Features |
|---|---|
| Free/Shared | Test, kein Custom Domain |
| Basic | Custom Domain, SSL |
| Standard | Auto-Scale, Staging Slots, Backups |
| Premium | VNET Integration, größere Instanzen |

**Auto-Scale:** Horizontal skalieren basierend auf CPU, Requests, Queue-Länge

**Deployment:** GitHub Actions, Azure DevOps, ZIP Deploy, Docker Container, FTP

**Konfiguration:** App Settings (Env Vars), Connection Strings, TLS/SSL, Custom Domains$$,
   '["Azure","PaaS","WebApp","Deployment"]', 'Compute'),

  (v_azure, v_uid, 'Azure Functions (Serverless)',
$$**Azure Functions** = Serverless Compute. Code ausführen ohne Server verwalten zu müssen.

**Trigger-Typen:**
- **HTTP Trigger:** REST-Endpunkt
- **Timer Trigger:** Cron-basiert (`0 */5 * * * *`)
- **Blob Trigger:** Bei neuer Datei in Storage
- **Queue Trigger:** Service Bus / Storage Queue
- **Event Hub Trigger:** Streaming-Events
- **Cosmos DB Trigger:** Änderungen in DB

**Hosting-Pläne:**
- **Consumption:** Zahlen pro Aufruf, Auto-Scale, Cold Start
- **Premium:** Vorgeheizt, VNET, keine Cold Starts
- **Dedicated:** App Service Plan, feste Kapazität

**Durable Functions:** Zustandsbehaftete Workflows
- **Orchestrator Function:** Koordiniert Aktivitäten
- **Activity Function:** Einzelner Arbeitsschritt
- **Entity Function:** Zustandsobjekte

**Limits:** 10 Min Timeout (Consumption), 230 Sek HTTP-Timeout$$,
   '["Azure","Serverless","Functions","FaaS"]', 'Compute'),

  (v_azure, v_uid, 'Azure Kubernetes Service (AKS)',
$$**AKS** = verwaltetes Kubernetes in Azure. Die Control Plane wird von Azure kostenlos verwaltet.

**Komponenten:**
- **Node Pool:** Gruppe identischer VMs (Nodes)
- **System Node Pool:** Für Kubernetes-Systemdienste
- **User Node Pool:** Für Workloads, kann skaliert werden
- **Virtual Nodes:** Burst in Azure Container Instances (ACI)

**Integration mit Azure-Diensten:**
- **Azure CNI / Kubenet:** Netzwerk-Plugin
- **ACR (Container Registry):** Docker Images bereitstellen
- **Key Vault:** Secrets direkt in Pods mounten
- **Azure Monitor / Log Analytics:** Metriken und Logs
- **Entra ID:** RBAC für Kubernetes mit AD-Gruppen
- **Azure Load Balancer:** Externer Traffic-Eingang

**Cluster-Upgrade:** Rolling Upgrade mit konfigurierbarem Surge

**Auto-Scaler:**
- **Cluster Autoscaler:** Nodes hinzufügen/entfernen
- **HPA:** Pods skalieren
- **KEDA:** Event-driven Autoscaling$$,
   '["Azure","Kubernetes","AKS","Container"]', 'Container'),

  (v_azure, v_uid, 'Azure DevOps',
$$**Azure DevOps** ist eine DevOps-Plattform mit integrierten Tools für den gesamten SDLC.

**Module:**
| Service | Funktion |
|---|---|
| Boards | Work Items, Sprints, Kanban (wie Jira) |
| Repos | Git-Repositories (private, unbegrenzt) |
| Pipelines | CI/CD (YAML-basiert, klassisch) |
| Test Plans | Manuelle und automatisierte Tests |
| Artifacts | Package-Feed (NuGet, npm, Maven, PyPI) |

**Pipeline-Konzepte:**
- **Stage:** Logische Phase (Build, Test, Deploy)
- **Job:** Läuft auf einem Agent
- **Step:** Einzelne Aufgabe (Task, Script)
- **Agent:** Build-Maschine (Microsoft-hosted oder self-hosted)
- **Environments:** Deployment-Ziele mit Genehmigungen

**YAML-Beispiel:**
```yaml
trigger: [main]
pool:
  vmImage: ubuntu-latest
steps:
  - script: npm test
  - task: AzureWebApp@1
```$$,
   '["Azure","DevOps","CI/CD","Pipeline"]', 'DevOps'),

  (v_azure, v_uid, 'Azure Key Vault',
$$**Azure Key Vault** sichert Secrets, Schlüssel und Zertifikate zentral und sicher.

**3 Arten von Inhalten:**
- **Secrets:** Passwörter, Connection Strings, API Keys
- **Keys:** Kryptografische Schlüssel (RSA, EC) — HSM-gesichert möglich
- **Certificates:** X.509-Zertifikate mit automatischer Erneuerung

**Zugriff:**
- **Managed Identity** empfohlen (kein Secret in Code/Config!)
- Service Principal + Client Secret/Certificate
- Vault Access Policies (alt) oder Azure RBAC (neu, empfohlen)

**Integration:**
- App Service: Key Vault Reference in App Settings: `@Microsoft.KeyVault(SecretUri=https://…)`
- AKS: Secret Store CSI Driver → Secrets als Volume mounten
- Azure DevOps: Key Vault Linked Variable Group

**Audit:** Alle Zugriffe werden in Activity Logs erfasst
**Soft Delete:** Gelöschte Objekte 90 Tage wiederherstellbar
**Purge Protection:** Verhindert sofortiges endgültiges Löschen$$,
   '["Azure","Sicherheit","KeyVault","Secrets"]', 'Sicherheit'),

  (v_azure, v_uid, 'RBAC in Azure',
$$**RBAC** (Role-Based Access Control) steuert Zugriff auf Azure-Ressourcen über Rollen.

**Konzepte:**
- **Security Principal:** Wer? (User, Group, Service Principal, Managed Identity)
- **Role Definition:** Was? (Berechtigungen wie read, write, delete)
- **Scope:** Wo? (Management Group → Subscription → Resource Group → Ressource)
- **Role Assignment:** Verbindet alle drei

**Integrierte Rollen (wichtigste):**
| Rolle | Darf |
|---|---|
| Owner | Alles inkl. Zugriff vergeben |
| Contributor | Alles außer Zugriff vergeben |
| Reader | Nur lesen |
| User Access Admin | Nur Zugriff verwalten |

**Prinzip:** Least Privilege — so wenig Rechte wie nötig
**Deny Assignments:** Explizit Zugriff verweigern (überschreibt RBAC-Allow)
**Custom Roles:** Eigene Rollendefinitionen über JSON$$,
   '["Azure","RBAC","Sicherheit","IAM"]', 'Sicherheit'),

  (v_azure, v_uid, 'Azure Monitor & Log Analytics',
$$**Azure Monitor** ist die zentrale Plattform für Monitoring und Observability in Azure.

**Datenquellen:**
- Azure Ressourcen (Metrics, Activity Logs)
- VMs (Metrics, Logs via Azure Monitor Agent)
- Anwendungen (Application Insights)
- Container (AKS → Container Insights)

**Zwei Datentypen:**
- **Metrics:** Numerische Zeitreihen (CPU %, Requests/s) → 93 Tage Aufbewahrung
- **Logs:** Strukturierte Ereignisse → Log Analytics Workspace

**Log Analytics / Kusto Query Language (KQL):**
```kusto
AzureActivity
| where TimeGenerated > ago(1h)
| where OperationName has "delete"
| summarize count() by Caller
```

**Alerts:**
- Metric Alert: CPU > 80% für 5 Min
- Log Alert: KQL-Abfrage → Schwellenwert
- Activity Log Alert: Ressource gelöscht

**Application Insights:** APM für Web-Apps (Request-Traces, Exceptions, Abhängigkeiten)$$,
   '["Azure","Monitoring","Logging","Observability"]', 'Operations'),

  (v_azure, v_uid, 'Azure Virtual Network (VNet)',
$$Ein **Virtual Network (VNet)** ist das private Netzwerk in Azure — isoliert und sicher.

**Kernkonzepte:**
- **Address Space:** IP-Bereich des VNet (z. B. `10.0.0.0/16`)
- **Subnet:** Teilnetz innerhalb des VNet (z. B. `10.0.1.0/24`)
- **NSG (Network Security Group):** Firewall-Regeln auf Subnetz/NIC-Ebene
- **UDR (User Defined Routes):** Custom Routing-Regeln

**Konnektivität:**
- **VNet Peering:** Zwei VNets verbinden (regional oder global)
- **VPN Gateway:** Site-to-Site oder Point-to-Site VPN
- **ExpressRoute:** Private dedizierte Leitung zu Azure (nicht über Internet)
- **Private Endpoint:** Azure PaaS-Dienst (Storage, SQL) ins VNet holen

**Service Endpoint:** VNet-Zugriff auf Azure-Dienste ohne Public IP

**Wichtige Ports:**
- RDP: 3389 (Windows VMs)
- SSH: 22 (Linux VMs)
- HTTP/HTTPS: 80/443$$,
   '["Azure","Netzwerk","VNet","Sicherheit"]', 'Netzwerk'),

  (v_azure, v_uid, 'Azure Container Registry (ACR)',
$$**Azure Container Registry (ACR)** ist eine private Docker-Registry in Azure.

**Wozu?**
- Docker Images sicher und privat hosten
- Integration mit AKS, App Service, Azure Functions
- Geo-Replikation für globale Deployments

**SKUs:**
- **Basic:** Dev/Test, eingeschränkt
- **Standard:** Produktionsworkloads
- **Premium:** Geo-Replikation, Private Link, Content Trust

**Wichtige Befehle:**
```bash
# Login
az acr login --name meinregistry

# Image pushen
docker tag myapp meinregistry.azurecr.io/myapp:v1
docker push meinregistry.azurecr.io/myapp:v1

# Image listen
az acr repository list --name meinregistry
```

**ACR Tasks:** Build-Pipeline direkt in ACR
```bash
az acr build --registry meinregistry --image myapp:v1 .
```

**Zugriff:** Managed Identity (empfohlen), Admin-Konto, Service Principal$$,
   '["Azure","Container","ACR","Docker","Registry"]', 'Container'),

  (v_azure, v_uid, 'Azure Cosmos DB',
$$**Azure Cosmos DB** ist eine globally distributed, multi-model NoSQL Datenbank.

**Kernfeatures:**
- **Globale Verteilung:** Daten in beliebig viele Regionen replizieren
- **Multi-Master:** Schreibzugriff in mehreren Regionen gleichzeitig
- **Garantierte Latenz:** <10ms für Reads, <15ms für Writes bei 99% der Anfragen
- **SLA: 99,999%** Verfügbarkeit

**APIs (Kompatibilitätsmodi):**
- **NoSQL (Core):** Native Cosmos DB JSON-Dokumente
- **MongoDB:** Kompatibel mit MongoDB-Treibern
- **Cassandra:** CQL-kompatibel
- **Gremlin:** Graph-API
- **Table:** Azure Table Storage API

**Konsistenzmodelle (stärkste → schwächste):**
Strong → Bounded Staleness → Session → Consistent Prefix → Eventual

**Partitionierung:**
- **Partition Key** muss gut gewählt sein (Cardinality!)
- Logische Partitionen max. 20 GB
- Physische Partitionen auto-skaliert

**Abrechnung:** RU/s (Request Units per Second)$$,
   '["Azure","CosmosDB","NoSQL","Datenbank"]', 'Datenbanken'),

  (v_azure, v_uid, 'ARM Templates & Bicep',
$$**Infrastructure as Code** für Azure: Ressourcen deklarativ definieren und reproduzierbar deployen.

**ARM Templates:** JSON-basiert, verbose
```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2021-04-01",
  "name": "[parameters('storageName')]",
  "location": "[resourceGroup().location]",
  "sku": { "name": "Standard_LRS" },
  "kind": "StorageV2"
}
```

**Bicep:** Domain-Specific Language (DSL) — kompiler zu ARM JSON
```bicep
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageName
  location: resourceGroup().location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}
```

**Deployment:**
```bash
az deployment group create \
  --resource-group meinRG \
  --template-file main.bicep \
  --parameters storageName=meinstorage
```

**Alternativen:** Terraform (cloud-agnostisch), Pulumi (imperative Sprachen)$$,
   '["Azure","IaC","ARM","Bicep","Infrastructure"]', 'DevOps');

  -- ════════════════════════════════════════════════════════════════
  -- KUBERNETES
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_kubernetes, v_uid, 'Was ist Kubernetes?',
$$**Kubernetes (K8s)** ist ein Open-Source-System zur **Orchestrierung** von Container-Workloads.

**Kernaufgaben:**
- Container deployen, skalieren, aktualisieren
- Self-Healing (automatischer Neustart abgestürzter Container)
- Service Discovery und Load Balancing
- Rolling Updates und Rollbacks
- Secret und Konfigurationsverwaltung

**Architektur:**
```
Control Plane (Master)
├── kube-apiserver     ← Einziger Einstiegspunkt
├── etcd               ← Cluster-Zustandsdatenbank
├── kube-scheduler     ← Weist Pods Nodes zu
└── controller-manager ← Überwacht Cluster-Zustand

Worker Nodes
├── kubelet            ← Kommuniziert mit Control Plane
├── kube-proxy         ← Netzwerk-Routing
└── Container Runtime  ← containerd, CRI-O
```

**Entstehung:** Von Google (Borg/Omega), 2014 open-source, seit 2016 bei CNCF$$,
   '["Kubernetes","Container","Orchestrierung"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'Pod',
$$Ein **Pod** ist die kleinste deploybare Einheit in Kubernetes — eine Gruppe von einem oder mehreren Containern.

**Eigenschaften:**
- Container in einem Pod teilen Netzwerk-Namespace (selbe IP) und Volumes
- Pods sind **ephemer** — keine feste Identität oder Adresse
- Ein Pod läuft auf genau einem Node

**Pod-Manifest:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mein-pod
  labels:
    app: webserver
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
```

**Multi-Container Pods:** Sidecar-Pattern, Ambassador, Adapter
**Status:** Pending → Running → Succeeded/Failed/CrashLoopBackOff$$,
   '["Kubernetes","Pod","Container"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Deployment',
$$Ein **Deployment** verwaltet eine Menge identischer Pods über ein ReplicaSet.

**Kernfunktionen:**
- Gewünschte Anzahl Replikas (Replicas) sicherstellen
- Rolling Update mit konfigurierbarer Strategie
- Rollback auf vorherige Version

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meine-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: meine-app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1    # Max. 1 Pod gleichzeitig down
      maxSurge: 1          # Max. 1 extra Pod beim Update
  template:
    metadata:
      labels:
        app: meine-app
    spec:
      containers:
        - name: app
          image: myapp:v2
```

**Wichtige Befehle:**
```bash
kubectl apply -f deployment.yaml
kubectl rollout status deployment/meine-app
kubectl rollout undo deployment/meine-app
kubectl scale deployment/meine-app --replicas=5
```$$,
   '["Kubernetes","Deployment","Rolling Update"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Service',
$$Ein **Service** stellt Pods unter einer stabilen IP/DNS-Adresse erreichbar (Pods kommen und gehen).

**Service-Typen:**

| Typ | Erreichbarkeit | Einsatz |
|---|---|---|
| **ClusterIP** | Nur innerhalb Cluster | Standard, Service-zu-Service |
| **NodePort** | Über Node-IP:Port (30000-32767) | Test, kein LoadBalancer |
| **LoadBalancer** | Externer Cloud-LB (Azure/AWS) | Produktion |
| **ExternalName** | Alias für externen DNS | Externe Services |

```yaml
apiVersion: v1
kind: Service
metadata:
  name: meine-app-svc
spec:
  selector:
    app: meine-app      # Wählt Pods mit diesem Label
  ports:
    - port: 80          # Service-Port
      targetPort: 8080  # Container-Port
  type: ClusterIP
```

**Service Discovery:** DNS `http://meine-app-svc.namespace.svc.cluster.local`
**Endpoints:** Service enthält dynamische Liste der Pod-IPs$$,
   '["Kubernetes","Service","Networking"]', 'Netzwerk'),

  (v_kubernetes, v_uid, 'Ingress',
$$**Ingress** steuert eingehenden HTTP/HTTPS-Traffic in den Cluster — ein externer Einstiegspunkt.

**Funktionen:**
- Host-basiertes Routing: `api.example.com` → Service A
- Pfad-basiertes Routing: `/api` → Service A, `/web` → Service B
- TLS-Terminierung (HTTPS)
- Authentifizierung, Rate-Limiting (per Ingress Controller)

**Ingress benötigt einen Ingress Controller:**
- **NGINX Ingress Controller** (am verbreitetsten)
- **Azure Application Gateway Ingress Controller (AGIC)**
- Traefik, HAProxy, Istio Gateway

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mein-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /v1
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 80
  tls:
    - hosts: [api.example.com]
      secretName: tls-secret
```$$,
   '["Kubernetes","Ingress","Netzwerk","HTTP"]', 'Netzwerk'),

  (v_kubernetes, v_uid, 'ConfigMap & Secret',
$$**ConfigMap** und **Secret** trennen Konfiguration vom Container-Image.

**ConfigMap** für nicht-sensible Daten:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  LOG_LEVEL: "debug"
  DATABASE_HOST: "db.cluster.local"
```

**Secret** für sensible Daten (base64-kodiert, nicht verschlüsselt!):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=   # base64("password")
```

**Verwendung im Pod:**
```yaml
env:
  - name: LOG_LEVEL
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: LOG_LEVEL
  - name: DB_PASS
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
# Oder als Volume mounten:
volumes:
  - name: config-vol
    configMap:
      name: app-config
```

⚠️ Secrets sind nur base64, nicht verschlüsselt — für echte Sicherheit: Sealed Secrets oder External Secrets Operator$$,
   '["Kubernetes","ConfigMap","Secret","Konfiguration"]', 'Konfiguration'),

  (v_kubernetes, v_uid, 'kubectl Grundbefehle',
$$**kubectl** ist das CLI-Tool zur Steuerung von Kubernetes-Clustern.

```bash
# Kontext/Cluster
kubectl config get-contexts
kubectl config use-context mein-cluster

# Ressourcen anzeigen
kubectl get pods                           # Pods im current namespace
kubectl get pods -n kube-system            # anderen namespace
kubectl get pods -A                        # alle namespaces
kubectl get pods -o wide                   # mit Node-Info
kubectl describe pod mein-pod              # Details + Events

# Logs
kubectl logs mein-pod
kubectl logs mein-pod -c container-name    # Multi-Container
kubectl logs -f mein-pod                   # follow/stream

# Exec in Container
kubectl exec -it mein-pod -- /bin/bash

# Ressourcen anwenden / löschen
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl delete pod mein-pod

# Port-Forwarding (lokaler Zugriff)
kubectl port-forward pod/mein-pod 8080:80
kubectl port-forward svc/mein-svc 8080:80

# Deployment skalieren
kubectl scale deployment meine-app --replicas=3

# Rollout
kubectl rollout status deployment/meine-app
kubectl rollout undo deployment/meine-app
```$$,
   '["Kubernetes","kubectl","CLI","Commands"]', 'Tools'),

  (v_kubernetes, v_uid, 'Namespace',
$$**Namespaces** partitionieren einen Kubernetes-Cluster in isolierte virtuelle Cluster.

**Einsatzzwecke:**
- Teams/Projekte trennen (team-a, team-b)
- Umgebungen trennen (dev, staging, prod) — besser eigene Cluster!
- Resource Quotas und RBAC pro Namespace

**Standard-Namespaces:**
- `default` — Standard wenn keiner angegeben
- `kube-system` — Kubernetes-Systemkomponenten
- `kube-public` — Öffentlich lesbar
- `kube-node-lease` — Node Heartbeats

**Befehle:**
```bash
kubectl get namespaces
kubectl create namespace mein-team
kubectl get pods -n mein-team
kubectl config set-context --current --namespace=mein-team
```

**Resource Quota (Limits pro Namespace):**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-quota
  namespace: mein-team
spec:
  hard:
    pods: "50"
    requests.cpu: "8"
    requests.memory: 16Gi
```

⚠️ Namespaces sind KEIN Sicherheitsmerkmal — Netzwerk-Policies separat konfigurieren$$,
   '["Kubernetes","Namespace","Organisation"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'Helm',
$$**Helm** ist der Paketmanager für Kubernetes — wie apt/npm, aber für K8s-Manifeste.

**Konzepte:**
- **Chart:** Paket von Kubernetes-Manifesten + Templates
- **Release:** Installierte Instanz eines Charts
- **Repository:** Sammlung von Charts (z. B. Artifact Hub)
- **Values:** Konfigurationswerte, die Templates füllen

**Typische Befehle:**
```bash
# Repo hinzufügen
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Chart suchen
helm search repo nginx

# Chart installieren
helm install mein-nginx bitnami/nginx \
  --namespace mein-ns \
  --create-namespace \
  --set service.type=LoadBalancer

# Mit values-Datei
helm install meine-app ./my-chart -f custom-values.yaml

# Upgrade
helm upgrade mein-nginx bitnami/nginx

# Status / Liste
helm list -A
helm status mein-nginx

# Deinstallieren
helm uninstall mein-nginx
```

**Chart-Struktur:**
```
my-chart/
├── Chart.yaml       # Metadaten
├── values.yaml      # Standardwerte
└── templates/       # Kubernetes-Manifeste mit Go-Templates
```$$,
   '["Kubernetes","Helm","Paketmanager","Tools"]', 'Tools'),

  (v_kubernetes, v_uid, 'StatefulSet & DaemonSet',
$$**StatefulSet** und **DaemonSet** sind spezialisierte Workload-Typen.

## StatefulSet
Für **zustandsbehaftete Anwendungen** (Datenbanken, Queues).

**Eigenschaften:**
- Stabile, eindeutige Pod-Namen: `pod-0`, `pod-1`, `pod-2`
- Stabiler persistenter Storage pro Pod (eigene PVC)
- Geordnetes Hochfahren (0 → 1 → 2) und Herunterfahren (2 → 1 → 0)
- Stabiler Netzwerkidentifier (Headless Service)

**Einsatz:** MongoDB, MySQL Cluster, Kafka, Zookeeper

## DaemonSet
Stellt sicher, dass **auf jedem Node** (oder ausgewählten Nodes) genau ein Pod läuft.

**Einsatz:**
- Log-Collector (Fluentd, Filebeat)
- Node-Monitoring (Prometheus Node Exporter)
- Netzwerk-Plugins (CNI-Agents)
- Storage-Agents

```yaml
kind: DaemonSet
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    spec:
      nodeSelector:
        kubernetes.io/os: linux
```$$,
   '["Kubernetes","StatefulSet","DaemonSet","Workloads"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Resource Limits & HPA',
$$## Resource Requests & Limits

```yaml
resources:
  requests:           # Mindestgarantie (für Scheduling)
    memory: "128Mi"
    cpu: "250m"       # 250 Millicores = 0.25 CPU
  limits:             # Maximum (wird hart durchgesetzt)
    memory: "256Mi"
    cpu: "500m"
```

- **OOMKilled:** Pod wird beendet wenn Memory Limit überschritten
- **CPU Throttling:** CPU wird gedrosselt (kein Kill)
- **QoS Klassen:** Guaranteed (req=limit), Burstable, BestEffort

## Horizontal Pod Autoscaler (HPA)

Skaliert Deployment automatisch basierend auf Metriken.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: meine-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: meine-app
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```$$,
   '["Kubernetes","Resources","HPA","Autoscaling"]', 'Performance'),

  (v_kubernetes, v_uid, 'Persistent Volumes',
$$Kubernetes abstrahiert Speicher über **PersistentVolume (PV)** und **PersistentVolumeClaim (PVC)**.

**PersistentVolume (PV):** Vom Admin bereitgestellter Speicherblock
**PersistentVolumeClaim (PVC):** Anfrage eines Pods nach Speicher
**StorageClass:** Definiert den Speichertyp (SSD, HDD, NFS…)

```yaml
# PVC (was der Pod anfragt)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mein-pvc
spec:
  accessModes:
    - ReadWriteOnce       # RWO: ein Node | RWX: mehrere Nodes
  storageClassName: managed-premium   # Azure Premium SSD
  resources:
    requests:
      storage: 10Gi
---
# Verwendung im Pod
volumes:
  - name: daten
    persistentVolumeClaim:
      claimName: mein-pvc
containers:
  - name: db
    volumeMounts:
      - mountPath: /var/lib/data
        name: daten
```

**Access Modes:**
- `ReadWriteOnce (RWO)` — ein Node, lesen+schreiben
- `ReadOnlyMany (ROX)` — viele Nodes, nur lesen
- `ReadWriteMany (RWX)` — viele Nodes, lesen+schreiben$$,
   '["Kubernetes","Storage","PVC","Volumes"]', 'Storage');

  -- ════════════════════════════════════════════════════════════════
  -- DOCKER
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_docker, v_uid, 'Was ist Docker?',
$$**Docker** ist eine Plattform zum Erstellen, Verteilen und Ausführen von **Containern**.

**Container vs. VM:**
| | Container | VM |
|---|---|---|
| Isolation | Prozessebene (Kernel geteilt) | Hardware-Ebene (eigener Kernel) |
| Startzeit | Millisekunden | Minuten |
| Größe | MBs | GBs |
| Overhead | Minimal | Hoch (Hypervisor + OS) |
| Portabilität | Sehr hoch | Eingeschränkt |

**Docker-Architektur:**
- **Docker Engine:** Daemon (`dockerd`) + REST API + CLI
- **Image:** Read-only Template (Layer-basiert)
- **Container:** Laufende Instanz eines Images
- **Registry:** Speicherort für Images (Docker Hub, ACR, ECR)

**Warum Docker?**
- "Works on my machine" Problem gelöst
- Konsistente Umgebungen (Dev = Prod)
- Schnelles Deployment, einfaches Rollback
- Microservices-Architektur$$,
   '["Docker","Container","Grundlagen"]', 'Grundlagen'),

  (v_docker, v_uid, 'Dockerfile',
$$Das **Dockerfile** ist die Bauanleitung für ein Docker-Image.

```dockerfile
# Basis-Image
FROM node:20-alpine

# Arbeitsverzeichnis im Container
WORKDIR /app

# Abhängigkeiten zuerst kopieren (besseres Layer-Caching!)
COPY package*.json ./
RUN npm ci --only=production

# Quellcode kopieren
COPY . .

# Port dokumentieren (informativ)
EXPOSE 3000

# Umgebungsvariable setzen
ENV NODE_ENV=production

# Startbefehl
CMD ["node", "server.js"]
```

**Wichtige Anweisungen:**
| Anweisung | Funktion |
|---|---|
| `FROM` | Basis-Image |
| `WORKDIR` | Arbeitsverzeichnis setzen |
| `COPY` | Dateien in Image kopieren |
| `ADD` | Wie COPY, + URL/tar entpacken |
| `RUN` | Befehl beim Build ausführen |
| `ENV` | Env-Variable setzen |
| `ARG` | Build-Zeit-Variable |
| `EXPOSE` | Port dokumentieren |
| `CMD` | Standardbefehl (überschreibbar) |
| `ENTRYPOINT` | Hauptprozess (schwerer zu überschreiben) |
| `USER` | Als welcher User ausführen |$$,
   '["Docker","Dockerfile","Build","Image"]', 'Grundlagen'),

  (v_docker, v_uid, 'docker build & run',
$$**Grundlegende Docker-Befehle für Build und Run.**

## docker build
```bash
docker build -t meine-app:v1 .
docker build -t meine-app:v1 -f ./docker/Dockerfile .
docker build --build-arg VERSION=1.2.3 -t meine-app .

# Images anzeigen
docker images
docker image ls
```

## docker run
```bash
# Einfach
docker run nginx

# Im Hintergrund (detached)
docker run -d nginx

# Port mappen: host:container
docker run -d -p 8080:80 nginx

# Volume mounten
docker run -d -v /host/daten:/app/daten meine-app

# Env-Variable setzen
docker run -e DB_HOST=localhost meine-app

# Name vergeben
docker run -d --name mein-container meine-app

# Ressourcen begrenzen
docker run -d --memory="256m" --cpus="0.5" meine-app

# Auto-Restart
docker run -d --restart unless-stopped meine-app

# Interaktiv
docker run -it ubuntu /bin/bash
```

## Häufige Container-Befehle
```bash
docker ps              # Laufende Container
docker ps -a           # Alle Container (auch gestoppte)
docker stop <id/name>
docker rm <id/name>
docker logs -f <id>
docker exec -it <id> bash
```$$,
   '["Docker","CLI","Build","Run"]', 'Tools'),

  (v_docker, v_uid, 'Docker Compose',
$$**Docker Compose** definiert und startet Multi-Container-Anwendungen deklarativ.

```yaml
# docker-compose.yml
version: '3.9'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
      - REDIS_URL=redis://cache:6379
    depends_on:
      - db
      - cache
    volumes:
      - ./uploads:/app/uploads
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: meindb
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}   # aus .env Datei
    volumes:
      - postgres_data:/var/lib/postgresql/data

  cache:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb

volumes:
  postgres_data:     # Benanntes Volume (persistent)
```

**Wichtige Befehle:**
```bash
docker compose up -d          # Starten (detached)
docker compose down           # Stoppen + Container entfernen
docker compose down -v        # + Volumes löschen
docker compose logs -f web    # Logs folgen
docker compose ps             # Status
docker compose exec web bash  # Shell in Container
docker compose build          # Images neu bauen
```$$,
   '["Docker","Compose","Multi-Container","DevOps"]', 'Tools'),

  (v_docker, v_uid, 'Volumes & Bind Mounts',
$$Docker hat drei Möglichkeiten, Daten persistent zu speichern.

## Volumes (empfohlen)
Docker verwaltet den Speicherort (`/var/lib/docker/volumes/`)
```bash
docker volume create mein-vol
docker run -v mein-vol:/data nginx
docker volume ls
docker volume inspect mein-vol
docker volume rm mein-vol
```

## Bind Mounts
Host-Verzeichnis direkt in Container eingebinden
```bash
docker run -v /host/pfad:/container/pfad nginx
# Kurzform (absoluter Pfad nötig)
docker run -v $(pwd)/config:/app/config nginx
```

## tmpfs Mounts (RAM)
Nur im RAM, nicht persistent
```bash
docker run --tmpfs /tmp nginx
```

## Vergleich
| | Volume | Bind Mount | tmpfs |
|---|---|---|---|
| Speicherort | Docker-verwaltet | Host-FS | RAM |
| Persistenz | ✅ | ✅ | ❌ |
| Performance | Gut | OS-abhängig | Sehr gut |
| Portabilität | Hoch | Niedrig | - |
| Einsatz | Prod-Daten | Dev (Hot Reload) | Temp-Daten |$$,
   '["Docker","Volumes","Storage","Persistenz"]', 'Storage'),

  (v_docker, v_uid, 'Multi-Stage Build',
$$**Multi-Stage Builds** reduzieren die finale Image-Größe massiv durch mehrere FROM-Stufen.

**Problem ohne Multi-Stage:**
- Build-Tools (Compiler, npm, Maven) im Produktions-Image
- Image wird unnötig groß (GBs statt MBs)
- Sicherheitsrisiko durch unnötige Tools

**Lösung:**
```dockerfile
# Stage 1: Build
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build     # Kompiliert TypeScript → JavaScript

# Stage 2: Production
FROM node:20-alpine   # Viel kleiner als node:20
WORKDIR /app
# Nur das Nötigste aus dem Build-Stage kopieren
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production   # Keine devDependencies
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Ergebnis:**
- Builder-Image: ~1 GB
- Produktions-Image: ~150 MB

**Bestimmten Stage bauen:**
```bash
docker build --target builder -t app-builder .
```$$,
   '["Docker","Multi-Stage","Optimierung","Build"]', 'Best Practices'),

  (v_docker, v_uid, 'ENTRYPOINT vs CMD',
$$Beide definieren was beim `docker run` ausgeführt wird — aber unterschiedlich.

## CMD
- **Standardbefehl** der beim Start ausgeführt wird
- Kann beim `docker run` **überschrieben** werden
```dockerfile
CMD ["node", "server.js"]
```
```bash
docker run meine-app              # → node server.js
docker run meine-app npm test     # → npm test (überschrieben!)
```

## ENTRYPOINT
- **Hauptprozess** des Containers
- Schwerer zu überschreiben (braucht `--entrypoint` Flag)
- `CMD` wird als Argument an ENTRYPOINT übergeben
```dockerfile
ENTRYPOINT ["node"]
CMD ["server.js"]        # Default-Argument
```
```bash
docker run meine-app              # → node server.js
docker run meine-app other.js     # → node other.js
```

## Kombination (häufigste Pattern)
```dockerfile
ENTRYPOINT ["docker-entrypoint.sh"]   # Immer ausgeführt
CMD ["server"]                         # Default-Argument
```

## Shell vs. Exec Form
```dockerfile
CMD node server.js           # Shell-Form: läuft in /bin/sh -c
CMD ["node", "server.js"]    # Exec-Form: direkt (empfohlen, PID 1)
```$$,
   '["Docker","ENTRYPOINT","CMD","Dockerfile"]', 'Grundlagen'),

  (v_docker, v_uid, 'Docker Netzwerk',
$$Docker bietet verschiedene **Netzwerk-Modi** für Container-Kommunikation.

## Netzwerk-Typen
```bash
docker network ls
```

| Typ | Beschreibung | Einsatz |
|---|---|---|
| **bridge** (Standard) | Eigenes virtuelles Netzwerk, Container isoliert vom Host | Standard dev/prod |
| **host** | Kein Netzwerk-Namespace, Container nutzt Host-Netzwerk | Performance-kritisch |
| **none** | Kein Netzwerk | Maximale Isolation |
| **overlay** | Multi-Host (Docker Swarm) | Verteilte Systeme |
| **macvlan** | Container bekommt eigene MAC/IP | Legacy-Netzwerke |

## Custom Bridge Network (empfohlen)
```bash
docker network create mein-netz
docker run -d --network mein-netz --name db postgres
docker run -d --network mein-netz --name web nginx

# Web kann jetzt 'db' als Hostname nutzen!
# http://db:5432 funktioniert intern
```

## Ports
```bash
# Host-Port 8080 → Container-Port 80
docker run -p 8080:80 nginx

# Alle Interfaces binden (Standard)
docker run -p 0.0.0.0:8080:80 nginx

# Nur Localhost
docker run -p 127.0.0.1:8080:80 nginx
```$$,
   '["Docker","Netzwerk","Networking","Bridge"]', 'Netzwerk'),

  (v_docker, v_uid, '.dockerignore & Image-Optimierung',
$$**.dockerignore** verhindert, dass unnötige Dateien ins Image gelangen.

```dockerignore
# Abhängigkeiten (werden im Container neu installiert)
node_modules/
vendor/

# Entwicklungstools & Configs
.git/
.gitignore
.env
.env.local
*.env

# Logs & temporäre Dateien
*.log
tmp/
.cache/

# Tests & Docs (nicht für Produktion)
tests/
__tests__/
*.test.ts
docs/
README.md

# Build-Outputs (werden im Multi-Stage Build erzeugt)
dist/
build/
```

## Image-Größe optimieren
1. **Alpine-Images** statt Ubuntu/Debian: `node:20-alpine` statt `node:20`
2. **Multi-Stage Builds:** Build-Tools nicht im Prod-Image
3. **Layers minimieren:** Mehrere RUN-Befehle zusammenfassen
   ```dockerfile
   # ❌ Viele Layers
   RUN apt-get update
   RUN apt-get install -y curl
   # ✅ Ein Layer
   RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
   ```
4. **Kein Root:** `USER node` statt als root laufen
5. **Layer-Caching nutzen:** Selten ändernde Dateien zuerst kopieren$$,
   '["Docker","Optimierung","Security","Best Practices"]', 'Best Practices'),

  (v_docker, v_uid, 'Docker Health Check',
$$**Health Checks** überwachen ob ein Container korrekt funktioniert.

```dockerfile
# Im Dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

**Parameter:**
- `--interval`: Wie oft prüfen (Standard: 30s)
- `--timeout`: Wie lange auf Antwort warten (Standard: 30s)
- `--start-period`: Startphase, Fehler ignorieren (Standard: 0s)
- `--retries`: Wie viele Fehlversuche bis unhealthy (Standard: 3)

**Exit Codes:**
- `0` = healthy
- `1` = unhealthy
- `2` = reserved (nicht nutzen)

**Status anzeigen:**
```bash
docker ps           # STATUS: healthy / unhealthy / starting
docker inspect <id> | grep -A 10 Health
```

**In Docker Compose:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 15s
```

**Kubernetes ignoriert Docker Health Checks** — dort werden `livenessProbe` und `readinessProbe` verwendet$$,
   '["Docker","Health Check","Monitoring","Produktion"]', 'Operations');

  -- ════════════════════════════════════════════════════════════════
  -- SCRUM
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_scrum, v_uid, 'Scrum Framework Überblick',
$$**Scrum** ist ein agiles Framework für die Entwicklung und Auslieferung komplexer Produkte.

**Grundprinzipien:**
- **Empirismus:** Entscheidungen basieren auf Erfahrung und Beobachtung
- **Drei Säulen:** Transparenz, Überprüfung (Inspection), Anpassung (Adaptation)

**Das Scrum-Framework:**
```
Product Backlog
      ↓
  Sprint Planning (max. 8h für 4-Wochen-Sprint)
      ↓
  Sprint (1–4 Wochen)
  ├── Daily Scrum (täglich, 15 Min)
  ├── Sprint Backlog wird abgearbeitet
  └── Increment entsteht täglich
      ↓
  Sprint Review (max. 4h)
      ↓
  Sprint Retrospektive (max. 3h)
      ↓
  Nächster Sprint
```

**Scrum-Werte:** Commitment, Focus, Offenheit, Respekt, Mut

**Scrum Guide:** Offizielle Referenz unter scrumguides.org (kostenlos)$$,
   '["Scrum","Agile","Framework","Überblick"]', 'Grundlagen'),

  (v_scrum, v_uid, 'Sprint',
$$Ein **Sprint** ist ein festes Zeitfenster (1–4 Wochen), in dem ein potenziell auslieferbares Increment entsteht.

**Eigenschaften:**
- Feste Länge — wird während des Sprints nicht verändert
- Kein Sprint hat Pausen zwischen sich und dem nächsten
- Während des Sprints: Qualitätsziel wird nicht gesenkt
- Sprint-Ziel kann ggf. angepasst werden, wenn neue Erkenntnisse

**Sprint-Abbruch:**
- Nur der **Product Owner** kann einen Sprint abbrechen
- Selten — nur wenn Sprint-Ziel obsolet wird

**Sprint Goal:**
- Verbindliches Ziel, das das Scrum Team im Sprint erreichen will
- Gibt Flexibilität: *wie* erreicht wird, kann sich ändern
- Bei Sprint Planning festgelegt

**Typische Sprint-Länge:**
- 2 Wochen: am häufigsten in der Praxis
- Kürzer = schnelleres Feedback, weniger Overhead
- Länger = mehr Planungssicherheit, aber träger$$,
   '["Scrum","Sprint","Zeitbox","Iteration"]', 'Events'),

  (v_scrum, v_uid, 'Product Backlog',
$$Der **Product Backlog** ist eine geordnete Liste aller bekannten Anforderungen an das Produkt.

**Eigenschaften:**
- Einzige Quelle für Arbeiten am Produkt
- Niemals "fertig" — entwickelt sich mit dem Produkt
- Transparent und sichtbar für alle
- Vom **Product Owner** verantwortet

**Einträge (Product Backlog Items / PBIs):**
- User Stories, Features, Bugs, technische Schulden, Recherchen (Spikes)
- Oben = detaillierter, geschätzt, bereit für Sprint
- Unten = grob, noch nicht geschätzt

**Ordnung:**
- Nach Wert, Risiko, Abhängigkeiten, Dringlichkeit
- PO entscheidet über Reihenfolge (nicht das Dev-Team)

**Backlog Refinement:**
- Regelmäßiges Verfeinern, Schätzen und Ordnen
- Keine offizielle Scrum-Veranstaltung, aber Best Practice
- Max. 10% der Sprint-Kapazität$$,
   '["Scrum","Backlog","Anforderungen","PO"]', 'Artefakte'),

  (v_scrum, v_uid, 'Sprint Backlog',
$$Der **Sprint Backlog** ist der Plan für den aktuellen Sprint.

**Bestandteile:**
1. **Sprint Goal** — Warum dieser Sprint?
2. **Ausgewählte PBIs** — Was wird umgesetzt?
3. **Plan der Umsetzung** — Wie wird's gemacht? (Tasks, max. 1 Tag)

**Eigenschaften:**
- Gehört dem **Development Team** — nur sie können es ändern
- Sichtbar und täglich aktualisiert
- Emerging: Neue Tasks entstehen während des Sprints

**Sichtbarkeit:**
- Meist als Kanban-Board: To Do → In Progress → Done
- Burndown Chart zeigt verbleibende Arbeit

**Unterschied zum Product Backlog:**
| | Product Backlog | Sprint Backlog |
|---|---|---|
| Eigentümer | Product Owner | Development Team |
| Umfang | Gesamtes Produkt | Aktueller Sprint |
| Veränderung | Jederzeit | Nur durch Dev-Team |
| Zeitraum | Langfristig | Aktueller Sprint |$$,
   '["Scrum","Sprint Backlog","Planung","Board"]', 'Artefakte'),

  (v_scrum, v_uid, 'Increment',
$$Das **Increment** ist das Ergebnis jedes Sprints — eine konkret nutzbare Produktversion.

**Definition:**
- Summe aller Sprint Backlog Items + Wert aller vorherigen Increments
- Muss die **Definition of Done** erfüllen
- Muss **potenziell auslieferbar** sein (nicht notwendig deployed)
- Kann mehrere Increments pro Sprint geben

**Warum wichtig?**
- Erzeugt echtes Feedback (statt Papier-Konzepten)
- PO kann jederzeit ein Release aus dem Increment machen
- Zeigt kontinuierlichen Fortschritt

**Continuous Delivery:**
In modernen Teams wird das Increment oft bei jedem Merge automatisch deployed (CI/CD).

**Häufige Missverständnisse:**
❌ Nur am Sprint-Ende vorhanden
✅ Wächst täglich während des Sprints

❌ PO muss es deployen
✅ PO entscheidet ob deployed wird — Increment muss aber auslieferbereit sein$$,
   '["Scrum","Increment","Lieferung","Qualität"]', 'Artefakte'),

  (v_scrum, v_uid, 'Product Owner (Rolle)',
$$Der **Product Owner (PO)** maximiert den Wert des Produkts und des Development Teams.

**Verantwortlichkeiten:**
- **Product Backlog** entwickeln, kommunizieren, ordnen
- Product Backlog Items klar formulieren und verständlich machen
- Stakeholder-Management: Erwartungen managen, Prioritäten abstimmen
- Entscheidet, was im Sprint gemacht wird (nicht wie)
- Akzeptiert oder lehnt Ergebnisse ab

**Eigenschaften:**
- **Eine Person**, keine Komitee
- Muss vom Unternehmen befähigt sein (Entscheidungen treffen dürfen)
- Fokus auf Wert und Outcome, nicht Output

**PO ist NICHT:**
- Projektmanager (kein Command-and-Control)
- Proxy (Entscheidungen müssen beim PO liegen)
- Teilzeit-Rolle

**Zusammenarbeit:**
- Enges Arbeiten mit Stakeholdern (was wird gebraucht?)
- Enges Arbeiten mit Dev-Team (wie ist es machbar?)
- Verfügbar für Fragen während des Sprints$$,
   '["Scrum","Product Owner","Rolle","Backlog"]', 'Rollen'),

  (v_scrum, v_uid, 'Scrum Master (Rolle)',
$$Der **Scrum Master** dient dem Scrum Team und der Organisation bei der Einführung von Scrum.

**Dienst für das Development Team:**
- Hindernisse (Impediments) beseitigen
- Coaching in Selbstorganisation und Cross-Funktionalität
- Scrum-Events facilitieren
- Schützt vor äußeren Störungen

**Dienst für den Product Owner:**
- Hilft bei effektiver Backlog-Pflege
- Vermittelt zwischen PO und Dev-Team
- Scrum verständlich machen

**Dienst für die Organisation:**
- Scrum einführen und adaptieren
- Empirisches Produktmanagement ermöglichen
- Silos zwischen Stakeholdern reduzieren

**Scrum Master ist NICHT:**
- Projektmanager oder Teamleiter
- "Scrum Police" (Regeln aufzwingen)
- Sekretär für das Team

**Führungsstil:** Servant Leadership — führen durch Dienen, nicht durch Autorität$$,
   '["Scrum","Scrum Master","Rolle","Coaching","Agile"]', 'Rollen'),

  (v_scrum, v_uid, 'Development Team (Rolle)',
$$Das **Development Team** (in Scrum Guide 2020: einfach Teil des "Scrum Teams") erstellt das Increment.

**Eigenschaften:**
- **Cross-funktional:** Alle Fähigkeiten im Team (Dev, Test, Design, Ops…)
- **Selbstorganisiert:** Team entscheidet, wie Arbeit erledigt wird
- **Keine Sub-Teams:** Keine "Frontend-Team" innerhalb — alle sind Entwickler
- **Gemeinsame Verantwortung:** Das Team als Ganzes, kein Einzelner

**Größe:** 3–9 Personen (optimal ~5–7)
- Zu klein: zu wenig Fähigkeiten, Abhängigkeiten von außen
- Zu groß: Koordinationsaufwand steigt, Kommunikation leidet

**Was das Dev-Team entscheidet:**
- Wie viel Arbeit im Sprint machbar ist (Kapazität)
- Wie die Arbeit erledigt wird (technische Entscheidungen)
- Wer welchen Task übernimmt

**Was das Dev-Team NICHT entscheidet:**
- Welche Backlog Items priorisiert werden (PO)
- Ob ein Increment released wird (PO)$$,
   '["Scrum","Development Team","Selbstorganisation","Rollen"]', 'Rollen'),

  (v_scrum, v_uid, 'Sprint Planning',
$$**Sprint Planning** eröffnet jeden Sprint. Das Scrum Team plant gemeinsam.

**Zeitbox:** Max. 8 Stunden für einen 4-Wochen-Sprint (proportional kürzer bei kürzeren Sprints)

**3 Fragen (Scrum Guide 2020):**
1. **Warum ist dieser Sprint wertvoll?** → Sprint Goal festlegen
2. **Was kann in diesem Sprint erledigt werden?** → PBIs aus Backlog auswählen
3. **Wie wird die ausgewählte Arbeit erledigt?** → Tasks/Plan erstellen

**Ablauf:**
```
1. PO erklärt Sprint Goal Idee + Top-Backlog-Items
2. Dev-Team schätzt/bespricht Machbarkeit
3. Sprint Goal wird formuliert (gemeinsam)
4. Dev-Team zieht PBIs in Sprint Backlog
5. Dev-Team zerlegt PBIs in Tasks (max. 1 Tag)
```

**Definition of Ready:** PBIs sollten vor Planning klar, schätzbar und testbar sein

**Ergebnis:** Sprint Goal + Sprint Backlog$$,
   '["Scrum","Sprint Planning","Events","Planung"]', 'Events'),

  (v_scrum, v_uid, 'Daily Scrum',
$$Das **Daily Scrum** ist ein tägliches 15-Minuten-Meeting für das Development Team.

**Zweck:** Fortschritt zum Sprint Goal überprüfen und Plan für die nächsten 24h anpassen

**Eigenschaften:**
- Zeitbox: **15 Minuten**
- Jeden Tag, gleiche Zeit, gleicher Ort (oder remote)
- Nur für das **Development Team** (PO/SM sind Gäste)
- Format freigestellt (nicht die 3-Fragen-Methode zwingend)

**Typische Struktur (optional):**
1. Was habe ich gestern getan (Richtung Sprint Goal)?
2. Was mache ich heute?
3. Gibt es Hindernisse?

**Was Daily Scrum NICHT ist:**
- Statusmeeting für den Manager
- Technische Diskussion (die findet nach dem Daily statt)
- Pflicht für PO oder Scrum Master

**Nutzen:**
- Transparenz über Fortschritt
- Impediments früh sichtbar machen
- Selbstorganisation fördern
- Unnötige weitere Meetings reduzieren$$,
   '["Scrum","Daily Scrum","Stand-Up","Events"]', 'Events'),

  (v_scrum, v_uid, 'Sprint Review',
$$Die **Sprint Review** findet am Ende jedes Sprints statt — das Scrum Team zeigt die Ergebnisse.

**Zeitbox:** Max. 4 Stunden (4-Wochen-Sprint)

**Teilnehmer:** Scrum Team + Stakeholder (Kunden, Management, User…)

**Zweck:**
- Increment inspizieren und Feedback sammeln
- Product Backlog anpassen basierend auf Feedback
- Fortschritt Richtung Product Goal besprechen

**Ablauf (typisch):**
1. PO erklärt was Done ist (und was nicht)
2. Dev-Team demonstriert das Increment live
3. Stakeholder geben Feedback
4. PO aktualisiert Product Backlog (neue Erkenntnisse!)
5. Nächste Schritte und Marktchancen besprechen

**Was Sprint Review NICHT ist:**
❌ Abnahme-Meeting (PO akzeptiert nicht formal)
❌ Präsentation von PowerPoints
❌ Nur für das Team

**Wichtig:** Das Increment wird vorgeführt, nicht beschrieben$$,
   '["Scrum","Sprint Review","Stakeholder","Events","Demo"]', 'Events'),

  (v_scrum, v_uid, 'Sprint Retrospektive',
$$Die **Sprint Retrospektive** ist die Selbstreflexion des Scrum Teams.

**Zeitbox:** Max. 3 Stunden (4-Wochen-Sprint)

**Teilnehmer:** Nur das Scrum Team (PO + SM + Dev-Team)

**Zweck:** Team-Prozesse, Tools und Zusammenarbeit verbessern — nicht das Produkt!

**3 Fragen:**
1. Was lief **gut**? (Beibehalten)
2. Was lief **nicht gut**? (Verbessern)
3. Was werden wir im **nächsten Sprint anders** machen? (Aktionspunkte)

**Typische Methoden:**
- **Start / Stop / Continue:** Was anfangen, aufhören, weitermachen?
- **4L's:** Liked, Learned, Lacked, Longed for
- **Mad / Sad / Glad:** Emotionale Perspektive
- **5 Whys:** Ursache von Problemen finden

**Ergebnis:** Mindestens **1 Verbesserungsmaßnahme** im nächsten Sprint Sprint Backlog

**Unterschied zu Review:**
- Review: Produkt (Was haben wir gebaut?)
- Retro: Prozess (Wie haben wir gearbeitet?)$$,
   '["Scrum","Retrospektive","Verbesserung","Events","Teamarbeit"]', 'Events'),

  (v_scrum, v_uid, 'Definition of Done (DoD)',
$$Die **Definition of Done (DoD)** beschreibt, wann ein Increment als fertig gilt.

**Zweck:**
- Gemeinsames Qualitätsverständnis
- Verhindert "Fast fertig"-Syndrom
- Transparenz über den Zustand eines Increments

**Beispiel DoD:**
- [ ] Code geschrieben und peer-reviewed
- [ ] Unit Tests geschrieben und bestanden (>80% Coverage)
- [ ] Integration Tests bestanden
- [ ] In Staging-Umgebung deployed und getestet
- [ ] Dokumentation aktualisiert
- [ ] Keine bekannten kritischen Bugs
- [ ] Accessibility-Check bestanden
- [ ] PO hat User Story akzeptiert

**Eigenschaften:**
- Gilt für das **gesamte Increment** (nicht einzelne Stories)
- Vom Dev-Team erstellt, von Organisation vorgegeben wenn vorhanden
- Strenger als "Acceptance Criteria" (die sind story-spezifisch)
- Wird in Retros verbessert

**Wenn DoD nicht erfüllt:** PBI gehört NICHT ins Increment, kommt zurück in Backlog$$,
   '["Scrum","DoD","Qualität","Artefakte"]', 'Qualität'),

  (v_scrum, v_uid, 'User Story',
$$Eine **User Story** beschreibt eine Anforderung aus der Nutzerperspektive.

**Format:**
> Als **[Rolle]** möchte ich **[Funktion]**, damit **[Nutzen]**.

**Beispiel:**
> Als **eingeloggter Nutzer** möchte ich **mein Passwort zurücksetzen können**, damit **ich auch nach Vergessen des Passworts Zugang zum System habe.**

**INVEST-Kriterien für gute Stories:**
| Buchstabe | Bedeutung |
|---|---|
| **I**ndependent | Unabhängig von anderen Stories |
| **N**egotiable | Verhandelbar (kein Vertrag) |
| **V**aluable | Wertvoll für Nutzer oder Kunde |
| **E**stimable | Schätzbar |
| **S**mall | Klein genug für einen Sprint |
| **T**estable | Testbar (Acceptance Criteria) |

**Acceptance Criteria:**
- Konkrete Bedingungen die erfüllt sein müssen
- Meist als Szenarien: "Gegeben … wenn … dann …"
- Story-spezifisch (nicht zu verwechseln mit DoD)

**Epics:** Zu große Stories → werden in kleinere User Stories aufgeteilt$$,
   '["Scrum","User Story","Anforderungen","INVEST"]', 'Anforderungen'),

  (v_scrum, v_uid, 'Story Points & Schätzung',
$$**Story Points** sind eine relative Maßeinheit für den Aufwand einer User Story.

**Wichtig:** Story Points messen relativen Aufwand und Komplexität, **nicht Zeit**!

**Fibonacci-Folge:** 1, 2, 3, 5, 8, 13, 21, 34, 55, 89 (oder 1, 2, 3, 5, 8, 13, 21)
- Große Lücken bei großen Zahlen → Unsicherheit eingebaut
- Story mit 8 Punkten ist ungefähr doppelt so groß wie eine mit 4

**Planning Poker:**
1. PO erklärt Story
2. Jeder wählt verdeckt eine Karte
3. Alle decken gleichzeitig auf
4. Diskussion bei großen Abweichungen
5. Neues Voting bis Konsens

**Referenzstory:** Eine bekannte Story als Maßstab nutzen
→ "Login-Button implementieren = 2 Punkte. Diese Story ist doppelt so groß = 4 Punkte"

**Was beinflusst Story Points:**
- Komplexität der Umsetzung
- Risiko / Unsicherheit
- Menge der Arbeit
- **Nicht:** Wer die Arbeit macht

**Velocity:** Durchschnittliche Story Points pro Sprint → Sprint-Kapazität planen$$,
   '["Scrum","Story Points","Schätzung","Planning Poker"]', 'Planung'),

  (v_scrum, v_uid, 'Velocity & Burndown Chart',
$$## Velocity
**Velocity** = Summe der abgeschlossenen Story Points pro Sprint

**Verwendung:**
- Release-Planung: Wie viele Sprints für 200 Points noch? → 200 / Ø-Velocity
- Sprint-Planung: Nicht mehr reinpacken als die Velocity erlaubt
- Nach 3–5 Sprints stabilisiert sich die Velocity

**Velocity ≠ Produktivität** — kein Ziel, nur ein Planungswerkzeug

## Burndown Chart
Zeigt **verbleibende Arbeit** im Sprint über die Zeit.

```
Story Points
  ↑
20 |█
18 |  █
16 |     █
14 |        ●  ← ideal
12 |     █ (akt.)
10 |
 0 +──────────────→ Sprint-Tage
  Tag 1           Tag 10
```

- **Ideallinie:** Gleichmäßiger Abbau
- **Über Ideallinie:** Team ist hinter Plan
- **Unter Ideallinie:** Team ist vor Plan

## Burnup Chart
Zeigt **fertiggestellte Arbeit** (statt verbleibende) + Total Scope$$,
   '["Scrum","Velocity","Burndown","Metriken"]', 'Metriken'),

  (v_scrum, v_uid, 'Backlog Refinement',
$$**Backlog Refinement** (früher Grooming) ist das kontinuierliche Verfeinern des Product Backlogs.

**Ziel:** Product Backlog Items Sprint-Ready machen

**Aktivitäten:**
- Stories ausdetaillieren und Acceptance Criteria formulieren
- Große Stories (Epics) in kleinere aufteilen
- Stories schätzen (Story Points)
- Reihenfolge überprüfen und anpassen
- Abhängigkeiten identifizieren
- Alte/obsolete Items entfernen

**Definition of Ready** (DoR) für PBIs:
- [ ] User Story klar formuliert
- [ ] Acceptance Criteria vorhanden
- [ ] Geschätzt
- [ ] Abhängigkeiten bekannt
- [ ] Klein genug für einen Sprint

**Wann?**
- Keine offizielle Scrum-Veranstaltung
- Best Practice: 1-2x pro Sprint, ca. 1–2 Stunden
- Ca. **10% der Sprint-Kapazität**

**Wer?**
- Product Owner + Development Team
- Scrum Master als Facilitator$$,
   '["Scrum","Backlog Refinement","Grooming","Planung"]', 'Planung'),

  (v_scrum, v_uid, 'Technical Debt & Spike',
$$## Technical Debt (Technische Schulden)
**Aufgelaufene Mehrarbeit**, die durch kurzfristige Lösungen statt guter Architektur entsteht.

**Arten:**
- **Bewusst/strategisch:** Schnelle Lösung jetzt, Refactoring geplant
- **Unbewusst:** Fehlendes Wissen → schlechte Entscheidungen
- **Faulig:** Über Zeit angesammelter Verfall

**In Scrum:**
- Technical Debt als PBIs im Backlog sichtbar machen
- Regelmäßig priorisieren (PO muss verstehen warum es wichtig ist)
- "Boy Scout Rule": Code immer etwas besser hinterlassen als gefunden
- Tech-Debt verhindert langfristig Velocity

---

## Spike
Ein **Spike** ist eine zeitboxed Recherche-Aufgabe zur Reduktion von Unsicherheit.

**Wann?**
- Technologie-Evaluation ("Können wir X mit Framework Y umsetzen?")
- Schätzung nicht möglich (zu viel Unbekanntes)
- Proof of Concept benötigt

**Eigenschaften:**
- Feste Zeitbox (z. B. 2 Tage)
- Klar definiertes Ergebnis (Bericht, Entscheidung, POC)
- Ergebnis des Spikes = neues PBI oder Schätzung$$,
   '["Scrum","Technical Debt","Spike","Qualität"]', 'Qualität'),

  (v_scrum, v_uid, 'Scrum of Scrums & Skalierung',
$$Scrum funktioniert optimal für ein Team. Für größere Organisationen gibt es Skalierungsframeworks.

## Scrum of Scrums
**Koordination zwischen mehreren Scrum Teams**
- Tägliches/wöchentliches Meeting der Team-Vertreter
- Je ein "Ambassador" pro Team
- Ähnlich Daily Scrum: Koordination, Abhängigkeiten, Blocker

## Skalierungsframeworks

**SAFe (Scaled Agile Framework):**
- Am weitesten verbreitet in Konzernen
- Hierarchisch: Team → Program → Portfolio
- PI Planning (Program Increment): Alle Teams planen 8-12 Wochen
- Kritik: Komplex, schwer schlanker zu machen

**LeSS (Large-Scale Scrum):**
- Minimale Änderungen an Scrum
- 2-8 Teams, ein Product Backlog, ein PO
- Eine Sprint Review für alle Teams

**Nexus:**
- Scrum.org Framework (Erfinder von Scrum)
- 3-9 Teams, Nexus Integration Team koordiniert
- Gemeinsame Definition of Done

**Spotify Model:** (kein Framework, Inspiration)
- Squads (Teams), Tribes (Abteilungen), Chapters (Fachbereiche), Guilds (Communities)$$,
   '["Scrum","Skalierung","SAFe","LeSS","Nexus"]', 'Skalierung');

  RAISE NOTICE 'Seed erfolgreich! Bereiche, Boxen und Karten für % erstellt.', v_uid;
END;
$$ LANGUAGE plpgsql;
