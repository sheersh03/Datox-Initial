import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/secure_store.dart';
import '../../profile/data/profile_api.dart';
import 'widgets/social_login_button.dart';

const _loginAccent = Color(0xFFFFC629);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _quickSignInLoading = false;
  bool _facebookLoading = false;
  bool _googleLoading = false;

  Future<void> _quickSignIn() async {
    setState(() => _quickSignInLoading = true);
    try {
      final token = await SecureStore.read('token');
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No saved session. Sign in with your phone first.'),
          ),
        );
        return;
      }
      final hasProfile = await ProfileApi.exists();
      if (!mounted) return;
      context.go(hasProfile ? '/discover' : '/profile-setup');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please sign in again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _quickSignInLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _facebookLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _facebookLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook sign in coming soon.')),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _googleLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign in coming soon.')),
    );
  }

  void _useMobileNumber() {
    context.push('/phone-login');
  }

  void _openLink(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          _buildOverlay(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                child: Column(
                  children: [
                    _buildTopSection(context),
                    const SizedBox(height: 48),
                    _buildContent(context),
                    const SizedBox(height: 24),
                    _buildButtons(context),
                    const SizedBox(height: 32),
                    _buildBottomLinks(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: Image.network(
        'https://picsum.photos/seed/datox-login/800/1600',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              if (context.canPop())
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              Text(
                'Datox',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _loginAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Real Connections',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'For the Love of\nLove',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: _loginAccent,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ) ??
                const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _loginAccent,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'You last signed in with a mobile number',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    const spacing = 12.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SocialLoginButton(
            label: 'Quick sign in',
            onPressed: _quickSignIn,
            isLoading: _quickSignInLoading,
            icon: FaIcon(FontAwesomeIcons.userCheck, color: Colors.grey.shade800, size: 20),
          ),
          const SizedBox(height: spacing),
          SocialLoginButton(
            label: 'Continue with Facebook',
            onPressed: _signInWithFacebook,
            isLoading: _facebookLoading,
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            borderColor: const Color(0xFF1877F2),
            icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white, size: 20),
          ),
          const SizedBox(height: spacing),
          SocialLoginButton(
            label: 'Continue with Google',
            onPressed: _signInWithGoogle,
            isLoading: _googleLoading,
            icon: FaIcon(FontAwesomeIcons.google, color: Colors.grey.shade800, size: 20),
          ),
          const SizedBox(height: spacing),
          SocialLoginButton(
            label: 'Use mobile number',
            onPressed: _useMobileNumber,
            icon: FaIcon(FontAwesomeIcons.mobileScreen, color: Colors.grey.shade800, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLinks(BuildContext context) {
    final linkStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.9),
      fontSize: 12,
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text.rich(
        TextSpan(
          text: 'By signing up, you agree to our ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: 'Terms',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openLink(context, 'Terms'),
            ),
            const TextSpan(text: '. See how we use your data in our '),
            TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _openLink(context, 'Privacy Policy'),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
