# 🐺 WiresWolfs

Jogo multiplayer local de lobisomem inspirado no Wolvesville Classic, renomeado para **WiresWolfs**. Backend NestJS + SQLite; frontend React + Capacitor que pode ser usado como webapp ou empacotado como app Android.

## Estrutura

```
wiresWolf/
├── backend/        NestJS + TypeORM + SQLite + Socket.IO
├── frontend/       React + Vite + Capacitor
└── wolvesville-prompt.md   (spec original)
```

## Pré-requisitos

- Node.js 18+
- npm
- Mesma rede Wi-Fi entre o servidor (host) e os celulares

## Backend

```bash
cd backend
npm install
npm run start:dev
```

O servidor sobe em `0.0.0.0:8080`. Quando subir, o console mostra o IP da rede local — algo como:

```
=== WiresWolfs Server ===
Local:    http://localhost:8080
Network:  http://192.168.0.42:8080
=========================
```

O banco é um arquivo `game.db` (SQLite via `sql.js` — pure JS, sem dependência nativa). Apague para começar do zero.

### Endpoints REST

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/roles` | Lista todas as funções |
| POST | `/api/games` | Cria partida (host) |
| POST | `/api/games/:id/join` | Entrar como jogador |
| POST | `/api/games/:id/role-pool` | Host define funções |
| POST | `/api/games/:id/start` | Host inicia partida |
| POST | `/api/games/:id/ack-role` | Jogador confirma que leu sua função |
| POST | `/api/games/:id/night-action` | Submeter ação noturna |
| POST | `/api/games/:id/resolve-night` | Host resolve a noite |
| POST | `/api/games/:id/discussion` | Avançar para discussão |
| POST | `/api/games/:id/start-voting` | Iniciar votação |
| POST | `/api/games/:id/vote` | Votar |
| POST | `/api/games/:id/resolve-votes` | Apurar votação |
| GET | `/api/games/:id/state?token=…` | Estado completo da partida |
| POST | `/api/games/:id/chat` | Enviar mensagem (público ou lobos) |
| GET | `/api/games/:id/wolf-chat?token=…` | Mensagens dos lobos |

### WebSocket

Socket.IO em `/` — o front emite `join_game { gameId, playerToken? }` e recebe `state` / `state_changed`.

## Frontend (web)

```bash
cd frontend
npm install
npm run dev
```

Por padrão o front roda em `http://0.0.0.0:5173`. Acesse pelo celular usando o IP local do PC (ex.: `http://192.168.0.42:5173`). Na tela inicial, ajuste **Servidor** para apontar para o backend NestJS (ex.: `http://192.168.0.42:8080`) e salve.

## Frontend (Capacitor / Android)

1. Edite `frontend/capacitor.config.ts` e troque `server.url` pelo IP do servidor NestJS.
2. Faça o build e adicione a plataforma Android:

```bash
cd frontend
npm run build
npx cap add android
npm run cap:sync
npm run cap:android
```

3. Abra no Android Studio, conecte o celular e instale o APK.

> **Dica:** se preferir não usar Capacitor, basta abrir `http://IP:5173` (modo dev) ou `http://IP:8080` (servindo o build estático separadamente) no navegador do celular — funciona igual.

## Como jogar (fluxo do app)

1. **Mestre do Jogo**: abre o app → "Criar Partida" → recebe um ID.
2. Cada jogador abre o app no celular → "Entrar em Partida" → cola o ID e digita o nome.
3. Host monta o pool de funções (mesma quantidade de jogadores) e aperta **Iniciar Partida**.
4. Fase **Distribuição de Funções**: cada jogador vê sua função no próprio celular e toca em "Li e Entendi".
5. Fase **Noite**: cada jogador com ação age no próprio celular. Host clica em **Resolver Noite**.
6. Fase **Amanhecer**: o app anuncia as mortes silenciosas (apenas `"[Nome] morreu."`, sem revelar funções, conforme regras).
7. Fase **Discussão**: chat público. Bêbado bloqueado.
8. Fase **Votação**: cada jogador vota em alguém ou pula. Host aperta **Apurar Votos**.
9. Loop até atingir condição de vitória.

## Regras implementadas

Cobre todo o set de funções e mecânicas descritas em [wolvesville-prompt.md](wolvesville-prompt.md):

- **Aldeia:** Aldeão, Médico, Vingador, Bruxa, Pacifista, Padre, Prefeito, Guarda-costas, Detetive, Homem Sábio, Príncipe Bonitão, Irmão, Cientista Maluco, Caçador de Cabeças, Valentão, Menino Travesso, Dama de Vermelho, Vovó Rabugenta, Bêbado, Idiota, Pistoleiro, Vigilante, Franco-atirador, Caçador de Feras, Médium, Cupido, Ladrão de Túmulos, Presidente.
- **Lobos:** Lobisomem, Lobo Solitário, Lobisomem Filhote, Amaldiçoado, Feiticeira, Lobo Gatinho, Lobo Vidente, Lobisomem Alfa, Lobo Sombrio, Nightmare Werewolf.
- **Neutros:** Assassino, Incendiário, Bobo (Caçador de Cabeças e Cupido também jogam no lado solo/aldeia conforme regras).

Funções removidas explicitamente: **Líder da Seita** e **Inquisidor** (não disponíveis no pool).

### Mortes em cadeia processadas

- Vingador / Lobisomem Filhote (escolha pública)
- Cientista Maluco (mata vizinhos adjacentes)
- Casal do Cupido (um morre, o outro morre junto)
- Guarda-costas absorve ataque dos lobos
- Dama de Vermelho visitando lobo / lobo atacando dama visitante
- Amaldiçoado vira lobo silenciosamente quando atacado
- Valentão sobrevive a noite e morre no amanhecer seguinte

### Vitórias

Ordem de checagem: Bobo (linchado) → Assassino (último vivo) → Incendiário (último vivo) → Caçador de Cabeças (alvo linchado) → Lobos (≥ aldeões vivos) → Aldeia (todos os lobos mortos) → Casal Cupido (últimos 2 vivos) → Lobo Solitário (vence se sozinho na vitória dos lobos).

## Notas

- O servidor sobe em `0.0.0.0` e tem **CORS liberado** — só use em rede local.
- O banco SQLite é recriado por `synchronize: true`; para produção real, troque por `migrations`.
- A função do Vingador / Filhote ao morrer pede escolha pública: o GameEngine guarda em `state.pendingRevenge`; a UI atual ainda não oferece a tela para essa escolha (próximo incremento — basta enviar uma `night-action` com `actionType: 'revenge'` e `targetId` quando o estado tiver `pendingRevenge`).
- Reconexão é via polling (a cada 2.5s) + Socket.IO `state_changed` broadcast. Suficiente para LAN.

## Licença

Uso pessoal e educacional.
