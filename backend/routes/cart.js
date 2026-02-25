const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

// Get user's cart
router.get('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).populate('cart.product');
    res.json(user.cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add item to cart
router.post('/add', auth, async (req, res) => {
  try {
    const { productId, quantity, size, color } = req.body;
    const user = await User.findById(req.userId);

    // Check if product already in cart with same size/color
    const existingIndex = user.cart.findIndex(
      (item) =>
        item.product.toString() === productId &&
        item.size === size &&
        item.color === color
    );

    if (existingIndex > -1) {
      user.cart[existingIndex].quantity += quantity || 1;
    } else {
      user.cart.push({
        product: productId,
        quantity: quantity || 1,
        size: size || '',
        color: color || '',
      });
    }

    await user.save();
    const populated = await User.findById(req.userId).populate('cart.product');
    res.json(populated.cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update cart item quantity
router.put('/update', auth, async (req, res) => {
  try {
    const { productId, quantity, size, color } = req.body;
    const user = await User.findById(req.userId);

    const item = user.cart.find(
      (item) =>
        item.product.toString() === productId &&
        item.size === (size || '') &&
        item.color === (color || '')
    );

    if (item) {
      item.quantity = quantity;
    }

    await user.save();
    const populated = await User.findById(req.userId).populate('cart.product');
    res.json(populated.cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Remove item from cart
router.delete('/remove/:itemId', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    user.cart = user.cart.filter(
      (item) => item._id.toString() !== req.params.itemId
    );
    await user.save();
    const populated = await User.findById(req.userId).populate('cart.product');
    res.json(populated.cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Clear cart
router.delete('/clear', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    user.cart = [];
    await user.save();
    res.json([]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
