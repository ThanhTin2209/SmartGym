import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/water_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/update_profile_screen.dart';
import 'screens/suggestion_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/services/service_list_screen.dart';
import 'screens/notification_screen.dart';
import 'constants/app_theme.dart';

// RouteObserver để HomeScreen (và các màn khác) có thể subscribe và nhận lifecycle callbacks
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const SmartGymApp());
}

class SmartGymApp extends StatelessWidget {
  const SmartGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGym',
      debugShowCheckedModeBanner: false,
      // Sử dụng theme mới từ AppTheme
      theme: AppTheme.lightTheme,
      initialRoute: '/welcome',
      navigatorObservers: [routeObserver],
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/water': (context) => const WaterScreen(),
        '/sleep': (context) => const SleepScreen(),
        '/nutrition': (context) => const NutritionScreen(),
        '/exercise': (context) => const ExerciseScreen(),
        '/updateProfile': (context) => const UpdateProfileScreen(),
        '/exercise/suggestions': (c) => const SuggestionsScreen(),
        '/exercise/progress': (c) => const ProgressScreen(),
        '/shop': (context) => const ShopScreen(),
        '/cart': (context) => const CartScreen(),
        '/cart': (context) => const CartScreen(),
        '/aiChat': (context) => const AiChatScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/serviceList': (context) => const ServiceListScreen(),
        '/notifications': (context) => const NotificationScreen(),
      },
    );
  }
}