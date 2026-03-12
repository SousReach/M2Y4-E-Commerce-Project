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
        description: 'Wear this to the party like you deserve it daddy.',
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
        description: 'If you want to end up in the files, wear this bad boy for your island vacation.',
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
        description: 'Recommended by the best barber in the game. The best hast for the best stroker in the gang.',
        price: 1.00,
        images: ['https://pbs.twimg.com/media/FhIgQlsWYAA9bID.jpg'],
        category: catMap['Accessories'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Blue', 'Black', 'White'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Orange Hoodie',
        description: 'Wear this if messi is the goat',
        price: 1.00,
        images: ['https://campaignme.com/wp-content/uploads/2022/03/talabat-_-Cristiano-Ronaldo-2.jpg'],
        category: catMap['T-Shirts'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Orange', 'Black', 'White'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Dior Sweater',
        description: 'Feeling like oppa and taking penalty over dog ass club while ghosting in big games.',
        price: 1.00,
        images: ['https://versus.uk.com/wp-content/uploads/2025/08/64759600f36e14ee9b88a992_267549651_304332918257098_9186883737337548800_n-800x1000-1.jpeg'],
        category: catMap['T-Shirts'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Sand', 'Black', 'White'],
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
