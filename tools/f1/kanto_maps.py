"""F1 — mapas de Kanto: o que existe no FireRed (cidades, rotas e cavernas/prédios especiais) e no Fire Ash.

Uso: python3 tools/f1/kanto_maps.py <map_groups.json do pokefirered> > docs/F1-kanto-mapas.md
Compara por nome (aproximado). Ilhas Sevii e mapas de link/protótipo ficam de fora.
"""
import json
import re
import sys
from collections import OrderedDict

ROOT = __file__.rsplit("/tools/", 1)[0]
SKIP = re.compile(r"^(One|Two|Three|Four|Five|Six|Seven)Island|^Prototype|^Navel|^Birth|^Trainer_?Tower|^Battle|Union|Record|Link")


def split_words(name):
    name = name.replace("_", " ")
    name = re.sub(r"(?<=[a-z])(?=[A-Z0-9])|(?<=[0-9])(?=[A-Z])", " ", name)
    return name


def norm(n):
    n = n.lower().replace("mt.", "mt").replace("mount ", "mt ").replace("pokémon", "pokemon").replace("'", "")
    return re.sub(r"[^a-z0-9]", "", n)


def base(name):
    # "Mt Moon B1 F" -> "Mt Moon"; "Rocket Hideout B4 F" -> "Rocket Hideout"
    w = split_words(name)
    w = re.sub(r"\s+(B?\d+\s*F|Exterior|Interior|Entrance|Back|Room\s*\d+|North|South|Connection|Frontier.*)$", "", w)
    w = re.sub(r"\s+(B?\d+\s*F|Exterior|Interior)$", "", w)
    return w.strip()


groups = json.load(open(sys.argv[1]))
wanted = OrderedDict()
for g in ["gMapGroup_TownsAndRoutes", "gMapGroup_Dungeons", "gMapGroup_SpecialArea"]:
    for m in groups[g]:
        if SKIP.search(m):
            continue
        b = base(m)
        wanted.setdefault(b, []).append(m)

tree = open(f"{ROOT}/maps/_tree.txt", encoding="utf-8").read().splitlines()
kanto = {}
stack = []
for line in tree:
    depth = (len(line) - len(line.lstrip(" "))) // 2
    mid, name = line.strip().split(" ", 1)
    stack = stack[:depth] + [int(mid)]
    if 204 in stack or 205 in stack:
        kanto[int(mid)] = name
fa_by_norm = {}
for mid, name in kanto.items():
    fa_by_norm.setdefault(norm(name), []).append((mid, name))

rows = []
for b, maps in wanted.items():
    key = norm(b)
    if key.startswith("route"):
        hits = [x for k, v in fa_by_norm.items() if k == key for x in v]
    else:
        two = norm(" ".join(split_words(b).split()[:2]))
        hits = [x for k, v in fa_by_norm.items()
                if (len(k) >= 6 and (key in k or k in key)) or (len(two) >= 6 and two in k) for x in v]
    rows.append((b, len(maps), hits))

have = [r for r in rows if r[2]]
miss = [r for r in rows if not r[2]]
print("# F1 — Mapas de Kanto: FireRed × Fire Ash\n")
print("Gerado por `tools/f1/kanto_maps.py` a partir de `maps/_tree.txt` e do "
      "[pokefirered](https://github.com/pret/pokefirered) (`data/maps/map_groups.json`). "
      "Considera cidades, rotas e locais especiais do continente; interiores de casas e lojas e as Ilhas Sevii ficam para depois. "
      "A busca é por nome (aproximada): a lista de encontrados pode incluir a versão do anime de um local "
      "(ex.: a Liga), e um local com outro nome no Fire Ash aparece como ausente. A F1 confere um por um.\n")
print(f"**Resumo:** {len(rows)} locais do FireRed; {len(have)} encontrados no Fire Ash e **{len(miss)} ausentes**.\n")
print(f"## Ausentes no Fire Ash ({len(miss)})\n")
print("| Local do FireRed | Mapas no FireRed |")
print("| --- | --- |")
for b, n, _ in miss:
    print(f"| {b} | {n} |")
print(f"\n## Encontrados ({len(have)})\n")
print("| Local do FireRed | Mapas no FireRed | Mapas no Fire Ash |")
print("| --- | --- | --- |")
for b, n, hits in have:
    shown = ", ".join(f"{name} ({mid})" for mid, name in hits[:4]) + (" …" if len(hits) > 4 else "")
    print(f"| {b} | {n} | {shown} |")
