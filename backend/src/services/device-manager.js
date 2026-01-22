const { SerialPort } = require('serialport');
const { ReadlineParser } = require('@serialport/parser-readline');
const EventEmitter = require('events');
const logger = require('../utils/logger');

class DeviceManager extends EventEmitter {
    constructor(io) {
        super();
        this.io = io;
        this.activePort = null;
        this.parser = null;
        this.deviceInfo = {
            connected: false,
            port: null,
            status: 'idle',
            position: { x: 0, y: 0 },
            isHomed: false
        };
    }

    /**
     * Scan for available serial devices
     */
    async scanDevices() {
        try {
            const ports = await SerialPort.list();
            const devices = ports.map(port => ({
                path: port.path,
                manufacturer: port.manufacturer,
                serialNumber: port.serialNumber,
                vendorId: port.vendorId,
                productId: port.productId
            }));

            logger.info(`Found ${devices.length} serial devices`);
            this.io.emit('devices:list', devices);
            return devices;
        } catch (error) {
            logger.error('Error scanning devices:', error);
            throw error;
        }
    }

    /**
     * Connect to a specific device
     */
    async connect(portPath) {
        try {
            if (this.activePort && this.activePort.isOpen) {
                await this.disconnect();
            }

            this.activePort = new SerialPort({
                path: portPath,
                baudRate: parseInt(process.env.SERIAL_BAUD_RATE) || 115200,
                dataBits: 8,
                stopBits: 1,
                parity: 'none'
            });

            this.parser = this.activePort.pipe(new ReadlineParser({ delimiter: '\n' }));

            // Set up event listeners
            this.activePort.on('open', () => {
                logger.info(`Connected to device on ${portPath}`);
                this.deviceInfo.connected = true;
                this.deviceInfo.port = portPath;
                this.io.emit('device:connected', this.deviceInfo);
            });

            this.activePort.on('error', (err) => {
                logger.error('Serial port error:', err);
                this.io.emit('device:error', { message: err.message });
            });

            this.activePort.on('close', () => {
                logger.info('Device disconnected');
                this.deviceInfo.connected = false;
                this.io.emit('device:disconnected');
            });

            // Listen for device responses
            this.parser.on('data', (data) => {
                this.handleDeviceResponse(data);
            });

            return { success: true, port: portPath };
        } catch (error) {
            logger.error('Connection error:', error);
            throw error;
        }
    }

    /**
     * Disconnect from current device
     */
    async disconnect() {
        if (this.activePort && this.activePort.isOpen) {
            return new Promise((resolve, reject) => {
                this.activePort.close((err) => {
                    if (err) {
                        logger.error('Error closing port:', err);
                        reject(err);
                    } else {
                        this.deviceInfo.connected = false;
                        this.deviceInfo.port = null;
                        resolve();
                    }
                });
            });
        }
    }

    /**
     * Send G-code command to device
     */
    async sendCommand(command) {
        if (!this.activePort || !this.activePort.isOpen) {
            throw new Error('No device connected');
        }

        return new Promise((resolve, reject) => {
            this.activePort.write(command + '\n', (err) => {
                if (err) {
                    logger.error('Error sending command:', err);
                    reject(err);
                } else {
                    logger.debug(`Sent command: ${command}`);
                    resolve();
                }
            });
        });
    }

    /**
     * Send multiple commands (G-code program)
     */
    async sendProgram(commands) {
        if (!Array.isArray(commands)) {
            throw new Error('Commands must be an array');
        }

        this.deviceInfo.status = 'cutting';
        this.io.emit('device:status', this.deviceInfo);

        for (let i = 0; i < commands.length; i++) {
            await this.sendCommand(commands[i]);

            // Emit progress
            const progress = ((i + 1) / commands.length) * 100;
            this.io.emit('cut:progress', {
                progress: progress.toFixed(2),
                currentLine: i + 1,
                totalLines: commands.length
            });

            // Small delay between commands
            await this.delay(10);
        }

        this.deviceInfo.status = 'idle';
        this.io.emit('device:status', this.deviceInfo);
        this.io.emit('cut:complete');
    }

    /**
     * Home the device (move to origin)
     */
    async homeDevice() {
        await this.sendCommand('G28'); // G-code home command
        this.deviceInfo.isHomed = true;
        this.deviceInfo.position = { x: 0, y: 0 };
        this.io.emit('device:homed', this.deviceInfo);
    }

    /**
     * Emergency stop
     */
    async emergencyStop() {
        await this.sendCommand('M112'); // Emergency stop G-code
        this.deviceInfo.status = 'stopped';
        this.io.emit('device:emergency-stop');
    }

    /**
     * Handle responses from device
     */
    handleDeviceResponse(data) {
        const response = data.trim();
        logger.debug(`Device response: ${response}`);

        // Parse position updates
        if (response.startsWith('X:')) {
            const match = response.match(/X:([\d.]+)\s+Y:([\d.]+)/);
            if (match) {
                this.deviceInfo.position = {
                    x: parseFloat(match[1]),
                    y: parseFloat(match[2])
                };
                this.io.emit('device:position', this.deviceInfo.position);
            }
        }

        // Handle OK responses
        if (response === 'ok') {
            this.emit('command:complete');
        }

        // Handle errors
        if (response.startsWith('Error:')) {
            this.io.emit('device:error', { message: response });
        }
    }

    /**
     * Get current device status
     */
    getStatus() {
        return this.deviceInfo;
    }

    /**
     * Disconnect all devices
     */
    async disconnectAll() {
        await this.disconnect();
    }

    /**
     * Utility delay function
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

module.exports = DeviceManager;
