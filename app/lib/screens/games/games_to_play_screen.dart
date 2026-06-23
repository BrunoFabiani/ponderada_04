import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_routes.dart';
import '../../core/supabase_config.dart';
import '../../models/game_model.dart';
import '../../repositories/game_repository.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/game_card.dart';

class GamesToPlayScreen extends StatefulWidget {
  const GamesToPlayScreen({super.key});

  @override
  State<GamesToPlayScreen> createState() {
    return _GamesToPlayScreenState();
  }
}

class _GamesToPlayScreenState extends State<GamesToPlayScreen> {
  List<GameModel> savedGames = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSavedGames();
  }

  Future<void> loadSavedGames() async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.anonKey.isEmpty) {
      setState(() {
        errorMessage = 'Configure o Supabase para carregar os jogos salvos.';
        isLoading = false;
      });
      return;
    }

    final SupabaseClient client = Supabase.instance.client;
    final User? user = client.auth.currentUser;

    if (user == null) {
      setState(() {
        errorMessage = 'Entre para ver seus jogos salvos.';
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final GameRepository repository = GameRepository(supabaseClient: client);

      final List<GameModel> loadedGames = await repository.fetchMySavedGames(
        user.id,
      );

      if (!mounted) return;

      setState(() {
        savedGames = loadedGames;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Não foi possível carregar os jogos salvos.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.gamesToPlay,
      title: 'Jogos salvos',
      child: RefreshIndicator(
        onRefresh: loadSavedGames,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              _SavedError(
                message: errorMessage!,
                onLoginPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                onRetryPressed: loadSavedGames,
              )
            else if (savedGames.isEmpty)
              const EmptyState(
                icon: Icons.bookmarks_outlined,
                title: 'Nenhum jogo salvo ainda',
                subtitle: 'Salve jogos em Descobrir para vê-los aqui.',
              )
            else
              ...savedGames.map((GameModel game) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GameCard(game: game),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SavedError extends StatelessWidget {
  const _SavedError({
    required this.message,
    required this.onLoginPressed,
    required this.onRetryPressed,
  });

  final String message;
  final VoidCallback onLoginPressed;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: message.startsWith('Entre')
                ? onLoginPressed
                : onRetryPressed,
            child: Text(
              message.startsWith('Entre') ? 'Entrar' : 'Tentar novamente',
            ),
          ),
        ],
      ),
    );
  }
}
