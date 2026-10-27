# B2 — Golpes na batalha em tempo real

Cada efeito da batalha por turno ganhou uma versão em tempo real. "Turnos" viram segundos de luta
(a luta roda a 0,5x, então 10 s de luta são 20 s de relógio). A tabela de efeitos fica em
`Mods/rt_battle/010_moves.rb` (`EFFECTS`, por código de função do Essentials) e a lógica em
`Mods/rt_battle/021_sim_effects.rb`.

**Cobertura:** dos 1.069 golpes do Fire Ash, 946 têm versão em tempo real. Os 123 restantes são golpes
exclusivos do Fire Ash (Z-Moves, Max/G-Max, golpes de assinatura dos treinadores do anime) que nenhum
Pokémon de Kanto a Sinnoh aprende por nível; esses ainda mostram "sem efeito no tempo real".

## Clima e terreno (20 s)

| Golpe | Em tempo real |
|---|---|
| Rain Dance / Sunny Day | Água ou Fogo 1,5x e o outro 0,5x; véu de cor na arena e contador no topo |
| Sandstorm / Hail | 1/16 da vida a cada 1,5 s em quem não é Pedra/Terra/Aço (areia) ou Gelo (granizo) |
| Synthesis, Morning Sun, Moonlight | Curam 66% no sol, 25% em outro clima, 50% sem clima |
| Solar Beam | Carrega 0,8 s a mais, menos no sol; metade do poder em chuva/areia/granizo |
| Electric / Grassy / Psychic Terrain | Golpe do tipo 1,3x; elétrico impede sono; grama cura 1/16 a cada 1,5 s |
| Misty Terrain | Impede status e corta golpes Dragão pela metade |

## Telas e efeitos do lado (15 s)

Reflect e Light Screen cortam o dano pela metade (Aurora Veil faz os dois); Safeguard bloqueia status;
Mist bloqueia quedas de atributo; Lucky Chant impede críticos; Tailwind (12 s) acelera o movimento e a
recarga. Brick Break quebra as telas; Defog limpa telas e armadilhas.

## Armadilhas no chão (40 s)

Spikes, Toxic Spikes, Stealth Rock e Sticky Web são jogados perto do alvo e ficam no chão como marcas.
Quem pisa toma o efeito (Spikes 1/8 da vida, Toxic Spikes envenena, Stealth Rock 1/8 pela eficácia de
Pedra, Sticky Web baixa a Velocidade). Voadores só tomam Stealth Rock. Quem jogou não se machuca.
Rapid Spin limpa as armadilhas do adversário.

## Golpes de dois tempos

| Golpe | Em tempo real |
|---|---|
| Fly, Bounce, Dig, Dive, Phantom Force, Shadow Force | Some por 0,8 s (intocável) e cai em cima do alvo |
| Earthquake/Magnitude (Dig), Surf/Whirlpool (Dive), Gust/Twister/Sky Uppercut (Fly) | Alcançam quem sumiu, com dobro de dano |
| Solar Beam, Razor Wind, Sky Attack, Skull Bash, Geomancy, Meteor Beam | Carregam mais tempo antes de sair |
| Hyper Beam, Giga Impact... | Quem usa fica parado 1 s depois |
| Future Sight, Doom Desire | Caem no alvo depois de 1,2 s |
| Focus Punch | Carrega; se apanhar no meio, perde a concentração |

## Controle do alvo

| Golpe | Em tempo real |
|---|---|
| Recuo (Bite, Headbutt, Fake Out...) | Interrompe o golpe que o alvo estava preparando |
| Wrap, Bind, Fire Spin, Whirlpool... | Prende no lugar por 4 s (sem andar nem esquivar) e tira 1/8 a cada 1,5 s |
| Mean Look, Block, Spider Web | Impede fugir e trocar enquanto quem prendeu estiver em campo |
| Disable / Encore / Taunt / Torment / Spite | Bloqueia o último golpe / só deixa repetir o último / só golpes de dano / não repete / tira PP |
| Attract | 50% de chance de cada golpe falhar por 6 s (gêneros opostos) |
| Foresight, Odor Sleuth, Miracle Eye | Normal/Lutador acertam Fantasma; Psíquico acerta Sombrio |
| Dragon Tail, Circle Throw | Arremessam o alvo para longe (em vez de encerrar a luta) |

## Proteção, substituto e afins

Protect/Detect deixam intocável por 1 s; Spiky Shield, King's Shield, Baneful Bunker e Obstruct revidam
golpes de contato. Feint e Phantom Force quebram a proteção. Endure aguenta com 1 PV. Substitute custa
1/4 da vida e absorve dano e status (golpes de som passam). Magic Coat devolve o próximo golpe de status.

## Golpes que chamam outros

Metronome sorteia um golpe; Mirror Move e Me First usam o último golpe do alvo; Copycat o último usado
na luta; Sleep Talk (funciona dormindo) e Assist usam outro golpe próprio; Nature Power vira Tri Attack
(ou o golpe do terreno). Mimic e Sketch copiam o último golpe do alvo durante a luta.

## Dano especial

False Swipe deixa 1 PV (bom para capturar). Counter, Mirror Coat e Metal Burst devolvem o dano recebido
nos últimos 2 s (Bide, 3 s). Fissure, Horn Drill, Guillotine e Sheer Cold nocauteiam quem tem nível igual
ou menor (carregam 0,5 s a mais). Super Fang, Endeavor, Psywave e Final Gambit seguem a regra do jogo.
Poder variável: Flail/Reversal, Eruption/Water Spout, Wring Out, Gyro Ball, Electro Ball, Low Kick,
Heavy Slam, Hex, Venoshock, Brine, Facade, Revenge/Avalanche, Assurance, Stored Power, Punishment,
Magnitude, Present, Fury Cutter/Rollout (dobram se repetidos em 3 s), Return/Frustration (102).

## Outros

Swift, Aerial Ace e os golpes que "sempre acertam" perseguem o alvo; Lock-On e Mind Reader fazem o
próximo golpe perseguir também. Explosion, Self-Destruct, Memento, Healing Wish e Final Gambit derrubam
quem usa (Healing Wish cura quem entra depois). Perish Song derruba quem estiver em campo depois de 9 s
(trocar salva). U-turn, Volt Switch e Baton Pass trocam o Pokémon do jogador (Baton Pass passa atributos
e substituto). Outrage/Thrash/Petal Dance confundem quem usa. Jump Kick machuca quem erra. Belly Drum,
Pain Split, Psych Up, Power/Guard/Heart Swap, Transform, Conversion, Soak, Trick Room (o lento anda
rápido), Gravity (ninguém esquiva), Wish (cura em 2 s), Ingrain, Leech Seed, Nightmare, Heal Block,
Magnet Rise e Telekinesis também funcionam.

Golpes que dependem de parceiro (Helping Hand, Follow Me, Ally Switch...) e Splash/Celebrate mostram
"Mas nada aconteceu!", como numa luta individual por turno. Golpes ligados a habilidades ou itens
(Skill Swap, Trick, Knock Off...) aplicam só o dano, porque habilidades e itens ainda não contam no tempo
real.

## IA

A IA pesa cada golpe pelo momento: não repete clima ou tela já ativos, não explode com a vida cheia, só
usa Sucker Punch quando o alvo está atacando, Counter depois de apanhar, cura quando está ferida e
Splash quando é a única opção.

## Testes

`test/rt_sim_test.rb` (seção 7) confere os efeitos principais; `test/rt_moves_test.rb` usa cada um dos
1.069 golpes dos dois lados por 6 s de luta e confere que nenhum dá erro.
