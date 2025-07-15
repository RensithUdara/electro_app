# ElectroApp - Electrical Device Monitoring & Real-time Analytics

A comprehensive Flutter application for monitoring and managing electrical devices with real-time data visualization, Firebase integration, and advanced electrical parameter tracking.

## 🌟 Key Features

### � Authentication System
- **Firebase Authentication**: Secure email/password authentication
- **Splash Screen**: Beautiful animated loading screen with app branding  
- **Login**: Email/password authentication with remember me functionality
- **Signup**: Complete user registration with name, email, phone, and password
- **Auto-login**: Persistent authentication state management

### 🏠 Advanced Device Management
- **Real-time Device List**: View all registered electrical devices with live status
- **Comprehensive Device Configuration**: Support for 33 electrical measurement parameters:
  - Power Factor & Average Values (5 parameters)
  - Current Measurements (3 parameters)
  - Power Factor per Phase (3 parameters)
  - Total Power Measurements (3 parameters)
  - Energy Measurements (3 parameters)
  - Voltage Measurements (6 parameters)
  - Per-Phase Power Measurements (9 parameters)
- **Device Actions**: Create, edit, and delete device functionality
- **Firebase Integration**: All device data stored in Firebase Realtime Database

### 📊 Real-time Data Visualization & Analytics
- **Live Data Streaming**: Real-time data from Firebase Realtime Database
- **Interactive Charts**: 
  - Individual charts for each selected electrical parameter
  - Real-time line charts with data visualization using FL Chart
  - Color-coded parameter tracking (voltage, current, power, etc.)
- **Data Tables**: 
  - Live data tables with real-time parameter values
  - Parameter descriptions, units, and connection status
  - Data summary statistics (average, min/max values)
- **Multi-tab Interface**: Overview, Charts, and Data Table views
- **Connection Status**: Real-time Firebase connection monitoring

### 🛠️ Device Configuration & Management
- **Add Device Dialog**: Intuitive device registration with electrical parameter selection
- **Edit Device Dialog**: Modify existing devices and their parameter configurations
- **Parameter Filtering**: Only display data for user-selected measurements
- **Device Detail Screen**: Comprehensive device monitoring with edit and refresh options

### 📱 Modern UI/UX
- **Material Design 3**: Clean, modern interface with professional styling
- **Responsive Design**: Optimized for all screen sizes
- **Loading States**: Smooth loading animations and progress indicators
- **Error Handling**: Comprehensive error management with user-friendly messages
- **Professional Color Scheme**: Deep blue theme (#1E3A8A) with excellent contrast
- **Real-time Status Indicators**: Visual connection and data status feedback

## 🏗️ Technical Architecture

### 🔥 Firebase Integration
- **Firebase Core 2.15.1**: Complete Firebase platform integration
- **Firebase Authentication 4.7.2**: Secure user authentication
- **Firebase Realtime Database 10.2.4**: Live data streaming and storage
- **Database URL**: `https://panel-monitor-691c6-default-rtdb.firebaseio.com/`

### 🎯 State Management (Provider Pattern)
- **AuthController**: User authentication and session management
- **DeviceController**: Device CRUD operations and state management
- **DeviceDataController**: Historical device data management
- **RealtimeDataController**: Live data streaming and connection management

### 📦 Key Dependencies
- **provider ^6.0.5**: Advanced state management
- **fl_chart ^0.68.0**: Professional charts and data visualization
- **firebase_core ^2.15.1**: Firebase platform integration
- **firebase_auth ^4.7.2**: Firebase authentication
- **firebase_database ^10.2.4**: Firebase Realtime Database
- **shared_preferences**: Local data persistence

### 🎨 Advanced UI Components
- **Custom Widgets**: DeviceTile, AddDeviceDialog, EditDeviceDialog
- **Real-time Data Cards**: Live parameter value displays
- **Interactive Charts**: Parameter-specific visualizations
- **Professional Data Tables**: Sortable, responsive data displays
- **Responsive Layout**: Adaptive design for all screen sizes
- **Consistent Theming**: Unified color scheme and typography

### 📊 Data Models & Services
- **Device Model**: Complete electrical parameter configuration (33 parameters)
- **User Model**: Authentication and profile management
- **DeviceData Model**: Historical and real-time data structures
- **RealtimeDataService**: Firebase data streaming and filtering
- **DeviceService**: Firebase CRUD operations
- **AuthService**: Firebase authentication management

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.0+ (latest stable version recommended)
- **Dart SDK**: 3.0+
- **Firebase Project**: Configured with Authentication and Realtime Database
- **Development Environment**: Android Studio, VS Code, or IntelliJ IDEA
- **Testing Device**: Android/iOS device or emulator

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/RensithUdara/electro_app.git
   cd electro_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Enable Realtime Database
   - Add your platform-specific configuration files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Run the application**
   ```bash
   flutter run
   ```

### 🏗️ Project Structure
```
lib/
├── main.dart                           # App entry point with Firebase initialization
├── controllers/                        # State management controllers
│   ├── auth_controller.dart           # Authentication state management
│   ├── device_controller.dart         # Device CRUD operations
│   ├── device_data_controller.dart    # Historical data management
│   └── realtime_data_controller.dart  # Live data streaming
├── models/                            # Data models with JSON serialization
│   ├── user.dart                      # User authentication model
│   ├── device.dart                    # Device configuration model (33 parameters)
│   ├── device.g.dart                 # Generated JSON serialization
│   ├── device_data.dart               # Device data model
│   └── device_data.g.dart            # Generated JSON serialization
├── services/                          # Backend integration services
│   ├── auth_service.dart              # Firebase authentication
│   ├── device_service.dart            # Firebase device operations
│   ├── device_data_service.dart       # Historical data operations
│   └── realtime_data_service.dart     # Live data streaming
├── views/                             # UI screens
│   ├── splash_screen.dart             # App launch screen
│   ├── login_screen.dart              # User authentication
│   ├── signup_screen.dart             # User registration
│   ├── home_screen.dart               # Device management dashboard
│   ├── device_detail_screen.dart      # Real-time device monitoring
│   └── profile_screen.dart            # User profile management
└── widgets/                           # Reusable UI components
    ├── add_device_dialog.dart         # Device creation form
    ├── edit_device_dialog.dart        # Device modification form
    ├── device_tile.dart               # Device list item
    └── google_icon.dart               # Custom Google sign-in icon
```

## 🔥 Firebase Integration Details

### 🗄️ Database Structure
```
electro_app_db/
├── users/
│   └── {userId}/
│       └── devices/
│           └── {deviceId}: true
├── devices/
│   └── {deviceId}/
│       ├── name: "Device Name"
│       ├── deviceId: "ESP32_001"
│       ├── meterId: "MTR_001"
│       ├── averagePF: true/false
│       ├── avgI: true/false
│       └── ... (33 electrical parameters)
└── realtime_data/
    └── {deviceId}/
        ├── timestamp: 1234567890
        ├── voltage: 220.5
        ├── current: 5.2
        └── ... (electrical measurements)
```

### 🔌 Real-time Data Parameters
The application supports monitoring of 33 electrical measurement parameters:

**Power Factor & Average Values:**
- Average_PF, Avg_I, Avg_V_LL, Avg_V_LN, Frequency

**Current Measurements:**
- I1, I2, I3 (Phase currents)

**Power Factor per Phase:**
- PF1, PF2, PF3 (Individual phase power factors)

**Total Power Measurements:**
- Total_kVA, Total_kVAR, Total_kW

**Energy Measurements:**
- Total_net_kVAh, Total_net_kVArh, Total_net_kWh

**Voltage Measurements:**
- V12, V1N, V23, V2N, V31, V3N (Line and phase voltages)

**Per-Phase Power Measurements:**
- kVAR_L1/L2/L3, kVA_L1/L2/L3, kW_L1/L2/L3

## 🎯 Application Workflow

### 1. **User Authentication**
- User signs up or logs in using Firebase Authentication
- Authentication state is managed globally using Provider
- Remember me functionality for persistent sessions

### 2. **Device Management**
- Users can add new electrical devices with custom parameter selection
- Each device can monitor specific electrical measurements
- Device configurations are stored in Firebase Realtime Database
- Edit functionality allows modification of device parameters

### 3. **Real-time Monitoring**
- Live data streaming from Firebase Realtime Database
- Data filtering based on user-selected parameters
- Real-time charts and data tables update automatically
- Connection status monitoring with visual indicators

### 4. **Data Visualization**
- Individual charts for each selected electrical parameter
- Color-coded parameter tracking for easy identification
- Real-time data tables with parameter descriptions and units
- Summary statistics including averages and min/max values

## 📱 Application Screenshots & Features

### 🎨 Modern UI Design
- **Splash Screen**: Animated loading with app branding
- **Authentication**: Clean login/signup with Firebase integration
- **Device Dashboard**: Professional device list with real-time status
- **Device Configuration**: Comprehensive electrical parameter selection
- **Real-time Monitoring**: Live charts and data tables
- **Data Visualization**: Color-coded parameter tracking

### 🔧 Technical Features
- **Responsive Design**: Optimized for phones, tablets, and desktop
- **Professional Styling**: Material Design 3 with custom theming
- **Real-time Updates**: Live data streaming with visual indicators
- **Error Handling**: Comprehensive error management with user feedback
- **Loading States**: Smooth animations and progress indicators

## 🛠️ Development & Architecture

### 📋 Development Guidelines
- **Clean Architecture**: Separation of concerns with MVC pattern
- **State Management**: Provider pattern for reactive UI updates
- **Code Organization**: Modular structure with clear separation
- **Error Handling**: Comprehensive error management at all levels
- **Performance**: Optimized for smooth real-time data handling

### 🔄 State Management Flow
```
User Action → Controller → Service → Firebase → Controller → UI Update
```

### 📊 Data Flow Architecture
1. **Authentication**: Firebase Auth → AuthController → UI
2. **Device Management**: UI → DeviceController → DeviceService → Firebase
3. **Real-time Data**: Firebase → RealtimeDataService → RealtimeDataController → UI
4. **Data Visualization**: RealtimeDataController → Chart/Table Widgets

## 🌟 Advanced Features

### ⚡ Real-time Capabilities
- **Live Data Streaming**: Continuous data updates from Firebase
- **Connection Monitoring**: Real-time connection status tracking
- **Data Filtering**: Dynamic filtering based on device configuration
- **Auto-reconnection**: Automatic reconnection on network issues

### 📈 Analytics & Visualization
- **Parameter-specific Charts**: Individual charts for each measurement
- **Color-coded Tracking**: Visual parameter identification
- **Summary Statistics**: Real-time averages, min/max calculations
- **Data Export**: (Future enhancement) Export data for analysis

### 🔐 Security & Performance
- **Firebase Security Rules**: Secure data access control
- **Authentication Flow**: Secure user session management
- **Data Validation**: Input validation at all levels
- **Performance Optimization**: Efficient real-time data handling

## 🚀 Future Enhancements

### 📅 Roadmap
- [ ] **Advanced Analytics**: Historical data analysis and trends
- [ ] **Push Notifications**: Real-time alerts for device anomalies
- [ ] **Data Export**: PDF/CSV export functionality
- [ ] **Device Grouping**: Organize devices by location/type
- [ ] **Dark Mode**: Complete dark theme implementation
- [ ] **Multi-language**: Internationalization support
- [ ] **Offline Mode**: Cached data for offline viewing
- [ ] **Advanced Charts**: More chart types and customization
- [ ] **User Roles**: Admin/user permission system
- [ ] **API Integration**: External device API connections

### 🎯 Technical Improvements
- [ ] **WebSocket Integration**: Enhanced real-time performance
- [ ] **Advanced Caching**: Optimized data storage and retrieval
- [ ] **Unit Testing**: Comprehensive test coverage
- [ ] **Integration Testing**: End-to-end testing implementation
- [ ] **CI/CD Pipeline**: Automated testing and deployment
- [ ] **Performance Monitoring**: Real-time app performance tracking

## 🤝 Contributing

We welcome contributions to improve ElectroApp! Here's how you can help:

### 📝 Contribution Guidelines
1. **Fork the Repository**: Create your own fork of the project
2. **Create Feature Branch**: `git checkout -b feature/AmazingFeature`
3. **Follow Code Standards**: Maintain consistent code style
4. **Add Tests**: Include tests for new functionality
5. **Update Documentation**: Update README and code comments
6. **Commit Changes**: `git commit -m 'Add AmazingFeature'`
7. **Push to Branch**: `git push origin feature/AmazingFeature`
8. **Open Pull Request**: Create a detailed pull request

### 🐛 Bug Reports
When reporting bugs, please include:
- Device information and Flutter version
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots or error logs
- Firebase configuration details (if relevant)

### 💡 Feature Requests
For feature requests, please provide:
- Clear description of the proposed feature
- Use case and business value
- Technical implementation suggestions
- UI/UX mockups (if applicable)

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### 📞 Contact & Support

- **Developer**: Rensith Udara
- **Email**: [Your Email]
- **GitHub**: [@RensithUdara](https://github.com/RensithUdara)
- **Project Repository**: [ElectroApp](https://github.com/RensithUdara/electro_app)

---

**ElectroApp** - Empowering electrical monitoring with real-time analytics and professional data visualization. Built with ❤️ using Flutter and Firebase.
