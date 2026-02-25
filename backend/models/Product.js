const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
    min: 0,
  },
  images: {
    type: [String],
    default: [],
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true,
  },
  sizes: {
    type: [String],
    default: ['S', 'M', 'L', 'XL'],
  },
  colors: {
    type: [String],
    default: [],
  },
  stock: {
    type: Number,
    default: 0,
    min: 0,
  },
  isFeatured: {
    type: Boolean,
    default: false,
  },
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
