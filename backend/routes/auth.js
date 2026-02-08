const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const memStore = require('../memStore');
const { validate, schemas } = require('../validation');

const JWT_SECRET = process.env.JWT_SECRET || 'change-me';

router.post('/register', validate(schemas.register), async (req, res, next) => {
  try {
    const { firstName, email, password, preferences } = req.body;

    if (req.app.mongoReady) {
      const exists = await User.findOne({ email });
      if (exists) return res.status(409).json({ message: 'Email déjà utilisé' });
      const hash = await bcrypt.hash(password, 10);
      const user = await User.create({ firstName, email, password: hash, preferences });
      const token = jwt.sign({ sub: user._id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
      return res.status(201).json({ token, firstName: user.firstName });
    }

    const existsMem = memStore.users.find((u) => u.email === email);
    if (existsMem) return res.status(409).json({ message: 'Email déjà utilisé' });
    const hash = await bcrypt.hash(password, 10);
    const user = { id: String(memStore.users.length + 1), firstName, email, password: hash, preferences };
    memStore.users.push(user);
    const token = jwt.sign({ sub: user.id, email: user.email }, JWT_SECRET, { expiresIn: '7d' });
    return res.status(201).json({ token, firstName: user.firstName });
  } catch (e) {
    next(e);
  }
});

router.post('/login', validate(schemas.login), async (req, res, next) => {
  try {
    const { email, password } = req.body;

    let user;
    if (req.app.mongoReady) {
      user = await User.findOne({ email });
    } else {
      user = memStore.users.find((u) => u.email === email);
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
