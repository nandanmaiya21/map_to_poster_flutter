import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/bloc/app_shell/app_shell_cubit.dart';
import 'package:map_to_poster/bloc/location/location_cubit.dart';

import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/screens/create_screen.dart';
import 'package:map_to_poster/screens/home_screen.dart';
import 'package:map_to_poster/screens/project_screen.dart';
import 'package:map_to_poster/shared/navigation/app_bottom_navigation.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  Widget _getPage(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const HomePage(key: ValueKey('home'));

      case 1:
        return const CreateScreen(key: ValueKey('create'));

      case 2:
        return const ProjectsPage(key: ValueKey('projects'));

      default:
        return const HomePage(key: ValueKey('home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellCubit, AppShellState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,

          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            reverseDuration: const Duration(milliseconds: 200),

            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,

            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },

            child: _getPage(state.currentIndex),
          ),

          bottomNavigationBar: AppBottomNavigation(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<AppShellCubit>().updateIndex(index);
              context.read<LocationCubit>().selectLocation(null);
            },
          ),
        );
      },
    );
  }
}
