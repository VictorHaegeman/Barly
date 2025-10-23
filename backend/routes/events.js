const router = require('express').Router();
const auth = require('../middlewares/auth');
const Event = require('../models/Event');

// link to bars mock ids
const mem = {
  events: [
    { id: 'e1', barId: 'b1', title: 'Soirée House', date: new Date(Date.now() + 86400000), participants: [] },
    { id: 'e2', barId: 'b2', title: 'Live Jazz', date: new Date(Date.now() + 2 * 86400000), participants: [] },
  ],
};

router.get('/', auth, async (req, res, next) => {
  try {
    if (req.app.mongoReady) {
      const events = await Event.find().limit(50);
      return res.json(events);
    }
    res.json(mem.events);
  } catch (e) {
    next(e);
  }
});

router.post('/', auth, async (req, res, next) => {
  try {
    const { barId, title, date } = req.body;
    if (req.app.mongoReady) {
      const event = await Event.create({ barId, title, date });
      return res.status(201).json(event);
    }
    const ne = { id: `e${mem.events.length + 1}`, barId, title, date: new Date(date), participants: [] };
    mem.events.push(ne);
    res.status(201).json(ne);
  } catch (e) {
    next(e);
  }
});

router.post('/:id/join', auth, async (req, res, next) => {
  try {
    if (req.app.mongoReady) {
      const ev = await Event.findByIdAndUpdate(
        req.params.id,
        { $addToSet: { participants: req.userId } },
        { new: true }
      );
      if (!ev) return res.status(404).json({ message: 'Event introuvable' });
      return res.json(ev);
    }
    const ev = mem.events.find((e) => e.id === req.params.id);
    if (!ev) return res.status(404).json({ message: 'Event introuvable' });
    if (!ev.participants.includes(req.userId)) ev.participants.push(req.userId);
    res.json(ev);
  } catch (e) {
    next(e);
  }
});

module.exports = router;



