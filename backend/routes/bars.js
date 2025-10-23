const router = require('express').Router();
const Bar = require('../models/Bar');

// simple mocks
const mockBars = [
  {
    id: 'b1',
    name: 'Lavender Club',
    address: '12 rue des Fleurs, Paris',
    geo: { type: 'Point', coordinates: [2.3522, 48.8566] },
    ambiance: ['Cosy', 'Dance'],
    music: ['House', 'Pop'],
    priceLevel: '€€',
    coverImage: '/images/bar_cover.jpg',
  },
  {
    id: 'b2',
    name: 'Sway Bar',
    address: '5 avenue Montaigne, Paris',
    geo: { type: 'Point', coordinates: [2.303, 48.869] },
    ambiance: ['Chill'],
    music: ['Jazz'],
    priceLevel: '€',
    coverImage: '/images/bar_cover.jpg',
  },
  {
    id: 'b3',
    name: 'Purple Lounge',
    address: '8 quai de Seine, Paris',
    geo: { type: 'Point', coordinates: [2.377, 48.86] },
    ambiance: ['Lounge'],
    music: ['RnB'],
    priceLevel: '€€€',
    coverImage: '/images/bar_cover.jpg',
  },
];

router.get('/', async (req, res, next) => {
  try {
    if (req.app.mongoReady) {
      const query = {};
      // filters (ambiance/music/price) basic
      if (req.query.ambiance) query.ambiance = { $in: req.query.ambiance.split(',') };
      if (req.query.musique) query.music = { $in: req.query.musique.split(',') };
      if (req.query.price) query.priceLevel = req.query.price;
      const bars = await Bar.find(query).limit(50);
      return res.json(bars);
    }
    res.json(mockBars);
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
    const bar = mockBars.find((b) => b.id === req.params.id);
    if (!bar) return res.status(404).json({ message: 'Bar introuvable' });
    res.json(bar);
  } catch (e) {
    next(e);
  }
});

module.exports = router;



