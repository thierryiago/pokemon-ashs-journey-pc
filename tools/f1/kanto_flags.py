"""F1 — switches e variáveis que os eventos de Kanto usam.

Uso: python3 tools/f1/kanto_flags.py > docs/F1-kanto-flags.md
Para cada switch/variável lido ou mudado num mapa de Kanto: nome, onde muda, onde é lido, e se também
aparece em mapas de outras regiões (esses são os que podem quebrar eventos do anime quando a
progressão de Kanto mudar).
"""
import os
import re
import sys
from collections import defaultdict

import yaml

sys.path.insert(0, os.path.dirname(__file__))
import kanto_common as kc  # noqa: E402

ROOT = kc.ROOT
names = {}
for line in open(os.path.join(ROOT, "maps/_switches_variables.txt"), encoding="utf-8"):
    m = re.match(r"([SV])(\d+) (.*)", line.rstrip("\n"))
    if m:
        names[(m.group(1), int(m.group(2)))] = m.group(3)

kanto, _ = kc.kanto_maps()
_, all_names = kc.load_tree()
files = kc.fa_map_files()
use = defaultdict(lambda: {"set": set(), "read": set()})   # (S|V, id) -> mapas
SW = re.compile(r"\$game_switches\[(\d+)\]\s*(=)?")
VA = re.compile(r"\$game_variables\[(\d+)\]\s*(=|\+=|-=)?")
for mid, path in files.items():
    data = yaml.safe_load(open(path, encoding="utf-8"))
    for ev in data.get("events") or []:
        for page in ev.get("pages") or []:
            cond = page.get("condition") or {}
            for k in ("switch1", "switch2"):
                if cond.get(k):
                    use[("S", int(cond[k]))]["read"].add(mid)
            if cond.get("variable"):
                use[("V", int(cond["variable"][0]))]["read"].add(mid)
            for c in page.get("commands") or []:
                code, p = c.get("code"), c.get("p") or []
                if code == 121 and len(p) >= 2:
                    for i in range(int(p[0]), int(p[1]) + 1):
                        use[("S", i)]["set"].add(mid)
                elif code == 122 and len(p) >= 2:
                    for i in range(int(p[0]), int(p[1]) + 1):
                        use[("V", i)]["set"].add(mid)
                elif code == 111 and len(p) >= 2 and p[0] in (0, 1):
                    use[("S" if p[0] == 0 else "V", int(p[1]))]["read"].add(mid)
                texts = [str(x) for x in p if isinstance(x, str)]
                for t in texts:
                    for m in SW.finditer(t):
                        use[("S", int(m.group(1)))]["set" if m.group(2) else "read"].add(mid)
                    for m in VA.finditer(t):
                        use[("V", int(m.group(1)))]["set" if m.group(2) else "read"].add(mid)


def short(ids, limit=6):
    lst = sorted(ids)
    s = ", ".join(f"{all_names.get(i, '?')} ({i})" for i in lst[:limit])
    return s + (f" … (+{len(lst) - limit})" if len(lst) > limit else "")


rows = []
for key, u in use.items():
    maps = u["set"] | u["read"]
    k_maps = {m for m in maps if m in kanto}
    if not k_maps:
        continue
    others = maps - set(kanto)
    name = names.get(key, "")
    if name.startswith("s:"):
        continue   # switches de script (dia/noite, etc.), não guardam progresso
    rows.append((key, name, u, k_maps, others))

kind_count = {"S": 0, "V": 0}
shared = [r for r in rows if r[4]]
only = [r for r in rows if not r[4]]
for r in rows:
    kind_count[r[0][0]] += 1

print("# F1 — Switches e variáveis dos eventos de Kanto\n")
print("Gerado por `tools/f1/kanto_flags.py` a partir de `maps/` (condições de página, comandos 121/122/111 e "
      "`$game_switches`/`$game_variables` em scripts). Switches de script (dia/noite etc.) ficam de fora.\n")
print(f"**Resumo:** os mapas de Kanto usam **{kind_count['S']} switches** e **{kind_count['V']} variáveis**. "
      f"{len(shared)} deles também aparecem em mapas de outras regiões: são os que exigem cuidado na F3, porque "
      f"mudar quando eles ligam em Kanto pode mexer em eventos de outra região. Os outros {len(only)} só "
      "existem em Kanto.\n")
# Como cada região se abre: páginas de evento que ligam um switch "... Start" / "Start ..."
print("## Como as regiões se abrem no Fire Ash\n")
print("Páginas de evento que ligam os switches de início de região, com a condição de cada uma:\n")
print("| Liga | Condição da página | Mapa / evento |")
print("| --- | --- | --- |")
START = re.compile(r"(^Start |\bStart$|^Postgame$)")
for mid, path in sorted(files.items()):
    data = yaml.safe_load(open(path, encoding="utf-8"))
    for ev in data.get("events") or []:
        for page in ev.get("pages") or []:
            cond = page.get("condition") or {}
            for c in page.get("commands") or []:
                p = c.get("p") or []
                if c.get("code") == 121 and len(p) >= 3 and p[2] == 0:
                    for i in range(int(p[0]), int(p[1]) + 1):
                        n = names.get(("S", i), "")
                        if START.search(n):
                            cs = [f"S{cond[k]:04d} {names.get(('S', int(cond[k])), '')}" for k in ("switch1", "switch2")
                                  if cond.get(k)]
                            print(f"| S{i:04d} {n} | {'; '.join(cs) or '—'} | {all_names.get(mid, '?')} ({mid}), "
                                  f"evento {ev.get('id')} |")
print()
print("## Usados em Kanto e em outras regiões\n")
print("| # | Nome | Muda em | Lido em Kanto | Outras regiões |")
print("| --- | --- | --- | --- | --- |")
for (k, i), name, u, km, others in sorted(shared, key=lambda r: (r[0][0], r[0][1])):
    print(f"| {k}{i:04d} | {name or '—'} | {short(u['set'], 4) or '—'} | {short(km & u['read'], 4) or '—'} | "
          f"{len(others)} mapas: {short(others, 3)} |")
print("\n## Só em Kanto\n")
print("| # | Nome | Muda em | Lido em |")
print("| --- | --- | --- | --- |")
for (k, i), name, u, km, others in sorted(only, key=lambda r: (r[0][0], r[0][1])):
    print(f"| {k}{i:04d} | {name or '—'} | {short(u['set'], 4) or '—'} | {short(u['read'], 4) or '—'} |")
