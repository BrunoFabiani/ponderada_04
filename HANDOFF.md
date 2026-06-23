# Project Handoff - Ponderada 04

Este arquivo resume o contexto atual do projeto **Atividade Ponderada 4**, as decisões técnicas tomadas, o que já foi implementado e o que ainda falta antes da entrega.

## Contexto da Ponderada

A atividade pede um aplicativo mobile real, não apenas uma página web responsiva. Os requisitos principais são:

- App mobile em Flutter, Kotlin, SwiftUI ou tecnologia similar.
- Mais de duas telas.
- Navegação funcional.
- Integração com backend.
- Persistência em banco de dados.
- Consumo de API externa.
- Sistema de notificações.
- Compartilhamento nativo.
- Uso de pelo menos um recurso de hardware do celular.
- UI organizada.
- Loading e tratamento básico de erro.
- Documentação mínima.
- Demo/vídeo funcional.
- Repositório público no GitHub.

## Ideia do Projeto

Nome/conceito:

```text
FreeGame Finder
```

Problema:

```text
Usuários querem encontrar jogos bons para jogar, mas não querem pagar e nem perder tempo pesquisando manualmente.
```

Solução:

```text
Um app mobile que lista jogos free-to-play usando a FreeToGame API, permite salvar jogos em uma lista pessoal e usa IA para recomendar 3 jogos com base no texto do usuário.
```

## Estado Atual do App

O app está em:

```text
app/
```

Principais telas implementadas:

- Login.
- Cadastro.
- Descobrir jogos.
- Jogos salvos.
- Recomendação com IA.
- Perfil.

O `main.dart` já foi reduzido e a estrutura foi separada em arquivos menores:

```text
app/lib/
  main.dart
  app/
    app_routes.dart
    game_finder_app.dart
  core/
    supabase_config.dart
  models/
    game_model.dart
    game_recommendation_model.dart
    game_to_play_model.dart
    profile_model.dart
    recommendation_session_model.dart
  repositories/
    auth_repository.dart
    game_repository.dart
    profile_repository.dart
    recommendation_repository.dart
  services/
    ai_recommendation_service.dart
    freetogame_api_service.dart
    notification_service.dart
    storage_service.dart
  screens/
    auth/
    games/
    home/
    profile/
    recommendation/
  widgets/
```

## Funcionalidades Já Implementadas

### Autenticação

Login e cadastro estão conectados ao Supabase Auth.

Fluxo:

```text
LoginScreen -> AuthRepository.signIn
RegisterScreen -> AuthRepository.signUp -> ProfileRepository.upsertProfile
```

### Descobrir Jogos

A tela **Descobrir** consome diretamente a FreeToGame API através de:

```text
FreeToGameApiService
```

Ela exibe:

- Loading.
- Erro.
- Lista de jogos.
- Cards com imagem, título, descrição, gênero e plataforma.
- Filtros simples de plataforma e categoria.
- Botão para salvar jogo.

Decisão importante: a FreeToGame API não usa segredo, então ela pode ser chamada diretamente pelo Flutter. O `GameRepository` é usado principalmente para ações com Supabase.

### Salvar Jogos

Salvar um jogo faz:

```text
GameRepository.saveFreeGame
  -> upsert em games
  -> insert em games_to_play
```

Também trata duplicidade com a constraint única de:

```text
games_to_play(user_id, game_id)
```

### Jogos Salvos

A tela **Jogos salvos** carrega a lista persistida no Supabase:

```text
GameRepository.fetchMySavedGames
```

Ela mostra loading, erro, lista vazia e os cards dos jogos salvos.

### Perfil e Câmera

A tela **Perfil** usa `image_picker` para abrir a câmera do celular.

Fluxo:

```text
Usuário tira foto
-> XFile.readAsBytes()
-> StorageService.uploadAvatar
-> Supabase Storage bucket avatars
-> path {user_id}/avatar.jpg
-> ProfileRepository.updateAvatarUrl
-> profiles.avatar_url
```

Foi escolhida a abordagem com bytes e `uploadBinary`, evitando `dart:io` direto na tela.

O `Info.plist` do iOS recebeu:

```text
NSCameraUsageDescription
```

### Notificações

O app usa:

```text
flutter_local_notifications
```

Quando um jogo é salvo, uma notificação local é disparada:

```text
Jogo salvo
{gameTitle} foi adicionado aos seus jogos salvos.
```

No Android, já foi aplicado o ajuste de desugaring no Gradle para suportar o pacote.

### Recomendação com IA

A tela **Recomendação** já está funcional.

Fluxo:

```text
Usuário digita o tipo de jogo que quer
-> Flutter chama Supabase Edge Function recommend-games
-> Edge Function busca jogos populares da FreeToGame
-> Edge Function chama Groq
-> Groq retorna 3 game_id + reason em JSON
-> Edge Function mapeia os IDs para jogos reais
-> Flutter mostra 3 cards
-> Usuário pode salvar qualquer recomendação
```

Arquivos importantes:

```text
app/lib/services/ai_recommendation_service.dart
app/lib/models/game_recommendation_model.dart
app/lib/screens/recommendation/recommendation_screen.dart
supabase/functions/recommend-games/index.ts
```

Decisão importante: a IA **não deve inventar jogos**. Ela só pode recomendar jogos da lista de candidatos da FreeToGame.

### Provider de IA

Inicialmente foi tentado OpenAI via Responses API, mas a conta retornou:

```text
429 insufficient_quota
```

Depois foi feita a troca para **Groq**, mantendo a mesma Edge Function e sem mudar o Flutter.

Secrets atuais necessários para a função:

```text
GROQ_API_KEY
GROQ_MODEL=openai/gpt-oss-20b
```

Comandos:

```powershell
supabase secrets set GROQ_API_KEY=SUA_CHAVE
supabase secrets set GROQ_MODEL=openai/gpt-oss-20b
supabase functions deploy recommend-games
```

Observação: Groq também tem rate limit. Em testes, o usuário conseguiu fazer a função funcionar no app depois de aguardar o limite resetar.

## Backend

Backend escolhido:

```text
Supabase
```

Usado para:

- Auth.
- Postgres.
- Storage.
- RLS.
- Edge Function de recomendação.

Tabelas:

```text
profiles
games
games_to_play
recommendation_sessions
```

Na implementação atual, `recommendation_sessions` existe na model/repository, mas a conversa da IA **não é persistida**. Isso foi uma decisão consciente para simplificar:

```text
prompt in -> 3 jogos out
```

Os jogos salvos continuam persistindo normalmente.

Documentação de backend:

```text
docs/supabase_backend.md
```

## API Externa

FreeToGame API:

```text
https://www.freetogame.com/api-doc
```

Endpoints usados/relevantes:

```text
GET https://www.freetogame.com/api/games
GET https://www.freetogame.com/api/games?category=shooter&platform=pc
GET https://www.freetogame.com/api/games?sort-by=popularity
GET https://www.freetogame.com/api/game?id=540
```

A Edge Function usa:

```text
GET https://www.freetogame.com/api/games?sort-by=popularity
```

e corta a lista para os primeiros 120 jogos para reduzir payload/custo.

## Configuração de Runtime

O Flutter lê Supabase por Dart defines:

```dart
String.fromEnvironment('SUPABASE_URL')
String.fromEnvironment('SUPABASE_ANON_KEY')
```

Comando:

```powershell
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

## Edge Function

Criada com:

```powershell
supabase functions new recommend-games
```

Arquivo:

```text
supabase/functions/recommend-games/index.ts
```

Deploy:

```powershell
supabase functions deploy recommend-games
```

O Supabase CLI instalado neste ambiente não possui:

```text
supabase functions logs
supabase functions invoke
```

Para logs, usar Supabase Dashboard:

```text
Edge Functions -> recommend-games -> Logs
```

## UI e Idioma

A UI foi traduzida para português, mantendo identificadores técnicos em inglês.

Traduzido:

- Login/cadastro.
- Descobrir.
- Jogos salvos.
- Perfil.
- Recomendação.
- Mensagens de erro/sucesso.
- Notificações.
- Barra inferior.

Não traduzir:

- Rotas internas.
- Tabelas/colunas Supabase.
- Secrets.
- Nomes de função.
- Valores técnicos como `freetogame`, `recommend-games`, `games_to_play`.

## Firelink e Estilo de Código

O usuário pediu que todo Dart/Flutter siga a base do Firelink:

```text
https://firelink-library.github.io/mobile/flutter/dart-intro
```

Interpretação prática:

- Código simples e didático.
- Classes explícitas.
- Tipagem clara.
- Evitar abstrações desnecessárias.
- Não fazer parecer uma arquitetura enterprise.
- Manter cara de projeto universitário bem feito.
- Preferir nomes descritivos.
- Comentários só quando ajudarem.
- UI Material direta.

## Preferência de Colaboração

O usuário pediu:

```text
"sempre fale como vc irá fazer e como eu posso fazer antes de fazer qualquer coisa"
```

Antes de editar arquivos, explicar rapidamente:

1. O que será feito.
2. Por que será feito.
3. Como o usuário faria manualmente.
4. Depois aplicar a mudança.

Também foi pedido para evitar testes demorados quando não necessário. Preferir:

```powershell
flutter analyze --no-pub
```

e passar instruções de verificação manual quando o usuário pedir.

## Validações Recentes

Após tradução da UI:

```powershell
flutter analyze --no-pub
```

Resultado:

```text
No issues found!
```

Testes não devem ser rodados automaticamente se o usuário pedir para evitar demora.

## Pendências Reais Antes da Entrega

### 1. Compartilhamento nativo

`share_plus` está no `pubspec.yaml`, mas ainda não foi encontrado uso real em `lib`.

Este é o principal requisito técnico ainda pendente.

Implementação mais simples:

- Adicionar botão de compartilhar no `GameCard` ou em uma tela de detalhes.
- Usar `share_plus`.
- Compartilhar título + URL do jogo.

### 2. README

Criar ou atualizar `README.md` com:

- Problema.
- Solução.
- Stack.
- Como rodar.
- Configuração Supabase.
- Configuração Groq.
- API FreeToGame.
- Checklist de funcionalidades.

### 3. Vídeo/Demo

Gravar fluxo mostrando:

1. Login/cadastro.
2. Lista de jogos em Descobrir.
3. Salvar jogo.
4. Notificação.
5. Jogos salvos persistidos.
6. Perfil com câmera.
7. Recomendação com IA.
8. Salvar jogo recomendado.
9. Compartilhamento nativo, depois que for implementado.

### 4. GitHub público

Confirmar que o repositório está público.

## Checklist de Requisitos

Estado atual:

- App mobile Flutter: feito.
- Mais de duas telas: feito.
- Navegação funcional: feito.
- Backend Supabase: feito.
- Persistência em banco: feito.
- API externa FreeToGame: feito.
- Notificações: feito.
- Hardware/câmera: feito.
- IA/recomendação: feito com Groq via Edge Function.
- Loading/erro: feito em telas principais.
- UI em português: feito.
- Compartilhamento nativo: pendente.
- README: pendente ou precisa revisão.
- Demo/vídeo: pendente.
- GitHub público: confirmar.

## Comandos Úteis

Flutter:

```powershell
cd C:\Users\Bruno\Documents\ponderada_04\app
flutter pub get
flutter devices
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
flutter analyze --no-pub
```

Supabase:

```powershell
cd C:\Users\Bruno\Documents\ponderada_04
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets list
supabase secrets set GROQ_API_KEY=SUA_CHAVE
supabase secrets set GROQ_MODEL=openai/gpt-oss-20b
supabase functions deploy recommend-games
```

## Próxima Melhor Tarefa

Implementar **compartilhamento nativo** com `share_plus`, porque é o requisito funcional mais claro que ainda falta.

Depois disso:

1. README.
2. Demo.
3. Revisão final do checklist.
