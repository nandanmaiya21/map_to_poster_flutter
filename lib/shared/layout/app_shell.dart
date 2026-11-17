import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_to_poster/bloc/app_shell/app_shell_cubit.dart';
import 'package:map_to_poster/bloc/location/location_cubit.dart';

import 'package:map_to_poster/core/responsive/responsive.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/screens/create_screen.dart';
import 'package:map_to_poster/screens/home_screen.dart';
import 'package:map_to_poster/screens/project_screen.dart';
import 'package:map_to_poster/shared/navigation/app_bottom_navigation.dart';
import 'package:map_to_poster/shared/navigation/app_side_navigation.dart';

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

  void _onNavigate(BuildContext context, int index) {
    context.read<AppShellCubit>().updateIndex(index);
    context.read<LocationCubit>().selectLocation(null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellCubit, AppShellState>(
      builder: (context, state) {
        final screenSize = Responsive.of(context);
        final pages = _buildPages(state.currentIndex);

        // Wide web windows: side navigation instead of the bottom bar.
        if (screenSize == ScreenSize.expanded) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                AppSideNavigation(
                  currentIndex: state.currentIndex,
                  onTap: (index) => _onNavigate(context, index),
                ),
                Expanded(child: pages),
              ],
            ),
          );
        }

        final bottomNavigation = AppBottomNavigation(
          currentIndex: state.currentIndex,
          onTap: (index) => _onNavigate(context, index),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: pages,
          // Medium web windows: same bar, centred at a sensible width.
          bottomNavigationBar: screenSize == ScreenSize.medium
              ? Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: bottomNavigation,
                  ),
                )
              : bottomNavigation,
        );
      },
    );
  }

  Widget _buildPages(int currentIndex) {
    return AnimatedSwitcher(
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

      child: _getPage(currentIndex),
    );
  }
}
