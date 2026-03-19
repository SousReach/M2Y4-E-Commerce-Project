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
        description: 'I have tos',
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
        isFeatured: false,
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
        isFeatured: false,
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
        isFeatured: false,
      },

      {
        name: 'Royal Oak | Double Balance Wheel Openworked | Chandelier',
        description: 'Flex on the huzz with this watch.',
        price: 1840000.00,
        images: ['https://img.chrono24.com/images/uhren/33543635-pbt3cebk6wai1bf93o3ix0xd-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Royal Oak | Grande Complication | White Ceramic',
        description: 'Flex on the huzz with this watch.',
        price: 1420000.00,
        images: ['https://img.chrono24.com/images/uhren/41285536-c6pmr15c6knvapac9kydbbgq-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Ceramic'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Royal Oak | Perpetual Calendar | Openworked | Catus Jack',
        description: 'Flex on the huzz with this watch.',
        price: 640000.00,
        images: ['https://img.chrono24.com/images/uhren/41285610-bjhkppegi55xyevud06jp8tj-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Travis Scott Cactus Jack'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Royal Oak | Double Balance Wheel Openworked | Sapphire Bezel | Japan Edition',
        description: 'Flex on the huzz with this watch.',
        price: 687000.00,
        images: ['https://img.chrono24.com/images/uhren/37906252-b29itirtaacy61uq44bstmps-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Japan Edition White Gold'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Royal Oak | Skeletonized | Automatic Flywheel | Tourbillon',
        description: 'Flex on the huzz with this watch.',
        price: 627000.00,
        images: ['https://img.chrono24.com/images/uhren/34397880-ki0x75h09ny5zbkrrlrcrr5c-ExtraLarge.jpg'],
        category: catMap['Audemars Piguet'],
        sizes: ['S', 'M', 'L'],
        colors: ['Rose Gold'],
        stock: 30,
        isFeatured: false,
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
        isFeatured: false,
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
        isFeatured: false,
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
        isFeatured: false,
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
        isFeatured: false,
      },

      {
        name: 'RM 57-02 | Tourbillon Carbon TPT | Sapphire Dragon',
        description: 'Flex on the huzz with this watch.',
        price: 1200000.00,
        images: ['https://img.chrono24.com/images/uhren/41591552-zb9feu9d8wip00qasa1biecj-ExtraLarge.jpg'],
        category: catMap['Richard Mille'],
        sizes: ['S', 'M', 'L'],
        colors: ['Carbon TPT'],
        stock: 30,
        isFeatured: true,
      },

      //Rolex
      {
        name: 'Daytona | Rainbow Bezel',
        description: 'Flex on the huzz with this watch.',
        price: 700000.00,
        images: ['https://img.chrono24.com/images/uhren/30656295-pahnrg7utiqurktjshg3hyum-ExtraLarge.jpg'],
        category: catMap['Rolex'],
        sizes: ['S', 'M', 'L'],
        colors: ['Rose Gold','Platinum'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Day-Date | Meteorite Dial',
        description: 'Flex on the huzz with this watch.',
        price: 145000.00,
        images: ['https://img.chrono24.com/images/uhren/36908128-sg4pghpy94jzngsj2ysppvb9-ExtraLarge.jpg'],
        category: catMap['Rolex'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Daytona | Blue Carbon | Rainbow Dial',
        description: 'Flex on the huzz with this watch.',
        price: 345000.00,
        images: ['https://about-timepieces.com/wp-content/uploads/2021/02/rainbow-blue_3d_1.jpg'],
        category: catMap['Rolex'],
        sizes: ['S', 'M', 'L'],
        colors: ['Blue Carbon Fiber'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Daytona | Eye of the Tiger',
        description: 'Flex on the huzz with this watch.',
        price: 400000.00,
        images: ['https://img.chrono24.com/images/uhren/26238088-guna6wtswqveb7k822cq1qdg-ExtraLarge.jpg'],
        category: catMap['Rolex'],
        sizes: ['S', 'M', 'L'],
        colors: ['Gold','Rose Gold','Platinum','White Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Day-Date | Jigsaw Puzzle Dial',
        description: 'Flex on the huzz with this watch.',
        price: 315000.00,
        images: ['https://img.chrono24.com/images/uhren/44399674-1q2fwtv32358nnulxgtluudy-ExtraLarge.jpg'],
        category: catMap['Rolex'],
        sizes: ['S', 'M', 'L'],
        colors: ['Gold','Rose Gold','Platinum','White Gold'],
        stock: 30,
        isFeatured: false,
      },

      //Cartier
      {
        name: 'Crash | Skeleton',
        description: 'Flex on the huzz with this watch.',
        price: 577000.00,
        images: ['https://img.chrono24.com/images/uhren/41022556-peyp87luu66g44ysjslexkpg-ExtraLarge.jpg'],
        category: catMap['Cartier'],
        sizes: ['S', 'M', 'L'],
        colors: ['Platinum'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Crash | Paris',
        description: 'Flex on the huzz with this watch.',
        price: 275000.00,
        images: ['https://img.chrono24.com/images/uhren/41093363-s210u37ay3u2c8bb55es30j1-ExtraLarge.jpg'],
        category: catMap['Cartier'],
        sizes: ['S', 'M', 'L'],
        colors: ['Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Ballon Bleu | Tourbillon',
        description: 'Flex on the huzz with this watch.',
        price: 120000.00,
        images: ['https://img.chrono24.com/images/uhren/44956061-f3nd828o0y3eieouo80laqqe-ExtraLarge.jpg'],
        category: catMap['Cartier'],
        sizes: ['S', 'M', 'L'],
        colors: ['Rose Gold'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Santos | Factory Set Diamond Bezel',
        description: 'Flex on the huzz with this watch.',
        price: 160000.00,
        images: ['https://img.chrono24.com/images/uhren/45266401-v7rv3cz27ptpl9hh97yaemkc-ExtraLarge.jpg'],
        category: catMap['Cartier'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Tank | Asymetrique | Skeleton',
        description: 'Flex on the huzz with this watch.',
        price: 120000.00,
        images: ['https://img.chrono24.com/images/uhren/44705034-r4wfv3bafuaebyfchy4n1pv2-ExtraLarge.jpg'],
        category: catMap['Cartier'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold', 'Platinum'],
        stock: 30,
        isFeatured: false,
      },

      //Omega
      {
        name: 'De Ville | Central Tourbillon ',
        description: 'Flex on the huzz with this watch.',
        price: 242000.00,
        images: ['https://img.chrono24.com/images/uhren/44661002-37ueny3f3rf6ttobcnxrit1d-ExtraLarge.jpg'],
        category: catMap['Omega'],
        sizes: ['S', 'M', 'L'],
        colors: ['Gold','White Gold','Platinum','Rose Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Speedmaster Professional | Rainbow Canopus',
        description: 'Flex on the huzz with this watch.',
        price: 169000.00,
        images: ['https://cdn2.chrono24.com/images/product/228214-vgj9pqc809vfq3td8f5xen8k-Large.jpg'],
        category: catMap['Omega'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold'],
        stock: 30,
        isFeatured: true,
      },

      {
        name: 'Seamaster | James Bond | 60th Anniversary',
        description: 'Flex on the huzz with this watch.',
        price: 150000.00,
        images: ['https://www.omegawatches.com/media/catalog/product/o/m/omega-seamaster-diver-300m-co-axial-master-chronometer-42-mm-21055422099001-watch-wrist-04041c.png'],
        category: catMap['Omega'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Speedmaster | Two Counters | Moonphase',
        description: 'Flex on the huzz with this watch.',
        price: 140000.00,
        images: ['https://img.chrono24.com/images/uhren/44653015-2bweo4qbj6fxd31uygs46lar-ExtraLarge.jpg'],
        category: catMap['Omega'],
        sizes: ['S', 'M', 'L'],
        colors: ['Platinum Red'],
        stock: 30,
        isFeatured: false,
      },

      {
        name: 'Seamaster | Aqua Terra | World Timer',
        description: 'Flex on the huzz with this watch.',
        price: 110000.00,
        images: ['https://img.chrono24.com/images/uhren/37454441-7m5jwib0kyxu7lrzr6bfqtt8-ExtraLarge.jpg'],
        category: catMap['Omega'],
        sizes: ['S', 'M', 'L'],
        colors: ['White Gold'],
        stock: 30,
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
