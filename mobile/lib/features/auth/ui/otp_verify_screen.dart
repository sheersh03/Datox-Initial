import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/secure_store.dart';
import '../../../core/network/api_errors.dart';
import '../data/auth_api.dart';
import 'package:dio/dio.dart';

const _accentBlue = Color(0xFF3A86FF);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);
const _lightBluePrimary = Color(0xFFEAF2FF);
const _lightPinkAccent = Color(0xFFFFE6F0);
const _errorRed = Color(0xFFDC2626);

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _errorText;

  String _errorMessage(Object e) {
    if (e is DioException && e.error is ApiException) {
      return (e.error as ApiException).message;
    }
    return 'Something went wrong. Please try again.';
  }

  bool get _isValid => _otpCtrl.text.length >= 4;

  Future<void> _verify() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 4) {
      setState(() => _errorText = 'Enter a valid OTP');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final token = await AuthApi.verifyOtp(widget.phone, code);
      await SecureStore.write('token', token);
      if (!context.mounted) return;
      context.go('/create-passkey');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = _errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 22, color: _textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Enter the code we sent you',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a 6-digit code to ${widget.phone}',
                style: const TextStyle(
                  fontSize: 15,
                  color: _subtext,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (_) => setState(() => _errorText = null),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: _subtext.withValues(alpha: 0.4),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: _lightBluePrimary.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errorText != null ? _errorRed : _subtext.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _accentBlue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _errorRed),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  errorText: _errorText,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: _isValid && !_loading
                        ? const LinearGradient(
                            colors: [_lightBluePrimary, _lightPinkAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isValid && !_loading ? null : _subtext.withValues(alpha: 0.2),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isValid && !_loading ? _verify : null,
                      borderRadius: BorderRadius.circular(26),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _accentBlue,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _accentBlue,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
