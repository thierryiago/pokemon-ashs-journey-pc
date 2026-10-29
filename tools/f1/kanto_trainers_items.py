"""F1 — treinadores comuns e itens de Kanto: FireRed × Fire Ash, por local.

Uso: python3 tools/f1/kanto_trainers_items.py <pasta do pokefirered>
Gera docs/F1-kanto-treinadores.md, docs/F1-kanto-itens.md e content/f1_kanto_locais.json
(resumo por local, usado no custo por arco).

O pokefirered pode ser baixado só com os dados:
  git clone --depth 1 --filter=blob:none --sparse https://github.com/pret/pokefirered.git pfr
  cd pfr && git sparse-checkout set data/maps data/scripts src/data
"""
import difflib
import json
import os
import re
import sys
from collections import Counter, OrderedDict, defaultdict

import yaml

sys.path.insert(0, os.path.dirname(__file__))
import kanto_common as kc  # noqa: E402

PFR = sys.argv[1]
ROOT = kc.ROOT

# Líderes, Elite dos 4, campeão e rival já estão em F1-kanto-lideres.md.
BOSS_FR = {"LEADER", "ELITE_FOUR", "CHAMPION", "RIVAL_EARLY", "RIVAL_LATE", "RS_LEADER", "RS_ELITE_FOUR",
           "PROFESSOR", "PLAYER", "BOSS"}
BOSS_FA = re.compile(r"^(LEADER|ELITEFOUR|CHAMPION|RIVAL|ARC|SECRET|SYGNA|NC)_|^(PKMNTRAINER|POKEMONTRAINER)")


# ---------------------------------------------------------------- FireRed
def fr_trainers_h():
    txt = open(os.path.join(PFR, "src/data/trainers.h"), encoding="utf-8").read()
    out = {}
    for m in re.finditer(r"\[(TRAINER_\w+)\]\s*=\s*\{(.*?)\n    \},", txt, re.S):
        body = m.group(2)
        cls = re.search(r"TRAINER_CLASS_(\w+)", body)
        name = re.search(r'trainerName = _\("([^"]*)"\)', body)
        party = re.search(r"\((sParty_\w+)\)", body)
        female = "F_TRAINER_FEMALE" in body
        out[m.group(1)] = dict(cls=cls.group(1) if cls else "", name=(name.group(1) if name else "").title(),
                               party=party.group(1) if party else None, female=female)
    ptxt = open(os.path.join(PFR, "src/data/trainer_parties.h"), encoding="utf-8").read()
    levels = {}
    for m in re.finditer(r"(sParty_\w+)\[\]\s*=\s*\{(.*?)\n\};", ptxt, re.S):
        levels[m.group(1)] = [int(x) for x in re.findall(r"\.lvl\s*=\s*(\d+)", m.group(2))]
    for t in out.values():
        t["levels"] = levels.get(t["party"], [])
    return out


def fr_item(c):
    return c.replace("ITEM_", "").replace("_", "")


def fr_data(locs):
    trainers = fr_trainers_h()
    labels = kc.inc_labels(PFR)
    res = {}
    for loc, maps in locs.items():
        tr, balls, hidden, gifts = OrderedDict(), [], [], []
        for m in maps:
            mj = os.path.join(PFR, "data/maps", m, "map.json")
            if not os.path.exists(mj):
                continue
            d = json.load(open(mj))
            seen_scripts = set()
            for o in d.get("object_events") or []:
                script = o.get("script", "")
                seen_scripts.add(script)
                lines = labels.get(script, [])
                if "ITEM_BALL" in o.get("graphics_id", ""):
                    for l in lines:
                        mm = re.match(r"finditem\s+(ITEM_\w+)", l)
                        if mm:
                            balls.append(fr_item(mm.group(1)))
                            break
                    continue
                for l in lines:
                    mm = re.match(r"trainerbattle\w*\s+(TRAINER_\w+)", l)
                    if mm and mm.group(1) in trainers:
                        tr[mm.group(1)] = trainers[mm.group(1)]
            for b in d.get("bg_events") or []:
                if b.get("type") == "hidden_item":
                    hidden.append(fr_item(b["item"]))
            inc = os.path.join(PFR, "data/maps", m, "scripts.inc")
            if os.path.exists(inc):
                for l in open(inc, encoding="utf-8", errors="replace"):
                    mm = re.match(r"\s*giveitem(?:_msg)?\s+(?:\w+,\s*)?(ITEM_\w+)", l.strip())
                    if mm:
                        gifts.append(fr_item(mm.group(1)))
                    mm = re.match(r"\s*trainerbattle\w*\s+(TRAINER_\w+)", l.strip())
                    if mm and mm.group(1) in trainers:
                        tr[mm.group(1)] = trainers[mm.group(1)]
        res[loc] = dict(trainers=[t for t in tr.values() if t["cls"] not in BOSS_FR],
                        bosses=[t for t in tr.values() if t["cls"] in BOSS_FR],
                        balls=balls, hidden=hidden, gifts=gifts)
    return res


# ---------------------------------------------------------------- Fire Ash
def fa_levels():
    data = yaml.safe_load(open(os.path.join(ROOT, "data/trainers.yaml"), encoding="utf-8"))
    out = {}
    for t in data:
        tid = t.get("id") or []
        if len(tid) < 3:
            continue
        out[(str(tid[0]), str(tid[1]), int(tid[2] or 0))] = [p.get("level") for p in t.get("pokemon") or []]
    return out


TB = re.compile(r'pb(?:Double)?TrainerBattle\(\s*:(\w+)\s*,\s*"([^"]*)"(?:\s*,\s*[^,()]*\s*,\s*[^,()]*\s*,\s*(\d+))?')
IB = re.compile(r"pbItemBall\(\s*:(\w+)")
RI = re.compile(r"pbReceiveItem\(\s*:(\w+)")


def fa_data(assign):
    files = kc.fa_map_files()
    levels = fa_levels()
    res = defaultdict(lambda: dict(trainers=OrderedDict(), bosses=OrderedDict(), balls=[], hidden=[], gifts=[],
                                   maps=[]))
    for mid, loc in assign.items():
        if loc is None or mid not in files:
            continue
        r = res[loc]
        r["maps"].append(mid)
        seen_items = set()
        for ev, page, script in kc.fa_scripts(files[mid]):
            for m in TB.finditer(script):
                cls, name, ver = m.group(1), m.group(2), int(m.group(3) or 0)
                key = (cls, name, ver)
                t = dict(cls=cls, name=name, version=ver, levels=levels.get(key, []), map=mid)
                (r["bosses"] if BOSS_FA.search(cls) else r["trainers"]).setdefault(key, t)
            for m in IB.finditer(script):
                k = (mid, ev["id"], m.group(1))
                if k in seen_items:
                    continue
                seen_items.add(k)
                hidden = "hidden" in str(ev.get("name", "")).lower() or not page.get("graphic")
                (r["hidden"] if hidden else r["balls"]).append(m.group(1))
            for m in RI.finditer(script):
                k = (mid, ev["id"], "gift", m.group(1))
                if k in seen_items:
                    continue
                seen_items.add(k)
                r["gifts"].append(m.group(1))
    for r in res.values():
        r["trainers"] = list(r["trainers"].values())
        r["bosses"] = list(r["bosses"].values())
    return res


# ---------------------------------------------------------------- comparação
def tkey_fr(t):
    return re.sub(r"_?(M|F)$", "", t["cls"]).replace("_", "").lower(), t["name"].lower()


def tkey_fa(t):
    return re.sub(r"_?(M|F)$", "", t["cls"]).replace("_", "").lower(), t["name"].lower()


ALIAS = {"teamrocket": "rocketgrunt", "pkmnranger": "pokemonranger", "pkmnbreeder": "pokemonbreeder",
         "superner": "supernerd", "coolcouple": "youngcouple", "crushkin": "crushkin"}


def cls_norm(c):
    c = c.replace("pokemon", "pkmn")
    c = re.sub(r"\d+$", "", c)
    if c.startswith("teamrocket") or c.startswith("rocket"):
        return "rocket"
    return {"coolcouple": "youngcouple", "pkmnrangerf": "pkmnranger"}.get(c, c)


def compare_trainers(fr, fa):
    fa_left = list(fa)
    matched, missing = [], []
    for t in fr:
        c, n = tkey_fr(t)
        same_cls = [x for x in fa_left if cls_norm(tkey_fa(x)[0]) == cls_norm(c)]
        hit = next((x for x in same_cls if tkey_fa(x)[1] == n), None)
        if hit is None:
            hit = next((x for x in fa_left if tkey_fa(x)[1] == n), None)
        if hit is None:   # grafia parecida (Marcos/Marcus, Barny/Barney)
            hit = next((x for x in same_cls if difflib.SequenceMatcher(None, tkey_fa(x)[1], n).ratio() >= 0.8), None)
        if hit is None and n in ("grunt", "") and cls_norm(c) == "rocket":
            # O FireRed não dá nome aos Recrutas; no Fire Ash eles têm nome
            hit = next((x for x in same_cls if not x["name"].lower().startswith(("jessie", "james"))), None)
        if hit is not None:
            fa_left.remove(hit)
            matched.append((t, hit))
        else:
            missing.append(t)
    return matched, missing, fa_left


def avg(xs):
    xs = [x for x in xs if isinstance(x, (int, float))]
    return sum(xs) / len(xs) if xs else None


def item_norm(i):
    i = i.upper().replace("_", "")
    return {"PARLYZHEAL": "PARALYZEHEAL", "XDEFEND": "XDEFENSE", "XSPECIAL": "XSPATK", "ELIXIR": "ELIXIR",
            "THUNDERSTONE": "THUNDERSTONE", "HPUP": "HPUP", "TINYMUSHROOM": "TINYMUSHROOM",
            "NUGGET": "NUGGET", "POKEDOLL": "POKEDOLL", "SILPHSCOPE": "SILPHSCOPE"}.get(i, i)


def multiset_diff(a, b):
    ca, cb = Counter(map(item_norm, a)), Counter(map(item_norm, b))
    return ca - cb, cb - ca, sum((ca & cb).values())


def fmt_t(t):
    lv = "/".join(str(x) for x in t["levels"]) if t["levels"] else "?"
    cls = t["cls"].replace("_", " ").title()
    return f"{cls} {t['name']} ({lv})"


def fmt_items(c):
    return ", ".join(f"{k}" + (f" ×{v}" if v > 1 else "") for k, v in sorted(c.items())) or "—"


def main():
    locs = kc.fr_locations(PFR)
    assign, fa_names = kc.assign_fa(locs)
    fr = fr_data(locs)
    fa = fa_data(assign)
    summary = OrderedDict()
    trows, irows, details_t, details_i = [], [], [], []
    tot = Counter()
    for loc in locs:
        f, a = fr[loc], fa.get(loc)
        present = a is not None and a["maps"]
        a = a or dict(trainers=[], bosses=[], balls=[], hidden=[], gifts=[], maps=[])
        matched, missing, extra = compare_trainers(f["trainers"], a["trainers"])
        lvl_fr = avg([avg(t["levels"]) for t, _ in matched])
        lvl_fa = avg([avg(x["levels"]) for _, x in matched])
        miss_b, extra_b, same_b = multiset_diff(f["balls"] + f["hidden"], a["balls"] + a["hidden"])
        miss_g, extra_g, same_g = multiset_diff(f["gifts"], a["gifts"])
        s = dict(present=bool(present), fa_maps=a["maps"],
                 fr_trainers=len(f["trainers"]), fa_trainers=len(a["trainers"]), matched=len(matched),
                 missing_trainers=len(missing), extra_trainers=len(extra),
                 level_fr=round(lvl_fr, 1) if lvl_fr else None, level_fa=round(lvl_fa, 1) if lvl_fa else None,
                 fr_items=len(f["balls"]) + len(f["hidden"]), fa_items=len(a["balls"]) + len(a["hidden"]),
                 same_items=same_b, missing_items=sum(miss_b.values()), extra_items=sum(extra_b.values()),
                 fr_gifts=len(f["gifts"]), missing_gifts=sum(miss_g.values()))
        summary[loc] = s
        for k in ("fr_trainers", "fa_trainers", "matched", "missing_trainers", "extra_trainers", "fr_items",
                  "fa_items", "same_items", "missing_items", "extra_items"):
            tot[k] += s[k]
        if f["trainers"] or a["trainers"]:
            lv = (f"{s['level_fr']} → {s['level_fa']}" if s["level_fr"] else "—")
            trows.append(f"| {loc} | {'' if present else '**ausente** '}{len(f['trainers'])} | {len(a['trainers'])} | "
                         f"{len(matched)} | {len(missing)} | {len(extra)} | {lv} |")
            if missing or extra:
                details_t.append(f"### {loc}\n")
                if missing:
                    details_t.append("- Faltam: " + "; ".join(fmt_t(t) for t in missing))
                if extra:
                    details_t.append("- Só no Fire Ash: " + "; ".join(fmt_t(t) for t in extra[:25]) +
                                     (f" … (+{len(extra) - 25})" if len(extra) > 25 else ""))
                details_t.append("")
        if f["balls"] or f["hidden"] or a["balls"] or a["hidden"] or f["gifts"]:
            irows.append(f"| {loc} | {'' if present else '**ausente** '}{len(f['balls'])} + {len(f['hidden'])} | "
                         f"{len(a['balls'])} + {len(a['hidden'])} | {same_b} | {sum(miss_b.values())} | "
                         f"{sum(extra_b.values())} | {len(f['gifts'])} / {sum(miss_g.values())} |")
            if miss_b or extra_b or miss_g:
                details_i.append(f"### {loc}\n")
                if miss_b:
                    details_i.append(f"- Faltam no chão: {fmt_items(miss_b)}")
                if extra_b:
                    details_i.append(f"- Só no Fire Ash: {fmt_items(extra_b)}")
                if miss_g:
                    details_i.append(f"- Presentes do FireRed que faltam: {fmt_items(miss_g)}")
                details_i.append("")

    src = ("Gerado por `tools/f1/kanto_trainers_items.py` a partir de `maps/` e do "
           "[pokefirered](https://github.com/pret/pokefirered) (mapas, scripts e `src/data/trainers.h`). ")
    with open(os.path.join(ROOT, "docs/F1-kanto-treinadores.md"), "w", encoding="utf-8") as out:
        out.write("# F1 — Treinadores comuns de Kanto: FireRed × Fire Ash\n\n" + src +
                  "Compara por local (cidade com seus prédios, caverna com todos os andares). Líderes, Elite dos 4, "
                  "campeão e rival estão em `F1-kanto-lideres.md`. Um treinador conta como o mesmo quando nome e "
                  "classe batem; os níveis são a média do time.\n\n")
        out.write(f"**Resumo:** FireRed tem {tot['fr_trainers']} treinadores comuns no continente; o Fire Ash tem "
                  f"{tot['fa_trainers']} nesses locais. **{tot['matched']} batem**, {tot['missing_trainers']} faltam "
                  f"e {tot['extra_trainers']} existem só no Fire Ash (do anime ou de outra versão).\n\n")
        out.write("| Local | FireRed | Fire Ash | Iguais | Faltam | Só no Fire Ash | Nível médio dos iguais (FR → FA) |\n")
        out.write("| --- | --- | --- | --- | --- | --- | --- |\n")
        out.write("\n".join(trows) + "\n\n## Detalhes por local\n\n" + "\n".join(details_t) + "\n")
    with open(os.path.join(ROOT, "docs/F1-kanto-itens.md"), "w", encoding="utf-8") as out:
        out.write("# F1 — Itens de Kanto: FireRed × Fire Ash\n\n" + src +
                  "Itens no chão = Poké Bolas visíveis + itens escondidos. Presentes = itens que um NPC dá "
                  "(`giveitem` no FireRed). Os nomes são comparados sem underline; TMs do FireRed e do Fire Ash "
                  "(Gen 8) têm numeração diferente, então um TM no mesmo lugar pode aparecer como falta + sobra.\n\n")
        out.write(f"**Resumo:** {tot['fr_items']} itens no chão do FireRed e {tot['fa_items']} no Fire Ash nesses "
                  f"locais; **{tot['same_items']} batem**, {tot['missing_items']} faltam e {tot['extra_items']} "
                  f"existem só no Fire Ash.\n\n")
        out.write("| Local | FireRed (visíveis + escondidos) | Fire Ash | Iguais | Faltam | Só no Fire Ash | "
                  "Presentes FR / faltam |\n| --- | --- | --- | --- | --- | --- | --- |\n")
        out.write("\n".join(irows) + "\n\n## Detalhes por local\n\n" + "\n".join(details_i) + "\n")
    os.makedirs(os.path.join(ROOT, "content"), exist_ok=True)
    json.dump(summary, open(os.path.join(ROOT, "content/f1_kanto_locais.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    print(dict(tot))


main()
