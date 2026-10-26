# B0 — Protótipo da batalha em tempo real

Plano v0.5, seção 7 (decisões R1–R6). Este protótipo cobre **batalhas selvagens um contra um** e, como opção, **batalhas contra um treinador**.
Continuam por turno: duplas e triplas, batalhas com parceiro, Safari, Concurso de Insetos, batalhas
surfando ou mergulhando, Max Raids, Grandeur Club e qualquer batalha com regra especial (limite de itens,
efeito de campo). Lendários de evento entram em tempo real e respeitam "não pode fugir".

## Como testar

1. Na pasta do jogo: `git pull`.
2. Abra o jogo, carregue um save e ande no mato (a Rota 1 serve).
3. Quando aparecer um Pokémon, a luta acontece **no próprio mapa**, dentro do retângulo branco (13×9 tiles).

| Tecla | Ação |
| --- | --- |
| WASD ou setas | Mover (o Pokémon ataca na direção em que anda; há ajuda na mira) |
| 1, 2, 3, 4 | Golpes (gastam PP; cada um tem recarga) |
| Espaço | Esquiva rápida, invencível durante o movimento |
| F | Poké Bola (sempre acerta; a chance segue a fórmula clássica) |
| Q | Troca para o próximo Pokémon da equipe que pode lutar |
| Segurar Esc/X | Fugir |
| Enter | Pausar / voltar |

No menu **Opções**:

- "Batalha selvagem: Tempo real / Turnos" (padrão: Tempo real);
- "Batalha de treinador: Turnos / Tempo real" (padrão: Turnos, até você testar).

## O que conferir e me contar

- O jogo abre sem erro? (Se der erro ao abrir, a mensagem cita o arquivo de `Mods/` e a linha.)
- Se a batalha em tempo real der erro no meio, o jogo avisa, continua a mesma luta por turno e grava os
  detalhes em `Mods/rt_battle_erros.txt`. Me mande esse arquivo.
- A luta fica fluida? Se travar, diga em que momento (muitos golpes na tela, troca, captura).
- Os Pokémon aparecem com o sprite certo e andando para o lado certo?
- As paredes e árvores bloqueiam o movimento e os disparos?
- O ritmo: a luta está curta ou longa demais? Dá para ajustar em `Mods/000_ash_journey.rb`
  (`RT_DAMAGE_SCALE` e `RT_COOLDOWN_SCALE`).
- EXP, subida de nível, captura (apelido, PC) e fuga funcionam como esperado?

## Como os golpes viram tempo real

`Mods/rt_battle/010_moves.rb` classifica cada um dos 1.069 golpes pela categoria, alvo, flags e código de efeito:

| Família | Regra | Exemplos |
| --- | --- | --- |
| Corpo a corpo | físico com contato | Tackle, Scratch |
| Avanço | contato com prioridade ou recuo | Quick Attack, Take Down |
| Projétil | sem contato, alvo único | Thunder Shock, Ember, Gust |
| Feixe | nome com BEAM/RAY/CANNON/BLAST | Ice Beam, Solar Beam |
| Área | atinge todos em volta ou é som | Earthquake, Hyper Voice |
| Status | golpe de status no alvo | Thunder Wave, Sleep Powder |
| Redução | status em área que baixa atributos | Growl, Tail Whip |
| Buff | status em si mesmo | Swords Dance, Recover |
| Sem efeito ainda | armadilhas, clima, terreno e efeitos únicos | Spikes, Rain Dance |

Distribuição atual: 283 projéteis, 240 corpo a corpo, 107 área, 51 buffs, 41 feixes, 31 de status,
25 avanços, 6 reduções e 285 ainda sem efeito em tempo real (a maioria golpes de status com efeito único,
como Disable, Encore, armadilhas e clima).

Efeitos de status já tratados: sono, veneno, paralisia, queimadura, congelamento, confusão, mudanças de
atributo, cura, Protect/Detect/Endure, Leech Seed, Rest, Roar/Whirlwind e Teleport (encerram a batalha
selvagem, como no jogo), Haze, Focus Energy/Laser Focus. Precisão e evasão viram velocidade (aproximação).

## Limites conhecidos do protótipo

- Sprites: usa os sprites de seguidor do Fire Ash (4 direções); os do PMD entram no B2.
- Shiny e formas alternativas usam o sprite normal quando não houver arquivo próprio.
- A Poké Bola usada é a mais simples que houver na bolsa (Poké, Great, Ultra, Premier).
- Habilidades, itens segurados e Exp. Share/Exp. All ainda não agem na batalha em tempo real.
- A IA contorna obstáculos e o adversário sempre nasce num ponto alcançável a pé.
- Golpes de efeito único (Protect, Substitute, Teleport, Metronome…) aparecem como "ainda sem efeito".
