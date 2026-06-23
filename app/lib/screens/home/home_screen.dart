import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_routes.dart';
import '../../core/supabase_config.dart';
import '../../models/game_model.dart';
import '../../repositories/game_repository.dart';
import '../../services/freetogame_api_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/game_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final FreeToGameApiService apiService = FreeToGameApiService();

  List<GameModel> games = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedPlatform = 'all';
  String selectedCategory = 'all';
  final Set<int> savingGameIds = {};

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final List<GameModel> loadedGames = await apiService.fetchGames(
        platform: selectedPlatform == 'all' ? null : selectedPlatform,
        category: selectedCategory == 'all' ? null : selectedCategory,
        sortBy: 'popularity',
      );

      if (!mounted) return;

      setState(() {
        games = loadedGames;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Não foi possível carregar os jogos. Verifique sua conexão.';
        isLoading = false;
      });
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
      currentRoute: AppRoutes.home,
      title: 'Descobrir',
      child: RefreshIndicator(
        onRefresh: loadGames,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(
              title: 'Jogos gratuitos recomendados',
              subtitle: 'Jogos free-to-play populares da FreeToGame.',
            ),
            const SizedBox(height: 16),
            _HomeFilters(
              selectedPlatform: selectedPlatform,
              selectedCategory: selectedCategory,
              onPlatformChanged: (String value) {
                setState(() {
                  selectedPlatform = value;
                });
                loadGames();
              },
              onCategoryChanged: (String value) {
                setState(() {
                  selectedCategory = value;
                });
                loadGames();
              },
            ),
            const SizedBox(height: 16),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return _ErrorState(message: errorMessage!, onRetry: loadGames);
    }

    if (games.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nenhum jogo encontrado',
        subtitle: 'Tente mudar o filtro de plataforma ou categoria.',
      );
    }

    return Column(
      children: games.map((GameModel game) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GameCard(
            game: game,
            isSaving: savingGameIds.contains(game.id),
            onSavePressed: () {
              saveGame(game);
            },
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.recommendation);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _HomeFilters extends StatelessWidget {
  const _HomeFilters({
    required this.selectedPlatform,
    required this.selectedCategory,
    required this.onPlatformChanged,
    required this.onCategoryChanged,
  });

  final String selectedPlatform;
  final String selectedCategory;
  final ValueChanged<String> onPlatformChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedPlatform,
          decoration: const InputDecoration(
            labelText: 'Plataforma',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Todas as plataformas')),
            DropdownMenuItem(value: 'pc', child: Text('PC')),
            DropdownMenuItem(value: 'browser', child: Text('Browser')),
          ],
          onChanged: (String? value) {
            if (value != null) onPlatformChanged(value);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('Todas as categorias')),
            DropdownMenuItem(value: 'shooter', child: Text('Shooter')),
            DropdownMenuItem(value: 'strategy', child: Text('Strategy')),
            DropdownMenuItem(value: 'moba', child: Text('MOBA')),
            DropdownMenuItem(value: 'racing', child: Text('Racing')),
            DropdownMenuItem(value: 'sports', child: Text('Sports')),
            DropdownMenuItem(value: 'mmorpg', child: Text('MMORPG')),
          ],
          onChanged: (String? value) {
            if (value != null) onCategoryChanged(value);
          },
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off,
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
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
