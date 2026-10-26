"""Gera content/kanto_encounters_frlg.rb: os encontros de Kanto do FireRed no formato de
Mods/010_data_overrides.rb (AJData.encounters), para os mapas que existem no Fire Ash.

Uso: python3 tools/f1/gen_kanto_encounters.py <wild_encounters.json do pokefirered>

O arquivo NÃO é carregado pelo jogo enquanto estiver em content/. Para ativar (fase F3),
copiar para Mods/data/. Mapas de caverna usam o tipo Cave do Essentials; os outros, Land.
"""
import json
import re
import sys
from collections import defaultdict

import yaml

ROOT = __file__.rsplit("/tools/", 1)[0]


def norm(name):  # mesmas regras de kanto_encounters.py
    n = name.lower().replace("mt.", "mt").replace("mount ", "mt ").replace("pokémon", "pokemon")
    return re.sub(r"[^a-z0-9]", "", n)


def species_name(s):  # SPECIES_NIDORAN_F -> NIDORANfE (ids do Essentials)
    s = s.replace("SPECIES_", "")
    return {"NIDORAN_F": "NIDORANfE", "NIDORAN_M": "NIDORANmA", "MR_MIME": "MRMIME"}.get(s, s.replace("_", ""))


def main():
    data = json.load(open(sys.argv[1]))
    tree = open(f"{ROOT}/maps/_tree.txt", encoding="utf-8").read().splitlines()
    kanto, stack = {}, []
    for line in tree:
        depth = (len(line) - len(line.lstrip(" "))) // 2
        mid, name = line.strip().split(" ", 1)
        stack = stack[:depth] + [int(mid)]
        if 204 in stack or 205 in stack:
            kanto[int(mid)] = name
    by_norm = defaultdict(list)
    for mid, name in kanto.items():
        by_norm[norm(name)].append(mid)
    fa_enc = {e["map"]: e for e in yaml.safe_load(open(f"{ROOT}/data/encounters.yaml", encoding="utf-8"))
              if e.get("version", 0) == 0}
    species_ok = {s["id"] for s in yaml.safe_load(open(f"{ROOT}/data/species.yaml", encoding="utf-8"))}

    out = ["# Encontros de Kanto no padrão do FireRed (gerado por tools/f1/gen_kanto_encounters.py).",
           "# Fonte: pret/pokefirered, src/data/wild_encounters.json (versão FireRed).",
           "# Inativo em content/. Para usar, copiar para Mods/data/ (fase F3).", ""]
    done = 0
    for e in data["wild_encounter_groups"][0]["encounters"]:
        if not e["base_label"].endswith("_FireRed"):
            continue
        m = e["map"].replace("MAP_", "")
        if re.match(r"(ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN)_ISLAND", m):
            continue
        pretty = re.sub(r"(_NORTH|_SOUTH)$", "", m).replace("_", " ").title()
        pretty = re.sub(r"^Route(\d+)", r"Route \1", pretty.replace("Route ", "Route"))
        ids = by_norm.get(norm(pretty), [])
        if not ids:
            continue
        cave = bool(re.search(r"CAVE|TUNNEL|MT_MOON|VICTORY_ROAD|SEAFOAM|POWER_PLANT|MANSION|TOWER|ROCKET|DIGLETT", m))
        types, steps = {}, {}

        def slots(field, rates, idx=None):
            mons = (e.get(field) or {}).get("mons") or []
            res = []
            for i, mon in enumerate(mons):
                if idx is not None and i not in idx:
                    continue
                sp = species_name(mon["species"])
                if sp not in species_ok:
                    continue
                res.append(f"[{rates[i]}, :{sp}, {mon['min_level']}, {mon['max_level']}]")
            return res

        if e.get("land_mons"):
            key = "Cave" if cave else "Land"
            types[key] = slots("land_mons", [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1])
            steps[key] = e["land_mons"]["encounter_rate"]
        if e.get("water_mons"):
            types["Water"] = slots("water_mons", [60, 30, 5, 4, 1])
            steps["Water"] = e["water_mons"]["encounter_rate"]
        if e.get("rock_smash_mons"):
            types["RockSmash"] = slots("rock_smash_mons", [60, 30, 5, 4, 1])
            steps["RockSmash"] = e["rock_smash_mons"]["encounter_rate"]
        if e.get("fishing_mons"):
            fr = [70, 30, 60, 20, 20, 40, 40, 15, 4, 1]
            types["OldRod"] = slots("fishing_mons", fr, {0, 1})
            types["GoodRod"] = slots("fishing_mons", fr, {2, 3, 4})
            types["SuperRod"] = slots("fishing_mons", fr, {5, 6, 7, 8, 9})
            for k in ("OldRod", "GoodRod", "SuperRod"):
                steps[k] = e["fishing_mons"]["encounter_rate"]
        for mid in ids:
            old = fa_enc.get(mid)
            out.append(f"# {kanto[mid]} ({mid}) <- FireRed {m}"
                       + (f"; antes no Fire Ash: {', '.join(sorted((old.get('types') or {}).keys()))}" if old else "; sem encontros antes"))
            body = ",\n".join(f"  {k}: [{', '.join(v)}]" for k, v in types.items() if v)
            st = ", ".join(f"{k}: {v}" for k, v in steps.items() if types.get(k))
            out.append(f"AJData.encounters({mid}, step_chances: {{ {st} }}, types: {{\n{body}\n}})\n")
            done += 1
    path = f"{ROOT}/content/kanto_encounters_frlg.rb"
    import os
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8").write("\n".join(out))
    print(f"{done} tabelas geradas em {path}")


if __name__ == "__main__":
    main()
