import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRequiredWrapper extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? unauthorizedWidget;

  const AuthRequiredWrapper({
    super.key,
    required this.child,
    this.loadingWidget,
    this.unauthorizedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return unauthorizedWidget ?? 
            const Center(child: Text('Please login to view this content'));
        }

        return child;
      },
    );
  }
}