"""F1 — custo por arco de Kanto (K01…K09), juntando as matrizes da F1.

Uso: python3 tools/f1/kanto_arcs.py <pasta do pokefirered> > docs/F1-kanto-arcos.md
Lê content/f1_kanto_locais.json (gerado por kanto_trainers_items.py) e docs/F1-kanto-encontros.md.

O custo é em pontos relativos, não em horas: serve para comparar arcos e escolher a ordem da F3.
Pesos (por item de trabalho):
  mapa do FireRed que falta no Fire Ash ............ 3   (montar o mapa no RPG Maker é o mais caro)
  andar que falta numa caverna/prédio que existe ... 2
  treinador do FireRed que falta ................... 0,5
  treinador só do Fire Ash num local do FireRed .... 0,2 (tirar, trocar ou manter como extra)
  local com nível médio diferente em mais de 3 ..... 1   (reajustar o time dos treinadores)
  item que falta / item só do Fire Ash ............. 0,2 / 0,1
  mapa com encontros diferentes .................... 0,3 (os dados do FireRed já estão prontos em content/)
  líder com time diferente ......................... 1
  evento de progressão a mudar ..................... 2
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
import kanto_common as kc  # noqa: E402

ROOT = kc.ROOT
PFR = sys.argv[1]
locs_fr = kc.fr_locations(PFR)
data = json.load(open(os.path.join(ROOT, "content/f1_kanto_locais.json"), encoding="utf-8"))

ARCS = [
    ("K01", "Brock", ["Pallet Town", "Route 1", "Viridian City", "Route 22", "Route 2", "Viridian Forest",
                      "Pewter City"],
     ["Oak entrega o Pokédex e Blue luta no laboratório (FRLG); no Fire Ash o início é o do anime (Pikachu, Gary)",
      "Viridian City: o ginásio do Giovanni (8 treinadores do FireRed) só abre no K08"]),
    ("K02", "Misty", ["Route 3", "Mt. Moon", "Route 4", "Cerulean City", "Route 24", "Route 25"],
     ["Mt. Moon: Team Rocket e a escolha de fóssil (Dome/Helix) do FRLG", "Bill no Sea Cottage dá o ticket do S.S. Anne"]),
    ("K03", "Lt. Surge", ["Route 5", "Underground Path", "Route 6", "Vermilion City", "S.S. Anne", "Route 11",
                          "Diglett's Cave"],
     ["Route 6 e Diglett's Cave não existem no Fire Ash", "S.S. Anne: o Fire Ash troca os treinadores do FRLG por Team Rocket do anime",
      "HM01 Cut no S.S. Anne"]),
    ("K04", "Erika", ["Route 9", "Rock Tunnel", "Route 10", "Power Plant", "Lavender Town", "Route 8", "Route 7",
                      "Celadon City", "Rocket Hideout"],
     ["Route 9, Rock Tunnel e Rocket Hideout não existem no Fire Ash", "Ordem das insígnias: no Fire Ash a 4ª é a Sabrina (anime)",
      "Silph Scope no Rocket Hideout abre a Pokémon Tower"]),
    ("K05", "Koga", ["Pokémon Tower", "Route 12", "Route 13", "Route 14", "Route 15", "Route 16", "Route 17",
                     "Route 18", "Fuchsia City", "Safari Zone"],
     ["Snorlax bloqueando as rotas 12 e 16 (Poké Flute da Pokémon Tower)", "Safari Zone dá HM03 Surf e o Gold Teeth",
      "Rotas 12–15 no Fire Ash têm treinadores de nível ~45 (o FRLG tem ~28)"]),
    ("K06", "Sabrina", ["Saffron City", "Silph Co."],
     ["Silph Co. no Fire Ash é um mapa só, sem os 11 andares nem os treinadores", "Saffron fechada por guardas até o chá (FRLG)",
      "Ordem das insígnias: a Sabrina passa de 4ª para 6ª"]),
    ("K07", "Blaine", ["Route 19", "Route 20", "Seafoam Islands", "Cinnabar Island", "Pokémon Mansion", "Route 21"],
     ["Route 21 não existe no Fire Ash", "Secret Key na Pokémon Mansion abre o ginásio"]),
    ("K08", "Giovanni", ["Route 23", "Victory Road"],
     ["Victory Road e Route 23 (guardas das insígnias) não existem no Fire Ash",
      "Ginásio de Viridian: líder e treinadores do FireRed (o Fire Ash usa o ginásio para o anime)"]),
    ("K09", "Liga", ["Indigo Plateau", "Pokémon League"],
     ["Liga no Fire Ash é a Indigo Conference do anime (torneio); no FRLG é a Elite dos 4 + Blue",
      "Abrir Johto ao vencer a Liga: hoje Johto só abre depois das Ilhas Laranja (switch Beat Drake)"]),
    ("K10", "Pós-jogo", ["Cerulean Cave"], ["Cerulean Cave (Mewtwo) não existe no Fire Ash"]),
]
# O S.S. Anne do FireRed tem 25 mapas porque cada cabine é um mapa; o do Fire Ash junta as cabines em 10.
FLOOR_OVERRIDE = {"S.S. Anne": 4}
LEADER_DIFF = {"K01": 1, "K02": 1, "K03": 1, "K04": 1, "K05": 1, "K06": 1, "K07": 1, "K08": 1, "K09": 5}
PROGRESSION = {"K01": 2, "K02": 1, "K03": 1, "K04": 2, "K05": 2, "K06": 2, "K07": 1, "K08": 1, "K09": 2, "K10": 0}

# Encontros: situação por mapa do FireRed
enc_bad = {}
for line in open(os.path.join(ROOT, "docs/F1-kanto-encontros.md"), encoding="utf-8"):
    cols = [c.strip() for c in line.split("|")]
    if len(cols) < 4 or cols[1] in ("Mapa (FireRed)", "---"):
        continue
    name, status = cols[1], cols[3]
    if not status or status == "igual":
        continue
    loc = None
    for l in locs_fr:
        ln, nn = kc.norm(l), kc.norm(name)
        if (ln.startswith("route") and re.match(rf"^{ln}(?!\d)", nn)) or (not ln.startswith("route") and nn.startswith(ln)):
            loc = l
            break
    if loc:
        enc_bad[loc] = enc_bad.get(loc, 0) + 1


def cost(loc):
    s = data.get(loc)
    if not s:
        return {}
    parts = {}
    if not s["present"]:
        parts["mapas"] = 3 * len(locs_fr.get(loc, []))
    elif loc in FLOOR_OVERRIDE:
        parts["mapas"] = FLOOR_OVERRIDE[loc]
    elif not re.search(r"City|Town|Island$|Route|Plateau", loc):
        # Caverna/prédio que existe com menos andares (Silph Co. tem 1 mapa no Fire Ash e 13 no FireRed)
        parts["mapas"] = 2 * max(0, len(locs_fr.get(loc, [])) - len(s["fa_maps"]))
    parts["treinadores"] = 0.5 * s["missing_trainers"] + 0.2 * s["extra_trainers"]
    if s["level_fr"] and s["level_fa"] and abs(s["level_fr"] - s["level_fa"]) > 3:
        parts["treinadores"] += 1
    parts["itens"] = 0.2 * s["missing_items"] + 0.1 * s["extra_items"] + 0.2 * s["missing_gifts"]
    parts["encontros"] = 0.3 * enc_bad.get(loc, 0)
    return parts


def size(p):
    return "P" if p < 15 else "M" if p < 35 else "G" if p < 60 else "GG"


print("# F1 — Custo por arco de Kanto\n")
print("Gerado por `tools/f1/kanto_arcs.py` juntando as matrizes da F1 (`F1-kanto-mapas`, `-encontros`, "
      "`-treinadores`, `-itens`, `-lideres`, `-flags`). O custo é em **pontos relativos** para comparar os arcos "
      "e escolher a ordem da F3; os pesos estão no topo do script (mapa que falta = 3, treinador que falta = 0,5, "
      "líder com time diferente = 1, evento de progressão = 2...). Tamanho: P < 15, M < 35, G < 60, GG ≥ 60.\n")
rows, total = [], 0
detail = []
for code, leader, places, notes in ARCS:
    agg = {"mapas": 0, "treinadores": 0, "itens": 0, "encontros": 0}
    absent, counts = [], {"tr_fr": 0, "tr_miss": 0, "it_fr": 0, "it_miss": 0}
    for loc in places:
        c = cost(loc)
        for k, v in c.items():
            agg[k] += v
        s = data.get(loc) or {}
        if s and not s["present"]:
            absent.append(f"{loc} ({len(locs_fr.get(loc, []))} mapas)")
        elif s and c.get("mapas"):
            absent.append(f"{loc}: {len(locs_fr.get(loc, []))} mapas no FireRed, {len(s['fa_maps'])} no Fire Ash")
        counts["tr_fr"] += s.get("fr_trainers", 0)
        counts["tr_miss"] += s.get("missing_trainers", 0)
        counts["it_fr"] += s.get("fr_items", 0)
        counts["it_miss"] += s.get("missing_items", 0)
    agg["líder"] = LEADER_DIFF.get(code, 0)
    agg["progressão"] = 2 * PROGRESSION.get(code, 0)
    pts = sum(agg.values())
    total += pts
    rows.append(f"| {code} | {leader} | {', '.join(places)} | {agg['mapas']:.0f} | {agg['treinadores']:.1f} | "
                f"{agg['itens']:.1f} | {agg['encontros']:.1f} | {agg['líder'] + agg['progressão']:.0f} | "
                f"**{pts:.0f} ({size(pts)})** |")
    detail.append(f"### {code} — {leader}\n")
    detail.append(f"- Mapas que faltam: {', '.join(absent) if absent else 'nenhum'}")
    detail.append(f"- Treinadores comuns: {counts['tr_fr']} no FireRed, {counts['tr_miss']} faltam no Fire Ash")
    detail.append(f"- Itens no chão: {counts['it_fr']} no FireRed, {counts['it_miss']} faltam")
    for n in notes:
        detail.append(f"- {n}")
    detail.append("")

print("| Arco | Líder | Locais (ordem do FRLG) | Mapas | Treinadores | Itens | Encontros | Líder + progressão | Total |")
print("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
print("\n".join(rows))
to_build = 0
for code, leader, places, notes in ARCS:
    for loc in places:
        st = data.get(loc)
        if not st:
            continue
        if not st["present"]:
            to_build += len(locs_fr.get(loc, []))
        else:
            c = cost(loc).get("mapas", 0)
            to_build += round(c / 2)
map_pts = sum(sum(cost(l).get("mapas", 0) for l in a[2]) for a in ARCS)
print(f"\n**Total de Kanto: {total:.0f} pontos.** Mapas a construir ou completar: ~{to_build} "
      f"({map_pts:.0f} pontos, {100 * map_pts / total:.0f}% do total).\n")
print("## O que pesa em cada arco\n")
print("\n".join(detail))

print("## Conclusões para a F3\n")
print("- **A ordem da F3 segue a do jogo** (K01 → K10): a progressão é linear e cada arco depende do anterior. "
      "O custo serve para saber onde está o esforço, não para mudar a ordem.")
print("- **Mapas são o gargalo:** ~28% dos pontos e concentrados em K03, K04, K06, K07 e K08 (Route 6, 9, 21 e 23, "
      "Diglett's Cave, Rock Tunnel, Rocket Hideout, os andares da Silph Co. e das Seafoam Islands, Victory Road). "
      "Antes do K03 é preciso decidir como montar mapas novos (RPG Maker XP ou gerados por código a partir do "
      "layout do pokefirered).")
print("- **Treinadores são o maior volume:** 214 dos 330 treinadores comuns do FireRed não estão no Fire Ash, e várias "
      "rotas (12–15, 19) têm treinadores do anime com nível bem acima do FRLG. Os times podem entrar como dados "
      "(como os encontros); os eventos no mapa exigem mexer nos `.rxdata`.")
print("- **Encontros já estão prontos:** as 43 tabelas do FireRed em `content/kanto_encounters_frlg.rb` só precisam "
      "ser ligadas arco a arco.")
print("- **Abertura das regiões (F2):** hoje Johto só abre depois das Ilhas Laranja (switch *Beat Drake*) e Sinnoh "
      "depois da Battle Pyramid (*Beat Pyramid*). Pela regra dos locais do anime, Johto deve abrir ao vencer a Liga "
      "de Kanto (K09) e Sinnoh ao vencer a Liga de Hoenn; Ilhas Laranja e Battle Frontier ficam opcionais. "
      "Ver `F1-kanto-flags.md`.")
print("- **Switches compartilhados:** 132 switches/variáveis usados em Kanto também aparecem em outras regiões "
      "(`F1-kanto-flags.md`); qualquer mudança de progressão na F3 confere essa lista antes.")
