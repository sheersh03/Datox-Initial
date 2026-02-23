/// Add-on types. Extensible for future additions.
enum AddonType {
  spotlight,
  superSwipe,
  boost,
  compliment,
  extend,
  rematch,
  backtrack,
  travelMode,
  incognito,
}

extension AddonTypeExt on AddonType {
  /// API/server string identifier.
  String get value {
    switch (this) {
      case AddonType.spotlight:
        return 'spotlight';
      case AddonType.superSwipe:
        return 'super_swipe';
      case AddonType.boost:
        return 'boost';
      case AddonType.compliment:
        return 'compliment';
      case AddonType.extend:
        return 'extend';
      case AddonType.rematch:
        return 'rematch';
      case AddonType.backtrack:
        return 'backtrack';
      case AddonType.travelMode:
        return 'travel_mode';
      case AddonType.incognito:
        return 'incognito';
    }
  }

  /// Display name.
  String get displayName {
    switch (this) {
      case AddonType.spotlight:
        return 'Spotlight';
      case AddonType.superSwipe:
        return 'SuperSwipe';
      case AddonType.boost:
        return 'Boost';
      case AddonType.compliment:
        return 'Compliments';
      case AddonType.extend:
        return 'Extends';
      case AddonType.rematch:
        return 'Rematch';
      case AddonType.backtrack:
        return 'Backtrack';
      case AddonType.travelMode:
        return 'Travel Mode';
      case AddonType.incognito:
        return 'Incognito';
    }
  }

  /// Whether this add-on uses a consumable count (vs time-based).
  bool get isConsumable {
    switch (this) {
      case AddonType.spotlight:
      case AddonType.travelMode:
      case AddonType.incognito:
        return false;
      case AddonType.superSwipe:
      case AddonType.boost:
      case AddonType.compliment:
      case AddonType.extend:
      case AddonType.rematch:
      case AddonType.backtrack:
        return true;
    }
  }
}
