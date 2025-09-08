import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/location_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bus_provider.dart';
import 'providers/route_provider.dart';
import 'providers/location_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/dashboard/coordinator_dashboard.dart';
import 'screens/dashboard/driver_dashboard.dart';
import 'screens/dashboard/teacher_dashboard.dart';
import 'screens/dashboard/student_dashboard.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'upashtit2',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    try {
      print('🔍 Checking authentication state...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthState();
      print('✅ Authentication state checked successfully');
    } catch (e) {
      print('❌ Error checking authentication state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🏗️ Building AuthWrapper - Loading: ${authProvider.isLoading}, User: ${authProvider.user?.email ?? 'null'}');
        
        if (authProvider.isLoading) {
          print('⏳ Showing loading screen...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.user == null) {
          print('🔐 No user authenticated, showing login screen...');
          return const LoginScreen();
        }

        // Navigate based on user role
        print('👤 User authenticated with role: ${authProvider.user!.role}');
        switch (authProvider.user!.role) {
          case UserRole.admin:
            print('🎯 Navigating to Admin Dashboard');
            return const AdminDashboard();
          case UserRole.coordinator:
            print('🎯 Navigating to Coordinator Dashboard');
            return const CoordinatorDashboard();
          case UserRole.driver:
            print('🎯 Navigating to Driver Dashboard');
            return const DriverDashboard();
          case UserRole.teacher:
            print('🎯 Navigating to Teacher Dashboard');
            return const TeacherDashboard();
          case UserRole.student:
            print('🎯 Navigating to Student Dashboard');
            return const StudentDashboard();
          default:
            print('⚠️ Unknown user role, showing login screen');
            return const LoginScreen();
        }
      },
    );
  }
}