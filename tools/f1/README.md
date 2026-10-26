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
