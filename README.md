# FreeGame Finder

Aplicativo mobile desenvolvido para a **Atividade Ponderada 4**. A proposta do app é ajudar pessoas a encontrarem jogos gratuitos para jogar, sem precisar pesquisar manualmente em vários sites.

O app lista jogos free-to-play da FreeToGame API, permite salvar jogos em uma lista pessoal, usa câmera para foto de perfil, envia notificações locais, permite compartilhar links de jogos e possui uma tela de recomendação que sugere 3 jogos com base no texto do usuário.

## Ideia do App

O problema escolhido foi:

```text
Muitas pessoas querem encontrar jogos bons para jogar, mas não querem pagar e nem perder tempo procurando manualmente.
```

A solução foi criar um app chamado **FreeGame Finder**, onde o usuário pode:

- criar uma conta;
- ver jogos gratuitos;
- filtrar jogos por plataforma e categoria;
- salvar jogos que quer testar depois;
- receber notificação ao salvar um jogo;
- tirar foto de perfil com a câmera;
- pedir uma recomendação de jogos;
- compartilhar o link de um jogo usando o compartilhamento nativo do celular.

## Tecnologias Usadas

- **Flutter**: desenvolvimento do app mobile.
- **Dart**: linguagem principal do app.
- **Supabase Auth**: login e cadastro.
- **Supabase Postgres**: persistência dos perfis, jogos e jogos salvos.
- **Supabase Storage**: armazenamento da foto de perfil.
- **Supabase Edge Functions**: backend da recomendação.
- **FreeToGame API**: API externa com catálogo de jogos gratuitos.
- **image_picker**: acesso à câmera do celular.
- **flutter_local_notifications**: notificações locais.
- **share_plus**: compartilhamento nativo.
- **http**: chamadas HTTP para a FreeToGame API.

## Requisitos da Ponderada

### Aplicativo mobile

O projeto foi feito em Flutter e deve ser executado como app mobile, principalmente em Android/emulador.

### Mais de duas telas

O app possui várias telas:

- Login.
- Cadastro.
- Descobrir.
- Jogos salvos.
- Recomendação.
- Perfil.

### Navegação funcional

A navegação usa rotas internas e uma barra inferior com as abas principais:

- Descobrir.
- Salvos.
- Indicar.
- Perfil.

### Backend

O backend utilizado é o Supabase. Ele é usado para autenticação, banco de dados, storage e função server-side de recomendação.

### Persistência em banco de dados

Os jogos salvos ficam persistidos no Supabase. O app usa as tabelas:

- `profiles`
- `games`
- `games_to_play`
- `recommendation_sessions`

Na prática, os jogos são salvos assim:

```text
games
= dados do jogo vindo da FreeToGame

games_to_play
= relação entre usuário e jogo salvo
```

### Consumo de API externa

O app consome a FreeToGame API:

```text
https://www.freetogame.com/api/games
```

Ela é usada para listar os jogos gratuitos e também como base para a tela de recomendação.

### Notificações

Quando o usuário salva um jogo, o app dispara uma notificação local:

```text
Jogo salvo
{nome do jogo} foi adicionado aos seus jogos salvos.
```

### Compartilhamento nativo

Os cards dos jogos têm botão **Compartilhar**. Ele usa o pacote `share_plus` para abrir a folha nativa de compartilhamento do Android/iOS com o link do jogo.

O link usado é:

```text
game_url
```

ou, se não existir:

```text
freetogame_profile_url
```

### Recurso de hardware mobile

A tela de Perfil usa a câmera do celular para tirar uma foto de perfil.

Fluxo:

```text
Usuário tira foto
-> app lê a imagem
-> envia para Supabase Storage
-> salva a URL em profiles.avatar_url
```

### Recomendação

A tela de Recomendação permite que o usuário escreva o tipo de jogo que quer jogar.

Exemplo:

```text
Quero um RPG tranquilo, com progressão e sem ser competitivo demais.
```

O Flutter chama uma Supabase Edge Function chamada:

```text
recommend-games
```

A função:

1. Busca jogos populares da FreeToGame.
2. Envia uma lista compacta de candidatos para um serviço externo de recomendação.
3. Pede exatamente 3 recomendações.
4. Retorna jogos reais da FreeToGame.
5. O usuário pode salvar qualquer jogo recomendado.

A recomendação não deve inventar jogos. Ela só retorna jogos presentes na lista enviada pela função.

### Loading e erro

As telas principais possuem estados de carregamento e erro:

- login/cadastro;
- listagem de jogos;
- jogos salvos;
- recomendação;
- perfil/câmera.

### UI organizada

A UI foi feita com Material Design e textos em português. A estrutura foi separada em telas, serviços, modelos, repositórios e widgets.

## Como Rodar o Projeto

### 1. Pré-requisitos

Instale:

- Flutter.
- Android Studio ou emulador Android.
- Supabase CLI.
- Conta/projeto Supabase.
- Chave do serviço externo de recomendação.

No Windows, se aparecer erro de symlink em plugins Flutter, ative o Developer Mode:

```powershell
start ms-settings:developers
```

### 2. Instalar dependências Flutter

Entre na pasta do app:

```powershell
cd C:\Users\Bruno\Documents\ponderada_04\app
flutter pub get
```

### 3. Configurar Supabase no Flutter

O app lê as configurações por Dart defines:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Rode assim:

```powershell
flutter run --dart-define=SUPABASE_URL=SUA_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=SUA_SUPABASE_ANON_KEY
```

Para escolher dispositivo:

```powershell
flutter devices
flutter run -d android --dart-define=SUPABASE_URL=SUA_SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=SUA_SUPABASE_ANON_KEY
```

### 4. Configurar a Edge Function de recomendação

Na raiz do projeto:

```powershell
cd C:\Users\Bruno\Documents\ponderada_04
```

Faça login e link com o projeto Supabase:

```powershell
supabase login
supabase link --project-ref SEU_PROJECT_REF
```

Configure os secrets da função de recomendação conforme o provedor usado no projeto:

```powershell
supabase secrets set RECOMMENDATION_API_KEY=SUA_CHAVE
supabase secrets set RECOMMENDATION_MODEL=MODELO_USADO
supabase secrets set RECOMMENDATION_API_URL=URL_DO_ENDPOINT_COMPATIVEL_COM_CHAT_COMPLETIONS
```

Faça deploy da função:

```powershell
supabase functions deploy recommend-games
```

### 5. Rodar validação básica

Dentro de `app/`:

```powershell
flutter analyze --no-pub
```

## Estrutura Principal

```text
app/lib/
  app/
  core/
  models/
  repositories/
  screens/
  services/
  widgets/

supabase/functions/recommend-games/
  index.ts
```

## Observações

- Chaves de API não devem ser colocadas no código.
- A chave do provedor de recomendação fica como secret da Supabase Edge Function.
- A chave anônima do Supabase é usada pelo app via `--dart-define`.
- A recomendação pode sofrer rate limit dependendo do plano do provedor configurado.
- O app foi pensado como projeto universitário: simples, direto e funcional.

## Checklist Final

- [x] App mobile Flutter.
- [x] Mais de duas telas.
- [x] Navegação funcional.
- [x] Backend com Supabase.
- [x] Persistência em banco.
- [x] API externa FreeToGame.
- [x] Notificações locais.
- [x] Compartilhamento nativo.
- [x] Câmera como recurso de hardware.
- [x] Recomendação.
- [x] Loading e erro nas principais telas.
- [x] UI em português.
- [x] Documentação mínima.
- [ ] Vídeo/demo da aplicação.
- [ ] Repositório público no GitHub.
