const express = require('express');
const router = express.Router();
const GCodeGenerator = require('../services/gcode-generator');

/**
 * POST /api/cut/start
 * Start a cutting job
 */
router.post('/start', async (req, res) => {
    try {
        const { gcode, speed, pressure } = req.body;

        if (!gcode || !Array.isArray(gcode)) {
            return res.status(400).json({
                success: false,
                error: 'Valid G-code array is required'
            });
        }

        // Set parameters if provided
        if (speed || pressure) {
            const generator = new GCodeGenerator({ speed, pressure });
            generator.setParameters(speed, pressure);
        }

        // Send G-code program to device
        req.deviceManager.sendProgram(gcode).catch(error => {
            req.io.emit('cut:error', { message: error.message });
        });

        res.json({
            success: true,
            message: 'Cutting job started',
            lines: gcode.length
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/cut/pause
 * Pause current cutting job
 */
router.post('/pause', async (req, res) => {
    try {
        await req.deviceManager.sendCommand('M0'); // Pause command
        res.json({
            success: true,
            message: 'Job paused'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/cut/resume
 * Resume paused cutting job
 */
router.post('/resume', async (req, res) => {
    try {
        await req.deviceManager.sendCommand('M108'); // Resume command
        res.json({
            success: true,
            message: 'Job resumed'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/cut/cancel
 * Cancel current cutting job
 */
router.post('/cancel', async (req, res) => {
    try {
        await req.deviceManager.emergencyStop();
        res.json({
            success: true,
            message: 'Job cancelled'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/cut/test
 * Run a test cutting pattern
 */
router.post('/test', async (req, res) => {
    try {
        const generator = new GCodeGenerator();
        const testGCode = generator.generateTestPattern();

        req.deviceManager.sendProgram(testGCode).catch(error => {
            req.io.emit('cut:error', { message: error.message });
        });

        res.json({
            success: true,
            message: 'Test pattern started',
            gcode: testGCode
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router;
