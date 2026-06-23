import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_routes.dart';
import '../../core/supabase_config.dart';
import '../../models/game_model.dart';
import '../../models/game_recommendation_model.dart';
import '../../repositories/game_repository.dart';
import '../../services/ai_recommendation_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/game_card.dart';
import '../../widgets/section_header.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() {
    return _RecommendationScreenState();
  }
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final TextEditingController promptController = TextEditingController();

  List<GameRecommendationModel> recommendations = [];
  bool isLoading = false;
  String? errorMessage;
  final Set<int> savingGameIds = {};

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  Future<void> findRecommendations() async {
    final String prompt = promptController.text.trim();

    if (prompt.isEmpty) {
      showMessage('Descreva que tipo de jogo você quer encontrar.');
      return;
    }

    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      showMessage('Configure o Supabase antes de usar recomendações com IA.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      recommendations = [];
    });

    try {
      final service = AiRecommendationService(Supabase.instance.client);
      final List<GameRecommendationModel> loadedRecommendations = await service
          .recommendGames(prompt);

      if (!mounted) return;

      setState(() {
        recommendations = loadedRecommendations;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Não foi possível gerar recomendações: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveGame(GameModel game) async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      showMessage('Configure o Supabase antes de salvar jogos.');
      return;
    }

    final SupabaseClient client = Supabase.instance.client;
    final User? user = client.auth.currentUser;

    if (user == null) {
      showMessage('Crie uma conta ou entre antes de salvar jogos.');
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    setState(() {
      savingGameIds.add(game.id);
    });

    try {
      final GameRepository repository = GameRepository(supabaseClient: client);
      await repository.saveFreeGame(userId: user.id, game: game);

      await NotificationService.instance.showGameSavedNotification(
        gameId: game.id,
        gameTitle: game.title,
      );

      if (!mounted) return;
      showMessage('${game.title} foi salvo.');
    } on PostgrestException catch (error) {
      if (!mounted) return;

      if (error.code == '23505') {
        showMessage('Esse jogo já está salvo.');
      } else {
        showMessage('Não foi possível salvar esse jogo.');
      }
    } catch (error) {
      if (!mounted) return;
      showMessage('Não foi possível salvar esse jogo.');
    } finally {
      if (mounted) {
        setState(() {
          savingGameIds.remove(game.id);
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.recommendation,
      title: 'Recomendação',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Encontrar meu jogo',
            subtitle:
                'Descreva o que você procura e receba 3 jogos gratuitos reais.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: promptController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Que tipo de jogo você quer?',
              hintText:
                  'Exemplo: um RPG tranquilo, com progressão e sem ser difícil demais',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isLoading ? null : findRecommendations,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(isLoading ? 'Buscando jogos...' : 'Recomendar jogos'),
          ),
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (errorMessage != null) {
      return _RecommendationMessage(
        icon: Icons.error_outline,
        message: errorMessage!,
      );
    }

    if (recommendations.isEmpty) {
      return const _RecommendationMessage(
        icon: Icons.psychology_alt_outlined,
        message: 'Suas recomendações vão aparecer aqui.',
      );
    }

    return Column(
      children: recommendations.map((GameRecommendationModel recommendation) {
        final GameModel game = recommendation.game;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GameCard(
                game: game,
                isSaving: savingGameIds.contains(game.id),
                onSavePressed: () {
                  saveGame(game);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  recommendation.reason,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RecommendationMessage extends StatelessWidget {
  const _RecommendationMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
