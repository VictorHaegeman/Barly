const mongoose = require('mongoose');

const EventSchema = new mongoose.Schema(
  {
    barId: { type: mongoose.Schema.Types.ObjectId, ref: 'Bar', required: true },
    title: { type: String, required: true },
    date: { type: Date, required: true },
    participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  },
  { timestamps: true }
);

module.exports = mongoose.models.Event || mongoose.model('Event', EventSchema);


