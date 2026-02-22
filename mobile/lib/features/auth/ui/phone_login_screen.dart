import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import '../../../core/storage/secure_store.dart';
import '../../../core/network/api_errors.dart';
import '../data/auth_api.dart';
import '../../profile/data/profile_api.dart';
import 'package:go_router/go_router.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  bool otpSent = false;
  bool loading = false;

  String _errorMessage(Object e) {
    if (e is DioException && e.error is ApiException) {
      return (e.error as ApiException).message;
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Datox', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            if (otpSent)
              TextField(
                controller: otpCtrl,
                decoration: const InputDecoration(labelText: 'OTP'),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final phone = phoneCtrl.text.trim();
                      final otp = otpCtrl.text.trim();
                      if (phone.isEmpty || (otpSent && otp.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Enter required fields')),
                        );
                        return;
                      }

                      setState(() => loading = true);
                      try {
                        if (!otpSent) {
                          await AuthApi.sendOtp(phone);
                          if (!mounted) return;
                          setState(() => otpSent = true);
                        } else {
                          final token = await AuthApi.verifyOtp(phone, otp);
                          await SecureStore.write('token', token);
                          if (!context.mounted) return;
                          final hasProfile = await ProfileApi.exists();
                          if (!context.mounted) return;
                          context
                              .go(hasProfile ? '/discover' : '/profile-setup');
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_errorMessage(e))),
                        );
                      } finally {
                        if (mounted) setState(() => loading = false);
                      }
                    },
              child: Text(
                loading
                    ? 'Please wait...'
                    : (otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
