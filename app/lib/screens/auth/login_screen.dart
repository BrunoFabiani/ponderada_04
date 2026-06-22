import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/auth_scaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'FreeGame Finder',
      subtitle: 'Find free games that fit what you want to play next.',
      primaryLabel: 'Enter app',
      onPrimaryPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      secondaryLabel: 'Create account',
      onSecondaryPressed: () {
        Navigator.pushNamed(context, AppRoutes.register);
      },
    );
  }
}
