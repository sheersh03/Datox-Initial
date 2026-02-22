import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_errors.dart';
import '../data/discovery_api.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, this.skipLocationRedirect = false});

  /// When true, show error instead of redirecting to location-permission.
  /// Set when user tapped "Maybe later" on location screen.
  final bool skipLocationRedirect;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List profiles = [];
  int index = 0;
  bool loading = true;
  String? error;
  bool _isLocationRequired = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
      _isLocationRequired = false;
    });
    try {
      profiles = await DiscoveryApi.candidates();
    } catch (e) {
      if (e is DioException && e.error is ApiException) {
        final apiErr = e.error as ApiException;
        if (apiErr.code == 'LOCATION_REQUIRED') {
          if (!widget.skipLocationRedirect && mounted) {
            context.go('/location-permission');
            return;
          }
          error = apiErr.message;
          _isLocationRequired = true;
        } else if (apiErr.code == 'PROFILE_REQUIRED') {
          error = 'Complete your profile to start discovery.';
        } else {
          error = apiErr.message;
        }
      } else {
        error = 'Failed to load candidates.';
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Discover')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error!, textAlign: TextAlign.center),
                if (_isLocationRequired) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/location-permission'),
                    child: const Text('Enable Location'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    if (profiles.isEmpty || index >= profiles.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Discover')),
        body: const Center(child: Text('No candidates right now.')),
      );
    }

    final p = profiles[index];

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: SizedBox(
                width: 320,
                height: 420,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(p['name'],
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('${DateTime.now().year - p['birth_year']} yrs'),
                      const SizedBox(height: 12),
                      Text(p['bio'] ?? ''),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 36),
                  onPressed: () async {
                    await DiscoveryApi.swipe(p['user_id'], false);
                    setState(() => index++);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red, size: 36),
                  onPressed: () async {
                    try {
                      await DiscoveryApi.swipe(p['user_id'], true);
                      setState(() => index++);
                    } catch (_) {
                      Navigator.pushNamed(context, '/paywall');
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
