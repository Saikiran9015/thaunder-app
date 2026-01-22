const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const http = require('http');
const path = require('path');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
require('dotenv').config();

const deviceRoutes = require('./src/api/device.routes');
const designRoutes = require('./src/api/design.routes');
const cutRoutes = require('./src/api/cut.routes');
const templateRoutes = require('./src/api/template.routes');
const downloadRoutes = require('./src/api/download.routes');

const DeviceManager = require('./src/services/device-manager');
const logger = require('./src/utils/logger');

// Initialize Express
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI;
if (MONGODB_URI) {
  mongoose.connect(MONGODB_URI)
    .then(() => logger.info('🍃 Connected to MongoDB Successfully'))
    .catch((err) => {
      logger.error('❌ MongoDB Connection Error:', err.message);
      // Suppress crash on Vercel if DB fails
      if (process.env.VERCEL) {
        logger.warn('Skipping crash because we are on Vercel.');
      }
    });
} else {
  logger.warn('⚠️ MONGODB_URI not found in environment variables. Running without MongoDB.');
}

// Initialize Device Manager
const deviceManager = new DeviceManager(io);

// Make deviceManager available to routes
app.use((req, res, next) => {
  req.deviceManager = deviceManager;
  req.io = io;
  next();
});

// API Routes
app.use('/api/devices', deviceRoutes);
app.use('/api/design', designRoutes);
app.use('/api/cut', cutRoutes);
app.use('/api/templates', templateRoutes);
app.use('/api/download', downloadRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
  });

  socket.on('device:command', async (data) => {
    try {
      await deviceManager.sendCommand(data.command);
    } catch (error) {
      socket.emit('device:error', { message: error.message });
    }
  });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, async () => {
  logger.info(`🚀 ThunderCut Backend Server running on port ${PORT}`);
  logger.info(`📡 WebSocket server ready`);

  // Ensure uploads directory exists
  const fs = require('fs');
  const uploadDir = process.env.UPLOAD_DIR || './uploads';
  if (!fs.existsSync(uploadDir)) {
    try {
      fs.mkdirSync(uploadDir, { recursive: true });
      logger.info(`📁 Created uploads directory: ${uploadDir}`);
    } catch (e) {
      logger.warn(`Could not create uploads dir (likely read-only cloud): ${e.message}`);
    }
  }

  // Hardware check: Only scan devices if NOT on Vercel
  if (!process.env.VERCEL) {
    logger.info('💻 Local environment detected: Initializing hardware drivers...');
    deviceManager.scanDevices();
  } else {
    logger.info('☁️ Cloud environment (Vercel) detected: Hardware scanning disabled.');
  }
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    logger.info('HTTP server closed');
    deviceManager.disconnectAll();
    process.exit(0);
  });
});

module.exports = app;
