import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/database_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Form Fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  String _businessType = 'Bistro / Café';

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _businessTypes = [
    'Bistro / Café',
    'Fine Dining Restaurant',
    'Fast Food / QSR',
    'Food Truck',
    'Bakery & Dessert Shop',
  ];

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = DatabaseService();
      await db.registerOwner(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        restaurantName: _restaurantNameController.text,
      );
      if (mounted) {
        context.go('/dashboard/analytics');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _currentStep = 0; // Go back to first step on error
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

    Widget stepIndicator() => Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep >= 1
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        );

    Widget firstStepForm() => Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let\'s create your Owner Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your details to create the super-user account.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Name is required.',
                decoration: const InputDecoration(
                  hintText: 'e.g. John Doe',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Valid email is required.',
                decoration: const InputDecoration(
                  hintText: 'john@restaurant.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Text('Secure Password', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (v) => v != null && v.length >= 6 ? null : 'Password must be >= 6 characters.',
                decoration: const InputDecoration(
                  hintText: 'Min 6 characters',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey1.currentState!.validate()) {
                    setState(() => _currentStep = 1);
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next: Restaurant Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ),
        );

    Widget secondStepForm() => Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your Restaurant',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'This seeds your brand workspace, menus, and table layout.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Text('Restaurant Name', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(height: 6),
              TextFormField(
                controller: _restaurantNameController,
                validator: (v) => v != null && v.isNotEmpty ? null : 'Restaurant name is required.',
                decoration: const InputDecoration(
                  hintText: 'e.g. La Bella Vita',
                  prefixIcon: Icon(Icons.restaurant_rounded),
                ),
              ),
              const SizedBox(height: 18),
              Text('Business Type', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _businessType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _businessTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _businessType = val);
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey2.currentState!.validate()) {
                                _handleRegister();
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Finish Onboarding', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    Widget formContainer() => Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/login'),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Create SaaS Account',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                stepIndicator(),
                const SizedBox(height: 24),
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
                _currentStep == 0 ? firstStepForm() : secondStepForm(),
              ],
            ),
          ),
        );

    return Scaffold(
      body: isMobile
          ? formContainer()
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: formContainer(),
                ),
                // Visual Split Screen Panel
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                          Theme.of(context).colorScheme.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Launch your Restaurant in minutes.',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Setting up your workspace automatically registers database partitions, seeds initial menus, generates starter tables, and activates a 14-day free trial on our premium SaaS Pro Plan.',
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
