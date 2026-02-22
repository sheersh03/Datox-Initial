import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_errors.dart';
import '../data/auth_api.dart';

// OTP page theme colors (local to this feature)
const _lightBluePrimary = Color(0xFFEAF2FF);
const _accentBlue = Color(0xFF3A86FF);
const _lightPinkAccent = Color(0xFFFFE6F0);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);
const _errorRed = Color(0xFFDC2626);

class CountryCode {
  const CountryCode(this.name, this.code);
  final String name;
  final String code;
}

const _countries = [
  CountryCode('India', '+91'),
  CountryCode('United States', '+1'),
  CountryCode('United Kingdom', '+44'),
  CountryCode('Australia', '+61'),
  CountryCode('Canada', '+1'),
  CountryCode('Germany', '+49'),
  CountryCode('France', '+33'),
];

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneFocus = FocusNode();
  final _phoneCtrl = TextEditingController();
  CountryCode _selectedCountry = _countries.first;
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _phoneCtrl.removeListener(_onPhoneChanged);
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  bool get _isValid => _validatePhone(_phoneCtrl.text) == null;

  String? _validatePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String get _fullPhone => '${_selectedCountry.code}${_phoneCtrl.text.replaceAll(RegExp(r'\D'), '')}';

  Future<void> _sendOtp() async {
    final err = _validatePhone(_phoneCtrl.text);
    if (err != null) {
      setState(() => _errorText = err);
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await AuthApi.sendOtp(_fullPhone);
      if (!mounted) return;
      context.push('/otp-verify', extra: _fullPhone);
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException && e.error is ApiException
          ? (e.error as ApiException).message
          : 'Something went wrong. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              Text(
                'Can we get your number, please?',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We only use phone numbers to make sure everyone on Datox is real.',
                style: const TextStyle(
                  fontSize: 15,
                  color: _subtext,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Country',
                        style: TextStyle(
                          fontSize: 12,
                          color: _subtext,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _CountryDropdown(
                        value: _selectedCountry,
                        onChanged: (c) => setState(() => _selectedCountry = c),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PhoneInput(
                      controller: _phoneCtrl,
                      focusNode: _phoneFocus,
                      errorText: _errorText,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _PrivacyHelper(),
              const SizedBox(height: 24),
              _ContinueButton(
                isValid: _isValid,
                loading: _loading,
                onPressed: _sendOtp,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  const _CountryDropdown({
    required this.value,
    required this.onChanged,
  });

  final CountryCode value;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _subtext.withValues(alpha: 0.25)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryCode>(
          value: value,
          isExpanded: true,
          icon: FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 14,
            color: _subtext.withValues(alpha: 0.8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: BorderRadius.circular(12),
          items: _countries
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      '${c.code}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (c) => c != null ? onChanged(c) : null,
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
    required this.controller,
    required this.focusNode,
    this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            fontSize: 12,
            color: _subtext,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter your number',
            hintStyle: TextStyle(color: _subtext.withValues(alpha: 0.6)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? _errorRed : _subtext.withValues(alpha: 0.25),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? _errorRed : _subtext.withValues(alpha: 0.25),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _PrivacyHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: FaIcon(
              FontAwesomeIcons.lock,
              size: 12,
              color: _subtext.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'We never share this with anyone and it won\'t be on your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _subtext.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.isValid,
    required this.loading,
    required this.onPressed,
  });

  final bool isValid;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isValid ? 1 : 0.5,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: isValid
                ? const LinearGradient(
                    colors: [_lightBluePrimary, _lightPinkAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isValid ? null : _subtext.withValues(alpha: 0.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isValid && !loading ? onPressed : null,
              borderRadius: BorderRadius.circular(26),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accentBlue,
                        ),
                      )
                    : Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isValid ? _accentBlue : _subtext,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
