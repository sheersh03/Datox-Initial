import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../domain/location_service.dart';

const _bg = Color(0xFFF4F8FF);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);
const _accentBlue = Color(0xFF3A86FF);
const _lightPink = Color(0xFFFFE6F0);
const _errorRed = Color(0xFFDC2626);

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  final _locationService = LocationService();
  bool _loading = false;
  String? _errorText;

  Future<void> _onMaybeLater() async {
    if (!mounted) return;
    context.go('/discover?skip_location=1');
  }

  Future<void> _onAllowLocation() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final result = await _locationService.requestAndSaveLocation(
      timeout: const Duration(seconds: 10),
    );

    if (!mounted) return;

    switch (result) {
      case LocationResult.granted:
        context.go('/discover');
        return;
      case LocationResult.denied:
        setState(() {
          _loading = false;
          _errorText = 'Location access was denied. You can enable it in Settings.';
        });
        break;
      case LocationResult.permanentlyDenied:
        setState(() {
          _loading = false;
          _errorText = 'Location is disabled. Open Settings to enable it.';
        });
        break;
      case LocationResult.serviceDisabled:
        setState(() {
          _loading = false;
          _errorText = 'Please enable location services.';
        });
        break;
      case LocationResult.timeout:
        setState(() {
          _loading = false;
          _errorText = 'Location request timed out. Please try again.';
        });
        break;
      case LocationResult.unknown:
        setState(() {
          _loading = false;
          _errorText = 'Something went wrong. Please try again.';
        });
        break;
    }
  }

  Future<void> _openSettings() async {
    await _locationService.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                  'Enable location to discover people nearby',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildParagraph(
                  'We use your location to show you people in your area. '
                  'This helps with matching, safety, and finding connections nearby.',
                ),
                const SizedBox(height: 16),
                _buildParagraph(
                  'Your location is only shared with matches when you choose to. '
                  'You can change this anytime in Settings.',
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                      color: _errorRed,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_errorText!.contains('Settings')) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading ? null : _openSettings,
                      child: const Text('Open Settings'),
                    ),
                  ],
                ],
                const SizedBox(height: 48),
                _buildButtons(),
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
          color: _lightPink.withValues(alpha: 0.5),
          boxShadow: [
            BoxShadow(
              color: _accentBlue.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const FaIcon(
          FontAwesomeIcons.locationDot,
          size: 40,
          color: _accentBlue,
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
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _loading ? null : _onAllowLocation,
            style: FilledButton.styleFrom(
              backgroundColor: _accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Allow Location'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _loading ? null : _onMaybeLater,
          child: const Text(
            'Maybe later',
            style: TextStyle(
              color: _subtext,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
