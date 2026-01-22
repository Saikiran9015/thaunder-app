const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const GCodeGenerator = require('../services/gcode-generator');
const VectorProcessor = require('../services/vector-processor');

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, process.env.UPLOAD_DIR || './uploads');
    },
    filename: (req, file, cb) => {
        const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage,
    limits: {
        fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10485760 // 10MB
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = ['.svg', '.dxf', '.png', '.jpg', '.jpeg'];
        const ext = path.extname(file.originalname).toLowerCase();

        if (allowedTypes.includes(ext)) {
            cb(null, true);
        } else {
            cb(new Error('Invalid file type. Allowed: SVG, DXF, PNG, JPG'));
        }
    }
});

/**
 * POST /api/design/upload
 * Upload a design file
 */
router.post('/upload', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                error: 'No file uploaded'
            });
        }

        const designId = uuidv4();
        const fileInfo = {
            id: designId,
            originalName: req.file.originalname,
            filename: req.file.filename,
            path: req.file.path,
            size: req.file.size,
            mimeType: req.file.mimetype,
            uploadedAt: new Date().toISOString()
        };

        res.json({
            success: true,
            design: fileInfo
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/design/process
 * Process design file and generate G-code
 */
router.post('/process', async (req, res) => {
    try {
        const {
            filePath,
            scaleX = 1,
            scaleY = 1,
            offsetX = 0,
            offsetY = 0,
            mirror = false,
            speed = 50,
            pressure = 300
        } = req.body;

        if (!filePath) {
            return res.status(400).json({
                success: false,
                error: 'File path is required'
            });
        }

        // Process vector file
        const processor = new VectorProcessor();
        const pathData = await processor.processFile(filePath);

        // Generate G-code
        const generator = new GCodeGenerator({ speed, pressure });
        const gcode = generator.pathToGCode(pathData, {
            scaleX,
            scaleY,
            offsetX,
            offsetY,
            mirror
        });

        // Optimize G-code
        const optimizedGCode = generator.optimize(gcode);

        res.json({
            success: true,
            gcode: optimizedGCode,
            stats: {
                totalLines: optimizedGCode.length,
                estimatedTime: (optimizedGCode.length * 0.1).toFixed(2) + ' seconds'
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/design/preview
 * Generate preview data for design
 */
router.post('/preview', async (req, res) => {
    try {
        const { filePath } = req.body;

        if (!filePath) {
            return res.status(400).json({
                success: false,
                error: 'File path is required'
            });
        }

        const processor = new VectorProcessor();
        const pathData = await processor.processFile(filePath);
        const bounds = processor.getBounds(pathData);

        res.json({
            success: true,
            preview: {
                pathData,
                bounds,
                pathCount: pathData.length
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/design/:id
 * Get design details
 */
router.get('/:id', (req, res) => {
    // This would typically fetch from database
    res.json({
        success: true,
        message: 'Design retrieval not yet implemented'
    });
});

/**
 * DELETE /api/design/:id
 * Delete a design
 */
router.delete('/:id', (req, res) => {
    // This would typically delete from database and filesystem
    res.json({
        success: true,
        message: 'Design deletion not yet implemented'
    });
});

module.exports = router;
