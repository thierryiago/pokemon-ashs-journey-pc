# F1 — Insígnias: como o Fire Ash guarda e em que ordem

Levantado nos eventos dos mapas (`maps/*.yaml`, comandos `$Trainer.badges[N]=true`).

**O Fire Ash já separa as insígnias por região**, em faixas de 8 posições do mesmo vetor
`$Trainer.badges`. Isso facilita a regra D7 (HM pede a insígnia da região atual): basta olhar a faixa
da região. A ordem dentro da faixa segue o anime; nas regiões da campanha principal ela precisa
bater com o jogo original.

| Faixa | Região | Ordem no Fire Ash | Ordem no jogo original | Situação |
| --- | --- | --- | --- | --- |
| 0–7 | Kanto | Brock, Misty, Surge, **Sabrina, Erika, Koga**, Blaine, Giovanni | FRLG: Brock, Misty, Surge, **Erika, Koga, Sabrina**, Blaine, Giovanni | Diferente: Sabrina vem antes (anime) |
| 8–15 | Johto | Falkner, Bugsy, Whitney, Morty, Chuck, Jasmine, Pryce, Clair | SoulSilver: a mesma | Igual (Whitney é dada na Rota 35, mapa 293) |
| 16–23 | Hoenn | Roxanne, Brawly, Wattson, Flannery, Norman, Winona, Tate e Liza, Juan | Emerald: a mesma | Igual (Brawly é dado na Rota 106, mapa 385) |
| 24–31 | Sinnoh | Roark, Gardenia, **Maylene, Wake, Fantina**, Byron, Candice, Volkner | Platinum: Roark, Gardenia, **Fantina, Maylene, Wake**, Byron, Candice, Volkner | Diferente: segue Diamond/Pearl |
| 32–39 | Unova | Cilan, Lenora, Burgh, Elesa, Clay, Skyla, Brycen, Roxie | — (continuação com a história do Fire Ash) | Fica como está |
| 40–47 | Kalos | Viola, Grant, Korrina, Ramos, Clemont, Valerie, Olympia, Wulfric | — | Fica como está |

Alola e Galar não usam o vetor de insígnias (provas e campeonato próprios).

## O que isso muda no plano

- **Kanto (F3):** trocar a ordem de Sabrina e Erika/Koga envolve os bloqueios de caminho (Saffron fechada
  até a hora certa no FRLG) e o índice das insígnias 3–5. Como lojas e obediência contam o total
  (`numbadges`), manter o índice pela ordem do FRLG evita efeitos colaterais.
- **Sinnoh (F6):** passar da ordem de Diamond/Pearl para a de Platinum (Fantina antes de Maylene).
- **Johto e Hoenn:** a ordem já está certa; o trabalho é nos caminhos e eventos.
- **Mapa 48 (laboratório do Oak)** tem um evento "Zephyr Badge Fix" que mexe nas posições 8 e 48: é uma
  correção de saves antigos do Fire Ash e precisa continuar funcionando.
