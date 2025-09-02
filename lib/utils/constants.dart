enum UserRole {
  admin,
  coordinator,
  driver,
  teacher,
  student,
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}

enum RouteType {
  pickup,
  drop,
}

class AppConstants {
  static const String appName = 'College Bus Tracker';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String busesCollection = 'buses';
  static const String routesCollection = 'routes';
  static const String locationsCollection = 'locations';
  static const String collegesCollection = 'colleges';
  
  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Default colleges
  static const List<Map<String, String>> defaultColleges = [
    {'name': 'ABC Engineering College', 'domain': 'abc.edu'},
    {'name': 'XYZ University', 'domain': 'xyz.edu'},
    {'name': 'Tech Institute', 'domain': 'tech.edu'},
  ];
}

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
}