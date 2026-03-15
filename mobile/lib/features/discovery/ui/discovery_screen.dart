import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_errors.dart';
import '../data/discovery_api.dart';

const _bg = Color(0xFFF4F8FF);
const _white = Colors.white;
const _subtleBorder = Color(0x40FFFFFF);
const _actionPurple = Color(0xFF6D4CFF);
const _actionPink = Color(0xFFF59AD9);
const _actionRed = Color(0xFFFF7A7A);
const _actionBlueGray = Color(0xFFCBD5E1);

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, this.skipLocationRedirect = false});

  final bool skipLocationRedirect;

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List profiles = [];
  int index = 0;
  bool loading = true;
  bool _submitting = false;
  bool _dragActive = false;
  double _cardOffsetDx = 0;
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

  Future<void> _swipe(bool like) async {
    if (_submitting || profiles.isEmpty || index >= profiles.length) return;
    final p = profiles[index];
    setState(() => _submitting = true);
    try {
      await DiscoveryApi.swipe(p['user_id'], like);
      if (!mounted) return;
      setState(() {
        index++;
        _cardOffsetDx = 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cardOffsetDx = 0);
      if (like) {
        context.go('/paywall');
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _dragActive = false;
        });
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_submitting) return;
    setState(() {
      _dragActive = true;
      _cardOffsetDx += details.delta.dx;
    });
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (_submitting) return;
    const swipeThreshold = 110.0;
    final shouldLike = _cardOffsetDx > swipeThreshold;
    final shouldPass = _cardOffsetDx < -swipeThreshold;

    if (!shouldLike && !shouldPass) {
      setState(() {
        _dragActive = false;
        _cardOffsetDx = 0;
      });
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _dragActive = false;
      _cardOffsetDx = shouldLike ? screenWidth : -screenWidth;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    await _swipe(shouldLike);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        backgroundColor: _bg,
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
        backgroundColor: _bg,
        appBar: AppBar(title: const Text('Discover')),
        body: const Center(child: Text('No candidates right now.')),
      );
    }

    final p = profiles[index] as Map<String, dynamic>;
    final age = DateTime.now().year - (p['birth_year'] as int);
    final distance = p['distance_km'];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = ((_cardOffsetDx.abs() / constraints.maxWidth)
                            .clamp(0.0, 1.0))
                        .toDouble();
                    final rotation = _cardOffsetDx / constraints.maxWidth * 0.12;

                    return GestureDetector(
                      onPanUpdate: _handleDragUpdate,
                      onPanEnd: _handleDragEnd,
                      child: AnimatedContainer(
                        key: ValueKey('${p['user_id']}-${index}'),
                        duration: Duration(milliseconds: _dragActive ? 0 : 220),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.identity()
                          ..translate(_cardOffsetDx, progress * -8)
                          ..rotateZ(rotation),
                        transformAlignment: Alignment.center,
                        child: _DiscoveryProfileCard(
                          profile: p,
                          age: age,
                          distance: distance,
                          disabled: _submitting,
                          onRewind: () {},
                          onPass: () => _swipe(false),
                          onLike: () => _swipe(true),
                          onBoost: () {},
                          dragProgress: progress,
                          swipeDirection: _cardOffsetDx.sign.toInt(),
                        ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryProfileCard extends StatefulWidget {
  const _DiscoveryProfileCard({
    required this.profile,
    required this.age,
    required this.distance,
    required this.disabled,
    required this.onRewind,
    required this.onPass,
    required this.onLike,
    required this.onBoost,
    required this.dragProgress,
    required this.swipeDirection,
  });

  final Map<String, dynamic> profile;
  final int age;
  final dynamic distance;
  final bool disabled;
  final VoidCallback onRewind;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onBoost;
  final double dragProgress;
  final int swipeDirection;

  @override
  State<_DiscoveryProfileCard> createState() => _DiscoveryProfileCardState();
}

class _DiscoveryProfileCardState extends State<_DiscoveryProfileCard> {
  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.profile['primary_photo_url'] as String?;
    final name = (widget.profile['name'] ?? 'Unknown').toString();
    final city = (widget.profile['city'] ?? '').toString();
    final bio = (widget.profile['bio'] ?? '').toString();
    final verified = widget.profile['verification_status'] == 'verified';
    final subtitle = [
      if (city.isNotEmpty) city,
      if (widget.distance != null) '${widget.distance.toString()} km away',
    ].join(' • ');
    final chips = _buildChips(city: city, bio: bio);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ProfileImageLayer(
              photoUrl: photoUrl,
              seed: widget.profile['user_id']?.toString() ?? name,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0, 0.38, 1],
                ),
              ),
            ),
            // ── Bottom layers (painted before BackdropFilter) ──────────────
            if (widget.dragProgress > 0.02)
              Positioned(
                top: 110,
                left: widget.swipeDirection > 0 ? null : 22,
                right: widget.swipeDirection > 0 ? 22 : null,
                child: Opacity(
                  opacity: widget.dragProgress.clamp(0.0, 0.95).toDouble(),
                  child: _SwipeHintBadge(
                    label: widget.swipeDirection > 0 ? 'LIKE' : 'PASS',
                    color:
                        widget.swipeDirection > 0 ? _actionPurple : _actionRed,
                  ),
                ),
              ),
            // Bottom info — BackdropFilter blurs only image + gradient above
            Positioned(
              left: 18,
              right: 18,
              bottom: 112,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withValues(alpha: 0.22),
                  border: Border.all(color: _subtleBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$name, ${widget.age}',
                              style: const TextStyle(
                                color: _white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                          ),
                          if (verified)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF60A5FA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: _white,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: _white.withValues(alpha: 0.92),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                      ],
                      if (chips.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: chips
                              .map(
                                (chip) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _white.withValues(alpha: 0.24),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _white.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    chip,
                                    style: const TextStyle(
                                      color: _white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 22,
              child: _DiscoveryActions(
                disabled: widget.disabled,
                onRewind: widget.onRewind,
                onPass: widget.onPass,
                onLike: widget.onLike,
                onBoost: widget.onBoost,
              ),
            ),
            // ── Top overlay (painted AFTER BackdropFilter — never blurred) ─
            const Positioned(
              top: 76,
              left: 16,
              child: _LivePill(),
            ),
            // Heading pill — centered, independent, above BackdropFilter layer
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _white.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: const Text(
                    'Discover your vibe',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: Color(0xCC000000),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: _TopOverlayButton(
                icon: FontAwesomeIcons.sliders,
                onTap: () {},
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: _TopOverlayButton(
                icon: FontAwesomeIcons.bell,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildChips({
    required String city,
    required String bio,
  }) {
    final chips = <String>[];
    if (city.isNotEmpty) {
      chips.add(city.toUpperCase());
    }
    for (final token in bio.split(RegExp(r'[\s,.;:!?-]+'))) {
      final clean = token.trim();
      if (clean.length >= 4) {
        chips.add(clean.toUpperCase());
      }
      if (chips.length == 3) break;
    }
    return chips.take(3).toList();
  }
}

class _SwipeHintBadge extends StatelessWidget {
  const _SwipeHintBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: label == 'LIKE' ? 0.14 : -0.14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 2.5),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ProfileImageLayer extends StatelessWidget {
  const _ProfileImageLayer({
    required this.photoUrl,
    required this.seed,
  });

  final String? photoUrl;
  final String seed;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _FallbackDiscoveryImage(seed: seed),
        errorWidget: (_, __, ___) => _FallbackDiscoveryImage(seed: seed),
      );
    }

    return _FallbackDiscoveryImage(seed: seed);
  }
}

class _FallbackDiscoveryImage extends StatelessWidget {
  const _FallbackDiscoveryImage({
    required this.seed,
  });

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://picsum.photos/seed/$seed/900/1400',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1F2937),
                  Color(0xFF6B4F3F),
                  Color(0xFFC08457),
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.2,
              colors: [
                Color(0x22FFFFFF),
                Color(0x00000000),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopOverlayButton extends StatelessWidget {
  const _TopOverlayButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            shape: BoxShape.circle,
            border: Border.all(color: _white.withValues(alpha: 0.18)),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16,
              color: _white.withValues(alpha: 0.92),
            ),
          ),
        ),
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF60A5FA),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'LIVE',
            style: TextStyle(
              color: _white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryActions extends StatelessWidget {
  const _DiscoveryActions({
    required this.disabled,
    required this.onRewind,
    required this.onPass,
    required this.onLike,
    required this.onBoost,
  });

  final bool disabled;
  final VoidCallback onRewind;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _DiscoveryActionButton(
          icon: Icons.replay_rounded,
          iconColor: _actionBlueGray,
          borderColor: _actionBlueGray.withValues(alpha: 0.7),
          onTap: disabled ? null : onRewind,
        ),
        _DiscoveryActionButton(
          icon: Icons.close_rounded,
          iconColor: _actionRed,
          borderColor: _actionRed.withValues(alpha: 0.7),
          onTap: disabled ? null : onPass,
        ),
        _DiscoveryActionButton(
          icon: Icons.favorite_rounded,
          iconColor: _white,
          fillColor: _actionPurple,
          isPrimary: true,
          onTap: disabled ? null : onLike,
        ),
        _DiscoveryActionButton(
          icon: Icons.star_rounded,
          iconColor: _actionPink,
          borderColor: _actionPink.withValues(alpha: 0.9),
          onTap: disabled ? null : onBoost,
        ),
      ],
    );
  }
}

class _DiscoveryActionButton extends StatefulWidget {
  const _DiscoveryActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.borderColor,
    this.fillColor = _white,
    this.isPrimary = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final Color fillColor;
  final VoidCallback? onTap;
  final bool isPrimary;

  @override
  State<_DiscoveryActionButton> createState() => _DiscoveryActionButtonState();
}

class _DiscoveryActionButtonState extends State<_DiscoveryActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isPrimary ? 82.0 : 66.0;
    final iconSize = widget.isPrimary ? 30.0 : 26.0;

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: widget.fillColor,
            shape: BoxShape.circle,
            border: widget.borderColor == null
                ? null
                : Border.all(color: widget.borderColor!, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: widget.isPrimary
                    ? _actionPurple.withValues(alpha: 0.26)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: widget.isPrimary ? 20 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
