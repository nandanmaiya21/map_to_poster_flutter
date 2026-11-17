import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static Future<void> loadEnv() async {
    await dotenv.load(fileName: "assets/env/.env");
  }

  static String getBaseUrl() {
    // A browser can't reach the Android-emulator host alias (10.0.2.2),
    // so the web build has its own setting. Mobile is unchanged.
    if (kIsWeb) {
      return dotenv.get("WEB_BASEURL", fallback: "http://localhost:8080");
    }
    return dotenv.get("BASEURL", fallback: "http://10.0.2.2:8080");
  }

  static String getOpenStreetMapBaseUrl() {
    return dotenv.get(
      "OPENSTREETBASEURL",
      fallback: "https://nominatim.openstreetmap.org/search",
    );
  }

  // Poster-service serves rendered files (e.g. "/exports/foo.png") relative
  // to its own root; nginx exposes that root at "/api/posters/".
  static String posterAssetUrl(String path) {
    return "${getBaseUrl()}/api/posters$path";
  }
}
