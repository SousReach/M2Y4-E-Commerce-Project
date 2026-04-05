const express = require('express');
const Coupon = require('../models/Coupon');
const auth = require('../middleware/auth');

const router = express.Router();

// Get all active coupons
router.get('/', async (req, res) => {
  try {
    const coupons = await Coupon.find({
      isActive: true,
      expiresAt: { $gt: new Date() },
    }).sort({ createdAt: -1 });
    res.json(coupons);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Validate a coupon code
router.post('/validate', auth, async (req, res) => {
  try {
    const { code, cartTotal } = req.body;

    const coupon = await Coupon.findOne({
      code: code.toUpperCase(),
      isActive: true,
      expiresAt: { $gt: new Date() },
    });

    if (!coupon) {
      return res.status(404).json({ message: 'Invalid or expired coupon' });
    }

    if (coupon.usedCount >= coupon.usageLimit) {
      return res.status(400).json({ message: 'Coupon usage limit reached' });
    }

    if (cartTotal && cartTotal < coupon.minPurchase) {
      return res.status(400).json({
        message: `Minimum purchase of $${coupon.minPurchase} required`,
      });
    }

    // Calculate the discount
    let discount = (cartTotal * coupon.discountPercent) / 100;
    if (coupon.maxDiscount > 0 && discount > coupon.maxDiscount) {
      discount = coupon.maxDiscount;
    }

    res.json({
      valid: true,
      code: coupon.code,
      discountPercent: coupon.discountPercent,
      discount: parseFloat(discount.toFixed(2)),
      maxDiscount: coupon.maxDiscount,
      minPurchase: coupon.minPurchase,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
