import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../addons/addon_controller.dart';
import '../../paywall/ui/pay_plan_tab.dart';
import '../data/profile_api.dart';

const _bg = Color(0xFFF4F8FF);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);
const _primaryBlue = Color(0xFF3A86FF);
const _accentPink = Color(0xFFFFE6F0);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  int _selectedTabIndex = 0;
  final _addonController = AddonController();

  static const _tabs = [
    'Pay plan',
    'Dating advice',
    'Photo insights',
    'Safety and wellbeing',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await ProfileApi.getMe();
      if (mounted) {
        setState(() {
          _profile = p;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  int _completionPercent() {
    if (_profile == null) return 0;
    var filled = 0;
    const total = 6;
    if ((_profile!['name'] ?? '').toString().isNotEmpty) filled++;
    if (_profile!['birth_year'] != null) filled++;
    if ((_profile!['bio'] ?? '').toString().isNotEmpty) filled++;
    if ((_profile!['city'] ?? '').toString().isNotEmpty) filled++;
    if (_profile!['photos'] != null &&
        (_profile!['photos'] as List).isNotEmpty) filled++;
    if (_profile!['verification_status'] == 'verified') filled++;
    return (filled / total * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.circleQuestion, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.gear, size: 20),
            onPressed: () => context.go('/profile-setup'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            _buildTabs(),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final name = _profile?['name'] ?? 'Profile';
    final birthYear = _profile?['birth_year'] ?? 2000;
    final age = DateTime.now().year - birthYear;
    final percent = _completionPercent();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: _accentPink.withValues(alpha: 0.5),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: _primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$age years',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _subtext,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: _subtext.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(_primaryBlue),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _subtext,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Profile completion',
                  style: TextStyle(
                    fontSize: 11,
                    color: _subtext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(
          _tabs.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_tabs[i]),
              selected: _selectedTabIndex == i,
              onSelected: (selected) {
                if (selected) setState(() => _selectedTabIndex = i);
              },
              selectedColor: _accentPink.withValues(alpha: 0.6),
              labelStyle: TextStyle(
                color: _selectedTabIndex == i ? _primaryBlue : _subtext,
                fontWeight:
                    _selectedTabIndex == i ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return PayPlanTab(addonController: _addonController);
      case 1:
        return _placeholderContent('Dating advice');
      case 2:
        return _placeholderContent('Photo insights');
      case 3:
        return _placeholderContent('Safety and wellbeing');
      default:
        return PayPlanTab(addonController: _addonController);
    }
  }

  Widget _placeholderContent(String title) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Text(
          '$title coming soon.',
          style: const TextStyle(color: _subtext),
        ),
      ),
    );
  }
}
