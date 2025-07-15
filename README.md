# ElectroApp - Electrical Device Monitoring

A comprehensive Flutter application for monitoring and managing electrical devices with real-time data visualization.

## Features

### 🚀 Authentication System
- **Splash Screen**: Beautiful animated loading screen with app branding
- **Login**: Email/password authentication with remember me functionality
- **Signup**: Complete user registration with name, email, phone, and password

### 🏠 Home Dashboard
- **Device Management**: View all registered electrical devices
- **Add Device Dialog**: Easy device registration with:
  - Device name and ID
  - Meter ID
  - Test configuration options (Test 1, 2, 3)
- **Empty State**: Elegant "no devices" screen with call-to-action
- **Device Actions**: Edit and delete device functionality

### 📊 Device Details & Analytics
- **Real-time Monitoring**: Live device status and data
- **Data Visualization**: 
  - Interactive line charts for hourly/daily consumption
  - Pie charts for power distribution
  - Summary cards for key metrics
- **Data Table**: Detailed tabular view of recent device readings
- **Multi-tab Interface**: Overview, Charts, and Data Table views

### 📱 Modern UI/UX
- **Material Design 3**: Clean, modern interface
- **Responsive Design**: Works on all screen sizes
- **Loading States**: Smooth loading animations
- **Error Handling**: User-friendly error messages
- **Professional Color Scheme**: Deep blue theme with excellent contrast

## Technical Architecture

### 🏗️ MVC Pattern
- **Models**: User, Device, DeviceData with JSON serialization
- **Views**: Splash, Login, Signup, Home, Device Detail screens
- **Controllers**: Auth, Device, and DeviceData controllers using Provider state management

### 📦 Key Dependencies
- **provider**: State management
- **fl_chart**: Beautiful charts and data visualization  
- **shared_preferences**: Local data persistence
- **http**: API communication
- **email_validator**: Form validation
- **flutter_spinkit**: Loading animations

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

---

**ElectroApp** - Making electrical device monitoring simple and beautiful. 🔌⚡

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
