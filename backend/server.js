import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
dotenv.config({ path: join(dirname(fileURLToPath(import.meta.url)), '.env') });
import express from 'express';
import cors from 'cors';
import boxRoutes from './routes/boxes.js';
import cardRoutes from './routes/cards.js';
import aiRoutes from './routes/ai.js';

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors({ origin: true })); // lokales Netz + localhost
app.use(express.json());

app.use('/api/boxes', boxRoutes);
app.use('/api/cards', cardRoutes);
app.use('/api/ai', aiRoutes);

// Globale Fehlerbehandlung — verhindert Server-Crash bei unbehandelten Fehlern
process.on('uncaughtException', (err) => {
  console.error('[FEHLER] Uncaught Exception:', err.message);
});
process.on('unhandledRejection', (reason) => {
  console.error('[FEHLER] Unhandled Rejection:', reason);
});

app.use((err, req, res, next) => {
  console.error('[FEHLER] Express:', err.message);
  res.status(500).json({ error: err.message });
});

app.listen(PORT, () => console.log(`Backend läuft auf http://localhost:${PORT}`));
