const mongoose = require('mongoose');
require('dotenv').config();

const Category = require('./models/Category');
const Product = require('./models/Product');

const categories = [
  { name: 'T-Shirts', image: '' },
  { name: 'Pants', image: '' },
  { name: 'Dresses', image: '' },
  { name: 'Jackets', image: '' },
  { name: 'Shoes', image: '' },
  { name: 'Accessories', image: '' },
];

const seedDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing data
    await Category.deleteMany({});
    await Product.deleteMany({});
    console.log('Cleared existing data');

    // Insert categories
    const createdCategories = await Category.insertMany(categories);
    console.log(`Inserted ${createdCategories.length} categories`);

    const catMap = {};
    createdCategories.forEach((c) => (catMap[c.name] = c._id));

    // Insert products
    const products = [
      // T-Shirts
      {
        name: 'Classic White Tee',
        description: 'A timeless white cotton t-shirt. Soft, breathable, and perfect for everyday wear.',
        price: 1.00,
        images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600'],
        category: catMap['T-Shirts'],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['White', 'Black', 'Gray'],
        stock: 50,
        isFeatured: true,
      },
      {
        name: 'Oversized Graphic Tee',
        description: 'Relaxed fit t-shirt with a modern graphic print. Made from 100% organic cotton.',
        price: 1.00,
        images: ['https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600'],
        category: catMap['T-Shirts'],
        sizes: ['M', 'L', 'XL'],
        colors: ['Black', 'Navy'],
        stock: 35,
        isFeatured: false,
      },
      {
        name: 'Striped Crew Neck',
        description: 'Casual striped t-shirt with a comfortable crew neck. Great for layering.',
        price: 1.00,
        images: ['https://images.unsplash.com/photo-1627225924765-552d49cf47ad?w=600'],
        category: catMap['T-Shirts'],
        sizes: ['S', 'M', 'L'],
        colors: ['Blue/White', 'Red/White'],
        stock: 40,
        isFeatured: false,
      },

      // Pants
      {
        name: 'Slim Fit Chinos',
        description: 'Modern slim-fit chino pants with a comfortable stretch fabric.',
        price: 1.00,
        images: ['https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600'],
        category: catMap['Pants'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Khaki', 'Navy', 'Black'],
        stock: 30,
        isFeatured: true,
      },

    ];

    const createdProducts = await Product.insertMany(products);
    console.log(`Inserted ${createdProducts.length} products`);

    console.log('Database seeded successfully!');
    process.exit(0);
  } catch (err) {
    console.error('Seeding error:', err.message);
    process.exit(1);
  }
};

seedDB();
