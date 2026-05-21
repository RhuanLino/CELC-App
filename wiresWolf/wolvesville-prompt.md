# Prompt para Claude Code — Wolvesville Local (NestJS + SQLite + Capacitor)

## Visão Geral do Projeto

Crie um jogo multiplayer local inspirado no Wolvesville Classic (jogo de lobisomem/mafia). O backend roda em **NestJS** com banco **SQLite** via **TypeORM**. Os jogadores acessam pelo celular via app **Capacitor** na mesma rede Wi-Fi. O NestJS deve subir em `0.0.0.0` para aceitar conexões externas na rede local. CORS deve estar liberado. O frontend é uma SPA simples (pode ser Vue ou React com Capacitor) que consome a API REST + WebSocket do backend.

---

## Stack Técnica

- **Backend:** NestJS + TypeORM + SQLite (`game.db`)
- **Comunicação em tempo real:** Socket.IO (via `@nestjs/websockets`)
- **Frontend:** React ou Vue + Capacitor (empacotado como app mobile)
- **Banco:** SQLite — zero configuração, arquivo local

---

## Estrutura Geral do Jogo

O jogo é gerenciado por um **Mestre do Jogo** (host), que cria a partida no dispositivo que roda o servidor. Os demais jogadores entram via IP local pelo celular.

### Fluxo Completo

```
Lobby → Distribuição de Funções → Primeira Noite → Loop(Amanhecer → Discussão → Votação → Noite) → Fim de Jogo
```

---

## Fase 1 — Lobby

- Host cria a partida e define quais funções estarão disponíveis no pool.
- Jogadores entram informando um nome.
- Mínimo de jogadores: 4. Sem máximo definido.
- Host clica em "Iniciar" quando todos estiverem prontos.
- O sistema distribui as funções aleatoriamente entre os jogadores.

---

## Fase 2 — Distribuição de Funções (Primeira Noite — Parte 1)

- Cada jogador, **um por vez**, recebe o celular (ou acessa no próprio dispositivo).
- O app mostra ao jogador:
  1. Qual é a sua função.
  2. A descrição completa do que ela faz.
- O jogador confirma que leu e passa o celular (ou o host controla o fluxo).
- **Nenhuma ação é tomada nesse momento** — é apenas informativo.

---

## Fase 3 — Noite (Primeira e demais)

- O app exibe: **"A aldeia dormiu. É noite."**
- Cada jogador com ação noturna age **um por vez** (o app chama cada um na ordem correta — veja Ordem de Resolução abaixo).
- Jogadores sem ação noturna (ex: Aldeão, Bêbado) não são chamados.
- As ações são registradas mas **não resolvidas ainda** — a resolução acontece no Amanhecer.
- O Bêbado não pode falar em nenhum momento do jogo (o app deve bloquear/ignorar o campo de fala dele no chat de discussão).

### Ordem de Resolução das Ações Noturnas

A ordem abaixo define **em que sequência o sistema processa** as ações, não necessariamente em que ordem os jogadores são chamados para agir (todos agem primeiro, depois o sistema resolve):

1. Cupido (só age na noite 1)
2. Lobo Gatinho (conversão em vez de matar — se usou o poder)
3. Lobisomens (escolhem vítima coletivamente — veja regras dos lobos)
4. Nightmare Werewolf (bloqueia ação de jogador)
5. Caçador de Feras (armadilha ativa — verifica se lobo atacou jogador armadilhado)
6. Médico (protege jogador)
7. Guarda-costas (protege jogador, morre no lugar)
8. Bruxa (salva todos ou envenena um — veja regras da Bruxa)
9. Dama de Vermelho (visita jogador)
10. Vovó Rabugenta (bloqueia voto de jogador no próximo dia)
11. Assassino (mata jogador — neutro)
12. Incendiário (encharcar ou queimar)
13. Feiticeira (investiga se alvo é Vidente ou Lobo)
14. Lobo Vidente (descobre função do alvo)
15. Detetive (compara times de dois jogadores)
16. Vigilante (investiga função OU atira — não ambos na mesma noite)
17. Franco-atirador (marca alvo ou executa alvo marcado na noite anterior)
18. Inquisidor (mata se alvo for de seita — **função removida do jogo, ignorar**)
19. Ladrão de Túmulos (na noite 1 escolhe alvo para assumir função se morrer)
20. Padre (usa água benta)

---

## Fase 4 — Amanhecer

- O app exibe: **"Amanheceu. A aldeia acorda."**
- O sistema resolve todas as ações da noite na ordem acima e exibe o resumo.
- O resumo segue as regras de revelação abaixo.

### Regras de Revelação de Morte/Ação

**Regra geral:** quando alguém morre, o app anuncia apenas **"[Nome] morreu."** — sem revelar a função, sem revelar a causa, sem revelar quem matou.

**Exceções — funções que revelam ao AGIR (efeito público):**

| Função | O que é revelado |
|---|---|
| Pacifista | Revela a função do jogador alvo escolhido por ele + cancela a votação do dia. O Pacifista em si NÃO é revelado. |
| Prefeito | Revela a si mesmo quando ativa o dobro de voto. |
| Pistoleiro | Revela a si mesmo após o **primeiro** tiro (o segundo pode ser dado sem revelar novamente, mas a função já é pública). |
| Lobo Sombrio | Ativa o poder publicamente, mas **não revela** quem é (o bot anuncia "Um poder foi ativado hoje" sem identificar). |
| Presidente | Já começa o jogo com a função revelada para todos. |
| Príncipe Bonitão | Revela a si mesmo ao sobreviver o primeiro linchamento. |
| Idiota | Revela a si mesmo ao sobreviver o primeiro linchamento (perde o voto permanentemente). |
| Padre | O efeito é público (alguém morre ou o Padre morre), mas só se anuncia **"[Nome] morreu."** — não fica claro a causa para os outros. |
| Médium | Revela a si mesmo ao usar o poder de reviver (só ele pode fazer isso, é inevitável). |
| Bobo | Revela a si mesmo ao vencer por linchamento. |

**Exceções — funções que revelam ao MORRER (efeito público da morte):**

| Função | O que é revelado |
|---|---|
| Vingador | Anuncia: **"[Nome do Vingador] morreu e levou [Nome da vítima] junto."** (revela que era Vingador). |
| Lobisomem Filhote | Anuncia: **"[Nome do Filhote] morreu e levou [Nome da vítima] junto."** (revela que era Filhote). |
| Cientista Maluco | Anuncia: **"[Nome] morreu e a substância tóxica matou [Vizinho1] e [Vizinho2]."** (revela que era Cientista Maluco). |

**Tudo mais é silencioso:**
- Guarda-costas morre defendendo → apenas "[Nome] morreu."
- Dama de Vermelho morre visitando lobo → apenas "[Nome] morreu."
- Caçador de Feras: lobo cai na armadilha → apenas "[Nome do lobo] morreu." (sem mencionar armadilha ou Caçador)
- Vigilante atira → apenas "[Nome da vítima] morreu." (Vigilante não é revelado)
- Franco-atirador → apenas "[Nome da vítima] morreu."
- Cupido: casal formado não é anunciado publicamente. Se um morre, o outro morre também — ambos com "[Nome] morreu." sem explicação.
- Bruxa envenena → apenas "[Nome] morreu."
- Assassino mata → apenas "[Nome] morreu."
- Incendiário queima → apenas "[Nome] morreu."
- Lobos matam → apenas "[Nome] morreu." (não anuncia que foram os lobos)

---

## Fase 5 — Discussão

- Após o amanhecer, começa o período de discussão.
- Todos os jogadores vivos podem falar (exceto o Bêbado, que está bloqueado).
- Duração: definida pelo host (pode ser tempo livre ou timer configurável).
- Se o Pacifista usou o poder nessa rodada, a votação é cancelada e o jogo vai direto para a próxima noite.

---

## Fase 6 — Votação

- Cada jogador vivo pode **votar em outro jogador** ou **pular** (se abstiver).
- Vovó Rabugenta pode bloquear o voto de um jogador específico naquele dia (esse jogador não consegue votar).
- Prefeito: seu voto conta como 2.
- Lobo Sombrio: quando ativa, dobra os votos de todos os lobos e oculta todos os votos dos jogadores (ninguém vê quem votou em quem).
- **Resultado:**
  - O jogador com mais votos é expulso (linchado).
  - Em caso de empate, **ninguém é expulso** (empate = impunidade).
  - Idiota: se receber votos suficientes para ser expulso, **não morre** — revela a função e perde o direito de voto permanentemente (só acontece uma vez).
  - Príncipe Bonitão: se receber votos suficientes para ser expulso, **não morre** — revela a função e sobrevive (só acontece uma vez).

---

## Condições de Vitória

Verificar após **cada morte** (incluindo mortes em cadeia) e ao fim da votação:

### Ordem de prioridade das vitórias solo (verificar antes das vitórias de time):

1. **Bobo** — vence se for linchado pela aldeia durante a votação do dia.
2. **Assassino** — vence se for o último jogador vivo.
3. **Incendiário** — vence se for o último jogador vivo.
4. **Caçador de Cabeças** — vence se seu alvo for linchado pela aldeia durante o dia.

### Vitórias de time:

5. **Lobisomens vencem** se o número de lobos vivos for ≥ número de aldeões vivos (independente de neutros).
6. **Aldeões vencem** se todos os lobos estiverem mortos.
7. **Empate/todos mortos** se não restar ninguém.

> Vitórias solo têm prioridade. Se o Bobo for linchado no mesmo turno que os lobos atingiriam maioria, o Bobo vence.

---

## Sistema de Mortes em Cadeia

Algumas mortes disparam mortes adicionais. O sistema deve processar mortes em fila (queue), resolvendo cada efeito antes de passar para o próximo:

- **Vingador** morre → escolhe 1 jogador para morrer junto (pode ser qualquer vivo).
- **Lobisomem Filhote** morre → escolhe 1 jogador para morrer junto.
- **Cientista Maluco** morre → os 2 jogadores vivos mais próximos na ordem de assentos morrem automaticamente.
- **Casal (Cupido)** — se 1 do casal morre, o outro morre imediatamente na mesma resolução.
- **Guarda-costas** — morre no lugar do protegido (se lobos atacam o protegido, Guarda-costas morre, protegido sobrevive).
- **Dama de Vermelho** — se está visitando um lobo ou o alvo dela é morto pelos lobos naquela noite, ela morre também.
- **Amaldiçoado** — se atacado pelos lobos sem proteção, **não morre**: torna-se um Lobisomem Comum. A transformação não é anunciada publicamente.
- **Valentão** — se atacado pelos lobos, sobrevive até o fim do próximo dia (morre ao amanhecer do dia seguinte ao ataque, não na hora).

---

## Funções — Especificações Completas

### Time da Aldeia

**Aldeão**
- Sem ação noturna.
- Participa da discussão e votação.

**Médico**
- Noite: escolhe 1 jogador para proteger (não pode ser o mesmo jogador 2 noites seguidas; pode se proteger).
- Se os lobos atacarem o protegido: o protegido sobrevive.
- Se Guarda-costas também protege o mesmo alvo: Guarda-costas morre, Médico não (o Guarda-costas tem prioridade na absorção do dano).

**Vingador**
- Sem ação noturna.
- Ao morrer (por qualquer causa): escolhe 1 jogador vivo para morrer junto. Essa escolha é pública (veja regras de revelação).

**Bruxa**
- Tem 2 poções, cada uma usável apenas 1 vez no jogo inteiro.
- **Poção de cura:** salva **todos** os jogadores que iam morrer naquela noite (incluindo ela mesma). Não precisa escolher alvo — é AOE.
- **Poção de veneno:** mata 1 jogador específico à sua escolha (pode ser ela mesma? Não — "outro jogador").
- Pode usar as duas poções na mesma noite (uma por decisão, ambas se quiser).
- Morte por veneno não é revelada — apenas "[Nome] morreu."

**Pacifista**
- Dia (durante discussão ou votação): usa 1 vez por jogo.
- Revela publicamente a função de 1 jogador escolhido por ele.
- Cancela completamente a votação daquele dia (ninguém vota, ninguém é expulso).
- O próprio Pacifista NÃO é identificado — o app anuncia a revelação sem dizer quem a causou.

**Padre**
- Noite: usa água benta em 1 jogador (1 vez no jogo).
- Se o alvo for Lobisomem (qualquer tipo): o alvo morre.
- Se o alvo NÃO for Lobisomem: o Padre morre.
- O resultado é silencioso — apenas "[Nome] morreu."

**Prefeito**
- Pode revelar sua função durante o dia (ação voluntária).
- Após revelação: seu voto passa a valer 2 pelo resto do jogo.
- A revelação é permanente e pública.

**Guarda-costas**
- Noite: escolhe 1 jogador para proteger.
- Se os lobos atacarem esse jogador: Guarda-costas morre, protegido sobrevive.
- Morte silenciosa: apenas "[Nome] morreu."

**Detetive**
- Noite: escolhe 2 jogadores.
- Recebe no DM: se os dois pertencem ao mesmo time ou não (não revela as funções, apenas "mesmo time" ou "times diferentes").
- Times para efeito do Detetive: Aldeia vs. Lobos vs. Neutros (cada neutro é seu próprio time).

**Homem Sábio**
- Passivo: nunca pode ser morto pelos lobos à noite (imune ao ataque da matilha).
- Pode ser morto por veneno da Bruxa, Assassino, Incendiário, Padre, Vigilante, etc.

**Príncipe Bonitão**
- Passivo: na primeira vez que a aldeia tentar linchá-lo, ele sobrevive e revela a função.
- A partir daí é tratado como qualquer outro jogador.

**Irmão** (pode haver 2 ou 3 no jogo)
- Ao receber a função, já vê no app quem são os outros Irmãos.
- Sem ação noturna especial além dessa informação.

**Cientista Maluco**
- Sem ação noturna.
- Ao morrer: os 2 jogadores vivos imediatamente adjacentes na ordem de assentos morrem automaticamente.
- Morte em cadeia — os adjacentes também disparam seus efeitos de morte se tiverem (ex: se um adjacente for Vingador, ele escolhe alguém).

**Caçador de Cabeças**
- Ao receber a função: recebe no app o nome do seu alvo (1 jogador aleatório vivo que não seja ele mesmo).
- Objetivo: fazer o alvo ser **linchado** pela aldeia durante o dia.
- Se o alvo morrer de qualquer outra forma (lobos, veneno, etc.): Caçador de Cabeças torna-se Aldeão Comum.
- Se conseguir o linchamento: vence (vitória solo).

**Valentão**
- Passivo: se atacado pelos lobos, não morre imediatamente. Sobrevive o restante daquela noite e o dia seguinte. Morre ao amanhecer do segundo dia após o ataque.
- Pode ser morto normalmente por outros meios durante esse período (votação, veneno, etc.).

**Menino Travesso**
- 1 vez por jogo, durante a noite: escolhe 2 jogadores e troca as funções deles.
- As funções trocadas valem imediatamente (incluindo ações daquela mesma noite se ainda não agiram, a critério da implementação).
- Os jogadores afetados recebem notificação no DM de que sua função foi trocada.

**Dama de Vermelho**
- Noite: escolhe 1 jogador para "visitar".
- Se esse jogador for Lobisomem (ou for morto pelos lobos naquela noite): a Dama morre também.
- Se os lobos tentarem matar a Dama mas ela estiver visitando outro jogador: ela sobrevive (não estava em casa).
- Morte silenciosa.

**Vovó Rabugenta**
- Noite: escolhe 1 jogador. Esse jogador não poderá votar no próximo dia.
- Pode usar todo jogo (toda noite).

**Bêbado**
- Passivo: nunca pode falar durante o jogo (campo de chat bloqueado para ele).
- Sem ação noturna.
- Pode votar normalmente.

**Idiota**
- Passivo: na primeira vez que a aldeia tentar linchá-lo, ele não morre — revela a função e perde o direito de voto permanentemente.
- A partir daí é tratado como Aldeão Comum sem voto.

**Pistoleiro**
- Tem 2 balas.
- Pode atirar **1 bala por dia** (durante o dia, não à noite).
- Após o primeiro tiro: revela a função publicamente.
- O segundo tiro pode ser dado em outro dia; a função já é pública.
- Ao atirar: o alvo morre imediatamente. Anúncio: apenas "[Nome] morreu."

**Vigilante**
- Noite: escolhe entre 2 ações (não pode fazer ambas na mesma noite):
  - **Investigar:** descobre a função exata de 1 jogador (info vai só pro DM dele). Nessa noite, não pode votar no dia seguinte. — *Aguarda confirmação se essa restrição de voto está correta.*
  - **Atirar:** mata 1 jogador. Morte silenciosa. O Vigilante nunca é revelado.

**Franco-atirador**
- Tem 2 flechas.
- Noite N: marca 1 jogador como alvo.
- Noite N+1: pode confirmar o kill (alvo morre) ou trocar o alvo para outro jogador.
- Se tentar matar um Aldeão (qualquer membro do time da aldeia): a flecha se volta e mata o Franco-atirador.
- Se o alvo for Lobo, Neutro: mata normalmente.
- Morte silenciosa em ambos os casos.

**Caçador de Feras**
- Noite: coloca armadilha em 1 jogador.
- Armadilha fica ativa na **próxima noite**.
- O jogador armadilhado não pode ser morto pelos lobos naquela noite (proteção só contra lobos).
- Se os lobos atacarem o jogador armadilhado: o **Lobisomem mais fraco da matilha morre** (hierarquia: Lobisomem Comum primeiro; se só houver especiais, o de menor "poder" — definir ordem na implementação).
- Morte do lobo: silenciosa, apenas "[Nome] morreu."

**Médium**
- 1 vez por jogo: revive 1 jogador morto.
- O jogador revivido volta com a mesma função (sem memória de "morto", age normalmente).
- A ação é pública (o app anuncia que o Médium usou o poder e quem foi revivido — a identidade do Médium é revelada).

**Cupido**
- Age apenas na **noite 1**.
- Escolhe 2 jogadores para formar um casal.
- O casal só vence se ambos forem os 2 últimos vivos (vitória exclusiva do casal — substitui qualquer outra vitória de time para eles).
- Se 1 do casal morre: o outro morre imediatamente.
- O casal sabe quem é o par (notificação no DM). Ninguém mais sabe.
- Cupido pode se incluir no casal? **Sim.**

**Bobo**
- Objetivo solo: ser linchado pela aldeia durante o dia.
- Se for linchado: vence imediatamente (vitória solo, antes de qualquer outra).
- Se morrer de qualquer outra forma (lobos, veneno, etc.): perde.

**Ladrão de Túmulos**
- Noite 1: escolhe 1 jogador alvo.
- Se esse jogador morrer durante o jogo (por qualquer causa): o Ladrão assume a função do morto e passa a jogar com ela.
- Se o alvo nunca morrer: o Ladrão permanece como Ladrão (sem função especial).
- A troca é silenciosa.

### Time dos Lobisomens

**Lobisomem (Comum)**
- Noite: junto com os outros lobos, escolhem 1 jogador para matar.
- Os lobos se comunicam entre si (app deve ter canal/chat exclusivo para lobos ou mostrar os nomes dos outros lobos no DM de cada um).
- O voto da matilha é por maioria; em caso de empate, o sistema escolhe aleatoriamente entre os empatados.

**Lobo Solitário**
- É um Lobisomem Comum em tudo, exceto:
- Só vence se for o **único lobisomem vivo** (se outros lobos ainda estiverem vivos quando a condição de vitória dos lobos for atingida, ele não vence junto — vence sozinho apenas se os outros lobos morreram antes).

**Lobisomem Filhote**
- É um Lobisomem Comum em tudo, exceto:
- Ao morrer: escolhe 1 jogador para morrer junto (igual ao Vingador, mas do time dos lobos).
- Revelação: veja regras de revelação (revela ao morrer com efeito público).

**Amaldiçoado**
- Começa como Aldeão Comum (pertence ao time da aldeia).
- Se os lobos o atacarem sem proteção: não morre — transforma-se em Lobisomem Comum silenciosamente. A transformação não é anunciada.
- A partir da transformação: age como lobo nas noites seguintes.

**Feiticeira**
- Pertence ao time dos lobos, mas **não acorda com a matilha** (não sabe quem são os lobos, não vota na vítima da noite).
- Noite: investiga 1 jogador — recebe no DM se ele é o **Vidente** ou um **Lobisomem** (qualquer tipo). Para qualquer outra função, recebe "nenhum dos dois".

**Lobo Gatinho**
- É um Lobisomem Comum, exceto:
- 1 vez por jogo: em vez de matar o alvo da noite, **converte** o alvo em Lobisomem Comum.
- O convertido descobre sua nova função via DM. A conversão é silenciosa.

**Lobo Vidente**
- É um Lobisomem Comum, exceto:
- Noite: descobre a função exata de 1 jogador (info via DM).
- Se for o último lobo vivo OU se abrir mão do poder: torna-se Lobisomem Comum automaticamente.

**Lobisomem Alfa**
- É um Lobisomem Comum, exceto:
- Seu voto para escolher a vítima da noite conta como 2.

**Lobo Sombrio**
- É um Lobisomem Comum, exceto:
- 1 vez por jogo, durante o dia: ativa um poder que dobra os votos de **todos os lobos** e oculta todos os votos de todos os jogadores (ninguém vê quem votou em quem naquele dia).
- O app anuncia "Um poder foi ativado." sem revelar quem é o Lobo Sombrio.

**Nightmare Werewolf**
- É um Lobisomem Comum, exceto:
- 2 vezes no jogo: escolhe 1 jogador para "dormir" na próxima noite — esse jogador não consegue usar nenhuma habilidade naquela noite.
- O jogador afetado não sabe que foi bloqueado (ou recebe mensagem neutra "você dormiu pesado esta noite").

### Neutros

**Assassino**
- Noite: mata 1 jogador.
- Objetivo: ser o último jogador vivo.
- Imune ao ataque dos lobos? **Não** — pode ser morto normalmente.

**Incendiário**
- Objetivo: ser o último jogador vivo.
- Noite: pode **encharcar** 1 ou 2 jogadores (acumula encharcados ao longo do jogo) OU **queimar** todos os encharcados ao mesmo tempo (matando todos de uma vez).
- Não pode ser morto pelos lobos.
- Morte por queima: silenciosa.

**Cupido** — veja Time da Aldeia (pode ser considerado neutro dependendo de quem forma o casal).

**Bobo** — veja Time da Aldeia (neutro solo).

**Caçador de Cabeças** — veja Time da Aldeia (neutro solo).

**Assassino** e **Incendiário** são os neutros que vencem por "last man standing".

---

## Interações Especiais e Edge Cases

1. **Médico + Amaldiçoado:** se o Médico protege o Amaldiçoado e os lobos o atacam → o ataque é bloqueado → o Amaldiçoado **não se transforma** (o ataque não chegou).
2. **Bruxa (cura) + ataque:** a poção de cura salva todos que iam morrer naquela noite, incluindo vítima dos lobos. Se a Bruxa salvar, ninguém morre dos ataques daquela noite.
3. **Guarda-costas + Médico no mesmo alvo:** Guarda-costas morre (absorve o ataque), Médico não é consumido (o dano foi absorvido antes).
4. **Príncipe Bonitão votado + Idiota votado no mesmo linchamento:** impossível (só 1 pessoa é linchada por vez).
5. **Valentão atacado + protegido:** se o Médico protege o Valentão na noite do ataque, o ataque não passa → Valentão não entra no estado "ferido". A proteção bloqueia tudo.
6. **Franco-atirador + Aldeão:** flecha volta e mata o próprio Franco-atirador. Se o "Aldeão" for na verdade um Amaldiçoado já transformado em lobo, a flecha o mata normalmente (pois ele já é lobo).
7. **Cadeia infinita:** se Cientista Maluco mata um Vingador adjacente, o Vingador escolhe alguém antes de a fila encerrar. Processar via fila de morte — nunca recursão direta.
8. **Presidente morre:** a aldeia perde imediatamente, independente de qualquer outra condição.
9. **Médium revive alguém que já tinha função revelada:** a função continua revelada.
10. **Lobo Gatinho converte Homem Sábio:** o Homem Sábio (que era imune a ataques de lobos) agora é lobo — a imunidade some (ele era imune como aldeão, não como lobo).
11. **Nightmare Werewolf bloqueia Bruxa:** se a Bruxa for bloqueada, ela não pode usar poção naquela noite.
12. **Caçador de Feras + Guarda-costas no mesmo alvo:** a armadilha e a proteção do Guarda-costas coexistem; se os lobos atacam, o Guarda-costas absorve e morre; a armadilha não dispara (o ataque foi absorvido antes de chegar ao armadilhado).

---

## Fim de Jogo

- Quando a condição de vitória é atingida: o app exibe quem venceu.
- **Revela a função de TODOS os jogadores** (vivos e mortos).
- Exibe resumo da partida (mortes por rodada, ações relevantes).

---

## Regras do App / UX

- **Mestre do Jogo (host):** vê o painel de controle. Pode avançar fases manualmente se necessário. Não participa como jogador (ou pode — a critério da implementação, mas separar é mais limpo).
- **DMs (mensagens privadas):** o app deve ter sistema de mensagem privada — cada jogador vê só o que é para ele (sua função, resultados de investigações, notificações de casal, etc.).
- **Chat de discussão:** chat público visível para todos durante a fase de discussão. Bêbado não pode enviar mensagens.
- **Chat de lobos:** canal separado visível apenas para lobos (para coordenarem o voto da noite).
- **Ordem de assentos:** o host define a ordem dos jogadores no lobby (para efeito do Cientista Maluco — "2 vizinhos mais próximos" = posições adjacentes na lista).
- **Timer opcional:** host pode definir timer para discussão e para ações noturnas.
- **Reconexão:** como é rede local, implementar lógica básica de reconexão via Socket.IO.

---

## Banco de Dados — Entidades Sugeridas

```
Game { id, status, phase, round, createdAt }
Player { id, gameId, name, role, isAlive, isRevealed, seatOrder }
NightAction { id, gameId, round, actorId, targetId, actionType }
Vote { id, gameId, round, voterId, targetId }
GameLog { id, gameId, round, phase, event, isPublic }
```

---

## Observações Finais para Implementação

- **Função removida:** Líder da Seita e Inquisidor **não existem** neste jogo — ignorar completamente.
- O servidor NestJS deve rodar em `0.0.0.0` e ter CORS liberado.
- SQLite com TypeORM — usar `better-sqlite3` ou `typeorm sqlite` driver.
- WebSocket (Socket.IO) para notificações em tempo real (fim de fase, mortes, votação).
- REST API para ações (entrar no lobby, submeter ação noturna, submeter voto).
- O frontend Capacitor acessa via `http://[IP_LOCAL]:3000`.
- Separar claramente a lógica de resolução de fases em um `GameEngine` service isolado — facilita testes e manutenção.
