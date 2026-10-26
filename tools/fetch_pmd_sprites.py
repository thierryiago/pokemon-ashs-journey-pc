"""Baixa sprites de batalha do PMD SpriteCollab para Graphics/RTB/<ESPÉCIE>/.

Uso: python3 tools/fetch_pmd_sprites.py [primeiro_numero] [ultimo_numero]   (padrão: 1 151)

Para cada espécie (forma 0) guarda Walk, Attack, Shoot, Hurt e Idle quando existirem,
mais anim.txt ("Nome largura altura duração,duração,...") e os créditos em
Graphics/RTB/CREDITS.txt. Licença dos sprites: CC BY-NC 4.0 (só uso não comercial,
crédito obrigatório). Folhas do PMD: 8 linhas de direção (baixo, baixo-dir., dir.,
cima-dir., cima, cima-esq., esq., baixo-esq.), um quadro por coluna.
"""
import json
import os
import sys
import urllib.request
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor

import yaml

BASE = "https://raw.githubusercontent.com/PMDCollab/SpriteCollab/master/"
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
OUT = os.path.join(ROOT, "Graphics", "RTB")
WANTED = ["Walk", "Attack", "Shoot", "Hurt", "Idle"]


def get(url):
    with urllib.request.urlopen(url, timeout=60) as r:
        return r.read()


def fetch(species_id, num, credits_by_key):
    folder = f"{num:04d}"
    try:
        xml = get(BASE + f"sprite/{folder}/AnimData.xml")
    except Exception as e:  # sem sprite para esta espécie
        return species_id, None, str(e)
    root = ET.fromstring(xml)
    anims = {}
    for a in root.iter("Anim"):
        name = a.findtext("Name")
        copy = a.findtext("CopyOf")
        anims[name] = a if not copy else ("copy", copy)
    lines = []
    dest = os.path.join(OUT, species_id)
    os.makedirs(dest, exist_ok=True)
    for name in WANTED:
        a = anims.get(name)
        if a is None:
            continue
        if isinstance(a, tuple):  # CopyOf: usa a folha da outra animação
            a = anims.get(a[1])
            if a is None or isinstance(a, tuple):
                continue
            src_name = a.findtext("Name")
        else:
            src_name = name
        fw, fh = a.findtext("FrameWidth"), a.findtext("FrameHeight")
        durs = ",".join(d.text for d in a.iter("Duration"))
        hit = a.findtext("HitFrame") or "-1"
        png = get(BASE + f"sprite/{folder}/{src_name}-Anim.png")
        with open(os.path.join(dest, f"{name}.png"), "wb") as f:
            f.write(png)
        lines.append(f"{name} {fw} {fh} {durs} {hit}")
    with open(os.path.join(dest, "anim.txt"), "w") as f:
        f.write("\n".join(lines) + "\n")
    return species_id, credits_by_key.get(folder), None


def main():
    first = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    last = int(sys.argv[2]) if len(sys.argv) > 2 else 151
    species = yaml.safe_load(open(os.path.join(ROOT, "data", "species.yaml"), encoding="utf-8"))
    targets = [(s["id"], s["id_number"]) for s in species
               if int(s.get("form") or 0) == 0 and first <= s["id_number"] <= last]
    tracker = json.loads(get(BASE + "tracker.json"))
    names = {}
    for line in get(BASE + "credit_names.txt").decode("utf-8").splitlines()[1:]:
        parts = line.split("\t")
        if len(parts) >= 2:
            names[parts[1]] = parts[0]
            names[parts[0]] = parts[0]
    credits_by_key = {}
    for key, entry in tracker.items():
        c = entry.get("sprite_credit") or {}
        people = [c.get("primary")] + list(c.get("secondary") or [])
        credits_by_key[key] = (entry.get("name"), [names.get(p, p) for p in people if p])
    os.makedirs(OUT, exist_ok=True)
    results = []
    with ThreadPoolExecutor(8) as pool:
        for r in pool.map(lambda t: fetch(t[0], t[1], credits_by_key), targets):
            results.append(r)
            sid, credit, err = r
            print(("ok   " if not err else "sem  ") + sid + ("" if not err else f" ({err[:60]})"))
    # Créditos acumulados (mantém espécies baixadas antes)
    cred_path = os.path.join(OUT, "CREDITS.txt")
    old = {}
    if os.path.exists(cred_path):
        for line in open(cred_path, encoding="utf-8"):
            if "\t" in line and not line.startswith("#"):
                k, v = line.rstrip("\n").split("\t", 1)
                old[k] = v
    for sid, credit, err in results:
        if credit:
            old[sid] = ", ".join(credit[1]) or "?"
    with open(cred_path, "w", encoding="utf-8") as f:
        f.write("# Sprites de batalha: PMD SpriteCollab (https://github.com/PMDCollab/SpriteCollab)\n")
        f.write("# Licença CC BY-NC 4.0. CHUNSOFT = sprites originais de Pokémon Mystery Dungeon.\n")
        for k in sorted(old):
            f.write(f"{k}\t{old[k]}\n")


if __name__ == "__main__":
    main()
