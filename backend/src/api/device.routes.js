const express = require('express');
const router = express.Router();

/**
 * GET /api/devices
 * List all available serial devices
 */
router.get('/', async (req, res) => {
    try {
        const devices = await req.deviceManager.scanDevices();
        res.json({
            success: true,
            devices
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/devices/connect
 * Connect to a specific device
 */
router.post('/connect', async (req, res) => {
    try {
        const { port } = req.body;

        if (!port) {
            return res.status(400).json({
                success: false,
                error: 'Port path is required'
            });
        }

        const result = await req.deviceManager.connect(port);
        res.json({
            success: true,
            ...result
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/devices/disconnect
 * Disconnect from current device
 */
router.post('/disconnect', async (req, res) => {
    try {
        await req.deviceManager.disconnect();
        res.json({
            success: true,
            message: 'Device disconnected'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/devices/status
 * Get current device status
 */
router.get('/status', (req, res) => {
    try {
        const status = req.deviceManager.getStatus();
        res.json({
            success: true,
            status
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/devices/home
 * Home the device
 */
router.post('/home', async (req, res) => {
    try {
        await req.deviceManager.homeDevice();
        res.json({
            success: true,
            message: 'Device homed successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/devices/emergency-stop
 * Emergency stop
 */
router.post('/emergency-stop', async (req, res) => {
    try {
        await req.deviceManager.emergencyStop();
        res.json({
            success: true,
            message: 'Emergency stop executed'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * POST /api/devices/command
 * Send custom G-code command
 */
router.post('/command', async (req, res) => {
    try {
        const { command } = req.body;

        if (!command) {
            return res.status(400).json({
                success: false,
                error: 'Command is required'
            });
        }

        await req.deviceManager.sendCommand(command);
        res.json({
            success: true,
            message: 'Command sent'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

module.exports = router;
