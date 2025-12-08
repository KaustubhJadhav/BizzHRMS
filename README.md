# HSRM Flutter App

A Flutter application for HR Management System with MVVM architecture, converted from the web-based HRMS at https://creativecrows.co.in/arena/dashboard.

## Features

- ✅ MVVM Architecture
- ✅ Modular Code Structure
- ✅ Sign In Page
- ✅ Dashboard with user info, personal details, projects, tasks
- ✅ Attendance Management
- ✅ Leave Management
- ✅ Projects Management
- ✅ Announcements
- ✅ Complaints
- ✅ Work Reports
- ✅ Shared Components (Sidebar, Header, Breadcrumb)
- ✅ Smooth Animations & Transitions

## Project Structure

```
lib/
├── config/
│   ├── routes/          # App routing configuration
│   └── theme/          # App theme configuration
├── core/
│   ├── constants/      # App constants
│   └── utils/          # Utility functions
├── data/
│   ├── data_sources/   # Remote & Local data sources
│   ├── models/         # Data models
│   └── repositories/   # Repository layer
└── presentation/
    ├── auth/           # Authentication module
    ├── dashboard/      # Dashboard module
    ├── attendance/     # Attendance module
    ├── leaves/         # Leaves module
    ├── projects/       # Projects module
    ├── announcements/  # Announcements module
    ├── complaints/     # Complaints module
    ├── work_report/    # Work Report module
    └── shared/         # Shared widgets & components
```

## MVVM Architecture

Each feature module follows the MVVM pattern:

```
feature/
├── view/
│   └── feature_page.dart      # UI Layer
├── view_model/
│   └── feature_view_model.dart # Business Logic Layer
└── models/
    └── feature_model.dart      # Data Models (if needed)
```

### Components:

- **View**: Flutter widgets that display UI and handle user interactions
- **ViewModel**: Contains business logic, state management using ChangeNotifier/Provider
- **Model**: Data structures and entities

## Setup Instructions

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Adding Backend APIs

When you receive the API endpoints, integrate them in the following places:

### 1. Update Constants
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'YOUR_API_BASE_URL';
static const String loginEndpoint = 'login/auth';
// Add more endpoints as needed
```

### 2. Update Remote Data Source
Edit `lib/data/data_sources/remote_data_source.dart`:
```dart
Future<AuthResponse> login(String username, String password) async {
  final response = await _dio.post(
    AppConstants.loginEndpoint,
    data: {'username': username, 'password': password},
  );
  return AuthResponse.fromJson(response.data);
}
```

### 3. Update ViewModels
Edit the respective ViewModels to use the repository/data source:
```dart
final authRepository = AuthRepository();
final result = await authRepository.login(username, password);
```

## Dependencies

- `provider`: State management
- `go_router`: Navigation
- `dio`: HTTP client for API calls
- `shared_preferences`: Local storage
- `font_awesome_flutter`: Icons
- `intl`: Internationalization

## Pages Implemented

1. **Sign In Page** (`/sign-in`)
   - Username/password login
   - Quick login buttons (Admin/Employee)
   - Forgot password link

2. **Dashboard** (`/dashboard`)
   - User info card
   - Personal details
   - Projects list
   - Tasks list
   - Attendance stats
   - Announcements & Awards

3. **Attendance** (`/attendance`)
   - Attendance records table
   - Clock in/out functionality

4. **Leaves** (`/leaves`)
   - Leave statistics
   - Add leave form
   - Leave records table

5. **Projects** (`/projects`)
   - Projects list table

6. **Announcements** (`/announcements`)
   - Announcements list table

7. **Complaints** (`/complaints`)
   - Complaints list table

8. **Work Report** (`/work-report`)
   - Work reports list table

## Future Enhancements

- [ ] Add complete data table implementations with pagination, sorting, filtering
- [ ] Add form validation and error handling
- [ ] Add image loading and caching
- [ ] Add calendar widgets for date selection
- [ ] Add file upload functionality
- [ ] Add push notifications
- [ ] Add offline support with local caching
- [ ] Add dark mode support
- [ ] Add multilingual support

## Notes

- The app uses mock data currently - replace with actual API calls when backend is ready
- All ViewModels are set up to easily integrate with API calls
- Shared components (Sidebar, Header) are reusable across all pages
- The code is modular and follows Flutter best practices

## Contributing

When adding new features:
1. Follow the MVVM architecture pattern
2. Create separate modules for each feature
3. Use shared widgets for common UI components
4. Update routing in `app_router.dart`
5. Add appropriate error handling

## License

This project is proprietary and confidential.
