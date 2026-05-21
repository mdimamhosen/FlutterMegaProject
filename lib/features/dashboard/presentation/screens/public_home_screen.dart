import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

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
              top: isMobile ? 120 : 180,
              bottom: isMobile ? 80 : 120,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E1E38),
                        const Color(0xFF090D16),
                      ]
                    : [
                        const Color(0xFFE0E7FF),
                        const Color(0xFFF8FAFC),
                      ],
                center: const Alignment(0.6, -0.6),
                radius: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.indigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.indigo.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NEW: Live Kitchen Audio & QR Pay Integrated',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'The Smart Operating System\nfor Modern Gastronomy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 36 : 64,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        height: 1.15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        'Empower your culinary venue with responsive multi-table QR ordering, lightning-fast realtime kitchen screens, automated table status mapping, and streamlined Stripe-backed billing pipelines in one beautiful workspace.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(200, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => context.go('/register'),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Launch Free Trial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(200, 54),
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => context.go('/dishes'),
                          child: Text(
                            'Explore Specialties',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            color: isDark ? const Color(0xFF0D131F) : Colors.white,
            width: double.infinity,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Text(
                      'Why Food Brands Prefer Mega',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 48),
                    GridView.count(
                      crossAxisCount: isMobile ? 1 : 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: isMobile ? 1.4 : 1.1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'QR-Code Menu Ordering',
                          desc: 'Each physical table maps to a dynamic digital menu route. Guests scan, customize details, and push tickets directly to the chefs without downloading any applications.',
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.kitchen_rounded,
                          title: 'Realtime Kitchen display',
                          desc: 'Automatic preparation timelines, ticket priority alerts, and loud sound pings sync state dynamically across staff terminals.',
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                        ),
                        _buildFeatureCard(
                          context: context,
                          icon: Icons.analytics_outlined,
                          title: 'Stripe SaaS Infrastructure',
                          desc: 'Easily manage plans, active waiters limits, and operational capacity quotas with natively integrated Stripe billing rules.',
                          color: const Color(0xFF38BDF8),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            color: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
            width: double.infinity,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    Text(
                      'Simple Transparent Pricing',
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start with our fully functional 14-day free trial. No credit card required.',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 48),
                    GridView.count(
                      crossAxisCount: isMobile ? 1 : 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: isMobile ? 1.25 : 0.82,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildPriceCard(
                          context: context,
                          plan: 'BASIC',
                          price: '\$29',
                          desc: 'Ideal for local coffee trucks and fast dessert stalls.',
                          features: ['1 Active Branch', 'Max 150 Orders/Mo', '3 Staff Seats', 'Digital Menu Access'],
                          isPopular: false,
                          isDark: isDark,
                        ),
                        _buildPriceCard(
                          context: context,
                          plan: 'PRO',
                          price: '\$79',
                          desc: 'Perfect for established bistros and bustling eateries.',
                          features: ['Up to 5 Branches', '1000 Orders/Mo', '15 Staff Seats', 'Realtime Kitchen System', 'Priority support'],
                          isPopular: true,
                          isDark: isDark,
                        ),
                        _buildPriceCard(
                          context: context,
                          plan: 'ENTERPRISE',
                          price: '\$199',
                          desc: 'Designed for franchise chains and massive dining hubs.',
                          features: ['Unlimited Branches', 'Unlimited Orders', 'Unlimited Staff Seats', 'Custom Domain Setup', 'Super Admin APIs'],
                          isPopular: false,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
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
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required BuildContext context,
    required String plan,
    required String price,
    required String desc,
    required List<String> features,
    required bool isPopular,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: isDark
            ? (isPopular ? const Color(0xFF1E1E38) : const Color(0xFF131A26))
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular
              ? const Color(0xFF8B5CF6)
              : (isDark ? Colors.white10 : Colors.black12),
          width: isPopular ? 2.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isPopular ? const Color(0xFF8B5CF6) : Colors.grey,
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/month',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          features[idx],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPopular ? const Color(0xFF8B5CF6) : Colors.transparent,
              foregroundColor: isPopular ? Colors.white : (isDark ? Colors.white : Colors.indigo),
              side: isPopular
                  ? BorderSide.none
                  : BorderSide(color: isDark ? Colors.white24 : Colors.black12),
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => context.go('/register'),
            child: Text(
              isPopular ? 'Launch Free Trial' : 'Get Started',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      width: double.infinity,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'MEGA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Outfit',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Decentralized digital menu ordering and restaurant automation workspace.',
                          style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildFooterCol('Product', ['Features', 'Dishes Catalog', 'Pricing']),
                  _buildFooterCol('Company', ['About Us', 'Contact', 'Blog']),
                  _buildFooterCol('Legal', ['Terms', 'Privacy', 'Stripe compliance']),
                ],
              ),
              const Divider(color: Colors.white10, height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '© 2026 MEGA Restaurant Systems. Built for elite dining experiences.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  Row(
                    children: [
                      _buildSocialIcon(Icons.share_rounded),
                      const SizedBox(width: 12),
                      _buildSocialIcon(Icons.rocket_launch_rounded),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterCol(String title, List<String> links) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...links.map((lnk) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  lnk,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 16),
    );
  }
}
