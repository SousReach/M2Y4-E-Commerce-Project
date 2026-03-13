const mongoose = require('mongoose');
require('dotenv').config();

const Category = require('./models/Category');
const Product = require('./models/Product');

const categories = [
  { name: 'Audemars Piguet', image: '' },
  { name: 'Patek Philippe', image: '' },
  { name: 'Richard Mille', image: '' },
  { name: 'Rolex', image: '' },
  { name: 'Omega', image: '' },
  { name: 'Cartier', image: '' },
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
        name: 'Royal Oak Perpetual Calendar 41 Skeleton Black Ceramic',
        description: 'Flex on the huzz with this watch.',
        price: 528000.00,
        images: ['https://watchlab.ae/upload/iblock/9c3/3meosh19f0ht8xvd2jw2rflm9pt3mvle.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Black Ceramic'],
        stock: 30,
        isFeatured: true,
      },
      
      {
        name: 'Royal Oak Perpetual Calendar Blue Ceramic',
        description: 'Flex on the huzz with this watch.',
        price: 1250000.00,
        images: ['https://img.chrono24.com/images/uhren/43730272-x8wfot8qbmyvl2122z2wwirs-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Blue Ceramic'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Ultra-Complication Universelle',
        description: 'Flex on the huzz with this watch.',
        price: 1980000.00,
        images: ['https://img.chrono24.com/images/uhren/30991066-k38a4fu3ye23e18n1pn50s4e-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Gold','Platinum','Rose Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Royal Oak Rainbow Double Balance Wheel Openworked',
        description: 'Flex on the huzz with this watch.',
        price: 248000.00,
        images: ['https://img.chrono24.com/images/uhren/32729340-b48ocvb1mcj9fz41i8xg41va-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold','Platinum','Rose Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Royal Oak Concept MARVEL BLACK PANTHER Flying Tourbillon',
        description: 'Flex on the huzz with this watch.',
        price: 804000.00,
        images: ['https://watchlab.ae/upload/iblock/287/hb1a2prwbpmlt0l0i4h3wzegotwzkzg0.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Purple'],
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
