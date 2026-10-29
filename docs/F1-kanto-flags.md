# F1 — Switches e variáveis dos eventos de Kanto

Gerado por `tools/f1/kanto_flags.py` a partir de `maps/` (condições de página, comandos 121/122/111 e `$game_switches`/`$game_variables` em scripts). Switches de script (dia/noite etc.) ficam de fora.

**Resumo:** os mapas de Kanto usam **189 switches** e **13 variáveis**. 132 deles também aparecem em mapas de outras regiões: são os que exigem cuidado na F3, porque mudar quando eles ligam em Kanto pode mexer em eventos de outra região. Os outros 70 só existem em Kanto.

## Como as regiões se abrem no Fire Ash

Páginas de evento que ligam os switches de início de região, com a condição de cada uma:

| Liga | Condição da página | Mapa / evento |
| --- | --- | --- |
| S0082 Start Johto | S0081 Beat Drake | Professor Oak's Lab (48), evento 7 |
| S0111 Start Hoenn | S0110 Silver Harrison | Professor Oak's Lab (48), evento 7 |
| S0138 Frontier Start | S0135 Ever Grande over | Professor Oak's Lab (48), evento 7 |
| S0152 Sinnoh Start | S0145 Beat Pyramid | Professor Oak's Lab (48), evento 7 |
| S0198 Unova Start | S0197 Lily Done | Professor Oak's Lab (48), evento 7 |
| S0439 Kalos Start | S0245 Reshiram | Professor Oak's Lab (48), evento 21 |
| S0285 Alola Start | S0281 Kalos Done | Professor Oak's Lab (48), evento 21 |
| S0430 Galar Start | S0428 Alola Done | Professor Oak's Lab (48), evento 21 |
| S0429 Postgame | S0564 Return Home | Professor Oak's Lab (48), evento 21 |
| S0572 Terracotta Start | S0145 Beat Pyramid | Route 22 (195), evento 5 |
| S0062 Indigo Start | — | Kanto Pokemon League (198), evento 24 |
| S0456 WCS Start | — | Colossus Ruins (311), evento 9 |
| S0105 Silver Conference Start | — | Johto Pokemon League (350), evento 24 |
| S0478 Darkest Day Start | — | Kanto Power Plant (412), evento 22 |
| S0130 Ever Grande Start | — | Hoenn Pokemon League (464), evento 24 |
| S0150 Aipom Start | S0149 Pyramid.2 | Battle Pyramid (499), evento 10 |
| S0167 Start Tag Battle | — | Battle Hall (557), evento 2 |
| S0551 WCS Master Start | S0546 WCS Steven | Ballonlea Stadium (636), evento 9 |
| S0192 Lily Start | — | Sinnoh Pokemon League (643), evento 19 |
| S0211 Straiton Gym Start | — | Striaton Gym (663), evento 7 |
| S0211 Straiton Gym Start | — | Striaton Gym (663), evento 8 |
| S0211 Straiton Gym Start | — | Striaton Gym (663), evento 9 |
| S0236 Vetress Start | — | Unova Pokemon League (758), evento 24 |
| S0273 Lumiose Start | — | Kalos Pokemon League (869), evento 24 |
| S0289 Start School | S0288 Egg Delivered | Route 1 (889), evento 40 |
| S0300 Start Llillie | S0299 Beat Mall | Pokémon School (891), evento 18 |
| S0401 Malie Start | S0400 Malie Go | Pokémon School (891), evento 18 |
| S0295 Start Lana | S0445 Learnt Z Move; S0294 Classmate Battle 1 | Kukui's House (892), evento 8 |
| S0298 Start Sophocles | S0297 Lana Gyarados | Kukui's House (892), evento 8 |
| S0314 Start Lillie 2 | S0310 Beat Grand Trial 1 | Kukui's House (892), evento 8 |
| S0317 Start Mallow | S0316 Beat Kiawe | Kukui's House (892), evento 8 |
| S0320 Start Gladion | S0319 Beat Mallow | Kukui's House (892), evento 8 |
| S0322 Start Akala | S0321 Beat Gladion | Kukui's House (892), evento 8 |
| S0351 Start UB | S0350 Lillie Lanakila | Kukui's House (892), evento 8 |
| S0388 Start Poni | S0387 Beat Alola Brock | Kukui's House (892), evento 8 |
| S0406 Manalo Start | — | Alola Pokemon League (958), evento 24 |

## Usados em Kanto e em outras regiões

| # | Nome | Muda em | Lido em Kanto | Outras regiões |
| --- | --- | --- | --- | --- |
| S0001 | Starting over | \PN's house (3), Cedolan City Poké Center (9), Lerucean Town Poké Center (24), Pokémon League (36) … (+117) | Pallet House (42), Viridian Pokémon Center (78), Pewter Pokémon Center (84), Cerulean Pokémon Center (93) … (+13) | 104 mapas: \PN's house (3), Cedolan City Poké Center (9), Lerucean Town Poké Center (24) … (+101) |
| S0002 | Seen Pokérus in Poké Center | Cedolan City Poké Center (9), Lerucean Town Poké Center (24), Pokémon League (36), Battle Frontier Poké Center (53) … (+108) | — | 100 mapas: Cedolan City Poké Center (9), Lerucean Town Poké Center (24), Pokémon League (36) … (+97) |
| S0003 | Choosing starter | Pokémon Lab (4), Professor Oak's Lab (48) | Professor Oak's Lab (48) | 1 mapas: Pokémon Lab (4) |
| S0004 | Defeated Gym 1 | Cedolan Gym (10), Pewter Gym (86) | Pallet Town (33), Pallet House (42), Viridian City (43), Route 1 (76) … (+4) | 1 mapas: Cedolan Gym (10) |
| S0005 | Defeated Gym 2 | Route 7 (47), Cerulean Gym (95) | Viridian Pokémon Center (78), Pewter Pokémon Center (84), Pewter Gym (86), Cerulean Gym (95) … (+1) | 1 mapas: Route 7 (47) |
| S0007 | Defeated Gym 4 | Saffron Gym (136) | Viridian Pokémon Center (78), Pewter Pokémon Center (84), Cerulean Pokémon Center (93), Vermilion Pokémon Center (110) … (+4) | 1 mapas: Gate (79) |
| S0009 | Defeated Gym 6 | Fuchsia Gym (178) | Viridian Pokémon Center (78), Pewter Pokémon Center (84), Cerulean Pokémon Center (93), Vermilion Pokémon Center (110) … (+6) | 1 mapas: Gate (79) |
| S0013 | Fossil revival in progress | Cedolan City (7), Pokémon Institute (11), Pewter City (82), Wild Area (187) … (+1) | Pewter Museum of Science (188) | 3 mapas: Cedolan City (7), Pokémon Institute (11), Wild Area (187) |
| S0029 | Has National Dex | Pokémon Lab (4), Professor Oak's Lab (48) | Pallet House (42) | 2 mapas: Pokémon Lab (4), National Park Pavillion (30) |
| S0043 | 3rd Gym Switch | Vermilion Gym (112), Mauville Gym (398) | Vermilion Gym (112) | 1 mapas: Mauville Gym (398) |
| S0044 | 3rd Gym Switch 2 | Vermilion Gym (112), Mauville Gym (398) | Vermilion Gym (112) | 1 mapas: Mauville Gym (398) |
| S0069 | Indigo Done | Indigo Stadium (203), Valencia House (207) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48) | 1 mapas: Valencia House (207) |
| S0072 | Got GS Ball | Valencia House (207) | Pallet Town (33), Pallet House (42), Viridian House (77), Vermilion City (108) | 2 mapas: Valencia House (207), Valencia Island (209) |
| S0081 | Beat Drake | Pummelo Stadium (247) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48), Indigo Plateau (197) … (+1) | 4 mapas: Valencia House (207), Pummelo Island (245), Pummelo Pokémon Center (246) … (+1) |
| S0083 | Beat Gym 9 | Violet Gym (267) | Professor Oak's Lab (48) | 3 mapas: Cherrygrove Pokémon Center (258), Violet Gym (267), Route 36 (294) |
| S0085 | Beat Gym 11 | Route 35 (293) | Magnet Train (135), Oak's Corral (764) | 7 mapas: Cherrygrove Pokémon Center (258), Violet Pokémon Center (264), Azalea Pokémon Center (273) … (+4) |
| S0087 | Beat Gym 13 | Cianwood Gym (321) | Vermilion City (108), Safari Zone Kanto (180) | 10 mapas: Cherrygrove Pokémon Center (258), Violet Pokémon Center (264), Azalea Pokémon Center (273) … (+7) |
| S0088 | Beat Gym 14 | Olivine Gym (330) | Oak's Corral (764) | 5 mapas: Ecruteak City (299), Burned Tower (303), Kimono Dance Theater (304) … (+2) |
| S0110 | Silver Harrison | Professor Oak's Lab (48), Silver Stadium (354) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48) | 3 mapas: Silver Conference (349), Johto Pokemon League (350), Silver Stadium (354) |
| S0111 | Start Hoenn | Professor Oak's Lab (48) | Pallet Town (33), Pallet House (42), Pewter Gym (86), Cerulean Gym (95) … (+2) | 1 mapas: Route 45 (250) |
| S0112 | Met Birch | Professor Birch's Lab (359) | Pallet Town (33), Pallet House (42), Vermilion City (108) | 5 mapas: Valencia House (207), Professor Elm's Lab (253), Johto Pokemon League (350) … (+2) |
| S0115 | Beat Gym 19 | Mauville Gym (398) | Cerulean Gym (95) | 9 mapas: Littleroot Town (357), Oldale Pokémon Center (363), Petalburg City (366) … (+6) |
| S0116 | Beat Gym 20 | Lavaridge Gym (413) | Cerulean Gym (95) | 14 mapas: Oldale Pokémon Center (363), Petalburg City (366), Petalburg House (367) … (+11) |
| S0135 | Ever Grande over | Professor Oak's Lab (48), Grande Top 8 (469) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48) | 2 mapas: Ever Grande Conference (463), Grande Top 8 (469) |
| S0138 | Frontier Start | Professor Oak's Lab (48) | Pallet Town (33), Pallet House (42), Viridian City (43), Pewter City (82) … (+5) | 3 mapas: Petalburg House (367), Route 121 (425), Pacifidlog Town (459) |
| S0140 | Beat Arena | Battle Arena Stage (479) | Saffron City (130), Cinnabar Island (184), Battle Arena (478) | 1 mapas: Gate (79) |
| S0152 | Sinnoh Start | Professor Oak's Lab (48) | Pallet House (42), Professor Oak's Lab (48), Pewter Gym (86), Vermilion City (108) … (+2) | 1 mapas: Petalburg House (367) |
| S0153 | Met Paul | Professor Rowan's Lab (509) | Pallet House (42), Vermilion City (108) | 5 mapas: Valencia House (207), Professor Elm's Lab (253), Professor Birch's Lab (359) … (+2) |
| S0154 | Beat Gym 25 | Oreburgh Gym (530) | Pallet House (42), Oak's Corral (764) | 4 mapas: Sandgem Pokémon Center (505), Jubilife Pokémon Center (519), Route 204 (529) … (+1) |
| S0157 | Beat Gym 28 | Pastoria Gym (600) | Safari Zone Kanto (180) | 13 mapas: Sandgem Pokémon Center (505), Jubilife Pokémon Center (519), Oreburgh Pokémon Center (525) … (+10) |
| S0160 | Beat Gym 31 | Snowpoint Gym (629) | Vermilion City (108) | 14 mapas: Sandgem Pokémon Center (505), Sandgem Town (507), Jubilife Pokémon Center (519) … (+11) |
| S0197 | Lily Done | Professor Oak's Lab (48), Lily Top 4 (647) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48) | 4 mapas: Sunnyshore City (632), Lily of the Valley Island (642), Sinnoh Pokemon League (643) … (+1) |
| S0198 | Unova Start | Professor Oak's Lab (48) | Pallet House (42), Professor Oak's Lab (48), Viridian House (77), Pewter House (83) … (+2) | 4 mapas: Lake Verity (512), Lake Valor (590), Snowpoint City (625) … (+1) |
| S0199 | Met Juniper | Professor Juniper's Lab (653) | Pallet House (42), Professor Oak's Lab (48), Viridian House (77) | 6 mapas: Valencia House (207), Professor Elm's Lab (253), Professor Birch's Lab (359) … (+3) |
| S0200 | Beat Gym 33 | Striaton Gym (663) | Professor Oak's Lab (48) | 5 mapas: Nuvema Town (651), Professor Juniper's Lab (653), Accumula Pokémon Center (657) … (+2) |
| S0203 | Beat Gym 36 | Nimbasa Gym (692) | Safari Zone Kanto (180) | 6 mapas: Accumula Pokémon Center (657), Striaton Pokémon Center (662), Nacrene Pokémon Center (672) … (+3) |
| S0242 | N arc | Professor Juniper's Lab (653) | Pallet House (42) | 4 mapas: Professor Juniper's Lab (653), Virbank City (738), Route 12 (753) … (+1) |
| S0245 | Reshiram | White Ruins (771) | Pallet House (42), Professor Oak's Lab (48), Oak's Corral (764) | 3 mapas: Route 4 (682), Aspertia City (767), White Ruins (771) |
| S0249 | Beat Gym 41 | Santalune Gym (802) | Pewter Gym (86) | 5 mapas: White Ruins (771), Lumiose City (793), Lumiose Pokémon Center (795) … (+2) |
| S0255 | Beat Gym 47 | Anistar Gym (853) | Safari Zone Kanto (180) | 12 mapas: Lumiose City (793), Lumiose Pokémon Center (795), Santalune Pokémon Center (801) … (+9) |
| S0257 | Met Sycamore | Professor Sycamore's Lab (796) | Pallet House (42) | 8 mapas: Valencia House (207), Professor Elm's Lab (253), Professor Birch's Lab (359) … (+5) |
| S0281 | Kalos Done | Professor Oak's Lab (48), Lumiose City (793) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48) | 1 mapas: Lumiose City (793) |
| S0283 | Met Elm | Professor Elm's Lab (253) | Pallet House (42) | 3 mapas: Valencia House (207), New Bark Town (251), Professor Elm's Lab (253) |
| S0285 | Alola Start | Professor Oak's Lab (48) | Pallet House (42), Viridian City (43), Professor Oak's Lab (48), Viridian House (77) … (+1) | 5 mapas: Lumiose City (793), Lumiose House (794), Lumiose Gym (833) … (+2) |
| S0287 | Alola Mom | Route 1 (889) | Viridian House (77) | 1 mapas: Route 1 (889) |
| S0290 | Got Rotom Dex | Kukui's House (892) | Pallet House (42) | 9 mapas: Valencia House (207), Professor Elm's Lab (253), Professor Birch's Lab (359) … (+6) |
| S0312 | Beat Grand Trial 3 | Tapu House (934) | Safari Zone Kanto (180) | 5 mapas: Route 1 (889), Pokémon School (891), Kukui's House (892) … (+2) |
| S0328 | Return to Kanto | Kukui's House (892) | Professor Oak's Lab (48) | 2 mapas: Pokémon School (891), Kukui's House (892) |
| S0329 | Kanto Go | Pokémon School (891) | Pallet Town (33), Pallet House (42), Viridian House (77), Oak's Corral (764) | 2 mapas: Route 1 House (890), Pokémon School (891) |
| S0332 | Return to School | Oak's Corral (764) | Pallet Town (33), Professor Oak's Lab (48), Viridian House (77), Oak's Corral (764) | 2 mapas: Pokémon School (891), Kukui's House (892) |
| S0333 | Rocket Return Kanto | Pallet House (42) | Pallet House (42) | 1 mapas: Route 1 House (890) |
| S0387 | Beat Alola Brock | Hau'oli Pokémon Center (896) | Pewter Gym (86) | 3 mapas: Pokémon School (891), Kukui's House (892), Hau'oli Pokémon Center (896) |
| S0414 | Guzzlord Defeat | Manalo Stadium (957) | Pallet House (42) | 3 mapas: Manalo Stadium (957), Alola Pokemon League (958), Manalo Finals (963) |
| S0428 | Alola Done | Pokémon School (891) | Professor Oak's Lab (48) | 2 mapas: Pokémon School (891), Kukui's House (892) |
| S0429 | Postgame | Pallet House (42), Professor Oak's Lab (48), Kukui's House (892) | Pallet Town (33), Pallet House (42), Viridian City (43), Professor Oak's Lab (48) … (+14) | 78 mapas: Opelucid Gym (85), Wyndon Stadium (177), Wild Area (232) … (+75) |
| S0430 | Galar Start | Professor Oak's Lab (48) | Pallet House (42), Professor Oak's Lab (48), Vermilion City (108), Vermilion Gym (112) | 1 mapas: Kukui's House (892) |
| S0449 | Venusuar JN | Professor Cerise's Lab (94) | Pallet House (42), Professor Oak's Lab (48), Professor Cerise's Lab (94), Vermilion City (108) … (+1) | 1 mapas: Pokémon School (891) |
| S0451 | Flute Cup | Wild Area (187) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 1 mapas: Wild Area (187) |
| S0452 | Flute Cup Over | Hoenn Battle Frontier (261) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 7 mapas: Hoenn Battle Frontier (167), Wild Area (187), Hoenn Battle Frontier (261) … (+4) |
| S0454 | Galar Champion | Dragonite Island (265) | Professor Cerise's Lab (94), Cinnabar Island (184), Dragonite Island (265), Cerise Park (390) | 2 mapas: Wyndon (171), Wyndon Stadium (177) |
| S0455 | Unova Ruins | Wyndon Stadium (274) | Professor Cerise's Lab (94), Dragonite Island (265), Cerise Park (390) | 3 mapas: Wyndon Stadium (177), Wyndon Stadium (274), Route 4 (682) |
| S0456 | WCS Start | Colossus Ruins (311) | Professor Cerise's Lab (94), Vermilion Gym (112), Cerise Park (390) | 7 mapas: Wyndon Stadium (177), Colossus Ruins (311), Cianwood City (317) … (+4) |
| S0457 | WCS Oliver | Vermilion Gym (112) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 1 mapas: Colossus Ruins (311) |
| S0460 | WCS Korrina | Resort Area (345) | Professor Cerise's Lab (94), Cerise Park (390) | 2 mapas: Resort Area (345), Shalour House (824) |
| S0461 | Raihan/Sonia | Shalour House (824) | Professor Cerise's Lab (94), Cerise Park (390) | 3 mapas: Wyndon (171), Wyndon Stadium (177), Shalour House (824) |
| S0464 | WCS Tony | Wyndon (171) | Professor Cerise's Lab (94), Vermilion Gym (112), Cerise Park (390) | 2 mapas: Wyndon (171), Goldenrod City (282) |
| S0465 | WCS Kricketina Kylie | Vermilion Gym (112) | Professor Cerise's Lab (94), Vermilion City (108), Vermilion Pokémon Center (110), Fighting Dojo (164) … (+1) | 1 mapas: Wyndon (171) |
| S0471 | Alola Return | Mauville City (369) | Professor Cerise's Lab (94), Cerise Park (390) | 3 mapas: Mauville City (369), Pokémon School (891), Kukui's House (892) |
| S0473 | WCS Carmo | Pokémon School (891) | Pewter City (82), Professor Cerise's Lab (94), Fighting Dojo (164), Cerise Park (390) | 1 mapas: Pokémon School (891) |
| S0474 | WCS Bea 2 | Pewter City (82) | Cerise Park (390) | 2 mapas: Cianwood Gym (321), Pokémon School (891) |
| S0475 | Zapdos | Cianwood Gym (321) | Professor Cerise's Lab (94), Route 11 (124), Lavender Town (137), Cerise Park (390) | 2 mapas: Cianwood City (317), Cianwood Gym (321) |
| S0477 | Team Rocket PP | Route 10 (406) | Route 10 (406) | 1 mapas: Cianwood Gym (321) |
| S0478 | Darkest Day Start | Kanto Power Plant (412) | Professor Cerise's Lab (94), Route 11 (124), Magnet Train (135), Route 10 (406) … (+1) | 2 mapas: Wyndon (171), Wyndon Stadium (177) |
| S0479 | Dynamax Centy | Slumbering Weald (422) | Professor Cerise's Lab (94) | 1 mapas: Slumbering Weald (422) |
| S0480 | Dynamax Pangoro | Slumbering Weald (422) | Magnet Train (135) | 2 mapas: Wyndon (171), Slumbering Weald (422) |
| S0486 | WCS Maike | Tower Summit (508) | Professor Cerise's Lab (94), Saffron City (130), Cerise Park (390) | 4 mapas: Wyndon House (172), Slumbering Weald (422), Hammerlocke Stadium (457) … (+1) |
| S0488 | WCS Riven | Saffron City (130) | — | 1 mapas: Goldenrod City (282) |
| S0490 | Mewtwo | Mistralton City (707) | Professor Cerise's Lab (94), Vermilion City (108) | 1 mapas: Mistralton City (707) |
| S0491 | WCS Ariel | Iki Town (902) | Cero Island (517) | 2 mapas: Floaroma Town (532), Iki Town (902) |
| S0492 | Galar Fossil | Cero Island (517) | Professor Cerise's Lab (94), Vermilion City (108), Safari Zone Kanto (180), Cerise Park (390) | 2 mapas: Wild Area (187), Aether Paradise (919) |
| S0496 | No Fly | Pallet Town (33), Professor Cerise's Lab (94), Valencia House (207), Valencia Island Blimp (208) … (+31) | — | 31 mapas: Valencia House (207), Valencia Island Blimp (208), Olivine City (308) … (+28) |
| S0501 | WCS Johan | Wild Area (187) | Professor Cerise's Lab (94), Cerise Park (390) | 2 mapas: Wild Area (187), Iki Town (902) |
| S0504 | WCS Dozer | Dendemille Town (842) | Route 10 (518) | 1 mapas: Dendemille Town (842) |
| S0505 | Ballonlea | Route 10 (518) | Professor Cerise's Lab (94), Vermilion City (108), Route 11 (124), Cerise Park (390) | 1 mapas: Hammerlocke (440) |
| S0506 | WCS Harry | Ballonlea (586) | Cerise Park (390) | 5 mapas: Wyndon Pokémon Center (173), Hammerlocke Pokémon Center (452), Stow-on-Side (526) … (+2) |
| S0507 | Wikstrom | Stow-on-Side (526) | Professor Cerise's Lab (94) | 3 mapas: Stow-on-Side (526), Ballonlea (586), Lumiose House (794) |
| S0508 | WCS Rinto | Castle of Chivalry (616) | Vermilion City (108), Cerise Park (390) | 2 mapas: Castle of Chivalry (616), Undella Town (743) |
| S0509 | WCS Iris | Vermilion City (108) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 3 mapas: Opelucid Gym (85), Lilycove City (426), Opelucid City (754) |
| S0510 | Moltres | Opelucid Gym (85) | Professor Oak's Lab (48), Professor Cerise's Lab (94), Cerise Park (390), Oak's Corral (764) | 2 mapas: Opelucid Gym (85), Opelucid City (754) |
| S0511 | Alolan Ninetales | Oak's Corral (764) | Professor Oak's Lab (48), Professor Cerise's Lab (94), Cerise Park (390), Oak's Corral (764) | 2 mapas: Route 207 (550), Hearthome City (551) |
| S0512 | Cressila/Darkrai | Mt. Coronet (628) | Professor Cerise's Lab (94), Cerise Park (390) | 2 mapas: Floaroma Meadow (537), Mt. Coronet (628) |
| S0513 | Goh Battle | Floaroma Meadow (537) | Professor Cerise's Lab (94), Cerise Park (390) | 2 mapas: Floaroma Meadow (537), Route 1 (889) |
| S0514 | WCS Volkner | Cerise Park (390) | Cerise Park (390) | 1 mapas: Sunnyshore Gym (641) |
| S0515 | PM Volcarona | Sunnyshore Gym (641) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 4 mapas: Violet City (262), Colossus Ruins (311), Sunnyshore City (632) … (+1) |
| S0516 | Opal | Colossus Ruins (311) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 3 mapas: Colossus Ruins (311), Ballonlea (586), Ballonlea Stadium (602) |
| S0517 | WCS Bea 3 | Ballonlea Stadium (636) | Cerise Park (390) | 4 mapas: Stow-on-Side Stadium (544), Ballonlea (586), Ballonlea Stadium (602) … (+1) |
| S0518 | Dialga/Palkia | Stow-on-Side Stadium (972) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 5 mapas: Sandgem Town (507), Professor Rowan's Lab (509), Stow-on-Side Stadium (544) … (+2) |
| S0519 | Max Soup | Mt. Coronet (628) | Professor Cerise's Lab (94), Vermilion City (108) | 4 mapas: Sandgem Town (507), Professor Rowan's Lab (509), Stow-on-Side Stadium (544) … (+1) |
| S0520 | TG Hisui | Stow-on-Side Stadium (544) | Pewter Gym (86), Professor Cerise's Lab (94), Cerise Park (390) | 7 mapas: Wild Area (187), Wild Area (222), Wild Area (397) … (+4) |
| S0523 | JN Sophocles | Mt. Coronet (628) | Professor Cerise's Lab (94), Cerise Park (390) | 4 mapas: Mossdeep Space Center (441), Oreburgh City (523), Oreburgh Pokémon Center (525) … (+1) |
| S0524 | WCS Marnie | Mossdeep Space Center (441) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) | 5 mapas: Wyndon (171), Wyndon Stadium (177), Hammerlocke (440) … (+2) |
| S0526 | PM Articuno | Wyndon Stadium (274) | Professor Cerise's Lab (94), Cinnabar Island (184), Cerise Park (390) | 4 mapas: Wyndon (171), Wyndon Stadium (177), Wyndon Stadium (274) … (+1) |
| S0527 | JN Clemont | Seafoam Islands (979) | Professor Cerise's Lab (94), Cinnabar Island (184), Cerise Park (390), Seafoam Islands (979) | 4 mapas: Wyndon (171), Lumiose City (793), Lumiose Gym (833) … (+1) |
| S0529 | JN Wallace | Lumiose Final (875) | Professor Cerise's Lab (94), Cerise Park (390) | 5 mapas: Lilycove City (426), Lilycove Contest (429), Lumiose City (793) … (+2) |
| S0530 | JN Serena | Professor Cerise's Lab (94), Lilycove Contest (429), Snowbelle Gym (866) | — | 4 mapas: Lilycove City (426), Lilycove Contest (429), Lumiose City (793) … (+1) |
| S0531 | WCS Raihan | Professor Cerise's Lab (94), Lilycove City (426), Snowbelle Gym (866) | Professor Cerise's Lab (94), Cerise Park (390) | 4 mapas: Lilycove City (426), Lilycove Contest (429), Hammerlocke Stadium (457) … (+1) |
| S0532 | Crown Tundra | Hammerlocke Stadium (980) | Professor Cerise's Lab (94) | 4 mapas: Wyndon House (172), Lilycove City (426), Hammerlocke Stadium (457) … (+1) |
| S0534 | Pallet Town Paul | Battle Royal Dome (930) | Professor Oak's Lab (48), Professor Cerise's Lab (94), Cerise Park (390), Oak's Corral (764) | 4 mapas: Pokémon School (891), Royal Avenue (927), Royal House (928) … (+1) |
| S0536 | Final Goh Battle | Oak's Corral (764) | Pallet Town (33), Professor Oak's Lab (48), Professor Cerise's Lab (94), Cerise Park (390) | 2 mapas: Royal House (928), Crown Tundra (983) |
| S0537 | WCS Masters | Cerise Park (390) | Professor Cerise's Lab (94), Magnet Train (135), Cerise Park (390), Oak's Corral (764) | 11 mapas: Wyndon (171), Wyndon House (172), Wyndon Pokémon Center (173) … (+8) |
| S0538 | Met Magnolia | Professor Magnolia's Lab (988) | Pallet House (42), Professor Oak's Lab (48) | 8 mapas: Valencia House (207), Professor Elm's Lab (253), Professor Birch's Lab (359) … (+5) |
| S0550 | Beat Leon | Wyndon Stadium (274) | Pallet House (42), Professor Oak's Lab (48), Professor Cerise's Lab (94), Vermilion City (108) … (+1) | 3 mapas: Wyndon (171), Wyndon Stadium (177), Wyndon Stadium (274) |
| S0552 | Lugia battle | Vermilion City (108) | Pallet House (42), Professor Cerise's Lab (94), Vermilion City (108) | 2 mapas: Wyndon (171), Wyndon Stadium (274) |
| S0555 | Find Misty/Clauncher | Route 26 (494) | Professor Cerise's Lab (94), Route 26 (494) | 1 mapas: Route 8 (812) |
| S0558 | Squirtle | Route 216 (620) | Vermilion City (108) | 3 mapas: Glimwood Tangle (567), Route 216 (620), Snowpoint City (625) |
| S0559 | Lapras/Wailmer | Vermilion City (108) | Vermilion City (108) | 1 mapas: Route 32 (268) |
| S0560 | Banette | Route 32 (268) | Vermilion City (108) | 2 mapas: Route 32 (268), Rustboro City (373) |
| S0562 | Jessie/James | Rustboro Pokémon Center (376) | Route 19 (181) | 2 mapas: Rustboro City (373), Rustboro Pokémon Center (376) |
| S0570 | No Teleport | Oak's Corral (764), Pokémon School (891) | Pallet House (42) | 7 mapas: Professor Elm's Lab (253), Professor Birch's Lab (359), Professor Rowan's Lab (509) … (+4) |
| S0602 | To Cerise Lab | Professor Cerise's Lab (94), Vermilion Pokémon Center (110), Wyndon (171), Wild Area (187) … (+17) | Dragonite Island (265) | 13 mapas: Wyndon (171), Wild Area (187), Hoenn Battle Frontier (261) … (+10) |
| V0001 | Temp Pokemon Choice | Route 1 (5), Cedolan Dept. Rooftop (19), Battle Tower (55), Stadium Cup lobby (57) … (+23) | Pallet House (42), Professor Oak's Lab (48), Viridian House (77), Viridian Pokémon Center (78) … (+29) | 187 mapas: \PN's house (3), Route 1 (5), Daisy's house (8) … (+184) |
| V0002 | Temp Move Choice | Battle Tower (55), Stadium Cup lobby (57), Battle Palace (58), Battle Arena (60) … (+10) | Saffron City (130), Fuchsia House (175) | 21 mapas: \PN's house (3), Daisy's house (8), Cedolan City Condo (12) … (+18) |
| V0003 | Temp Pokemon Name | Pokémon Institute (11), Cedolan City Condo (12), Pewter City (82), Route 5 (97) … (+7) | Route 22 (195) | 9 mapas: Daisy's house (8), Pokémon Institute (11), Cedolan City Condo (12) … (+6) |
| V0004 | Temp Move Name | Ice Cave (34), Rock Cave (49) | Route 5 Daycare (98), P1 Grand Prix (165), Route 22 (195), Battle Factory (473) … (+1) | 23 mapas: Daisy's house (8), Game Corner (13), Pokémon Day Care (27) … (+20) |
| V0005 | Temp Text Entry | Daisy's house (8), Cedolan City Condo (12), Pokémon Day Care (27), Ice Cave (34) … (+24) | Route 5 (97), Route 5 Daycare (98), P1 Grand Prix (165), Route 22 (195) … (+2) | 30 mapas: Daisy's house (8), Cedolan City Condo (12), Lerucean Town (23) … (+27) |
| V0006 | Poké Center healing ball count | Cedolan City Poké Center (9), Lerucean Town Poké Center (24), Pokémon League (36), Battle Frontier Poké Center (53) … (+108) | Viridian Pokémon Center (78), Pewter Pokémon Center (84), Cerulean Pokémon Center (93), Route 24 Pokémon Center (103) … (+8) | 100 mapas: Cedolan City Poké Center (9), Lerucean Town Poké Center (24), Pokémon League (36) … (+97) |
| V0007 | Starter choice | Pokémon Lab (4), Professor Oak's Lab (48) | Professor Oak's Lab (48) | 2 mapas: Pokémon Lab (4), Route 3 (31) |
| V0009 | Fossil being revived | Pokémon Institute (11), Pewter Museum of Science (188) | — | 1 mapas: Pokémon Institute (11) |
| V0010 | Elevator current floor | Cedolan Dept. 1F (14), Cedolan Dept. 2F (15), Cedolan Dept. 3F (16), Cedolan Dept. 4F (17) … (+33) | Pallet House (42), Celadon Dept. Elevator (161) | 30 mapas: Cedolan Dept. 1F (14), Cedolan Dept. 2F (15), Cedolan Dept. 3F (16) … (+27) |
| V0011 | Elevator new floor | Cedolan Dept. Elevator (20), Pallet House (42) | Pallet House (42), Celadon Dept. Elevator (161) | 5 mapas: Cedolan Dept. Elevator (20), Goldenrod Dept. Elevator (289), Lilycove Dept. Elevator (436) … (+2) |
| V0051 | follower_iterator | Lappet Town (2), Route 1 (5), Cedolan City (7), Lerucean Town (23) … (+16) | Battle Arena (478), Metallica Island (491) | 18 mapas: Lappet Town (2), Route 1 (5), Cedolan City (7) … (+15) |
| V0052 | follower_count | — | Battle Arena (478), Metallica Island (491) | 18 mapas: Lappet Town (2), Route 1 (5), Cedolan City (7) … (+15) |

## Só em Kanto

| # | Nome | Muda em | Lido em |
| --- | --- | --- | --- |
| S0006 | Defeated Gym 3 | Vermilion Gym (112) | Viridian Pokémon Center (78), Pewter Pokémon Center (84), Cerulean City (89), Cerulean Pokémon Center (93) … (+5) |
| S0008 | Defeated Gym 5 | Celadon Gym (163) | Viridian City (43), Professor Oak's Lab (48), Viridian Pokémon Center (78), Pewter Pokémon Center (84) … (+7) |
| S0010 | Defeated Gym 7 | Cinnabar Gym (193) | Viridian City (43), Viridian Pokémon Center (78), Pewter Pokémon Center (84), Cerulean Pokémon Center (93) … (+6) |
| S0011 | Defeated Gym 8 | Viridian Gym (194) | Pallet Town (33), Pallet House (42), Viridian City (43), Cerulean Gym (95) |
| S0036 | Pikachu | Professor Oak's Lab (48) | Professor Oak's Lab (48) |
| S0037 | Team Rocket | Viridian City (43), Viridian Pokémon Center (78), S.S. Anne Room (121), S.S. Anne 3F (123) | Viridian City (43), S.S. Anne 1F (115), S.S. Anne B1F (117), S.S. Anne 2F (119) … (+3) |
| S0038 | Beginning | Pallet House (42), Professor Oak's Lab (48) | Pallet Town (33), Pallet House (42) |
| S0039 | Before first gym | Pallet House (42), Viridian City (43), Pewter City (82), Pewter Gym (86) | Pallet Town (33), Pallet House (42), Pewter House (83) |
| S0040 | Get Charmander | Route 24 Pokémon Center (103) | Route 24 (101) |
| S0041 | Got Charmander | Route 24 (101) | Route 24 Pokémon Center (103) |
| S0042 | Got Squirtle | Route 25 (106) | Route 25 (104), Route 25 House (105) |
| S0045 | S.S. Anne Beat | S.S. Anne 3F (123) | Vermilion City (108) |
| S0046 | Defeated Gym 4-2 | Saffron Gym (136) | Lavender Town (137) |
| S0047 | Defeated Pokemon Tower | Pokémon Tower 7F (149) | Saffron Gym (136) |
| S0048 | Safari Zone | Safari Zone (179) | Oak's Corral (764) |
| S0049 | Togepi | Route 19 House (182) | Route 19 (181), Route 19 House (788) |
| S0050 | Vermillion Ticket | Route 19 House (788) | Vermilion City (108) |
| S0059 | Cinnabar Gym | Pokémon Mansion B1F (192) | Cinnabar Island (184) |
| S0060 | Defeated Gym 7-2 | Cinnabar Gym (193) | Cinnabar Gym (193) |
| S0061 | Cinnabar Switch | Cinnabar Gym (193) | Cinnabar Gym (193) |
| S0062 | Indigo Start | Kanto Pokemon League (198), Indigo Water (200) | Kanto Pokemon League (198) |
| S0063 | Indigo Water | Indigo Rock (199), Indigo Water (200) | Kanto Pokemon League (198) |
| S0064 | Indigo Rock | Indigo Rock (199), Indigo Ice (201) | Kanto Pokemon League (198) |
| S0065 | Indigo Ice | Indigo Plateau (196), Indigo Grass (202) | Kanto Pokemon League (198) |
| S0066 | Indigo Grass | Indigo Grass (202), Indigo Stadium (203) | Kanto Pokemon League (198) |
| S0067 | Kingler Image | Indigo Water (200) | Oak's Corral (764) |
| S0068 | Indigo Brock | Indigo Plateau (196), Indigo Ice (201) | Indigo Plateau (196), Kanto Pokemon League (198) |
| S0070 | Fearow | Pallet Town (33) | Pallet House (42), Viridian House (77), Viridian Forest (81) |
| S0071 | Fearow Done | Viridian Forest (81) | Pallet Town (33), Pallet House (42), Viridian House (77), Indigo Plateau (197) |
| S0082 | Start Johto | Professor Oak's Lab (48) | Pallet Town (33) |
| S0139 | Beat Factory | Battle Factory Stage (475) | Saffron City (130), Lavender Town (137), Battle Factory (474) |
| S0141 | Beat Dome | Battle Dome Stage (483) | Safari Zone Kanto (180), Battle Dome (484) |
| S0142 | Beat Pike | Battle Pike Stage (490) | Cinnabar Island (184), Safari Zone Hoenn (487), Battle Pike (489) |
| S0143 | Beat Palace | Battle Palace Stage (493) | Route 22 (195), Battle Palace (492) |
| S0144 | Beat Tower | Battle Tower Stage (498) | Pewter City (82), Route 26 (494), Battle Tower (496) |
| S0145 | Beat Pyramid | Battle Pyramid Stage (502) | Pallet Town (33), Pallet House (42), Viridian City (43), Professor Oak's Lab (48) … (+5) |
| S0146 | Rocket Egg | Route 12 Breeding Center (481) | Pewter Gym (86), Route 12 (480), Route 12 Breeding Center (481) |
| S0147 | Beat Tower.5 | Battle Tower Challenge (497) | Battle Tower (496) |
| S0148 | Pyramid.1 | Battle Pyramid (499) | Battle Pyramid (499), Battle Pyramid (500) |
| S0149 | Pyramid.2 | Battle Pyramid Stage (502) | Route 22 (195), Indigo Plateau (196), Indigo Plateau (197), Battle Pyramid (499) … (+1) |
| S0150 | Aipom Start | Battle Pyramid (499) | Battle Pyramid (500) |
| S0151 | Aipom Stop | Indigo Plateau (197) | Battle Pyramid (500) |
| S0246 | Pokedex | Professor Oak's Lab (48) | Professor Oak's Lab (48) |
| S0286 | Earth Badge | Viridian City (43) | Route 22 (195) |
| S0330 | Beat Misty | Oak's Corral (764) | Oak's Corral (764) |
| S0331 | Beat Brock | Oak's Corral (764) | Oak's Corral (764) |
| S0424 | Frontier Pass | Viridian City (43) | Viridian City (43), Battle Factory (474) |
| S0425 | Kanto Grand Festival | Kanto Grand Festival (968) | Indigo Plateau (197), Kanto Grand Festival (968) |
| S0439 | Kalos Start | Professor Oak's Lab (48) | Viridian House (77) |
| S0446 | Mr Mime | Pallet Town (33) | Pallet Town (33) |
| S0447 | Lugia Vermilion | Professor Cerise's Lab (94) | Professor Cerise's Lab (94), Vermilion City (108), Celadon Gym (163) |
| S0448 | Luigia Vermilion Done | Vermilion City (108) | Professor Cerise's Lab (94), Vermilion City (108) |
| S0450 | Begin Galar | Vermilion City (108) | Professor Cerise's Lab (94), Vermilion City (108), Magnet Train (135) |
| S0458 | WCS Hayden | Vermilion City (108) | Vermilion City (108), Vermilion Pokémon Center (110), Cerise Park (390) |
| S0459 | Resort Area | Vermilion City (108) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) |
| S0466 | Goh Heracross | Vermilion Pokémon Center (110) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) |
| S0467 | WCS Bea | Cerise Park (390) | Professor Cerise's Lab (94), Fighting Dojo (164), Cerise Park (390) |
| S0468 | WCS Wrap | Fighting Dojo (164) | Vermilion City (108), Saffron City (130), Cerise Park (390) |
| S0469 | WCS Bind | Vermilion City (108) | Vermilion City (108), Saffron City (130) |
| S0470 | Flygon | Vermilion City (108) | Professor Cerise's Lab (94) |
| S0476 | Finished Goh | Vermilion City (108), Kanto Power Plant (412) | Kanto Power Plant (412) |
| S0493 | Riolu Switch | Vermilion Pokémon Center (110) | Vermilion City (108) |
| S0553 | Leave Cerise Lab | Vermilion City (108) | Professor Cerise's Lab (94), Vermilion City (108), Cerise Park (390) |
| S0554 | Find Latias | Professor Cerise's Lab (94) | Cerulean Gym (95), Vermilion City (108), Route 26 (494), Oak's Corral (764) … (+1) |
| S0563 | Jessie/James Blastoff | Route 20 (991) | Route 20 (991) |
| S0564 | Return Home | Route 20 Cave (992) | Pallet Town (33), Pallet House (42), Professor Oak's Lab (48), Oak's Corral (764) … (+1) |
| S0572 | Terracotta Start | Route 22 (195) | Route 22 (195) |
| S0573 | Terracotta Win | Route 22 (195) | Route 22 (195) |
| S0576 | Spawn Postgame Mewtwo | Route 4 (88), Indigo Stadium (203) | Route 4 (88) |
| V0027 | Indigo Rematch | Kanto Pokemon League (198), Indigo Rock (199), Indigo Water (200), Indigo Ice (201) … (+2) | Kanto Pokemon League (198), Indigo Stadium (203) |
