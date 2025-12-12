import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'theme_provider.dart';

// Global theme provider
late ThemeProvider globalThemeProvider;

void main() async {
  // Đảm bảo Flutter đã khởi tạo trước khi chạy async
  WidgetsFlutterBinding.ensureInitialized();

  globalThemeProvider = ThemeProvider();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    globalThemeProvider.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    globalThemeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: globalThemeProvider.lightTheme,
      darkTheme: globalThemeProvider.darkTheme,
      themeMode: globalThemeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
