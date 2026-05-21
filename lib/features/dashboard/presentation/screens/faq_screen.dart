import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

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
                      'Frequently Asked Questions',
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
                      'Get answer to common technical queries about the MEGA platform.',
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
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  children: [
                    _buildAccordionTile(
                      title: 'How do I configure my restaurant\'s physical QR codes?',
                      answer: 'Within the Workspace dashboard, go to the Table Tracking section. Each active table displays a QR card quick-button. Clicking this allows you to preview, print, or download the high-resolution ordering card. The QR automatically points to the table\'s unique web route.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildAccordionTile(
                      title: 'Can I run MEGA without active Firebase connections?',
                      answer: 'Absolutely. MEGA features a dual-mode database architecture. If Firebase is active and initialized, all auth records and live streams sync to Cloud Firestore. If Firebase is offline or unconfigured, the system automatically falls back to our robust, pre-seeded local memory cache, allowing you to demo all kitchen Kanban screens immediately.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildAccordionTile(
                      title: 'How does the Stripe integration trial threshold function?',
                      answer: 'New workspace registrations seed an immediate 14-day Pro Plan trial. Under the Billing screen, you will see linear usage bars tracking your branch quotas, active staff members seats, and monthly order capacity. If you approach these limits, you can upgrade plans immediately to authorize high-volume Stripe direct billing.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildAccordionTile(
                      title: 'Does table ordering support active waiter notifications?',
                      answer: 'Yes. In the digital table grid, managers can assign specific default waiters to individual tables. When a customer scans a table QR and initiates an order or requests service, a notification is immediately streamed to the assigned waiter\'s terminal dashboard in real time.',
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

  Widget _buildAccordionTile({
    required String title,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedIconColor: isDark ? Colors.white70 : Colors.black87,
            iconColor: const Color(0xFF8B5CF6),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Outfit',
              ),
            ),
            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            children: [
              Text(
                answer,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
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
          'MEGA FAQ Core. Updated May 2026.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
