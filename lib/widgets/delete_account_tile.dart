import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class DeleteAccountTile extends StatelessWidget {
  final _authService = AuthService();

  DeleteAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.delete_outline,
        color: Colors.red[700],
      ),
      title: Text(
        'Delete Account',
        style: TextStyle(
          color: Colors.red[700],
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _DeleteConfirmationDialog(authService: _authService),
        );
      },
    );
  }
}
class _DeleteConfirmationDialog extends StatefulWidget {
  final AuthService authService;

  const _DeleteConfirmationDialog({required this.authService});

  @override
  State<_DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      title: const Text('Delete Account'),
      content: _isDeleting
          ? Row(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
                ),
                const SizedBox(width: 16),
                const Text('Deleting account...'),
              ],
            )
          : const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
      actions: [
        if (!_isDeleting)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        if (!_isDeleting)
          TextButton(
            onPressed: () async {
              setState(() => _isDeleting = true);
              try {
                await widget.authService.deleteAccount();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                setState(() => _isDeleting = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.red[700],
              ),
            ),
          ),
      ],
    );
  }
}