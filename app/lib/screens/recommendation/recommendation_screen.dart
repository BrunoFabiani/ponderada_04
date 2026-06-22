import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/placeholder_card.dart';
import '../../widgets/section_header.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.recommendation,
      title: 'Recommendation',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionHeader(
            title: 'Find my game',
            subtitle:
                'This flow will ask questions, send candidate games to the LLM and save the session.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            title: 'Akinator-style flow',
            subtitle:
                'Next step: build questions about genre, platform, play style and session length.',
            icon: Icons.psychology_alt_outlined,
          ),
        ],
      ),
    );
  }
}
