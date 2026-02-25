const mongoose = require('mongoose');
require('dotenv').config();

const Category = require('./models/Category');
const Product = require('./models/Product');

const categories = [
  { name: 'T-Shirts', image: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400' },
  { name: 'Pants', image: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400' },
  { name: 'Dresses', image: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400' },
  { name: 'Jackets', image: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400' },
  { name: 'Shoes', image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400' },
  { name: 'Accessories', image: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=400' },
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
        price: 24.99,
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
        price: 34.99,
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
        price: 29.99,
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
        price: 49.99,
        images: ['https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=600'],
        category: catMap['Pants'],
        sizes: ['28', '30', '32', '34', '36'],
        colors: ['Khaki', 'Navy', 'Black'],
        stock: 30,
        isFeatured: true,
      },
      {
        name: 'Classic Denim Jeans',
        description: 'Premium straight-fit denim jeans with a vintage wash finish.',
        price: 59.99,
        images: ['https://images.unsplash.com/photo-1542272604-787c3835535d?w=600'],
        category: catMap['Pants'],
        sizes: ['28', '30', '32', '34'],
        colors: ['Blue', 'Dark Blue', 'Black'],
        stock: 25,
        isFeatured: true,
      },
      {
        name: 'Jogger Pants',
        description: 'Comfortable jogger pants perfect for casual outings or lounging.',
        price: 39.99,
        images: ['https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=600'],
        category: catMap['Pants'],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Gray', 'Black', 'Olive'],
        stock: 45,
        isFeatured: false,
      },

      // Dresses
      {
        name: 'Floral Summer Dress',
        description: 'Light and flowy floral dress, perfect for warm weather outings.',
        price: 54.99,
        images: ['https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=600'],
        category: catMap['Dresses'],
        sizes: ['XS', 'S', 'M', 'L'],
        colors: ['Floral Print', 'Blue'],
        stock: 20,
        isFeatured: true,
      },
      {
        name: 'Little Black Dress',
        description: 'An elegant little black dress for any special occasion.',
        price: 69.99,
        images: ['https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=600'],
        category: catMap['Dresses'],
        sizes: ['XS', 'S', 'M', 'L'],
        colors: ['Black'],
        stock: 15,
        isFeatured: true,
      },
      {
        name: 'Casual Midi Dress',
        description: 'A relaxed midi-length dress in soft cotton. Comfortable yet stylish.',
        price: 44.99,
        images: ['https://images.unsplash.com/photo-1596783074918-c84cb06531ca?w=600'],
        category: catMap['Dresses'],
        sizes: ['S', 'M', 'L'],
        colors: ['Beige', 'Dusty Rose'],
        stock: 22,
        isFeatured: false,
      },

      // Jackets
      {
        name: 'Leather Biker Jacket',
        description: 'Classic faux leather biker jacket with a modern slim fit.',
        price: 89.99,
        images: ['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600'],
        category: catMap['Jackets'],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Black', 'Brown'],
        stock: 18,
        isFeatured: true,
      },
      {
        name: 'Denim Trucker Jacket',
        description: 'A versatile denim jacket that goes with everything.',
        price: 64.99,
        images: ['https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=600'],
        category: catMap['Jackets'],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Light Blue', 'Dark Blue'],
        stock: 20,
        isFeatured: false,
      },
      {
        name: 'Windbreaker',
        description: 'Lightweight windbreaker with a water-resistant shell. Great for outdoor activities.',
        price: 54.99,
        images: ['https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600'],
        category: catMap['Jackets'],
        sizes: ['M', 'L', 'XL'],
        colors: ['Navy', 'Green', 'Black'],
        stock: 30,
        isFeatured: false,
      },

      // Shoes
      {
        name: 'White Canvas Sneakers',
        description: 'Clean minimalist white sneakers. A wardrobe essential.',
        price: 44.99,
        images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'],
        category: catMap['Shoes'],
        sizes: ['38', '39', '40', '41', '42', '43', '44'],
        colors: ['White', 'Black'],
        stock: 40,
        isFeatured: true,
      },
      {
        name: 'Running Shoes',
        description: 'Lightweight and supportive running shoes with cushioned soles.',
        price: 74.99,
        images: ['https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600'],
        category: catMap['Shoes'],
        sizes: ['39', '40', '41', '42', '43', '44'],
        colors: ['Black/Red', 'Gray/Blue'],
        stock: 25,
        isFeatured: false,
      },
      {
        name: 'Chelsea Boots',
        description: 'Classic leather Chelsea boots with elastic side panels.',
        price: 84.99,
        images: ['https://images.unsplash.com/photo-1638247025967-b4e38f787b76?w=600'],
        category: catMap['Shoes'],
        sizes: ['39', '40', '41', '42', '43', '44'],
        colors: ['Black', 'Brown'],
        stock: 15,
        isFeatured: false,
      },

      // Accessories
      {
        name: 'Leather Belt',
        description: 'Premium leather belt with a brushed metal buckle.',
        price: 29.99,
        images: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600'],
        category: catMap['Accessories'],
        sizes: ['S', 'M', 'L'],
        colors: ['Black', 'Brown'],
        stock: 50,
        isFeatured: false,
      },
      {
        name: 'Minimalist Watch',
        description: 'Sleek minimalist watch with a genuine leather strap.',
        price: 49.99,
        images: ['https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=600'],
        category: catMap['Accessories'],
        sizes: ['One Size'],
        colors: ['Silver/Black', 'Gold/Brown'],
        stock: 20,
        isFeatured: true,
      },
      {
        name: 'Canvas Tote Bag',
        description: 'Spacious canvas tote bag for everyday use.',
        price: 19.99,
        images: ['https://images.unsplash.com/photo-1544816155-12df9643f363?w=600'],
        category: catMap['Accessories'],
        sizes: ['One Size'],
        colors: ['Natural', 'Black'],
        stock: 60,
        isFeatured: false,
      },
      {
        name: 'Wool Beanie',
        description: 'Warm knitted wool beanie for the colder months.',
        price: 14.99,
        images: ['https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=600'],
        category: catMap['Accessories'],
        sizes: ['One Size'],
        colors: ['Black', 'Gray', 'Burgundy'],
        stock: 45,
        isFeatured: false,
      },
      {
        name: 'Aviator Sunglasses',
        description: 'Classic aviator sunglasses with UV400 protection.',
        price: 24.99,
        images: ['https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600'],
        category: catMap['Accessories'],
        sizes: ['One Size'],
        colors: ['Gold/Green', 'Silver/Blue'],
        stock: 35,
        isFeatured: false,
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
