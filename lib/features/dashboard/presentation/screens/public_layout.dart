import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_provider.dart';

class PublicLayout extends ConsumerStatefulWidget {
  final Widget child;
  const PublicLayout({super.key, required this.child});

  @override
  ConsumerState<PublicLayout> createState() => _PublicLayoutState();
}

class _PublicLayoutState extends ConsumerState<PublicLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: isDark
                ? const Color(0xFF090D16).withOpacity(0.7)
                : const Color(0xFFF8FAFC).withOpacity(0.7),
            elevation: 0,
            leading: isMobile
                ? IconButton(
                    icon: Icon(Icons.menu_rounded, color: isDark ? Colors.white : Colors.black87),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  )
                : null,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'MEGA',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.black,
                        fontFamily: 'Outfit',
                        letterSpacing: 1.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (!isMobile) ...[
                _buildNavLink(context, 'Features', '/features', currentRoute == '/features', isDark),
                _buildNavLink(context, 'Dishes Catalog', '/dishes', currentRoute == '/dishes', isDark),
                _buildNavLink(context, 'About Us', '/about', currentRoute == '/about', isDark),
                _buildNavLink(context, 'FAQs', '/faq', currentRoute == '/faq', isDark),
                _buildNavLink(context, 'Contact', '/contact', currentRoute == '/contact', isDark),
                const SizedBox(width: 16),
              ],
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amberAccent : Colors.indigo,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              const SizedBox(width: 8),
              if (!isMobile) ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(120, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'Launch Trial',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ),
      drawer: isMobile ? _buildDrawer(context, isDark) : null,
      body: widget.child,
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    String title,
    String route,
    bool isActive,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go(route),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isActive
                      ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF8B5CF6))
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'MEGA',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.black,
                      fontFamily: 'Outfit',
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildDrawerItem(context, 'Features', Icons.auto_awesome_rounded, '/features', isDark),
            _buildDrawerItem(context, 'Dishes Catalog', Icons.restaurant_menu_rounded, '/dishes', isDark),
            _buildDrawerItem(context, 'About Us', Icons.info_outline_rounded, '/about', isDark),
            _buildDrawerItem(context, 'FAQs', Icons.help_outline_rounded, '/faq', isDark),
            _buildDrawerItem(context, 'Contact', Icons.mail_outline_rounded, '/contact', isDark),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                    child: Text('Sign In', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/register');
                      },
                      child: const Text('Launch Trial'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
          fontFamily: 'Outfit',
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
