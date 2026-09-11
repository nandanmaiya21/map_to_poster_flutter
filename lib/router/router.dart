import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/bloc/generate_map/generate_map_cubit.dart';
import 'package:map_to_poster/bloc/layout/layout_cubit.dart';
import 'package:map_to_poster/bloc/render_map/render_map_cubit.dart';
import 'package:map_to_poster/bloc/theme/theme_cubit.dart';
import 'package:map_to_poster/bloc/create_project/create_project_cubit.dart';
import 'package:map_to_poster/bloc/location/location_cubit.dart';
import 'package:map_to_poster/data/global_key/global_key.dart';
import 'package:map_to_poster/data/models/location_result.dart';
import 'package:map_to_poster/data/models/project_entry.dart';
import 'package:map_to_poster/repository/repository.dart';
import 'package:map_to_poster/router/route_names.dart';
import 'package:map_to_poster/screens/generate_map_screen.dart';
import 'package:map_to_poster/screens/layout_selection.dart';
import 'package:map_to_poster/screens/render_poster_screen.dart';
import 'package:map_to_poster/screens/theme_selection.dart';
import 'package:map_to_poster/services/location_service.dart';
import 'package:map_to_poster/shared/layout/app_shell.dart';

class AppRouter {
  static Route<dynamic> _animatedRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('ERROR')),
        );
      },
    );
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Define your routes here
      // case '/':
      //   return _animatedRoute(HomePage());
      // case '/details':
      //   return _animatedRoute(DetailsPage());
      case RouteNames.home:
        return _animatedRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => LocationCubit(
                  repository: Repository(),
                  locationService: LocationService(),
                ),
              ),
              BlocProvider.value(value: appShellCubit),
            ],
            child: const AppShell(),
          ),
        );
      case RouteNames.themeSelection:
        final project = settings.arguments as ProjectEntry;
        return _animatedRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CreateProjectCubit(project: project),
              ),
              BlocProvider(
                create: (context) =>
                    ThemeCubit(repository: Repository())..loadThemes(),
              ),
            ],
            child: const ThemeSelectionScreen(),
          ),
        );
      case RouteNames.layoutSelection:
        final createProjectCubit = settings.arguments as CreateProjectCubit;
        return _animatedRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: createProjectCubit),
              BlocProvider(create: (context) => LayoutCubit()),
            ],
            child: const LayoutSelectionScreen(),
          ),
        );
      case RouteNames.generateMap:
        final location = settings.arguments as LocationResult;
        return _animatedRoute(
          BlocProvider(
            create: (context) => GenerateMapCubit(repository: Repository()),
            child: GenerateMapScreen(location: location),
          ),
        );
      case RouteNames.renderPoster:
        final project = settings.arguments as ProjectEntry;
        return _animatedRoute(
          BlocProvider(
            create: (context) => RenderMapCubit(
              repository: Repository(),
              mapId: project.mapId,
              theme: project.themeSlug,
              title: project.posterTitle,
              subtitle: project.posterSubtitle,
              coordinates: project.posterCoordinates,
              layout: project.posterLayout.name,
            ),
            child: const RenderPosterScreen(),
          ),
        );
      default:
        return _errorRoute();
    }
  }
}
