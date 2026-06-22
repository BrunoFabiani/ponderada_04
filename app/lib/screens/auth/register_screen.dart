import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/auth_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create profile',
      subtitle: 'Your profile will store your saved games and preferences.',
      primaryLabel: 'Create account',
      onPrimaryPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      secondaryLabel: 'Back to login',
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
