import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static Future<void> loadEnv() async {
    await dotenv.load(fileName: "assets/env/.env");
  }

  static String getBaseUrl() {
    return dotenv.get("BASEURL", fallback: "http://10.0.2.2:8080");
  }

  static String getOpenStreetMapBaseUrl() {
    return dotenv.get(
      "OPENSTREETBASEURL",
      fallback: "https://nominatim.openstreetmap.org/search",
    );
  }
}
