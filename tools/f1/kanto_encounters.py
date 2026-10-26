"""F1 — matriz de encontros de Kanto: Fire Ash x FireRed (pret/pokefirered).

Uso: python3 tools/f1/kanto_encounters.py <wild_encounters.json do pokefirered> > docs/F1-kanto-encontros.md
Compara, mapa a mapa, as espécies selvagens (terra, água, pesca, Rock Smash).
"""
import json
import re
import sys
from collections import defaultdict

import yaml

ROOT = __file__.rsplit("/tools/", 1)[0]


def norm(name):
    n = name.lower().replace("mt.", "mt").replace("mount ", "mt ").replace("pokémon", "pokemon")
    n = re.sub(r"[^a-z0-9]", "", n)
    return n


def species_name(s):  # SPECIES_NIDORAN_F -> NIDORANfE (ids do Essentials)
    s = s.replace("SPECIES_", "")
    return {"NIDORAN_F": "NIDORANfE", "NIDORAN_M": "NIDORANmA", "MR_MIME": "MRMIME",
            "FARFETCHD": "FARFETCHD"}.get(s, s.replace("_", ""))


# Árvore de mapas do Fire Ash: pega Kanto (cidades 204 e rotas 205) e tudo abaixo.
tree = open(f"{ROOT}/maps/_tree.txt", encoding="utf-8").read().splitlines()
kanto = {}
stack = []
for line in tree:
    depth = (len(line) - len(line.lstrip(" "))) // 2
    mid, name = line.strip().split(" ", 1)
    mid = int(mid)
    stack = stack[:depth] + [mid]
    if 204 in stack or 205 in stack:
        kanto[mid] = name

encs = yaml.safe_load(open(f"{ROOT}/data/encounters.yaml", encoding="utf-8"))
fa = defaultdict(set)      # nome normalizado -> espécies
fa_names = {}
for e in encs:
    if e["map"] not in kanto or e.get("version", 0) != 0:
        continue
    key = norm(kanto[e["map"]])
    fa_names[key] = f"{kanto[e['map']]} ({e['map']})"
    for slots in (e.get("types") or {}).values():
        for slot in slots:
            fa[key].add(slot[1])

data = json.load(open(sys.argv[1]))
frlg = defaultdict(set)
frlg_names = {}
for e in data["wild_encounter_groups"][0]["encounters"]:
    if not e["base_label"].endswith("_FireRed"):
        continue
    m = e["map"].replace("MAP_", "")
    if re.match(r"(ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN)_ISLAND", m):
        continue  # Sevii fica para depois da Liga
    pretty = m.replace("_", " ").title().replace("Route", "Route ").replace("  ", " ")
    pretty = re.sub(r"Route (\d+) ?(North|South)?", lambda x: f"Route {x.group(1)}" + (f" {x.group(2)}" if x.group(2) else ""), pretty)
    key = norm(re.sub(r" (North|South)$", "", pretty))
    frlg_names[key] = pretty
    for field in ("land_mons", "water_mons", "fishing_mons", "rock_smash_mons"):
        for mon in (e.get(field) or {}).get("mons", []):
            frlg[key].add(species_name(mon["species"]))

print("# F1 — Encontros selvagens de Kanto: Fire Ash × FireRed\n")
print("Gerado por `tools/f1/kanto_encounters.py` a partir de `data/encounters.yaml` e do "
      "[pokefirered](https://github.com/pret/pokefirered) (`src/data/wild_encounters.json`, versão FireRed). "
      "Compara as espécies que aparecem em cada mapa, somando terra, água, pesca e Rock Smash. Ilhas Sevii ficam de fora.\n")
rows = []
for key in sorted(frlg, key=lambda k: frlg_names[k]):
    want = frlg[key]
    have = fa.get(key)
    if have is None:
        same_name = [f"{n} ({i})" for i, n in kanto.items() if norm(n) == key]
        if same_name:
            rows.append((frlg_names[key], same_name[0], "mapa existe, sem encontros", ", ".join(sorted(want)), ""))
        else:
            rows.append((frlg_names[key], "—", "falta o mapa", ", ".join(sorted(want)), ""))
        continue
    missing = sorted(want - have)
    extra = sorted(have - want)
    same = len(want & have)
    status = "igual" if not missing and not extra else f"{same}/{len(want)} iguais"
    rows.append((frlg_names[key], fa_names[key], status, ", ".join(missing), ", ".join(extra)))
total = len(rows)
equal = sum(1 for r in rows if r[2] == "igual")
absent = sum(1 for r in rows if r[1] == "—")
no_table = sum(1 for r in rows if r[2] == "mapa existe, sem encontros")
print(f"**Resumo:** {total} mapas com encontros no FireRed (Route 21 Norte e Sul contam juntas): "
      f"{equal} iguais no Fire Ash, {total - equal - absent - no_table} com espécies diferentes, "
      f"{no_table} com o mapa mas sem encontros e {absent} sem o mapa.\n")
print("| Mapa (FireRed) | Mapa no Fire Ash | Situação | Faltam (FireRed) | Sobram (só no Fire Ash) |")
print("| --- | --- | --- | --- | --- |")
for r in rows:
    print("| " + " | ".join(r) + " |")
only_fa = sorted(set(fa) - set(frlg))
print(f"\n## Mapas de Kanto com encontros só no Fire Ash ({len(only_fa)})\n")
for k in only_fa:
    print(f"- {fa_names[k]}: {', '.join(sorted(fa[k]))}")
