import 'package:share_plus/share_plus.dart';

import '../models/game_model.dart';

class ShareService {
  const ShareService();

  bool hasGameLink(GameModel game) {
    return _gameLink(game) != null;
  }

  Future<void> shareGameLink(GameModel game) async {
    final String? link = _gameLink(game);
    if (link == null) return;

    await SharePlus.instance.share(ShareParams(text: link));
  }

  String? _gameLink(GameModel game) {
    if (game.gameUrl != null && game.gameUrl!.isNotEmpty) {
      return game.gameUrl;
    }

    if (game.freetogameProfileUrl != null &&
        game.freetogameProfileUrl!.isNotEmpty) {
      return game.freetogameProfileUrl;
    }

    return null;
  }
}
