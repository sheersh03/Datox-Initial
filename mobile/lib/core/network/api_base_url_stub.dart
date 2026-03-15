import 'dart:io';

import 'package:flutter/foundation.dart';

String getFallbackBaseUrl() {
  if (kIsWeb) return 'http://localhost:8080/api/v1';
  if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
  return 'http://localhost:8080/api/v1';
}
