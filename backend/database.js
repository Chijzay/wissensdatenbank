import { DatabaseSync } from 'node:sqlite';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const db = new DatabaseSync(join(__dirname, 'wissen.db'));

db.exec(`PRAGMA journal_mode = WAL`);
db.exec(`PRAGMA foreign_keys = ON`);

db.exec(`
  CREATE TABLE IF NOT EXISTS boxes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    color TEXT DEFAULT '#6366f1',
    icon TEXT DEFAULT '📦',
    parent_id INTEGER DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    box_id INTEGER NOT NULL REFERENCES boxes(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT DEFAULT '',
    tags TEXT DEFAULT '[]',
    category TEXT DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS card_questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS card_links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    linked_card_id INTEGER NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(card_id, linked_card_id)
  );
`);

// Migration: parent_id hinzufügen falls noch nicht vorhanden
try { db.exec(`ALTER TABLE boxes ADD COLUMN parent_id INTEGER DEFAULT NULL`); } catch {}
// Migration: sort_order für manuelle Sortierung
try { db.exec(`ALTER TABLE boxes ADD COLUMN sort_order INTEGER DEFAULT 999`); } catch {}
// Migration: IT → Informatik umbenennen (idempotent)
db.prepare("UPDATE boxes SET name = 'Informatik' WHERE name = 'IT' AND parent_id IS NULL").run();
// Reihenfolge der Top-Level-Bereiche setzen
db.prepare("UPDATE boxes SET sort_order = 1 WHERE name = 'Biologie' AND parent_id IS NULL").run();
db.prepare("UPDATE boxes SET sort_order = 2 WHERE name = 'Mathe' AND parent_id IS NULL").run();
db.prepare("UPDATE boxes SET sort_order = 3 WHERE name = 'Informatik' AND parent_id IS NULL").run();
db.prepare("UPDATE boxes SET sort_order = 4 WHERE name = 'Haushalt' AND parent_id IS NULL").run();
// Migration: Farben der Bereiche — Mathe lila, Informatik sky-blau (gut unterscheidbar)
db.prepare("UPDATE boxes SET color = '#a855f7' WHERE name = 'Mathe' AND parent_id IS NULL").run();
db.prepare("UPDATE boxes SET color = '#0ea5e9' WHERE name = 'Informatik' AND parent_id IS NULL").run();

// Seed: Basis-Bereiche anlegen wenn leer
const boxCount = db.prepare('SELECT COUNT(*) as c FROM boxes').get();
if (boxCount.c === 0) {
  const ib = db.prepare(`INSERT INTO boxes (name, description, color, icon) VALUES (?, ?, ?, ?)`);
  ib.run('Biologie', 'Naturwissenschaften und Lebewesen', '#22c55e', '🧬');
  ib.run('Haushalt', 'Tipps und Alltagswissen', '#f59e0b', '🏠');
  ib.run('Informatik', 'Berufliches IT-Wissen', '#6366f1', '💻');

  const ic = db.prepare(`INSERT INTO cards (box_id, title, content, tags, category) VALUES (?, ?, ?, ?, ?)`);
  ic.run(1, 'Photosynthese', 'Photosynthese ist der Prozess, bei dem Pflanzen Lichtenergie in chemische Energie umwandeln.\n\nDie Formel lautet:\n$$6CO_2 + 6H_2O + Licht \\rightarrow C_6H_{12}O_6 + 6O_2$$\n\nSie findet in den Chloroplasten statt, genauer in den Thylakoiden (Lichtreaktion) und im Stroma (Dunkelreaktion/Calvin-Zyklus).', '["Pflanze","Energie","Zelle"]', 'Botanik');
  ic.run(1, 'Mitose', 'Die Mitose ist eine Zellteilung, bei der aus einer Mutterzelle zwei genetisch identische Tochterzellen entstehen.\n\nPhasen: Prophase → Metaphase → Anaphase → Telophase\n\nZiel: Wachstum und Gewebereparatur.', '["Zelle","Teilung","DNA"]', 'Zellbiologie');
  ic.run(2, 'Flecken entfernen', 'Rotwein: sofort mit kaltem Wasser spülen, dann Salz drauf.\nFett: Spülmittel direkt auf den Fleck, 30 min einwirken.\nKugelschreiber: Haarspray oder Alkohol.\nBlut: nur kaltes Wasser, niemals heiß!', '["Haushalt","Wäsche","Tipps"]', 'Reinigung');
  ic.run(3, 'Git Grundbefehle', 'git init – neues Repo erstellen\ngit add . – alle Änderungen stagen\ngit commit -m "Nachricht" – committen\ngit push – auf Remote pushen\ngit pull – aktualisieren\ngit branch name – neuer Branch\ngit checkout name – Branch wechseln', '["Git","Terminal","Versionskontrolle"]', 'Entwicklung');
}

// Migration: Demo-Karte für Haushalt
const haushaltsBox = db.prepare("SELECT id FROM boxes WHERE name = 'Haushalt' AND parent_id IS NULL").get();
if (haushaltsBox) {
  const vorratExists = db.prepare("SELECT id FROM cards WHERE box_id = ? AND title = 'Küchen-Grundvorrat'").get(haushaltsBox.id);
  if (!vorratExists) {
    db.prepare(`INSERT INTO cards (box_id, title, content, tags, category) VALUES (?, ?, ?, ?, ?)`)
      .run(
        haushaltsBox.id,
        'Küchen-Grundvorrat',
        `Diese Zutaten sollten immer zuhause sein:\n\n**Haltbares:**\n- Pasta (Spaghetti, Penne)\n- Reis (Langkorn + Risotto)\n- Dosentomaten, Kichererbsen, Linsen\n- Olivenöl, Sonnenblumenöl\n- Essig (Apfel, Balsamico)\n\n**Gewürze:**\n- Salz, Pfeffer, Paprika, Kreuzkümmel\n- Oregano, Thymian, Lorbeer\n- Knoblauchpulver, Zwiebelpulver\n\n**Kühlschrank:**\n- Eier (immer!)\n- Butter, Parmesan\n- Joghurt, Milch\n\n**Tiefkühler:**\n- Erbsen, Spinat, Brokkoli (TK)`,
        JSON.stringify(['Küche', 'Einkauf', 'Vorrat', 'Tipps']),
        'Einkaufen'
      );
  }
}

// Migration: Azure / DevOps / Kubernetes Beispieldaten anlegen
const azureExists = db.prepare("SELECT COUNT(*) as c FROM boxes WHERE name = 'Azure'").get();
if (azureExists.c === 0) {
  const arbeit = db.prepare("SELECT id FROM boxes WHERE name = 'Informatik' OR name = 'IT' OR name = 'Arbeit'").get();
  if (arbeit) {
    const ib = db.prepare(`INSERT INTO boxes (name, color, icon, parent_id) VALUES (?, ?, ?, ?)`);
    const azureId = ib.run('Azure', '#0089d6', '☁️', arbeit.id).lastInsertRowid;
    const devopsId = ib.run('DevOps', '#f97316', '🔧', arbeit.id).lastInsertRowid;
    const k8sId = ib.run('Kubernetes', '#326ce5', '🐳', arbeit.id).lastInsertRowid;

    const ic = db.prepare(`INSERT INTO cards (box_id, title, content, tags, category) VALUES (?, ?, ?, ?, ?)`);

    ic.run(azureId, 'Was ist Azure?', 'Microsoft Azure ist die Cloud-Computing-Plattform von Microsoft. Sie bietet über 200 Dienste an, darunter:\n\n- **IaaS** (Infrastructure as a Service): VMs, Netzwerke, Storage\n- **PaaS** (Platform as a Service): App Service, Azure Functions\n- **SaaS** (Software as a Service): Microsoft 365, Dynamics\n\nAzure ist in über 60 Regionen weltweit verfügbar und konkurriert mit AWS und Google Cloud.', '["Cloud","Microsoft","IaaS","PaaS"]', 'Grundlagen');
    ic.run(azureId, 'Azure Resource Manager (ARM)', 'ARM ist das Deployment- und Verwaltungs-Framework für Azure.\n\nKernkonzepte:\n- **Resource Group**: Logischer Container für zusammengehörige Ressourcen\n- **ARM Templates**: JSON-Dateien zur Infrastructure-as-Code\n- **RBAC**: Role-Based Access Control für Berechtigungen\n\nBeispiel CLI:\n```\naz group create --name MeineGruppe --location westeurope\naz vm create --resource-group MeineGruppe --name MeineVM\n```', '["ARM","IaC","CLI","ResourceGroup"]', 'Verwaltung');
    ic.run(azureId, 'Azure Active Directory', 'Azure AD (jetzt Entra ID) ist der Cloud-Identitätsdienst von Microsoft.\n\nFunktionen:\n- Single Sign-On (SSO) für Cloud-Apps\n- Multi-Factor Authentication (MFA)\n- Conditional Access Policies\n- App Registrations für OAuth 2.0\n\nUnterschied zu lokalem AD: Azure AD ist HTTP/REST-basiert, kein LDAP/Kerberos.', '["IAM","SSO","MFA","EntraID"]', 'Identität & Zugriff');

    ic.run(devopsId, 'CI/CD Grundlagen', 'CI/CD steht für Continuous Integration / Continuous Delivery.\n\n**Continuous Integration (CI)**:\n- Code wird automatisch gebaut und getestet bei jedem Commit\n- Frühe Fehlererkennung\n- Tools: GitHub Actions, GitLab CI, Jenkins\n\n**Continuous Delivery (CD)**:\n- Automatisches Deployment in Staging/Produktion\n- Rollback-Möglichkeit\n\nZiel: Kürzere Releasezyklen, höhere Qualität.', '["CI","CD","Automation","Pipeline"]', 'Grundlagen');
    ic.run(devopsId, 'GitLab CI Pipeline', 'Eine .gitlab-ci.yml Datei definiert die Pipeline:\n\n```yaml\nstages:\n  - build\n  - test\n  - deploy\n\nbuild-job:\n  stage: build\n  script:\n    - npm install\n    - npm run build\n\ntest-job:\n  stage: test\n  script:\n    - npm test\n\ndeploy-job:\n  stage: deploy\n  script:\n    - echo "Deploying..."\n  only:\n    - main\n```\n\nJeder Job läuft in einem eigenen Docker-Container.', '["GitLab","YAML","Pipeline","Docker"]', 'Tools');
    ic.run(devopsId, 'Infrastructure as Code (IaC)', 'IaC bedeutet, Infrastruktur (Server, Netzwerke, Datenbanken) durch Code zu definieren und zu verwalten.\n\nVorteile:\n- Reproduzierbarkeit\n- Versionskontrolle (Git)\n- Automatisierung\n\nTools:\n- **Terraform**: Cloud-agnostisch, HCL-Syntax\n- **Ansible**: Agentless, YAML-basiert\n- **ARM/Bicep**: Azure-spezifisch\n- **Pulumi**: Infrastructure mit echten Programmiersprachen', '["IaC","Terraform","Ansible","Automatisierung"]', 'Tools');

    ic.run(k8sId, 'Was ist Kubernetes?', 'Kubernetes (K8s) ist ein Open-Source-System zur Automatisierung von Deployment, Skalierung und Verwaltung von Container-Anwendungen.\n\nUrsprünglich von Google entwickelt, heute von der CNCF verwaltet.\n\nKernprinzipien:\n- **Deklarativ**: Du beschreibst den gewünschten Zustand\n- **Self-Healing**: Pods werden automatisch neugestartet\n- **Skalierbar**: Horizontal Pod Autoscaler (HPA)\n- **Portable**: Läuft überall (On-Prem, Cloud, Hybrid)', '["Container","Cloud-Native","CNCF","Orchestrierung"]', 'Grundlagen');
    ic.run(k8sId, 'Pods und Deployments', 'Ein **Pod** ist die kleinste deploybare Einheit in K8s. Er enthält einen oder mehrere Container.\n\nEin **Deployment** verwaltet eine gewünschte Anzahl von Pod-Replikas:\n\n```yaml\napiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: meine-app\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: meine-app\n  template:\n    metadata:\n      labels:\n        app: meine-app\n    spec:\n      containers:\n      - name: app\n        image: meine-app:1.0\n        ports:\n        - containerPort: 8080\n```', '["Pod","Deployment","YAML","Replikas"]', 'Objekte');
    ic.run(k8sId, 'kubectl Befehle', 'Die wichtigsten kubectl Befehle:\n\n```bash\n# Pods anzeigen\nkubectl get pods\nkubectl get pods -n namespace\n\n# Details anzeigen\nkubectl describe pod mein-pod\n\n# Logs lesen\nkubectl logs mein-pod\nkubectl logs -f mein-pod  # live\n\n# In Pod einloggen\nkubectl exec -it mein-pod -- /bin/sh\n\n# Deployment skalieren\nkubectl scale deployment meine-app --replicas=5\n\n# Ressource anlegen/updaten\nkubectl apply -f deployment.yaml\n\n# Ressource löschen\nkubectl delete pod mein-pod\n```', '["kubectl","CLI","Terminal","Debugging"]', 'Tools');
  }
}

export default db;
