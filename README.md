# ElectroApp v2.0 - Smart Device Monitoring & Real-time Analytics

<div align="center">
  <img src="assets/images/app_icon.png" alt="ElectroApp Logo" width="120" height="120">
  <br>
  <strong>Smart Device Monitoring</strong>
</div>

A comprehensive Flutter application for monitoring and managing electrical devices with real-time data visualization, Firebase integration, and advanced electrical parameter tracking. Built with modern Material Design 3 principles and optimized for professional electrical monitoring.

## 🌟 Key Features

### 🔐 Enhanced Authentication System
- **Firebase Authentication**: Secure email/password authentication with session persistence
- **Advanced Splash Screen**: Beautiful animated loading screen with geometric animations, particle effects, and multi-layered UI elements
- **Smart Login**: Email/password authentication with remember me functionality and auto-login capabilities
- **Complete Signup**: User registration with name, email, phone, and password validation
- **Session Management**: Persistent authentication state with automatic session recovery - Electrical Device Monitoring & Real-time Analytics

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

### 📱 Modern UI/UX Experience
- **Material Design 3**: Clean, modern interface with professional deep blue theme (#1E3A8A)
- **Enhanced Animations**: 
  - Sophisticated splash screen with geometric backgrounds, rotating elements, and particle systems
  - Multi-layered circular progress indicators with pulsing effects
  - Smooth fade, scale, slide, and rotation animations throughout the app
  - Floating geometric elements and interactive visual feedback
- **Responsive Design**: Optimized for all screen sizes and orientations
- **Advanced Loading States**: 
  - Dynamic loading text transitions ("Initializing", "Loading", "Preparing", "Ready")
  - Wave progress dots with color transitions
  - Multi-ring progress indicators with synchronized animations
- **Error Handling**: Comprehensive error management with user-friendly messages
- **Professional Typography**: Google Fonts integration (Poppins, Roboto) with proper spacing and hierarchy
- **Real-time Status Indicators**: Visual connection and data status feedback with color-coded states

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

### 📦 Key Dependencies & Versions
- **provider ^6.1.2**: Advanced state management with reactive UI updates
- **fl_chart ^0.68.0**: Professional charts and real-time data visualization
- **firebase_core ^2.15.1**: Complete Firebase platform integration
- **firebase_auth ^4.7.2**: Secure Firebase authentication
- **firebase_database ^10.2.4**: Firebase Realtime Database with live streaming
- **google_fonts ^6.1.0**: Professional typography with Poppins and Roboto fonts
- **google_sign_in ^6.1.4**: Google authentication integration
- **shared_preferences ^2.2.3**: Local data persistence and user preferences
- **sqflite ^2.3.0**: Local SQLite database for offline capabilities
- **email_validator ^2.1.17**: Email validation and verification
- **flutter_spinkit ^5.2.1**: Advanced loading animations and indicators
- **url_launcher ^6.1.14**: External URL and deep link handling
- **http ^1.2.1**: HTTP client for API communications

### 🎨 Advanced UI Components & Animations
- **Enhanced Splash Screen**: 
  - Multi-layered circular progress indicators with synchronized animations
  - Geometric background patterns with floating shapes and particle systems
  - Advanced text animations with gradient effects and smooth transitions
  - Corner decorations with rotating electrical service icons
  - Pulsing rings and dynamic visual feedback elements
- **Custom Widgets**: DeviceTile, AddDeviceDialog, EditDeviceDialog with modern styling
- **Real-time Data Cards**: Live parameter value displays with color-coded indicators
- **Interactive Charts**: Parameter-specific visualizations with smooth animations
- **Professional Data Tables**: Sortable, responsive displays with advanced filtering
- **Responsive Layout**: Adaptive design that works seamlessly across all screen sizes
- **Consistent Theming**: Unified color scheme, typography, and visual hierarchy
- **Particle Animations**: Background particle systems for enhanced visual appeal

### 📊 Data Models & Services
- **Device Model**: Complete electrical parameter configuration (33 parameters)
- **User Model**: Authentication and profile management
- **DeviceData Model**: Historical and real-time data structures
- **RealtimeDataService**: Firebase data streaming and filtering
- **DeviceService**: Firebase CRUD operations
- **AuthService**: Firebase authentication management

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.4.3+ (current stable version)
- **Dart SDK**: 3.0+
- **Firebase Project**: Configured with Authentication and Realtime Database
- **Development Environment**: Android Studio, VS Code, or IntelliJ IDEA
- **Testing Device**: Android/iOS device or emulator
- **Platform Support**: Android, iOS, Web, Windows, macOS, Linux

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
├── widgets/                           # Reusable UI components
    ├── add_device_dialog.dart         # Device creation form
    ├── edit_device_dialog.dart        # Device modification form
    ├── device_tile.dart               # Device list item
    ├── particle_animation.dart        # Particle animation system for splash screen
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

### 🎨 Modern UI Design & User Experience
- **Enhanced Splash Screen**: 
  - Sophisticated animations with geometric backgrounds and particle effects
  - Multi-layered progress indicators with synchronized timing
  - Gradient text effects and smooth transitions
  - Professional branding with app logo and version information
- **Authentication Screens**: Clean login/signup with Firebase integration and form validation
- **Device Dashboard**: Professional device list with real-time status indicators
- **Device Configuration**: Comprehensive electrical parameter selection with intuitive UI
- **Real-time Monitoring**: Live charts and data tables with smooth updates
- **Data Visualization**: Color-coded parameter tracking with advanced chart interactions
- **Responsive Design**: Seamlessly adapts to phones, tablets, and desktop environments

### 🔧 Technical Features & Performance
- **Cross-Platform Support**: Runs on Android, iOS, Web, Windows, macOS, and Linux
- **Responsive Design**: Optimized for phones, tablets, and desktop with adaptive layouts
- **Professional Styling**: Material Design 3 with custom deep blue theme and consistent typography
- **Real-time Updates**: Live data streaming with visual indicators and connection monitoring
- **Advanced Animations**: Sophisticated splash screen with particle systems and geometric animations
- **Error Handling**: Comprehensive error management with user-friendly feedback
- **Loading States**: Multiple loading animation types with smooth transitions
- **Performance Optimization**: Efficient memory management and smooth 60fps animations
- **Offline Capabilities**: Local data caching with SQLite for offline viewing
- **Security**: Firebase security rules and secure authentication flow

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

## ⚡ Performance & Technical Specifications

### 🎯 Performance Metrics
- **Splash Screen Animation**: 30-second optimized loading sequence with smooth 60fps animations
- **Real-time Data Updates**: Sub-second Firebase data synchronization
- **Memory Usage**: Optimized for devices with 2GB+ RAM
- **Battery Efficiency**: Power-optimized animations and background processes
- **Cross-Platform**: Native performance on Android, iOS, Web, and Desktop platforms

### 🔧 Technical Requirements
- **Minimum Android**: API Level 21 (Android 5.0)
- **Minimum iOS**: iOS 11.0+
- **Web Browsers**: Chrome 68+, Firefox 68+, Safari 12+, Edge 79+
- **Desktop**: Windows 10+, macOS 10.14+, Ubuntu 18.04+
- **Network**: Internet connection required for real-time features
- **Storage**: 100MB+ available storage space

### 📊 App Architecture Highlights
- **State Management**: Provider pattern with reactive UI updates
- **Animation System**: Custom animation controllers with staggered timing
- **Data Flow**: Unidirectional data flow with clear separation of concerns
- **Error Recovery**: Automatic retry mechanisms and graceful error handling
- **Security**: Firebase security rules and encrypted data transmission

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

## 🚀 Future Enhancements & Roadmap

### 📅 Version 2.1 Planned Features
- [ ] **Advanced Analytics**: Historical data analysis with trend detection and predictive insights
- [ ] **Smart Notifications**: Real-time alerts for device anomalies with customizable thresholds
- [ ] **Data Export**: PDF/CSV export functionality with professional report generation
- [ ] **Device Grouping**: Organize devices by location, type, or custom categories
- [ ] **Enhanced Dark Mode**: Complete dark theme implementation with automatic switching
- [ ] **Multi-language Support**: Internationalization with support for multiple languages
- [ ] **Offline Mode**: Enhanced cached data for comprehensive offline viewing
- [ ] **Advanced Chart Types**: Pie charts, bar charts, and custom visualization options
- [ ] **User Role Management**: Admin/user permission system with role-based access control
- [ ] **External API Integration**: Support for third-party device APIs and protocols

### 🎯 Technical Improvements
- [ ] **WebSocket Integration**: Enhanced real-time performance with WebSocket connections
- [ ] **Advanced Caching**: Optimized data storage and retrieval with intelligent caching strategies
- [ ] **Comprehensive Testing**: Unit testing, widget testing, and integration testing implementation
- [ ] **CI/CD Pipeline**: Automated testing, building, and deployment workflows
- [ ] **Performance Monitoring**: Real-time app performance tracking with analytics
- [ ] **Code Quality**: Enhanced code documentation, linting rules, and best practices
- [ ] **Accessibility**: Full accessibility support with screen reader compatibility
- [ ] **Progressive Web App**: Enhanced PWA features with offline capabilities

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
- **Project**: ElectroApp v2.0 - Smart Device Monitoring
- **GitHub**: [@RensithUdara](https://github.com/RensithUdara)
- **Repository**: [ElectroApp](https://github.com/RensithUdara/electro_app)
- **Version**: 2.0.0 (January 2025)
- **Platform**: Flutter 3.4.3+ | Firebase Integration

For technical support, feature requests, or contributions, please visit our GitHub repository or contact the development team.

---

<div align="center">
  <strong>ElectroApp v2.0</strong> - Empowering electrical monitoring with real-time analytics and professional data visualization.
  <br>
  Built with ❤️ using Flutter, Firebase, and Material Design 3
  <br><br>
  <img src="https://img.shields.io/badge/Flutter-3.4.3+-blue?logo=flutter" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Firebase-Integrated-orange?logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Material%20Design-3-green?logo=material-design" alt="Material Design 3">
  <img src="https://img.shields.io/badge/License-MIT-red" alt="License">
</div>
