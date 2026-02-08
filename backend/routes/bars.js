const router = require('express').Router();
const Bar = require('../models/Bar');
const memStore = require('../memStore');

router.get('/', async (req, res, next) => {
  try {
    if (req.app.mongoReady) {
      const query = {};
      if (req.query.ambiance) query.ambiance = { $in: req.query.ambiance.split(',') };
      if (req.query.musique) query.music = { $in: req.query.musique.split(',') };
      if (req.query.price) query.priceLevel = req.query.price;
      const bars = await Bar.find(query).limit(50);
      return res.json(bars);
    }
    res.json(memStore.bars);
  } catch (e) {
    next(e);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    if (req.app.mongoReady) {
      const bar = await Bar.findById(req.params.id);
      if (!bar) return res.status(404).json({ message: 'Bar introuvable' });
      return res.json(bar);
    }
    const bar = memStore.bars.find((b) => b.id === req.params.id);
    if (!bar) return res.status(404).json({ message: 'Bar introuvable' });
    res.json(bar);
  } catch (e) {
    next(e);
  }
});

module.exports = router;
