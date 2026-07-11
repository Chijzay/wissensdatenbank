export default function Impressum({ onClose }) {
  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'var(--bg)',
      overflowY: 'auto', zIndex: 200, padding: '40px 24px',
    }}>
      <div style={{ maxWidth: 640, margin: '0 auto' }}>
        <button
          onClick={onClose}
          style={{
            display: 'flex', alignItems: 'center', gap: 6,
            background: 'none', border: 'none', color: 'var(--text-muted)',
            fontSize: 14, cursor: 'pointer', marginBottom: 32, padding: 0,
          }}
        >
          ← Zurück
        </button>

        <h1 style={{ fontSize: 28, fontWeight: 700, color: 'var(--text)', marginBottom: 8 }}>
          Impressum
        </h1>
        <p style={{ color: 'var(--text-muted)', fontSize: 13, marginBottom: 40 }}>
          Angaben gemäß § 5 TMG
        </p>

        <section style={{ marginBottom: 32 }}>
          <h2 style={{ fontSize: 15, fontWeight: 600, color: 'var(--text)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: '0.06em', fontSize: 11 }}>
            Verantwortlich
          </h2>
          <p style={{ color: 'var(--text)', lineHeight: 1.8, fontSize: 15 }}>
            {/* HIER DEINEN NAMEN UND ADRESSE EINTRAGEN */}
            Steven Illg<br />
            Musterstraße 1<br />
            12345 Musterstadt<br />
            Deutschland
          </p>
        </section>

        <section style={{ marginBottom: 32 }}>
          <h2 style={{ fontSize: 11, fontWeight: 600, color: 'var(--text)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: '0.06em' }}>
            Kontakt
          </h2>
          <p style={{ color: 'var(--text)', lineHeight: 1.8, fontSize: 15 }}>
            E-Mail:{' '}
            <a href="mailto:steven.illg.it@outlook.com" style={{ color: 'var(--accent)' }}>
              steven.illg.it@outlook.com
            </a>
          </p>
        </section>

        <section style={{ marginBottom: 32 }}>
          <h2 style={{ fontSize: 11, fontWeight: 600, color: 'var(--text)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: '0.06em' }}>
            Hinweis
          </h2>
          <p style={{ color: 'var(--text-muted)', lineHeight: 1.7, fontSize: 14 }}>
            Diese Anwendung ist ein privates Wissensmanagementsystem und dient ausschließlich dem
            persönlichen Gebrauch. Es werden keine personenbezogenen Daten Dritter verarbeitet oder
            weitergegeben.
          </p>
        </section>

        <section>
          <h2 style={{ fontSize: 11, fontWeight: 600, color: 'var(--text)', marginBottom: 12, textTransform: 'uppercase', letterSpacing: '0.06em' }}>
            Haftungsausschluss
          </h2>
          <p style={{ color: 'var(--text-muted)', lineHeight: 1.7, fontSize: 14 }}>
            Die Inhalte dieser Anwendung wurden mit größter Sorgfalt erstellt. Für die Richtigkeit,
            Vollständigkeit und Aktualität der Inhalte wird keine Gewähr übernommen.
          </p>
        </section>
      </div>
    </div>
  );
}
