import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_errors.dart';
import '../../../core/widgets/cypher_logo.dart';
import '../data/cypher_api.dart';
import '../data/cypher_avatars.dart';

const _bg = Color(0xFFF4F8FF);
const _cypherGradientStart = Color(0xFF111827);
const _cypherGradientMid = Color(0xFF312E81);
const _cypherGradientEnd = Color(0xFF6D28D9);
const _white = Colors.white;
const _textPrimary = Color(0xFF1F1F1F);
const _textSecondary = Color(0xFF5F5F5F);
const _actionPurple = Color(0xFF6D4CFF);
const _actionRed = Color(0xFFFF7A7A);

class CypherScreen extends StatefulWidget {
  const CypherScreen({super.key});

  @override
  State<CypherScreen> createState() => _CypherScreenState();
}

class _CypherScreenState extends State<CypherScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  bool _showPaywall = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    setState(() {
      _loading = true;
      _error = null;
      _showPaywall = false;
    });
    try {
      await CypherApi.checkEntitlement();
      if (!mounted) return;
      final profile = await CypherApi.getProfile();
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.error is ApiException) {
        final apiErr = e.error as ApiException;
        if (apiErr.statusCode == 402 && apiErr.code == 'CYPHER_PAYWALL') {
          setState(() {
            _showPaywall = true;
            _loading = false;
          });
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

  void _onProfileCreated() {
    _checkAccess();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _cypherGradientEnd)),
      );
    }

    if (_showPaywall) {
      return _CypherPaywallTeaser(onUpgrade: () => context.push('/paywall?context=cypher'));
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _checkAccess,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_profile == null) {
      return _CypherOnboardingScreen(
        onComplete: _onProfileCreated,
      );
    }

    return _CypherDiscoveryScreen(profile: _profile!);
  }
}

class _CypherPaywallTeaser extends StatelessWidget {
  const _CypherPaywallTeaser({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_cypherGradientStart, _cypherGradientMid, _cypherGradientEnd],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CypherLogo(color: _white, size: 48),
                  const SizedBox(height: 20),
                  Text(
                    'Cypher Mode',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore deeper interests, fantasies, and curiosities through anonymous avatars. Match on compatibility before revealing who you are.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _white.withValues(alpha: 0.92),
                          height: 1.4,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _white.withValues(alpha: 0.14)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.circleCheck, color: _white, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Anonymous avatars',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.circleCheck, color: _white, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Interest-based discovery',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.circleCheck, color: _white, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Consent-based reveal',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: onUpgrade,
                      style: FilledButton.styleFrom(
                        backgroundColor: _white,
                        foregroundColor: _cypherGradientEnd,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Upgrade to Plus to unlock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CypherOnboardingScreen extends StatefulWidget {
  const _CypherOnboardingScreen({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_CypherOnboardingScreen> createState() => _CypherOnboardingScreenState();
}

class _CypherOnboardingScreenState extends State<_CypherOnboardingScreen> {
  int _step = 0;
  String _avatarId = cypherAvatarIds.first;
  final _usernameController = TextEditingController();
  final _headlineController = TextEditingController();
  List<String> _interestTags = [];
  bool _saving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _headlineController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    if (username.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a username (2+ characters)')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await CypherApi.upsertProfile(
        avatarId: _avatarId,
        anonymousUsername: username,
        headline: _headlineController.text.trim().isEmpty
            ? null
            : _headlineController.text.trim(),
        interestTags: _interestTags,
      );
      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return _buildWelcomeStep();
    }
    if (_step == 1) {
      return _buildAvatarStep();
    }
    return _buildProfileStep();
  }

  Widget _buildWelcomeStep() {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: CypherLogo(color: _cypherGradientEnd, size: 80)),
              const SizedBox(height: 24),
              Text(
                'Welcome to Cypher',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create your anonymous identity. Choose an avatar, pick a username, and share your interests. No photos, no pressure—just curiosity.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => setState(() => _step = 1),
                style: FilledButton.styleFrom(
                  backgroundColor: _cypherGradientEnd,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarStep() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Choose avatar'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pick an avatar that represents you. No one will see your real photo here.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _textSecondary),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: cypherAvatarIds.length,
                itemBuilder: (context, index) {
                  final id = cypherAvatarIds[index];
                  final color = Color(cypherAvatarColors[index]);
                  final isSelected = _avatarId == id;
                  return GestureDetector(
                    onTap: () => setState(() => _avatarId = id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? _cypherGradientEnd : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: CypherLogo(
                          color: isSelected ? _cypherGradientEnd : color,
                          size: 36,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: () => setState(() => _step = 2),
              style: FilledButton.styleFrom(
                backgroundColor: _cypherGradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStep() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Your Cypher profile'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Anonymous username',
                hintText: 'e.g. curious_owl',
                border: OutlineInputBorder(),
              ),
              maxLength: 30,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _headlineController,
              decoration: const InputDecoration(
                labelText: 'Headline (optional)',
                hintText: 'A short line about what you\'re curious about',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text(
              'Add interest tags (optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['curious', 'playful', 'slow burn', 'conversation', 'exploration']
                  .map((tag) {
                final isSelected = _interestTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _interestTags.add(tag);
                      } else {
                        _interestTags.remove(tag);
                      }
                    });
                  },
                );
              })
                  .toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _saveProfile,
              style: FilledButton.styleFrom(
                backgroundColor: _cypherGradientEnd,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _white),
                    )
                  : const Text('Create profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CypherDiscoveryScreen extends StatefulWidget {
  const _CypherDiscoveryScreen({required this.profile});

  final Map<String, dynamic> profile;

  @override
  State<_CypherDiscoveryScreen> createState() => _CypherDiscoveryScreenState();
}

class _CypherDiscoveryScreenState extends State<_CypherDiscoveryScreen> {
  List<dynamic> _candidates = [];
  int _index = 0;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await CypherApi.getCandidates();
      if (mounted) {
        setState(() {
          _candidates = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _react(bool isLike) async {
    if (_submitting || _candidates.isEmpty || _index >= _candidates.length) return;
    final c = _candidates[_index] as Map<String, dynamic>;
    final toUserId = c['user_id'] as String? ?? '';
    setState(() => _submitting = true);
    try {
      final result = await CypherApi.react(toUserId: toUserId, isLike: isLike);
      if (!mounted) return;
      setState(() {
        _index++;
        _submitting = false;
      });
      if (result['matched'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('It\'s a match!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _cypherGradientEnd)),
      );
    }

    if (_candidates.isEmpty || _index >= _candidates.length) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: const Text('Cypher'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CypherLogo(color: _cypherGradientEnd, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No one new right now',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for more anonymous matches.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final candidate = _candidates[_index] as Map<String, dynamic>;
    final avatarId = candidate['avatar_id'] as String? ?? 'avatar_1';
    final username = (candidate['anonymous_username'] ?? 'Anonymous').toString();
    final headline = (candidate['headline'] ?? '').toString();
    final tags = (candidate['interest_tags'] as List?)?.cast<String>() ?? [];
    final sharedCount = candidate['shared_count'] as int? ?? 0;

    final avatarIndex = cypherAvatarIds.indexOf(avatarId);
    final avatarColor = avatarIndex >= 0
        ? Color(cypherAvatarColors[avatarIndex])
        : const Color(0xFF6D28D9);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Cypher'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      avatarColor.withValues(alpha: 0.3),
                      avatarColor.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      CypherLogo(color: avatarColor, size: 100),
                      const SizedBox(height: 20),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: _textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (headline.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          headline,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: tags
                              .map((t) => Chip(
                                    label: Text(t, style: const TextStyle(fontSize: 12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ))
                              .toList(),
                        ),
                      ],
                      if (sharedCount > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          '$sharedCount shared interests',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _cypherGradientEnd,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: FontAwesomeIcons.xmark,
                  color: _actionRed,
                  onTap: () => _react(false),
                  disabled: _submitting,
                ),
                const SizedBox(width: 32),
                _ActionButton(
                  icon: FontAwesomeIcons.solidHeart,
                  color: _actionPurple,
                  onTap: () => _react(true),
                  disabled: _submitting,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: disabled ? 0.4 : 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}
