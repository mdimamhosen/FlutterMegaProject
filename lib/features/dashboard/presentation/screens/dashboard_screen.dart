import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/database_service.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../analytics/presentation/screens/analytics_view.dart';
import '../../../order/presentation/screens/order_management_view.dart';
import '../../../menu/presentation/screens/menu_management_view.dart';
import '../../../table/presentation/screens/table_management_view.dart';
import '../../../reservation/presentation/screens/reservation_view.dart';
import '../../../workspace/presentation/screens/staff_management_view.dart';
import '../../../billing/presentation/screens/billing_view.dart';
import '../../../workspace/presentation/screens/settings_view.dart';

class DashboardScreen extends ConsumerWidget {
  final String currentTab;

  const DashboardScreen({super.key, required this.currentTab});

  Widget _buildBody() {
    switch (currentTab) {
      case 'analytics':
        return const AnalyticsView();
      case 'orders':
        return const OrderManagementView();
      case 'menu':
        return const MenuManagementView();
      case 'tables':
        return const TableManagementView();
      case 'reservations':
        return const ReservationView();
      case 'staff':
        return const StaffManagementView();
      case 'billing':
        return const BillingView();
      case 'settings':
        return const SettingsView();
      default:
        return const AnalyticsView();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = DatabaseService();
    final user = db.currentUser ?? {'name': 'Imam Hosen', 'role': 'owner'};
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final navItems = [
      _NavItem(id: 'analytics', title: 'Analytics', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded),
      _NavItem(id: 'orders', title: 'Live Orders', icon: Icons.restaurant_menu_outlined, activeIcon: Icons.restaurant_menu_rounded),
      _NavItem(id: 'menu', title: 'Menu Designer', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded),
      _NavItem(id: 'tables', title: 'Table Tracking', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded),
      _NavItem(id: 'reservations', title: 'Bookings', icon: Icons.book_online_outlined, activeIcon: Icons.book_online_rounded),
      _NavItem(id: 'staff', title: 'Staff List', icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded),
      _NavItem(id: 'billing', title: 'Stripe Billing', icon: Icons.credit_card_outlined, activeIcon: Icons.credit_card_rounded),
      _NavItem(id: 'settings', title: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
    ];

    Widget sidebar() => Container(
          width: 250,
          color: isDark ? const Color(0xFF111827) : Colors.white,
          child: Column(
            children: [
              // Sidebar Header Logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF10B981), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MEGA',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PRO', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),

              // Navigation Links List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: navItems.length,
                  itemBuilder: (context, idx) {
                    final item = navItems[idx];
                    final isSel = item.id == currentTab;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: ListTile(
                        onTap: () => context.go('/dashboard/${item.id}'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        selected: isSel,
                        selectedTileColor: const Color(0xFF10B981).withOpacity(0.08),
                        selectedColor: const Color(0xFF10B981),
                        leading: Icon(isSel ? item.activeIcon : item.icon),
                        title: Text(
                          item.title,
                          style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),

              // Sidebar Profile Footer & Sign Out
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                          child: Text(user['name']![0].toUpperCase(), style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(user['role']!.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        await db.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 14),
                      label: const Text('Sign Out', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      drawer: isMobile ? Drawer(child: sidebar()) : null,
      appBar: AppBar(
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        title: Row(
          children: [
            if (!isMobile) ...[
              const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La Parisienne Bistro',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Supabase Sync Realtime', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                )
              ],
            )
          ],
        ),
        actions: [
          // Realtime Connection Pulse indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('Realtime Live', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Theme Switcher Button
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) sidebar(),
          if (!isMobile) const VerticalDivider(width: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}

class _NavItem {
  final String id;
  final String title;
  final IconData icon;
  final IconData activeIcon;

  _NavItem({required this.id, required this.title, required this.icon, required this.activeIcon});
}
