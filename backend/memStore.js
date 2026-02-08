// Shared in-memory store used when MongoDB is unavailable.
// Keeps users, bars, events coherent across routes.

module.exports = {
  users: [],
  bars: [
    {
      id: 'b1',
      name: 'Lavender Club',
      address: '12 rue des Fleurs, Paris',
      geo: { type: 'Point', coordinates: [2.3522, 48.8566] },
      ambiance: ['Cosy', 'Dance'],
      music: ['House', 'Pop'],
      drinks: ['Cocktails', 'Bières'],
      priceLevel: '€€',
      pintPrice: '7€',
      rating: 4.6,
      coverImage: '/images/bar_cover.jpg',
    },
    {
      id: 'b2',
      name: 'Sway Bar',
      address: '5 avenue Montaigne, Paris',
      geo: { type: 'Point', coordinates: [2.303, 48.869] },
      ambiance: ['Chill'],
      music: ['Jazz'],
      drinks: ['Vin', 'Soft'],
      priceLevel: '€',
      pintPrice: '5€',
      rating: 4.4,
      coverImage: '/images/bar_cover.jpg',
    },
    {
      id: 'b3',
      name: 'Purple Lounge',
      address: '8 quai de Seine, Paris',
      geo: { type: 'Point', coordinates: [2.377, 48.86] },
      ambiance: ['Lounge'],
      music: ['RnB'],
      drinks: ['Cocktails', 'Spiritueux'],
      priceLevel: '€€€',
      pintPrice: '9€',
      rating: 4.8,
      coverImage: '/images/bar_cover.jpg',
    },
  ],
  events: [
    { id: 'e1', barId: 'b1', title: 'Soirée House', date: new Date(Date.now() + 86400000), participants: [] },
    { id: 'e2', barId: 'b2', title: 'Live Jazz', date: new Date(Date.now() + 2 * 86400000), participants: [] },
  ],
};
