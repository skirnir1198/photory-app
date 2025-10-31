
import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Anniversary Tracker',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => authService.signInWithGoogle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9AAB7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
