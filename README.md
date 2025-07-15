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

### 🎨 UI Components
- **Custom Widgets**: Reusable DeviceTile and AddDeviceDialog
- **Responsive Layout**: Adaptive design for different screen sizes
- **Consistent Theming**: Unified color scheme and typography

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK
- Android Studio or VS Code
- A device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd electro_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── controllers/              # State management controllers
│   ├── auth_controller.dart
│   ├── device_controller.dart
│   └── device_data_controller.dart
├── models/                   # Data models
│   ├── user.dart
│   ├── device.dart
│   └── device_data.dart
├── services/                 # API services
│   ├── auth_service.dart
│   ├── device_service.dart
│   └── device_data_service.dart
├── views/                    # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   └── device_detail_screen.dart
└── widgets/                  # Reusable components
    ├── add_device_dialog.dart
    └── device_tile.dart
```

## API Integration

The app is designed to work with a REST API backend. Currently using mock data for demonstration, but easily configurable for real API endpoints.

### API Endpoints (to be implemented)
- `POST /auth/login` - User authentication
- `POST /auth/signup` - User registration
- `GET /devices` - Fetch user devices
- `POST /devices` - Add new device
- `DELETE /devices/{id}` - Remove device
- `GET /devices/{id}/data` - Fetch device data

## Screenshots

The app features a modern, professional design with:
- Intuitive navigation flow
- Consistent visual hierarchy
- Beautiful data visualizations
- Responsive layouts

## Development Notes

### State Management
Using Provider pattern for clean separation of concerns and reactive UI updates.

### Local Storage
Device data is temporarily stored locally using SharedPreferences for demo purposes.

### Mock Data
The app generates realistic mock data for demonstration of charts and analytics features.

## Future Enhancements

- [ ] Real-time WebSocket connections for live data
- [ ] Push notifications for device alerts
- [ ] Advanced analytics and reporting
- [ ] Device grouping and categorization
- [ ] Export data functionality
- [ ] Dark mode support
- [ ] Multi-language support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
