require('dotenv').config({ path: __dirname + '/.env' });
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

dotenv.config();

if (!process.env.JWT_SECRET) {
  throw new Error('JWT_SECRET manquant : renseignez-le dans .env');
}

const app = express();

const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:3000,http://localhost:3001,http://10.0.2.2:3001')
  .split(',')
  .map((s) => s.trim());
app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(helmet());
app.use(express.json({ limit: '1mb' }));
app.use(rateLimit({ windowMs: 15 * 60 * 1000, limit: 300 }));

// Health
app.get('/api/health', (_, res) => res.json({ ok: true }));

// Mongo connection (optional)
const mongoUri = process.env.MONGO_URI;
let mongoReady = false;
if (mongoUri) {
  mongoose
    .connect(mongoUri, { dbName: process.env.MONGO_DB || undefined })
    .then(() => {
      mongoReady = true;
      console.log('MongoDB connecté');
    })
    .catch((err) => {
      console.warn('MongoDB non disponible. Fallback mock en mémoire.', err.message);
    });
} else {
  console.warn('MONGO_URI absent. Utilisation de données mock en mémoire.');
}

// Exposer l'état pour les routes
app.set('mongoReady', mongoReady);
Object.defineProperty(app, 'mongoReady', {
  get: () => mongoReady,
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/bars', require('./routes/bars'));
app.use('/api/events', require('./routes/events'));

// Global error handler
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ message: err.message || 'Erreur serveur' });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Backend Barly sur http://localhost:${PORT}`));

module.exports = app;
