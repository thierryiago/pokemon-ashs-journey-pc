# Pokémon Ash's Journey (PC)

Mod do Pokémon Fire Ash 3.7.1 (Pokémon Essentials v19.1 + mkxp-z, Ruby 3.0).
Kanto (FRLG) → Johto (SoulSilver) → Hoenn (Emerald) → Sinnoh (Platinum) seguem os jogos originais;
Unova, Kalos, Alola e Galar abrem depois de Sinnoh com a história original do Fire Ash.
Plano: "Plano de Desenvolvimento — Pokémon Ash's Journey v0.5" (doc no claude.ai).

## Regras
- O jogo lê só `Data/*.rxdata` e `Data/*.dat`. Arquivos em `scripts/` são cópia de leitura gerada por `tools/extract_scripts.rb`.
- Tag `upstream-3.7.1` = Fire Ash original intacto. Nunca reescrever.
- Audio/ e Graphics/ (exceto Tilesets e Autotiles) ficam fora do git; o backup é o zip da 3.7.1.
- Locais do anime continuam no jogo, mas não podem bloquear a progressão canônica.
- Desvios do canônico vão para `docs/canon/exceptions.yml`.
- O jogo só roda no Windows do usuário: toda mudança precisa de teste dele no Game.exe.

## Código novo (Mods/)
- Todo código novo fica em `Mods/**/*.rb`, carregado em ordem alfabética pela seção `AJ_ModLoader`
  do `Scripts.rxdata`, **depois dos plugins**. Instalar/atualizar o carregador: `ruby tools/install_loader.rb`.
- Não editar as seções originais do `Scripts.rxdata`; sobrescrever por alias/redefinição em `Mods/`.
- `Mods/000_ash_journey.rb`: configuração geral (batalha em tempo real, ajustes de dano e recarga).
- `Mods/rt_battle/`: batalha em tempo real. `010_moves` e `020_sim` são Ruby puro (testáveis fora do jogo);
  `030_scene` desenha no mapa; `040_hook` troca a batalha selvagem quando possível.
- Testes fora do jogo: `ruby test/rt_sim_test.rb` e `ruby test/rt_scene_test.rb` (dublês do RGSS). Rodar antes de commitar.

## Ferramentas
- `ruby tools/extract_scripts.rb` — exporta scripts e plugins para `scripts/`.
- `ruby tools/dump_data.rb` — exporta os `.dat` (espécies, golpes, treinadores, encontros, itens...) para `data/*.yaml`.
- `ruby tools/dump_maps.rb` — exporta árvore de mapas, eventos de cada mapa e nomes de switches/variáveis para `maps/`.
- Depois de qualquer mudança em `Data/`, rodar os três exportadores de novo e commitar junto.
- `ruby tools/map_to_json.rb <id> > m.json && python3 tools/render_map.py m.json m.png` — imagem de um mapa.
