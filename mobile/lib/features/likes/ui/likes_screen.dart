import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_errors.dart';
import '../../discovery/data/discovery_api.dart';
import '../../discovery/ui/profile_detail_sheet.dart';
import '../data/likes_api.dart';

const _bg = Color(0xFFF4F8FF);
const _cardBg = Colors.white;
const _textPrimary = Color(0xFF1F1F1F);
const _textSecondary = Color(0xFF5F5F5F);

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  List<dynamic> _profiles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await LikesApi.whoLikedMe();
      if (mounted) {
        setState(() {
          _profiles = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.error is ApiException) {
        final apiErr = e.error as ApiException;
        if (apiErr.statusCode == 402 && apiErr.code == 'PAYWALL_REQUIRED') {
          context.go('/paywall');
          return;
        }
        setState(() {
          _error = apiErr.message;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load.';
          _loading = false;
        });
      }
    }
  }

  void _removeProfile(String userId) {
    setState(() {
      _profiles = _profiles
          .where((p) => (p as Map)['user_id'] != userId)
          .toList();
    });
  }

  Future<void> _swipe(String userId, bool like) async {
    try {
      await DiscoveryApi.swipe(userId, like);
      _removeProfile(userId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted && e is DioException && e.error is ApiException) {
        final apiErr = e.error as ApiException;
        if (apiErr.statusCode == 402 && apiErr.code == 'LIKE_LIMIT') {
          context.go('/paywall');
          return;
        }
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(title: const Text('Liked You')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(title: const Text('Liked You')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_profiles.isEmpty) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(title: const Text('Liked You')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'People who liked you will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _textSecondary,
                  ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Liked You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _profiles.length,
          itemBuilder: (context, index) {
            final p = _profiles[index] as Map<String, dynamic>;
            final birthYear = p['birth_year'];
            final age = birthYear != null
                ? DateTime.now().year - (birthYear is int ? birthYear : int.tryParse(birthYear.toString()) ?? 0)
                : null;
            final distance = p['distance_km'];
            final name = (p['name'] ?? 'Unknown').toString();
            final city = (p['city'] ?? '').toString();
            final photoUrl = p['primary_photo_url'] as String?;
            final userId = p['user_id'] as String? ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LikerCard(
                photoUrl: photoUrl,
                seed: userId,
                name: name,
                age: age,
                city: city,
                distance: distance,
                verified: p['verification_status'] == 'verified',
                onTap: () async {
                  await showDiscoveryProfileDetailSheet(
                    context,
                    profile: p,
                    age: age ?? 0,
                    distance: distance,
                    onPass: () => _swipe(userId, false),
                    onLike: () => _swipe(userId, true),
                    onBoost: () => _swipe(userId, true),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LikerCard extends StatelessWidget {
  const _LikerCard({
    required this.photoUrl,
    required this.seed,
    required this.name,
    required this.age,
    required this.city,
    required this.distance,
    required this.verified,
    required this.onTap,
  });

  final String? photoUrl;
  final String seed;
  final String name;
  final int? age;
  final String city;
  final dynamic distance;
  final bool verified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (city.isNotEmpty) city,
      if (distance != null) '${distance.toString()} km away',
    ].join(' • ');

    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const ColoredBox(
                            color: _textSecondary,
                            child: Center(
                              child: Icon(Icons.person, color: Colors.white54),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _FallbackImage(seed: seed),
                        )
                      : _FallbackImage(seed: seed),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            age != null ? '$name, $age' : name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        if (verified)
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF60A5FA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://picsum.photos/seed/$seed/160/160',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: _textSecondary,
        child: Center(
          child: Icon(Icons.person, color: Colors.white54),
        ),
      ),
    );
  }
}
