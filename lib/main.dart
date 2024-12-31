import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'core/services/auth_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/formatting_provider.dart';
import 'core/utils/theme.dart';
import 'core/utils/util.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AuthService().trySilentSignIn();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FormattingProvider()),
      ],
      child: const Fundi(),
    ),
  );
}

class Fundi extends StatelessWidget {
  const Fundi({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Create text themes with Electrolize font for headers and titles
        // Use Roboto (system default) for body text
        final textTheme = createTextTheme(
          context,
          'Roboto', // Body font (system default)
          'Maven Pro', // Display font for headers and titles
        );

        // Get the appropriate theme based on mode
        final bool isDark = themeProvider.useSystemTheme
            ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
            : themeProvider.isDarkMode;

        // Update system UI based on theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
        );

        final themeMode = themeProvider.useSystemTheme
            ? ThemeMode.system
            : themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light;

        return ResponsiveSizer(
          builder: (context, orientation, screenType) {
            return MaterialApp(
              title: 'Fundi',
              theme: MaterialTheme(textTheme).light(),
              darkTheme: MaterialTheme(textTheme).dark(),
              themeMode: themeMode,
              initialRoute: AppRoutes.splash,
              routes: AppRoutes.routes,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final textScaler = mediaQuery.textScaler;
                final double adjustedScale;

                if (textScaler.scale(1.0) > 1.1) {
                  // For very large system text sizes, use a more conservative scale
                  adjustedScale = 0.8;
                } else if (textScaler.scale(1.0) < 0.8) {
                  // For very small system text sizes, ensure minimum readability
                  adjustedScale = 0.85;
                } else {
                  // For normal range, use a slightly reduced scale for consistency
                  adjustedScale = 0.9;
                }

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    // Apply the adjusted scale using textScaler
                    textScaler: TextScaler.linear(adjustedScale),
                  ),
                  child: child ?? const SizedBox(),
                );
              },
            );
          },
        );
      },
    );
  }
}
