import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MoonsRoot());
}

class MoonsRoot extends StatefulWidget {
  const MoonsRoot({super.key});

  @override
  State<MoonsRoot> createState() => _MoonsRootState();
}

class _MoonsRootState extends State<MoonsRoot> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: const MoonsApp(),
    );
  }
}

class MoonsApp extends StatelessWidget {
  const MoonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (appState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MoonsTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Moons',
      debugShowCheckedModeBanner: false,
      theme: MoonsTheme.lightTheme,
      darkTheme: MoonsTheme.darkTheme,
      themeMode: appState.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
