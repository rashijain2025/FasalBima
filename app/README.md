# Farmer App

A comprehensive Flutter application designed for farmers to manage their crops, track crop stages, report losses, and file insurance claims.

## Features

### 🌱 Crop Management
- **Add Crops**: Upload crop images, select crop type, set sowing date, area, and geo-location
- **Crop Tracking**: Monitor crop stages from sowing → vegetative → flowering → fruiting → harvest
- **Crop Details**: View detailed information about each crop including location and progress

### 📊 Dashboard
- **Overview**: Quick stats showing total crops and area
- **Recent Crops**: Display recently added crops with current stages
- **Weather Alerts**: Real-time weather warnings and alerts
- **Quick Actions**: Easy access to add crops and report losses

### 🚨 Loss Reporting & Claims
- **Disaster Reporting**: Instantly report crop damage with photos
- **Claim Filing**: File insurance claims for crop losses
- **Status Tracking**: Monitor claim status (Under Review → Verified → Approved → Paid)
- **Multiple Disaster Types**: Support for floods, droughts, pest attacks, diseases, etc.

### 📈 Insights
- **Weather Data**: Current weather conditions and forecasts
- **Weather Alerts**: Critical weather warnings for farming
- **Farming Tips**: Expert advice and best practices for different crops
- **Crop-specific Guidance**: Tailored recommendations based on crop type

### 👤 User Management
- **Authentication**: Secure login and signup system
- **Profile Management**: Update personal information and farm details
- **Settings**: Customize app preferences and notifications

## Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: Go Router
- **Local Storage**: SharedPreferences, SQLite
- **Image Handling**: Image Picker, Cached Network Image
- **Location Services**: Geolocator, Geocoding
- **HTTP Requests**: HTTP package
- **UI Components**: Material Design with custom theming

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Android Studio or VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd farmer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Demo Credentials
- **Email**: farmer@example.com
- **Password**: password

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── crop_model.dart
│   ├── claim_model.dart
│   ├── user_model.dart
│   └── weather_model.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── crop_provider.dart
│   ├── claim_provider.dart
│   └── weather_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   ├── home/
│   ├── crops/
│   ├── claims/
│   ├── insights/
│   └── profile/
└── utils/                    # Utilities
    └── app_colors.dart
```

## Key Features Implementation

### Crop Stage Tracking
The app automatically tracks crop stages and allows manual updates:
- **Sowing**: Initial planting stage
- **Vegetative**: Growth and development
- **Flowering**: Blooming phase
- **Fruiting**: Fruit/seed development
- **Harvest**: Ready for collection

### Disaster Reporting System
- **Instant Reporting**: Quick photo upload and damage assessment
- **Multiple Disaster Types**: Floods, droughts, pest attacks, diseases, etc.
- **Loss Estimation**: Calculate percentage and monetary loss
- **Image Documentation**: Multiple photos for evidence

### Claim Management
- **Automated Workflow**: Under Review → Verified → Approved → Paid
- **Status Tracking**: Real-time updates on claim progress
- **Documentation**: Complete audit trail of all claims

### Weather Integration
- **Real-time Data**: Current weather conditions
- **Alerts System**: Critical weather warnings
- **Farming Tips**: Expert advice based on weather patterns

## Permissions Required

- **Camera**: For taking crop photos
- **Location**: For geo-tagging crops and farms
- **Storage**: For saving images locally
- **Internet**: For API calls and data synchronization

## Future Enhancements

- [ ] Offline mode support
- [ ] Push notifications
- [ ] Advanced analytics and reporting
- [ ] Integration with government schemes
- [ ] Multi-language support
- [ ] Voice notes for observations
- [ ] Integration with IoT sensors
- [ ] Blockchain-based claim verification

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Built with ❤️ for farmers worldwide**
