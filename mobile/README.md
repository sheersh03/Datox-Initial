# datox

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

folder Structure : (temporarily added in this file, will be fixed further)

lib/
├── main.dart
├── app.dart
├── config/
│   └── env.dart
├── core/
│   ├── analytics/
│   │   └── analytics.dart
│   ├── crash/
│   │   └── crash_reporter.dart
│   ├── navigation/
│   │   ├── main_navigation_shell.dart
│   │   ├── bottom_nav_bar.dart
│   │   └── navigation_service.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_errors.dart
│   │   └── interceptors.dart
│   ├── storage/
│   │   └── secure_store.dart
│   └── widgets/
│       ├── datox_button.dart
│       ├── datox_card.dart
│       ├── datox_chip.dart
│       ├── datox_input.dart
│       ├── empty_state.dart
│       └── skeleton.dart
├── features/
│   ├── admin/
│   │   └── ui/
│   │       └── admin_reports_screen.dart
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_api.dart
│   │   │   └── auth_repo.dart
│   │   ├── domain/
│   │   │   └── auth_state.dart
│   │   └── ui/
│   │       ├── login_screen.dart
│   │       ├── otp_verify_screen.dart
│   │       ├── phone_entry_screen.dart
│   │       ├── phone_login_screen.dart
│   │       └── widgets/
│   │           └── social_login_button.dart
│   ├── chat/
│   │   ├── data/
│   │   │   └── chat_api.dart
│   │   ├── domain/
│   │   │   └── chat_controller.dart
│   │   └── ui/
│   │       ├── chat_list_screen.dart
│   │       └── chat_screen.dart
│   ├── discovery/
│   │   ├── data/
│   │   │   └── discovery_api.dart
│   │   ├── domain/
│   │   │   └── discovery_controller.dart
│   │   └── ui/
│   │       ├── discovery_screen.dart
│   │       └── profile_detail_sheet.dart
│   ├── likes/
│   │   └── ui/
│   │       └── likes_screen.dart
│   ├── location/
│   │   ├── data/
│   │   │   └── location_repository.dart
│   │   ├── domain/
│   │   │   └── location_service.dart
│   │   └── ui/
│   │       └── location_permission_screen.dart
│   ├── matches/
│   │   ├── data/
│   │   │   └── matches_api.dart
│   │   └── ui/
│   │       └── matches_screen.dart
│   ├── onboarding/
│   │   └── ui/
│   │       ├── photo_upload_screen.dart
│   │       ├── profile_setup_screen.dart
│   │       ├── prompts_screen.dart
│   │       └── verification_screen.dart
│   ├── passkey/
│   │   ├── data/
│   │   │   └── passkey_repository.dart
│   │   ├── domain/
│   │   │   └── passkey_service.dart
│   │   └── ui/
│   │       └── create_passkey_screen.dart
│   ├── paywall/
│   │   ├── data/
│   │   │   └── revenuecat_service.dart
│   │   └── ui/
│   │       ├── entitlement_badge.dart
│   │       └── paywall_screen.dart
│   ├── profile/
│   │   ├── data/
│   │   │   └── profile_api.dart
│   │   └── ui/
│   │       └── profile_screen.dart
│   └── safety/
│       └── ui/
│           ├── block_confirm_sheet.dart
│           ├── community_guidelines_screen.dart
│           └── report_screen.dart
├── routing/
│   ├── guards.dart
│   └── router.dart
└── theme/
    ├── datox_theme.dart
    └── tokens.dart
