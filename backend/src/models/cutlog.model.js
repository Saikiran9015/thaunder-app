const mongoose = require('mongoose');

const CutLogSchema = new mongoose.Schema({
    templateId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Template'
    },
    templateName: String,
    status: {
        type: String,
        enum: ['completed', 'cancelled', 'failed'],
        default: 'completed'
    },
    duration: Number, // in seconds
    speed: Number,
    pressure: Number,
    timestamp: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('CutLog', CutLogSchema);
