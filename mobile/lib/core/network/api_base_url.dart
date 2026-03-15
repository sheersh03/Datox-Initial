import 'api_base_url_stub.dart' if (dart.library.html) 'api_base_url_web.dart' as _impl;

/// Resolves the API base URL. Web reads from window.DATOX_API_BASE (set in index.html).
/// Mobile uses dart-define or platform defaults.
String getApiBaseUrl() {
  const configured = String.fromEnvironment('API_BASE_URL');
  if (configured.isNotEmpty) return configured;
  return _impl.getFallbackBaseUrl();
}
