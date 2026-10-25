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

## Ferramentas
- `ruby tools/extract_scripts.rb` — exporta scripts e plugins para `scripts/`.
- `ruby tools/map_to_json.rb <id> > m.json && python3 tools/render_map.py m.json m.png` — imagem de um mapa.
