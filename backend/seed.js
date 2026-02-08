const mongoose = require('mongoose');
const memStore = require('./memStore');
require('dotenv').config({ path: __dirname + '/.env' });

async function seed() {
  if (!process.env.MONGO_URI) {
    console.log('MONGO_URI manquant, seed annulé.');
    return;
  }
  await mongoose.connect(process.env.MONGO_URI, { dbName: process.env.MONGO_DB || 'barly' });
  const Bar = require('./models/Bar');
  const Event = require('./models/Event');

  await Bar.deleteMany({});
  await Event.deleteMany({});

  const bars = await Bar.insertMany(memStore.bars);
  const events = memStore.events.map((e) => ({
    barId: bars.find((b) => b.id === e.barId || b._id?.toString() === e.barId)?._id || bars[0]._id,
    title: e.title,
    date: e.date,
    participants: [],
  }));
  await Event.insertMany(events);
  console.log('Seed terminé.');
  await mongoose.disconnect();
}

seed().catch((e) => {
  console.error(e);
  process.exit(1);
});
