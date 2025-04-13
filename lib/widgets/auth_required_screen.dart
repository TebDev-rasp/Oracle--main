import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRequiredScreen extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget Function(BuildContext)? unauthorizedBuilder;

  const AuthRequiredScreen({
    super.key,
    required this.child,
    this.loadingWidget,
    this.unauthorizedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return unauthorizedBuilder?.call(context) ?? 
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please login to view this content'),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
        }

        return child;
      },
    );
  }
}