const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  items: [
    {
      product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
      quantity: { type: Number, default: 1, min: 1 },
      size: { type: String, default: '' },
      color: { type: String, default: '' },
    },
  ],
}, { timestamps: true });

module.exports = mongoose.model('Cart', cartSchema);
