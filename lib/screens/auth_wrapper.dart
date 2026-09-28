// lib/screens/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';

/// Listens to Firebase Auth state and shows either [LoginScreen] or [HomeScreen].
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a splash while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is signed in → show the home screen
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // No user → show login
        return const LoginScreen();
      },
    );
  }
}
