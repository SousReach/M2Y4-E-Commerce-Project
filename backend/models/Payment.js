const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
  },
  transactionId: {
    type: String,
    required: true,
    unique: true,
  },
  amount: {
    type: Number,
    required: true,
    min: 0,
  },
  currency: {
    type: String,
    enum: ['USD', 'KHR'],
    default: 'USD',
  },
  method: {
    type: String,
    enum: ['aba_khqr', 'cash_on_delivery', 'credit_card', 'bank_transfer'],
    default: 'aba_khqr',
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'declined', 'refunded'],
    default: 'pending',
  },
}, { timestamps: true });

module.exports = mongoose.model('Payment', paymentSchema);
