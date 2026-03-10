const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  items: [
    {
      product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
      name: String,
      price: Number,
      quantity: { type: Number, default: 1 },
      size: String,
      color: String,
    },
  ],
  totalPrice: {
    type: Number,
    required: true,
  },
  shippingAddress: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    country: { type: String, required: true },
    phone: { type: String, required: true },
  },
  status: {
    type: String,
    enum: ['pending', 'paid', 'confirmed', 'shipped', 'delivered', 'cancelled'],
    default: 'pending',
  },
  paymentMethod: {
    type: String,
    default: '',
  },
  abaTranId: {
    type: String,
    default: '',
  },
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
