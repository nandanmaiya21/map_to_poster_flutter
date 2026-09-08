import 'package:flutter/material.dart';
import 'package:map_to_poster/constants/api_consatant.dart';
import 'package:map_to_poster/core/theme/app_theme.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConstants.loadEnv();
  runApp(MyApp(router: AppRouter(), initialRoute: RouteNames.home));
}

class MyApp extends StatelessWidget {
  final AppRouter router;
  final String initialRoute;
  const MyApp({super.key, required this.router, required this.initialRoute});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      title: 'Map to Poster',
      theme: AppTheme.theme,
    );
  }
}
