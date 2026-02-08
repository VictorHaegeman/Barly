const router = require('express').Router();
const auth = require('../middlewares/auth');
const User = require('../models/User');
const memStore = require('../memStore');

router.get('/me', auth, async (req, res, next) => {
  try {
    if (req.app.mongoReady) {
      const user = await User.findById(req.userId).select('-password');
      return res.json(user);
    }
    const user = memStore.users.find((u) => u.id === req.userId);
    if (!user) return res.status(404).json({ message: 'Utilisateur introuvable' });
    const { password, ...safe } = user;
    res.json(safe);
  } catch (e) {
    next(e);
  }
});

router.patch('/me', auth, async (req, res, next) => {
  try {
    const { preferences } = req.body;
    if (req.app.mongoReady) {
      const user = await User.findByIdAndUpdate(
        req.userId,
        { $set: { preferences } },
        { new: true }
      ).select('-password');
      return res.json(user);
    }
    const idx = memStore.users.findIndex((u) => u.id === req.userId);
    if (idx === -1) return res.status(404).json({ message: 'Utilisateur introuvable' });
    memStore.users[idx].preferences = preferences;
    const { password, ...safe } = memStore.users[idx];
    res.json(safe);
  } catch (e) {
    next(e);
  }
});

module.exports = router;

