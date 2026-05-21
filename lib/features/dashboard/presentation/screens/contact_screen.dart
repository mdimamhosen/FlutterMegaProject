import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _msgController = TextEditingController();
  String _subject = 'General SaaS Inquiries';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: isDark ? const Color(0xFF131A26) : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Message Transmitted',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you ${_nameController.text}. We seeded your request to our operations center. A developer agent will contact you shortly.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () {
                    _nameController.clear();
                    _emailController.clear();
                    _msgController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

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
                      'Contact Our Core Team',
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
                      'Have questions regarding Stripe integration, table quotas, or custom domains?',
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
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isMobile
                    ? Column(
                        children: [
                          _buildFormSection(isDark),
                          const SizedBox(height: 40),
                          _buildMapSection(isDark),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildFormSection(isDark)),
                          const SizedBox(width: 48),
                          Expanded(flex: 4, child: _buildMapSection(isDark)),
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

  Widget _buildFormSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Inquiry Ticket',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 24),
            Text('Your Name', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              validator: (v) => v != null && v.isNotEmpty ? null : 'Name is required.',
              decoration: const InputDecoration(hintText: 'e.g. John Doe'),
            ),
            const SizedBox(height: 18),
            Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email address.',
              decoration: const InputDecoration(hintText: 'john@restaurant.com'),
            ),
            const SizedBox(height: 18),
            Text('Inquiry Type', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _subject,
              items: ['General SaaS Inquiries', 'Stripe Merchant Pipeline', 'Custom Franchise Solutions']
                  .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _subject = val);
                }
              },
            ),
            const SizedBox(height: 18),
            Text('Message', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 6),
            TextFormField(
              controller: _msgController,
              maxLines: 4,
              validator: (v) => v != null && v.isNotEmpty ? null : 'Message body cannot be empty.',
              decoration: const InputDecoration(hintText: 'Describe your request details...'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Transmit Request Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operating Centers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 24),
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GridPainter(isDark: isDark),
                ),
              ),
              const Positioned(
                left: 60,
                top: 80,
                child: _MapPin(title: 'Paris Head Office', subtitle: 'Support Center'),
              ),
              const Positioned(
                right: 80,
                bottom: 60,
                child: _MapPin(title: 'New York Node', subtitle: 'Developer Core'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoTile(Icons.phone_rounded, '+1 (555) 019-MEGA', 'Mon-Fri 9AM to 6PM'),
        _buildInfoTile(Icons.mail_outline_rounded, 'inquiries@mega-saas.net', 'Expect responses in 2 hours'),
        _buildInfoTile(Icons.location_on_outlined, '12 Place de la Bastille', '75011 Paris, France'),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String primary, String secondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 18),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(primary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(secondary, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
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
          'MEGA Core Infrastructure. Encrypted inquiries routing active.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  final String title;
  final String subtitle;
  const _MapPin({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$title\n$subtitle',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
            ),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
