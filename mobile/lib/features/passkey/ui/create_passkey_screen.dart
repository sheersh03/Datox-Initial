import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../profile/data/profile_api.dart';
import '../../../core/network/api_errors.dart';
import '../domain/passkey_service.dart';
import 'package:passkeys/exceptions.dart';

const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);
const _accentBlue = Color(0xFF3A86FF);
const _lightBlue = Color(0xFFEAF2FF);
const _lightPink = Color(0xFFFFE6F0);

class CreatePasskeyScreen extends StatefulWidget {
  const CreatePasskeyScreen({super.key});

  @override
  State<CreatePasskeyScreen> createState() => _CreatePasskeyScreenState();
}

class _CreatePasskeyScreenState extends State<CreatePasskeyScreen> {
  final _passkeyService = PasskeyService();
  bool _loading = false;
  String? _errorText;

  Future<void> _continueToHome() async {
    if (!mounted) return;
    final hasProfile = await ProfileApi.exists();
    if (!mounted) return;
    context.go(hasProfile ? '/discover' : '/profile-setup');
  }

  Future<void> _createPasskey() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await _passkeyService.registerPasskey();
      if (!mounted) return;
      await _continueToHome();
    } on PasskeyAuthCancelledException {
      if (!mounted) return;
      setState(() => _loading = false);
    } on PasskeyUnsupportedException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.message ?? 'Passkeys are not supported on this device.';
      });
    } on SyncAccountNotAvailableException {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = 'Sign in to your Google Account to create passkeys.';
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.code == 'channel-error' || e.message?.contains('channel') == true
            ? 'Passkeys aren\'t available on this device. You can set it up later on a supported device.'
            : (e.message ?? 'Passkey setup failed. You can try again later.');
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.response?.statusCode == 404
            ? 'Passkey service is not available. You can set it up later in Settings.'
            : (e.error is ApiException
                ? (e.error as ApiException).message
                : 'Something went wrong. You can try again later.');
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                _buildIcon(),
              const SizedBox(height: 32),
              const Text(
                'Do you want to create a passkey?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              _buildParagraph(
                'With a passkey, we\'ll always remember your device, so you can log in quickly and securely.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'To create one, we\'ll just need to find your email. That way, it can save to your Android Keychain.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'You can use this passkey on all of your devices.',
              ),
              const SizedBox(height: 16),
              _buildParagraph(
                'If you don\'t want to create one now, you can always do it later.',
              ),
                if (_errorText != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 48),
                _buildBottomActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [_lightBlue, _lightPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(2, 2),
          child: const FaIcon(
            FontAwesomeIcons.userLock,
            size: 40,
            color: _accentBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: _subtext,
        height: 1.5,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _loading ? null : _continueToHome,
          child: const Text(
            'Not now',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_lightBlue, _lightPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _loading ? null : _createPasskey,
              customBorder: const CircleBorder(),
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
                    : const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        color: _accentBlue,
                        size: 20,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
