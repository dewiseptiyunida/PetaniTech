import 'package:flutter/foundation.dart';

// URL backend lokal Petanitech (Go API):
// - Web / Chrome: http://localhost:8080/api/v1
// - Android Emulator: http://10.0.2.2:8080/api/v1
// - Lainnya / Desktop: http://localhost:8080/api/v1
String get appUrl {
  if (kIsWeb) {
    return "http://localhost:8080/api/v1";
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return "http://10.0.2.2:8080/api/v1";
  } else {
    return "http://localhost:8080/api/v1";
  }
}

final String appName = "Petanitech";

