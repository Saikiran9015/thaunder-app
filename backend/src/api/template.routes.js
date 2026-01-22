const express = require('express');
const router = express.Router();

const ALL_BRANDS = [
    'Apple', 'Google', 'MOTOROLA', 'vivo', 'OPPO', 'Infinix', 'Nothing', 'POCO', 'realme', 'Samsung',
    'REDMI', 'LAVA', 'Mi', 'itel', 'OnePlus', 'KARBONN', 'ASUS', 'MTR', 'Kechaoda', 'Nokia',
    'Tecno', 'Snexian', 'BlackZone', 'IAIR', 'IQOO', 'Micromax', 'Jmax', 'ringme', 'I Kall', 'oneme',
    'FONEME', 'Lenovo', 'Snexan', 'Panasonic', 'Peace', 'SIAVANTAGE', 'LG', 'ANGAGE', 'Lvix', 'GFive',
    'SONY', 'HOTLINE', 'HTC', 'GIONEE', 'Sia', 'Fuziqra', 'leysky', 'XOLO', 'TOUCH 18', 'Honor',
    'Pious', 'hmd', 'ROCK TOUCH', 'Jio', 'Amozkart', 'SAREGAMA', 'Pear', 'amaq', 'Intex', 'Gamma',
    'GOLY', 'Ai+', 'Vox', 'Texllo', 'YU', 'UiSmart', 'TRYTO', 'G\'Five', 'kasjiry', 'Snectian',
    'VDTECH', 'Easyfone', 'CMF by Nothing', 'BlackBerry', 'PHILIPS', 'FUZIQRA AL PRODUCTS', 'iVoomi',
    'MIXX', 'LYF', 'GOODVIBES', 'Mobilezone', 'Huawei', 'V GADGETS', 'ONEXIAN', 'MTOUCH', 'Alcatel',
    'Rastic', 'Coolpad', 'CAUL', 'Acer', 'LIVX', 'Jivi', 'Good One', 'GREENBERRI', 'Voto', 'Meizu',
    'T3REE', 'Swipe', 'Shreyansh', 'SLEEKON', 'SKYSHOP', 'Maplin', 'Geotel', 'DIZO', 'BlackBear',
    'mobiistar', 'hopi5', 'TMB', 'Habib', 'villaon', 'Smartron', 'SAM', 'Muphone', 'MADAAN ELECTRONICS',
    'iSmart', 'Yxtel', 'XTOUCH', 'Syamx', 'Salora', 'STK', 'Nextbit', 'MAFE', 'Kechadda', 'Ierenk',
    'sellocityhub', 'jbharat', 'iball', 'Zen', 'Virat FANBOX', 'Videocon', 'Tempta', 'Sansui', 'Ramtri',
    'Oister', 'Nuvo', 'M A ZONE', 'LeEco', 'Inoyo', 'Giyotel', 'Energizer', 'Elephone'
];

const MOCK_TEMPLATES = [
    {
        id: 'iphone-15-pro',
        name: 'iPhone 15 Pro',
        brand: 'Apple',
        category: 'phone',
        dimensions: { width: 71.6, height: 146.6 },
        cutouts: [
            { type: 'camera', x: 15, y: 10, width: 35, height: 40 },
            { type: 'speaker', x: 30, y: 5, width: 15, height: 3 }
        ]
    },
    {
        id: 'iphone-15-plus',
        name: 'iPhone 15 Plus',
        brand: 'Apple',
        category: 'phone',
        dimensions: { width: 77.8, height: 160.9 },
        cutouts: [
            { type: 'camera', x: 18, y: 12, width: 32, height: 32 }
        ]
    },
    {
        id: 'pixel-8-pro',
        name: 'Google Pixel 8 Pro',
        brand: 'Google',
        category: 'phone',
        dimensions: { width: 76.5, height: 162.6 },
        cutouts: [
            { type: 'camera-bar', x: 0, y: 15, width: 76.5, height: 25 }
        ]
    },
    {
        id: 'samsung-s24-ultra',
        name: 'Samsung S24 Ultra',
        brand: 'Samsung',
        category: 'phone',
        dimensions: { width: 79, height: 162.3 },
        cutouts: [
            { type: 'camera', x: 20, y: 12, width: 40, height: 45 }
        ]
    },
    {
        id: 'galaxy-z-fold-5',
        name: 'Galaxy Z Fold 5',
        brand: 'Samsung',
        category: 'phone',
        dimensions: { width: 129.9, height: 154.9 },
        cutouts: [
            { type: 'camera', x: 100, y: 10, width: 25, height: 50 }
        ]
    },
    {
        id: 'moto-edge-40',
        name: 'Motorola Edge 40',
        brand: 'MOTOROLA',
        category: 'phone',
        dimensions: { width: 72, height: 158.4 },
        cutouts: [
            { type: 'camera', x: 15, y: 15, width: 30, height: 35 }
        ]
    },
    {
        id: 'nothing-phone-2',
        name: 'Nothing Phone (2)',
        brand: 'Nothing',
        category: 'phone',
        dimensions: { width: 76.4, height: 162.1 },
        cutouts: [
            { type: 'camera', x: 15, y: 15, width: 25, height: 45 }
        ]
    },
    {
        id: 'oneplus-12',
        name: 'OnePlus 12',
        brand: 'OnePlus',
        category: 'phone',
        dimensions: { width: 75.8, height: 164.3 },
        cutouts: [
            { type: 'camera', x: 10, y: 10, width: 45, height: 45 }
        ]
    }
];

/**
 * GET /api/templates
 * Get all available templates
 */
router.get('/', async (req, res) => {
    try {
        const { category, brand } = req.query;

        let filtered = MOCK_TEMPLATES;
        if (category) {
            filtered = filtered.filter(t => t.category.toLowerCase() === category.toLowerCase());
        }
        if (brand) {
            filtered = filtered.filter(t => t.brand.toLowerCase() === brand.toLowerCase());
        }

        res.json({
            success: true,
            templates: filtered,
            total: filtered.length
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/templates/:id
 * Get specific template details
 */
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const template = MOCK_TEMPLATES.find(t => t.id === id);

        if (!template) {
            return res.status(404).json({
                success: false,
                error: 'Template not found'
            });
        }

        res.json({
            success: true,
            template
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/templates/categories
 * Get all template categories
 */
router.get('/meta/categories', (req, res) => {
    res.json({
        success: true,
        categories: [
            { id: 'phone', name: 'Smartphones', count: MOCK_TEMPLATES.filter(t => t.category === 'phone').length },
            { id: 'tablet', name: 'Tablets', count: MOCK_TEMPLATES.filter(t => t.category === 'tablet').length },
            { id: 'laptop', name: 'Laptops', count: MOCK_TEMPLATES.filter(t => t.category === 'laptop').length },
            { id: 'watch', name: 'Smartwatches', count: MOCK_TEMPLATES.filter(t => t.category === 'watch').length }
        ]
    });
});

/**
 * GET /api/templates/brands
 * Get all brands
 */
router.get('/meta/brands', (req, res) => {
    res.json({
        success: true,
        brands: ALL_BRANDS
    });
});

module.exports = router;
