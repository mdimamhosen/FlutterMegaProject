import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/order/presentation/screens/customer_menu_screen.dart';
import '../network/database_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    final db = DatabaseService();
    final isLoggedIn = db.currentUser != null;
    final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (state.matchedLocation.startsWith('/menu/table/')) {
      return null;
    }

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
