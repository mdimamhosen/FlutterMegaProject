import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/order/presentation/screens/customer_menu_screen.dart';
import '../../features/dashboard/presentation/screens/public_layout.dart';
import '../../features/dashboard/presentation/screens/public_home_screen.dart';
import '../../features/dashboard/presentation/screens/about_screen.dart';
import '../../features/dashboard/presentation/screens/contact_screen.dart';
import '../../features/dashboard/presentation/screens/faq_screen.dart';
import '../../features/dashboard/presentation/screens/features_screen.dart';
import '../../features/menu/presentation/screens/public_dishes_screen.dart';
import '../../features/menu/presentation/screens/dish_detail_screen.dart';
import '../network/database_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final db = DatabaseService();
    final isLoggedIn = db.currentUser != null;

    final isPublic = state.matchedLocation == '/' ||
        state.matchedLocation == '/about' ||
        state.matchedLocation == '/contact' ||
        state.matchedLocation == '/faq' ||
        state.matchedLocation == '/features' ||
        state.matchedLocation == '/dishes' ||
        state.matchedLocation.startsWith('/dishes/') ||
        state.matchedLocation.startsWith('/menu/table/');

    if (isPublic) {
      return null;
    }

    final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isLoggedIn && !isGoingToAuth) {
      return '/login';
    }
    if (isLoggedIn && isGoingToAuth) {
      return '/dashboard/analytics';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PublicLayout(child: PublicHomeScreen()),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const PublicLayout(child: AboutScreen()),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const PublicLayout(child: ContactScreen()),
    ),
    GoRoute(
      path: '/faq',
      builder: (context, state) => const PublicLayout(child: FaqScreen()),
    ),
    GoRoute(
      path: '/features',
      builder: (context, state) => const PublicLayout(child: FeaturesScreen()),
    ),
    GoRoute(
      path: '/dishes',
      builder: (context, state) => const PublicLayout(child: PublicDishesScreen()),
    ),
    GoRoute(
      path: '/dishes/:dishId',
      builder: (context, state) {
        final dishId = state.pathParameters['dishId']!;
        return PublicLayout(child: DishDetailScreen(dishId: dishId));
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard/:tab',
      builder: (context, state) {
        final tab = state.pathParameters['tab'] ?? 'analytics';
        return DashboardScreen(currentTab: tab);
      },
    ),
    GoRoute(
      path: '/menu/table/:tableId/:tableNumber',
      builder: (context, state) {
        final tableId = state.pathParameters['tableId']!;
        final tableNumber = state.pathParameters['tableNumber']!;
        return CustomerMenuScreen(tableId: tableId, tableNumber: tableNumber);
      },
    ),
  ],
);
