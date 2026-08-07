import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'design/taskflow_tokens.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Theme provider for managing light/dark mode
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'TaskFlow',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),


        // Home screen
        home: const HomeScreen(),

        // Named routes
        routes: {
          '/home': (context) => const HomeScreen(),
        },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final palette =
        isDark ? TaskFlowPalette.dark : TaskFlowPalette.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: <ThemeExtension<dynamic>>[palette],
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: brightness,
        primary: palette.accent,
        secondary: TaskFlowTokens.eveningAccent,
        surface: palette.surface,
        error: palette.danger,
      ),
      scaffoldBackgroundColor: palette.surface,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: Typography.blackCupertino.copyWith(
        displayLarge: TaskFlowText.largeTitle(palette.textPrimary),
        displayMedium: TaskFlowText.largeTitle(palette.textPrimary),
        displaySmall: TaskFlowText.title1(palette.textPrimary),
        headlineMedium: TaskFlowText.title1(palette.textPrimary),
        titleLarge: TaskFlowText.navTitle(palette.textPrimary),
        titleMedium: TaskFlowText.listTitle(palette.textPrimary),
        bodyLarge: TaskFlowText.taskTitle(palette.textPrimary),
        bodyMedium: TaskFlowText.meta(palette.textTertiary),
        bodySmall: TaskFlowText.meta(palette.textQuaternary),
        labelLarge: TaskFlowText.sectionHeader(palette.textPrimary),
        labelMedium: TaskFlowText.badge(palette.textTertiary),
        labelSmall: TaskFlowText.badge(palette.textTertiary),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TaskFlowText.title1(palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusMd),
          side: BorderSide(color: palette.separator, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: palette.accent,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
        filled: true,
        fillColor: palette.fill,
        hintStyle: TaskFlowText.taskTitle(palette.textTertiary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TaskFlowText.button(Colors.white),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: TaskFlowText.button(Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accent,
          side: BorderSide(color: palette.separator),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaskFlowTokens.radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.groupedFill,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TaskFlowText.tag(palette.textSecondary),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(TaskFlowTokens.radiusCheckbox),
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.accent;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: palette.controlBorder, width: 1.5),
      ),
      dividerTheme:
          DividerThemeData(color: palette.separator, thickness: 1, space: 1),
    );
  }
}
