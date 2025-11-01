
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/anniversary_screen.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      return AnniversaryScreen(userId: user.uid);
    } else {
      // ログインしていない場合は、ログインを促す画面などを表示
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to see your anniversaries.'),
        ),
      );
    }
  }
}
