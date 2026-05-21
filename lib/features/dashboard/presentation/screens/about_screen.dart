import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                      'Our Vision & Infrastructure',
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
                      'Decentralizing culinary operations with premium software interfaces.',
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
                    GridView.count(
                      crossAxisCount: isMobile ? 1 : 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildPillarCard(
                          icon: Icons.restaurant_rounded,
                          title: 'Gastronomic Focus',
                          desc: 'We place the kitchen first. Every QR ordering card, waiter assignment table, and menu categories configuration is optimized for fast cooking performance.',
                          color: const Color(0xFFEC4899),
                          isDark: isDark,
                        ),
                        _buildPillarCard(
                          icon: Icons.bolt_rounded,
                          title: 'Engineering Velocity',
                          desc: 'Realtime updates with Firestore broadcast channels ensure orders reach preparation boards in less than 300 milliseconds.',
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                        ),
                        _buildPillarCard(
                          icon: Icons.palette_rounded,
                          title: 'Visual Elegance',
                          desc: 'We banish ugly spreadsheets. Staff managers use responsive modern layouts featuring glassmorphic overlays, vibrant gradients, and premium imagery.',
                          color: const Color(0xFF38BDF8),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                    Text(
                      'The SaaS Software Stack',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildTechChip('Flutter 3.41 SDK', isDark),
                        _buildTechChip('Riverpod Reactive State', isDark),
                        _buildTechChip('GoRouter Navigation', isDark),
                        _buildTechChip('Firebase Authentication', isDark),
                        _buildTechChip('Cloud Firestore Sync', isDark),
                        _buildTechChip('Stripe Payments API', isDark),
                        _buildTechChip('Gemini Image Generation', isDark),
                      ],
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

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white12 : Colors.indigo.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMiniFooter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
      child: const Center(
        child: Text(
          'MEGA System Core. 100% self-documenting clean modular setup.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
