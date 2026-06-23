# Backend - FreeGame Finder

Este documento explica como o backend do FreeGame Finder está estruturado usando Supabase.

## Visão Geral

O backend da aplicação usa **Supabase** para:

- autenticação de usuários;
- banco de dados Postgres;
- armazenamento de foto de perfil;
- regras de segurança com RLS;
- função server-side para recomendação de jogos.

Arquitetura geral:

```text
Flutter app
  -> Supabase Auth
  -> Supabase Postgres
  -> Supabase Storage
  -> Supabase Edge Function recommend-games
  -> FreeToGame API
```

## Autenticação

A autenticação é feita com Supabase Auth.

Fluxo no app:

```text
LoginScreen
  -> AuthRepository.signIn

RegisterScreen
  -> AuthRepository.signUp
  -> ProfileRepository.upsertProfile
```

Depois que o usuário cria a conta, o app cria ou atualiza um registro em:

```text
profiles
```

O `id` do perfil é o mesmo `id` do usuário autenticado no Supabase Auth.

## Banco de Dados

As tabelas principais são:

```text
profiles
games
games_to_play
recommendation_sessions
```

### profiles

Guarda dados específicos do perfil do usuário dentro do app.

Campos principais:

```text
id
username
avatar_url
```

Uso:

- mostrar nome do usuário;
- salvar URL da foto de perfil;
- relacionar dados do app ao usuário autenticado.

### games

Guarda dados de jogos vindos da FreeToGame API.

O `id` do jogo é o próprio ID da FreeToGame.

Campos principais:

```text
id
title
thumbnail
short_description
game_url
genre
platform
publisher
developer
release_date
freetogame_profile_url
details
```

Uso:

- cache dos jogos salvos;
- carregar dados completos na tela de jogos salvos;
- manter o link do jogo para compartilhamento.

### games_to_play

Guarda a relação entre usuário e jogo salvo.

Campos principais:

```text
id
user_id
game_id
status
priority
user_notes
source
created_at
updated_at
```

Uso:

- listar os jogos que o usuário salvou;
- impedir que o mesmo usuário salve o mesmo jogo mais de uma vez;
- permitir evolução futura com status como interessado, jogando, finalizado etc.

Regra importante:

```text
games_to_play(user_id, game_id) deve ser único
```

### recommendation_sessions

Tabela planejada para guardar sessões de recomendação.

No estado atual do app, a recomendação é simples:

```text
texto do usuário -> 3 jogos recomendados
```

A conversa/sessão não precisa ser persistida para o fluxo atual.

## Storage

O Supabase Storage é usado para fotos de perfil.

Bucket:

```text
avatars
```

Fluxo:

```text
Usuário tira foto no app
-> Flutter lê a imagem
-> StorageService envia para o bucket avatars
-> caminho: {user_id}/avatar.jpg
-> app salva a URL em profiles.avatar_url
```

Arquivo responsável no Flutter:

```text
app/lib/services/storage_service.dart
```

## Regras de Segurança

O banco usa RLS para proteger dados dos usuários.

Regras esperadas:

- usuário só acessa o próprio perfil;
- usuário só acessa a própria lista de jogos salvos;
- jogos em `games` podem ser lidos pelos usuários autenticados;
- jogos podem ser inseridos/atualizados para cache quando o usuário salva um jogo.

## Edge Function de Recomendação

A função fica em:

```text
supabase/functions/recommend-games/index.ts
```

Nome da função:

```text
recommend-games
```

Fluxo:

```text
Flutter envia prompt do usuário
-> Edge Function busca jogos populares da FreeToGame
-> monta uma lista compacta de candidatos
-> chama um serviço externo de recomendação
-> recebe 3 IDs de jogos e motivos
-> mapeia os IDs para jogos reais
-> retorna os dados para o Flutter
```

Formato esperado da resposta:

```json
{
  "recommendations": [
    {
      "game": {
        "id": 1,
        "title": "Nome do jogo",
        "thumbnail": "https://...",
        "short_description": "Descrição curta",
        "game_url": "https://...",
        "genre": "Genre",
        "platform": "Platform",
        "freetogame_profile_url": "https://..."
      },
      "reason": "Motivo curto da recomendação."
    }
  ]
}
```

## Secrets da Edge Function

A função usa secrets genéricos para não deixar chave no app Flutter.

Secrets:

```text
RECOMMENDATION_API_KEY
RECOMMENDATION_MODEL
RECOMMENDATION_API_URL
```

Configuração:

```powershell
supabase secrets set RECOMMENDATION_API_KEY=SUA_CHAVE
supabase secrets set RECOMMENDATION_MODEL=MODELO_USADO
supabase secrets set RECOMMENDATION_API_URL=URL_DO_ENDPOINT
```

Depois:

```powershell
supabase functions deploy recommend-games
```

## Integração com o Flutter

O app chama a função por:

```text
app/lib/services/ai_recommendation_service.dart
```

Apesar do nome atual do arquivo, a responsabilidade dele é apenas chamar a Edge Function de recomendação.

Fluxo no app:

```text
RecommendationScreen
  -> AiRecommendationService.recommendGames
  -> Supabase functions.invoke('recommend-games')
```

## Variáveis do App Flutter

O app recebe as configurações do Supabase por Dart defines:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Exemplo:

```powershell
flutter run --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY
```

## Arquivos Importantes

```text
app/lib/core/supabase_config.dart
app/lib/repositories/auth_repository.dart
app/lib/repositories/profile_repository.dart
app/lib/repositories/game_repository.dart
app/lib/services/storage_service.dart
app/lib/services/ai_recommendation_service.dart
supabase/functions/recommend-games/index.ts
docs/supabase_backend.md
```

## Resumo

O backend foi estruturado para manter o app simples:

- Flutter cuida da interface.
- Supabase Auth cuida dos usuários.
- Supabase Postgres persiste perfis e jogos salvos.
- Supabase Storage guarda foto de perfil.
- Edge Function protege a chave do serviço de recomendação.
- FreeToGame fornece os dados dos jogos.
