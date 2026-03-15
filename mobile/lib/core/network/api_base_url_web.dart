// ignore: deprecated_member_use
import 'dart:html' as html;

String getFallbackBaseUrl() {
  try {
    final localMeta = html.document.querySelector('meta[name="datox-backend-local"]');
    final useLocal = localMeta?.getAttribute('content')?.toLowerCase() == 'true';
    if (useLocal) {
      return 'http://localhost:8080/api/v1';
    }
    final apiMeta = html.document.querySelector('meta[name="datox-api-base"]');
    final content = apiMeta?.getAttribute('content');
    if (content != null && content.trim().isNotEmpty) {
      return content.trim();
    }
  } catch (_) {}
  return 'http://localhost:8080/api/v1';
}
