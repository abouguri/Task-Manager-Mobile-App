import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/task_detail_screen.dart';

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
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
        
        // Minimalist Fancy Theme - Light Mode
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF), // Modern purple/indigo
            brightness: Brightness.light,
            primary: const Color(0xFF6C63FF),
            secondary: const Color(0xFFFF6584),
            surface: const Color(0xFFFAFAFA),
            background: const Color(0xFFF5F5F7),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          
          // App Bar theme - Clean and minimal
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFFF5F5F7),
            foregroundColor: Color(0xFF1A1A1A),
            titleTextStyle: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          
          // Card theme - Sleek and modern
          cardTheme: CardTheme(
            elevation: 0,
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          
          // Floating Action Button - Gradient effect
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0,
            backgroundColor: Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          
          // Input Decoration - Minimal borders
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          
          // Elevated Button - Modern and clean
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Text Button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Outlined Button theme
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C63FF),
              side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          
          // Chip theme
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          
          // Checkbox theme
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF6C63FF);
              }
              return Colors.transparent;
            }),
            side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 2),
          ),
        ),
        
        // Dark theme - Elegant and sleek
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
            primary: const Color(0xFF8B84FF),
            secondary: const Color(0xFFFF8FA3),
            surface: const Color(0xFF1E1E1E),
            background: const Color(0xFF121212),
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          
          cardTheme: CardTheme(
            elevation: 0,
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0,
            backgroundColor: Color(0xFF8B84FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF8B84FF), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
          ),
        ),
        
        // Home screen
        home: const HomeScreen(),
        
        // Named routes
        routes: {
          '/home': (context) => const HomeScreen(),
        },
        
        // Handle named routes with arguments
        onGenerateRoute: (settings) {
          if (settings.name == '/task-detail') {
            final taskId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => TaskDetailScreen(taskId: taskId),
            );
          }
          return null;
        },
          );
        },
      ),
    );
  }
}
