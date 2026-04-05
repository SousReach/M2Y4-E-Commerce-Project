const express = require('express');
const Address = require('../models/Address');
const auth = require('../middleware/auth');

const router = express.Router();

// Get user's saved addresses
router.get('/', auth, async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.userId }).sort({ isDefault: -1, createdAt: -1 });
    res.json(addresses);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add new address
router.post('/', auth, async (req, res) => {
  try {
    const { label, street, city, country, phone, isDefault } = req.body;

    // If setting as default, unset other defaults
    if (isDefault) {
      await Address.updateMany({ user: req.userId }, { isDefault: false });
    }

    const address = new Address({
      user: req.userId,
      label: label || 'Home',
      street,
      city,
      country,
      phone: phone || '',
      isDefault: isDefault || false,
    });

    await address.save();
    res.status(201).json(address);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update address
router.put('/:id', auth, async (req, res) => {
  try {
    const { label, street, city, country, phone, isDefault } = req.body;

    if (isDefault) {
      await Address.updateMany({ user: req.userId }, { isDefault: false });
    }

    const address = await Address.findOneAndUpdate(
      { _id: req.params.id, user: req.userId },
      { label, street, city, country, phone, isDefault },
      { new: true }
    );

    if (!address) {
      return res.status(404).json({ message: 'Address not found' });
    }
    res.json(address);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Delete address
router.delete('/:id', auth, async (req, res) => {
  try {
    const address = await Address.findOneAndDelete({
      _id: req.params.id,
      user: req.userId,
    });
    if (!address) {
      return res.status(404).json({ message: 'Address not found' });
    }
    res.json({ message: 'Address deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
