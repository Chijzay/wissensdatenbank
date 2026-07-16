-- ================================================================
-- Seed: Informatik + Scrum Lernkarten für steven.illg.it@outlook.com
-- Im Supabase SQL-Editor ausführen — NACH migration_001
-- ================================================================

DO $SEED$
DECLARE
  v_uid          uuid;
  v_informatik   integer;
  v_itmathe      integer;
  v_azure        integer;
  v_kubernetes   integer;
  v_docker       integer;
  v_scrum        integer;
  v_devops       integer;
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
  INSERT INTO boxes (name, icon, color, parent_id, user_id, sort_order)
    VALUES ('DevOps', '🔄', '#f97316', v_informatik, v_uid, 5) RETURNING id INTO v_devops;

  -- ════════════════════════════════════════════════════════════════
  -- IT MATHE
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_itmathe, v_uid, 'Big-O-Notation',
$C$**Big-O** beschreibt das **Wachstumsverhalten** eines Algorithmus in Abhängigkeit von der Eingabegröße n — unabhängig von Hardware und Konstanten.

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
- Best / Average / Worst Case sind unterschiedlich — O beschreibt meist den Worst Case$C$,
   '["Algorithmen","Komplexität","Laufzeit"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Binärzahlen',
$C$Das **Binärsystem** ist ein Stellenwertsystem zur Basis 2 — Computer arbeiten intern ausschließlich damit.

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
`1 + 1 = 10₂` (0, Übertrag 1)$C$,
   '["Binär","Zahlensysteme","Grundlagen"]', 'Zahlensysteme'),

  (v_itmathe, v_uid, 'Hexadezimalzahlen',
$C$Das **Hexadezimalsystem** (Basis 16) wird in der IT für kompakte Darstellung von Binärwerten verwendet.

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

**Präfixe:** `0x` (C/Java), `#` (CSS/Farben), `h` (Assembler)$C$,
   '["Hexadezimal","Zahlensysteme","Darstellung"]', 'Zahlensysteme'),

  (v_itmathe, v_uid, 'Bitoperationen',
$C$**Bitoperationen** arbeiten direkt auf den einzelnen Bits einer Ganzzahl.

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
- Farb-Channels extrahieren: `color >> 16 & 0xFF`$C$,
   '["Bitoperationen","Binär","Low-Level"]', 'Grundlagen'),

  (v_itmathe, v_uid, 'Aussagenlogik',
$C$Die **Aussagenlogik** (Boolesche Logik) beschäftigt sich mit Aussagen, die wahr (W) oder falsch (F) sind.

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
**De Morgan:** `¬(A ∧ B) = ¬A ∨ ¬B`$C$,
   '["Logik","Boolesch","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Mengen und Mengenoperationen',
$C$Eine **Menge** ist eine Sammlung eindeutiger Elemente: `M = {1, 2, 3}`

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

**In der Informatik:** Datenbankoperationen (JOIN, UNION), Filterlogik, Graphentheorie$C$,
   '["Mengen","Mathematik","Diskrete Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Graphen und Graphentheorie',
$C$Ein **Graph** G = (V, E) besteht aus **Knoten** (Vertices V) und **Kanten** (Edges E).

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

**Algorithmen:** BFS, DFS, Dijkstra (kürzester Weg), Kruskal/Prim (minimaler Spannbaum)$C$,
   '["Graphen","Algorithmen","Datenstrukturen"]', 'Datenstrukturen'),

  (v_itmathe, v_uid, 'Rekursion',
$C$**Rekursion** = eine Funktion ruft sich selbst auf. Jede Rekursion braucht:
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

**Memoization:** Ergebnisse cachen → vermeidet redundante Berechnungen (Dynamic Programming)$C$,
   '["Rekursion","Algorithmen","Programmierung"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Vollständige Induktion',
$C$Die **vollständige Induktion** beweist, dass eine Aussage für alle natürlichen Zahlen gilt.

**Schema:**
1. **Induktionsanfang (IA):** Aussage für n=0 (oder n=1) zeigen
2. **Induktionsvoraussetzung (IV):** Aussage gilt für n=k (angenommen)
3. **Induktionsschritt (IS):** Zeige, dass Aussage dann auch für n=k+1 gilt

**Beispiel:** Summe 1+2+…+n = n(n+1)/2

*IA:* n=1: 1 = 1·2/2 = 1 ✓
*IV:* Gilt für k: 1+…+k = k(k+1)/2
*IS:* 1+…+k+(k+1) = k(k+1)/2 + (k+1) = (k+1)(k+2)/2 ✓

**In der Informatik:** Korrektheitsbeweise für Algorithmen, Datenbanktheoreme, Laufzeitanalysen$C$,
   '["Induktion","Beweise","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Modulo-Arithmetik',
$C$Der **Modulo-Operator** (`%`) gibt den Rest einer ganzzahligen Division zurück.

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
Python: `-7 % 3 = 2` | Java/C: `-7 % 3 = -1`$C$,
   '["Modulo","Arithmetik","Kryptographie"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Hash-Funktionen',
$C$Eine **Hash-Funktion** bildet Daten beliebiger Länge auf einen Wert fixer Länge ab (Hash/Digest).

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

**Anwendungen:** Passwort-Speicherung, Dateiintegrität, Signaturen, Blockchain, Hash-Tables$C$,
   '["Hash","Kryptographie","Sicherheit"]', 'Kryptographie'),

  (v_itmathe, v_uid, 'Kombinatorik',
$C$Die **Kombinatorik** zählt Anordnungen und Auswahlen von Elementen.

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
- Anagramme von "ANNA": 4!/(2!·2!) = 6$C$,
   '["Kombinatorik","Wahrscheinlichkeit","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'Wahrscheinlichkeitsrechnung',
$C$**Wahrscheinlichkeit** P(A) gibt an, wie wahrscheinlich Ereignis A eintritt.
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
- Zufallsalgorithmen (Randomized Quicksort, Monte Carlo)$C$,
   '["Wahrscheinlichkeit","Statistik","Mathematik"]', 'Mathematik'),

  (v_itmathe, v_uid, 'P vs. NP Problem',
$C$Eines der größten ungelösten Probleme der Informatik.

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
- NP-schwere Probleme werden mit Heuristiken / Approximation gelöst$C$,
   '["Komplexität","Theorie","Informatik"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Endliche Automaten (DFA)',
$C$Ein **deterministischer endlicher Automat (DFA)** erkennt reguläre Sprachen.

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
- Textsuchalgorithmen$C$,
   '["Automaten","Theorie","Formale Sprachen"]', 'Theoretische Informatik');

  -- ════════════════════════════════════════════════════════════════
  -- AZURE
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_azure, v_uid, 'Microsoft Entra ID (Azure AD)',
$C$**Microsoft Entra ID** (früher Azure Active Directory) ist der cloud-basierte Identity & Access Management Service von Microsoft.

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

**Unterschied zu on-prem AD:** Entra ID ist cloud-native, kein LDAP/Kerberos, kein Gruppenrichtlinien-GPO$C$,
   '["Azure","Identity","Sicherheit","EntraID"]', 'Azure Grundlagen'),

  (v_azure, v_uid, 'Azure Virtual Machines',
$C$**Azure VMs** bieten IaaS (Infrastructure as a Service) — vollständige Kontrolle über OS, Software und Konfiguration.

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
- Images für schnelles Bereitstellen nutzen$C$,
   '["Azure","IaaS","VM","Compute"]', 'Compute'),

  (v_azure, v_uid, 'Azure Blob Storage',
$C$**Azure Blob Storage** ist Microsofts Object Storage für unstrukturierte Daten.

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

**Redundanz:** LRS → ZRS → GRS → GZRS (lokal bis geo-redundant)$C$,
   '["Azure","Storage","Blob","Cloud"]', 'Storage'),

  (v_azure, v_uid, 'Azure App Service',
$C$**Azure App Service** ist eine PaaS-Plattform für Web-Apps, REST-APIs und mobile Backends.

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

**Konfiguration:** App Settings (Env Vars), Connection Strings, TLS/SSL, Custom Domains$C$,
   '["Azure","PaaS","WebApp","Deployment"]', 'Compute'),

  (v_azure, v_uid, 'Azure Functions (Serverless)',
$C$**Azure Functions** = Serverless Compute. Code ausführen ohne Server verwalten zu müssen.

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

**Limits:** 10 Min Timeout (Consumption), 230 Sek HTTP-Timeout$C$,
   '["Azure","Serverless","Functions","FaaS"]', 'Compute'),

  (v_azure, v_uid, 'Azure Kubernetes Service (AKS)',
$C$**AKS** = verwaltetes Kubernetes in Azure. Die Control Plane wird von Azure kostenlos verwaltet.

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
- **KEDA:** Event-driven Autoscaling$C$,
   '["Azure","Kubernetes","AKS","Container"]', 'Container'),

  (v_azure, v_uid, 'Azure DevOps',
$C$**Azure DevOps** ist eine DevOps-Plattform mit integrierten Tools für den gesamten SDLC.

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
```$C$,
   '["Azure","DevOps","CI/CD","Pipeline"]', 'DevOps'),

  (v_azure, v_uid, 'Azure Key Vault',
$C$**Azure Key Vault** sichert Secrets, Schlüssel und Zertifikate zentral und sicher.

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
**Purge Protection:** Verhindert sofortiges endgültiges Löschen$C$,
   '["Azure","Sicherheit","KeyVault","Secrets"]', 'Sicherheit'),

  (v_azure, v_uid, 'RBAC in Azure',
$C$**RBAC** (Role-Based Access Control) steuert Zugriff auf Azure-Ressourcen über Rollen.

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
**Custom Roles:** Eigene Rollendefinitionen über JSON$C$,
   '["Azure","RBAC","Sicherheit","IAM"]', 'Sicherheit'),

  (v_azure, v_uid, 'Azure Monitor & Log Analytics',
$C$**Azure Monitor** ist die zentrale Plattform für Monitoring und Observability in Azure.

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

**Application Insights:** APM für Web-Apps (Request-Traces, Exceptions, Abhängigkeiten)$C$,
   '["Azure","Monitoring","Logging","Observability"]', 'Operations'),

  (v_azure, v_uid, 'Azure Virtual Network (VNet)',
$C$Ein **Virtual Network (VNet)** ist das private Netzwerk in Azure — isoliert und sicher.

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
- HTTP/HTTPS: 80/443$C$,
   '["Azure","Netzwerk","VNet","Sicherheit"]', 'Netzwerk'),

  (v_azure, v_uid, 'Azure Container Registry (ACR)',
$C$**Azure Container Registry (ACR)** ist eine private Docker-Registry in Azure.

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

**Zugriff:** Managed Identity (empfohlen), Admin-Konto, Service Principal$C$,
   '["Azure","Container","ACR","Docker","Registry"]', 'Container'),

  (v_azure, v_uid, 'Azure Cosmos DB',
$C$**Azure Cosmos DB** ist eine globally distributed, multi-model NoSQL Datenbank.

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

**Abrechnung:** RU/s (Request Units per Second)$C$,
   '["Azure","CosmosDB","NoSQL","Datenbank"]', 'Datenbanken'),

  (v_azure, v_uid, 'ARM Templates & Bicep',
$C$**Infrastructure as Code** für Azure: Ressourcen deklarativ definieren und reproduzierbar deployen.

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

**Alternativen:** Terraform (cloud-agnostisch), Pulumi (imperative Sprachen)$C$,
   '["Azure","IaC","ARM","Bicep","Infrastructure"]', 'DevOps');

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_azure, v_uid, 'Azure Entra ID (Azure AD)',
$C$**Azure Entra ID** (früher: Azure Active Directory) ist der cloudbasierte **Identity & Access Management**-Dienst von Microsoft.

## Kernkonzepte

**Tenant:** Deine Organisation in Azure — jede Firma hat einen eigenen Tenant mit eigener Domain.

**User & Groups:** Nutzer werden zentral verwaltet, Berechtigungen über Gruppen vergeben.

**App-Registrierungen:** Externe Apps erhalten eine Client-ID und können OAuth2/OIDC nutzen.

**Service Principal:** Maschinelles Konto für Apps, CI/CD-Pipelines oder Skripte.

**Managed Identity:** Azure-Service erhält automatisch eine Identität — kein Passwort nötig!

## Authentifizierungsfluss (OIDC)
```
App → Azure Entra ID → Access Token → API
```

## Rollen-Konzept

- **Global Administrator:** Vollzugriff auf Entra ID
- **User Administrator:** Nutzer verwalten
- **Owner/Contributor/Reader:** Azure-Ressource-Rollen (RBAC)

## Praktisch
```bash
# Azure CLI: Login
az login
# Service Principal erstellen
az ad sp create-for-rbac --name "mein-sp" --role Contributor
```

**Merke:** Entra ID = *Wer bist du?* (AuthN). Azure RBAC = *Was darfst du?* (AuthZ)$C$,
   '["Azure","Entra ID","Active Directory","Identity","IAM"]', 'Sicherheit'),

  (v_azure, v_uid, 'Azure Policy & Governance',
$C$**Azure Policy** erzwingt organisationsweite Regeln auf Ressourcen.

## Azure Policy

Regeln, die definieren was erlaubt ist:
- *Allowed locations* — Ressourcen nur in EU
- *Required tags* — jede Ressource braucht den Tag "CostCenter"
- *SKU restrictions* — nur bestimmte VM-Größen erlaubt

**Assignment:** Policy wird auf Subscription, Resource Group oder Ressource angewendet.

**Effect:**
| Effect | Bedeutung |
|--------|-----------|
| `deny` | Ressource wird abgelehnt |
| `audit` | Erlaubt, aber Warnung |
| `append` | Fehlende Felder ergänzen |
| `deployIfNotExists` | Auto-Deployment bei Fehlen |

## Management Groups
Hierarchie über Subscriptions:
```
Root Management Group
  └─ Produktion MG
       ├─ Subscription A
       └─ Subscription B
```
Policies vererben sich nach unten.

## Azure Blueprints
Pakete aus Policies + RBAC + ARM Templates — für reproduzierbare Umgebungen.

**Merke:** Policy = Leitplanken für die Cloud-Nutzung$C$,
   '["Azure","Policy","Governance","Compliance","Management Groups"]', 'Governance'),

  (v_azure, v_uid, 'Azure Monitor & Application Insights',
$C$**Azure Monitor** ist die zentrale Observability-Plattform in Azure.

## Drei Säulen der Observability

**1. Metrics** (Zahlen über die Zeit)
- CPU-Auslastung, RAM, Requests/Sekunde
- Im Azure Portal als Graphen sichtbar

**2. Logs** (strukturierte Ereignisse)
- Log Analytics Workspace: zentrale Ablage
- KQL (Kusto Query Language) zum Abfragen:
```kql
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
```

**3. Alerts** (Benachrichtigungen)
- Metriken oder Log-Abfragen lösen Alarme aus
- Aktionsgruppen: E-Mail, SMS, Webhook, Azure Function

## Application Insights
Speziell für **Applikations-Telemetrie**:
- Request/Response-Zeiten
- Abhängigkeiten (DB, externe APIs)
- Exceptions & Stack Traces
- User-Journeys (Trichter-Analyse)

```javascript
// App Insights SDK einbinden
appInsights.trackEvent({ name: 'UserLogin' });
```

**Merke:** Monitor = Infrastruktur. App Insights = deine App selbst.$C$,
   '["Azure","Monitor","Application Insights","Logging","Observability"]', 'Monitoring'),

  (v_azure, v_uid, 'Azure Functions (Serverless)',
$C$**Azure Functions** sind ereignisgesteuerte, serverlose Code-Bausteine — du zahlst nur für die tatsächliche Ausführung.

## Konzept

```
Trigger → Funktion → Output Binding
```

**Trigger-Typen:**
| Trigger | Wann |
|---------|------|
| HTTP | API-Aufruf |
| Timer | Zeitgesteuert (Cron) |
| Queue | Neue Nachricht in Queue |
| Blob | Neue Datei in Blob Storage |
| Event Hub | Stream-Ereignis |

## Beispiel (C#)
```csharp
[FunctionName("HelloWorld")]
public static async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req)
{
    return new OkObjectResult("Hello, World!");
}
```

## Hosting-Pläne

| Plan | Kaltstart | Skalierung | Kosten |
|------|-----------|------------|--------|
| Consumption | möglich | Auto | Pay-per-use |
| Premium | keiner | Auto | Monatlich |
| Dedicated | keiner | Manuell | App Service Plan |

## Bindings
Deklarative Ein-/Ausgaben ohne Verbindungscode:
```json
{ "type": "queueOutput", "name": "outQueue", "queueName": "myqueue" }
```

**Merke:** Serverless = kein Server-Management, nur Code$C$,
   '["Azure","Functions","Serverless","FaaS","Trigger"]', 'Compute'),

  (v_azure, v_uid, 'Azure App Service (PaaS)',
$C$**Azure App Service** ist eine **Platform-as-a-Service (PaaS)**-Lösung zum Hosten von Webanwendungen.

## Unterstützte Stacks
- .NET, .NET Core, Java, Node.js, Python, PHP, Ruby
- Docker Container (einzeln oder Compose)

## Deployment-Optionen
```bash
# Git-Deploy
git remote add azure https://...
git push azure main

# Azure CLI
az webapp up --name meine-app --runtime "PYTHON:3.11"

# ZIP-Deploy
az webapp deployment source config-zip --src app.zip
```

## Deployment Slots
- **Production** + **Staging** Slot
- Änderungen erst auf Staging testen → dann **swap** (ohne Downtime!)
- Rollback: nochmals swap

## Skalierung
- **Scale Up:** Größere Instanz (mehr CPU/RAM)
- **Scale Out:** Mehr Instanzen (horizontal)
- Auto-Scale basierend auf CPU, RAM, Requests

## App Service Plan
Definiert die Ressourcen: `F1` (kostenlos) → `P3V3` (Premium)

**Merke:** App Service = Managed Hosting; du kümmerst dich nur um den Code$C$,
   '["Azure","App Service","PaaS","Web App","Hosting"]', 'Compute'),

  (v_azure, v_uid, 'Azure Virtual Network (VNet)',
$C$Das **Azure Virtual Network (VNet)** ist das private Netzwerk für deine Azure-Ressourcen.

## Grundstruktur
```
VNet: 10.0.0.0/16
  ├─ Subnet Web:  10.0.1.0/24 (App Service, VMs)
  ├─ Subnet DB:   10.0.2.0/24 (Azure SQL, Cosmos)
  └─ Subnet GW:   10.0.3.0/28 (VPN Gateway)
```

## Kernkonzepte

**Subnets:** Unterteilungen des VNets — Ressourcen im selben Subnet kommunizieren direkt.

**Network Security Groups (NSG):** Firewall-Regeln für ein Subnet oder eine Netzwerkkarte:
```
Eingehend: Port 443 erlauben, alles andere ablehnen
Ausgehend: Port 1433 zur DB erlauben
```

**VNet Peering:** Zwei VNets verbinden (auch cross-region) — kein Gateway nötig.

**Private Endpoint:** Azure-Service (z.B. Storage) bekommt eine private IP im VNet — kein Internetrouting.

## VPN Gateway & ExpressRoute
- **VPN Gateway:** Verschlüsselter Tunnel zum On-Premise-Netz (über Internet)
- **ExpressRoute:** Dedizierte Privatleitung (höhere Bandbreite, kein Internet)

**Merke:** VNet = dein privates Azure-Netzwerk; NSG = deine Firewall-Regeln$C$,
   '["Azure","VNet","Networking","NSG","Subnet"]', 'Netzwerk'),

  (v_azure, v_uid, 'Azure Storage Account',
$C$**Azure Storage Account** bietet skalierbaren, hochverfügbaren Cloud-Speicher.

## Speicherdienste im Storage Account

| Dienst | Beschreibung | Typischer Einsatz |
|--------|-------------|-------------------|
| **Blob Storage** | Unstrukturierte Dateien | Bilder, Videos, Backups |
| **Table Storage** | NoSQL Key-Value | Logs, einfache Daten |
| **Queue Storage** | Nachrichten-Queue | Entkopplung von Services |
| **File Storage** | SMB/NFS Dateifreigabe | Legacy-Apps, Mounts |

## Blob Storage Tier

| Tier | Zugriffszeit | Kosten |
|------|-------------|--------|
| Hot | sofort | am teuersten |
| Cool | sofort | günstiger |
| Archive | Stunden | sehr günstig |

## Zugriff
```bash
# SAS-Token (Shared Access Signature)
az storage blob generate-sas --container-name mein-container \
  --name bild.jpg --permissions r --expiry 2025-12-31

# Upload
az storage blob upload --file ./bild.jpg --container-name mein-container
```

## Redundanz
- **LRS** — lokal redundant (3 Kopien, 1 Rechenzentrum)
- **ZRS** — zonenredundant (3 Zonen einer Region)
- **GRS** — georedundant (+ 2. Region)

**Merke:** Blob = Dateien, Queue = Nachrichten, Table = simple NoSQL, File = Netzlaufwerk$C$,
   '["Azure","Storage","Blob","Queue","Table"]', 'Storage'),

  (v_azure, v_uid, 'Azure SQL & Cosmos DB',
$C$Azure bietet **managed Datenbank-Dienste** — kein Server-Patch-Management nötig.

## Azure SQL Database
Vollständig verwaltetes **relationales** Datenbankservice (SQL Server-Engine):
```sql
-- Verbindung wie normales SQL Server
SELECT TOP 10 * FROM Orders WHERE Status = 'Pending'
```
- Automatisches Backup, Patching, HA
- **Elastic Pool:** Mehrere DBs teilen sich Ressourcen
- **Serverless:** Auto-Pause bei Inaktivität

## Azure Cosmos DB
**Globale, multi-model NoSQL-Datenbank:**
- Sub-10ms Latenz weltweit
- APIs: SQL (Core), MongoDB, Cassandra, Gremlin (Graph), Table

```json
// Dokument in Cosmos DB
{
  "id": "user-123",
  "name": "Max Mustermann",
  "partitionKey": "DE"
}
```

**Partition Key:** entscheidend für Performance — wähle ihn weise!

## Wann was?
| Szenario | Empfehlung |
|----------|-----------|
| Relationale Daten | Azure SQL |
| JSON-Dokumente | Cosmos DB (SQL API) |
| Globale Skalierung | Cosmos DB |
| MongoDB-Migration | Cosmos DB (Mongo API) |

**Merke:** SQL = relational & ACID; Cosmos = global, NoSQL, millisekunden-schnell$C$,
   '["Azure","SQL","Cosmos DB","NoSQL","Datenbank"]', 'Datenbank'),

  (v_azure, v_uid, 'Azure Key Vault',
$C$**Azure Key Vault** ist der sichere Tresor für Secrets, Schlüssel und Zertifikate.

## Was wird gespeichert?

| Typ | Beispiele |
|-----|----------|
| **Secrets** | Passwörter, Connection Strings, API Keys |
| **Keys** | Kryptographische Schlüssel (RSA, EC) |
| **Certificates** | TLS/SSL-Zertifikate |

## Zugriff

Prinzip: **Kein Passwort im Code** — stattdessen:
1. App hat eine **Managed Identity**
2. Key Vault gibt dieser Identity Berechtigung
3. App liest Secret zur Laufzeit

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://mein-vault.vault.azure.net", credential=credential)
secret = client.get_secret("DatenbankPasswort")
```

## App Settings Integration
```bash
# Referenz in App Service / Azure Functions:
@Microsoft.KeyVault(SecretUri=https://mein-vault.vault.azure.net/secrets/DbPass/)
```
App liest automatisch den aktuellen Wert — kein Neustart bei Rotation nötig!

**Merke:** Key Vault = dein sicherer Passwort-Manager für Azure-Apps$C$,
   '["Azure","Key Vault","Security","Secrets","Zertifikate"]', 'Sicherheit'),

  (v_azure, v_uid, 'Azure Service Bus & Event Hub',
$C$Zwei wichtige Messaging-Dienste in Azure — beide entkoppeln Services voneinander.

## Azure Service Bus (Message Queue / Topic)

**Queue:** Nachrichten werden genau einmal verarbeitet (Point-to-Point):
```
Producer → [Queue] → Consumer
```

**Topic + Subscriptions:** Nachrichten an mehrere Empfänger (Pub/Sub):
```
Producer → [Topic] → Sub A → Consumer A
                   → Sub B → Consumer B
```

**Einsatz:** Bestellsystem, Bezahlprozess, Workflows wo Reihenfolge wichtig ist.

**Features:** Dead Letter Queue, Sessions, Scheduled Messages, Duplicate Detection

## Azure Event Hub (Event Streaming)

Für **große Mengen** an Ereignissen (Telemetrie, Logs, IoT):
- Millions events/sec
- Retention: 1-7 Tage (oder länger)
- **Consumer Groups:** Mehrere unabhängige Reader

```
IoT-Geräte → Event Hub → Stream Analytics → Power BI
                       → Azure Function → Datenbank
```

**Partitionen:** Parallele Verarbeitung; Reihenfolge nur innerhalb einer Partition.

## Wann was?
| Szenario | Dienst |
|----------|--------|
| Bestellung verarbeiten | Service Bus Queue |
| Notification an mehrere | Service Bus Topic |
| IoT-Telemetrie | Event Hub |
| Log-Streaming | Event Hub |

**Merke:** Service Bus = Nachrichten; Event Hub = Ereignisströme$C$,
   '["Azure","Service Bus","Event Hub","Messaging","Pub-Sub"]', 'Integration'),

  (v_azure, v_uid, 'Azure Kubernetes Service (AKS)',
$C$**Azure Kubernetes Service (AKS)** ist der managed Kubernetes-Dienst in Azure.

## Warum AKS?
Microsoft übernimmt das **Control Plane** (Master-Nodes) kostenlos — du verwaltest nur die Worker Nodes.

## Cluster erstellen
```bash
# Cluster anlegen
az aks create \
  --resource-group meine-rg \
  --name mein-cluster \
  --node-count 3 \
  --enable-managed-identity

# kubectl konfigurieren
az aks get-credentials --resource-group meine-rg --name mein-cluster
```

## Azure-Integrationen

**Azure Container Registry (ACR):** Private Image Registry
```bash
az aks update --attach-acr mein-acr
```

**Azure Load Balancer:** Automatisch für `type: LoadBalancer` Services erstellt.

**Managed Identity:** Pods können Azure-Services (Key Vault, Storage) ohne Passwort nutzen.

**Azure Monitor:** Logs und Metrics automatisch in Log Analytics Workspace.

## Node Pools
```bash
# Zusätzlichen Node Pool hinzufügen (z.B. GPU-Nodes)
az aks nodepool add --cluster-name mein-cluster \
  --name gpupool --node-vm-size Standard_NC6
```

**Merke:** AKS = Kubernetes in Azure, Control Plane gratis, du verwaltest nur die Worker$C$,
   '["Azure","AKS","Kubernetes","Container","Managed Service"]', 'Container');

  -- ════════════════════════════════════════════════════════════════
  -- KUBERNETES
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_kubernetes, v_uid, 'Was ist Kubernetes?',
$C$**Kubernetes (K8s)** ist ein Open-Source-System zur **Orchestrierung** von Container-Workloads.

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

**Entstehung:** Von Google (Borg/Omega), 2014 open-source, seit 2016 bei CNCF$C$,
   '["Kubernetes","Container","Orchestrierung"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'Pod',
$C$Ein **Pod** ist die kleinste deploybare Einheit in Kubernetes — eine Gruppe von einem oder mehreren Containern.

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
**Status:** Pending → Running → Succeeded/Failed/CrashLoopBackOff$C$,
   '["Kubernetes","Pod","Container"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Deployment',
$C$Ein **Deployment** verwaltet eine Menge identischer Pods über ein ReplicaSet.

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
```$C$,
   '["Kubernetes","Deployment","Rolling Update"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Service',
$C$Ein **Service** stellt Pods unter einer stabilen IP/DNS-Adresse erreichbar (Pods kommen und gehen).

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
**Endpoints:** Service enthält dynamische Liste der Pod-IPs$C$,
   '["Kubernetes","Service","Networking"]', 'Netzwerk'),

  (v_kubernetes, v_uid, 'Ingress',
$C$**Ingress** steuert eingehenden HTTP/HTTPS-Traffic in den Cluster — ein externer Einstiegspunkt.

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
```$C$,
   '["Kubernetes","Ingress","Netzwerk","HTTP"]', 'Netzwerk'),

  (v_kubernetes, v_uid, 'ConfigMap & Secret',
$C$**ConfigMap** und **Secret** trennen Konfiguration vom Container-Image.

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

⚠️ Secrets sind nur base64, nicht verschlüsselt — für echte Sicherheit: Sealed Secrets oder External Secrets Operator$C$,
   '["Kubernetes","ConfigMap","Secret","Konfiguration"]', 'Konfiguration'),

  (v_kubernetes, v_uid, 'kubectl Grundbefehle',
$C$**kubectl** ist das CLI-Tool zur Steuerung von Kubernetes-Clustern.

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
```$C$,
   '["Kubernetes","kubectl","CLI","Commands"]', 'Tools'),

  (v_kubernetes, v_uid, 'Namespace',
$C$**Namespaces** partitionieren einen Kubernetes-Cluster in isolierte virtuelle Cluster.

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

⚠️ Namespaces sind KEIN Sicherheitsmerkmal — Netzwerk-Policies separat konfigurieren$C$,
   '["Kubernetes","Namespace","Organisation"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'Helm',
$C$**Helm** ist der Paketmanager für Kubernetes — wie apt/npm, aber für K8s-Manifeste.

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
```$C$,
   '["Kubernetes","Helm","Paketmanager","Tools"]', 'Tools'),

  (v_kubernetes, v_uid, 'StatefulSet & DaemonSet',
$C$**StatefulSet** und **DaemonSet** sind spezialisierte Workload-Typen.

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
```$C$,
   '["Kubernetes","StatefulSet","DaemonSet","Workloads"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Resource Limits & HPA',
$C$## Resource Requests & Limits

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
```$C$,
   '["Kubernetes","Resources","HPA","Autoscaling"]', 'Performance'),

  (v_kubernetes, v_uid, 'Persistent Volumes',
$C$Kubernetes abstrahiert Speicher über **PersistentVolume (PV)** und **PersistentVolumeClaim (PVC)**.

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
- `ReadWriteMany (RWX)` — viele Nodes, lesen+schreiben$C$,
   '["Kubernetes","Storage","PVC","Volumes"]', 'Storage');

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_kubernetes, v_uid, 'Kubernetes Namespaces',
$C$**Namespaces** unterteilen einen Kubernetes-Cluster in virtuelle Teilbereiche.

## Warum Namespaces?
- Isolierung von Teams, Projekten, Umgebungen
- `dev`, `staging`, `production` im selben Cluster
- Eigene Ressourcen-Quotas pro Namespace

## Standard-Namespaces
```bash
kubectl get namespaces
# NAME              STATUS
# default           Active   ← deine Ressourcen wenn kein Namespace angegeben
# kube-system       Active   ← Kubernetes-interne Komponenten
# kube-public       Active   ← öffentlich lesbar
# kube-node-lease   Active   ← Node-Heartbeats
```

## Namespace erstellen und nutzen
```bash
kubectl create namespace produktion

# Ressource in Namespace deployen
kubectl apply -f deployment.yaml -n produktion

# Standard-Namespace setzen
kubectl config set-context --current --namespace=produktion
```

## Manifest mit Namespace
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mein-pod
  namespace: produktion
```

## Ressourcen-Quotas
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    limits.memory: 8Gi
```

**Merke:** Namespaces = Virtuelle Cluster im Cluster; nicht für Node-Isolierung$C$,
   '["Kubernetes","Namespace","Isolation","Quota","Cluster"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'Kubernetes RBAC (Zugriffskontrolle)',
$C$**Role-Based Access Control (RBAC)** steuert, wer was im Kubernetes-Cluster darf.

## Konzepte

**Role** — Berechtigungen in einem Namespace:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: produktion
  name: pod-leser
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

**ClusterRole** — Berechtigungen cluster-weit (alle Namespaces).

**RoleBinding** — Bindet Role an User/ServiceAccount:
```yaml
kind: RoleBinding
metadata:
  name: pod-leser-binding
  namespace: produktion
subjects:
- kind: User
  name: "anna@example.com"
roleRef:
  kind: Role
  name: pod-leser
  apiGroup: rbac.authorization.k8s.io
```

## Wichtige Verbs
`get`, `list`, `watch`, `create`, `update`, `patch`, `delete`

## ServiceAccount
Jeder Pod hat einen ServiceAccount — die Identität des Pods für den Kubernetes-API-Server.

```bash
# Berechtigungen prüfen
kubectl auth can-i create pods --namespace=produktion --as=anna@example.com
```

**Merke:** RBAC = Wer (Subject) darf was (Verb) auf welchen Ressourcen?$C$,
   '["Kubernetes","RBAC","Security","Role","Zugriffskontrolle"]', 'Sicherheit'),

  (v_kubernetes, v_uid, 'ConfigMaps & Secrets',
$C$**ConfigMaps** und **Secrets** trennen Konfiguration vom Container-Image.

## ConfigMap — unkritische Konfiguration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "postgres.default.svc.cluster.local"
  LOG_LEVEL: "info"
  MAX_CONNECTIONS: "100"
```

### Im Pod verwenden
```yaml
env:
- name: DB_HOST
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: DATABASE_HOST
# Oder als Volume (Konfig-Dateien)
volumes:
- name: config-vol
  configMap:
    name: app-config
```

## Secret — sensible Daten (Base64-kodiert)

```bash
kubectl create secret generic db-secret \
  --from-literal=password=SuperGeheim123
```

```yaml
env:
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

**Wichtig:** Secrets sind in etcd nur Base64-kodiert (nicht verschlüsselt by default).
Für echte Sicherheit: Secrets verschlüsseln oder **External Secrets Operator** + Key Vault nutzen.

**Merke:** ConfigMap = .env-Datei; Secret = Passwort-Tresor (aber kein echter Vault!)$C$,
   '["Kubernetes","ConfigMap","Secret","Konfiguration","Environment"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'Kubernetes Ingress',
$C$**Ingress** ist der HTTP/HTTPS-Router für Kubernetes — leitet externen Traffic zu internen Services.

## Problem ohne Ingress
Ohne Ingress braucht jeder Service einen eigenen LoadBalancer (= eigene IP + Kosten).

## Ingress-Lösung
Ein Ingress-Controller (z.B. nginx, Traefik) nimmt alle HTTP-Anfragen entgegen und routet intern:

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
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
      - path: /shop
        pathType: Prefix
        backend:
          service:
            name: shop-service
            port:
              number: 80
  tls:
  - hosts: ["api.example.com"]
    secretName: tls-secret
```

## Ingress Controller installieren (nginx)
```bash
helm install ingress-nginx ingress-nginx/ingress-nginx
```

**Merke:** Ingress = Reverse Proxy + Router für HTTP/HTTPS im Cluster$C$,
   '["Kubernetes","Ingress","Networking","HTTP","Routing"]', 'Netzwerk'),

  (v_kubernetes, v_uid, 'Kubernetes Jobs & CronJobs',
$C$**Jobs** und **CronJobs** sind für Aufgaben die einmalig oder regelmäßig laufen sollen.

## Job — einmalige Aufgabe

Läuft bis zur Fertigstellung (im Gegensatz zu Deployments die ewig laufen):
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: datenbank-migration
spec:
  template:
    spec:
      containers:
      - name: migration
        image: mein-image:latest
        command: ["python", "migrate.py"]
      restartPolicy: OnFailure
  backoffLimit: 4       # max. 4 Versuche bei Fehler
  completions: 1        # 1 erfolgreicher Abschluss
  parallelism: 1        # 1 Pod gleichzeitig
```

## CronJob — regelmäßige Aufgabe

Wie Linux cron, aber als Kubernetes-Ressource:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"   # Täglich um 02:00 Uhr
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
          restartPolicy: OnFailure
```

## Cron-Syntax
`Minute Stunde Tag Monat Wochentag`
- `*/5 * * * *` — alle 5 Minuten
- `0 8 * * 1-5` — werktags um 8 Uhr

**Merke:** Job = einmalig bis Erfolg; CronJob = wiederkehrend nach Zeitplan$C$,
   '["Kubernetes","Job","CronJob","Batch","Zeitplanung"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Horizontal Pod Autoscaler (HPA)',
$C$Der **Horizontal Pod Autoscaler (HPA)** skaliert automatisch die Anzahl der Pods basierend auf Metriken.

## Wie funktioniert HPA?
```
Metrik (CPU/RAM/Custom) → HPA berechnet Ziel-Replicas → Deployment anpassen
```

Formel: $\text{Ziel-Replicas} = \lceil \text{Aktuelle Replicas} \times \frac{\text{Aktuelle Metrik}}{\text{Zielwert}} \rceil$

## Beispiel
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70   # Ziel: 70% CPU-Auslastung
```

## Voraussetzungen
- **Metrics Server** muss im Cluster laufen
- Pods müssen `resources.requests` definiert haben

```bash
kubectl get hpa
# NAME      REFERENCE       TARGETS   MINPODS   MAXPODS   REPLICAS
# web-hpa   Deployment/web  45%/70%   2         10        3
```

## Custom Metrics
HPA kann auch auf eigene Metriken reagieren (Requests/s, Queue-Länge) via Prometheus Adapter.

**Merke:** HPA = automatisch mehr Pods bei Last, weniger bei Leerlauf$C$,
   '["Kubernetes","HPA","Autoscaling","Skalierung","Metriken"]', 'Skalierung'),

  (v_kubernetes, v_uid, 'Kubernetes Helm (Paketmanager)',
$C$**Helm** ist der Paketmanager für Kubernetes — wie apt/npm, aber für K8s-Manifeste.

## Kernbegriffe

**Chart:** Paket mit allen K8s-Ressourcen einer Anwendung (Deployment, Service, Ingress, etc.)

**Release:** Eine installierte Instanz eines Charts

**Repository:** Sammlung von Charts (wie npm registry)

**Values:** Konfigurationsparameter die beim Install übergeben werden

## Typischer Workflow
```bash
# Repository hinzufügen
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Chart installieren
helm install mein-postgres bitnami/postgresql \
  --set auth.postgresPassword=geheim \
  --set primary.persistence.size=10Gi

# Releases anzeigen
helm list

# Upgrade
helm upgrade mein-postgres bitnami/postgresql --set image.tag=15.0

# Deinstallieren
helm uninstall mein-postgres
```

## Chart-Struktur
```
mein-chart/
├── Chart.yaml        # Metadaten (Name, Version)
├── values.yaml       # Standardwerte
└── templates/        # Jinja-ähnliche K8s-Templates
    ├── deployment.yaml
    ├── service.yaml
    └── _helpers.tpl
```

## Template-Beispiel
```yaml
replicas: {{ .Values.replicaCount }}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

**Merke:** Helm = "apt install" für Kubernetes; Values = deine Anpassungen$C$,
   '["Kubernetes","Helm","Paketmanager","Chart","Deployment"]', 'Tools'),

  (v_kubernetes, v_uid, 'Kubernetes Probes (Health Checks)',
$C$**Probes** teilen Kubernetes mit, ob ein Container gesund und bereit ist.

## Drei Typen

**Liveness Probe** — Ist der Container am Leben?
- Wenn fehlgeschlagen: Container wird neu gestartet

**Readiness Probe** — Ist der Container bereit für Traffic?
- Wenn fehlgeschlagen: Pod wird aus dem Service entfernt (kein Traffic), aber NICHT neugestartet

**Startup Probe** — Hat der Container erfolgreich gestartet?
- Für langsam startende Apps; Liveness/Readiness pausieren bis Startup erfolgreich

## Beispiel
```yaml
spec:
  containers:
  - name: api
    image: meine-api:1.0
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 10   # 10s warten vor erstem Check
      periodSeconds: 15         # alle 15s prüfen
      failureThreshold: 3       # 3 Fehler = Neustart
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    startupProbe:
      httpGet:
        path: /health
        port: 8080
      failureThreshold: 30      # 30 × 10s = 5min für Start
      periodSeconds: 10
```

## Probe-Typen
- `httpGet` — HTTP-Request
- `exec` — Befehl im Container
- `tcpSocket` — TCP-Verbindung

**Merke:** Liveness = lebt der Container? Readiness = darf er Traffic bekommen?$C$,
   '["Kubernetes","Probes","Health Check","Liveness","Readiness"]', 'Betrieb'),

  (v_kubernetes, v_uid, 'Kubernetes Resource Requests & Limits',
$C$**Requests** und **Limits** steuern den CPU- und RAM-Verbrauch von Pods.

## Konzept

**Request:** Minimum garantierter Ressourcen — Kubernetes-Scheduler nutzt dies zur Pod-Platzierung.

**Limit:** Maximum erlaubter Verbrauch — bei Überschreitung wird der Pod gedrosselt (CPU) oder beendet (RAM).

## Einheiten
- **CPU:** `1` = 1 vCore, `500m` = 0,5 vCore (m = Milli)
- **Memory:** `256Mi` = 256 Mebibyte, `1Gi` = 1 Gibibyte

## Beispiel
```yaml
resources:
  requests:
    cpu: "250m"      # garantiert 0,25 vCore
    memory: "256Mi"  # garantiert 256 MB
  limits:
    cpu: "1"         # max 1 vCore
    memory: "512Mi"  # max 512 MB → sonst OOMKilled!
```

## QoS-Klassen (Quality of Service)
| Klasse | Bedingung | Verhalten |
|--------|-----------|-----------|
| `Guaranteed` | requests == limits | Zuletzt beendet |
| `Burstable` | requests < limits | Mittlere Priorität |
| `BestEffort` | keine Angaben | Zuerst beendet |

## Warum wichtig?
- Ohne Requests: Pod kann überall landen, schlechte Performance
- Ohne Limits: Ein Pod kann den ganzen Node blockieren

**Merke:** Requests = Mindestgarantie; Limits = harte Obergrenze$C$,
   '["Kubernetes","Resources","CPU","Memory","Limits"]', 'Grundlagen'),

  (v_kubernetes, v_uid, 'kubectl — Wichtige Befehle',
$C$`kubectl` ist das Kommandozeilen-Tool zur Steuerung von Kubernetes-Clustern.

## Basis-Befehle

```bash
# Kontext / Cluster wechseln
kubectl config get-contexts
kubectl config use-context mein-cluster

# Ressourcen anzeigen
kubectl get pods                    # alle Pods im aktuellen Namespace
kubectl get pods -n produktion      # Namespace angeben
kubectl get pods -A                 # alle Namespaces
kubectl get all                     # alles anzeigen

# Details anzeigen
kubectl describe pod mein-pod
kubectl describe deployment mein-deployment

# Logs
kubectl logs mein-pod
kubectl logs mein-pod -c mein-container   # bei mehreren Containern
kubectl logs -f mein-pod                  # follow (live)

# In Container einsteigen
kubectl exec -it mein-pod -- /bin/sh
kubectl exec -it mein-pod -c api -- bash
```

## Deployment-Befehle
```bash
kubectl apply -f manifest.yaml     # erstellen/aktualisieren
kubectl delete -f manifest.yaml    # löschen
kubectl delete pod mein-pod        # direkt löschen

kubectl rollout status deployment/web-app
kubectl rollout history deployment/web-app
kubectl rollout undo deployment/web-app   # Rollback!
kubectl scale deployment web-app --replicas=5
```

## Nützliche Shortcuts
```bash
# Port-Forwarding (lokal testen)
kubectl port-forward pod/mein-pod 8080:80

# Ressourcen beobachten
kubectl get pods -w   # watch (live updates)

# YAML einer Ressource ausgeben
kubectl get deployment web-app -o yaml
```

**Merke:** `kubectl get`, `describe`, `logs`, `exec` — die vier wichtigsten Befehle$C$,
   '["Kubernetes","kubectl","CLI","Befehle","Tooling"]', 'Tools');

  -- ════════════════════════════════════════════════════════════════
  -- DOCKER
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_docker, v_uid, 'Was ist Docker?',
$C$**Docker** ist eine Plattform zum Erstellen, Verteilen und Ausführen von **Containern**.

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
- Microservices-Architektur$C$,
   '["Docker","Container","Grundlagen"]', 'Grundlagen'),

  (v_docker, v_uid, 'Dockerfile',
$C$Das **Dockerfile** ist die Bauanleitung für ein Docker-Image.

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
| `USER` | Als welcher User ausführen |$C$,
   '["Docker","Dockerfile","Build","Image"]', 'Grundlagen'),

  (v_docker, v_uid, 'docker build & run',
$C$**Grundlegende Docker-Befehle für Build und Run.**

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
```$C$,
   '["Docker","CLI","Build","Run"]', 'Tools'),

  (v_docker, v_uid, 'Docker Compose',
$C$**Docker Compose** definiert und startet Multi-Container-Anwendungen deklarativ.

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
```$C$,
   '["Docker","Compose","Multi-Container","DevOps"]', 'Tools'),

  (v_docker, v_uid, 'Volumes & Bind Mounts',
$C$Docker hat drei Möglichkeiten, Daten persistent zu speichern.

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
| Einsatz | Prod-Daten | Dev (Hot Reload) | Temp-Daten |$C$,
   '["Docker","Volumes","Storage","Persistenz"]', 'Storage'),

  (v_docker, v_uid, 'Multi-Stage Build',
$C$**Multi-Stage Builds** reduzieren die finale Image-Größe massiv durch mehrere FROM-Stufen.

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
```$C$,
   '["Docker","Multi-Stage","Optimierung","Build"]', 'Best Practices'),

  (v_docker, v_uid, 'ENTRYPOINT vs CMD',
$C$Beide definieren was beim `docker run` ausgeführt wird — aber unterschiedlich.

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
```$C$,
   '["Docker","ENTRYPOINT","CMD","Dockerfile"]', 'Grundlagen'),

  (v_docker, v_uid, 'Docker Netzwerk',
$C$Docker bietet verschiedene **Netzwerk-Modi** für Container-Kommunikation.

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
```$C$,
   '["Docker","Netzwerk","Networking","Bridge"]', 'Netzwerk'),

  (v_docker, v_uid, '.dockerignore & Image-Optimierung',
$C$**.dockerignore** verhindert, dass unnötige Dateien ins Image gelangen.

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
5. **Layer-Caching nutzen:** Selten ändernde Dateien zuerst kopieren$C$,
   '["Docker","Optimierung","Security","Best Practices"]', 'Best Practices'),

  (v_docker, v_uid, 'Docker Health Check',
$C$**Health Checks** überwachen ob ein Container korrekt funktioniert.

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

**Kubernetes ignoriert Docker Health Checks** — dort werden `livenessProbe` und `readinessProbe` verwendet$C$,
   '["Docker","Health Check","Monitoring","Produktion"]', 'Operations');

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_docker, v_uid, 'Docker Netzwerk-Typen',
$C$Docker bietet verschiedene **Netzwerk-Treiber** um zu steuern, wie Container kommunizieren.

## Bridge (Standard)
Isoliertes privates Netzwerk auf dem Host:
```bash
# Standard: docker0 Bridge
docker run --network bridge nginx

# Eigenes Bridge-Netzwerk (empfohlen!)
docker network create mein-netz
docker run --network mein-netz --name api api:latest
docker run --network mein-netz --name db postgres:15
# api kann db per Name erreichen: ping db
```

**Vorteil eigener Bridge:** DNS-Auflösung per Container-Namen!

## Host
Container teilt Netzwerk-Stack direkt mit dem Host:
```bash
docker run --network host nginx
# nginx läuft auf Port 80 des Hosts direkt
```
**Vorteil:** Maximale Performance. **Nachteil:** Keine Isolierung.

## None
Kein Netzwerk — maximale Isolierung:
```bash
docker run --network none mein-sicherheits-job
```

## Overlay (Docker Swarm)
Netzwerk über mehrere Docker-Hosts — für Multi-Host-Kommunikation.

## Wichtige Befehle
```bash
docker network ls
docker network inspect mein-netz
docker network connect mein-netz laufender-container
docker network disconnect mein-netz laufender-container
```

**Merke:** Eigenes Bridge-Netzwerk nutzen → Container sprechen per Name miteinander$C$,
   '["Docker","Netzwerk","Bridge","Network","Kommunikation"]', 'Netzwerk'),

  (v_docker, v_uid, 'Docker Volumes vs Bind Mounts',
$C$Daten in Containern sind **flüchtig** — sie verschwinden wenn der Container gelöscht wird. Volumes und Bind Mounts lösen das.

## Docker Volumes (empfohlen)

Von Docker verwaltet, liegen in `/var/lib/docker/volumes/`:
```bash
# Volume erstellen
docker volume create meine-daten

# Volume einbinden
docker run -v meine-daten:/app/data postgres:15

# Volume-Inhalt anzeigen
docker run --rm -v meine-daten:/data alpine ls /data

# Volumes auflisten / löschen
docker volume ls
docker volume rm meine-daten
docker volume prune   # alle ungenutzten löschen
```

## Bind Mounts
Verzeichnis vom Host direkt in Container einbinden:
```bash
# Absoluter Pfad vom Host
docker run -v /home/max/code:/app -p 3000:3000 node:20

# Relative Pfad (PowerShell)
docker run -v ${PWD}:/app -p 3000:3000 node:20
```
**Vorteil:** Ideal für Entwicklung — Datei-Änderungen sofort im Container sichtbar.

## Vergleich
| Merkmal | Volume | Bind Mount |
|---------|--------|------------|
| Verwaltung | Docker | Du |
| Portabilität | Hoch | Niedrig |
| Performance | Besser (Linux) | Vergleichbar |
| Einsatz | Produktion, DBs | Entwicklung |

**Merke:** Volumes für Produktion (DB-Daten), Bind Mounts für Entwicklung (Code-Hot-Reload)$C$,
   '["Docker","Volumes","Bind Mount","Persistenz","Datenspeicherung"]', 'Storage'),

  (v_docker, v_uid, 'Docker Multi-Stage Build',
$C$**Multi-Stage Builds** erzeugen schlanke Produktions-Images — nur das Nötigste landet im finalen Image.

## Problem ohne Multi-Stage
Ein Node.js-Build-Image enthält npm, node_modules, Quellcode, Tests — alles unnötig in Produktion.

## Lösung: Mehrere FROM-Stufen
```dockerfile
# ── Stage 1: Build ──────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci                    # alle Dependencies inkl. devDeps
COPY . .
RUN npm run build             # kompiliert TypeScript → dist/

# ── Stage 2: Production ─────────────────────────
FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev         # NUR production dependencies
COPY --from=builder /app/dist ./dist   # nur das Build-Artefakt
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

## Ergebnis
| Image | Größe |
|-------|-------|
| Ohne Multi-Stage | ~800 MB |
| Mit Multi-Stage | ~120 MB |

## Build-Argumente
```bash
# Nur bestimmte Stage bauen
docker build --target builder -t mein-app:builder .
# Finale Stage
docker build -t mein-app:prod .
```

**Merke:** Multi-Stage = kleinere Images, schnellere Deployments, weniger Angriffsfläche$C$,
   '["Docker","Multi-Stage","Build","Optimierung","Image"]', 'Best Practices'),

  (v_docker, v_uid, 'Docker Compose — Netzwerke & Abhängigkeiten',
$C$Docker Compose verwaltet automatisch Netzwerke zwischen Services.

## Automatisches Netzwerk
Compose erstellt ein Standard-Bridge-Netzwerk für alle Services im File — sie sprechen per Servicename:

```yaml
services:
  api:
    build: ./api
    # Kann "db" per Name erreichen!
    environment:
      DATABASE_URL: postgres://postgres:pass@db:5432/mydb

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: pass

  redis:
    image: redis:7-alpine
```

## Abhängigkeiten
```yaml
services:
  api:
    depends_on:
      db:
        condition: service_healthy  # warten bis DB healthy
  db:
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
      retries: 5
```

## Eigene Netzwerke
```yaml
networks:
  frontend:
  backend:

services:
  nginx:
    networks: [frontend, backend]  # beide Netzwerke
  api:
    networks: [backend]
  db:
    networks: [backend]            # nginx kann nicht direkt auf db!
```

## Nützliche Befehle
```bash
docker compose up -d        # im Hintergrund starten
docker compose logs -f api  # Logs eines Services
docker compose ps           # Status aller Services
docker compose down -v      # stoppen + Volumes löschen
docker compose exec api sh  # in Service-Container einsteigen
```

**Merke:** Servicename = Hostname; depends_on + healthcheck für korrekte Startreihenfolge$C$,
   '["Docker","Compose","Netzwerk","Service Discovery","Abhängigkeiten"]', 'Tools'),

  (v_docker, v_uid, 'Dockerfile Best Practices',
$C$Gute Dockerfiles erzeugen **kleine**, **sichere** und **cacheable** Images.

## Layer-Caching verstehen
Jede `RUN`, `COPY`, `ADD`-Zeile = neuer Layer. Cache wird ungültig wenn sich etwas ändert:
```dockerfile
# SCHLECHT: Jede Code-Änderung installiert npm neu
COPY . .
RUN npm ci

# GUT: Dependencies erst kopieren (ändert sich selten)
COPY package*.json ./
RUN npm ci              # bleibt im Cache bis package.json sich ändert
COPY . .                # Quellcode danach
```

## Schlanke Base-Images
```dockerfile
# SCHLECHT: zu groß
FROM node:20

# GUT: Alpine-basiert (~5x kleiner)
FROM node:20-alpine

# NOCH BESSER: Distroless (nur Runtime, kein Shell!)
FROM gcr.io/distroless/nodejs:20
```

## Sicherheit
```dockerfile
# Nicht als root laufen
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Spezifische Versionen pinnen (keine :latest in Produktion)
FROM node:20.11.1-alpine3.19

# .dockerignore nutzen
# → node_modules, .env, .git nicht ins Image kopieren
```

## .dockerignore
```
node_modules/
.env
.git/
*.log
dist/
```

## Zusammenfassung
1. Kleine Base-Images (alpine/distroless)
2. Layer-Reihenfolge optimieren (selten änderndes zuerst)
3. Nicht als root laufen
4. .dockerignore pflegen
5. Spezifische Tags pinnen
6. Multi-Stage für Build-Artefakte

**Merke:** Ein gutes Dockerfile ist klein, deterministisch und nicht-root$C$,
   '["Docker","Best Practices","Dockerfile","Sicherheit","Optimierung"]', 'Best Practices'),

  (v_docker, v_uid, 'Docker Security Grundlagen',
$C$Container sind **keine VMs** — sie teilen den Kernel des Hosts. Sicherheit ist wichtig!

## Risiken

**Root-Container:** Standard ist root — wenn der Container kompromittiert wird, ist der Host gefährdet.
```dockerfile
# Lösung: Non-root User
USER 1001
```

**Privileged Mode:** Gibt dem Container fast alle Kernel-Capabilities:
```bash
# Nur wenn wirklich nötig!
docker run --privileged mein-container
```

## Capabilities
Linux-Kernel-Capabilities einzeln steuern:
```bash
docker run \
  --cap-drop ALL \           # alle Capabilities entfernen
  --cap-add NET_BIND_SERVICE \  # nur diese eine erlauben
  nginx
```

## Read-Only Filesystem
```bash
docker run --read-only \
  --tmpfs /tmp \             # nur /tmp ist schreibbar
  mein-app
```

## Image-Scanning
```bash
# Docker Scout (integriert)
docker scout cves mein-image:latest

# Trivy (Open Source)
trivy image mein-image:latest
```

## Rootless Docker
Docker Daemon als nicht-root User laufen lassen — isoliert Host besser.

## Checkliste
- Non-root User im Dockerfile
- Minimale Base-Images
- Image regelmäßig scannen
- Secrets nicht in ENV-Variablen (Key Vault nutzen)
- Read-only Filesystem wo möglich

**Merke:** Least Privilege Prinzip: so wenig Rechte wie nötig$C$,
   '["Docker","Security","Sicherheit","Capabilities","Rootless"]', 'Sicherheit'),

  (v_docker, v_uid, 'Docker Logs & Debugging',
$C$Effektives Debugging ist entscheidend wenn Container-Anwendungen nicht funktionieren.

## Logs lesen
```bash
# Logs eines Containers
docker logs mein-container

# Mit Zeitstempeln
docker logs --timestamps mein-container

# Nur letzte 50 Zeilen
docker logs --tail 50 mein-container

# Live-Logs (follow)
docker logs -f mein-container

# Logs seit Zeitpunkt
docker logs --since 1h mein-container
docker logs --since 2024-01-15T10:00:00 mein-container
```

## Container untersuchen
```bash
# In laufenden Container einsteigen
docker exec -it mein-container /bin/sh

# Einzelnen Befehl ausführen
docker exec mein-container ls /app

# Prozesse im Container anzeigen
docker top mein-container

# Ressourcenverbrauch live
docker stats
docker stats mein-container
```

## Container inspizieren
```bash
# Alle Details als JSON
docker inspect mein-container

# Spezifische Felder (Go-Template)
docker inspect --format='{{.State.Status}}' mein-container
docker inspect --format='{{.NetworkSettings.IPAddress}}' mein-container

# Dateisystem-Änderungen anzeigen
docker diff mein-container
```

## Gestoppte Container debuggen
```bash
# Gestoppte Container anzeigen
docker ps -a

# Container-Logs nach Crash
docker logs --tail 100 mein-container

# Image mit anderem Entrypoint starten
docker run --entrypoint /bin/sh mein-image:latest
```

**Merke:** `docker logs -f` für live, `docker exec -it ... sh` für interaktives Debuggen$C$,
   '["Docker","Debugging","Logs","Troubleshooting","Betrieb"]', 'Operations');

  -- ════════════════════════════════════════════════════════════════
  -- SCRUM
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_scrum, v_uid, 'Scrum Framework Überblick',
$C$**Scrum** ist ein agiles Framework für die Entwicklung und Auslieferung komplexer Produkte.

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

**Scrum Guide:** Offizielle Referenz unter scrumguides.org (kostenlos)$C$,
   '["Scrum","Agile","Framework","Überblick"]', 'Grundlagen'),

  (v_scrum, v_uid, 'Sprint',
$C$Ein **Sprint** ist ein festes Zeitfenster (1–4 Wochen), in dem ein potenziell auslieferbares Increment entsteht.

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
- Länger = mehr Planungssicherheit, aber träger$C$,
   '["Scrum","Sprint","Zeitbox","Iteration"]', 'Events'),

  (v_scrum, v_uid, 'Product Backlog',
$C$Der **Product Backlog** ist eine geordnete Liste aller bekannten Anforderungen an das Produkt.

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
- Max. 10% der Sprint-Kapazität$C$,
   '["Scrum","Backlog","Anforderungen","PO"]', 'Artefakte'),

  (v_scrum, v_uid, 'Sprint Backlog',
$C$Der **Sprint Backlog** ist der Plan für den aktuellen Sprint.

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
| Zeitraum | Langfristig | Aktueller Sprint |$C$,
   '["Scrum","Sprint Backlog","Planung","Board"]', 'Artefakte'),

  (v_scrum, v_uid, 'Increment',
$C$Das **Increment** ist das Ergebnis jedes Sprints — eine konkret nutzbare Produktversion.

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
✅ PO entscheidet ob deployed wird — Increment muss aber auslieferbereit sein$C$,
   '["Scrum","Increment","Lieferung","Qualität"]', 'Artefakte'),

  (v_scrum, v_uid, 'Product Owner (Rolle)',
$C$Der **Product Owner (PO)** maximiert den Wert des Produkts und des Development Teams.

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
- Verfügbar für Fragen während des Sprints$C$,
   '["Scrum","Product Owner","Rolle","Backlog"]', 'Rollen'),

  (v_scrum, v_uid, 'Scrum Master (Rolle)',
$C$Der **Scrum Master** dient dem Scrum Team und der Organisation bei der Einführung von Scrum.

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

**Führungsstil:** Servant Leadership — führen durch Dienen, nicht durch Autorität$C$,
   '["Scrum","Scrum Master","Rolle","Coaching","Agile"]', 'Rollen'),

  (v_scrum, v_uid, 'Development Team (Rolle)',
$C$Das **Development Team** (in Scrum Guide 2020: einfach Teil des "Scrum Teams") erstellt das Increment.

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
- Ob ein Increment released wird (PO)$C$,
   '["Scrum","Development Team","Selbstorganisation","Rollen"]', 'Rollen'),

  (v_scrum, v_uid, 'Sprint Planning',
$C$**Sprint Planning** eröffnet jeden Sprint. Das Scrum Team plant gemeinsam.

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

**Ergebnis:** Sprint Goal + Sprint Backlog$C$,
   '["Scrum","Sprint Planning","Events","Planung"]', 'Events'),

  (v_scrum, v_uid, 'Daily Scrum',
$C$Das **Daily Scrum** ist ein tägliches 15-Minuten-Meeting für das Development Team.

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
- Unnötige weitere Meetings reduzieren$C$,
   '["Scrum","Daily Scrum","Stand-Up","Events"]', 'Events'),

  (v_scrum, v_uid, 'Sprint Review',
$C$Die **Sprint Review** findet am Ende jedes Sprints statt — das Scrum Team zeigt die Ergebnisse.

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

**Wichtig:** Das Increment wird vorgeführt, nicht beschrieben$C$,
   '["Scrum","Sprint Review","Stakeholder","Events","Demo"]', 'Events'),

  (v_scrum, v_uid, 'Sprint Retrospektive',
$C$Die **Sprint Retrospektive** ist die Selbstreflexion des Scrum Teams.

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
- Retro: Prozess (Wie haben wir gearbeitet?)$C$,
   '["Scrum","Retrospektive","Verbesserung","Events","Teamarbeit"]', 'Events'),

  (v_scrum, v_uid, 'Definition of Done (DoD)',
$C$Die **Definition of Done (DoD)** beschreibt, wann ein Increment als fertig gilt.

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

**Wenn DoD nicht erfüllt:** PBI gehört NICHT ins Increment, kommt zurück in Backlog$C$,
   '["Scrum","DoD","Qualität","Artefakte"]', 'Qualität'),

  (v_scrum, v_uid, 'User Story',
$C$Eine **User Story** beschreibt eine Anforderung aus der Nutzerperspektive.

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

**Epics:** Zu große Stories → werden in kleinere User Stories aufgeteilt$C$,
   '["Scrum","User Story","Anforderungen","INVEST"]', 'Anforderungen'),

  (v_scrum, v_uid, 'Story Points & Schätzung',
$C$**Story Points** sind eine relative Maßeinheit für den Aufwand einer User Story.

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

**Velocity:** Durchschnittliche Story Points pro Sprint → Sprint-Kapazität planen$C$,
   '["Scrum","Story Points","Schätzung","Planning Poker"]', 'Planung'),

  (v_scrum, v_uid, 'Velocity & Burndown Chart',
$C$## Velocity
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
Zeigt **fertiggestellte Arbeit** (statt verbleibende) + Total Scope$C$,
   '["Scrum","Velocity","Burndown","Metriken"]', 'Metriken'),

  (v_scrum, v_uid, 'Backlog Refinement',
$C$**Backlog Refinement** (früher Grooming) ist das kontinuierliche Verfeinern des Product Backlogs.

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
- Scrum Master als Facilitator$C$,
   '["Scrum","Backlog Refinement","Grooming","Planung"]', 'Planung'),

  (v_scrum, v_uid, 'Technical Debt & Spike',
$C$## Technical Debt (Technische Schulden)
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
- Ergebnis des Spikes = neues PBI oder Schätzung$C$,
   '["Scrum","Technical Debt","Spike","Qualität"]', 'Qualität'),

  (v_scrum, v_uid, 'Scrum of Scrums & Skalierung',
$C$Scrum funktioniert optimal für ein Team. Für größere Organisationen gibt es Skalierungsframeworks.

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
- Squads (Teams), Tribes (Abteilungen), Chapters (Fachbereiche), Guilds (Communities)$C$,
   '["Scrum","Skalierung","SAFe","LeSS","Nexus"]', 'Skalierung');

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_scrum, v_uid, 'User Story Format',
$C$Eine **User Story** beschreibt eine Funktion aus Nutzerperspektive.

## Das Format

> Als **[Rolle]** möchte ich **[Funktion]**, damit **[Nutzen]**.

## Beispiele
- Als *Kunde* möchte ich *meine Bestellung verfolgen*, damit *ich weiß, wann sie ankommt*.
- Als *Administrator* möchte ich *Nutzer deaktivieren können*, damit *keine unbefugten Zugriffe entstehen*.
- Als *Entwickler* möchte ich *eine CI-Pipeline haben*, damit *Fehler früh gefunden werden*.

## Epic vs. Story vs. Task
```
Epic (groß, ≥1 Sprint)
  └─ User Story (1 Sprint passt)
        └─ Task (Stunden, technisch)
```

**Epic:** "Als Nutzer möchte ich mich registrieren und einloggen können."
**Story:** "Als Nutzer möchte ich mich per E-Mail registrieren, damit ich ein Konto erstelle."
**Task:** "Registrierungsformular UI implementieren"

## Gute User Stories: INVEST
| Buchstabe | Bedeutung |
|-----------|-----------|
| **I**ndependent | Unabhängig lieferbar |
| **N**egotiable | Details verhandelbar |
| **V**aluable | Wert für Nutzer/Kunde |
| **E**stimable | Schätzbar |
| **S**mall | Klein genug für Sprint |
| **T**estable | Testbar mit Akzeptanzkriterien |

**Merke:** User Stories = Anforderungen aus Nutzersicht, NICHT technische Specs$C$,
   '["Scrum","User Story","INVEST","Format","Anforderungen"]', 'Grundlagen'),

  (v_scrum, v_uid, 'Akzeptanzkriterien & Definition of Ready',
$C$**Akzeptanzkriterien** definieren, wann eine Story *fertig und akzeptiert* ist.

## Akzeptanzkriterien

Jede User Story braucht klare Testbedingungen:

**Format: Given-When-Then (Gherkin)**
```
Gegeben dass ein Nutzer eingeloggt ist
Wenn er auf "Bestellung aufgeben" klickt
Dann wird die Bestellung gespeichert
  Und er erhält eine Bestätigungs-E-Mail
  Und der Warenkorb wird geleert
```

**Alternativ:** Checkliste
- [ ] E-Mail-Validierung zeigt Fehlermeldung bei falscher Adresse
- [ ] Passwort muss mind. 8 Zeichen haben
- [ ] Login-Button deaktiviert während Request läuft

## Definition of Ready (DoR)
Kriterien, bevor eine Story ins Sprint Planning darf:
- User Story im korrekten Format
- Akzeptanzkriterien vorhanden
- Abhängigkeiten geklärt
- Story geschätzt (Story Points)
- UX-Design vorhanden (wenn nötig)
- Keine offenen Fragen

**Merke:** DoR = Story ist *bereit für Sprint*; DoD = Story ist *fertig und auslieferbar*$C$,
   '["Scrum","Akzeptanzkriterien","Definition of Ready","DoR","Testing"]', 'Qualität'),

  (v_scrum, v_uid, 'Story Points & Velocity',
$C$**Story Points** sind eine relative Maßeinheit für den Aufwand einer User Story.

## Was sind Story Points?

Kein Zeitmaß! Story Points messen:
- Komplexität
- Risiko / Unsicherheit
- Menge der Arbeit

## Fibonacci-Skala
Üblich: `1, 2, 3, 5, 8, 13, 21, 40, 100`

Exponentiell, weil Unsicherheit bei großen Aufgaben wächst.

## Planning Poker
1. Jeder schätzt heimlich (Karten)
2. Alle decken gleichzeitig auf
3. Ausreißer diskutieren ihren Standpunkt
4. Erneut schätzen bis Konsens

**Ziel:** Gemeinsames Verständnis der Story, nicht exakte Zeitschätzung!

## Velocity

Durchschnittliche Story Points pro Sprint:
$$V = \frac{\sum \text{abgeschlossene Story Points}}{\text{Anzahl Sprints}}$$

**Beispiel:** Team schließt 3 Sprints mit 34, 38, 36 Punkten ab:
$$V = \frac{34 + 38 + 36}{3} = 36 \text{ Points/Sprint}$$

## Forecast mit Velocity
Backlog hat 180 Punkte → $\frac{180}{36} = 5$ Sprints bis Fertig.

**Merke:** Story Points = Relative Schätzung; Velocity = Team-Leistung über Zeit$C$,
   '["Scrum","Story Points","Velocity","Schätzung","Planning Poker"]', 'Planung'),

  (v_scrum, v_uid, 'Burndown Chart & Burnup Chart',
$C$**Burndown** und **Burnup Charts** visualisieren den Fortschritt im Sprint oder Release.

## Sprint Burndown Chart

X-Achse: Tage im Sprint | Y-Achse: verbleibende Story Points

```
40 |●
35 | ╲   ← Ideal-Linie
30 |  ●╲
25 |   ╲ ●
20 |    ╲  ●
15 |     ╲   ● ← Tatsächlich (langsamer)
10 |      ╲
 5 |       ╲
 0 |________╲___________
   Tag1 2 3 4 5 6 7 8 9 10
```

**Ideal-Linie:** Gleichmäßiger Abbau der Punkte.
**Abweichungen:** Sprint wird nicht vollständig fertig wenn Linie über Null bleibt.

## Burnup Chart
Zeigt *abgeschlossene* Arbeit (steigt von 0 nach oben) + Gesamtumfang:
- Besser sichtbar wenn Scope wächst (Gesamtlinie steigt)
- Burndown: totaler Scope ändert sich unsichtbar

## Release Burndown
Über mehrere Sprints: Wann ist das Release fertig?

**Merke:** Burndown = wie viel übrig? Burnup = wie viel geschafft? (+ Scope-Änderungen sichtbar)$C$,
   '["Scrum","Burndown","Burnup","Fortschritt","Metriken"]', 'Metriken'),

  (v_scrum, v_uid, 'Scrum Anti-Patterns',
$C$**Anti-Patterns** sind häufige Fehler bei der Scrum-Einführung.

## Top Anti-Patterns

**Mini-Waterfall (Scrumfall)**
Sprint-Phasen wie Wasserfall: "Woche 1 Design, Woche 2 Dev, Woche 3 Test"
→ Kein potenziell auslieferbares Inkrement am Sprint-Ende

**Daily Scrum als Status-Meeting**
Product Owner fragt jeden: "Was hast du gestern gemacht?"
→ Kein Austausch, keine Hindernisse identifiziert

**Sprint Scope creep**
Neue Anforderungen werden mitten im Sprint hinzugefügt
→ Scrum schützt das Team vor Unterbrechungen; Neues geht ins Backlog

**Proxy Product Owner**
PO hat keine Entscheidungsbefugnis, muss alles eskalieren
→ Team blockiert, kein schnelles Feedback möglich

**Keine echte Definition of Done**
Stories werden als fertig markiert ohne Tests, Deployment, Doku
→ "Technische Schuld" häuft sich an

**Backlog ist eine Aufgabenliste**
Tasks statt User Stories, keine Priorisierung nach Wert
→ Kein Kundenfokus

**Sprint Review ohne echte Stakeholder**
Nur internes Team zeigt Ergebnisse → kein Kundenfeedback

**Merke:** Scrum scheitert meist an Menschen und Kultur, nicht am Prozess$C$,
   '["Scrum","Anti-Pattern","Fehler","Einführung","Kultur"]', 'Qualität'),

  (v_scrum, v_uid, 'Technische Schulden in Scrum',
$C$**Technische Schulden (Technical Debt)** entstehen wenn schnelle Lösungen langfristige Wartbarkeit opfern.

## Was sind Technische Schulden?

> "Technische Schulden sind der zukünftige Mehraufwand, der durch eine jetzt getroffene suboptimale Lösung entsteht."

Wie finanzielle Schulden: schnell aufgenommen, teuer zurückzuzahlen.

## Arten
- **Absichtlich:** "Wir hacken das jetzt, refactorn später" (oft wird "später" nie)
- **Unabsichtlich:** Schlechte Entscheidung ohne es zu wissen
- **Bit-Rot:** Gut implementiert, aber durch Änderungen überholt

## Technische Schulden in Scrum managen

**Option 1: % der Sprint-Kapazität reservieren**
```
Sprint-Kapazität: 40 Story Points
Neu-Features: 32 Punkte (80%)
Tech-Schulden: 8 Punkte (20%)
```

**Option 2: Refactoring in DoD aufnehmen**
Keine Story ohne sauberen Code als fertig markieren.

**Option 3: Explizit im Backlog**
Tech-Schulden als eigene Backlog-Items (technische Stories).

## Definition of Done gegen Schulden
```
✓ Code reviewed
✓ Unit Tests vorhanden (>80% Coverage)
✓ Keine kritischen SonarQube-Warnungen
✓ Auf Staging deployt und getestet
```

**Merke:** Technische Schulden sind normal — wichtig ist, sie sichtbar zu halten und abzubauen$C$,
   '["Scrum","Technical Debt","Refactoring","Qualität","DoD"]', 'Qualität');

  -- ════════════════════════════════════════════════════════════════
  -- DEVOPS
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_devops, v_uid, 'Was ist DevOps?',
$C$**DevOps** ist eine Kultur, Bewegung und Praxis, die **Entwicklung (Dev)** und **Betrieb (Ops)** vereint.

## Das Problem vorher

```
Dev:  "Der Code läuft bei mir!"
Ops:  "Auf dem Server läuft er nicht!"
```
Getrennte Teams, unterschiedliche Ziele, langsame Releases, gegenseitige Schuldzuweisungen.

## DevOps-Lösung
- **Gemeinsame Verantwortung** für den gesamten Lebenszyklus
- **Automatisierung** von Build, Test, Deploy, Betrieb
- **Feedback-Schleifen** verkürzen (schneller auf Probleme reagieren)
- **Kontinuierliche Verbesserung** (Kaizen)

## DevOps-Lebenszyklus (Infinity-Symbol)
```
Plan → Code → Build → Test → Release → Deploy → Operate → Monitor
                                                         ↑_____|
```

## CALMS-Framework
| Buchstabe | Bedeutung |
|-----------|-----------|
| **C**ulture | Zusammenarbeit, Vertrauen, Fehlerkultur |
| **A**utomation | Alles automatisieren was automatisiert werden kann |
| **L**ean | Verschwendung eliminieren, Flow optimieren |
| **M**easurement | Metriken messen, datengetrieben entscheiden |
| **S**haring | Wissen und Tools teilen |

## DevOps ≠ ein Tool
DevOps ist primär eine **Kultur**, sekundär Tools und Prozesse.

**Merke:** DevOps = Dev + Ops + Kultur + Automatisierung → schnellere, zuverlässigere Releases$C$,
   '["DevOps","Grundlagen","Kultur","CALMS","Überblick"]', 'Grundlagen'),

  (v_devops, v_uid, 'CI/CD — Continuous Integration & Delivery',
$C$**CI/CD** automatisiert das Testen und Ausliefern von Software.

## Continuous Integration (CI)
Entwickler integrieren Code **mehrmals täglich** in einen gemeinsamen Branch.
Jeder Commit triggert automatisch:
1. Build (kompilieren)
2. Unit Tests ausführen
3. Statische Code-Analyse (Linting, SAST)
4. Feedback an Entwickler (grün/rot)

**Ziel:** Fehler früh finden, bevor sie sich stapeln.

## Continuous Delivery (CD)
Jeder erfolgreiche CI-Build ist **bereit zum Deployment** (in Staging):
```
CI ✅ → Staging Deployment → manuelle Freigabe → Produktion
```

## Continuous Deployment
Jeder erfolgreiche Build geht **automatisch in Produktion**:
```
CI ✅ → Staging → Auto-Deploy → Produktion
```

## Typische CI/CD-Pipeline
```yaml
stages:
  - name: build
    run: npm run build
  - name: test
    run: npm test
  - name: lint
    run: npm run lint
  - name: deploy-staging
    run: deploy.sh staging
  - name: e2e-tests
    run: playwright test
  - name: deploy-production
    run: deploy.sh production
    when: manual
```

## Vorteile
- Schnellere Releases (Tage statt Monate)
- Frühe Fehlererkennung
- Geringeres Deployment-Risiko (kleine Änderungen)
- Immer deploybare Codebasis

**Merke:** CI = automatisch testen; CD = automatisch ausliefern$C$,
   '["DevOps","CI/CD","Pipeline","Continuous Integration","Automation"]', 'CI/CD'),

  (v_devops, v_uid, 'GitHub Actions',
$C$**GitHub Actions** ist die in GitHub integrierte CI/CD-Plattform.

## Grundkonzepte
- **Workflow:** Automatisierungsprozess (YAML-Datei in `.github/workflows/`)
- **Event:** Trigger (push, pull_request, schedule, workflow_dispatch)
- **Job:** Gruppe von Steps, läuft auf einem Runner
- **Step:** Einzelner Befehl oder Action
- **Runner:** Virtuelle Maschine (ubuntu-latest, windows-latest, macos-latest)

## Beispiel-Workflow
```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Code auschecken
        uses: actions/checkout@v4

      - name: Node.js einrichten
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Dependencies installieren
        run: npm ci

      - name: Tests ausführen
        run: npm test

      - name: Build erstellen
        run: npm run build

  deploy:
    needs: test          # erst nach erfolgreichem Test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Auf Server deployen
        run: ./deploy.sh
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
```

## Secrets & Variablen
- `${{ secrets.MEIN_SECRET }}` — verschlüsselt in GitHub gespeichert
- `${{ vars.API_URL }}` — Nicht-sensitive Variablen
- `${{ github.sha }}` — Commit-Hash
- `${{ github.actor }}` — Wer hat den Push ausgelöst

## Marketplace Actions
Tausende vorgefertigte Actions: Docker push, Azure Deploy, Slack Notify...

**Merke:** YAML-Datei in `.github/workflows/` → automatische CI/CD bei jedem Push$C$,
   '["DevOps","GitHub Actions","CI/CD","Workflow","Automation"]', 'CI/CD'),

  (v_devops, v_uid, 'Git Branching-Strategien',
$C$Eine **Branching-Strategie** definiert, wie Teams mit Git-Branches arbeiten.

## Git Flow (klassisch)

Für Releases mit festen Versionen:
```
main (Produktion)
  └─ develop (Integration)
       ├─ feature/login
       ├─ feature/checkout
       └─ release/v1.2
hotfix/kritischer-bug → direkt in main + develop
```
**Vorteil:** Klare Struktur für mehrere Versionen.
**Nachteil:** Komplex, lange Feature-Branches, seltene Integrations.

## Trunk-Based Development (TBD)

Alle Entwickler committen täglich auf `main` (oder kurzlebige Feature-Branches ≤2 Tage):
```
main ←── feature/A (1 Tag)
     ←── feature/B (2 Tage)
     ←── bugfix/X  (Stunden)
```
**Vorteil:** Schnelle Integration, weniger Merge-Konflikte, CI/CD freundlich.
**Nachteil:** Erfordert Feature Flags für unfertige Features.

## GitHub Flow (vereinfacht)

```
main ← Pull Request ← feature-branch
```
1. Branch von main
2. Commits
3. Pull Request öffnen
4. Code Review
5. Merge in main → automatisches Deployment

## Empfehlung
| Team | Strategie |
|------|-----------|
| Kleine Teams, Web-Apps | GitHub Flow / TBD |
| Mehrere Release-Versionen | Git Flow |
| Enterprise CI/CD | Trunk-Based |

**Merke:** Trunk-Based + Feature Flags = schnellste CI/CD-Zyklen$C$,
   '["DevOps","Git","Branching","GitFlow","Trunk-Based"]', 'Versionskontrolle'),

  (v_devops, v_uid, 'Infrastructure as Code (IaC)',
$C$**Infrastructure as Code (IaC)** bedeutet: Infrastruktur (Server, Netzwerke, Datenbanken) wird wie Code in Dateien definiert und versioniert.

## Warum IaC?

**Ohne IaC:** Klick-Ops im Portal, schlecht reproduzierbar, Fehler beim manuellen Setup.

**Mit IaC:**
- Reproduzierbar: gleiches Setup in dev, staging, prod
- Versioniert: Git-History für Infrastruktur
- Automatisierbar: CI/CD deployt Infrastruktur
- Dokumentiert: der Code IST die Dokumentation

## Deklarativ vs. Imperativ

**Deklarativ:** Du beschreibst *was* du haben willst:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```
Tools: Terraform, Pulumi, CloudFormation, ARM Templates

**Imperativ:** Du beschreibst *wie* es erstellt wird:
```bash
aws ec2 run-instances --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t2.micro
```

## IaC-Tools im Vergleich
| Tool | Cloud | Sprache |
|------|-------|---------|
| Terraform | Alle | HCL |
| Pulumi | Alle | TypeScript/Python/Go |
| CloudFormation | AWS | YAML/JSON |
| ARM/Bicep | Azure | JSON/Bicep |
| Ansible | Alle | YAML (Playbooks) |

**Merke:** IaC = Infrastruktur in Git; niemals manuell im Portal klicken was auch Code kann$C$,
   '["DevOps","IaC","Terraform","Infrastructure","Automatisierung"]', 'IaC'),

  (v_devops, v_uid, 'Terraform Grundlagen',
$C$**Terraform** ist das populärste IaC-Tool — cloud-agnostisch und deklarativ.

## Kernkonzepte

**Provider:** Plugin für einen Cloud-Anbieter:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}
provider "azurerm" {
  features {}
}
```

**Resource:** Eine Infrastruktur-Komponente:
```hcl
resource "azurerm_resource_group" "main" {
  name     = "meine-rg"
  location = "Germany West Central"
}

resource "azurerm_storage_account" "storage" {
  name                = "meinstorage123"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  account_tier        = "Standard"
  account_replication_type = "LRS"
}
```

## Terraform Workflow
```bash
terraform init      # Provider herunterladen
terraform plan      # Änderungen anzeigen (Dry-Run)
terraform apply     # Änderungen anwenden
terraform destroy   # Alles löschen
```

## State
Terraform merkt sich den aktuellen Zustand in `terraform.tfstate`:
- Lokal: Datei im Projektverzeichnis
- Remote: Azure Blob Storage, S3, Terraform Cloud (für Teams!)

## Variablen
```hcl
variable "environment" {
  type    = string
  default = "dev"
}
resource "azurerm_resource_group" "main" {
  name = "rg-${var.environment}"
}
```

**Merke:** `plan` zeigt was sich ändert; `apply` macht es; State ist das Gedächtnis von Terraform$C$,
   '["DevOps","Terraform","IaC","HCL","Azure"]', 'IaC'),

  (v_devops, v_uid, 'Monitoring & Observability',
$C$**Observability** beschreibt die Fähigkeit, den internen Zustand eines Systems aus seinen Ausgaben zu verstehen.

## Die drei Säulen

**1. Logs** — Was ist passiert?
```json
{"timestamp": "2024-01-15T10:23:45Z", "level": "ERROR",
 "message": "DB connection failed", "service": "api", "traceId": "abc123"}
```
- Strukturiert (JSON) statt plain text
- Zentral aggregiert (ELK Stack, Loki, Azure Monitor)

**2. Metrics** — Wie verhält sich das System?
Numerische Werte über die Zeit:
- `http_requests_total{status="200"}` — Anzahl erfolgreicher Requests
- `cpu_usage_percent` — CPU-Auslastung
- `db_query_duration_seconds` — DB-Antwortzeit

Tools: Prometheus, Grafana, Datadog, Azure Monitor

**3. Traces** — Wo verliert eine Anfrage Zeit?
Verfolgt eine Anfrage durch alle Services (Distributed Tracing):
```
Request → API (5ms) → Auth Service (12ms) → DB (450ms!) → Response
```
Tools: Jaeger, Zipkin, OpenTelemetry

## OpenTelemetry
Offener Standard für Telemetriedaten (Logs, Metrics, Traces) — herstellerneutral.

## Alerting
```
Metric: p99 Latenz > 1s für 5 min → Alert → PagerDuty/Slack
```

**Merke:** Logs = Was, Metrics = Wie viel/oft, Traces = Wo/Wie lang$C$,
   '["DevOps","Monitoring","Observability","Logs","Metriken"]', 'Monitoring'),

  (v_devops, v_uid, 'SLI / SLO / SLA',
$C$**SLI, SLO und SLA** sind Werkzeuge um Service-Qualität messbar zu machen.

## SLI — Service Level Indicator
Eine **messbare Kennzahl** für die Service-Qualität:
- Verfügbarkeit: `requests_erfolgreiche / requests_gesamt × 100`
- Latenz: p99 Response-Zeit
- Fehlerrate: `Fehler / requests_gesamt × 100`
- Durchsatz: Requests pro Sekunde

## SLO — Service Level Objective
Das **interne Ziel** für einen SLI:
```
Verfügbarkeit SLO: 99,9% (über 30 Tage)
Latenz SLO: p99 < 200ms
```

Formel für erlaubte Ausfallzeit:
$$\text{Ausfallzeit} = (1 - \text{SLO}) \times \text{Zeitraum}$$

Beispiel 99,9%: $(1 - 0{,}999) \times 30 \text{ Tage} = 43{,}2 \text{ Minuten/Monat}$

## Error Budget
$(1 - \text{SLO}) \times \text{Zeitraum}$ = erlaubte Ausfallzeit ("Budget")
- Budget aufgebraucht → keine neuen Features, nur Stabilitäts-Fixes
- Budget vorhanden → schnell deployen ist OK

## SLA — Service Level Agreement
Das **vertragliche Versprechen** an den Kunden:
- SLO ist intern (strenger), SLA ist extern (kundengerichtet)
- Bei SLA-Verletzung: finanzielle Konsequenzen (Credits, Rückerstattungen)

**Merke:** SLI misst, SLO ist das Ziel, SLA ist der Vertrag. Error Budget = Risikopuffer$C$,
   '["DevOps","SLI","SLO","SLA","SRE"]', 'SRE'),

  (v_devops, v_uid, 'DORA Metrics',
$C$**DORA Metrics** (DevOps Research & Assessment) sind vier Schlüsselkennzahlen für DevOps-Performance.

## Die vier DORA-Metriken

**1. Deployment Frequency** — Wie oft wird deployed?
| Elite | High | Medium | Low |
|-------|------|--------|-----|
| On-demand / mehrfach tägl. | 1x tägl. – 1x wöchentl. | 1x wöchentl. – 1x monatl. | < 1x monatl. |

**2. Lead Time for Changes** — Commit bis Produktion?
| Elite | High | Medium | Low |
|-------|------|--------|-----|
| < 1 Stunde | 1 Tag – 1 Woche | 1 Woche – 1 Monat | > 1 Monat |

**3. Change Failure Rate** — Wie viele Deployments verursachen Probleme?
| Elite | High | Medium | Low |
|-------|------|--------|-----|
| 0-5% | 5-10% | 10-15% | 15-45% |

**4. Mean Time to Recovery (MTTR)** — Wie lange bis Wiederherstellung?
| Elite | High | Medium | Low |
|-------|------|--------|-----|
| < 1 Stunde | < 1 Tag | 1 Tag – 1 Woche | > 1 Woche |

## Warum DORA-Metriken?

Forschung (5000+ Teams) zeigt: Elite-Teams haben **7x weniger Ausfälle** und **2555x schnellere Deployments** als Low-Teams.

Gute Geschwindigkeit (Freq + Lead Time) geht **nicht auf Kosten** von Stabilität (Failure Rate + MTTR) — im Gegenteil!

**Merke:** DORA misst DevOps-Reifegrad: Schnell UND stabil ist möglich!$C$,
   '["DevOps","DORA","Metriken","Performance","Messung"]', 'Metriken'),

  (v_devops, v_uid, 'Blue-Green & Canary Deployment',
$C$**Deployment-Strategien** reduzieren das Risiko beim Ausrollen neuer Software-Versionen.

## Blue-Green Deployment

Zwei identische Produktionsumgebungen (Blue = alt, Green = neu):
```
Internet → Load Balancer → Blue (v1, aktuell live)
                        → Green (v2, im Test)
```
1. v2 auf Green deployen und testen
2. Load Balancer auf Green umschalten (kein Downtime!)
3. Blue bleibt als Rollback bereit
4. Nach Bestätigung: Blue = neues Staging

**Vorteil:** Sofortiger Rollback (einfach zurückschalten).
**Nachteil:** Doppelte Infrastrukturkosten.

## Canary Deployment

Neue Version wird **schrittweise** für mehr Nutzer ausgerollt:
```
100% Nutzer → v1 (stabil)

5% Nutzer → v2 (Canary) | 95% → v1
↓ Metriken OK?
20% → v2 | 80% → v1
↓ Metriken OK?
100% → v2 (vollständig ausgerollt)
```

**Vorteil:** Echtes Nutzer-Feedback vor vollem Rollout; minimale Auswirkung bei Fehlern.
**Nachteil:** Komplexer zu implementieren (A/B-Traffic-Routing).

## Rolling Update (Kubernetes Standard)
Pods werden schrittweise ersetzt:
```
[v1][v1][v1] → [v2][v1][v1] → [v2][v2][v1] → [v2][v2][v2]
```

**Merke:** Blue-Green = schneller Rollback; Canary = schrittweiser Rollout mit Monitoring$C$,
   '["DevOps","Deployment","Blue-Green","Canary","Rolling Update"]', 'Deployment'),

  (v_devops, v_uid, 'Feature Flags',
$C$**Feature Flags** (auch Feature Toggles) entkoppeln **Deployment** von **Release**.

## Das Konzept

Code deployen ohne Features zu aktivieren → Feature erst für bestimmte Nutzer/Umgebungen einschalten:

```javascript
if (featureFlag.isEnabled('neue-suche', userId)) {
  return <NeuesSuchfeld />;
} else {
  return <AltesSuchfeld />;
}
```

## Anwendungsfälle

| Einsatz | Beschreibung |
|---------|-------------|
| **Trunk-Based Dev** | Unfertiger Code schon gemergt, aber deaktiviert |
| **A/B Testing** | Feature für 50% der Nutzer → Konversionen messen |
| **Canary Release** | Feature für 1% → 10% → 100% |
| **Kill Switch** | Problematisches Feature sofort deaktivieren |
| **Beta-Nutzer** | Feature nur für ausgewählte Nutzer |

## Tools für Feature Flags
- **LaunchDarkly** (kommerziell, sehr mächtig)
- **Azure App Configuration** (Feature Manager)
- **Unleash** (Open Source)
- **Selbst gebaut** (einfache Datenbank-Tabelle)

## Azure App Configuration
```csharp
if (await featureManager.IsEnabledAsync("NeueKI"))
{
    // neue KI-Funktion
}
```

```json
// Azure Portal
{
  "id": "NeueKI",
  "enabled": true,
  "conditions": {
    "clientFilters": [{ "name": "Percentage", "parameters": { "Value": 10 } }]
  }
}
```

**Merke:** Feature Flags = deploye früh, release kontrolliert$C$,
   '["DevOps","Feature Flags","Deployment","A/B Testing","Trunk-Based"]', 'Deployment'),

  (v_devops, v_uid, 'GitOps & ArgoCD',
$C$**GitOps** ist ein Betriebsmodell bei dem Git die einzige Wahrheitsquelle für Infrastruktur und Anwendungen ist.

## GitOps-Prinzipien

1. **Deklarativ:** System-Zustand ist in Git-Dateien beschrieben
2. **Versioniert:** Vollständige Audit-History in Git
3. **Automatisch:** Ein Agent synchronisiert Git-Zustand mit dem Live-System
4. **Selbstheilend:** Wenn jemand manuell etwas ändert, wird es automatisch zurückgesetzt

## Push vs. Pull

**Push (klassisches CD):**
```
CI/CD Pipeline → kubectl apply → Cluster
```

**Pull (GitOps):**
```
Git (Wahrheit) ← ArgoCD (Pull) → Cluster (Anpassung)
```
ArgoCD überwacht Git und Cluster — wenn sie abweichen, synchronisiert ArgoCD.

## ArgoCD

ArgoCD läuft im Kubernetes-Cluster und synchronisiert Git → Cluster:

```yaml
# ArgoCD Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: meine-app
spec:
  source:
    repoURL: https://github.com/mein-org/k8s-configs
    path: production/meine-app
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: produktion
  syncPolicy:
    automated:
      prune: true      # Nicht in Git = wird gelöscht
      selfHeal: true   # Manuelle Änderungen werden rückgängig gemacht
```

## Workflow
```
PR erstellen → Review → Merge in main → ArgoCD synct → Cluster aktuell
```

**Merke:** GitOps = Git ist das Steuer, nicht kubectl oder Azure Portal$C$,
   '["DevOps","GitOps","ArgoCD","Kubernetes","CD"]', 'GitOps'),

  (v_devops, v_uid, 'Site Reliability Engineering (SRE)',
$C$**SRE (Site Reliability Engineering)** ist Googles Ansatz, Software-Engineering-Prinzipien auf Operations anzuwenden.

## "SRE ist, was passiert wenn man Software-Ingenieure damit beauftragt, Operations-Arbeit zu erledigen."
— Ben Treynor Sloss, Google

## SRE-Kernprinzipien

**Error Budget:** $1 - \text{SLO}$ = erlaubtes Risiko
- Budget vorhanden → neue Features deployen OK
- Budget aufgebraucht → nur Stabilität, keine Features

**Toil (Plackerei) reduzieren:**
Toil = manuelle, repetitive Arbeit ohne dauerhaften Wert.
SREs streben an: max. 50% Zeit für Toil, min. 50% für Engineering.

**Automation first:** Wenn du etwas zweimal manuell machst, automatisiere es beim dritten Mal.

**Postmortems ohne Schuld:**
Nach Incidents: Was lief schief? → Systeme verbessern, nicht Schuldige suchen.

## SRE vs. DevOps
| | SRE | DevOps |
|--|-----|--------|
| Ursprung | Google | Gemeinschaft |
| Fokus | Reliability | Kultur + Prozess |
| Messung | SLI/SLO/Error Budget | DORA Metriken |
| Ansatz | Engineering für Ops | Dev+Ops vereinen |

SRE ist eine **konkrete Implementierung** von DevOps-Prinzipien.

## Incident Management
1. **Detect:** Alert schlägt an
2. **Respond:** On-Call-Person übernimmt
3. **Mitigate:** Sofortmaßnahme (Rollback, Feature Flag)
4. **Resolve:** Root Cause beheben
5. **Postmortem:** Lernmaterial, Verbesserungen

**Merke:** SRE = Software-Engineering für Reliability; Error Budget = Lizenz zum Deployen$C$,
   '["DevOps","SRE","Reliability","SLO","Error Budget"]', 'SRE'),

  (v_devops, v_uid, 'Container-Sicherheit in der CI/CD-Pipeline',
$C$**Container-Sicherheit** muss in jeder Phase der Pipeline berücksichtigt werden — "Shift Left Security".

## Shift Left

Sicherheits-Checks so früh wie möglich in die Pipeline:
```
Code → SAST → Build → Image-Scan → Deploy → Runtime-Schutz
```

## SAST (Static Application Security Testing)
Code wird analysiert ohne Ausführung:
```yaml
# GitHub Actions: CodeQL
- uses: github/codeql-action/analyze@v3
  with:
    languages: ['javascript', 'python']
```

## Dependency-Scanning
Bekannte CVEs in Abhängigkeiten finden:
```bash
npm audit                # Node.js
pip-audit                # Python
trivy fs .               # Alle Sprachen
```

## Container-Image-Scanning
```bash
# Trivy: nach CVEs suchen
trivy image meine-app:latest

# Docker Scout (in Docker integriert)
docker scout cves meine-app:latest

# In CI/CD Pipeline:
trivy image --severity CRITICAL,HIGH --exit-code 1 meine-app:latest
# exit-code 1 = Pipeline schlägt fehl bei Findings
```

## Secrets-Scanning
Verhindert dass Passwörter ins Repo kommen:
```bash
# GitLeaks
gitleaks detect --source . --verbose

# In GitHub: Secret Scanning aktivieren
# (automatisch für öffentliche Repos)
```

## Supply Chain Security
- **SBOM (Software Bill of Materials):** Inventar aller Dependencies
- **Image Signing:** Cosign signiert Images kryptographisch
- **Trusted Base Images:** Nur offizielle, gepatchte Base-Images

**Merke:** Security in die Pipeline einbauen, nicht hintendran kleben$C$,
   '["DevOps","Security","CI/CD","Container","SAST"]', 'Sicherheit');

  RAISE NOTICE 'Seed erfolgreich! Bereiche, Boxen und Karten für % erstellt.', v_uid;
END;
$SEED$ LANGUAGE plpgsql;
