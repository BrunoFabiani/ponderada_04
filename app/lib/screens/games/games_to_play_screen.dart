import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';

class GamesToPlayScreen extends StatelessWidget {
  const GamesToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.gamesToPlay,
      title: 'Games to Play',
      child: const EmptyState(
        icon: Icons.bookmarks_outlined,
        title: 'No saved games yet',
        subtitle: 'Saved FreeToGame recommendations will be listed here.',
      ),
    );
  }
}
