import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/category_detail_screen.dart';
import '../screens/search_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String detail = '/detail';
  static const String categoryDetail = '/category_detail';
  static const String search = '/search';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        home: (context) => const MainScreen(),
        detail: (context) => const DetailScreen(),
        categoryDetail: (context) => const CategoryDetailScreen(),
        search: (context) => const SearchScreen(),
      };
}
