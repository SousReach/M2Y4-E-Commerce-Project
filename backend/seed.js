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

    // Insert products area
    const products = [
      {
        name: 'Blazer',
        description: 'Black',
        price: 1.00,
        images: ['https://static01.nyt.com/images/2025/05/05/multimedia/05MET-GALA-LIVEBLOG-DIDDY-01-pqvt/05MET-GALA-LIVEBLOG-DIDDY-01-pqvt-articleLarge-v2.jpg?quality=75&auto=webp&disable=upscale'],
        category: catMap['Dresses'],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Red', 'Black', 'Gray'],
        stock: 50,
        isFeatured: true,
      },
      {
        name: 'Quarter Zip',
        description: 'The Island Best Choice',
        price: 1.00,
        images: ['https://static01.nyt.com/images/2026/02/04/fashion/04epstein-clothes/04epstein-clothes-articleLarge.jpg?quality=75&auto=webp&disable=upscale'],
        category: catMap['T-Shirts'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Navy', 'Black', 'Blue'],
        stock: 30,
        isFeatured: true,
      },
      {
        name: 'KC-Hat',
        description: 'The best hat for the best stroker',
        price: 1.00,
        images: ['https://pbs.twimg.com/media/FhIgQlsWYAA9bID.jpg'],
        category: catMap['Accessories'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Blue', 'Black', 'White'],
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
