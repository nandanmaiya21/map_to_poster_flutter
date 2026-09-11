import 'package:flutter/material.dart';
import 'package:map_to_poster/bloc/app_shell/app_shell_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Lives for the app's lifetime so screens pushed outside the home route's
// widget subtree (e.g. after generating a poster) can switch bottom-nav
// tabs without needing a BuildContext inside that subtree.
final AppShellCubit appShellCubit = AppShellCubit();
