"""F1 — base comum: locais de Kanto no FireRed (pokefirered) e no Fire Ash (maps/).

Um "local" é o que o jogador chama pelo nome: Pewter City inclui o ginásio e as casas, Mt Moon inclui
todos os andares. No FireRed, o local vem do prefixo do nome do mapa (PewterCity_Gym -> Pewter City).
No Fire Ash, cada mapa de Kanto (árvore abaixo dos mapas 204/205) recebe o local cujo nome aparece no
dele; se nenhum aparecer, herda o local do mapa pai (Pewter Gym fica em Pewter City).
"""
import glob
import json
import os
import re
from collections import OrderedDict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

# Ilhas Sevii e mapas fora da jornada (link, protótipos, ilhas de evento) ficam de fora.
SKIP = re.compile(
    r"^(One|Two|Three|Four|Five|Six|Seven)Island|^Prototype|^Navel|^Birth|^Trainer_?Tower|^Battle|Union|Record"
    r"|Link|^TradeCenter|^MtEmber|^BerryForest|^IcefallCave|^RocketWarehouse|^LostCave|^PatternBush"
    r"|^AlteringCave|^TanobyRuins|^TanobyKey|^DottedHole|^SevaultCanyon|^MemorialPillar|^CapeBrink|^KindleRoad"
    r"|^TreasureBeach|^BondBridge|^ResortGorgeous|^WaterLabyrinth|^FiveIsle|^GreenPath|^OutcastIsland"
    r"|^WaterPath|^RuinValley|^TrainerTower|^CanyonEntrance|^SixIsland|^SeavaultCanyon|^MonaChamber"
    r"|^LiptooChamber|^WeepthChamber|^DilfordChamber|^ScufibChamber|^RixyChamber|^ViapoisChamber"
    r"|^SSAnne_Exterior$|^SevenIslandRoute|Unused|^UndergroundPath_NorthSouthTunnel_Unused")


def split_words(name):
    name = name.replace("_", " ")
    return re.sub(r"(?<=[a-z])(?=[A-Z0-9])|(?<=[0-9])(?=[A-Z])", " ", name).strip()


def norm(n):
    n = n.lower().replace("mt.", "mt").replace("mount ", "mt ").replace("pokémon", "pokemon").replace("'", "")
    return re.sub(r"[^a-z0-9]", "", n)


def fr_location(map_name):
    """PewterCity_Gym -> 'Pewter City'; MtMoon_B1F -> 'Mt Moon'; SSAnne_1F_Corridor -> 'SS Anne'."""
    first = map_name.split("_", 1)[0]
    w = split_words(first)
    w = w.replace("Pokemon", "Pokémon").replace("Digletts", "Diglett's").replace("Mt ", "Mt. ")
    return {"SSAnne": "S.S. Anne", "S S Anne": "S.S. Anne", "Silph Co": "Silph Co."}.get(w, w)


def fr_locations(pfr):
    groups = json.load(open(os.path.join(pfr, "data/maps/map_groups.json")))
    locs = OrderedDict()
    for g in groups["group_order"]:
        for m in groups[g]:
            if SKIP.search(m):
                continue
            locs.setdefault(fr_location(m), []).append(m)
    return locs


def load_tree():
    tree = open(os.path.join(ROOT, "maps/_tree.txt"), encoding="utf-8").read().splitlines()
    parent, names, stack = {}, {}, []
    for line in tree:
        depth = (len(line) - len(line.lstrip(" "))) // 2
        mid, name = line.strip().split(" ", 1)
        mid = int(mid)
        stack = stack[:depth] + [mid]
        parent[mid] = stack[-2] if len(stack) > 1 else None
        names[mid] = name
    return parent, names


def kanto_maps():
    parent, names = load_tree()
    out = OrderedDict()
    for mid in names:
        p, chain = mid, []
        while p is not None:
            chain.append(p)
            p = parent[p]
        if 204 in chain or 205 in chain:
            out[mid] = names[mid]
    return out, parent


def _match(fa_name, keys):
    n = norm(fa_name)
    r = re.match(r"^route(\d+)", n)
    best = None
    for key, loc in keys:
        if key.startswith("route"):
            if r and key == "route" + r.group(1):
                return loc
            continue
        if len(key) >= 5 and key in n and (best is None or len(key) > len(best[0])):
            best = (key, loc)
    return best[1] if best else None


def assign_fa(fr_locs):
    """{id do mapa do Fire Ash: local do FireRed ou None}"""
    maps, parent = kanto_maps()
    keys = [(norm(l), l) for l in fr_locs]
    out = {}
    for mid, name in maps.items():
        loc = _match(name, keys)
        if loc is None:
            p = parent.get(mid)
            loc = out.get(p)
        out[mid] = loc
    return out, maps


def fa_map_files():
    files = {}
    for f in glob.glob(os.path.join(ROOT, "maps", "[0-9]*.yaml")):
        files[int(os.path.basename(f).split("_", 1)[0])] = f
    return files


def fa_scripts(path):
    """Linhas de script (comandos 111 condição-script, 355/655 script) de cada evento do mapa."""
    import yaml
    data = yaml.safe_load(open(path, encoding="utf-8"))
    for ev in data.get("events") or []:
        for page in ev.get("pages") or []:
            for c in page.get("commands") or []:
                code, p = c.get("code"), c.get("p") or []
                if code == 111 and len(p) > 1 and p[0] == 12:
                    yield ev, page, str(p[1])
                elif code in (355, 655) and p:
                    yield ev, page, str(p[0])


def inc_labels(pfr):
    """label -> linhas do script (todos os .inc do pokefirered)."""
    labels = {}
    for f in glob.glob(os.path.join(pfr, "data/**/*.inc"), recursive=True):
        cur = None
        for line in open(f, encoding="utf-8", errors="replace"):
            m = re.match(r"^(\w+)::", line)
            if m:
                cur = m.group(1)
                labels[cur] = []
            elif cur:
                labels[cur].append(line.strip())
    return labels
