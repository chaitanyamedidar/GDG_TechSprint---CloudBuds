# SafeLabs - Multi-Lab IoT Monitoring & Safety System

![SafeLabs](https://img.shields.io/badge/SafeLabs-v1.0-blue)
![ESP32](https://img.shields.io/badge/ESP32-Firmware-green)
![Firebase](https://img.shields.io/badge/Firebase-Realtime-orange)
![Flutter](https://img.shields.io/badge/Flutter-Frontend-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Overview

SafeLabs is a comprehensive IoT-based laboratory monitoring and safety system designed for educational institutions and research facilities. The system provides real-time environmental monitoring, automated climate control, occupancy detection, and security event logging across multiple laboratory spaces.

### Key Capabilities

- **Multi-Lab Support**: Monitor up to 3 laboratories simultaneously with independent sensor nodes
- **Real-Time Monitoring**: Live temperature, humidity, air quality (gas), and motion detection
- **Smart Automation**: Occupancy-based AC/cooling system control with configurable timers
- **Security Logging**: Automatic event logging for motion detection and environmental anomalies
- **Alert System**: Dynamic alert generation based on configurable safety thresholds
- **Multiple Interfaces**: 
  - Flutter web/desktop application for administrative control
  - Streamlit dashboard for real-time monitoring and analytics
  - Node.js backend for automation logic
- **Cloud Integration**: Firebase Realtime Database for data persistence and synchronization
- **Simulation Support**: Full Wokwi simulation environment for testing before hardware deployment

### Technology Stack

**Hardware/Firmware:**
- ESP32 microcontroller
- DHT22 temperature/humidity sensor
- MQ-135 gas sensor
- PIR motion sensor
- PlatformIO build system

**Backend:**
- Node.js with Express
- Firebase Admin SDK
- Real-time automation engine

**Frontend:**
- Flutter (Web, Desktop, Mobile)
- Firebase Authentication
- Real-time data streaming
- Responsive material design

**Dashboard:**
- Python Streamlit
- Plotly for data visualization
- Google Gemini AI integration (optional)

**Cloud Services:**
- Firebase Realtime Database
- Firebase Authentication
- Firebase Cloud Functions

---

## 📁Repository Structure

```
/
├── firmware/                    # Shared ESP32 code
│   ├── src/main.cpp            # Main firmware (supports all labs)
│   ├── include/config.h        # Symlink to active lab config
│   ├── platformio.ini          # PlatformIO configuration
│   ├── lib/                    # Dependencies
│   └── .pio/                   # Build output (auto-generated)
│
├── configs/                     # Lab-specific configurations
│   ├── lab1_config.h           # sensor_node_01
│   ├── lab2_config.h           # sensor_node_02
│   └── lab3_config.h           # sensor_node_03
│
├── simulations/                 # Wokwi circuits
│   ├── lab1/
│   │   ├── diagram.json
│   │   └── wokwi.toml
│   ├── lab2/
│   │   ├── diagram.json
│   │   └── wokwi.toml
│   └── lab3/
│       ├── diagram.json
│       └── wokwi.toml
│
├── backend/
│   ├── server.js               # Node.js automation engine
│   ├── package.json
│   └── .env.example
│
├── frontend/                    # Flutter web/desktop application
│   ├── lib/                    # Dart source code
│   │   ├── main.dart           # Application entry point
│   │   ├── core/               # Core services, models, widgets
│   │   ├── desktop/            # Desktop UI screens
│   │   └── mobile/             # Mobile UI screens
│   ├── pubspec.yaml            # Flutter dependencies
│   ├── firebase.json           # Firebase configuration
│   └── android/                # Android build configuration
│
├── dashboard/
│   ├── dashboard.py            # Streamlit monitoring dashboard
│   ├── requirements.txt        # Python dependencies
│  Prerequisites

Before setting up SafeLabs, ensure you have the following installed:

- **Python 3.8+** (for Streamlit dashboard)
- **Node.js 16+** and npm (for backend server)
- **Flutter SDK 3.0+** (for frontend application)
- **PlatformIO** (for ESP32 firmware development)
- **VS Code** with Wokwi extension (for simulation)
- **Git** (for version control)

## Initial Setup

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd SafeLabs
```

### Step 2: Firebase Project Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - Realtime Database
   - Authentication (Email/Password)
   - Cloud Functions (optional)

3. Configure Firebase Realtime Database Rules:
   ```json
   {
     "rules": {
       "devices": {
         ".read": "auth != null",
         ".write": true
       },
       "labs": {
         ".read": "auth != null",
         ".write": "auth != null"
       },
       "events": {
         ".read": "auth != null",
         ".write": true
       }
     }
   }
   ```

### Step 3: Obtain Firebase Credentials

#### A. Web API Key and Database URL

1. Go to Firebase Console → Project Settings → General
2. Note down:
   - Web API Key
   - Project ID
   - Realtime Database URL (e.g., `https://your-project-default-rtdb.firebaseio.com/`)

###Running the System

### Option 1: Complete System (All Components)

#### 1. Build and Run Firmware Simulations

Build firmware for all labs:

**Windows:**
```powershell
.\build.bat all
```

**Linux/Mac:**
```bash
chmod +x build.sh
./build.sh all
```

Start Wokwi simulations (can run all 3 simultaneously):

1. Open VS Code
2. Open `simulations/lab1/diagram.json`
3. Press F1 → "Wokwi: Start Simulator"
4. Repeat for lab2 and lab3 in separate VS Code windows

Verify data is being sent:
- Check Serial Monitor for "Data sent successfully!" messages every 5 seconds
- Verify data appears in Firebase Console → Realtime Database

#### 2. Start Backend Server

```bash
cd backend
npm start
```

The backend handles:
- AC automation logic (motion-based control)
- Energy optimization
- Event processing

#### 3. Start Streamlit Dashboard

```bash
cd dashboard
streamlit run dashboard.py
```

Access at: `http://localhost:8501`

Features:
- Multi-lab selector (switch between sensor_node_01, 02, 03)
- Real-time sensor readings with auto-refresh
- Historical data visualization
- AC control interface
- Online/offline status detection
- AI-powered insights (if Gemini API key configured)

#### 4. Start Flutter Frontend

**For Web:**
```bash
cd frontend
flutter run -d chrome
```

**For Desktop (Windows):**
```bash
cd frontend
flutter run -d windows
```

**For Production Build:**
```bash
cd frontend
flutter build web
```

Access at: `http://localhost:<port>` (port will be shown in terminal)

Features:
- Campus overview dashboard
- All laboratories page with live data
- Individual lab detail pages
- Alert notification system
- Settings and user management
- System analytics

### Option 2: Frontend Only (Without Firmware)

If you only want to run the frontend application:

1. Ensure Firebase Realtime Database has sample data
2. Start the Flutter frontend:
   ```bash
   cd frontend
   flutter run -d chrome
   ```
3. The app will work with any existing Firebase data

### Option 3: Dashboard Only

For quick monitoring:

```bash
cd dashboard
streamlit run dashboard.py
```

Select the lab to monitor from the sidebar dropdown.```

3. Edit `backend/.env`:
   ```env
   PORT=3000
   FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com
   ```

4. Install dependencies:
   ```bash
   cd backend
   npm install
   ```

### Step 6: Configure Dashboard

1. Copy service account key:
   ```powershell
   Copy-Item firebase-service-account.json dashboard\
   ```

2. Install dependencies:
   ```bash
   cd dashboard
   pip install -r requirements.txt
   ```

3. (Optional) For AI insights, create `.env` file:
   ```env
   GEMINI_API_KEY=your-gemini-api-key
   ```

### Step 7: Configure Flutter Frontend

1. Install Flutter dependencies:
   ```bash
   cd frontend
   flutter pub get
   ```

2. Configure Firebase for Flutter:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

3. Follow the prompts to select your Firebase project

4. Update database URL in the generated `firebase_options.dart` if needed
   Copy-Item firebase-service-account.json backend\
   Copy-Item firebase-service-account.json dashboard\
   ```

### 3. Create Backend Environment File

```powershell
Copy-Item backend\.env.example backend\.env
# Edit .env with your credentials
```

**Setup Complete!** These files are excluded from Git via `.gitignore` for security.

---

## Quick Start

### 1️ Build Firmware for a Lab

**WSystem Features

### Firmware Features

- **Single Codebase Architecture**: One firmware supports all laboratory configurations
- **Configuration-Based Deployment**: Lab-specific settings via config files
- **Automated Build System**: Cross-platform build scripts (Windows/Linux/Mac)
- **Sensor Integration**: DHT22, MQ-135, PIR motion sensor support
- **Firebase Real-Time Sync**: Live data streaming to cloud database
- **Event Logging**: Automatic security and anomaly event recording
- **AC Automation**: Motion-based climate control with configurable timers
- **Dual Timestamp Support**: Handles both Unix epoch and boot time formats

### Frontend Application Features

- **Multi-Lab Overview**: Monitor all laboratories from a single dashboard
- **Real-Time Data Streaming**: Live sensor readings with Firebase integration
- **Dynamic Alert System**: Automatic alert generation based on safety thresholds
  - Critical alerts: Temperature >30°C or <10°C, Humidity >70% or <20%, Gas >800 ppm
  - Warning alerts: Temperature >26°C or <18°C, Humidity >60% or <30%, Gas >500 ppm
- **Interactive Lab Cards**: Click to view detailed lab information
- **Visual Status Indicators**: Color-coded borders and badges for lab conditions
- **Alert Notifications**: Click-to-view alert details with severity indicators
- **Responsive Design**: Works on web, desktop, and mobile platforms
- **Authentication**: Secure login with Firebase Authentication
- **Settings Management**: User management and system configuration

### Dashboard Features

- **Real-Time Monitoring**: Auto-refresh every 5 seconds
- **Multi-Lab Selection**: Switch between different laboratory nodes
- **Status Indicators**: Online/offline detection with visual cues
- **Historical Trends**: Temperature, humidity, gas level charts
- **Occupancy Tracking**: Motion detection timeline and statistics
- **AC Control Interface**: Manual override for climate control
- **AI Insights**: Optional Google Gemini integration for recommendations
- **Offline Handling**: Graceful degradation when simulators are stopped

### Backend Features

- **Automation Engine**: Occupancy-based AC control logic
- **Event Processing**: Real-time event handling and logging
- **Firebase Admin SDK**: Secure server-side database operations
- **REST API**: Endpoints for external integrations
- **Energy Optimization**: Automatic climate control based on occupancy pattern
```bash
chmod +x build.sh

# Build Lab 1
./build.sh lab1

# Build all labs
./build.sh all
```

### 2️ Run Wokwi Simulation
 and Verification

### Multi-Lab Simulation Testing

1. Build firmware for all labs:
   ```bash
   .\build.bat all
   ```

2. Open 3 separate VS Code windows

3. In each window, open the respective simulation:
   - Window 1: `simulations/lab1/diagram.json`
   - Window 2: `simulations/lab2/diagram.json`
   - Window 3: `simulations/lab3/diagram.json`

4. Start each simulator (F1 → "Wokwi: Start Simulator")

5. Verify all labs are sending data independently to Firebase


### Status Indicators

**Dashboard:**
- ONLINE: Sensor active, real-time values displayed
- OFFLINE: Simulator stopped, empty metrics (-- °C, -- %, -- ppm)
- WARNING: Values outside normal range but not critical
- CRITICAL: Values exceed safety thresholds

### Troubleshooting

**No data in Firebase:**
1. Verify Firebase credentials in config files
2. Check Firebase Realtime Database rules allow write access
3. Confirm WiFi connection in Serial Monitor
4. Rebuild firmware with correct configuration



### 4️ Start Backend (Optional)

```powershell
cd backend
npm install
npm start
```

---


### Firmware Deployment to Physical Hardware

1. Connect ESP32 board via USB
2. Update config files with production WiFi credentials
3. Build firmware: `.\build.bat lab1`
4. Upload to ESP32:
   ```bash
   cd firmware
   pio run --target upload
   ```
5. Monitor serial output to verify operation

### Frontend Deployment

**Web Hosting (Firebase Hosting):**
```bash
cd frontend
flutter build web
firebase deploy --only hosting
```

**Desktop Application:**
```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

### Backend Deployment

**Heroku:**
```bash
cd backend
heroku create safelabs-backend
git push heroku main
```

**Google Cloud Run:**
```bash
gcloud run deploy safelabs-backend --source .
```

### Dashboard Deployment

**Streamlit Cloud:**
1. Push code to GitHub repository
2. Connect repository to Streamlit Cloud
3. Configure secrets in Streamlit dashboard settings
4. Deploy

**Docker:**
```bash
cd dashboard
docker build -t safelabs-dashboard .
docker run -p 8501:8501 safelabs-dashboard
```

## System Architecture

### Data Flow

```
ESP32 Sensors → Firebase Realtime Database → Flutter Frontend
                          ↓
                    Backend Server
                          ↓
                  Automation Logic
                          ↓
                    AC Control
```

### Database Structure

```
/devices
  /sensor_node_01
    /latest          # Current readings
    /history         # Historical data
  /sensor_node_02
    /latest
    /history
  /sensor_node_03
    /latest
    /history

/labs
  /sensor_node_01
    /ac              # AC status (true/false)
  /sensor_node_02
    /ac
  /sensor_node_03
    /ac

/events
  /sensor_node_01    # Security events
  /sensor_node_02
  /sensor_node_03
```

## Development Workflow

### Adding a New Laboratory

1. Create configuration file:
   ```bash
   cp configs/config.h.example configs/lab4_config.h
   ```

2. Update device ID:
   ```c
   #define DEVICE_ID "sensor_node_04"
   ```

3. Create Wokwi simulation:
   ```bash
   mkdir simulations/lab4
   # Copy diagram.json and wokwi.toml from existing lab
   # Update references to point to firmware binary
   ```

4. Build firmware:
   ```bash
   .\build.bat lab4
   ```

5. Update frontend to include new lab in services

### Modifying Safety Thresholds

Update thresholds in `frontend/lib/core/services/alert_service.dart`:

```dart
// Critical conditions
if (temp > 30 || temp < 10) {
  criticalIssues.add('Critical Temperature: ${temp}°C');
}
```

Update corresponding logic in `dashboard/dashboard.py` to maintain consistency.

## License

MIT License - See [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## Support and Documentation

- **Issues**: Report bugs and request features via GitHub Issues
- **Documentation**: Additional documentation available in `/docs` directory
- **Firebase Setup**: See Firebase documentation for database and authentication setup
- **Flutter Development**: See Flutter documentation for frontend development

## Project Credits

**SafeLabs** - Multi-Lab IoT Monitoring and Safety System

Developed using:
- ESP32 microcontroller platform
- Firebase Realtime Database and Authentication
- Flutter framework for cross-platform UI
- Node.js for backend automation
- Python Streamlit for analytics dashboard
- Wokwi for IoT simulation

## Version History

- **v1.0** - Initial release
  - Multi-lab firmware support
  - Flutter web/desktop frontend
  - Streamlit monitoring dashboard
  - Node.js automation backend
  - Firebase cloud integration
  - Dynamic alert system
  - Real-time data streaming1/firmware.bin`
5. **Simulate**: All 3 simulations point to same firmware binary

### Multi-Lab Deployment

```
Lab 1 (sensor_node_01) ──┐
Lab 2 (sensor_node_02) ──┼─→ Firebase ─→ Dashboard
Lab 3 (sensor_node_03) ──┘              ↓
                                      Backend
```

Each lab writes to its own Firebase path:
- `/devices/sensor_node_01/latest`
- `/devices/sensor_node_02/latest`
- `/devices/sensor_node_03/latest`

---


## Development Workflow

### Adding a New Lab (Lab 4)

1. Create config: `configs/lab4_config.h`
2. Set `DEVICE_ID "sensor_node_04"`
3. Create simulation: `simulations/lab4/diagram.json`
4. Build: `.\build.bat lab4`

No changes to firmware needed!

---

## Testing

**Run all 3 labs simultaneously:**

1. Build firmware: `.\build.bat all`
2. Open 3 VS Code windows
3. In each window:
   - Open `simulations/lab1/diagram.json` (or lab2, lab3)
   - Press F1 → "Wokwi: Start Simulator"
4. All 3 will push to Firebase independently!

**Dashboard Status Indicators:**
- 🟢 **ONLINE**: Sensor active, real-time values displayed
- ⚫ **OFFLINE**: Simulator stopped, empty metrics shown (-- °C, -- %, -- ppm)
- Offline detection triggers after 30 seconds of no updates
- Auto-refresh continues even when offline (every 5s)

**Serial Monitor Verification:**
- Look for: `✓ Data sent successfully!` every 5 seconds
- If offline: Check WiFi connection, Firebase rules, or rebuild firmware

---

## 🔒 Security & Credentials

**Protected Files (excluded from Git):**
- `firebase-service-account.json` - Firebase Admin SDK credentials
- `configs/lab1_config.h`, `lab2_config.h`, `lab3_config.h` - WiFi passwords & API keys
- `backend/.env` - Environment variables
- `firmware/include/config.h` - Generated during build

**Template Files (safe to commit):**
- `configs/config.h.example` - Lab config template
- `firebase-service-account.json.example` - Firebase credential template
- `backend/.env.example` - Backend environment template


## 🔥Firebase Structure

```
devices/
  ├── sensor_node_01/
  │   ├── latest/
  │   └── history/
  ├── sensor_node_02/
  │   ├── latest/
  │   └── history/
  └── sensor_node_03/
      ├── latest/
      └── history/

labs/
  ├── sensor_node_01/ac
  ├── sensor_node_02/ac
  └── sensor_node_03/ac

events/
  ├── sensor_node_01/
  ├── sensor_node_02/
  └── sensor_node_03/
```

---

## 📄 License

MIT License - See [LICENSE](LICENSE)

---

## 👥 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## Credits

**Cloudbuds** - Autonomous Lab Safety System  
Built with ESP32, Firebase, Node.js, Streamlit & Wokwi
