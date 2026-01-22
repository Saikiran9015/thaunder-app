# 🎓 ThunderCut - Academic Project Documentation

## 📚 Project Overview

**ThunderCut** is a professional-grade cutting plotter control software designed for mobile skin/vinyl cutting operations. This project demonstrates a complete full-stack application suitable for:

- **Academic Projects** (Final Year / Capstone)
- **Startup MVP** (Minimum Viable Product)
- **Commercial Deployment** (With additional features)

---

## 🏗️ System Architecture

### Three-Tier Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│              (Flutter Desktop Application)               │
│  • Material Design 3 UI                                  │
│  • BLoC State Management                                 │
│  • Responsive Design                                     │
└─────────────────────────────────────────────────────────┘
                          ↕ REST API / WebSocket
┌─────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                   │
│                  (Node.js Backend Server)                │
│  • Express.js REST API                                   │
│  • Socket.IO Real-time Communication                     │
│  • Vector Processing Engine                              │
│  • G-code Generation                                     │
└─────────────────────────────────────────────────────────┘
                          ↕ Serial Communication
┌─────────────────────────────────────────────────────────┐
│                   HARDWARE LAYER                         │
│              (Cutting Plotter Machine)                   │
│  • STM32/Arduino Microcontroller                         │
│  • Stepper Motor Drivers                                 │
│  • Cutting Blade Mechanism                               │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features Implemented

### 1. Frontend (Flutter Desktop)

#### ✅ User Interface
- **Sidebar**: Template selection with brand/model filters
- **Toolbar**: Design tools (upload, edit, font, template, mirror)
- **Canvas**: Real-time design preview with 360° rotation
- **Control Panel**: Speed/pressure controls, device status

#### ✅ State Management (BLoC Pattern)
- **DeviceBloc**: Device connection and control
- **DesignBloc**: Design upload and processing
- **TemplateBloc**: Template library management

#### ✅ Features
- File upload (SVG, DXF, PNG, JPG)
- Template library (1000+ mobile models)
- Real-time preview
- Material Design 3 theming

### 2. Backend (Node.js)

#### ✅ REST API Endpoints
```
Device Management:
  GET    /api/devices              - List devices
  POST   /api/devices/connect      - Connect device
  POST   /api/devices/disconnect   - Disconnect
  GET    /api/devices/status       - Get status
  POST   /api/devices/home         - Home device

Design Processing:
  POST   /api/design/upload        - Upload file
  POST   /api/design/process       - Generate G-code
  POST   /api/design/preview       - Get preview

Cutting Operations:
  POST   /api/cut/start            - Start cutting
  POST   /api/cut/pause            - Pause job
  POST   /api/cut/resume           - Resume job
  POST   /api/cut/cancel           - Cancel job

Templates:
  GET    /api/templates            - Get templates
  GET    /api/templates/:id        - Get template details
```

#### ✅ Core Services
- **DeviceManager**: Serial port communication
- **GCodeGenerator**: Vector to G-code conversion
- **VectorProcessor**: SVG/DXF parsing
- **Logger**: Winston logging system

#### ✅ Real-time Features
- WebSocket connection for live updates
- Progress tracking
- Device status monitoring

### 3. Hardware Integration

#### ✅ G-code Support
- Standard G-code commands (G0, G1, G28, M3, M5)
- Custom blade pressure control
- Multi-pass cutting support
- Emergency stop functionality

---

## 📊 Data Flow Diagram

```
User Action (Flutter UI)
        ↓
BLoC Event Dispatch
        ↓
Repository Layer
        ↓
API Service (HTTP/WebSocket)
        ↓
Express.js Backend
        ↓
Service Layer (Device/Design/Template)
        ↓
Hardware Communication (Serial Port)
        ↓
Cutting Plotter Device
```

---

## 🔧 Technology Stack

### Frontend
| Technology | Purpose | Version |
|------------|---------|---------|
| Flutter | Cross-platform UI framework | 3.x |
| Dart | Programming language | 3.x |
| flutter_bloc | State management | 8.1.3 |
| dio | HTTP client | 5.4.0 |
| socket_io_client | WebSocket client | 2.0.3 |
| google_fonts | Typography | 6.1.0 |

### Backend
| Technology | Purpose | Version |
|------------|---------|---------|
| Node.js | Runtime environment | 18+ |
| Express.js | Web framework | 4.18.2 |
| Socket.IO | Real-time communication | 4.6.1 |
| serialport | Serial communication | 12.0.0 |
| winston | Logging | 3.11.0 |
| multer | File upload | 1.4.5 |

---

## 📁 Project Structure

```
cutting-plotter-app/
├── flutter-app/                    # Flutter Desktop App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   └── theme/
│   │   │       └── app_theme.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── device_model.dart
│   │   │   │   └── template_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── device_repository.dart
│   │   │   │   ├── design_repository.dart
│   │   │   │   └── template_repository.dart
│   │   │   └── services/
│   │   │       └── api_service.dart
│   │   ├── business_logic/
│   │   │   ├── device_bloc/
│   │   │   ├── design_bloc/
│   │   │   └── template_bloc/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── main_screen.dart
│   │       └── widgets/
│   │           ├── sidebar.dart
│   │           ├── toolbar.dart
│   │           ├── design_canvas.dart
│   │           └── control_panel.dart
│   └── pubspec.yaml
│
├── backend/                        # Node.js Backend
│   ├── server.js
│   ├── src/
│   │   ├── api/
│   │   │   ├── device.routes.js
│   │   │   ├── design.routes.js
│   │   │   ├── cut.routes.js
│   │   │   └── template.routes.js
│   │   ├── services/
│   │   │   ├── device-manager.js
│   │   │   ├── gcode-generator.js
│   │   │   └── vector-processor.js
│   │   └── utils/
│   │       └── logger.js
│   ├── package.json
│   └── .env.example
│
└── docs/
    ├── README.md
    └── PROJECT_DOCUMENTATION.md
```

---

## 🚀 Setup Instructions

### Prerequisites
```bash
# Check Flutter
flutter --version

# Check Node.js
node --version
npm --version
```

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

### Flutter Setup
```bash
cd flutter-app
flutter pub get
flutter run -d windows
```

---

## 🎓 Academic Project Deliverables

### 1. Documentation
- [x] System Architecture Diagram
- [x] Data Flow Diagram
- [x] API Documentation
- [x] Technology Stack Analysis
- [x] Component Breakdown

### 2. Code Deliverables
- [x] Complete Source Code
- [x] Well-commented code
- [x] Modular architecture
- [x] Clean code principles

### 3. Demonstration
- [x] Working prototype
- [x] UI/UX implementation
- [x] API integration
- [x] Real-time features

---

## 📈 Future Enhancements

### Phase 2 Features
- [ ] User authentication (JWT)
- [ ] Cloud storage integration
- [ ] Design history/versioning
- [ ] Multi-language support
- [ ] Advanced vector editing

### Phase 3 Features
- [ ] Mobile app (Flutter)
- [ ] Cloud sync
- [ ] Analytics dashboard
- [ ] Batch processing
- [ ] AI-powered optimization

---

## 🎯 Use Cases

### 1. Small Business
- Mobile skin printing shops
- Custom vinyl cutting services
- Personalized gift shops

### 2. Educational
- Engineering capstone projects
- Computer science final year projects
- Mechatronics demonstrations

### 3. Commercial
- Production-ready with scaling
- Multi-device support
- Enterprise features

---

## 📊 Performance Metrics

| Metric | Target | Achieved |
|--------|--------|----------|
| API Response Time | < 100ms | ✅ |
| File Upload Size | 10MB | ✅ |
| Concurrent Connections | 10+ | ✅ |
| UI Responsiveness | 60fps | ✅ |

---

## 🤝 Contributing

This is an academic/startup project. Contributions welcome!

### How to Contribute
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

---

## 📄 License

MIT License - Free for academic and commercial use

---

## 👥 Team Credits

**Project Type**: Academic/Startup MVP  
**Development Time**: 2-3 months  
**Team Size**: 1-4 developers

---

## 📞 Support

For questions and support:
- Create GitHub issue
- Email: support@thundercut.dev
- Documentation: /docs

---

## 🎉 Conclusion

ThunderCut demonstrates a complete full-stack application with:
- Modern UI/UX (Flutter)
- Robust backend (Node.js)
- Real-time communication (WebSocket)
- Hardware integration (Serial)
- Professional architecture (BLoC, MVC)

**Perfect for**: Final year projects, startup MVPs, portfolio projects

---

**Last Updated**: January 2026  
**Version**: 1.0.0
