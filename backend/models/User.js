const mongoose = require('mongoose');

const PreferencesSchema = new mongoose.Schema(
  {
    ambiance: [String],
    music: [String],
    drinks: [String],
  },
  { _id: false }
);

const UserSchema = new mongoose.Schema(
  {
    firstName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    preferences: { type: PreferencesSchema, default: {} },
    favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Bar' }],
    role: { type: String, default: 'user' },
  },
  { timestamps: true }
);

module.exports = mongoose.models.User || mongoose.model('User', UserSchema);


