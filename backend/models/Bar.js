const mongoose = require('mongoose');

const GeoSchema = new mongoose.Schema(
  {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], required: true }, // [lng, lat]
  },
  { _id: false }
);

const BarSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    address: String,
    geo: { type: GeoSchema, index: '2dsphere' },
    ambiance: [String],
    music: [String],
    priceLevel: { type: String, enum: ['€', '€€', '€€€'], default: '€' },
    coverImage: String,
  },
  { timestamps: true }
);

module.exports = mongoose.models.Bar || mongoose.model('Bar', BarSchema);



