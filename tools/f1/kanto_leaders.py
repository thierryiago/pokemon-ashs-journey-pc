"""F1 — líderes, Elite dos 4 e campeão de Kanto: Fire Ash x FireRed (pret/pokefirered).

Uso: python3 tools/f1/kanto_leaders.py <trainer_parties.h do pokefirered> > docs/F1-kanto-lideres.md
"""
import re
import sys
from collections import defaultdict

import yaml

ROOT = __file__.rsplit("/tools/", 1)[0]
src = open(sys.argv[1], encoding="utf-8").read()

ORDER = [  # ordem do FireRed, com o tipo de treinador do Fire Ash
    ("Brock", "LeaderBrock", "LEADER_Brock"), ("Misty", "LeaderMisty", "LEADER_Misty"),
    ("Lt. Surge", "LeaderLtSurge", "LEADER_Surge"), ("Erika", "LeaderErika", "LEADER_Erika"),
    ("Koga", "LeaderKoga", "LEADER_Koga"), ("Sabrina", "LeaderSabrina", "LEADER_Sabrina"),
    ("Blaine", "LeaderBlaine", "LEADER_Blaine"), ("Giovanni", "LeaderGiovanni", "LEADER_Giovanni"),
    ("Lorelei", "EliteFourLorelei", "ELITEFOUR_Lorelei"), ("Bruno", "EliteFourBruno", "ELITEFOUR_Bruno"),
    ("Agatha", "EliteFourAgatha", "ELITEFOUR_Agatha"), ("Lance", "EliteFourLance", "ELITEFOUR_Lance"),
]


def frlg_party(label):
    m = re.search(r"sParty_%s\[\] = \{(.*?)\n\};" % label, src, re.S)
    if not m:
        return None
    mons = re.findall(r"\.lvl = (\d+),.*?\.species = SPECIES_(\w+)", m.group(1), re.S)
    return [f"{s.replace('_', '').title()} {l}" for l, s in mons]


trainers = yaml.safe_load(open(f"{ROOT}/data/trainers.yaml", encoding="utf-8"))
types = {t["id"] for t in yaml.safe_load(open(f"{ROOT}/data/trainer_types.yaml", encoding="utf-8"))}
by_type = defaultdict(list)
for t in trainers:
    by_type[t["trainer_type"]].append(t)


def fa_parties(ttype):
    out = []
    for t in sorted(by_type.get(ttype, []), key=lambda t: t["version"]):
        team = ", ".join(f"{p['species'].title()} {p['level']}" for p in t["pokemon"])
        out.append(f"v{t['version']}: {team}")
    return out


print("# F1 — Líderes, Elite dos 4 e campeão de Kanto: Fire Ash × FireRed\n")
print("Gerado por `tools/f1/kanto_leaders.py` a partir de `data/trainers.yaml` e do "
      "[pokefirered](https://github.com/pret/pokefirered) (`src/data/trainer_parties.h`). "
      "O Fire Ash tem várias versões (v0, v1…) de cada treinador para revanches e eventos do anime.\n")
print("| # | Treinador | Time no FireRed | Times no Fire Ash |")
print("| --- | --- | --- | --- |")
for i, (name, label, ttype) in enumerate(ORDER, 1):
    frlg = frlg_party(label) or ["?"]
    candidates = [ttype] + [t for t in sorted(by_type) if t.lower().endswith("_" + name.split()[-1].lower())]
    fa = []
    seen = set()
    for c in candidates:
        if c in seen:
            continue
        seen.add(c)
        for line in fa_parties(c):
            fa.append(f"{c} {line}")
    fa_text = "<br>".join(fa[:6]) + ("<br>…" if len(fa) > 6 else "") if fa else "não encontrado"
    print(f"| {i} | {name} | {', '.join(frlg)} | {fa_text} |")
champ = frlg_party("ChampionFirstSquirtle")
print(f"\nCampeão no FireRed (se o jogador escolheu Bulbasaur): Blue com {', '.join(champ)}.")
blue = [t for t in sorted(by_type) if "Blue" in t or "Gary" in t]
print(f"\nTipos de treinador do rival no Fire Ash: {', '.join(blue)}.")
