import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _cardBg = Color(0xFFFFFFFF);
const _primaryBlue = Color(0xFF3A86FF);
const _accentPink = Color(0xFFFFE6F0);
const _subtext = Color(0xFF6B7280);

/// Reusable subscription plan card.
class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.badge,
    required this.description,
    required this.price,
    required this.onTap,
    this.isSelected = false,
    this.isActive = false,
    this.isLoading = false,
  });

  final String badge;
  final String description;
  final String price;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _primaryBlue : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _accentPink.withValues(alpha: 0.6)
                            : _subtext.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _primaryBlue : _subtext,
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      const FaIcon(
                        FontAwesomeIcons.circleCheck,
                        size: 16,
                        color: _primaryBlue,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _subtext,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isLoading ? null : onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isActive ? 'Active' : 'Subscribe · $price',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
