import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const _pageBg = Color(0xFFF5F5F2);
const _cardBg = Colors.white;
const _textPrimary = Color(0xFF1F1F1F);
const _textSecondary = Color(0xFF5F5F5F);
const _chipBg = Color(0xFFF0F0F0);
const _border = Color(0xFFEAEAEA);
const _actionPurple = Color(0xFF6D4CFF);
const _actionPink = Color(0xFFF59AD9);
const _actionRed = Color(0xFFFF7A7A);
const _reportRed = Color(0xFFD84A35);

Future<void> showDiscoveryProfileDetailSheet(
  BuildContext context, {
  required Map<String, dynamic> profile,
  required int age,
  required dynamic distance,
  required VoidCallback onPass,
  required VoidCallback onLike,
  required VoidCallback onBoost,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _ProfileDetailScreen(
        profile: profile,
        age: age,
        distance: distance,
        onPass: onPass,
        onLike: onLike,
        onBoost: onBoost,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
    ),
  );
}

class _ProfileDetailScreen extends StatelessWidget {
  const _ProfileDetailScreen({
    required this.profile,
    required this.age,
    required this.distance,
    required this.onPass,
    required this.onLike,
    required this.onBoost,
  });

  final Map<String, dynamic> profile;
  final int age;
  final dynamic distance;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    final name = (profile['name'] ?? 'Unknown').toString();
    final city = (profile['city'] ?? '').toString();
    final bio = (profile['bio'] ?? '').toString();
    final gender = (profile['gender'] ?? '').toString();
    final intent = (profile['intent'] ?? '').toString();
    final verified = profile['verification_status'] == 'verified';
    final interestChips = _buildInterestChips(city: city, bio: bio);
    final aboutChips = _buildAboutChips(
      gender: gender,
      intent: intent,
      verified: verified,
    );

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Discover',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PhotoCard(
                      profile: profile,
                      name: name,
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '$name, $age',
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ),
                          if (verified)
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFF60A5FA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'My bio',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bio,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 17,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _ComplimentButton(isDark: false),
                          ],
                        ),
                      ),
                    ],
                    if (aboutChips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'About me',
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: aboutChips
                              .map((chip) => _InfoChip(label: chip))
                              .toList(),
                        ),
                      ),
                    ],
                    if (city.isNotEmpty || distance != null) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'My location',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: _textPrimary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (city.isNotEmpty)
                                        Text(
                                          city,
                                          style: const TextStyle(
                                            color: _textPrimary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            height: 1.1,
                                          ),
                                        ),
                                      if (distance != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '${distance.toString()} km away',
                                            style: const TextStyle(
                                              color: _textSecondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (city.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _InfoChip(label: 'Lives in $city'),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (intent.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: "I'm looking for",
                        child: _InfoChip(label: _intentLabel(intent)),
                      ),
                    ],
                    if (interestChips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'My interests',
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: interestChips
                              .map((chip) => _InfoChip(label: chip))
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.close_rounded,
                          background: Colors.white,
                          iconColor: _actionRed,
                          borderColor: _actionRed.withValues(alpha: 0.75),
                          onTap: () => _runAction(context, onPass),
                        ),
                        _ActionButton(
                          icon: Icons.favorite_rounded,
                          background: _actionPurple,
                          iconColor: Colors.white,
                          isPrimary: true,
                          onTap: () => _runAction(context, onLike),
                        ),
                        _ActionButton(
                          icon: Icons.star_rounded,
                          background: Colors.white,
                          iconColor: _actionPink,
                          borderColor: _actionPink.withValues(alpha: 0.9),
                          onTap: () => _runAction(context, onBoost),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: _textSecondary,
                      ),
                      child: const Text(
                        'Block',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: _reportRed,
                      ),
                      child: const Text(
                        'Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runAction(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      action();
    });
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.profile,
    required this.name,
  });

  final Map<String, dynamic> profile;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 0.82,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _DetailPhotoLayer(
                photoUrl: profile['primary_photo_url'] as String?,
                seed: profile['user_id']?.toString() ?? name,
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: const _ComplimentButton(isDark: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ComplimentButton extends StatelessWidget {
  const _ComplimentButton({
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final background = isDark
        ? Colors.black.withValues(alpha: 0.42)
        : _chipBg;
    final foreground = isDark ? Colors.white : _textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, color: foreground, size: 18),
          const SizedBox(width: 8),
          Icon(Icons.favorite_border_rounded, color: foreground, size: 18),
          const SizedBox(width: 8),
          Text(
            'Compliment',
            style: TextStyle(
              color: foreground,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.borderColor,
    this.isPrimary = false,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? borderColor;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final size = isPrimary ? 78.0 : 68.0;
    final iconSize = isPrimary ? 34.0 : 30.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 2.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x17000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            color: _textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DetailPhotoLayer extends StatelessWidget {
  const _DetailPhotoLayer({
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
        memCacheWidth: 1600,
        placeholder: (_, __) => _DetailFallbackImage(seed: seed),
        errorWidget: (_, __, ___) => _DetailFallbackImage(seed: seed),
      );
    }
    return _DetailFallbackImage(seed: seed);
  }
}

class _DetailFallbackImage extends StatelessWidget {
  const _DetailFallbackImage({
    required this.seed,
  });

  final String seed;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://picsum.photos/seed/$seed/1200/1800',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFECE5D8),
              Color(0xFFD6C4A5),
              Color(0xFFF1E6D2),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _buildAboutChips({
  required String gender,
  required String intent,
  required bool verified,
}) {
  final chips = <String>[];
  if (gender.isNotEmpty) {
    chips.add(_titleize(gender));
  }
  if (intent.isNotEmpty) {
    chips.add(_intentLabel(intent));
  }
  if (verified) {
    chips.add('Verified profile');
  }
  return chips;
}

List<String> _buildInterestChips({
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
    if (chips.length == 4) break;
  }
  return chips.take(4).toList();
}

String _titleize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

String _intentLabel(String intent) {
  switch (intent.toLowerCase()) {
    case 'dating':
      return 'Dating';
    case 'friends':
      return 'Friends';
    case 'marriage':
      return 'A long-term relationship';
    default:
      return _titleize(intent);
  }
}
