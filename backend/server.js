import express from 'express';
import cors from 'cors';
import boxRoutes from './routes/boxes.js';
import cardRoutes from './routes/cards.js';
import aiRoutes from './routes/ai.js';
import { requireAuth } from './middleware/auth.js';

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors({ origin: true }));
app.use(express.json());

app.use('/api/boxes', boxRoutes);
app.use('/api/cards', cardRoutes);
app.use('/api/ai', requireAuth, aiRoutes);

process.on('uncaughtException', (err) => console.error('[FEHLER]', err.message));
process.on('unhandledRejection', (reason) => console.error('[FEHLER]', reason));

app.use((err, req, res, next) => {
  console.error('[FEHLER] Express:', err.message);
  res.status(500).json({ error: err.message });
});

app.listen(PORT, '0.0.0.0', () => console.log(`Backend läuft auf http://localhost:${PORT}`));
