# F1 — matriz de divergências (Fire Ash × jogos originais)

Os scripts comparam os dados exportados (`data/`, `maps/`) com os dados do pret.
Baixar as referências do FireRed e gerar os relatórios:

```bash
mkdir -p /tmp/frlg
curl -sSo /tmp/frlg/wild.json https://raw.githubusercontent.com/pret/pokefirered/master/src/data/wild_encounters.json
curl -sSo /tmp/frlg/map_groups.json https://raw.githubusercontent.com/pret/pokefirered/master/data/maps/map_groups.json
curl -sSo /tmp/frlg/parties.h https://raw.githubusercontent.com/pret/pokefirered/master/src/data/trainer_parties.h
python3 tools/f1/kanto_encounters.py /tmp/frlg/wild.json > docs/F1-kanto-encontros.md
python3 tools/f1/kanto_leaders.py /tmp/frlg/parties.h > docs/F1-kanto-lideres.md
python3 tools/f1/kanto_maps.py /tmp/frlg/map_groups.json > docs/F1-kanto-mapas.md
```

Encontros do FireRed prontos para a F3 (arquivo inativo até ser copiado para `Mods/data/`):

```bash
python3 tools/f1/gen_kanto_encounters.py /tmp/frlg/wild.json   # gera content/kanto_encounters_frlg.rb
```

Treinadores comuns, itens, switches e custo por arco (precisam do pokefirered com os dados dos mapas):

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/pret/pokefirered.git /tmp/pfr
(cd /tmp/pfr && git sparse-checkout set data/maps data/scripts src/data)
python3 tools/f1/kanto_trainers_items.py /tmp/pfr   # docs/F1-kanto-treinadores.md, -itens.md, content/f1_kanto_locais.json
python3 tools/f1/kanto_flags.py > docs/F1-kanto-flags.md
python3 tools/f1/kanto_arcs.py /tmp/pfr > docs/F1-kanto-arcos.md
```

`kanto_common.py` define os locais (Pewter City inclui o ginásio e as casas; Mt. Moon, todos os andares).
