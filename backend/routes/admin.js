const express = require('express');
const Product = require('../models/Product');
const Category = require('../models/Category');
const Order = require('../models/Order');
const User = require('../models/User');
const Review = require('../models/Review');

const router = express.Router();

// ── Dashboard stats ─────────────────────────────────────────
router.get('/stats', async (req, res) => {
  try {
    const [totalProducts, totalOrders, totalUsers, totalCategories] =
      await Promise.all([
        Product.countDocuments(),
        Order.countDocuments(),
        User.countDocuments(),
        Category.countDocuments(),
      ]);

    const revenueAgg = await Order.aggregate([
      { $match: { status: { $nin: ['cancelled'] } } },
      { $group: { _id: null, total: { $sum: '$totalPrice' } } },
    ]);
    const totalRevenue = revenueAgg.length > 0 ? revenueAgg[0].total : 0;

    const ordersByStatus = await Order.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]);

    const recentOrders = await Order.find()
      .sort({ createdAt: -1 })
      .limit(10)
      .populate('user', 'name email');

    const lowStockProducts = await Product.find({ stock: { $lte: 5 } })
      .sort({ stock: 1 })
      .limit(10)
      .populate('category', 'name');

    res.json({
      totalProducts,
      totalOrders,
      totalUsers,
      totalCategories,
      totalRevenue,
      ordersByStatus,
      recentOrders,
      lowStockProducts,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ── Products CRUD ───────────────────────────────────────────
router.get('/products', async (req, res) => {
  try {
    const products = await Product.find()
      .populate('category', 'name')
      .sort({ createdAt: -1 });
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/products', async (req, res) => {
  try {
    const { name, description, price, images, category, sizes, colors, stock, isFeatured } = req.body;
    const product = new Product({
      name, description, price, images, category, sizes, colors, stock, isFeatured,
    });
    await product.save();
    const populated = await Product.findById(product._id).populate('category', 'name');
    res.status(201).json(populated);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put('/products/:id', async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true })
      .populate('category', 'name');
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/products/:id', async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    await Review.deleteMany({ product: req.params.id });
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ── Categories CRUD ─────────────────────────────────────────
router.get('/categories', async (req, res) => {
  try {
    const categories = await Category.find().sort({ name: 1 });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/categories', async (req, res) => {
  try {
    const category = new Category({ name: req.body.name, image: req.body.image || '' });
    await category.save();
    res.status(201).json(category);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/categories/:id', async (req, res) => {
  try {
    const productCount = await Product.countDocuments({ category: req.params.id });
    if (productCount > 0) {
      return res.status(400).json({
        message: `Cannot delete: ${productCount} product(s) use this category`,
      });
    }
    const cat = await Category.findByIdAndDelete(req.params.id);
    if (!cat) return res.status(404).json({ message: 'Category not found' });
    res.json({ message: 'Category deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ── Orders management ───────────────────────────────────────
router.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find()
      .sort({ createdAt: -1 })
      .populate('user', 'name email');
    res.json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put('/orders/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const valid = ['pending', 'paid', 'confirmed', 'shipped', 'delivered', 'cancelled'];
    if (!valid.includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    ).populate('user', 'name email');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ── Users (read-only) ───────────────────────────────────────
router.get('/users', async (req, res) => {
  try {
    const users = await User.find()
      .select('-password -cart')
      .sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
