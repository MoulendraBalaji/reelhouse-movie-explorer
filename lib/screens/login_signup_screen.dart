// CONCEPT: Forms & Validation (Syllabus Concept g)
// Form + GlobalKey<FormState> + TextFormField on Login & Sign-up with inline regex validation,
// disabled submission during loading, and Iris transition on auth success.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/validators.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/motion/iris_shutter_transition.dart';
import 'home_screen.dart';

class LoginSignupScreen extends StatefulWidget {
  final String? redirectPath;

  const LoginSignupScreen({super.key, this.redirectPath});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    try {
      if (_isSignUp) {
        await auth.signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await auth.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        // Success: transition via Iris Shutter to Home or redirect path
        Navigator.of(context).pushReplacement(
          IrisPageRoute(page: const HomeScreen()),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CinemaTokens.ticketRed,
            content: Text('Authentication dispatch failed. Check credentials.', style: CinemaText.monoLabel(color: CinemaTokens.bone)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemaTokens.celluloidBlack,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CinemaTokens.projectorAmber),
          tooltip: 'Return to Cinema Home',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
        ),
        title: Text(
          _isSignUp ? 'PATRON SIGN-UP' : 'PROJECTION BOOTH LOGIN',
          style: const TextStyle(fontFamily: CinemaTokens.fontDisplay, fontSize: 24, letterSpacing: 2),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: CinemaTokens.boothBrown,
                border: Border.all(color: CinemaTokens.hairline),
                borderRadius: CinemaTokens.borderSharp,
                boxShadow: [
                  BoxShadow(
                    color: CinemaTokens.projectorAmber.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Heading
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: CinemaTokens.projectorAmber, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.movie_filter, size: 28, color: CinemaTokens.projectorAmber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'REELHOUSE',
                        style: TextStyle(
                          fontFamily: CinemaTokens.fontDisplay,
                          fontSize: 32,
                          letterSpacing: 3,
                          color: CinemaTokens.bone,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        _isSignUp ? 'REGISTER FOR SCREENING ADMISSION' : 'ENTER 35MM PROJECTION CONTROL',
                        style: CinemaText.monoBadge(color: CinemaTokens.ash),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name (Sign-up only)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        validator: CinemaValidators.validateName,
                        style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                        decoration: const InputDecoration(
                          labelText: 'Patron Full Name',
                          prefixIcon: Icon(Icons.person_outline, color: CinemaTokens.ash),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      validator: CinemaValidators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                      decoration: const InputDecoration(
                        labelText: 'Dispatch Email Address',
                        prefixIcon: Icon(Icons.email_outlined, color: CinemaTokens.ash),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      validator: CinemaValidators.validatePassword,
                      obscureText: _obscurePassword,
                      style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                      decoration: InputDecoration(
                        labelText: 'Passcode (min 8 chars, 1 digit)',
                        prefixIcon: const Icon(Icons.lock_outline, color: CinemaTokens.ash),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: CinemaTokens.ash,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password (Sign-up only)
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _confirmPasswordController,
                        validator: (val) => CinemaValidators.validateConfirmPassword(
                          val,
                          _passwordController.text,
                        ),
                        obscureText: _obscurePassword,
                        style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                        decoration: const InputDecoration(
                          labelText: 'Confirm Passcode',
                          prefixIcon: Icon(Icons.lock_reset, color: CinemaTokens.ash),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 12),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleAuthSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(CinemaTokens.celluloidBlack),
                              ),
                            )
                          : Text(
                              _isSignUp ? 'COMPLETE REGISTRATION' : 'UNLOCK PROJECTION BOOTH',
                            ),
                    ),
                    const SizedBox(height: 12),

                    // One-click instant patron guest access
                    OutlinedButton.icon(
                      icon: const Icon(Icons.flash_on, size: 16),
                      label: const Text('CONTINUE AS PATRON (1-CLICK ACCESS)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CinemaTokens.projectorAmber,
                        side: const BorderSide(color: CinemaTokens.projectorAmber),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final auth = context.read<AuthProvider>();
                        final nav = Navigator.of(context);
                        await auth.login('moulendra@reelhouse.cinema', 'password123');
                        if (mounted) {
                          nav.pushReplacementNamed('/home');
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Toggle between Login & Sign-up
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isSignUp
                            ? 'ALREADY REGISTERED? SIGN IN INSTEAD'
                            : 'NEW PATRON? REGISTER FOR ADMISSION',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Safe return to Home
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                      child: Text(
                        '← RETURN TO NOW SHOWING',
                        style: CinemaText.monoBadge(color: CinemaTokens.ash),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
