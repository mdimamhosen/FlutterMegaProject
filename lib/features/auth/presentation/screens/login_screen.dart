import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/database_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'owner@mega.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = DatabaseService();
      await db.login(email, password);
      if (mounted) {
        context.go('/dashboard/analytics');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = size.width < 900;

    Widget formWidget() => Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Welcome to Mega',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'Outfit',
                          ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'SaaS Restaurant Management Platform',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email address.',
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (v) => v != null && v.length >= 6 ? null : 'Password must be at least 6 characters.',
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _handleLogin(_emailController.text, _passwordController.text);
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Want to launch a restaurant? ",
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          "Start Trial",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  // --- Premium Quick Login Drawer/Panel ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary, size: 20),
                            const SizedBox(width: 6),
                            const Text(
                              'Developer Quick-Login',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              label: const Text('🔑 Owner'),
                              onPressed: () => _handleLogin('owner@mega.com', 'password123'),
                            ),
                            ActionChip(
                              label: const Text('🍳 Kitchen'),
                              onPressed: () => _handleLogin('jacques@mega.com', 'password123'),
                            ),
                            ActionChip(
                              label: const Text('🏃 Waiter'),
                              onPressed: () => _handleLogin('alex@mega.com', 'password123'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Scaffold(
      body: isMobile
          ? formWidget()
          : Row(
              children: [
                // Visual split-screen panel
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.85),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Restaurant OS v1.0',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Manage all dining operations in one single unified place.',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Realtime kitchen status, interactive table grid, push ordering, and automated Stripe billing natively integrated.',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Form Container
                Expanded(
                  flex: 5,
                  child: formWidget(),
                ),
              ],
            ),
    );
  }
}
