const mongoose = require('mongoose');

const TemplateSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    brand: {
        type: String,
        required: true,
        index: true
    },
    category: {
        type: String,
        required: true,
        enum: ['phone', 'tablet', 'laptop', 'watch'],
        default: 'phone'
    },
    dimensions: {
        width: Number,
        height: Number
    },
    cutouts: [{
        type: { type: String },
        x: Number,
        y: Number,
        width: Number,
        height: Number
    }],
    svgData: String,
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Template', TemplateSchema);
