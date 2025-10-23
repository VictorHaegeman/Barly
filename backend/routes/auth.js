const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const JWT_SECRET = process.env.JWT_SECRET || 'change-me';

// In-memory store fallback
const mem = { users: [] };

router.post('/register', async (req, res, next) => {
  try {
    const { firstName, email, password, preferences } = req.body;
    if (!firstName || !email || !password) {
      return res.status(400).json({ message: 'Champs manquants' });
    }

    if (req.app.mongoReady) {
      const exists = await User.findOne({ email });
      if (exists) return res.status(409).json({ message: 'Email déjà utilisé' });
      const hash = await bcrypt.hash(password, 10);
      const user = await User.create({ firstName, email, password: hash, preferences });
      const token = jwt.sign({ sub: user._id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
      return res.status(201).json({ token, firstName: user.firstName });
    }

    const existsMem = mem.users.find((u) => u.email === email);
    if (existsMem) return res.status(409).json({ message: 'Email déjà utilisé' });
    const hash = await bcrypt.hash(password, 10);
    const user = { id: String(mem.users.length + 1), firstName, email, password: hash, preferences };
    mem.users.push(user);
    const token = jwt.sign({ sub: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    return res.status(201).json({ token, firstName: user.firstName });
  } catch (e) {
    next(e);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'Champs manquants' });

    let user;
    if (req.app.mongoReady) {
      user = await User.findOne({ email });
    } else {
      user = mem.users.find((u) => u.email === email);
    }
    if (!user) return res.status(401).json({ message: 'Identifiants invalides' });

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ message: 'Identifiants invalides' });

    const token = jwt.sign({ sub: user._id || user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, firstName: user.firstName });
  } catch (e) {
    next(e);
  }
});

module.exports = router;


