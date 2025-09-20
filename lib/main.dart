import 'package:flutter/material.dart';
import 'screens/playlist_calculator_screen.dart';

void main() {
  runApp(const YouTubePlaylistApp());
}

class YouTubePlaylistApp extends StatelessWidget {
  const YouTubePlaylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Playlist Calculator',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFF800020),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800020),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const PlaylistCalculatorScreen(),
    );
  }
}