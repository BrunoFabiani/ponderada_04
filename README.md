# Free Game Finder

O **Free Game Finder** é um aplicativo mobile feito com a ideia de ajudar pessoas a descobrirem jogos gratuitos que tenham relação com seus interesses e organizar estes jogos dentro do app.

A ideia surgiu a partir de um problema simples: com muitos jogos gratuitos disponíveis é dificil se manter atualizado ou se sentir sobrecarregado. O app vem para facilitar e auxiliar a procura de novos jogos para jogar e também organizar de forma limpa os jogos que te interessam.

## Tecnologias Utilizadas

O aplicativo foi desenvolvido em **Flutter**, usando **Dart**. A escolha do Flutter foi feita pela familiaridade com a tecnologia.

O backend foi feito com **Supabase**, que foi escolhido pela facilidade para configurar autenticação, banco de dados, storage e funções server-side em um mesmo ambiente. Isso ajudou a manter o projeto mais direto, sem precisar criar um backend separado do zero.

As principais tecnologias e pacotes utilizados foram:

- **Flutter** para o desenvolvimento mobile.
- **Supabase Auth** para login e cadastro.
- **Supabase Database** para salvar perfis, jogos e listas do usuário.
- **Supabase Storage** para guardar a foto de perfil.
- **Supabase Edge Function** para a lógica de recomendação.
- **Groq** como serviço externo usado pela função de recomendação.
- **FreeToGame API** para buscar jogos gratuitos reais.
- **image_picker** para usar a câmera do celular.
- **flutter_local_notifications** para notificações locais.
- **share_plus** para compartilhamento nativo.
- **http** para consumo de API externa.

## Organização do Código

O projeto foi organizado em algumas pastas principais para separar melhor as responsabilidades do app.

### Models

Os `models` representam os dados usados dentro do aplicativo. Eles servem para transformar os dados recebidos de APIs ou do Supabase em objetos Dart mais fáceis de usar nas telas.

Alguns exemplos:

- `GameModel`: representa um jogo vindo da FreeToGame API.
- `ProfileModel`: representa o perfil do usuário.
- `GameToPlayModel`: representa a relação entre um usuário e um jogo salvo.
- `GameRecommendationModel`: representa uma recomendação de jogo exibida na tela de recomendação.

Por exemplo, quando a FreeToGame API retorna um JSON de jogo, o app transforma esse JSON em um `GameModel`. Assim, nas telas, fica mais simples acessar campos como título, imagem, gênero, plataforma e link do jogo.

### Services

Os `services` concentram funcionalidades que conversam com APIs externas, recursos do celular ou serviços específicos.

No projeto, os principais services são:

- `FreeToGameApiService`: busca os jogos gratuitos na FreeToGame API.
- `AiRecommendationService`: chama a função de recomendação no Supabase.
- `StorageService`: envia a foto de perfil para o Supabase Storage.
- `NotificationService`: mostra notificações locais quando um jogo é salvo.
- `ShareService`: abre o compartilhamento nativo com o link do jogo.

Essa separação evita que as telas fiquem responsáveis por detalhes técnicos como chamada HTTP, upload de imagem, notificação ou compartilhamento.

### Repositories

Os `repositories` organizam o acesso aos dados principais da aplicação, principalmente quando existe interação com o Supabase.

No projeto:

- `AuthRepository`: cuida de login, cadastro e logout.
- `ProfileRepository`: busca e atualiza o perfil do usuário.
- `GameRepository`: salva jogos, carrega jogos salvos e mantém o cache dos jogos na tabela `games`.
- `RecommendationRepository`: estrutura preparada para sessões de recomendação.

Um exemplo é o processo de salvar jogo. A tela não precisa saber todos os detalhes do banco. Ela chama o `GameRepository`, e ele faz o necessário para salvar o jogo na tabela `games` e criar a relação na tabela `games_to_play`.

## Telas do Aplicativo

### Login

A tela de login permite que o usuário entre com uma conta existente. Ela usa o Supabase Auth para validar e autenticar o usuário.

### Cadastro

A tela de cadastro cria uma nova conta e também registra o perfil do usuário na tabela `profiles`.

### Descobrir

A tela **Descobrir** mostra jogos gratuitos vindos da FreeToGame API. Nela o usuário pode visualizar jogos, filtrar por plataforma e categoria, salvar jogos e compartilhar o link de um jogo.

Essa tela também possui estados de carregamento, erro e lista vazia.

### Jogos Salvos

A tela **Jogos salvos** mostra os jogos que o usuário salvou. Esses dados vêm do Supabase, usando a relação entre as tabelas `games_to_play` e `games`.

### Indicar

A tela **Indicar** permite que o usuário escreva o tipo de jogo que quer encontrar. A aplicação envia esse texto para uma função no Supabase, e essa função se comunica com o Groq para retornar três jogos recomendados com base na lista da FreeToGame.

Os jogos recomendados também podem ser salvos e compartilhados.

### Perfil

A tela **Perfil** mostra informações do usuário e permite tirar uma foto usando a câmera do celular. Essa foto é enviada para o Supabase Storage e a URL é salva no perfil.

## Uso do hardware

O recurso de hardware usado no aplicativo foi a câmera do celular. Essa funcionalidade aparece na tela **Perfil**, onde o usuário pode tirar uma foto para usar como avatar.

Para isso, foi utilizado o pacote `image_picker`. Quando o usuário toca no botão de tirar foto, o app abre a câmera do dispositivo. Depois que a foto é confirmada, o app lê a imagem e envia para o Supabase Storage usando o `StorageService`.

Com isso, o app usa um recurso real do dispositivo mobile e também conecta esse recurso com o backend.

## Tratamento de resposta

O app possui tratamento básico de carregamento e erro nas principais telas.

Na tela **Descobrir**, por exemplo, existe um estado de carregamento enquanto os jogos são buscados na FreeToGame API. Se a requisição falhar, o app mostra uma mensagem de erro:

```text
Não foi possível carregar os jogos. Verifique sua conexão.
```

Na tela **Jogos salvos**, também existe tratamento para casos como:

- Supabase não configurado;
- usuário não logado;
- erro ao carregar os jogos salvos;
- lista vazia.

Na tela **Indicar**, se a função de recomendação falhar, o app mostra uma mensagem avisando que não foi possível gerar recomendações. Também existe loading enquanto a recomendação está sendo buscada.

No salvamento de jogos, o app trata o caso de jogo duplicado. Se o usuário tentar salvar um jogo que já está na lista, ele recebe uma mensagem informando que o jogo já foi salvo.

## Funcionalidade de compartilhamento

O compartilhamento foi implementado com o pacote `share_plus`. Foi criado um `ShareService` para concentrar essa lógica fora das telas.

O app pega o link do jogo usando primeiro o campo:

```text
game_url
```

Se esse campo não existir, usa:

```text
freetogame_profile_url
```

Depois disso, o app chama o compartilhamento nativo do celular. Assim, o usuário pode enviar o link do jogo por WhatsApp, e-mail, mensagens ou qualquer outro app disponível no dispositivo.

Essa funcionalidade aparece nos cards dos jogos, então pode ser usada nos jogos da tela **Descobrir**, nos **Jogos salvos** e também nos jogos retornados pela tela **Indicar**.
