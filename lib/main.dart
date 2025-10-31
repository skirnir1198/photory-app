import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/screens/auth_wrapper.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/storage_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFFD9AAB7);
    const Color backgroundColor = Color(0xFFFAF9F6);
    const Color textColor = Color(0xFF333333);

    final ThemeData theme = ThemeData(
      primaryColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        background: backgroundColor,
        primary: accentColor,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: GoogleFonts.lora(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 16,
          color: textColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
      ],
      child: MaterialApp(
        title: 'Photo Milestone Tracker',
        theme: theme,
        home: const AuthWrapper(),
      ),
    );
  }
}
