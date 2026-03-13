const mongoose = require('mongoose');
require('dotenv').config();

const Category = require('./models/Category');
const Product = require('./models/Product');

const categories = [
  { name: 'Audemars Piguet', image: 'https://cdn.freebiesupply.com/logos/large/2x/audemars-piguet-logo-black-and-white.png' },
  { name: 'Patek Philippe', image: 'https://cdn.freebiesupply.com/logos/large/2x/patek-philippe-logo-black-and-white.png' },
  { name: 'Richard Mille', image: 'https://companylogos.org/wp-content/uploads/2024/12/Richard-Mille-2001.png' },
  { name: 'Rolex', image: 'https://cdn.freebiesupply.com/logos/large/2x/rolex-logo-black-and-white.png' },
  { name: 'Omega', image: 'https://cdn.freebiesupply.com/logos/large/2x/omega-2-logo-png-transparent.png' },
  { name: 'Cartier', image: 'https://cdn.freebiesupply.com/logos/large/2x/cartier-2-logo-png-transparent.png' },
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

      //Audemars Piguet
      {
        name: 'Royal Oak | Perpetual Calendar | 41 Skeleton | Black Ceramic',
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
        name: 'Royal Oak | Perpetual Calendar | Blue Ceramic',
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
        name: 'Ultra-Complication | Universelle',
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
        name: 'Royal Oak | Rainbow Double Balance Wheel | Openworked',
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
        name: 'Royal Oak | Concept | MARVEL BLACK PANTHER | Flying Tourbillon',
        description: 'Flex on the huzz with this watch.',
        price: 804000.00,
        images: ['https://watchlab.ae/upload/iblock/287/hb1a2prwbpmlt0l0i4h3wzegotwzkzg0.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Purple'],
        stock: 30,
        isFeatured: true,
      },

      //Patek Philippe
      {
        name: 'Nautilus | Tiffany & Co. Blue Dial',
        description: 'Flex on the huzz with this watch.',
        price: 1500000.00,
        images: ['https://cdn2.chrono24.com/images/product/159726-9ow4vym7vlq8xxbt5m49ut9w-Large.jpg'],
        category: catMap['Patek Philippe'],
        sizes: ['S', 'M', 'L'],
        colors: ['Tiffany Blue'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Celestial Moon | Grand complication',
        description: 'Flex on the huzz with this watch.',
        price: 1600000.00,
        images: ['https://img.chrono24.com/images/uhren/34252830-r6c42lvxxcdp5xtv0wwneezk-ExtraLarge.jpg'],
        category: catMap['Patek Philippe'],
        sizes: ['S', 'M', 'L'],
        colors: ['Rose Gold','Platinum','Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Perpetual Calendar | Chronograph',
        description: 'Flex on the huzz with this watch.',
        price: 245000.00,
        images: ['https://img.chrono24.com/images/uhren/42699417-tf6tpfgmsrbliw7xmthnbpcb-ExtraLarge.jpg'],
        category: catMap['Patek Philippe'],
        sizes: ['S', 'M', 'L'],
        colors: ['Platinum','Rose Gold','White Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Nautilus',
        description: 'Flex on the huzz with this watch.',
        price: 120000.00,
        images: ['https://img.chrono24.com/images/uhren/35216606-xuyiijb6865o7o7e4ts1w40p-ExtraLarge.jpg'],
        category: catMap['Patek Philippe'],
        sizes: ['S', 'M', 'L'],
        colors: ['Rose Gold','Platinum','Gold','White Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Aquanaut | Luce "Rainbow" Haute Joaillerie | Minute Repeater',
        description: 'Flex on the huzz with this watch.',
        price: 730000.00,
        images: ['https://img.chrono24.com/images/uhren/31744953-qv56opnnfjebla4g1smdyyre-ExtraLarge.jpg'],
        category: catMap['Patek Philippe'],
        sizes: ['S', 'M', 'L'],
        colors: ['Tiffany Blue'],
        stock: 30,
        isFeatured: true,
      },

      //Richard Mille
      {
        name: 'RM 052 | Skull Tourbillon | Rose Gold Limited Edition',
        description: 'Flex on the huzz with this watch.',
        price: 2000000.00,
        images: ['https://img.chrono24.com/images/uhren/32469519-95y9opbuudbfkdnbuz3hees0-ExtraLarge.jpg'],
        category: catMap['Richard Mille'],
        sizes: ['S', 'M', 'L'],
        colors: ['Rose Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'RM 11-03 | "Last White Edition" | Automatic Flyback Chronograph',
        description: 'Flex on the huzz with this watch.',
        price: 550000.00,
        images: ['https://img.chrono24.com/images/uhren/34526538-rwkxlrzkkz5v1nvrt7e20yvn-ExtraLarge.jpg'],
        category: catMap['Richard Mille'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Ceramic'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'RM 88 | Tourbillon | Smiley',
        description: 'Flex on the huzz with this watch.',
        price: 4024000.00,
        images: ['https://img.chrono24.com/images/uhren/38350421-lapkti2gscyxa9hszl9zat2v-ExtraLarge.jpg'],
        category: catMap['Richard Mille'],
        sizes: ['S', 'M', 'L'],
        colors: ['Multicolor Ceramic'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'RM 055 | Bubba Watson | White Ceramic',
        description: 'Flex on the huzz with this watch.',
        price: 360000.00,
        images: ['https://img.chrono24.com/images/uhren/32833542-2vvreliatzvyaqlvr94cktro-ExtraLarge.jpg'],
        category: catMap['Richard Mille'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Ceramic'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'RM 57-02 | Tourbillon Carbon TPT | Sapphire Dragon',
        description: 'Flex on the huzz with this watch.',
        price: 120000.00,
        images: ['https://img.chrono24.com/images/uhren/41591552-zb9feu9d8wip00qasa1biecj-ExtraLarge.jpg'],
        category: catMap['Richard Mille'],
        sizes: ['S', 'M', 'L'],
        colors: ['Carbon TPT'],
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
