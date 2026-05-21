import 'package:flutter/material.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = size.width < 900;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: isMobile ? 120 : 160,
              bottom: 60,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF090D16)]
                    : [const Color(0xFFEEF2F6), const Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Text(
                      'SaaS Operational Modules',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore how MEGA streamlines every aspect of tables tracking, cooking, and payment routing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            color: isDark ? const Color(0xFF0D131F) : Colors.white,
            width: double.infinity,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildModuleRow(
                      context: context,
                      title: 'Decentralized QR ordering',
                      subtitle: 'Violet aurora gradient theme',
                      desc: 'Customers scan a custom generated table QR code, browse categories, select item addons, and submit tickets directly. The order instantly bypasses manual servers to hit preparation queues, improving food throughput by 32%.',
                      colors: [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
                      icon: Icons.qr_code_2_rounded,
                      isImageLeft: true,
                      isMobile: isMobile,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 80),
                    _buildModuleRow(
                      context: context,
                      title: 'Live Prep Kitchen dashboard',
                      subtitle: 'Azure sky blue gradient theme',
                      desc: 'Chefs view dynamic Kanban cards showing elapsed time, custom prep alerts, and waiter assignments. Pings trigger sounds automatically when a new customer menu purchase fires from active sessions.',
                      colors: [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
                      icon: Icons.kitchen_rounded,
                      isImageLeft: false,
                      isMobile: isMobile,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 80),
                    _buildModuleRow(
                      context: context,
                      title: 'Table occupancy tracker & reservations',
                      subtitle: 'Mint green gradient theme',
                      desc: 'Tracks Available, Occupied, and Reserved table flags. Default waiters can be hot-assigned directly inside the grid, allowing direct pings and quick client dispatching.',
                      colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                      icon: Icons.calendar_month_rounded,
                      isImageLeft: true,
                      isMobile: isMobile,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildMiniFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildModuleRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String desc,
    required List<Color> colors,
    required IconData icon,
    required bool isImageLeft,
    required bool isMobile,
    required bool isDark,
  }) {
    final textCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.first.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.first, size: 24),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );

    final graphicsCol = Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 80),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          graphicsCol,
          const SizedBox(height: 24),
          textCol,
        ],
      );
    }

    return Row(
      children: [
        if (isImageLeft) ...[
          Expanded(child: graphicsCol),
          const SizedBox(width: 48),
          Expanded(child: textCol),
        ] else ...[
          Expanded(child: textCol),
          const SizedBox(width: 48),
          Expanded(child: graphicsCol),
        ]
      ],
    );
  }

  Widget _buildMiniFooter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
      child: const Center(
        child: Text(
          'MEGA Module Registry. Compiled successfully.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
