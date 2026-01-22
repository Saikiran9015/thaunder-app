# 🚀 ThunderCut - Quick Start Guide

## ⚡ 5-Minute Setup

### Step 1: Install Dependencies

#### Backend
```bash
cd cutting-plotter-app/backend
npm install
```

#### Flutter App
```bash
cd cutting-plotter-app/flutter-app
flutter pub get
```

---

### Step 2: Configure Environment

Create `.env` file in `backend/`:
```env
PORT=3000
NODE_ENV=development
SERIAL_BAUD_RATE=115200
```

---

### Step 3: Start Backend Server

```bash
cd backend
npm run dev
```

You should see:
```
🚀 ThunderCut Backend Server running on port 3000
📡 WebSocket server ready
```

---

### Step 4: Run Flutter App

```bash
cd flutter-app
flutter run -d windows
```

---

## 🎯 First Use

### 1. Connect Device
- Click "Scan Devices" in the sidebar
- Select your cutting plotter
- Click "Connect"

### 2. Select Template
- Choose brand (e.g., Apple)
- Select model (e.g., iPhone 15 Pro)
- Template loads in canvas

### 3. Upload Design
- Click "Upload Images" in toolbar
- Select SVG/DXF file
- Design appears on template

### 4. Start Cutting
- Adjust speed (1-100%)
- Set pressure (100-500g)
- Click "Start" button

---

## 🔧 Troubleshooting

### Backend won't start
```bash
# Check Node.js version
node --version  # Should be 18+

# Clear node_modules
rm -rf node_modules
npm install
```

### Flutter build errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Device not detected
- Check USB connection
- Install CH340 drivers (if needed)
- Restart backend server

---

## 📚 Next Steps

1. Read full documentation: `docs/PROJECT_DOCUMENTATION.md`
2. Explore API endpoints: `docs/API.md`
3. Customize templates
4. Add your own features

---

## 🎓 For Academic Projects

### Presentation Points
1. **Architecture**: Show 3-tier design
2. **Tech Stack**: Flutter + Node.js + Hardware
3. **Features**: Real-time, WebSocket, G-code
4. **Demo**: Live cutting demonstration

### Report Sections
1. Introduction & Problem Statement
2. System Architecture
3. Technology Stack
4. Implementation Details
5. Results & Screenshots
6. Future Enhancements
7. Conclusion

---

## 💡 Tips

- Start backend before Flutter app
- Use test pattern for first cut
- Check device status before cutting
- Save designs frequently

---

**Happy Cutting! 🎨✂️**
