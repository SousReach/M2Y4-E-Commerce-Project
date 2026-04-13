const express = require('express');
const Order = require('../models/Order');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();


router.post('/', auth, async (req, res) => {
  try {
    const { items, totalPrice, shippingAddress } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'No items in order' });
    }

    const order = new Order({
      user: req.userId,
      items,
      totalPrice,
      shippingAddress,
    });

    await order.save();

    // Clear user's cart after placing order
    const user = await User.findById(req.userId);
    user.cart = [];
    await user.save();

    res.status(201).json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get user's orders
router.get('/', auth, async (req, res) => {
  try {
    const orders = await Order.find({ user: req.userId }).sort({
      createdAt: -1,
    });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get single order
router.get('/:id', auth, async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.userId,
    });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    res.json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Cancel a pending order
router.put('/:id/cancel', auth, async (req, res) => {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      user: req.userId,
    });
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }
    if (order.status !== 'pending') {
      return res.status(400).json({
        message: 'Only pending orders can be cancelled',
      });
    }
    order.status = 'cancelled';
    await order.save();
    res.json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
