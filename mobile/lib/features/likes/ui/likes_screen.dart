import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/api_errors.dart';
import '../../../theme/tokens.dart';
import '../data/likes_api.dart';

// Match discovery page colors
const _bg = Color(0xFFF4F8FF);
const _white = Colors.white;
const _actionPurple = Color(0xFF6D4CFF);
const _actionPink = Color(0xFFF59AD9);
const _actionRed = Color(0xFFFF7A7A);
const _cardShadow = Color(0x1A000000);
const _expiryRed = Color(0xFFE63946);
const _premiumGradientStart = Color(0xFFA8D4FF);
const _premiumGradientEnd = Color(0xFFE8C5E8);

const _freePreviewLimit = 2;

/// Format API liked_at (ISO string) as "X min ago" / "X hours ago" / "X days ago".
String _formatLikedAgo(String? likedAtIso) {
  if (likedAtIso == null || likedAtIso.isEmpty) return 'Recently';
  try {
    final then = DateTime.parse(likedAtIso).toLocal();
    final now = DateTime.now();
    final diff = now.difference(then);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${diff.inDays ~/ 7} week${diff.inDays ~/ 7 == 1 ? '' : 's'} ago';
  } catch (_) {
    return 'Recently';
  }
}

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  List<dynamic> _items = [];
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
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.error is ApiException) {
        final apiErr = e.error as ApiException;
        if (apiErr.statusCode == 402 && apiErr.code == 'PAYWALL_REQUIRED') {
          context.go('/paywall?context=liked_you');
          return;
        }
      }
      setState(() {
        _loading = false;
        if (e is DioException && e.error is ApiException) {
          _error = (e.error as ApiException).message;
        } else {
          _error = 'Failed to load who liked you.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(color: _actionPurple),
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Liked You',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: DatoxColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: DatoxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalLikes = _items.length;
    final freePreviews = _items.take(_freePreviewLimit).toList();
    final moreCount = totalLikes > _freePreviewLimit ? totalLikes - _freePreviewLimit : 0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: _actionPurple,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Liked You',
                              style: GoogleFonts.quicksand(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: DatoxColors.textPrimary,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'They swiped right — will you? 👀',
                              style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: DatoxColors.textMuted,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_actionPurple, _actionPink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: _actionPurple.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '$totalLikes likes',
                          style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: Colors.grey.shade200,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {},
                          customBorder: const CircleBorder(),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.bars,
                                size: 18,
                                color: DatoxColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Expiry banner
              if (moreCount > 0)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _expiryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '3 likes expire in 23:40:59 — unlock before they\'re gone',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (moreCount > 0) const SliverToBoxAdapter(child: SizedBox(height: 16)),
              // FREE PREVIEWS section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'FREE PREVIEWS — ${freePreviews.length} of $_freePreviewLimit used',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DatoxColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              ...freePreviews.asMap().entries.map((e) {
                final i = e.key;
                final p = e.value as Map<String, dynamic>;
                return SliverToBoxAdapter(
                  child: _LikedYouCard(
                    profile: p,
                    onPass: () => _onPass(i),
                    onLike: () => _onLike(p),
                  ),
                );
              }),
              // VYBB PREMIUM card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_premiumGradientStart, _premiumGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _actionPurple.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VYBB PREMIUM',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _white.withValues(alpha: 0.95),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'See everyone who already likes you ✨',
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Don\'t keep them waiting. $totalLikes people swiped right on you — match instantly by liking back.',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _white.withValues(alpha: 0.95),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          color: _white,
                          borderRadius: BorderRadius.circular(999),
                          elevation: 2,
                          shadowColor: Colors.black26,
                          child: InkWell(
                            onTap: () => context.push('/paywall'),
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Unlock All Likes',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: DatoxColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: DatoxColors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'From \$9.99/mo · Cancel anytime',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // X MORE WAITING FOR YOU
              if (moreCount > 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Text(
                      '$moreCount MORE WAITING FOR YOU',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DatoxColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        decoration: BoxDecoration(
                          color: _white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _cardShadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                color: Colors.grey.shade200,
                              ),
                              Center(
                                child: Icon(
                                  Icons.lock_rounded,
                                  size: 32,
                                  color: DatoxColors.textMuted.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      childCount: moreCount > 9 ? 9 : moreCount,
                    ),
                  ),
                ),
              ],
              if (totalLikes == 0)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        'People who liked you will appear here.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: DatoxColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPass(int index) {
    setState(() {
      if (index < _items.length) {
        _items.removeAt(index);
      }
    });
  }

  void _onLike(Map<String, dynamic> p) {
    context.push('/paywall');
  }
}

class _LikedYouCard extends StatelessWidget {
  const _LikedYouCard({
    required this.profile,
    required this.onPass,
    required this.onLike,
  });

  final Map<String, dynamic> profile;
  final VoidCallback onPass;
  final VoidCallback onLike;

  Widget _avatar(String? photoUrl, String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey.shade300,
          child: photoUrl != null && photoUrl.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    width: 64,
                    height: 64,
                    placeholder: (_, __) => Text(
                      initial,
                      style: GoogleFonts.quicksand(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: DatoxColors.textMuted,
                      ),
                    ),
                    errorWidget: (_, __, ___) => Text(
                      initial,
                      style: GoogleFonts.quicksand(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: DatoxColors.textMuted,
                      ),
                    ),
                  ),
                )
              : Text(
                  initial,
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: DatoxColors.textMuted,
                  ),
                ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_actionPurple, _actionPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _white, width: 2),
            ),
            child: const Icon(Icons.favorite_rounded, size: 14, color: _white),
          ),
        ),
      ],
    );
  }

  /// Detail line from API: "City · X km" or "City" or "Near you".
  String _detailSubtitle(String city, Object? distanceKm) {
    final dist = distanceKm is num ? distanceKm.toDouble() : null;
    final cityPart = city.isNotEmpty ? city : 'Near you';
    if (dist != null) return '$cityPart · ${dist.toStringAsFixed(1)} km';
    return cityPart;
  }

  @override
  Widget build(BuildContext context) {
    final name = (profile['name'] ?? 'Unknown').toString();
    final birthYear = profile['birth_year'] as int?;
    final age = birthYear != null ? DateTime.now().year - birthYear : null;
    final city = (profile['city'] ?? '').toString();
    final bio = (profile['bio'] ?? '').toString();
    final photoUrl = profile['primary_photo_url'] as String?;
    final likedAtIso = profile['liked_at'] as String?;
    final distanceKm = profile['distance_km'];
    final quote = bio.length > 50 ? '${bio.substring(0, 50)}...' : bio;
    final subtitle = _detailSubtitle(city, distanceKm);
    final likedAgo = _formatLikedAgo(likedAtIso);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(photoUrl, name),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  age != null ? '$name, $age' : name,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DatoxColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DatoxColors.textMuted,
                  ),
                ),
                if (quote.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"$quote"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: DatoxColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '❤️ Liked you $likedAgo',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _actionRed,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: _actionRed,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onPass,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(Icons.close_rounded, color: _white, size: 26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onLike,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_actionPurple, _actionPink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, color: _white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
