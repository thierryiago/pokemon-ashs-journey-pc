# F1 — Custo por arco de Kanto

Gerado por `tools/f1/kanto_arcs.py` juntando as matrizes da F1 (`F1-kanto-mapas`, `-encontros`, `-treinadores`, `-itens`, `-lideres`, `-flags`). O custo é em **pontos relativos** para comparar os arcos e escolher a ordem da F3; os pesos estão no topo do script (mapa que falta = 3, treinador que falta = 0,5, líder com time diferente = 1, evento de progressão = 2...). Tamanho: P < 15, M < 35, G < 60, GG ≥ 60.

| Arco | Líder | Locais (ordem do FRLG) | Mapas | Treinadores | Itens | Encontros | Líder + progressão | Total |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| K01 | Brock | Pallet Town, Route 1, Viridian City, Route 22, Route 2, Viridian Forest, Pewter City | 0 | 13.2 | 3.4 | 1.8 | 5 | **23 (M)** |
| K02 | Misty | Route 3, Mt. Moon, Route 4, Cerulean City, Route 24, Route 25 | 2 | 13.4 | 6.7 | 2.4 | 3 | **28 (M)** |
| K03 | Lt. Surge | Route 5, Underground Path, Route 6, Vermilion City, S.S. Anne, Route 11, Diglett's Cave | 25 | 16.8 | 7.1 | 1.5 | 3 | **53 (G)** |
| K04 | Erika | Route 9, Rock Tunnel, Route 10, Power Plant, Lavender Town, Route 8, Route 7, Celadon City, Rocket Hideout | 24 | 28.1 | 11.2 | 2.4 | 5 | **71 (GG)** |
| K05 | Koga | Pokémon Tower, Route 12, Route 13, Route 14, Route 15, Route 16, Route 17, Route 18, Fuchsia City, Safari Zone | 0 | 37.3 | 9.2 | 4.8 | 5 | **56 (G)** |
| K06 | Sabrina | Saffron City, Silph Co. | 22 | 22.2 | 6.2 | 0.0 | 5 | **55 (G)** |
| K07 | Blaine | Route 19, Route 20, Seafoam Islands, Cinnabar Island, Pokémon Mansion, Route 21 | 14 | 21.8 | 3.6 | 3.9 | 3 | **46 (G)** |
| K08 | Giovanni | Route 23, Victory Road | 12 | 6.0 | 3.6 | 1.2 | 3 | **26 (M)** |
| K09 | Liga | Indigo Plateau, Pokémon League | 0 | 4.0 | 0.0 | 0.0 | 9 | **13 (P)** |
| K10 | Pós-jogo | Cerulean Cave | 9 | 0.0 | 1.8 | 0.9 | 0 | **12 (P)** |

**Total de Kanto: 384 pontos.** Mapas a construir ou completar: ~43 (108 pontos, 28% do total).

## O que pesa em cada arco

### K01 — Brock

- Mapas que faltam: nenhum
- Treinadores comuns: 14 no FireRed, 10 faltam no Fire Ash
- Itens no chão: 11 no FireRed, 6 faltam
- Oak entrega o Pokédex e Blue luta no laboratório (FRLG); no Fire Ash o início é o do anime (Pikachu, Gary)
- Viridian City: o ginásio do Giovanni (8 treinadores do FireRed) só abre no K08

### K02 — Misty

- Mapas que faltam: Mt. Moon: 3 mapas no FireRed, 2 no Fire Ash
- Treinadores comuns: 40 no FireRed, 20 faltam no Fire Ash
- Itens no chão: 31 no FireRed, 22 faltam
- Mt. Moon: Team Rocket e a escolha de fóssil (Dome/Helix) do FRLG
- Bill no Sea Cottage dá o ticket do S.S. Anne

### K03 — Lt. Surge

- Mapas que faltam: Underground Path: 6 mapas no FireRed, 3 no Fire Ash, Route 6 (2 mapas), S.S. Anne: 25 mapas no FireRed, 10 no Fire Ash, Diglett's Cave (3 mapas)
- Treinadores comuns: 35 no FireRed, 14 faltam no Fire Ash
- Itens no chão: 32 no FireRed, 26 faltam
- Route 6 e Diglett's Cave não existem no Fire Ash
- S.S. Anne: o Fire Ash troca os treinadores do FRLG por Team Rocket do anime
- HM01 Cut no S.S. Anne

### K04 — Erika

- Mapas que faltam: Route 9 (1 mapas), Rock Tunnel (2 mapas), Rocket Hideout (5 mapas)
- Treinadores comuns: 61 no FireRed, 43 faltam no Fire Ash
- Itens no chão: 56 no FireRed, 45 faltam
- Route 9, Rock Tunnel e Rocket Hideout não existem no Fire Ash
- Ordem das insígnias: no Fire Ash a 4ª é a Sabrina (anime)
- Silph Scope no Rocket Hideout abre a Pokémon Tower

### K05 — Koga

- Mapas que faltam: nenhum
- Treinadores comuns: 82 no FireRed, 51 faltam no Fire Ash
- Itens no chão: 41 no FireRed, 21 faltam
- Snorlax bloqueando as rotas 12 e 16 (Poké Flute da Pokémon Tower)
- Safari Zone dá HM03 Surf e o Gold Teeth
- Rotas 12–15 no Fire Ash têm treinadores de nível ~45 (o FRLG tem ~28)

### K06 — Sabrina

- Mapas que faltam: Silph Co.: 12 mapas no FireRed, 1 no Fire Ash
- Treinadores comuns: 42 no FireRed, 34 faltam no Fire Ash
- Itens no chão: 30 no FireRed, 29 faltam
- Silph Co. no Fire Ash é um mapa só, sem os 11 andares nem os treinadores
- Saffron fechada por guardas até o chá (FRLG)
- Ordem das insígnias: a Sabrina passa de 4ª para 6ª

### K07 — Blaine

- Mapas que faltam: Seafoam Islands: 5 mapas no FireRed, 1 no Fire Ash, Route 21 (2 mapas)
- Treinadores comuns: 44 no FireRed, 30 faltam no Fire Ash
- Itens no chão: 24 no FireRed, 11 faltam
- Route 21 não existe no Fire Ash
- Secret Key na Pokémon Mansion abre o ginásio

### K08 — Giovanni

- Mapas que faltam: Route 23 (1 mapas), Victory Road (3 mapas)
- Treinadores comuns: 12 no FireRed, 12 faltam no Fire Ash
- Itens no chão: 18 no FireRed, 18 faltam
- Victory Road e Route 23 (guardas das insígnias) não existem no Fire Ash
- Ginásio de Viridian: líder e treinadores do FireRed (o Fire Ash usa o ginásio para o anime)

### K09 — Liga

- Mapas que faltam: nenhum
- Treinadores comuns: 0 no FireRed, 0 faltam no Fire Ash
- Itens no chão: 0 no FireRed, 0 faltam
- Liga no Fire Ash é a Indigo Conference do anime (torneio); no FRLG é a Elite dos 4 + Blue
- Abrir Johto ao vencer a Liga: hoje Johto só abre depois das Ilhas Laranja (switch Beat Drake)

### K10 — Pós-jogo

- Mapas que faltam: Cerulean Cave (3 mapas)
- Treinadores comuns: 0 no FireRed, 0 faltam no Fire Ash
- Itens no chão: 9 no FireRed, 9 faltam
- Cerulean Cave (Mewtwo) não existe no Fire Ash

## Conclusões para a F3

- **A ordem da F3 segue a do jogo** (K01 → K10): a progressão é linear e cada arco depende do anterior. O custo serve para saber onde está o esforço, não para mudar a ordem.
- **Mapas são o gargalo:** ~28% dos pontos e concentrados em K03, K04, K06, K07 e K08 (Route 6, 9, 21 e 23, Diglett's Cave, Rock Tunnel, Rocket Hideout, os andares da Silph Co. e das Seafoam Islands, Victory Road). Antes do K03 é preciso decidir como montar mapas novos (RPG Maker XP ou gerados por código a partir do layout do pokefirered).
- **Treinadores são o maior volume:** 214 dos 330 treinadores comuns do FireRed não estão no Fire Ash, e várias rotas (12–15, 19) têm treinadores do anime com nível bem acima do FRLG. Os times podem entrar como dados (como os encontros); os eventos no mapa exigem mexer nos `.rxdata`.
- **Encontros já estão prontos:** as 43 tabelas do FireRed em `content/kanto_encounters_frlg.rb` só precisam ser ligadas arco a arco.
- **Abertura das regiões (F2):** hoje Johto só abre depois das Ilhas Laranja (switch *Beat Drake*) e Sinnoh depois da Battle Pyramid (*Beat Pyramid*). Pela regra dos locais do anime, Johto deve abrir ao vencer a Liga de Kanto (K09) e Sinnoh ao vencer a Liga de Hoenn; Ilhas Laranja e Battle Frontier ficam opcionais. Ver `F1-kanto-flags.md`.
- **Switches compartilhados:** 132 switches/variáveis usados em Kanto também aparecem em outras regiões (`F1-kanto-flags.md`); qualquer mudança de progressão na F3 confere essa lista antes.
