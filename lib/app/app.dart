import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_assignment/services/connectivity_checker.dart';
import 'package:task_manager_assignment/themes/app_theme.dart';
import 'package:task_manager_assignment/themes/theme_changer.dart';
import 'package:task_manager_assignment/utils/app_routes.dart';
import 'package:task_manager_assignment/utils/app_strings.dart';
import 'package:task_manager_assignment/viewModels/auth_view_model.dart';
import 'package:task_manager_assignment/viewModels/countdown_timer_view_model.dart';
import 'package:task_manager_assignment/viewModels/dashboard_view_model.dart';
import 'package:task_manager_assignment/viewModels/task_view_model.dart';
import 'package:task_manager_assignment/viewModels/user_view_model.dart';


class TaskManager extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final String userTheme;

  const TaskManager({super.key, required this.userTheme});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => CountdownTimerViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeChanger()),
        ChangeNotifierProvider(create: (_) => ConnectivityChecker()),
      ],
      child: Builder(builder: (context) {
        if (!context.read<ThemeChanger>().isAppLaunched) {
          loadUserTheme(userTheme, context);
        }
        context.read<ThemeChanger>().setIsAppLaunched = true;
        context.read<ConnectivityChecker>().initConnectivityChecker();
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashScreen,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          onGenerateRoute: (routeSettings) {
            return AppRoutes.generateRoute(routeSettings);
          },
          themeMode: context.watch<ThemeChanger>().themeMode,
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
        );
      }),
    );
  }

  void loadUserTheme(String theme, BuildContext context) {
    switch (theme) {
      case AppStrings.darkMode:
        context.read<ThemeChanger>().setThemeModeSilent = ThemeMode.dark;

      case AppStrings.lightMode:
        context.read<ThemeChanger>().setThemeModeSilent = ThemeMode.light;

      case AppStrings.systemMode:
        context.read<ThemeChanger>().setThemeModeSilent = ThemeMode.system;
    }
  }
}
