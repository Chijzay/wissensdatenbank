-- ================================================================
-- Seed v2: Zusaetzliche Karten fuer alle Bereiche
-- Fuegt NUR Karten ein, legt KEINE neuen Boxen an.
-- Sicher mehrfach ausfuehrbar (keine Duplikate bei Boxen).
-- Im Supabase SQL-Editor ausfuehren — NACH seed_steven.sql
-- ================================================================

DO $SEED2$
DECLARE
  v_uid        uuid;
  v_itmathe    integer;
  v_azure      integer;
  v_kubernetes integer;
  v_docker     integer;
  v_devops     integer;
  v_re         integer;
  v_sql_box    integer;
  v_bi_box     integer;
  v_scrum      integer;
  v_bprozesse  integer;
  v_ba_box     integer;
  v_strategy   integer;
  v_pm_classic integer;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = 'steven.illg.it@outlook.com';
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Nutzer nicht gefunden'; END IF;

  SELECT id INTO v_itmathe    FROM public.boxes WHERE user_id = v_uid AND name = 'IT Mathe';
  SELECT id INTO v_azure      FROM public.boxes WHERE user_id = v_uid AND name = 'Azure';
  SELECT id INTO v_kubernetes FROM public.boxes WHERE user_id = v_uid AND name = 'Kubernetes';
  SELECT id INTO v_docker     FROM public.boxes WHERE user_id = v_uid AND name = 'Docker';
  SELECT id INTO v_devops     FROM public.boxes WHERE user_id = v_uid AND name = 'DevOps';
  SELECT id INTO v_re         FROM public.boxes WHERE user_id = v_uid AND name = 'Requirements Engineering';
  SELECT id INTO v_sql_box    FROM public.boxes WHERE user_id = v_uid AND name = 'SQL';
  SELECT id INTO v_bi_box     FROM public.boxes WHERE user_id = v_uid AND name = 'Business Intelligence';
  SELECT id INTO v_scrum      FROM public.boxes WHERE user_id = v_uid AND name = 'Scrum';
  SELECT id INTO v_bprozesse  FROM public.boxes WHERE user_id = v_uid AND name = 'Geschäftsprozesse';
  SELECT id INTO v_ba_box     FROM public.boxes WHERE user_id = v_uid AND name = 'Business Analyse';
  SELECT id INTO v_strategy   FROM public.boxes WHERE user_id = v_uid AND name = 'Strategisches Management';
  SELECT id INTO v_pm_classic FROM public.boxes WHERE user_id = v_uid AND name = 'Projektmanagement';

  IF v_itmathe    IS NULL THEN RAISE EXCEPTION 'Box "IT Mathe" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;
  IF v_bprozesse  IS NULL THEN RAISE EXCEPTION 'Box "Geschaeftsprozesse" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;
  IF v_scrum      IS NULL THEN RAISE EXCEPTION 'Box "Scrum" nicht gefunden — seed_steven.sql zuerst ausfuehren!'; END IF;

  -- ════════════════════════════════════════════════════════════════
  -- IT MATHE — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_itmathe, v_uid, 'O-Notation & Zeitkomplexitaet',
$C$Die **O-Notation** (Landau-Notation) beschreibt das Wachstumsverhalten von Algorithmen.

## Was misst die O-Notation?
Wie viel Zeit (oder Speicher) braucht ein Algorithmus wenn die Eingabe **n** waechst?

## Wichtige Klassen (aufsteigend nach Aufwand)
| Klasse | Name | Beispiel |
|--------|------|---------|
| $O(1)$ | Konstant | Array-Zugriff per Index |
| $O(\log n)$ | Logarithmisch | Binaere Suche |
| $O(n)$ | Linear | Liste durchsuchen |
| $O(n \log n)$ | Linearithmisch | Merge Sort, Heap Sort |
| $O(n^2)$ | Quadratisch | Bubble Sort, doppelte Schleife |
| $O(2^n)$ | Exponentiell | Brute-Force-Loesungen |
| $O(n!)$ | Faktoriell | Alle Permutationen |

## Berechnung
Nur das **dominante** Glied zaehlt, Konstanten werden weggelassen:
$$T(n) = 3n^2 + 5n + 100 \Rightarrow O(n^2)$$

## Beispiele
```python
# O(1) — immer gleich schnell
def get_first(arr): return arr[0]

# O(n) — waechst linear mit Eingabe
def sum_all(arr):
    total = 0
    for x in arr:        # n Iterationen
        total += x
    return total

# O(n^2) — doppelte Schleife
def find_pair(arr):
    for i in arr:        # n
        for j in arr:    # n
            if i + j == 0: return True
```

## Best / Average / Worst Case
- **Best Case $\Omega$:** Guenstigster Fall
- **Average Case $\Theta$:** Durchschnitt
- **Worst Case O:** Schlechtester Fall (meist relevant)

**Merke:** O-Notation zeigt Skalierbarkeit; $O(n^2)$ bei grossen Daten vermeiden!$C$,
   '["Algorithmen","O-Notation","Komplexitaet","Performance","Mathe"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Sortieralgorithmen im Vergleich',
$C$Sortieren ist eines der fundamentalsten algorithmischen Probleme.

## Einfache Algorithmen

**Bubble Sort** — Nachbarn tauschen bis sortiert:
```python
for i in range(n):
    for j in range(n-i-1):
        if arr[j] > arr[j+1]:
            arr[j], arr[j+1] = arr[j+1], arr[j]
```
Komplexitaet: $O(n^2)$ — nur fuer Lernzwecke!

**Insertion Sort** — Karte nach Karte in sortierte Folge einsortieren:
$O(n^2)$ worst case, $O(n)$ bei fast sortierten Daten.

**Selection Sort** — Kleinstes Element suchen und nach vorne:
$O(n^2)$ immer.

## Effiziente Algorithmen

**Merge Sort** (Teile und Herrsche):
1. Liste halbieren
2. Beide Haelften rekursiv sortieren
3. Sortierte Haelften zusammenfuehren

Komplexitaet: $O(n \log n)$ immer. Stabil. Braucht extra Speicher $O(n)$.

**Quick Sort** — Pivotelement waehlen, kleiner links, groesser rechts:
$O(n \log n)$ average, $O(n^2)$ worst case. In-place. Nicht stabil.

**Heap Sort** — Max-Heap aufbauen, dann sortieren:
$O(n \log n)$ immer. In-place. Nicht stabil.

## Vergleich
| Algorithmus | Best | Average | Worst | Stabil | Speicher |
|-------------|------|---------|-------|--------|---------|
| Bubble | $O(n)$ | $O(n^2)$ | $O(n^2)$ | Ja | $O(1)$ |
| Merge | $O(n \log n)$ | $O(n \log n)$ | $O(n \log n)$ | Ja | $O(n)$ |
| Quick | $O(n \log n)$ | $O(n \log n)$ | $O(n^2)$ | Nein | $O(\log n)$ |
| Heap | $O(n \log n)$ | $O(n \log n)$ | $O(n \log n)$ | Nein | $O(1)$ |

Python/Java/C# nutzen intern Timsort ($O(n \log n)$, stabil).

**Merke:** Merge Sort = sicher und stabil; Quick Sort = oft schnellster in Praxis$C$,
   '["Sortieren","Algorithmen","Merge Sort","Quick Sort","Komplexitaet"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Binaere Suche & Suchalgorithmen',
$C$**Suchen** bedeutet, ein Element in einer Sammlung zu finden.

## Lineare Suche — $O(n)$
```python
def linear_search(arr, target):
    for i, val in enumerate(arr):
        if val == target:
            return i
    return -1
```
Kein Vorsortieren noetig. Fuer kleine/unsortierte Listen.

## Binaere Suche — $O(\log n)$
Voraussetzung: **sortiertes Array**!
```python
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1     # rechte Haelfte
        else:
            right = mid - 1    # linke Haelfte
    return -1
```

**Intuition:** Telefonbuch aufschlagen — Mitte pruefen, halbe Seiten eliminieren.

| n | Lineare Suche | Binaere Suche |
|---|---------------|--------------|
| 100 | max. 100 Schritte | max. 7 Schritte |
| 1.000 | 1.000 | 10 |
| 1.000.000 | 1.000.000 | 20 |

## Interpolationssuche — $O(\log \log n)$
Wie binaere Suche, aber klugere Schaetzung der Position (bei gleichmaessig verteilten Werten).

## Tiefensuche (DFS) & Breitensuche (BFS)
Fuer **Graphen und Baeume**:
- **DFS:** Stack, geht tief bevor breit — findet Pfad, kein kuerzester
- **BFS:** Queue, Ebene fuer Ebene — findet kuerzesten Pfad

```python
from collections import deque
def bfs(graph, start):
    visited, queue = {start}, deque([start])
    while queue:
        node = queue.popleft()
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
```

**Merke:** Binaere Suche = $O(\log n)$ aber nur auf sortierten Daten; BFS = kuerzester Pfad$C$,
   '["Suche","Binaere Suche","BFS","DFS","Algorithmen"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Graphentheorie Grundlagen',
$C$**Graphen** bestehen aus **Knoten (Vertices)** und **Kanten (Edges)** — eine der wichtigsten Datenstrukturen.

## Grundbegriffe
- **Knoten (V):** Entitaet (Person, Stadt, Webseite)
- **Kante (E):** Beziehung zwischen zwei Knoten
- **Gerichtet (Digraph):** Kanten haben eine Richtung (Pfeil)
- **Ungerichtet:** Kanten ohne Richtung
- **Gewichtet:** Kanten haben Gewichte (Distanz, Kosten)
- **Grad:** Anzahl Kanten an einem Knoten

## Darstellungsformen
**Adjazenzmatrix** (gut fuer dichte Graphen):
```
     A  B  C  D
A  [ 0  1  1  0 ]
B  [ 1  0  1  0 ]
C  [ 1  1  0  1 ]
D  [ 0  0  1  0 ]
```
Speicher: $O(V^2)$; Kante pruefen: $O(1)$

**Adjazenzliste** (gut fuer sparse Graphen):
```python
graph = {
  'A': ['B', 'C'],
  'B': ['A', 'C'],
  'C': ['A', 'B', 'D'],
  'D': ['C']
}
```
Speicher: $O(V + E)$

## Spezielle Graphtypen
- **Baum:** Zusammenhaengender Graph ohne Zyklen
- **DAG (Directed Acyclic Graph):** Gerichteter Graph ohne Zyklen (z.B. Abhaengigkeiten)
- **Vollstaendiger Graph $K_n$:** Jeder Knoten mit jedem verbunden, $\frac{n(n-1)}{2}$ Kanten

## Wichtige Algorithmen
| Problem | Algorithmus |
|---------|-----------|
| Kuerzester Pfad (gewichtet) | Dijkstra $O((V+E)\log V)$ |
| Kuerzester Pfad (negativ) | Bellman-Ford $O(VE)$ |
| Minimaler Spannbaum | Kruskal / Prim |
| Topologische Sortierung | Kahn / DFS |

**Merke:** Adjazenzliste fuer grosse Graphen; DAG fuer Abhaengigkeiten (Build-Systeme, Pipelines)$C$,
   '["Graphen","Algorithmen","BFS","DFS","Adjazenzmatrix"]', 'Graphen'),

  (v_itmathe, v_uid, 'Hashing & Hashtabellen',
$C$**Hashing** bildet beliebige Daten auf einen festen Indexbereich ab — Basis von Woerterbuechern, Datenbanken und Kryptografie.

## Hash-Funktion
$$h(key) = key \mod m$$
Bildet Schluessel auf Index $0 \ldots m-1$ ab.

Gute Hash-Funktion: schnell, gleichmaessige Verteilung, minimale Kollisionen.

## Hashtabelle (Dictionary/HashMap)
```python
# Python dict ist intern eine Hashtabelle
phone = {}
phone["Alice"] = "0171-123"   # O(1) Einfuegen
phone["Bob"]   = "0172-456"

print(phone["Alice"])          # O(1) Zugriff
del phone["Bob"]               # O(1) Loeschen
```

## Kollisionen
Wenn zwei Schluessel denselben Index ergeben:

**Verkettung (Chaining):** Jeder Slot ist eine Liste:
```
Index 3 → [("Alice", "0171"), ("Dave", "0173")]
```

**Offene Adressierung:** Naechsten freien Slot suchen (Linear Probing).

## Load Factor
$$\lambda = \frac{\text{Eintraege}}{\text{Tabellengroesse}}$$
Bei $\lambda > 0{,}7$: Tabelle vergroessern (Rehashing).

## Kryptografisches Hashing
Fuer Passwoerter und Integritaetspruefung:
- **SHA-256:** 256-bit Hash, kein Zurueckrechnen moeglich
- **bcrypt / Argon2:** Fuer Passwoerter — absichtlich langsam
- **MD5:** veraltet, unsicher!

```python
import hashlib
h = hashlib.sha256(b"mein passwort").hexdigest()
# "4a2b..." — gleiche Eingabe = immer gleicher Hash
# Minimale Aenderung = voellig anderer Hash (Avalanche Effect)
```

**Merke:** Hashtabelle = O(1) Zugriff; kryptografisches Hash = Einwegfunktion, nicht umkehrbar$C$,
   '["Hashing","Hashtabelle","Kryptografie","SHA","Algorithmen"]', 'Datenstrukturen'),

  (v_itmathe, v_uid, 'Boolsche Algebra & Logikgatter',
$C$**Boolsche Algebra** (George Boole, 1847) ist die mathematische Grundlage digitaler Schaltungen.

## Grundoperationen
| Operation | Symbol | Tabelle |
|-----------|--------|---------|
| **NOT (Negation)** | $\neg A$, `!A` | $\neg 0=1$, $\neg 1=0$ |
| **AND (Konjunktion)** | $A \land B$, `A & B` | $1 \land 1 = 1$, sonst 0 |
| **OR (Disjunktion)** | $A \lor B$, `A OR B` | $0 \lor 0 = 0$, sonst 1 |
| **XOR (Exklusiv-Oder)** | $A \oplus B` | 1 wenn genau einer 1 |
| **NAND** | $\neg(A \land B)$ | Inverse von AND |
| **NOR** | $\neg(A \lor B)$ | Inverse von OR |

## Rechenregeln (Axiome)
```
Kommutativitaet: A AND B = B AND A
Assoziativitaet: (A AND B) AND C = A AND (B AND C)
Distributivitaet: A AND (B OR C) = (A AND B) OR (A AND C)
De Morgan:        NOT(A AND B) = (NOT A) OR (NOT B)
                  NOT(A OR B)  = (NOT A) AND (NOT B)
Absorption:       A OR (A AND B) = A
Idempotenz:       A AND A = A
```

## De Morgans Gesetze (Praxisrelevant!)
```python
# Aequivalent:
not (a and b)  ==  (not a) or (not b)
not (a or b)   ==  (not a) and (not b)
```

## Anwendung: Schaltungen
NAND und NOR sind **universelle Gatter** — jede Schaltung kann nur damit gebaut werden.

## Karnaugh-Diagramm (KV-Diagramm)
Vereinfacht boolsche Ausdruecke visuell:
Wahrheitstabelle in 2D anordnen, groesste Gruppen von 1en zusammenfassen.

**Merke:** De Morgan: NOT(A AND B) = (NOT A) OR (NOT B) — unbedingt auswendig lernen!$C$,
   '["Boolsche Algebra","Logik","De Morgan","Gatter","Grundlagen"]', 'Grundlagen'),

  (v_itmathe, v_uid, 'Zahlensysteme & Binaerrechnung',
$C$Computer rechnen intern im **Binaersystem** (Basis 2). Wichtig fuer Verstaendnis von Bitoperationen, Speicher und Netzwerken.

## Zahlensysteme
| System | Basis | Ziffern | Beispiel |
|--------|-------|---------|---------|
| Dezimal | 10 | 0-9 | 42 |
| Binaer | 2 | 0, 1 | 101010 |
| Oktal | 8 | 0-7 | 52 |
| Hexadezimal | 16 | 0-9, A-F | 2A |

## Umwandlung Binaer → Dezimal
$$101010_2 = 1 \cdot 2^5 + 0 \cdot 2^4 + 1 \cdot 2^3 + 0 \cdot 2^2 + 1 \cdot 2^1 + 0 \cdot 2^0 = 32+8+2 = 42$$

## Dezimal → Binaer (Divisionsverfahren)
```
42 : 2 = 21 Rest 0
21 : 2 = 10 Rest 1
10 : 2 =  5 Rest 0
 5 : 2 =  2 Rest 1
 2 : 2 =  1 Rest 0
 1 : 2 =  0 Rest 1
Lese von unten: 101010
```

## Hexadezimal (kompakt)
4 Binaerstellen = 1 Hex-Stelle:
```
1010 1111 = AF (hex) = 175 (dez)
```
Hex-Farben: `#FF8800` = R:255 G:136 B:0

## Bitoperationen
```python
a = 0b1010   # 10
b = 0b1100   # 12

a & b   # AND:  0b1000 = 8
a | b   # OR:   0b1110 = 14
a ^ b   # XOR:  0b0110 = 6
~a      # NOT:  -11 (Zweierkomplement)
a << 1  # Links-Shift:  0b10100 = 20 (= x2)
a >> 1  # Rechts-Shift: 0b0101  = 5  (= /2)
```

## Zweierkomplement (negative Zahlen)
8-Bit: $-42 = \sim 42 + 1 = 11010110_2$

**Merke:** Hex = kompakte Darstellung von Binaer; Shift-Left = mal 2; Shift-Right = durch 2$C$,
   '["Binaer","Zahlensysteme","Hex","Bitoperationen","Grundlagen"]', 'Grundlagen'),

  (v_itmathe, v_uid, 'Rekursion verstehen',
$C$**Rekursion** ist wenn eine Funktion sich selbst aufruft — ein maechtiges Konzept fuer hierarchische und selbstaehnliche Probleme.

## Anatomie einer rekursiven Funktion
```python
def fakultaet(n):
    if n <= 1:        # Basisfall (PFLICHT!)
        return 1
    return n * fakultaet(n - 1)   # Rekursiver Fall

fakultaet(4) = 4 * fakultaet(3)
             = 4 * 3 * fakultaet(2)
             = 4 * 3 * 2 * fakultaet(1)
             = 4 * 3 * 2 * 1 = 24
```

**Zwei Teile sind zwingend:**
1. **Basisfall:** Abbruchbedingung (verhindert Endlosrekursion)
2. **Rekursiver Fall:** Verkleinertes Teilproblem aufrufen

## Call Stack
Jeder Aufruf legt einen **Stack Frame** auf den Call Stack:
```
fakultaet(4)
  fakultaet(3)
    fakultaet(2)
      fakultaet(1) → gibt 1 zurueck
    gibt 2 * 1 = 2 zurueck
  gibt 3 * 2 = 6 zurueck
gibt 4 * 6 = 24 zurueck
```
Bei zu tiefer Rekursion: **Stack Overflow**!

## Fibonacci
$$f(n) = f(n-1) + f(n-2), \quad f(0)=0, f(1)=1$$
```python
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)  # O(2^n) — sehr langsam!
```

**Besser: Memoization (Dynamic Programming)**
```python
from functools import lru_cache
@lru_cache(maxsize=None)
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)  # O(n) mit Cache
```

## Wann Rekursion?
Gut fuer: Baeume traversieren, Merge Sort, Quicksort, Backtracking
Schlecht fuer: Einfache Schleifen (hoeherer Overhead)

**Merke:** Basisfall nicht vergessen; Rekursion = Selbstaehnlichkeit; tief = Stack Overflow$C$,
   '["Rekursion","Algorithmen","Stack","Fibonacci","Grundlagen"]', 'Algorithmen'),

  (v_itmathe, v_uid, 'Datenstrukturen — Array, Stack, Queue, LinkedList',
$C$Datenstrukturen bestimmen wie Daten gespeichert und zugegriffen werden — direkt relevant fuer Performance.

## Array / Liste
```python
arr = [1, 2, 3, 4, 5]
arr[2]       # O(1) — direkter Zugriff per Index
arr.append(6) # O(1) amortisiert
arr.insert(0, 0) # O(n) — alle schieben sich
```
**Merke:** Zugriff O(1), Einfuegen/Loeschen in der Mitte O(n).

## Stack (LIFO — Last In First Out)
```python
stack = []
stack.append("A")   # push
stack.append("B")
stack.pop()          # "B" — letztes raus
```
**Anwendung:** Undo-Funktion, Call Stack, Klammerpruefer

## Queue (FIFO — First In First Out)
```python
from collections import deque
q = deque()
q.append("A")        # enqueue
q.append("B")
q.popleft()          # "A" — erstes raus
```
**Anwendung:** Aufgabenwarteschlangen, BFS, Nachrichten

## Linked List
Jedes Element (Node) zeigt auf das naechste:
```
[1|->] [2|->] [3|->] [4|NULL]
```
- Einfuegen am Anfang: O(1)
- Zugriff per Index: O(n) (kein direkter Index!)
- Loeschen (mit Zeiger): O(1)

## Wann was?
| Brauche | Struktur |
|---------|---------|
| Schneller Index-Zugriff | Array |
| LIFO (Undo, Parsing) | Stack |
| FIFO (Warteschlange) | Queue |
| Viele Einfuegen/Loeschen | Linked List |
| Sortierte Suche | Binary Search Tree |
| Schluessel-Wert | HashMap/Dictionary |

**Merke:** Array = schnell lesen; Linked List = schnell einfuegen; Stack = LIFO; Queue = FIFO$C$,
   '["Datenstrukturen","Array","Stack","Queue","LinkedList"]', 'Datenstrukturen'),

  (v_itmathe, v_uid, 'Mengenlehre & Relationen',
$C$**Mengenlehre** ist die Grundlage fuer Datenbanktheorie (SQL!), Logik und viele mathematische Bereiche.

## Mengen-Operationen
Sei $A = \{1, 2, 3, 4\}$ und $B = \{3, 4, 5, 6\}$:

| Operation | Symbol | Ergebnis |
|-----------|--------|---------|
| Vereinigung | $A \cup B$ | $\{1,2,3,4,5,6\}$ |
| Schnittmenge | $A \cap B$ | $\{3,4\}$ |
| Differenz | $A \setminus B$ | $\{1,2\}$ |
| Komplement | $\overline{A}$ | Alles nicht in A |
| Symmetrische Differenz | $A \triangle B$ | $\{1,2,5,6\}$ |

## SQL-Verbindung
```sql
-- Schnittmenge (INNER JOIN oder INTERSECT)
SELECT id FROM tabelle_a INTERSECT SELECT id FROM tabelle_b;

-- Vereinigung (UNION)
SELECT id FROM tabelle_a UNION SELECT id FROM tabelle_b;

-- Differenz (EXCEPT)
SELECT id FROM tabelle_a EXCEPT SELECT id FROM tabelle_b;
```

## Relationen
Eine **Relation** $R$ zwischen $A$ und $B$ ist eine Teilmenge von $A \times B$:
```
A x B = {(a,b) | a in A, b in B}
```

**Eigenschaften** einer Relation auf $A$:
- **Reflexiv:** $(a,a) \in R$ fuer alle $a$
- **Symmetrisch:** $(a,b) \in R \Rightarrow (b,a) \in R$
- **Transitiv:** $(a,b) \in R$ und $(b,c) \in R \Rightarrow (a,c) \in R$
- **Aequivalenzrelation:** Reflexiv + Symmetrisch + Transitiv

## Kardinalitaet
$$|A \cup B| = |A| + |B| - |A \cap B|$$

**Merke:** Mengenlehre = Grundlage von SQL-JOINs; INNER JOIN = Schnittmenge$C$,
   '["Mengenlehre","Relationen","Mengen","SQL","Mathematik"]', 'Grundlagen');

  -- ════════════════════════════════════════════════════════════════
  -- AZURE — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_azure, v_uid, 'Azure Regionen & Verfuegbarkeitszonen',
$C$**Regionen** und **Verfuegbarkeitszonen** sind Grundlage fuer Hochverfuegbarkeit in Azure.

## Azure-Regionen
Ein **Region** = ein oder mehrere Rechenzentren in geografischer Naehe (z.B. Germany West Central, North Europe).

- Weltweit **60+** Regionen
- Datenhaltung bleibt in der Region (wichtig fuer DSGVO!)
- **Region Pair:** Jede Region hat eine Partnerregion (100+ km entfernt) fuer Disaster Recovery

## Verfuegbarkeitszonen (AZ)
Innerhalb einer Region: **3 unabhaengige Zonen** mit eigenem Strom, Kuehlsystem und Netz.

```
Region: Germany West Central
  Zone 1: Rechenzentrum A
  Zone 2: Rechenzentrum B
  Zone 3: Rechenzentrum C
```

**Zone-redundante Dienste:** laufen in allen 3 Zonen gleichzeitig — eine Zone ausfaellt = kein Ausfall.

## SLA-Auswirkung
| Konfiguration | SLA |
|---------------|-----|
| Einzelne VM ohne AZ | 99,9% |
| VM in einer AZ | 99,95% |
| VM in 2+ AZs | 99,99% |

## Verfuegbarkeitssets (Legacy)
Fuer AZs nicht verfuegbare Regionen:
- **Fault Domains:** Verschiedene Racks (Strom/Netz getrennt)
- **Update Domains:** Verschiedene Update-Reihenfolgen

## Wichtige Abwaegungen
- **Latenz:** Naehere Region = niedrigere Latenz
- **Compliance:** Daten nur in EU? → EU-Regionen
- **Dienstverfuegbarkeit:** Nicht alle Dienste in allen Regionen

**Merke:** AZ = 3 Zonen in einer Region; zonenredundant = hoechste Verfuegbarkeit (99,99%+)$C$,
   '["Azure","Regionen","Verfuegbarkeitszonen","SLA","Hochverfuegbarkeit"]', 'Grundlagen'),

  (v_azure, v_uid, 'Azure Cost Management & Pricing',
$C$Azure-Kosten verstehen und optimieren.

## Azure-Preismodelle

**Pay-as-you-go:** Pro Minute/Stunde bezahlen — keine Vorabkosten, hoechste Flexibilitaet, teuerste Option.

**Reservierungen (Reserved Instances):** 1 oder 3 Jahre vorauszahlen → bis zu 72% Rabatt.

**Azure Hybrid Benefit:** Bestehende Windows Server / SQL Server Lizenzen in Azure nutzen → bis zu 40% Ersparnis.

**Dev/Test-Preise:** Fuer Entwicklungsumgebungen — deutlich guenstiger (kein SLA).

**Spot-VMs:** Ueberschusskapazitaet — sehr guenstig, aber kann jederzeit abgeschaltet werden.

## Wichtige Kostenfaktoren
- **Compute:** VM-Groesse, Laufzeit
- **Storage:** Gespeicherte Datenmenge, Zugriffsklasse
- **Netzwerk:** Ausgehender Traffic (Egress) kostet; eingehender meist kostenlos
- **Lizenzen:** Windows, SQL Server teuer

## Cost Management Tools
```
Azure Portal → Cost Management + Billing
  ├── Cost Analysis: Ausgaben visualisieren
  ├── Budgets: Alert bei x% Ueberschreitung
  ├── Cost Alerts: Benachrichtigungen
  └── Advisor: Kostenoptimierungs-Empfehlungen
```

## Azure Preisrechner
https://azure.microsoft.com/de-de/pricing/calculator/
— Kostenschaetzung vor Deployment

## Optimierungsstrategien
- VMs bei Nichtbenutzung herunterfahren (Dev/Test)
- Richtige Groesse waehlen (Right-Sizing)
- Alte Snapshots und Disks loeschen
- Ungenutzte Public IPs freigeben
- Azure Advisor Empfehlungen umsetzen

**Merke:** Egress (ausgehend) kostet immer; Reservierungen = 72% sparen; Advisor = gratis Tipps$C$,
   '["Azure","Kosten","Cost Management","Pricing","Optimierung"]', 'Betrieb'),

  (v_azure, v_uid, 'Azure DevOps Pipelines (YAML)',
$C$**Azure DevOps Pipelines** sind CI/CD-Pipelines die als YAML definiert werden.

## Pipeline-Datei: `azure-pipelines.yml`
```yaml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
- stage: Build
  displayName: 'Build & Test'
  jobs:
  - job: BuildJob
    steps:
    - task: UseDotNet@2
      inputs:
        version: '8.x'

    - script: dotnet restore
      displayName: 'Restore NuGet'

    - script: dotnet build --configuration $(buildConfiguration)
      displayName: 'Build'

    - script: dotnet test --logger trx
      displayName: 'Tests'

    - task: PublishTestResults@2
      inputs:
        testResultsFormat: 'VSTest'
        testResultsFiles: '**/*.trx'

    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'drop'

- stage: Deploy
  displayName: 'Deploy to Azure'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: DeployWeb
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'mein-service-connection'
              appName: 'meine-webapp'
              package: '$(Pipeline.Workspace)/drop/**/*.zip'
```

## Service Connections
Verbindung zu Azure-Abonnements:
- Wird einmalig in Projekteinstellungen konfiguriert
- Nutzt Service Principal oder Managed Identity

## Environments & Approvals
```yaml
environment: 'production'
# Im Portal: Approval-Gate konfigurieren
# → manuell genehmigen bevor Deploy startet
```

**Merke:** Trigger = wann; Stage = Gruppe von Jobs; dependsOn = Reihenfolge; condition = wann ausfuehren$C$,
   '["Azure DevOps","Pipeline","YAML","CI/CD","Build"]', 'CI/CD'),

  (v_azure, v_uid, 'Azure API Management (APIM)',
$C$**Azure API Management** ist ein vollstaendiger API-Gateway-Dienst.

## Was macht APIM?
- Zentrale Veroeffentlichung aller APIs
- Authentifizierung und Autorisierung
- Rate Limiting und Throttling
- Transformation (Request/Response aendern)
- API-Dokumentation (Developer Portal)
- Monitoring und Analytics

## Architektur
```
Clients → [APIM Gateway] → Backend-APIs
                          (Azure Functions, App Service, Container Apps, on-premise)
```

## Kern-Konzepte

**Products:** Buendelung von APIs fuer Abonnenten
```
Product "Basic": API A, API B (100 Req/min)
Product "Premium": API A, B, C (1000 Req/min)
```

**Policies (XML):** Verhalten des Gateways steuern:
```xml
<policies>
  <inbound>
    <rate-limit calls="100" renewal-period="60" />
    <validate-jwt header-name="Authorization">
      <openid-config url="https://login.microsoftonline.com/.../openid-configuration" />
    </validate-jwt>
    <set-header name="X-Request-ID" exists-action="override">
      <value>@(context.RequestId)</value>
    </set-header>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <cache-store duration="3600" />
  </outbound>
</policies>
```

**Subscriptions:** Kunden erhalten API-Keys die nach Product gesteuert sind.

## Tiers
- **Consumption:** Serverless, Pay-per-use (guenstig fuer Einstieg)
- **Developer:** Nicht produktionstauglich, guenstig
- **Standard/Premium:** Produktionsreif, VNet-Integration

**Merke:** APIM = zentrale API-Pforte; Policies = Regeln in XML; Rate Limiting schuetzt Backend$C$,
   '["Azure","APIM","API Management","Gateway","API"]', 'Integration'),

  (v_azure, v_uid, 'Azure Container Apps',
$C$**Azure Container Apps** ist ein serverloser Container-Dienst — einfacher als AKS, maechtig als Functions.

## Positionierung
```
Azure Functions  ←→  Container Apps  ←→  AKS
(Serverless Code)    (Serverless Container)  (Full Kubernetes)
```

## Was Container Apps koennen
- HTTP-Traffic und Event-basiertes Scaling
- Dapr-Integration (Sidecar-Pattern)
- Revision-basiertes Deployment (Blue-Green, Canary)
- Scale-to-Zero (kein Traffic = keine Kosten)
- Integrierte Ingress (HTTPS automatisch)

## Beispiel
```bash
# Container App erstellen
az containerapp create \
  --name meine-app \
  --resource-group meine-rg \
  --environment meine-env \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 10
```

## Skalierung
```yaml
scale:
  minReplicas: 0
  maxReplicas: 10
  rules:
  - name: http-scaling
    http:
      metadata:
        concurrentRequests: "100"
  - name: queue-scaling
    custom:
      type: azure-servicebus
      metadata:
        queueName: meine-queue
        messageCount: "5"
```

## Dapr-Integration
Distributed Application Runtime — vereinfacht Microservice-Kommunikation:
- Service Invocation, Pub/Sub, State Management, Secret Store
- Als Sidecar-Container automatisch eingefuegt

**Merke:** Container Apps = Kubernetes ohne Cluster-Management; Scale-to-Zero = guenstig bei wenig Last$C$,
   '["Azure","Container Apps","Serverless","Dapr","Container"]', 'Container'),

  (v_azure, v_uid, 'Azure Networking — Load Balancer & Traffic Manager',
$C$Azure bietet mehrere Schichten von Load Balancing.

## Azure Load Balancer (Layer 4)
Verteilt TCP/UDP-Traffic auf VMs:
- **Public LB:** Internet → VMs
- **Internal LB:** VNet-intern
- Health Probes prueft VM-Gesundheit
- SKU: Basic (kostenlos) vs. Standard (empfohlen)

## Azure Application Gateway (Layer 7)
HTTP/HTTPS-Load-Balancer mit Web-Application-Firewall (WAF):
- URL-basiertes Routing: `/api/*` → API-VMs; `/static/*` → Storage
- SSL-Termination
- WAF (OWASP Core Rule Set)
- Cookie-basiertes Session Affinity

## Azure Front Door (Global CDN + Load Balancer)
Globaler HTTP-Load-Balancer + CDN:
- Routing zum naehestgelegenen Backend
- Priority/Weighted Routing
- WAF global

## Azure Traffic Manager (DNS-basiert)
Verteilt Traffic auf globaler DNS-Ebene (kein Proxy):
- **Priority:** Failover — wenn Region A ausfaellt → Region B
- **Weighted:** 70% Region A, 30% Region B
- **Performance:** Naeheste Region zum Nutzer
- **Geographic:** Europaeische Nutzer → EU-Region

## Wann was?
| Szenario | Dienst |
|----------|--------|
| VMs hinter LB | Azure Load Balancer |
| HTTP + WAF | Application Gateway |
| Global CDN + WAF | Front Door |
| Multi-Region DNS Failover | Traffic Manager |

**Merke:** Layer 4 = TCP/UDP (LB); Layer 7 = HTTP (App Gateway, Front Door); DNS = Traffic Manager$C$,
   '["Azure","Load Balancer","Traffic Manager","Networking","HA"]', 'Netzwerk'),

  (v_azure, v_uid, 'Azure Identity: Managed Identity & RBAC',
$C$**Kein Passwort im Code** — Azure-interne Dienste authentifizieren sich mit Managed Identity.

## Problem ohne Managed Identity
```python
# SCHLECHT: Secret im Code / Env-Variable
conn_str = "Server=db;Password=SuperGeheim123"
```

## Managed Identity
Azure verwaltet die Identitaet automatisch — kein Secret, kein Ablaufen, kein Rotieren:

**System-assigned:** Gebunden an einen einzelnen Dienst (App Service, VM, Function).
Wird bei Loeschen des Dienstes automatisch geloescht.

**User-assigned:** Eigenstaendige Ressource, mehreren Diensten zuweisbar.

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Kein Passwort! DefaultAzureCredential erkennt Managed Identity automatisch
credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://mein-vault.vault.azure.net", credential=credential)
secret = client.get_secret("db-password")
```

## Azure RBAC — Built-in Rollen
| Rolle | Berechtigung |
|-------|-------------|
| Owner | Alles + Zugriffsrechte vergeben |
| Contributor | Alles ausser Zugriffsrechte |
| Reader | Nur lesen |
| User Access Admin | Nur Zugriffsrechte verwalten |

```bash
# Managed Identity Contributor-Recht auf Storage geben
az role assignment create \
  --assignee <object-id-der-identity> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/.../storageAccounts/meinstorage
```

## Principle of Least Privilege
Immer minimale Rechte vergeben:
- Nicht Owner wenn Contributor reicht
- Nicht Subscription-Scope wenn Resource Group reicht

**Merke:** Managed Identity = Passwortlos; RBAC = Wer darf was auf welcher Ressource$C$,
   '["Azure","Managed Identity","RBAC","IAM","Sicherheit"]', 'Sicherheit'),

  (v_azure, v_uid, 'Azure Migration — Cloud Adoption Framework',
$C$Wie migriert man On-Premise-Workloads nach Azure?

## Cloud Adoption Framework (CAF)
Microsofts Leitfaden fuer Azure-Adoptionen — 6 Phasen:

```
Strategy → Plan → Ready → Adopt → Govern → Manage
```

**Strategy:** Warum Cloud? Ziele, Business Case, Stakeholder
**Plan:** Inventar, Priorisierung, Roadmap
**Ready:** Landing Zone aufbauen (Netzwerk, IAM, Policies)
**Adopt:** Migrieren oder Modernisieren
**Govern:** Compliance, Kosten, Security
**Manage:** Betrieb, Monitoring, Optimierung

## 5 R's der Migration

| Strategie | Beschreibung | Wann? |
|-----------|-------------|-------|
| **Rehost** (Lift & Shift) | VM 1:1 in Azure IaaS | Schnell, wenig Risiko |
| **Refactor** | Minimale Code-Aenderungen (z.B. → App Service) | Etwas mehr Aufwand, PaaS-Vorteile |
| **Rearchitect** | Grundlegende Architekturanpassung (→ Microservices) | Groesster Aufwand |
| **Rebuild** | Neu bauen cloud-nativ | Von Grund auf neu |
| **Retire** | Abschalten (nicht mehr benoetigt) | Einfachste Option |

## Azure Migrate
Kostenloser Dienst fuer Bestandsaufnahme und Migrationsplanung:
- Erkennt VMs, Datenbanken, Web-Apps
- Berechnet Azure-Kosten
- Erstellt Abhaengigkeitskarte

**Merke:** Rehost = schnell; Rearchitect = aufwending aber cloud-optimal; Retire = vergessen!$C$,
   '["Azure","Migration","CAF","Cloud","5R"]', 'Migration');

  -- ════════════════════════════════════════════════════════════════
  -- KUBERNETES — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_kubernetes, v_uid, 'Kubernetes Architektur — Control Plane & Nodes',
$C$Kubernetes besteht aus zwei Typen von Komponenten: **Control Plane** (Steuerung) und **Worker Nodes** (Ausfuehrung).

## Control Plane Komponenten
```
┌──────────────────────── Control Plane ────────────────────────┐
│                                                               │
│  kube-apiserver   etcd   kube-scheduler   kube-controller-mgr │
│       |             |          |                  |           │
└───────|─────────────|──────────|──────────────────|───────────┘
        |             |          |                  |
        └─────────────┴──────────┴──────────────────┘
                              |
              ┌───────────────┴───────────────┐
              │          Worker Nodes          │
              │  kubelet  kube-proxy  Pods    │
              └───────────────────────────────┘
```

**kube-apiserver:** Einziger Einstiegspunkt — alle Befehle gehen hier durch (kubectl, Controller).

**etcd:** Verteilte Key-Value-DB — das Gehirn von Kubernetes, speichert den gesamten Cluster-Zustand.

**kube-scheduler:** Entscheidet auf welchem Node ein neuer Pod laeuft (Ressourcen, Affinitaet, Taints).

**kube-controller-manager:** Mehrere Controller die den gewuenschten Zustand durchsetzen:
- ReplicaSet Controller: haelt gewuenschte Pod-Anzahl
- Node Controller: reagiert auf ausgefallene Nodes
- Deployment Controller: verwaltet Rolling Updates

**cloud-controller-manager:** Cloud-spezifisch — provisioniert Load Balancer, Volumes.

## Worker Node Komponenten
**kubelet:** Laeuft auf jedem Node — empfaengt Pod-Spezifikationen vom API-Server und startet Container.

**kube-proxy:** Netzwerkregeln auf dem Node — implementiert Service-IP-Weiterleitung.

**Container Runtime:** Fuehrt Container aus (containerd, CRI-O — Docker ist veraltet).

## Deklarativer Ansatz
Du sagst WAS du willst (gewuenschter Zustand) — Kubernetes macht es (aktueller Zustand → gewuenschter Zustand):
```
Ich will 3 Replicas → ReplicaSet Controller zaehlt → 2 laufen → startet 1 neuen
```

**Merke:** etcd = Wahrheit; apiserver = einziger Zugang; kubelet = lokaler Agent auf Node$C$,
   '["Kubernetes","Architektur","Control Plane","etcd","kubelet"]', 'Architektur'),

  (v_kubernetes, v_uid, 'Kubernetes Services (ClusterIP, NodePort, LoadBalancer)',
$C$**Services** geben Pods eine stabile IP-Adresse und DNS-Namen — Pods koennen jederzeit sterben und neu starten.

## Problem ohne Service
Pod-IPs aendern sich bei Neustarts → andere Pods koennen sich nicht darauf verlassen.

## Service-Typen

**ClusterIP (Standard) — intern**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  type: ClusterIP
  selector:
    app: api               # trifft alle Pods mit Label app=api
  ports:
  - port: 80               # Service-Port
    targetPort: 8080       # Pod-Port
```
Nur innerhalb des Clusters erreichbar. DNS: `api-service.namespace.svc.cluster.local`

**NodePort — extern ueber Node**
```yaml
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080        # Port auf jedem Node (30000-32767)
```
Erreichbar: `http://<node-ip>:30080` — fuer Dev/Test.

**LoadBalancer — extern ueber Cloud LB**
```yaml
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
```
Erstellt automatisch einen Cloud-Load-Balancer (Azure LB, AWS ELB). Erhaelt externe IP.

**ExternalName — DNS-Alias**
Leitet auf externen DNS-Namen um:
```yaml
spec:
  type: ExternalName
  externalName: meine-datenbank.rds.amazonaws.com
```

## Headless Service
`clusterIP: None` → DNS gibt direkt Pod-IPs zurueck (fuer StatefulSets).

**Merke:** ClusterIP = intern; NodePort = Node-IP + Port; LoadBalancer = eigene externe IP via Cloud$C$,
   '["Kubernetes","Service","ClusterIP","LoadBalancer","Netzwerk"]', 'Netzwerk'),

  (v_kubernetes, v_uid, 'Kubernetes StatefulSets',
$C$**StatefulSets** verwalten Pods mit stabiler Identitaet — notwendig fuer zustandsbehaftete Anwendungen.

## Deployment vs. StatefulSet
| | Deployment | StatefulSet |
|--|-----------|------------|
| Pod-Namen | `web-abc12` (zufaellig) | `db-0`, `db-1`, `db-2` |
| Reihenfolge | Beliebig | Geordnet (0, 1, 2 ...) |
| Storage | Geteilt | Pro Pod eigenes PVC |
| Skalierung | Parallel | Einer nach dem anderen |

## Anwendungsfaelle
- Datenbanken (PostgreSQL Cluster, MySQL, Cassandra)
- Message Broker (Kafka, RabbitMQ)
- Verteilte Systeme mit Quorum (etcd, ZooKeeper)

## Beispiel
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: "postgres"
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:              # jeder Pod bekommt eigenes PVC!
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

Pods heissen: `postgres-0`, `postgres-1`, `postgres-2`
DNS: `postgres-0.postgres.default.svc.cluster.local`

**Merke:** StatefulSet = stabile Identitaet + eigener Storage pro Pod; fuer DBs und Cluster-Anwendungen$C$,
   '["Kubernetes","StatefulSet","Datenbank","Storage","Zustand"]', 'Workloads'),

  (v_kubernetes, v_uid, 'Kubernetes NetworkPolicy',
$C$**NetworkPolicies** steuern welche Pods miteinander kommunizieren duerfen (Micro-Segmentierung).

## Default-Verhalten
Ohne NetworkPolicy: **alle Pods koennen mit allen kommunizieren** — kein Schutz!

## NetworkPolicy aktivieren
Benoetigt ein CNI-Plugin das NetworkPolicies unterstuetzt (Calico, Cilium, Weave).

## Beispiel: Datenbank nur von API erreichbar
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-nur-von-api
  namespace: produktion
spec:
  podSelector:
    matchLabels:
      app: database          # gilt fuer alle Pods mit app=database
  policyTypes:
  - Ingress                  # Eingehenden Traffic einschraenken
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api           # nur api-Pods duerfen rein
    ports:
    - protocol: TCP
      port: 5432
  egress: []                 # kein ausgehender Traffic erlaubt
```

## Zero-Trust Ansatz
```yaml
# Schritt 1: Alles verbieten (Default-Deny)
spec:
  podSelector: {}          # gilt fuer alle Pods
  policyTypes: [Ingress, Egress]
  # kein ingress/egress = alles verboten

# Schritt 2: Explizit erlauben
```

## Wichtige Selektoren
- `podSelector`: Pods nach Label
- `namespaceSelector`: Pods aus bestimmtem Namespace
- `ipBlock`: IP-Adressen-Bereich (CIDR)

**Merke:** NetworkPolicy = Firewall zwischen Pods; Default = alles offen; Zero-Trust = erst alles sperren$C$,
   '["Kubernetes","NetworkPolicy","Security","Netzwerk","Zero-Trust"]', 'Sicherheit'),

  (v_kubernetes, v_uid, 'Kubernetes Operators Pattern',
$C$**Operators** erweitern Kubernetes um domainspezifisches Wissen — automatisieren komplexe, zustandsbehaftete Anwendungen.

## Was ist ein Operator?
Ein Operator = **Controller** + **Custom Resource Definition (CRD)**

Idee: Das Fachwissen eines erfahrenen Administrators als Code.

## Controller-Pattern
Kubernetes-Grundprinzip: Gewuenschter Zustand vs. Ist-Zustand:
```
Reconciliation Loop:
  1. Beobachte aktuellen Zustand
  2. Vergleiche mit gewuenschtem Zustand
  3. Handle um Unterschied zu beheben
  4. Wiederholen
```

## Custom Resource Definition (CRD)
Eigene Kubernetes-Ressourcentypen definieren:
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: postgresclusters.acid.zalan.do
spec:
  group: acid.zalan.do
  names:
    kind: postgresql
```

## Beispiel: Zalando Postgres Operator
```yaml
apiVersion: acid.zalan.do/v1
kind: postgresql
metadata:
  name: mein-postgres
spec:
  teamId: "myteam"
  volume:
    size: 10Gi
  numberOfInstances: 3
  users:
    admin: [superuser, createdb]
  databases:
    myapp: admin
  postgresql:
    version: "15"
```
→ Operator erstellt automatisch: StatefulSet, Services, Secrets, Backups, Failover!

## Bekannte Operators
- **Cert-Manager:** TLS-Zertifikate automatisch besorgen (Let's Encrypt)
- **Prometheus Operator:** Monitoring-Stack
- **Zalando Postgres Operator:** Postgres-Cluster
- **Strimzi:** Kafka auf Kubernetes

**Merke:** Operator = Kubernetes-Controller fuer komplexe Anwendungen; CRD = eigene Ressourcentypen$C$,
   '["Kubernetes","Operator","CRD","Custom Resource","Pattern"]', 'Fortgeschritten'),

  (v_kubernetes, v_uid, 'Kubernetes DaemonSet & Taints/Tolerations',
$C$Erweiterte Scheduling-Konzepte fuer besondere Anforderungen.

## DaemonSet
Stellt sicher dass **auf JEDEM Node genau ein Pod laeuft**:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd:v1.16
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

**Anwendungsfaelle:** Log-Collector (Fluentd), Monitoring-Agent (Prometheus Node Exporter), Netzwerk-Plugin.

## Taints & Tolerations
**Taint** = Node markieren: "Lande hier nur wenn du bereit bist!"

```bash
# Node tainten
kubectl taint nodes gpu-node gpu=true:NoSchedule
# NoSchedule: Kein neuer Pod ohne Toleration
# PreferNoSchedule: Lieber nicht, aber ok
# NoExecute: Bestehende Pods auch rauskicken
```

**Toleration** = Pod sagt: "Ich kann mit diesem Taint umgehen"
```yaml
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

## Node Affinity (Pods auf bestimmte Nodes)
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/arch
          operator: In
          values: [amd64]
```

**Merke:** DaemonSet = einmal pro Node; Taint = Node sagt Nein; Toleration = Pod sagt Ja trotzdem$C$,
   '["Kubernetes","DaemonSet","Taints","Tolerations","Scheduling"]', 'Workloads');

  -- ════════════════════════════════════════════════════════════════
  -- DOCKER — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_docker, v_uid, 'Docker Layer-System & Image-Cache',
$C$Docker-Images bestehen aus **schreibgeschuetzten Layern** — das Verstaendnis davon ist entscheidend fuer Performance.

## Wie Layer entstehen
Jede Anweisung im Dockerfile = neuer Layer:
```dockerfile
FROM ubuntu:22.04           # Layer 1: Base Image
RUN apt-get update          # Layer 2: apt cache
RUN apt-get install -y curl # Layer 3: curl installiert
COPY . /app                 # Layer 4: Quellcode
RUN pip install -r req.txt  # Layer 5: Python-Pakete
```

## Union File System
Alle Layer werden uebereinandergelegt (Overlay):
```
Layer 5 (rw): laufender Container (Copy-on-Write)
Layer 4 (ro): /app/...
Layer 3 (ro): /usr/bin/curl
Layer 2 (ro): apt-cache
Layer 1 (ro): Ubuntu-Basisimage
```

## Layer-Caching
Docker cached Layer — ein Layer wird nur neu gebaut wenn er sich oder ein vorheriger Layer aendert:

```dockerfile
# SCHLECHT: Code-Aenderung invalidiert npm install Layer
COPY . .
RUN npm install

# GUT: package.json selten aendernd → npm install aus Cache
COPY package*.json ./
RUN npm install       # bleibt gecacht wenn package.json unveraendert
COPY . .              # nur dieser Layer wird neu
```

## Image-Groesse minimieren
```bash
docker image ls          # Groessen anzeigen
docker history mein-image:latest  # Layer-Groessen anzeigen

# Unnoetige Layer zusammenfassen (Squash)
docker build --squash -t mein-image .
```

## .dockerignore
Verhindert dass unnoetiger Context zum Docker Daemon geschickt wird:
```
node_modules/    # gross, wird im Container sowieso neu installiert
.git/            # Git-Historie nicht noetig
*.log
.env             # Secrets!
dist/            # Build-Artefakte (werden im Container gebaut)
```

**Merke:** Selten-aendernde Schichten zuerst; .dockerignore pflegen; `docker history` zeigt Layer-Groessen$C$,
   '["Docker","Layer","Cache","Optimierung","Dockerfile"]', 'Grundlagen'),

  (v_docker, v_uid, 'Docker Swarm & Container-Orchestrierung',
$C$**Docker Swarm** ist Dockers eingebaute Orchestrierungsloesung fuer Multi-Host-Container-Deployments.

## Swarm vs. Kubernetes
| | Docker Swarm | Kubernetes |
|--|-------------|-----------|
| Einstieg | Sehr einfach | Komplexer |
| Funktionsumfang | Begrenzt | Riesig |
| Community | Klein | Riesig |
| Produktionseinsatz | Nimmt ab | Standard |

## Swarm initialisieren
```bash
# Manager-Node
docker swarm init --advertise-addr 192.168.1.1
# Ausgabe: docker swarm join --token SWMTKN-... 192.168.1.1:2377

# Worker-Node beitreten
docker swarm join --token SWMTKN-... 192.168.1.1:2377

# Cluster-Status
docker node ls
```

## Service deployen
```bash
# Service mit 3 Replicas erstellen
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  nginx:latest

# Skalieren
docker service scale web=5

# Rolling Update
docker service update --image nginx:1.25 web
```

## Stack (docker-compose fuer Swarm)
```yaml
# docker-compose.yml
services:
  web:
    image: nginx:latest
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
```
```bash
docker stack deploy -c docker-compose.yml mein-stack
```

**Merke:** Swarm = einfaches Multi-Host-Deployment; fuer grosse Produktionssysteme Kubernetes bevorzugen$C$,
   '["Docker","Swarm","Orchestrierung","Multi-Host","Stack"]', 'Orchestrierung'),

  (v_docker, v_uid, 'Docker Resource Limits & Stats',
$C$Ohne Limits kann ein einziger Container den gesamten Host blockieren.

## CPU-Limits
```bash
# --cpus: Anzahl CPU-Kerne (dezimal erlaubt)
docker run --cpus="1.5" mein-image   # max 1,5 Kerne

# --cpu-shares: Relatives Gewicht (default 1024)
docker run --cpu-shares=512 mein-image  # halb so viel wie default
```

## Memory-Limits
```bash
# --memory: Hardlimit
docker run --memory="512m" mein-image

# --memory-swap: Swap (memory + swap zusammen)
docker run --memory="512m" --memory-swap="1g" mein-image
# Swap = 1g - 512m = 512m Swap

# Kein Swap:
docker run --memory="512m" --memory-swap="512m" mein-image
```

**OOMKilled:** Ueberschreitet ein Container das Memory-Limit → Kernel killt ihn (Out of Memory).

## In docker-compose
```yaml
services:
  api:
    image: meine-api:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:    # Mindestgarantie
          cpus: '0.25'
          memory: 128M
```

## Monitoring
```bash
# Live-Statistiken aller Container
docker stats

# Bestimmter Container
docker stats mein-container

# Einmaliger Snapshot (kein Stream)
docker stats --no-stream
```

Ausgabe: CPU%, Memory Usage/Limit, Network I/O, Block I/O, PIDs

## Warum wichtig?
- Verhindert "noisy neighbor" Probleme
- Kubernetes Resource Requests/Limits basieren auf demselben Konzept
- Basis fuer Kostenoptimierung (nur was benoetigt)

**Merke:** Immer Memory-Limits setzen; OOMKilled = Container hat Limit ueberschritten; docker stats = live monitoring$C$,
   '["Docker","Resources","Limits","CPU","Memory"]', 'Betrieb'),

  (v_docker, v_uid, 'Container-Registries — Docker Hub & Private',
$C$**Container Registries** sind Speicherorte fuer Docker-Images.

## Docker Hub (public)
Die standard oeffentliche Registry:
```bash
# Login
docker login

# Image taggen (Konvention: user/repository:tag)
docker tag mein-image:latest maxmuster/mein-image:1.0.0

# Pushen
docker push maxmuster/mein-image:1.0.0

# Pullen
docker pull maxmuster/mein-image:1.0.0

# Offizielles Image (kein Username)
docker pull nginx:1.25
docker pull postgres:15-alpine
```

## Azure Container Registry (ACR)
Private Registry in Azure:
```bash
# ACR erstellen
az acr create --name meineacr --resource-group meine-rg --sku Basic

# Login
az acr login --name meineacr

# Image pushen
docker tag mein-image meineacr.azurecr.io/mein-image:1.0
docker push meineacr.azurecr.io/mein-image:1.0

# AKS mit ACR verbinden
az aks update --attach-acr meineacr --resource-group meine-rg --name mein-cluster
```

## GitHub Container Registry (ghcr.io)
```bash
docker login ghcr.io -u USERNAME -p GITHUB_TOKEN
docker push ghcr.io/USERNAME/REPO:TAG
```

## Image-Tagging Strategien
```bash
# Semantische Versionierung (empfohlen)
mein-image:1.2.3
mein-image:1.2       # Alias auf neueste 1.2.x
mein-image:1         # Alias auf neueste 1.x.x
mein-image:latest    # KEIN latest in Produktion!

# Git-Commit SHA (eindeutig, immutabel)
mein-image:abc1234f

# Branch-basiert (fuer CI/CD)
mein-image:main
mein-image:feature-xyz
```

**Merke:** Latest in Produktion vermeiden; SHA-Tags fuer Reproduzierbarkeit; ACR fuer private Azure-Images$C$,
   '["Docker","Registry","Docker Hub","ACR","Images"]', 'Grundlagen');

  -- ════════════════════════════════════════════════════════════════
  -- DEVOPS — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_devops, v_uid, 'Ansible Grundlagen',
$C$**Ansible** ist ein agentenloses Automatisierungstool fuer Konfigurationsmanagement, Deployments und Provisionierung.

## Warum Ansible?
- **Agentless:** Kein Agent auf dem Ziel-Server noetig — nur SSH
- **Idempotent:** Mehrfach ausfuehren = gleicher Endzustand
- **YAML-basiert:** Leicht lesbar, kein Code noetig
- **Push-Modell:** Steuert von einer Zentrale aus

## Kern-Konzepte

**Inventory:** Liste der Ziel-Server
```ini
[webserver]
web01.example.com
web02.example.com

[datenbank]
db01.example.com

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**Playbook:** YAML-Datei mit Aufgaben (Tasks):
```yaml
---
- name: Webserver einrichten
  hosts: webserver
  become: true          # sudo
  vars:
    app_port: 8080

  tasks:
  - name: Nginx installieren
    apt:
      name: nginx
      state: present    # idempotent: installiert wenn nicht vorhanden
      update_cache: true

  - name: Nginx starten und aktivieren
    service:
      name: nginx
      state: started
      enabled: true

  - name: Konfiguration kopieren
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: nginx neustarten     # Handler aufrufen

  handlers:
  - name: nginx neustarten
    service:
      name: nginx
      state: restarted
```

**Roles:** Wiederverwendbare Playbook-Module (fuer nginx, postgres, etc.)

```bash
# Playbook ausfuehren
ansible-playbook -i inventory.ini webserver.yml

# Trockenlauf (kein Aendern)
ansible-playbook --check webserver.yml
```

**Merke:** Ansible = agentlos, idempotent, YAML; Playbook = Was; Inventory = Wo; Role = Wiederverwendbarkeit$C$,
   '["Ansible","IaC","Automatisierung","Konfigurationsmanagement","DevOps"]', 'IaC'),

  (v_devops, v_uid, 'Prometheus & Grafana',
$C$**Prometheus** + **Grafana** ist der Standard-Monitoring-Stack in modernen Infrastrukturen.

## Prometheus — Metriken sammeln
Pull-basiertes Monitoring: Prometheus scraped Endpoints regelmaessig.

**Architektur:**
```
App (Metrics Endpoint /metrics) ← Prometheus scrapet alle 15s → Speicher (TSDB)
                                                                       ↓
                                                            AlertManager → Slack/PagerDuty
                                                                       ↓
                                                                  Grafana (Dashboards)
```

**Metrics-Typen:**
- **Counter:** Zaehlt monoton hoch (`http_requests_total`)
- **Gauge:** Kann steigen und fallen (`cpu_usage_percent`)
- **Histogram:** Verteilung von Werten (`http_request_duration_seconds`)
- **Summary:** Wie Histogram, aber Quantile auf Client-Seite

**PromQL (Prometheus Query Language):**
```promql
# Requests pro Sekunde (rate ueber 5 Minuten)
rate(http_requests_total[5m])

# Fehlerrate (5xx)
sum(rate(http_requests_total{status=~"5.."}[5m]))
  / sum(rate(http_requests_total[5m]))

# p95 Response-Zeit
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# CPU-Auslastung
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

## Grafana — Visualisierung
- Verbindet sich mit Prometheus als Datasource
- Dashboards aus fertigen Templates (grafana.com/dashboards)
- Alerting direkt in Grafana moeglich

```bash
# Prometheus + Grafana via Helm installieren (Kubernetes)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus prometheus-community/kube-prometheus-stack
```

**Merke:** Prometheus = Metriken sammeln (PromQL); Grafana = visualisieren; Beide zusammen = vollstaendiges Monitoring$C$,
   '["Prometheus","Grafana","Monitoring","Metriken","PromQL"]', 'Monitoring'),

  (v_devops, v_uid, 'Platform Engineering & Internal Developer Platform',
$C$**Platform Engineering** baut eine **Internal Developer Platform (IDP)** die Entwickler produktiver macht.

## Was ist Platform Engineering?
> Platform Engineering ist die Disziplin des Aufbaus und Betriebs von Self-Service-Infrastruktur-Plattformen fuer Software-Entwicklungsteams.

## Problem: Cognitive Load
Entwickler sollen Code schreiben — aber muessen sich mit Kubernetes, CI/CD, Monitoring, Security, Netzwerk auskennen.
→ Platform Engineering nimmt diese Komplexitaet weg.

## Internal Developer Platform (IDP)

```
Entwickler → Self-Service Portal → IDP
                                    ├── Cloud-Ressourcen (Terraform)
                                    ├── Kubernetes-Deployments
                                    ├── CI/CD-Pipelines
                                    ├── Monitoring/Logging
                                    └── Secrets Management
```

**Golden Path:** Empfohlener, vorgefertigter Weg zum Deployment — "Es soll einfach funktionieren."

## Bekannte IDP-Tools
- **Backstage (Spotify):** Developer Portal, Service Katalog, Documentation
- **Port:** No-Code IDP Builder
- **Humanitec:** IDP-Plattform

## Team Topologies
Buch-Konzept fuer optimale Team-Strukturen:
- **Stream-aligned Teams:** Produkt-Teams (End-to-End-Verantwortung)
- **Platform Team:** Baut die IDP, reduziert Cognitive Load
- **Enabling Team:** Hilft anderen Teams, neue Faehigkeiten zu lernen
- **Complicated-Subsystem Team:** Spezialistenwissen (ML, Security)

## Erfolgsmetriken
- Deployment-Frequenz steigt
- Zeit vom Commit bis Production sinkt
- Entwickler-Zufriedenheit steigt

**Merke:** Platform Engineering = Infrastruktur-Komplexitaet vom Entwickler nehmen; IDP = Self-Service-Portal$C$,
   '["Platform Engineering","IDP","DevOps","Backstage","Team Topologies"]', 'Kultur'),

  (v_devops, v_uid, 'Chaos Engineering',
$C$**Chaos Engineering** prueft die Resilienz von Systemen durch kontrolliertes Einfuehren von Fehlern.

## Definition
> "Chaos Engineering is the discipline of experimenting on a system to build confidence in the system's capability to withstand turbulent conditions in production." — Principles of Chaos Engineering

## Pionier: Netflix Chaos Monkey
Netflix schaltet zufaellig Produktions-Server ab — um sicherzustellen, dass das System trotzdem laeuft.

## Chaos Engineering Prozess
1. **Steady State definieren:** Was ist normales Systemverhalten? (KPIs, SLIs)
2. **Hypothese aufstellen:** "Wenn Server X ausfaellt, faellt der Service nicht aus."
3. **Experiment entwerfen:** Welchen Fehler einfuehren?
4. **Experiment ausfuehren:** In Staging, dann Production
5. **Ergebnis analysieren:** Steady State wiederhergestellt?
6. **Schwachstellen beheben:** Erkannte Probleme fixen

## Chaos-Experimente-Typen
| Experiment | Beschreibung |
|-----------|-------------|
| **Pod Kill** | Zufaellige Kubernetes-Pods beenden |
| **CPU Stress** | CPU 100% auslasten |
| **Network Latency** | Kuenstliche Netzwerkverzoegerung einbauen |
| **Network Partition** | Netzwerkverbindung trennen |
| **DNS Failure** | DNS-Aufloesung blockieren |
| **Disk Fill** | Festplatte vollfuellen |

## Tools
- **Chaos Monkey (Netflix):** VM-Chaos in AWS
- **LitmusChaos:** Kubernetes-nativer Chaos-Framework
- **Gremlin:** Kommerzielles Tool
- **Azure Chaos Studio:** Azure-native Chaos-Experimente

```yaml
# LitmusChaos Experiment
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: nginx-chaos
spec:
  appinfo:
    appns: produktion
    applabel: app=nginx
  chaosServiceAccount: litmus-admin
  experiments:
  - name: pod-delete
    spec:
      components:
        env:
        - name: TOTAL_CHAOS_DURATION
          value: "30"
```

**Merke:** Chaos Engineering = kontrollierte Fehler in Produktion; Ziel = Schwachstellen VOR Kunden finden$C$,
   '["Chaos Engineering","Resilience","Netflix","LitmusChaos","SRE"]', 'SRE'),

  (v_devops, v_uid, 'DevSecOps — Security in der Pipeline',
$C$**DevSecOps** integriert Sicherheit in jeden Schritt des DevOps-Zyklus — nicht am Ende.

## Shift Left Security
Sicherheit so frueh wie moeglich im Prozess:
```
Frueh (guenstig):    Code → Build → Test → Stage → Prod (teuer)
                      ↑ Hier Security-Checks einbauen!
```

## Security-Checks in der CI/CD-Pipeline

**Pre-Commit Hooks:**
```bash
# .pre-commit-config.yaml
repos:
- repo: https://github.com/gitleaks/gitleaks
  rev: v8.18.0
  hooks:
  - id: gitleaks    # Secrets im Code finden
```

**SAST (Static Application Security Testing):**
Code analysieren ohne Ausfuehren:
```yaml
- name: SonarQube Scan
  uses: sonarsource/sonarqube-scan-action@master
  env:
    SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

**Dependency Scanning:**
```bash
npm audit --audit-level=high
pip-audit
trivy fs . --severity HIGH,CRITICAL
```

**Container Image Scanning:**
```bash
trivy image --exit-code 1 --severity CRITICAL mein-image:latest
# exit-code 1 = Pipeline bricht ab bei Findings!
```

**DAST (Dynamic Application Security Testing):**
Laufende Anwendung testen (OWASP ZAP):
```yaml
- name: OWASP ZAP Scan
  uses: zaproxy/action-full-scan@v0.7.0
  with:
    target: 'https://staging.meine-app.de'
```

## Security Gates
Pipeline darf nicht in Produktion wenn:
- CRITICAL CVEs im Image
- Secrets im Code gefunden
- OWASP Top 10 Schwachstelle gefunden

**Merke:** DevSecOps = Security als Code; frueh eingebaut ist 100x billiger als nach Deployment$C$,
   '["DevSecOps","Security","SAST","DAST","Pipeline"]', 'Sicherheit');

  -- ════════════════════════════════════════════════════════════════
  -- REQUIREMENTS ENGINEERING — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_re, v_uid, 'UML Sequenzdiagramm',
$C$Das **Sequenzdiagramm** zeigt die zeitliche Abfolge von Nachrichten zwischen Objekten.

## Elemente
- **Lebenslinie (Lifeline):** Vertikale gestrichelte Linie pro Objekt/System
- **Aktivierungsbalken:** Zeigt wann Objekt aktiv ist
- **Nachricht (Pfeil):** Synchron (—>), Asynchron (---->), Antwort (gestrichelt)
- **Alt/Opt/Loop:** Kombinierte Fragmente fuer Bedingungen und Schleifen

## Beispiel: Login-Prozess
```
:Nutzer        :Browser       :AuthService   :Datenbank
   |               |               |               |
   |--POST /login->|               |               |
   |               |--authenticate(user,pw)------->|
   |               |               |               |
   |               |  [valide]     |<--user_data---|
   |               |<--JWT Token---|               |
   |<--200 OK------|               |               |
   |               |               |               |
```

## Kombinierte Fragmente
```
alt [Passwort korrekt]
  AuthService -> Browser: JWT Token
else [Passwort falsch]
  AuthService -> Browser: 401 Unauthorized
end

opt [User eingeloggt]
  Browser -> Profil: Lade Benutzerdaten
end

loop [1..5 Versuche]
  Nutzer -> Browser: Passwort eingeben
end
```

## Wann benutzen?
- API-Interaktionen dokumentieren
- Microservice-Kommunikation zeigen
- Login/Checkout-Flows visualisieren

**Merke:** Sequenzdiagramm = WER macht WANN in welcher REIHENFOLGE WAS; Zeitachse laeuft von oben nach unten$C$,
   '["UML","Sequenzdiagramm","Modellierung","Architektur","RE"]', 'UML'),

  (v_re, v_uid, 'UML Aktivitaetsdiagramm',
$C$Das **Aktivitaetsdiagramm** zeigt den Ablauf von Aktivitaeten (Geschaeftsprozesse, Algorithmen, Use-Cases).

## Elemente
- **Startknoten** (ausgefuellter Kreis): Beginn
- **Aktivitaet** (abgerundetes Rechteck): Aktion/Schritt
- **Entscheidungsknoten** (Raute): Verzweigung mit Guard `[Bedingung]`
- **Synchronisierungsbalken** (fetter Balken): Fork (parallel starten) / Join (parallel beenden)
- **Endknoten** (Kreis im Kreis): Ablauf-Ende

## Beispiel: Bestellprozess
```
●  Start
↓
[Warenkorb befuellen]
↓
◇  [Bezahlen?]
|   |
|   └─[per Kreditkarte]──→ [Kreditkarte belasten]──┐
|                                                   |
└─[per Rechnung]──→ [Rechnung erstellen]────────────┤
                                                    ↓
                                          [Bestellung bestaetigen]
                                                    ↓
                                                ◎ Ende
```

## Swimlanes (Verantwortlichkeiten)
```
| Kunde     | System    | Lager     |
|-----------|-----------|-----------|
| Bestellen |           |           |
|           | Pruefen   |           |
|           | Bestaetigen|          |
|           |           | Kommission|
|           |           | Versenden |
```

## Aktivitaet vs. Sequenz?
- **Aktivitaet:** WAS passiert (Ablauf, Entscheidungen, Parallelitaet)
- **Sequenz:** WER schickt welche Nachricht an WEN

**Merke:** Aktivitaetsdiagramm = Flussdiagramm auf Steroiden; Raute = Entscheidung; dicker Balken = parallel$C$,
   '["UML","Aktivitaetsdiagramm","Modellierung","Prozess","RE"]', 'UML'),

  (v_re, v_uid, 'UML Zustandsdiagramm (State Machine)',
$C$Das **Zustandsdiagramm** modelliert das Verhalten eines Objekts als Abfolge von Zustaenden.

## Elemente
- **Zustand (State):** Abgerundetes Rechteck — was ist das Objekt gerade?
- **Transition:** Pfeil mit `Ereignis [Guard] / Aktion`
- **Startzustand:** Ausgefuellter Kreis
- **Endzustand:** Kreis im Kreis

## Beispiel: Bestellung
```
    ●
    |
    ↓
[Neu] ──bezahlt──→ [Bezahlt] ──versandt──→ [Versandt] ──bestaetigt──→ ◎
  |                    |
  storniert         storniert
  |                    |
  ↓                    ↓
[Storniert] ←──────────┘
```

## Mit Aktionen
```
Zustand: [Verarbeitung]
  entry: Benachrichtigung senden
  do:    Zahlung verarbeiten
  exit:  Log-Eintrag schreiben
```

## Hierarchische Zustaende
Zustaende koennen Unterzustaende enthalten (Composite States):
```
[Aktiv]
  ├── [Tippen]
  ├── [Senden]
  └── [Warten]
  ESC → [Inaktiv] (egal in welchem Unterzustand)
```

## Wann benutzen?
- Objekte mit mehreren Lebensphasen (Bestellung, Ticket, User-Account)
- Validierungslogik verstehen (Welche Uebergaenge sind erlaubt?)
- Protokolle und Workflows

**Merke:** Zustandsdiagramm = Lebenszyklus eines Objekts; Transition = Ereignis das Zustand aendert$C$,
   '["UML","Zustandsdiagramm","State Machine","Modellierung","RE"]', 'UML'),

  (v_re, v_uid, 'Nicht-Funktionale Anforderungen & ISO 25010',
$C$**Nicht-Funktionale Anforderungen (NFRs)** beschreiben WIE gut ein System etwas tut — nicht WAS es tut.

## Funktional vs. Nicht-Funktional
| Funktional | Nicht-Funktional |
|-----------|-----------------|
| "Nutzer kann sich einloggen" | "Login dauert unter 2 Sekunden" |
| "System speichert Bestellungen" | "Daten werden DSGVO-konform gespeichert" |
| "Admin kann Nutzer loeschen" | "System ist 99,9% verfuegbar" |

## ISO 25010 — Qualitaetsmerkmale
Das internationale Standardmodell fuer Software-Qualitaet:

| Merkmal | Deutsch | Beispiel |
|---------|---------|---------|
| **Functional Suitability** | Funktionale Eignung | Vollstaendigkeit der Funktionen |
| **Performance Efficiency** | Leistungseffizienz | Antwortzeit, Durchsatz, Ressourcenverbrauch |
| **Compatibility** | Kompatibilitaet | Koexistenz, Interoperabilitaet |
| **Usability** | Benutzbarkeit | Erlernbarkeit, Fehlertoleranz |
| **Reliability** | Zuverlaessigkeit | Verfuegbarkeit, Fehlertoleranz, Wiederherstellbarkeit |
| **Security** | Sicherheit | Vertraulichkeit, Integritaet, Authentizitaet |
| **Maintainability** | Wartbarkeit | Testbarkeit, Modifizierbarkeit, Modularitaet |
| **Portability** | Uebertragbarkeit | Anpassbarkeit, Installierbarkeit |

## Wie NFRs formulieren? SMART-Kriterien!
```
SCHLECHT: "Das System soll schnell sein."
GUT: "Die Startseite muss innerhalb von 1,5 Sekunden laden
      (gemessen als Time to First Contentful Paint)
      bei 95% der Anfragen unter Normallast (100 gleichzeitige Nutzer)."
```

## Testbarkeit von NFRs
Jede NFR sollte messbar sein:
- **Performance:** JMeter Lasttests
- **Sicherheit:** Penetrationstest, OWASP Top 10
- **Verfuegbarkeit:** Monitoring, SLA-Berechnung
- **Usability:** Nutzertests, System Usability Scale (SUS)

**Merke:** ISO 25010 = Qualitaetsstandard; NFR = messbar und testbar formulieren; Performance + Security sind die kritischsten$C$,
   '["NFR","ISO 25010","Qualitaet","Anforderungen","RE"]', 'Qualitaet'),

  (v_re, v_uid, 'Prototyping in der Requirements-Phase',
$C$**Prototypen** helfen Anforderungen zu entdecken, zu validieren und Missverstaendnisse frueh aufzudecken.

## Warum Prototyping?
> "Kunden wissen nicht was sie wollen, bis sie es sehen."

- Missverstaendnisse aufdecken bevor Code geschrieben wird
- Feedback von Stakeholdern einsammeln
- Anforderungen konkretisieren ("Ich meine nicht das, sondern das!")

## Arten von Prototypen

**Papierprototyp (Wireframe auf Papier):**
Schnellste Methode — Stift und Papier.
Kosten: < 1 Stunde. Ideal fuer erste Ideen.

**Low-Fidelity Wireframe (Greyscale):**
Tools: Balsamiq, Figma (Wireframe-Modus), draw.io
Zeigt Struktur ohne Design-Ablenkung.

**High-Fidelity Mockup:**
Tools: Figma, Adobe XD, Sketch
Looks and feels wie das Endprodukt. Klickbares Prototyp moeglich.

**Wegwerf-Prototyp (Throwaway):**
Schnell gebaut, nie fuer Produktion — rein zum Erkunden.
Wichtig: Stakeholder KLAR kommunizieren dass es weggeworfen wird!

**Evolutionaerer Prototyp:**
Wird schrittweise zum Endprodukt — Risiko: schlechte Architektur bleibt.

## Wireframe-Elemente
```
Guten Wireframes enthalten:
☐ Navigation/Menu-Struktur
☐ Platzhalter fuer Inhalte (Lorem Ipsum)
☐ Interaktive Elemente (Buttons, Formulare)
☐ Annotations (Erklaerung von Verhalten)
☐ KEINE Farben/Fonts/Icons (vermeidet Design-Diskussionen)
```

## Im Anforderungsprozess
1. Workshop → Papierprototyp
2. Review mit Stakeholdern → Feedback
3. Digitaler Wireframe → Validierung
4. Clickable Mockup → User Testing
5. Anforderungen finalisieren → Entwicklung

**Merke:** Papierprototyp = billiger als Coding; Wegwerf-Prototyp = klar kommunizieren; Wireframes keine Farben!$C$,
   '["Prototyping","Wireframe","Mockup","Anforderungen","RE"]', 'Techniken'),

  (v_re, v_uid, 'Systemkontext & Kontextdiagramm',
$C$Das **Kontextdiagramm** zeigt das System als Black Box mit seinen externen Schnittstellen.

## Was ist der Systemkontext?
Alles was von aussen mit dem System interagiert:
- **Nachbarsysteme:** Andere IT-Systeme (ERP, CRM, Payment-Provider)
- **Akteure:** Menschen die das System nutzen (Admin, Kunde, Manager)

## Kontextdiagramm (UML Kontext)
```
           ┌─────────────┐
Kunde ────►│             │────► Buchhaltungs-
           │   Webshop   │       system
Admin ────►│  (Unser     │────► Versandlogistik
           │   System)   │
           │             │────► Zahlungs-
           └─────────────┘       gateway
                  ▲
                  │
            E-Mail-Service
```

## Arc42 — Systemkontext dokumentieren
Arc42 ist ein Template fuer Architekturdokumentation:
- Kapitel 3: Systemkontext und Abgrenzung
- Intern: Was gehoert zum System?
- Extern: Was liegt ausserhalb?

## Systemgrenzen festlegen
**Im System:** Was entwickeln WIR?
**Ausserhalb:** Was nehmen wir als gegeben? (Third-Party)

Beispiel:
```
IM System:           AUSSERHALB:
- Warenkorb          - PayPal (nehmen API)
- Bestellverwaltung  - DHL (nehmen API)
- Nutzerverwaltung   - E-Mail-Server (SMTP)
```

## Warum wichtig?
- Scope-Creep verhindern
- Schnittstellen frueh identifizieren
- Stakeholder auf gleichen Stand bringen

**Merke:** Kontextdiagramm = erster Schritt in jeder Anforderungsanalyse; zeigt WAS gehoert zu UNSEREM System$C$,
   '["Systemkontext","Kontextdiagramm","RE","Architektur","Scope"]', 'Analyse'),

  (v_re, v_uid, 'Akzeptanzkriterien & Gherkin (BDD)',
$C$**Akzeptanzkriterien** definieren wann eine User Story als "fertig" gilt.

## Was sind Akzeptanzkriterien?
Konkrete, testbare Bedingungen die erfullt sein muessen:
```
User Story:
"Als Nutzer moechte ich mich einloggen koennen,
um auf mein Konto zuzugreifen."

Akzeptanzkriterien:
✓ Mit gueltiger E-Mail und Passwort werde ich eingeloggt
✓ Bei falschem Passwort erscheint eine Fehlermeldung
✓ Nach 5 Fehlversuchen wird das Konto gesperrt
✓ "Passwort vergessen" Link fuehrt zur Wiederherstellung
✓ Login funktioniert auf Mobile-Geraeten
```

## Gherkin-Syntax (BDD — Behavior Driven Development)
```gherkin
Feature: Benutzer-Login

  Scenario: Erfolgreicher Login
    Given der Nutzer ist auf der Login-Seite
    When er eine gueltige E-Mail "max@example.com" eingibt
    And er das korrekte Passwort "Geheim123" eingibt
    And er auf "Einloggen" klickt
    Then wird er auf das Dashboard weitergeleitet
    And die Willkommensnachricht "Hallo Max!" wird angezeigt

  Scenario: Falsches Passwort
    Given der Nutzer ist auf der Login-Seite
    When er eine gueltige E-Mail eingibt
    And er ein falsches Passwort eingibt
    And er auf "Einloggen" klickt
    Then erscheint die Fehlermeldung "E-Mail oder Passwort falsch"
    And er bleibt auf der Login-Seite
```

## Tools: Cucumber, SpecFlow, Behave
Gherkin-Dateien koennen direkt in automatisierte Tests umgewandelt werden!

```python
@given("der Nutzer ist auf der Login-Seite")
def step_impl(context):
    context.browser.get("https://meine-app.de/login")

@when('er auf "Einloggen" klickt')
def step_impl(context):
    context.browser.find_element(By.ID, "login-btn").click()
```

**Merke:** Gherkin = Given/When/Then; lebende Dokumentation die gleichzeitig Test ist; BDD brueckt Fachbereich und Technik$C$,
   '["Akzeptanzkriterien","Gherkin","BDD","Testing","RE"]', 'Qualitaet');

  -- ════════════════════════════════════════════════════════════════
  -- SQL — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_sql_box, v_uid, 'SQL EXPLAIN & Abfragen optimieren',
$C$`EXPLAIN` zeigt den **Query Execution Plan** — wie die Datenbank eine Abfrage ausfuehrt.

## EXPLAIN vs. EXPLAIN ANALYZE
```sql
-- EXPLAIN: Geschaetzter Plan (fuehrt Abfrage NICHT aus)
EXPLAIN SELECT * FROM orders WHERE user_id = 42;

-- EXPLAIN ANALYZE: Echter Plan (fuehrt Abfrage AUS, mit echter Zeit)
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 42;

-- Mit Buffers (Speicher-IO anzeigen)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT ...;
```

## Plan lesen
```
Seq Scan on orders  (cost=0.00..52.15 rows=1500 width=100)
  Filter: (user_id = 42)

-- Seq Scan = SCHLECHT: Alle Zeilen durchsucht!
-- cost: Geschaetzte Kosten (0.00=Startkosten..52.15=Gesamtkosten)
-- rows: Geschaetzte Ergebniszeilen
-- width: Durchschnittliche Zeilenbreite in Bytes
```

```
Index Scan using idx_orders_user_id on orders
  (cost=0.43..8.45 rows=5 width=100)
  Index Cond: (user_id = 42)

-- Index Scan = GUT: Nutzt Index
```

## Haeufige Plan-Knoten
| Knoten | Bedeutung | Gut/Schlecht |
|--------|-----------|-------------|
| Seq Scan | Volle Tabellen-Scan | Schlecht bei grossen Tabellen |
| Index Scan | Index nutzen | Gut |
| Index Only Scan | Nur Index, keine Tabelle | Sehr gut |
| Hash Join | Groessere Joins | OK |
| Nested Loop | Kleine Ergebnismengen | Gut |
| Sort | Sortierung | Teuer ohne Index |

## Optimierung
```sql
-- Vorher: Seq Scan (langsam)
SELECT * FROM orders WHERE user_id = 42;

-- Index hinzufuegen
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Nachher: Index Scan (schnell)

-- Zusammengesetzter Index fuer Mehrfach-Filter
CREATE INDEX idx_orders_user_status
  ON orders(user_id, status)
  WHERE status != 'cancelled';  -- Partial Index

-- Statistiken aktualisieren (bei veralteten Schaetzungen)
ANALYZE orders;
```

**Merke:** EXPLAIN ANALYZE = echte Zahlen; Seq Scan auf grossen Tabellen = Index benoetigt; ANALYZE nach Massenimports$C$,
   '["SQL","EXPLAIN","Performance","Index","Optimierung"]', 'Performance'),

  (v_sql_box, v_uid, 'SQL Window Functions',
$C$**Window Functions** berechnen Werte ueber eine "Fenstermenge" von Zeilen — ohne GROUP BY Zeilen zu reduzieren.

## Syntax
```sql
funktion() OVER (
  PARTITION BY spalte1     -- Gruppen (optional)
  ORDER BY spalte2         -- Sortierung innerhalb Gruppe
  ROWS BETWEEN ...         -- Fenster-Frame (optional)
)
```

## Haeufige Window Functions

**ROW_NUMBER(), RANK(), DENSE_RANK():**
```sql
SELECT
  name,
  abteilung,
  gehalt,
  ROW_NUMBER() OVER (PARTITION BY abteilung ORDER BY gehalt DESC) AS zeile,
  RANK()       OVER (PARTITION BY abteilung ORDER BY gehalt DESC) AS rang,
  DENSE_RANK() OVER (PARTITION BY abteilung ORDER BY gehalt DESC) AS dichter_rang
FROM mitarbeiter;

-- Unterschied bei Gleichstand (beide 90000):
-- ROW_NUMBER: 1, 2, 3  (immer eindeutig)
-- RANK:       1, 1, 3  (Luecke nach Gleichstand)
-- DENSE_RANK: 1, 1, 2  (keine Luecke)
```

**LAG() / LEAD() — vorherige/naechste Zeile:**
```sql
SELECT
  monat,
  umsatz,
  LAG(umsatz) OVER (ORDER BY monat) AS vormonat,
  umsatz - LAG(umsatz) OVER (ORDER BY monat) AS veraenderung
FROM monatsumsaetze;
```

**Laufende Summe (Running Total):**
```sql
SELECT
  datum,
  betrag,
  SUM(betrag) OVER (ORDER BY datum ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS laufende_summe
FROM transaktionen;
```

**NTILE() — in N Gruppen aufteilen:**
```sql
-- Top 25% Kunden identifizieren
SELECT
  kunden_id,
  gesamtkauf,
  NTILE(4) OVER (ORDER BY gesamtkauf DESC) AS quartil
FROM kundenumsaetze;
-- quartil = 1 = top 25%
```

**FIRST_VALUE / LAST_VALUE:**
```sql
-- Hoechstes Gehalt in jeder Abteilung anzeigen
SELECT name, abteilung, gehalt,
  FIRST_VALUE(gehalt) OVER (PARTITION BY abteilung ORDER BY gehalt DESC) AS max_gehalt
FROM mitarbeiter;
```

**Merke:** Window Functions = Aggregation ohne Zeilen zu verlieren; PARTITION BY = Gruppe; ORDER BY = Reihenfolge im Fenster$C$,
   '["SQL","Window Functions","RANK","Analytics","Fortgeschritten"]', 'Fortgeschritten'),

  (v_sql_box, v_uid, 'SQL CTEs und rekursive Abfragen',
$C$**CTEs (Common Table Expressions)** mit `WITH` machen komplexe Abfragen lesbar und ermoeglichten Rekursion.

## Einfaches CTE
```sql
WITH aktive_kunden AS (
  SELECT id, name, email
  FROM kunden
  WHERE status = 'aktiv' AND letzte_bestellung > NOW() - INTERVAL '1 year'
),
umsatz_pro_kunde AS (
  SELECT kunden_id, SUM(betrag) AS gesamt
  FROM bestellungen
  WHERE datum > NOW() - INTERVAL '1 year'
  GROUP BY kunden_id
)
SELECT
  ak.name,
  ak.email,
  COALESCE(uk.gesamt, 0) AS jahresumsatz
FROM aktive_kunden ak
LEFT JOIN umsatz_pro_kunde uk ON ak.id = uk.kunden_id
ORDER BY jahresumsatz DESC;
```

## Mehrere CTEs hintereinander
```sql
WITH
  stufe1 AS (SELECT ...),
  stufe2 AS (SELECT ... FROM stufe1 WHERE ...),
  stufe3 AS (SELECT ... FROM stufe2 JOIN ... )
SELECT * FROM stufe3;
```

## Rekursive CTEs (Hierarchien)
```sql
-- Organigramm: alle Untergebenen eines Managers finden
WITH RECURSIVE org AS (
  -- Anker: Startperson
  SELECT id, name, manager_id, 0 AS ebene
  FROM mitarbeiter
  WHERE name = 'CEO'

  UNION ALL

  -- Rekursiver Teil: Untergebene finden
  SELECT m.id, m.name, m.manager_id, org.ebene + 1
  FROM mitarbeiter m
  JOIN org ON m.manager_id = org.id
)
SELECT * FROM org ORDER BY ebene, name;
```

## Verwendungsfaelle
- Hierarchien: Org-Charts, Kategorien-Baeume, Stueecklisten
- Pfade in Graphen (Kuerzester Weg)
- Sequenzgeneratoren:
```sql
WITH RECURSIVE zahlen AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM zahlen WHERE n < 100
)
SELECT n FROM zahlen;
```

**Merke:** CTE = Abfrage-Alias mit WITH; rekursiv = RECURSIVE Schluesselwort + UNION ALL + Abbruchbedingung$C$,
   '["SQL","CTE","Rekursion","WITH","Hierarchie"]', 'Fortgeschritten'),

  (v_sql_box, v_uid, 'PostgreSQL JSONB — JSON in der Datenbank',
$C$**JSONB** speichert JSON binaer in PostgreSQL — mit Indexierung und effizienten Operatoren.

## JSON vs. JSONB
| | JSON | JSONB |
|--|------|-------|
| Speicherung | Text | Binaer |
| Lesen | Schneller | Langsamer |
| Schreiben | Langsamer | Schneller |
| Indexierung | Nein | Ja (GIN Index!) |
| Schluesselreihenfolge | Erhalten | Nicht garantiert |
| Duplikat-Schluessel | Erhalten | Letzter gewinnt |

→ **In der Praxis fast immer JSONB verwenden.**

## Grundoperatoren
```sql
-- Tabelle
CREATE TABLE produkte (
  id SERIAL PRIMARY KEY,
  name TEXT,
  attribute JSONB
);

INSERT INTO produkte VALUES (1, 'Laptop', '{"farbe": "silber", "ram_gb": 16, "tags": ["premium","neu"]}');

-- Objekt-Zugriff
SELECT attribute->'ram_gb'      FROM produkte;  -- gibt JSON: 16
SELECT attribute->>'ram_gb'     FROM produkte;  -- gibt Text: "16"

-- Verschachtelt
SELECT attribute->'specs'->>'cpu' FROM produkte;

-- Array-Element
SELECT attribute->'tags'->0    FROM produkte;  -- "premium"

-- Enthaelt-Operator @>
SELECT * FROM produkte WHERE attribute @> '{"farbe": "silber"}';

-- Schluessel-Existenz-Operator ?
SELECT * FROM produkte WHERE attribute ? 'ram_gb';
```

## GIN Index
```sql
-- Index fuer alle Keys/Values
CREATE INDEX idx_produkte_attribute ON produkte USING GIN (attribute);

-- Jetzt sind @> und ? Abfragen schnell!
```

## JSON manipulieren
```sql
-- Key aktualisieren
UPDATE produkte
SET attribute = attribute || '{"ram_gb": 32}'   -- || = merge
WHERE id = 1;

-- Key loeschen
UPDATE produkte
SET attribute = attribute - 'farbe'
WHERE id = 1;

-- Array-Element hinzufuegen
UPDATE produkte
SET attribute = jsonb_set(attribute, '{tags,0}', '"gebraucht"')
WHERE id = 1;
```

**Merke:** JSONB > JSON (indexierbar); `->` gibt JSON; `->>` gibt Text; `@>` enthaelt-Operator; GIN Index noetig$C$,
   '["PostgreSQL","JSONB","JSON","NoSQL","Hybrid"]', 'Datentypen'),

  (v_sql_box, v_uid, 'SQL Transaktionen & Isolationsebenen',
$C$**Transaktionen** sichern Datenkonsistenz bei gleichzeitigen Zugriffen.

## ACID-Eigenschaften
| Eigenschaft | Bedeutung |
|------------|----------|
| **Atomicity** | Alles oder nichts — Teiloperationen nicht moeglich |
| **Consistency** | Datenbank wechselt von einem gueltigen in einen anderen gueltigen Zustand |
| **Isolation** | Gleichzeitige Transaktionen beeinflussen sich nicht |
| **Durability** | Committed = dauerhaft gespeichert (auch nach Crash) |

## Transaktion in SQL
```sql
BEGIN;
  UPDATE konten SET saldo = saldo - 100 WHERE id = 1;  -- Geld abbuchen
  UPDATE konten SET saldo = saldo + 100 WHERE id = 2;  -- Geld gutschreiben

  -- Wenn beide OK: Commit
  COMMIT;

  -- Wenn Fehler: Rollback
  ROLLBACK;
```

## Isolationsebenen (PostgreSQL)
| Ebene | Dirty Read | Non-Repeatable Read | Phantom Read |
|-------|-----------|---------------------|-------------|
| READ UNCOMMITTED | Moeglich | Moeglich | Moeglich |
| READ COMMITTED (Standard PG) | Verhindert | Moeglich | Moeglich |
| REPEATABLE READ | Verhindert | Verhindert | Verhindert |
| SERIALIZABLE | Verhindert | Verhindert | Verhindert |

```sql
-- Serializable Transaktion
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
  ...
COMMIT;
```

## Probleme bei konkurrenten Zugriffen
**Dirty Read:** T1 liest uncommitted-Daten von T2 — T2 macht Rollback → T1 hat falsche Daten.
**Non-Repeatable Read:** T1 liest Zeile zweimal — T2 aendert sie dazwischen → T1 bekommt unterschiedliche Werte.
**Phantom Read:** T1 fuehrt SELECT zweimal aus — T2 fuegt Zeile ein → T1 sieht mehr Zeilen beim zweiten Mal.

**Merke:** ACID = Korrektheitseigenschaften; Standard = READ COMMITTED; Serializable = strengste Isolation$C$,
   '["SQL","Transaktionen","ACID","Isolation","Datenbank"]', 'Grundlagen'),

  (v_sql_box, v_uid, 'SQL Datenbankdesign & Normalisierung',
$C$**Normalisierung** beseitigt Redundanz und Anomalien in relationalen Datenbanken.

## Anomalien ohne Normalisierung
```
id | name  | abt | abt_ort
1  | Max   | IT  | Berlin
2  | Anna  | IT  | Berlin
3  | Tim   | HR  | Hamburg

Problem: Abteilungs-Ort ist redundant!
- Einfuege-Anomalie: Neue Abt ohne Mitarbeiter?
- Update-Anomalie: Berlin→Munich → alle IT-Zeilen aendern!
- Loesch-Anomalie: Letzter HR-Mitarbeiter loeschen → HR-Info weg!
```

## Normalformen

**1. Normalform (1NF):** Atomare Werte, keine Gruppen
```sql
-- Schlecht: telefon = "0171, 0172"
-- Gut: eigene Zeile pro Telefonnummer
```

**2. Normalform (2NF):** 1NF + keine partiellen Abhaengigkeiten
(Jedes Nicht-Schluessel-Attribut haengt vom GANZEN Primaerschluessel ab)

**3. Normalform (3NF):** 2NF + keine transitiven Abhaengigkeiten
(Nicht-Schluessel haengt nur vom Schluessel ab, nicht von anderen Nicht-Schluesseln)

**Boyce-Codd NF (BCNF):** Verschaerfte 3NF — jeder Determinant ist Kandidatschluessel.

## Beispiel: 3NF erreichen
```sql
-- Vorher (nicht 3NF — abt_ort haengt von abt ab, nicht von id)
mitarbeiter(id, name, abt, abt_ort)

-- Nachher (3NF)
mitarbeiter(id, name, abt_id)
abteilungen(id, name, ort)
```

## Denormalisierung
Manchmal bewusst denormalisieren fuer Performance:
- Data Warehouses nutzen Star Schema (denormalisiert)
- Lesehaeufige Systeme cachen berechnete Werte

**Merke:** 3NF = jedes Attribut haengt nur vom Primaerschluessel ab; Normalisierung = Schreibsysteme; Denormalisierung = Lesesysteme$C$,
   '["SQL","Normalisierung","Datenbankdesign","3NF","Datenmodell"]', 'Design');

  -- ════════════════════════════════════════════════════════════════
  -- BUSINESS INTELLIGENCE — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_bi_box, v_uid, 'Data Warehouse Architektur',
$C$Ein **Data Warehouse (DWH)** ist eine zentrale Datenablage fuer analytische Zwecke — optimiert fuer Lesezugriffe und Reporting.

## OLTP vs. OLAP
| | OLTP (Transaktional) | OLAP (Analytisch) |
|--|---------------------|-------------------|
| Zweck | Taegliche Operationen | Analyse und Reporting |
| Beispiel | Webshop, ERP, CRM | Sales-Dashboard, KPI-Bericht |
| Abfragen | Viele, kleine, schnelle | Wenige, grosse, komplexe |
| Datenvolumen | GB | TB bis PB |
| Schema | Normalisiert | Denormalisiert |

## Data Warehouse Architektur

```
Quelldaten              ETL/ELT              Data Warehouse
(CRM, ERP, Webshop) → Extrakt → Transform → Load → (DWH)
                                                       ↓
                                                   Data Marts
                                              (Sales, Marketing)
                                                       ↓
                                              BI-Tools (Tableau,
                                              Power BI, Looker)
```

## Staging → Core → Data Mart Schichten
- **Staging:** Rohdaten 1:1 aus Quellsystemen (keine Transformation)
- **Core/Integration Layer:** Bereinigt, harmonisiert, historisiert (SCD)
- **Data Mart:** Fachabteilungs-spezifische, aggregierte Sichten

## Star Schema vs. Snowflake Schema
**Star Schema:** Faktentabelle in der Mitte, Dimensionen direkt angefuegt:
```
      dim_Zeit
         |
dim_Produkt — fakt_Verkauf — dim_Kunde
         |
      dim_Region
```
Einfach, gut fuer BI-Tools optimiert.

**Snowflake Schema:** Dimensionen weiter normalisiert (Unterebenen).
Weniger Redundanz, aber komplexere Joins.

**Merke:** DWH = analytisches System; OLAP fuer Abfragen; Star Schema = einfach und schnell fuer BI$C$,
   '["BI","Data Warehouse","OLAP","Star Schema","Architektur"]', 'Architektur'),

  (v_bi_box, v_uid, 'ETL vs. ELT — Datentransformation',
$C$**ETL** und **ELT** sind Muster um Daten von Quellsystemen in ein Data Warehouse zu laden.

## ETL — Extract, Transform, Load
```
Quelle → [Extract] → [Transform (aussen)] → [Load] → DWH
```
- Transform passiert ausserhalb des DWH (auf eigenem ETL-Server)
- Klassisch fuer On-Premise DWH (Oracle, SQL Server)
- Tools: Talend, Informatica, SSIS

## ELT — Extract, Load, Transform
```
Quelle → [Extract] → [Load] → DWH → [Transform (im DWH)]
```
- Rohdaten erst ins DWH laden, DANN transformieren
- Nutzt Rechenleistung des DWH (Snowflake, BigQuery, Redshift)
- Modern, Cloud-First

## Modern Data Stack (ELT-Ansatz)
```
Quellen → Fivetran/Airbyte → Snowflake/BigQuery → dbt → BI-Tool
          (Extrakt+Load)    (Storage + Engine)   (Transform)
```

**dbt (data build tool):**
SQL-basierte Transformationsschicht:
```sql
-- models/stg_orders.sql
SELECT
  id AS order_id,
  customer_id,
  amount / 100.0 AS amount_eur,  -- Cent → Euro
  created_at::DATE AS order_date
FROM raw.orders
WHERE status != 'cancelled'
```
```bash
dbt run    # Alle Models ausfuehren
dbt test   # Datentests ausfuehren
dbt docs generate  # Automatische Dokumentation
```

## SCD — Slowly Changing Dimensions
Wie historische Aenderungen in Dimensionstabellen speichern?
- **SCD Typ 1:** Ueberschreiben (kein History)
- **SCD Typ 2:** Neue Zeile pro Aenderung (+ gueltig_von, gueltig_bis)
- **SCD Typ 3:** Zusatzkolumne fuer "alten Wert"

**Merke:** ETL = Transform vor Load; ELT = Transform nach Load (im DWH); dbt = moderner ELT-Standard$C$,
   '["BI","ETL","ELT","dbt","Data Pipeline"]', 'Datenintegration'),

  (v_bi_box, v_uid, 'Power BI Grundkonzepte',
$C$**Power BI** ist Microsofts BI-Tool fuer interaktive Dashboards und Reports.

## Architektur-Komponenten
```
Power BI Desktop (Entwicklung)
    ↓ publizieren
Power BI Service (Cloud, Sharing)
    ↓ konsumieren
Power BI Mobile (iOS/Android)
```

## Datenmodell in Power BI
Stern-Schema aufbauen:
- **Faktentabellen:** Transaktionen, Verkaufe (numerisch, viele Zeilen)
- **Dimensionstabellen:** Kunden, Produkte, Zeit (beschreibend)
- **Beziehungen:** 1:n zwischen Dimension und Fakten

## Power Query (M-Sprache)
Daten importieren und transformieren:
```
Home → Get Data → (Excel, SQL Server, API, ...)
       ↓
Transform Data (Power Query Editor)
- Spalten entfernen/umbenennen
- Datentypen setzen
- Filter anwenden
- Tabellen zusammenfuehren (Merge/Append)
```

## DAX Grundformeln
```dax
-- Measure (Kennzahl)
Gesamt Umsatz = SUM(Verkauf[Betrag])

-- Vorjahrsumsatz
VJ Umsatz = CALCULATE([Gesamt Umsatz], SAMEPERIODLASTYEAR(Datum[Datum]))

-- Wachstum %
Wachstum % = DIVIDE([Gesamt Umsatz] - [VJ Umsatz], [VJ Umsatz])

-- Gefilterte Summe
IT Umsatz = CALCULATE(SUM(Verkauf[Betrag]), Produkt[Kategorie] = "IT")

-- Kumulierte Summe (YTD)
Umsatz YTD = TOTALYTD(SUM(Verkauf[Betrag]), Datum[Datum])
```

## Visualisierungstypen
| Visual | Wann |
|--------|------|
| Balkendiagramm | Kategorien vergleichen |
| Liniendiagramm | Zeitverlauf |
| Kreisdiagramm | Anteile (max. 5 Stuecke!) |
| Karte/Map | Geografische Daten |
| Matrix | Kreuztabelle |
| KPI | Einzelne Kennzahl mit Ziel |
| Wasserfall | Kumulierte Effekte |

**Merke:** Power Query = Daten formen; DAX = Berechnungen; Star Schema = Grundlage fuer gutes Modell$C$,
   '["Power BI","DAX","BI","Dashboard","Microsoft"]', 'Tools'),

  (v_bi_box, v_uid, 'KPIs — Key Performance Indicators',
$C$**KPIs** messen ob Ziele erreicht werden — das Herzstuck jedes BI-Systems.

## Was macht einen guten KPI?
Angelehnt an SMART:
- **Spezifisch:** Klare Definition (Umsatz = Netto oder Brutto?)
- **Messbar:** Berechenbar aus vorhandenen Daten
- **Attributierbar:** Wer ist verantwortlich?
- **Relevant:** Direkte Verbindung zum Geschaeftsziel
- **Zeitgebunden:** Mit Referenzzeitraum (Monat, Quartal, Jahr)

## Arten von KPIs
**Lag Indicators (nacheilend):** Zeigen Ergebnis der Vergangenheit
- Umsatz des letzten Monats
- Kundenzufriedenheit Q1
- Fluktuation 2024

**Lead Indicators (vorauseilend):** Prognose der Zukunft
- Anzahl qualifizierter Leads
- Pipeline-Wert
- Mitarbeiterzufriedenheit (Indikator fuer Fluktuation)

## Branchen-spezifische KPIs

**E-Commerce:**
```
Conversion Rate = Kaeufer / Besucher * 100
Customer Lifetime Value (CLV) = Durchschnittskauf * Haeufigkeit * Kundenlaufzeit
Cart Abandonment Rate = (Abgebrochene Warenkorbbestellungen / Erstellte) * 100
```

**SaaS:**
```
MRR = Monthly Recurring Revenue (monatliche Einnahmen)
ARR = Annual Recurring Revenue
Churn Rate = Verlorene Kunden / Gesamtkunden * 100
NPS = Net Promoter Score (-100 bis +100)
```

**IT-Betrieb (SRE):**
```
MTTR = Mean Time to Recover (Ø Wiederherstellungszeit)
MTTF = Mean Time to Failure (Ø Zeit bis Ausfall)
SLA = Service Level Agreement (z.B. 99,9% Uptime)
```

## KPI-Dashboard Design
- Maximal 7 KPIs auf einem Dashboard
- Ampelfarben: Rot/Gelb/Gruen
- Immer Vergleichswert: Vorjahr, Zielwert, Benchmark

**Merke:** Lead Indicators = Steuerung der Zukunft; Lag = Ergebnis messen; max. 7 KPIs auf ein Dashboard$C$,
   '["KPI","BI","Metriken","Dashboard","Reporting"]', 'Grundlagen'),

  (v_bi_box, v_uid, 'Datenqualitaet & Data Governance',
$C$Schlechte Datenqualitaet kostet Unternehmen Zeit, Geld und Vertrauen.

## Dimensionen der Datenqualitaet

| Dimension | Bedeutung | Beispiel |
|-----------|---------|---------|
| **Vollstaendigkeit** | Sind alle Felder befuellt? | E-Mail fehlt bei 30% der Kunden |
| **Korrektheit** | Sind die Daten richtig? | PLZ stimmt nicht mit Stadt ueberein |
| **Konsistenz** | Gleiche Bedeutung in allen Systemen? | "DE" vs. "Germany" vs. "Deutschland" |
| **Aktualitaet** | Wie aktuell sind die Daten? | Kundenadressen aus 2018 |
| **Eindeutigkeit** | Keine Duplikate? | Kunde zweimal mit leicht anderer Schreibweise |
| **Gueltigkeit** | Entspricht das Format den Regeln? | Negatives Alter, Datum 31.02. |

## Data Governance
Rahmenwerk fuer Datenverantwortung:
- **Data Owner:** Fachbereich verantwortet "seine" Daten
- **Data Steward:** Pflegt und ueberwacht Qualitaet
- **Data Catalog:** Zentrales Verzeichnis aller Datensaetze (Collibra, Alation)
- **Data Lineage:** Herkunft und Transformation nachvollziehen

## Datenqualitaet messen
```sql
-- Vollstaendigkeit pruefen
SELECT
  COUNT(*) AS gesamt,
  COUNT(email) AS mit_email,
  ROUND(COUNT(email)::numeric / COUNT(*) * 100, 2) AS vollstaendigkeit_pct
FROM kunden;

-- Duplikate finden
SELECT email, COUNT(*) AS anzahl
FROM kunden
GROUP BY email
HAVING COUNT(*) > 1;

-- Format-Gueltigkeit
SELECT * FROM kunden
WHERE email NOT SIMILAR TO '%@%.%';
```

## Great Expectations (Python DQ-Tool)
```python
import great_expectations as ge
df = ge.from_pandas(kunden_df)
df.expect_column_values_to_not_be_null("email")
df.expect_column_values_to_match_regex("email", r".+@.+\..+")
df.expect_column_values_to_be_between("alter", 18, 120)
```

**Merke:** Datenqualitaet = Fundament von BI; Garbage in = Garbage out; Data Governance = klare Verantwortung$C$,
   '["Datenqualitaet","Data Governance","BI","Data Catalog","Quality"]', 'Qualitaet');

  -- ════════════════════════════════════════════════════════════════
  -- SCRUM — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_scrum, v_uid, 'Sprint Planning Detail',
$C$**Sprint Planning** ist das erste Scrum-Event eines neuen Sprints — das Team plant was es in 1-4 Wochen liefert.

## Sprint Planning Agenda

**Teil 1 — Was wird gebaut? (~4h fuer 2-Wochen-Sprint)**
1. Product Owner praesentiert Sprint Goal (Warum?)
2. PO praesentiert priorisierte Backlog Items
3. Team stellt Fragen und versteht die Items
4. Team waehlt Items die es im Sprint umsetzen kann

**Teil 2 — Wie wird es gebaut? (~4h)**
1. Team bricht jedes Item in Aufgaben auf (Tasks)
2. Schreibt Tasks auf (Stundenschaetzung oder ohne)
3. Identifiziert Risiken und Abhaengigkeiten

## Sprint Goal
Das Sprint Goal ist das EINZIGE Commitment des Teams:
```
Gut: "Nutzer koennen sich registrieren und einloggen."
Schlecht: "Wir erledigen User Stories #23, #45, #67, #89."
```

## Velocity und Kapazitaet
```
Velocity = Durchschnittliche Story Points pro Sprint (letzte 3 Sprints)
Kapazitaet = Verfuegbare Arbeitstage * Teammitglieder

Sprint Planning: Nimm nicht mehr als Velocity erlaubt!
```

## Definition of Ready (DoR)
Backlog Items kommen nur in Sprint Planning wenn:
- [ ] User Story geschrieben (Als..., moechte ich..., damit...)
- [ ] Akzeptanzkriterien vorhanden
- [ ] Klein genug fuer einen Sprint
- [ ] Abhaengigkeiten bekannt
- [ ] Geschaetzt (Story Points)

**Merke:** Sprint Goal = das Warum; Teil 1 = Was; Teil 2 = Wie; Velocity = Planungsgrundlage$C$,
   '["Scrum","Sprint Planning","Sprint Goal","Velocity","Planning"]', 'Events'),

  (v_scrum, v_uid, 'Sprint Retrospektive Techniken',
$C$Die **Retrospektive** ist das wichtigste Scrum-Event fuer kontinuierliche Verbesserung.

## Ziel der Retro
Das Team reflektiert:
1. Was lief gut? → Fortfuehren
2. Was lief schlecht? → Verbesserungen ableiten
3. Was koennen wir im naechsten Sprint besser machen?

## Retro-Format 1: Start, Stop, Continue
Jedes Teammitglied schreibt Karten:
- **Start:** "Wir sollten anfangen mit..."
- **Stop:** "Wir sollten aufhoeren mit..."
- **Continue:** "Wir sollten fortfuehren mit..."
Gruppen bilden → Abstimmen → Top 3 als Actions

## Retro-Format 2: 4Ls
- **Liked:** Was haben wir gemocht?
- **Learned:** Was haben wir gelernt?
- **Lacked:** Was hat uns gefehlt?
- **Longed For:** Was wuenschen wir uns?

## Retro-Format 3: Mad, Sad, Glad
- **Mad:** Was hat uns geaergert?
- **Sad:** Was hat uns enttaeuscht?
- **Glad:** Worauf sind wir stolz?

## Retro-Format 4: Segelboot
Zeichne ein Segelboot auf das Whiteboard:
- **Wind (Segel):** Was treibt uns voran?
- **Anker:** Was bremst uns?
- **Sonne:** Was macht uns Freude?
- **Eisberg:** Welche Risiken sehen wir?

## Wichtige Regeln (Vegas-Regel)
"Was in der Retro passiert, bleibt in der Retro."
→ Psychologische Sicherheit ist Voraussetzung!

## Action Items
Jede Retro endet mit konkreten, messbaren Actions:
```
Schlecht: "Kommunikation verbessern"
Gut: "Wir fuehren ab naechstem Sprint einen Daily Standup Call um 9:30 Uhr ein."
```

**Merke:** Retro = sicherer Raum; immer Action Items mit Verantwortlichen; Formate rotieren verhindert Schemamudigkeit$C$,
   '["Scrum","Retrospektive","Continuous Improvement","Retro","Agile"]', 'Events'),

  (v_scrum, v_uid, 'Backlog Refinement & Story Points',
$C$**Backlog Refinement** (auch Grooming) bereitet den Backlog auf kuenftige Sprints vor.

## Was passiert beim Refinement?
- Product Backlog Items (PBIs) besprechen und verfeinern
- Grosse Epics in kleinere Stories aufteilen
- Akzeptanzkriterien erarbeiten
- Stories schaetzen
- Priorisierung besprechen

**Kein offizielles Scrum-Event**, aber best practice: ~1-2h pro Woche.

## Story Points
Relative Schaetzung von Komplexitaet, Unsicherheit und Aufwand:

**Fibonacci-Zahlen:** 1, 2, 3, 5, 8, 13, 21, 40, 100, ?
Grosse Sprunge betonen Unsicherheit bei grossen Items.

## Planning Poker
1. PO erklaert User Story
2. Jeder haelt versteckt eine Karte hoch
3. Alle aufdecken gleichzeitig
4. Ausreisser erklaeren ihre Schaetzung
5. Erneut schaetzen bis Konsens

## Story Point Referenz (Beispiel)
```
1 SP:  Kleinste bekannte Aufgabe (Config-Wert aendern)
3 SP:  Einfaches Feature mit klaren Anforderungen
5 SP:  Normales Feature, einige Unbekannte
8 SP:  Komplexes Feature, grosse Unsicherheit
13 SP: Zu gross — aufteilen!
```

## INVEST-Kriterien (gute User Stories)
- **I**ndependent: Unabhaengig von anderen Stories
- **N**egotiable: Details verhandelbar
- **V**aluable: Wertliefernd fuer Stakeholder
- **E**stimable: Schaetzbar
- **S**mall: Klein genug fuer einen Sprint
- **T**estable: Akzeptanzkriterien vorhanden

**Merke:** Refinement = Backlog sauber halten; Story Points = relativ, nicht Stunden; INVEST = Qualitaetsscheck fuer Stories$C$,
   '["Scrum","Backlog","Story Points","Planning Poker","Refinement"]', 'Artifacts'),

  (v_scrum, v_uid, 'Scrum Skalierung — SAFe & LeSS',
$C$Wenn mehrere Scrum-Teams an einem Produkt arbeiten, braucht es Koordination.

## Das Problem
Scrum ist fuer 1 Team designed (5-9 Personen). Was wenn 5 oder 50 Teams am gleichen Produkt arbeiten?

## LeSS (Large-Scale Scrum)
Hält Scrum-Prinzipien einfach und skaliert minimal:
- **LeSS:** 2-8 Teams, ein Product Owner, ein Product Backlog
- **LeSS Huge:** 8+ Teams, Area Product Owners

Gemeinsames Sprint Planning (Teams synchronisieren sich).
Gemeinsame Sprint Review, separate Retros.

## SAFe (Scaled Agile Framework)
Umfangreicher Rahmen fuer grosse Unternehmen:

```
Portfolio Level
    ↓
Program Level (Agile Release Train — ART)
    ↓
Team Level (Scrum Teams)
```

**PI Planning (Program Increment):**
Alle Teams planen gemeinsam 8-12 Wochen (2 Tage Event):
- Features fuer naechstes PI
- Abhaengigkeiten identifizieren
- Risiken erkennen

**SAFe Rollen:**
- Release Train Engineer (RTE) = Scrum Master des ART
- Product Manager = Produktverantwortung auf Program-Ebene
- System Architect = Technische Architektur uebergreifend

## Nexus
Scrum.org's Skalierungs-Framework:
- 3-9 Scrum Teams
- Nexus Integration Team (Koordinationsteam)
- Integrations-Sprint-Backlog zusaetzlich

## Wann was?
| | LeSS | SAFe | Nexus |
|-|------|------|-------|
| Teams | 2-8 | 50-150 | 3-9 |
| Komplexitaet | Einfach | Hoch | Mittel |
| Unternehmen | Klein/Mittel | Konzern | Mittel |

**Merke:** LeSS = minimal; SAFe = komplex, fuer Konzerne; PI Planning = gemeinsame Planung aller Teams$C$,
   '["Scrum","SAFe","LeSS","Skalierung","Agile"]', 'Skalierung');

  -- ════════════════════════════════════════════════════════════════
  -- GESCHAEFTSPROZESSE — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_bprozesse, v_uid, 'BPMN 2.0 Grundlagen',
$C$**BPMN 2.0** (Business Process Model and Notation) ist der internationale Standard zur Prozessmodellierung.

## Warum BPMN?
- Standardisiert — von allen verstehbar (Fachbereich + IT)
- Automatisierbar (Camunda, Activiti, Flowable)
- Plattformunabhaengig (XML-basiert)

## Kernelemente

**Flussobjekte:**
```
○  Start-Event (Beginn eines Prozesses)
◉  End-Event (Ende)
⬡  Task (Aktivitaet)
◇  Gateway (Entscheidung/Verzweigung)
```

**Gateways:**
```
◇  Exklusives Gateway (XOR): Genau ein Pfad
⊕  Paralleles Gateway (AND): Alle Pfade gleichzeitig
○◇ Inklusives Gateway (OR): Ein oder mehr Pfade
```

**Swimlanes:**
```
| Pool: Unternehmen |
|------- Lane: Vertrieb --------|------- Lane: Logistik --------|
| ○→[Angebot erstellen]→⊡      |     [Versand beauftragen]→◉  |
|------------------------Nachricht------------------------→      |
```

## Beispiel: Rechnungsfreigabe
```
Eingang → [Pruefung] → ◇ Korrekt? →[Ja]→ [Freigabe] → [Buchung] → ●
                            ↓[Nein]
                       [Ruecksendung] → ●
```

## Task-Typen
- **User Task:** Mensch fuehrt aus (Formular ausfuellen)
- **Service Task:** System fuehrt aus (API-Call)
- **Send/Receive Task:** Nachricht senden/empfangen
- **Script Task:** Automatisches Script

## Events
- **Message:** Nachricht erhalten/senden
- **Timer:** Zeitabhaengig
- **Error:** Fehlerbehandlung

**Merke:** BPMN = Industriestandard fuer Prozesse; XOR-Gateway = Entscheidung; Swimlane = Verantwortung$C$,
   '["BPMN","Prozessmodellierung","Geschaeftsprozesse","Standard","Workflow"]', 'Modellierung'),

  (v_bprozesse, v_uid, 'Prozessoptimierung — Lean & Kaizen',
$C$**Lean** und **Kaizen** kommen aus der japanischen Automobilindustrie (Toyota) und sind universell anwendbar.

## Lean-Prinzipien
1. **Value:** Was ist dem Kunden tatsaechlich wertvoll?
2. **Value Stream:** Alle Schritte um diesen Wert zu liefern
3. **Flow:** Wert soll fliessen ohne Unterbrechungen
4. **Pull:** Nur produzieren wenn Bedarf besteht (kein Push)
5. **Perfection:** Kontinuierlich verbessern (Kaizen)

## Verschwendung (Muda) — 7+1 Arten
| Art | Deutsch | Beispiel |
|-----|---------|---------|
| Transport | Transport | Dokument hin und her schicken |
| Inventory | Bestande | Halb-fertige Stories im Backlog |
| Motion | Bewegung | Wechsel zwischen Anwendungen |
| Waiting | Warten | Auf Genehmigung warten |
| Overproduction | Ueberproduktion | Features bauen die niemand braucht |
| Overprocessing | Ueberbearbeitung | 3 Genehmigungen fuer kleine Aenderung |
| Defects | Fehler | Bugs korrigieren |
| +Skills | Nicht genutztes Wissen | Mitarbeiterpotenzial ungenutzt |

## Value Stream Mapping (VSM)
Prozess visualisieren und Verschwendung identifizieren:
```
Schritt 1: Ist-Zustand zeichnen (wie es wirklich ist!)
Schritt 2: Verschwendung markieren (roter Blitz)
Schritt 3: Soll-Zustand zeichnen (Ziel)
Schritt 4: Verbesserungsplan ableiten
```

## Kaizen — Kontinuierliche Verbesserung
- Kleine, regelmaessige Verbesserungen statt grosser Revolutionen
- **Kaizen-Event:** 3-5 Tage intensiver Workshop zur Prozessverbesserung
- Alle Mitarbeiter sind einbezogen (kein Top-Down!)

## PDCA-Zyklus (Kaizen-Methode)
```
Plan → Do → Check → Act → Plan → ...
```

**Merke:** Lean = Verschwendung eliminieren; Kaizen = jeder, jeden Tag, ein bisschen besser; VSM = Prozess sichtbar machen$C$,
   '["Lean","Kaizen","Verschwendung","VSM","Prozessoptimierung"]', 'Optimierung'),

  (v_bprozesse, v_uid, 'Compliance & regulatorische Anforderungen',
$C$**Compliance** bedeutet die Einhaltung von Gesetzen, Normen und internen Richtlinien.

## Warum Compliance wichtig?
- Rechtliche Pflicht (Bussgelder bei Verstoessen)
- Reputation schuetzen
- Risikominimierung
- Voraussetzung fuer Geschaeftspartner

## Wichtige Regularien in Deutschland/EU

**DSGVO (Datenschutz-Grundverordnung):**
- Personenbezogene Daten nur mit Rechtsgrundlage verarbeiten
- Auskunftsrecht, Loeschrecht, Datenportabilitaet
- Bussgelder bis 4% des Jahresumsatzes oder 20 Mio. EUR

**GoBD (Ordnungsmaessige Buchfuehrung):**
- Belege und Buchungen vollstaendig, richtig, rechtzeitig
- 6-10 Jahre Aufbewahrungspflicht
- Unveraenderbarkeit von Dokumenten

**ISO 27001 (Informationssicherheit):**
- ISMS (Information Security Management System)
- Zertifizierung moeglich — oft von Kunden gefordert
- Risikobasierter Ansatz

**SOX (Sarbanes-Oxley):**
- Fuer US-boersennotierte Unternehmen
- Interne Kontrollen fuer Finanzberichterstattung

## Three Lines of Defence (Modell)
```
1. Linie: Operative Einheiten (fuehren Kontrollpflichten aus)
2. Linie: Risiko/Compliance-Funktion (ueberwacht, beraat)
3. Linie: Interne Revision (prueft unabhaengig)
```

## Compliance-Prozess
1. **Identifizieren:** Welche Regularien gelten?
2. **Analysieren:** Welche Luecken (Gaps) bestehen?
3. **Umsetzen:** Massnahmen implementieren
4. **Ueberwachen:** Kontinuierliches Monitoring
5. **Reporten:** Nachweisen der Einhaltung

**Merke:** DSGVO = Datenschutz; GoBD = Buchhaltungspflichten; ISO 27001 = Informationssicherheit; 3 Lines = Kontrollmodell$C$,
   '["Compliance","DSGVO","Recht","Risiko","Governance"]', 'Governance');

  -- ════════════════════════════════════════════════════════════════
  -- BUSINESS ANALYSE — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_ba_box, v_uid, 'Stakeholder-Analyse & -Management',
$C$**Stakeholder** sind alle Personen und Gruppen die vom Projekt betroffen sind oder Einfluss haben.

## Stakeholder-Analyse — 3 Schritte
1. **Identifizieren:** Wer ist betroffen?
2. **Analysieren:** Einfluss und Interesse bewerten
3. **Strategien ableiten:** Wie kommunizieren?

## Power/Interest-Matrix
```
        Interesse
          hoch
    hoher |
   Einfl. | Stakeholder  |  Hauptakteure
          | eng halten   |  eng einbinden
          |              |
    ——————|——————————————|——————
          |              |
   niedr. | Beobachten   |  Zufrieden halten
   Einfl. |(informieren) |  (Einbinden!)
          ↓________________________→ Interesse
         niedrig         hoch
```

**Hauptakteure (hoch/hoch):** Eng einbinden, regelmaessige Abstimmung, Entscheidungsrechtgeber.
**Zufrieden halten (hoch/niedrig):** Haben Macht aber wenig Interesse — nicht ignoriern! (z.B. Geschaeftsfuehrer)
**Informieren (niedrig/hoch):** Aktiv informieren, Feedback einholen (z.B. Endnutzer)
**Beobachten (niedrig/niedrig):** Gelegentlich updaten.

## Stakeholder-Register
| Name | Rolle | Interesse | Einfluss | Erwartung | Kommunikation |
|------|-------|-----------|---------|----------|--------------|
| Herr Muster | CFO | Niedrig | Hoch | ROI | Monatl. Status |
| Frau Test | Key User | Hoch | Mittel | Benutzerfreundlichkeit | Sprint Reviews |
| IT-Security | Team | Mittel | Hoch | Sicherheit | Weekly |

## Haeufige Fehler
- Stakeholder zu spaet einbinden
- Kritiker ignorieren statt einbinden
- Nur formale Entscheider ansprechen (informelle Macht vergessen!)
- Einmalige Analyse statt kontinuierlichem Monitoring

**Merke:** Power/Interest-Matrix = Basis fuer Kommunikationsstrategie; Kritiker frueh einbinden = spaeter weniger Widerstand$C$,
   '["Stakeholder","Business Analyse","Kommunikation","Analyse","Projekt"]', 'Analyse'),

  (v_ba_box, v_uid, 'Requirements-Erhebungstechniken',
$C$Verschiedene Techniken um Anforderungen von Stakeholdern zu erheben.

## 1. Interview
Strukturiertes Einzelgespraech:
- **Offen:** "Wie laeuft Ihr Prozess ab?"
- **Geschlossen:** "Nutzen Sie Funktion X?"
- **Hypothetisch:** "Was waere, wenn das System X koennte?"

Vorbereitung: Leitfaden erstellen, maximal 60-90 Minuten, protokollieren.

## 2. Workshop / Focus Group
Gruppe von Stakeholdern gemeinsam:
- Moderator fuehrt die Gruppe
- Widersprueche aufdecken (verschiedene Perspektiven!)
- Brainstorming, Priorisierung

## 3. Beobachtung (Contextual Inquiry)
Dem Nutzer bei der Arbeit zuschauen:
- Entdeckt implizites Wissen ("Das mache ich immer so, dachte jeder weiss das")
- Aufdecken von Workarounds
- Unterschied: Was Nutzer SAGEN vs. was sie TUN

## 4. Fragebogen / Survey
Viele Stakeholder gleichzeitig befragen:
- Skalenfragen: "Wie wichtig ist X? (1-5)"
- Offen oder geschlossen
- Guenstig in der Durchfuehrung, aber kein Rueckfragen moeglich

## 5. Dokumentenanalyse
Bestehende Dokumente analysieren:
- Handbuecher, Gesetze, bestehende Systeme
- Screen-Captures des aktuellen Systems
- Pflichtenheft des Vorgaengersystems

## 6. Prototyping (Explorativ)
Schnelle Mockups um Anforderungen zu entdecken (siehe RE-Karte Prototyping).

## Wann was?
| Situation | Methode |
|-----------|--------|
| Experte mit implizitem Wissen | Beobachtung |
| Widersprueche aufdecken | Workshop |
| Viele Stakeholder | Fragebogen |
| Konkrete Systemvorstellung | Prototyping |
| Spezifisches Wissen vertiefen | Interview |

**Merke:** Beobachtung deckt auf was Interviews nicht zeigen; Workshop synchronisiert Stakeholder; nie auf eine Technik allein verlassen$C$,
   '["Business Analyse","Requirements","Interview","Workshop","Erhebung"]', 'Techniken'),

  (v_ba_box, v_uid, 'Gap-Analyse & Impact-Analyse',
$C$**Gap-Analyse** und **Impact-Analyse** sind zwei zentrale Werkzeuge in der Business Analyse.

## Gap-Analyse
"Wo sind wir?" vs. "Wo wollen wir hin?" → **Was fehlt (der Gap)?**

```
IST-Zustand:
- Manuelle Excel-Prozesse
- Keine Echtzeit-Daten
- Keine mobile Nutzung

SOLL-Zustand:
- Automatisiertes Reporting
- Live-Dashboards
- App fuer Aussendienst

GAP (Handlungsbedarf):
- BI-System implementieren
- API-Integration mit ERP
- Mobile App entwickeln
```

## Gap-Analyse Vorgehen
1. **Ist-Aufnahme:** Aktuellen Zustand dokumentieren (Workshops, Interviews, Beobachtung)
2. **Soll-Definition:** Zielzustand festlegen (Strategie, Anforderungen)
3. **Luecken identifizieren:** Differenz beschreiben
4. **Massnahmen ableiten:** Was ist noetig um die Luecke zu schliessen?
5. **Priorisieren:** Welche Gaps zuerst schliessen?

## Impact-Analyse
**Was hat welche Auswirkung wenn sich etwas aendert?**

Vor jeder Aenderung fragen:
- Welche Systeme sind betroffen?
- Welche Prozesse muessen angepasst werden?
- Welche Teams muessen involviert werden?
- Welche Risiken entstehen?

## Impact-Matrix
```
Anforderungselement → betroffene Systeme / Prozesse / Teams
A01: Login aendern  → Webseite, Mobile App, API, Sicherheits-Team
A02: Preisfeld      → Webshop, ERP-Integration, Buchhaltung
```

## Wann Impact-Analyse?
- Vor Aenderungen an bestehenden Systemen
- Release-Entscheidungen
- Change-Management

**Merke:** Gap = Ist minus Soll; Impact = Wer/Was ist betroffen; beide IMMER vor Implementierung durchfuehren$C$,
   '["Gap-Analyse","Impact-Analyse","Business Analyse","Change Management","Analyse"]', 'Techniken');

  -- ════════════════════════════════════════════════════════════════
  -- STRATEGISCHES MANAGEMENT — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_strategy, v_uid, 'SWOT-Analyse vertieft',
$C$Die **SWOT-Analyse** bewertet Staerken, Schwaechen, Chancen und Risiken — und leitet daraus Strategien ab.

## Die 4 Felder
| | Positiv | Negativ |
|--|---------|---------|
| **Intern** | Strengths (Staerken) | Weaknesses (Schwaechen) |
| **Extern** | Opportunities (Chancen) | Threats (Risiken) |

## Von Analyse zu Strategie — TOWS-Matrix
```
         | Chancen (O)     | Risiken (T)
---------|-----------------|------------------
Staerken | SO-Strategie:   | ST-Strategie:
(S)      | Staerken nutzen | Staerken gegen
         | fuer Chancen    | Risiken einsetzen
---------|-----------------|------------------
Schw.(W) | WO-Strategie:   | WT-Strategie:
         | Schwaechen abba-| Rueckzug /
         | uen um Chancen  | Verteidigung
         | zu nutzen       |
```

## Beispiel: Mittelstaendisches IT-Unternehmen
```
Staerken:  Kundennaeche, Flexibilitaet, Spezialwissen Cloud
Schwaechen: Kleines Team, keine Marketing-Abteilung, kein 24/7 Support
Chancen:    Wachsender Cloud-Markt, KI-Nachfrage
Risiken:    Grosse Konzerne, Fachkraeftemangel
```

**SO-Strategie:** Cloud-Spezialwissen fuer KI-Projekte anbieten
**WT-Strategie:** Kooperationen mit anderen Mittelstaendlern

## Haeufige Fehler
- Zu viele Punkte (max 5 pro Feld!)
- Faktoren nicht belegt
- Keine Strategien abgeleitet
- Einmalig statt regelmaessig

**Merke:** SWOT = Analyse; TOWS = Strategieableitung; Intern = kontrollierbar; Extern = nicht kontrollierbar$C$,
   '["SWOT","TOWS","Strategie","Analyse","Management"]', 'Analyse'),

  (v_strategy, v_uid, 'Ansoff-Matrix & Wachstumsstrategien',
$C$Die **Ansoff-Matrix** (1957) beschreibt vier Wachstumsstrategien anhand von Produkt und Markt.

## Die 4 Strategien
```
             | Bestehende Produkte | Neue Produkte
-------------|---------------------|------------------
Bestehende   | Marktdurchdringung  | Produktentwicklung
Maerkte      | (Penetration)       |
-------------|---------------------|------------------
Neue         | Marktentwicklung    | Diversifikation
Maerkte      |                     |
```

## 1. Marktdurchdringung (geringes Risiko)
Mehr vom gleichen verkaufen:
- Werbung intensivieren
- Preise senken
- Promotionen
- Beispiel: Spotify → mehr Premium-Abonnenten gewinnen

## 2. Produktentwicklung (mittleres Risiko)
Neue Produkte fuer bekannte Kunden:
- Produktinnovation
- Neue Varianten
- Beispiel: Apple Watch (Apple kennt iPhone-Kunden)

## 3. Marktentwicklung (mittleres Risiko)
Bestehende Produkte in neuen Maerkten:
- Internationalisierung
- Neue Segmente
- Beispiel: McDonald's Expansion nach China

## 4. Diversifikation (hohes Risiko)
Neues Produkt, neuer Markt:
- **Verwandt:** Aehnliche Branche (Synergien)
- **Unverwandt:** Voellig andere Branche
- Beispiel: Amazon → AWS (von Handel zu Cloud)

## Risikobewertung
Je weiter von der Stammkompetenz entfernt, desto hoeher das Risiko:
```
Niedrig: Marktdurchdringung (bekannt + bekannt)
Mittel:  Produkt- oder Marktentwicklung
Hoch:    Diversifikation (neu + neu)
```

**Merke:** Ansoff = 4 Wachstumsstrategien; Diversifikation = hoechstes Risiko; beginne mit Marktdurchdringung$C$,
   '["Ansoff","Wachstum","Strategie","Diversifikation","Management"]', 'Frameworks'),

  (v_strategy, v_uid, 'OKR — Objectives and Key Results',
$C$**OKR** ist ein Zielsetzungs-Framework das Unternehmensziele mit messbaren Ergebnissen verknuepft.

## Aufbau
**Objective (O):** Inspirierendes, qualitatives Ziel (WOHIN?)
**Key Results (KR):** 2-5 messbare Ergebnisse die zeigen wann O erreicht ist (WIE messen?)

## Beispiel
```
Objective:
"Wir werden der fuehrende Cloud-Partner fuer KMU in Bayern."

Key Results:
KR1: Neukundenumsatz Q3: 500.000 EUR (aktuell: 280.000)
KR2: NPS steigt von 32 auf 55
KR3: 3 neue Mitarbeitende mit Azure-Zertifizierung eingestellt
KR4: Case Study von 2 Bestandskunden veroeffentlicht
```

## OKR-Ebenen
```
Unternehmen (Annual OKRs)
    └── Abteilung (Quarterly OKRs)
             └── Team (Quarterly OKRs)
                      └── Individual (optional)
```

## OKR-Prinzipien
- **Ambitioniert:** 70% Zielerreichung = Erfolg! (Moonshots)
- **Transparent:** Alle OKRs fuer alle sichtbar
- **Nicht KPI-Basiert:** OKRs sind fuer Wandel; KPIs fuer Stabil-Betrieb
- **Kein Bonus an OKR koppeln** (fuehrt zu safe Targets!)

## OKR vs. BSC (Balanced Scorecard)
| | OKR | BSC |
|--|-----|-----|
| Zyklus | Quartal | Jahr |
| Fokus | Wenige, wichtige Ziele | Umfassend, alle Bereiche |
| Stil | Bottom-up + Top-down | Eher Top-down |
| Herkunft | Google/Intel | Norton/Kaplan |

**Merke:** Objective = inspirierend; Key Result = messbar; 70% = Erfolg; nicht an Bonus koppeln!$C$,
   '["OKR","Strategie","Ziele","Management","Google"]', 'Frameworks'),

  (v_strategy, v_uid, 'Porter 5 Forces — Branchenanalyse',
$C$Porters **Fuenf Kraeftemodell** analysiert die Wettbewerbsintensitaet einer Branche.

## Die 5 Kraefte

```
         Bedrohung durch neue Anbieter
                    ↓
Verhandlungs- ←  Branchenrivalitaet  → Verhandlungs-
macht Lieferant   (existierende       macht Kunden
                    Wettbewerber)
                    ↑
         Bedrohung durch Substitute
```

## 1. Rivalitaet (Wettbewerbsintensitaet)
Wie stark konkurrieren bestehende Anbieter?
- Viele gleichwertige Anbieter → hohe Rivalitaet
- Differenzierung → niedrigere Rivalitaet

## 2. Neue Anbieter (Eintrittshuerden)
Wie schwer ist es in den Markt einzutreten?
- Hohe Kapitalanforderungen → niedrige Bedrohung
- Skalierbare Softwareprodukte → hohe Bedrohung

## 3. Verhandlungsmacht Kunden
Wie stark koennen Kunden Preise druecken?
- Wenige, grosse Kunden → hohe Macht
- Viele, kleine Kunden → niedrige Macht

## 4. Verhandlungsmacht Lieferanten
Wie abhaengig sind wir von Lieferanten?
- Monopol-Lieferant (z.B. einziger GPU-Hersteller) → hohe Macht
- Viele alternative Lieferanten → niedrige Macht

## 5. Substitute
Gibt es Alternativen die meinen Markt ersetzen koennen?
- Streaming → Substitut fuer DVD
- KI-Code-Assistenten → Substitut fuer Junior-Entwickler?

## Anwendung
```
Analyse Cloud-Anbieter-Markt:
1. Rivalitaet: Mittel (AWS, Azure, GCP — aber differenziert)
2. Neue Anbieter: Niedrig (Enorme Investitionen noetig)
3. Kundenmacht: Mittel (Lock-in durch Services)
4. Lieferanten: Niedrig (eigene Rechenzentren)
5. Substitute: Mittel (on-premise kommt zurueck?)
```

**Merke:** 5 Forces = Branchenattraktivitaet bewerten; hohe Kraefte = unattraktive Branche; niedrig = Gewinnpotenzial$C$,
   '["Porter","5 Forces","Strategie","Wettbewerb","Branchenanalyse"]', 'Frameworks');

  -- ════════════════════════════════════════════════════════════════
  -- PROJEKTMANAGEMENT — Weitere Karten
  -- ════════════════════════════════════════════════════════════════

  INSERT INTO cards (box_id, user_id, title, content, tags, category) VALUES
  (v_pm_classic, v_uid, 'Projektphasen & Wasserfall-Modell',
$C$Das **Wasserfallmodell** ist der klassische sequenzielle Projektansatz.

## Phasen des Wasserfalls
```
1. Initiierung
   ├── Projektauftrag/-charter
   ├── Stakeholder identifizieren
   └── Machbarkeitsstudie
         ↓
2. Planung
   ├── Anforderungen erheben
   ├── Projektplan (Zeitplan, Budget, Ressourcen)
   ├── Risikoplan
   └── Kommunikationsplan
         ↓
3. Durchfuehrung
   ├── Team fuehren
   ├── Aufgaben koordinieren
   └── Deliverables erstellen
         ↓
4. Ueberwachung & Steuerung (parallel zu Phase 3!)
   ├── Fortschritt messen
   ├── Abweichungen erkennen
   └── Korrekturmassnahmen
         ↓
5. Abschluss
   ├── Abnahme
   ├── Dokumentation
   └── Lessons Learned
```

## Magisches Dreieck
```
           Zeit
          /    \
         /      \
     Kosten ──── Umfang
               (Scope)
```
Aendern einer Dimension beeinflusst die anderen zwei!

## Wasserfall — Vor- und Nachteile
**Vorteile:**
- Klare Struktur und Phasen
- Gut bei fixen Anforderungen
- Einfach nachzuvollziehen

**Nachteile:**
- Spaetes Feedback (erst am Ende lieferbar)
- Anforderungen aendern sich (aber Wasserfall nicht flexibel)
- Risiken spaet entdeckt

**Wann noch sinnvoll?**
- Physische Produkte (Fabrikbau, Bruecke)
- Regulierte Bereiche mit unveraenderlichen Anforderungen
- Kleine Projekte mit sehr klaren Anforderungen

**Merke:** Wasserfall = sequenziell; Magisches Dreieck = Zeit/Kosten/Umfang; Abschluss nicht vergessen (Lessons Learned!)$C$,
   '["Projektmanagement","Wasserfall","Projektphasen","PMBOK","klassisch"]', 'Grundlagen'),

  (v_pm_classic, v_uid, 'Earned Value Management (EVM)',
$C$**Earned Value Management** misst objektiv den Projektfortschritt — Planung vs. Realitaet.

## Kern-Kennzahlen

**PV (Planned Value):** Wie viel sollte bis jetzt geleistet sein?
**EV (Earned Value):** Wie viel wurde tatsaechlich geleistet (bewertet)?
**AC (Actual Cost):** Wie viel wurde tatsaechlich ausgegeben?

## Abweichungsanalyse
$$SV = EV - PV \quad \text{(Schedule Variance — Zeitabweichung)}$$
$$CV = EV - AC \quad \text{(Cost Variance — Kostenabweichung)}$$

- $SV > 0$: Wir sind voraus (schneller als geplant)
- $SV < 0$: Wir sind im Verzug
- $CV > 0$: Wir sind unter Budget
- $CV < 0$: Wir sind ueber Budget

## Performance-Indizes
$$SPI = \frac{EV}{PV} \quad \text{(Schedule Performance Index)}$$
$$CPI = \frac{EV}{AC} \quad \text{(Cost Performance Index)}$$

- $SPI = 1.0$: Exakt im Zeitplan
- $SPI = 0.8$: Wir leisten nur 80% des Geplanten
- $CPI = 1.2$: Fuer jeden Euro Ausgabe liefern wir 1,20 EUR Wert

## Prognose (Estimate at Completion)
$$EAC = \frac{BAC}{CPI}$$
Wenn CPI konstant bleibt, was kostet das Projekt am Ende?

($BAC$ = Budget at Completion = Gesamtbudget)

## Beispiel
```
Projekt: 100.000 EUR Budget, 50% der Zeit verstrichen.
PV = 50.000 EUR (sollte zu 50% fertig sein)
EV = 40.000 EUR (nur 40% fertig)
AC = 55.000 EUR (schon 55.000 ausgegeben)

SV = 40.000 - 50.000 = -10.000 (Verzug!)
CV = 40.000 - 55.000 = -15.000 (Ueber Budget!)
CPI = 40.000 / 55.000 = 0,73
EAC = 100.000 / 0,73 = 136.986 EUR (Prognose: 37% teurer!)
```

**Merke:** EVM = objektiver Fortschritt; CV und SV < 0 = Probleme; CPI und SPI < 1 = unterdurchschnittlich$C$,
   '["EVM","Earned Value","Projektmanagement","Kosten","Schedule"]', 'Kontrolle'),

  (v_pm_classic, v_uid, 'Risikomanagement im Projekt',
$C$**Risikomanagement** ist der systematische Umgang mit Unsicherheiten im Projekt.

## Risikomanagement-Prozess (PMBOK)
1. **Risikoidentifikation:** Alle moeglichen Risiken listen (Brainstorming, Checklisten, SWOT)
2. **Qualitative Bewertung:** Wahrscheinlichkeit und Auswirkung bewerten
3. **Quantitative Bewertung:** Erwartete Kosten berechnen (optional)
4. **Reaktionsplanung:** Strategie fuer jedes Risiko
5. **Ueberwachung:** Laufend ueberwachen und neue Risiken erfassen

## Risikomatrix
```
Auswirkung
  Kritisch | □  | ■  | ■  | ■
    Hoch   | □  | □  | ■  | ■
    Mittel | □  | □  | □  | ■
    Niedrig| □  | □  | □  | □
           ---+----+----+----
          <10 10-25 25-50 >50%
                  Wahrscheinlichkeit
```
■ = Handlungsbedarf!

## Risikostrategien

**Fuer negative Risiken (Bedrohungen):**
- **Vermeiden:** Risiko-Ursache eliminieren (Plan aendern)
- **Reduzieren:** Wahrscheinlichkeit oder Auswirkung minimieren
- **Uebertragen:** Risiko auf Dritte abwaelzen (Versicherung, Subunternehmer)
- **Akzeptieren:** Risiko bewusst in Kauf nehmen (Contingency-Reserve einplanen)

**Fuer positive Risiken (Chancen):**
- **Ausnutzen:** Chance sicherstellen
- **Erhoehen:** Wahrscheinlichkeit oder Auswirkung vergroessern
- **Teilen:** Mit Dritten gemeinsam nutzen

## Risikoregister
| # | Risiko | W% | Auswirkung | Score | Strategie | Verant. |
|---|--------|----|-----------|-------|----------|---------|
| R1 | Schluesselperson krank | 30% | Hoch | 9 | Reduzieren | PM |
| R2 | Technologie-Wechsel | 10% | Kritisch | 6 | Vermeiden | CTO |

**Merke:** Risiko = Wahrscheinlichkeit x Auswirkung; 4 Strategien: Vermeiden/Reduzieren/Uebertragen/Akzeptieren$C$,
   '["Risikomanagement","Projektmanagement","Risiko","PMBOK","Matrix"]', 'Risiko'),

  (v_pm_classic, v_uid, 'Projektabschluss & Lessons Learned',
$C$Der **Projektabschluss** wird haeufig vernachlaessigt — dabei ist er wichtig fuer zukuenftige Projekte.

## Warum Projektabschluss?
- Formale Abnahme durch Auftraggeber
- Ressourcen freigeben
- Vertragliche Abschlusspflichten
- Wissen sichern (Lessons Learned)

## Abschluss-Checkliste
```
Deliverables:
[ ] Alle Liefergegenstande uebergeben und abgenommen
[ ] Dokumentation vollstaendig uebergeben
[ ] Quellcode ins Repository

Vertraege:
[ ] Auftragnehmer-Rechnungen bezahlt
[ ] Abschlussrechnung gestellt

Ressourcen:
[ ] Projekttmitglieder entlastet und neuen Projekten zugeordnet
[ ] Hard- und Softwarelizenzen zurueckgegeben

Administration:
[ ] Projektakte archiviert
[ ] Zugangsrechte entzogen
[ ] Lessons Learned durchgefuehrt
```

## Lessons Learned — Workshop
```
1. Was lief gut? (Was uebernehmen wir?)
2. Was lief schlecht? (Was vermeiden wir?)
3. Was wuerden wir anders machen?
4. Empfehlungen fuer kuenftige Projekte
```

Methode: Open Space, Retro-Formate (Start-Stop-Continue)

## Lessons Learned sichern
Nutzlos wenn niemand sie liest!
- In Wissensdatenbank (Confluence, SharePoint)
- Template fuer zuekuenftige Projektleiter
- Checklisten ableiten

## Abschlussberichte
- **Management Summary:** Ergebnisse, Budget, Zeit, Qualitaet
- **Technische Dokumentation:** Architektur, Konfigurationen
- **Projektabschlussbericht:** Vollstaendige Dokumentation

**Merke:** Abschluss ist Pflicht, kein Optional; Lessons Learned nur nuetzlich wenn archiviert und zuegaenglich$C$,
   '["Projektabschluss","Lessons Learned","Projektmanagement","Abschluss","Wissensmanagement"]', 'Abschluss'),

  (v_pm_classic, v_uid, 'Projektstrukturplan (PSP) & Arbeitspakete',
$C$Der **Projektstrukturplan (PSP)** (englisch: Work Breakdown Structure / WBS) ist die hierarchische Zerlegung des Projekts.

## Was ist ein PSP?
Jedes Projekt wird in ueberschaubare **Arbeitspakete** zerlegt:
```
0. Webshop-Projekt (100%)
   ├── 1. Konzept & Planung
   │   ├── 1.1 Anforderungsanalyse
   │   ├── 1.2 Systemarchitektur
   │   └── 1.3 Projektplan
   ├── 2. Entwicklung
   │   ├── 2.1 Frontend
   │   │   ├── 2.1.1 Startseite
   │   │   └── 2.1.2 Produktseite
   │   └── 2.2 Backend
   │       ├── 2.2.1 Nutzerverwaltung
   │       └── 2.2.2 Bestellabwicklung
   └── 3. Abschluss
       ├── 3.1 Testing
       └── 3.2 Deployment
```

## 100%-Regel
Der PSP muss den **gesamten Umfang** abdecken:
Summe aller Arbeitspakete = 100% des Projekts.
Kein "geheimes" Arbeitspaket ausserhalb des PSP!

## Arbeitspaket (AP)
Kleinstes Element im PSP:
- Von einer Person verantwortbar
- Dauer: 1-2 Wochen (schatzbarer Aufwand)
- Klares Ergebnis und Abnahmekriterium
- Aufwand schaetzbar

## Vom PSP zum Projektplan
```
PSP → Aufwandsschaetzung (Personentage)
    → Ressourcenzuweisung (Wer macht was?)
    → Terminplanung (Wann?)
    → Netzplan / Gantt-Diagramm
```

**Merke:** PSP = Arbeitszerlegung; 100%-Regel = kein Paket ausserhalb; Arbeitspaket = kleinstes Element, klar abgrenzbar$C$,
   '["PSP","WBS","Projektmanagement","Arbeitspakete","Planung"]', 'Planung');

  RAISE NOTICE 'Seed v2 erfolgreich! Alle Bereiche befuellt fuer %', v_uid;
END;
$SEED2$ LANGUAGE plpgsql;
