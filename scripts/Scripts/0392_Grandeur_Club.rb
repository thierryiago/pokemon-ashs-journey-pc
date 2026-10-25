module GCVariables
  TRAINER_BAG = 54
  TRAINER_OUTFIT = 55
  SYGNA_TRAINERS = 60
  SYGNA_CREDITS = 61 # Credits earned even when losing in Sync/Titan
  DUET_TRAINER_OPTIONS = 64
  DUET_PARTNER = 65
  DUET_TRAINER_NUMS = 66
  MAX_TRAINERS_IN_CHALLENGE = 67
  BEATEN_MAYHEM_TRAINERS = 68
  MAYHEM_ROOM = 70
  MAYHEM_TRAINERS = 71
  TRAINER_POOL = 79
  GC_CREDITS = 80
  GAUNTLET_WIN_COUNT = 81
  TRAINER_RANDOMIZER = 100
end

def createNew(maxtrainers)
  trainers = []
  for i in 1...maxtrainers + 1
    trainers.push(i)
  end
  pbSet(GCVariables::TRAINER_POOL, trainers)
  pbSet(GCVariables::MAX_TRAINERS_IN_CHALLENGE, maxtrainers)
end

def trainerCheck(trainers)
  return (trainers.include? pbGet(GCVariables::TRAINER_RANDOMIZER))
end

def returnOutfit
  if $Trainer.outfit == 10 && ![141, 151, 214].include?(@map_id)
    $Trainer.outfit = pbGet(GCVariables::TRAINER_OUTFIT)
    pbSet(GCVariables::TRAINER_OUTFIT, -1)
  end
end


def randomTrainer(number,increment=0)
  trainers = pbGet(GCVariables::TRAINER_POOL)
  max = trainers.length
  pbSet(GCVariables::TRAINER_RANDOMIZER, rand(number) + 1 + increment)
  while !trainerCheck(trainers)
    pbSet(GCVariables::TRAINER_RANDOMIZER, rand(number) + 1 + increment)
  end
  trainers.delete(pbGet(GCVariables::TRAINER_RANDOMIZER))
  pbSet(GCVariables::TRAINER_POOL, trainers)
  return pbGet(GCVariables::TRAINER_RANDOMIZER)
end

def gauntletReward(floors=pbGet(GCVariables::GAUNTLET_WIN_COUNT))
  creds = (0.75*floors*Math.log10(floors)).to_i
  pbSet(GCVariables::GC_CREDITS, pbGet(GCVariables::GC_CREDITS)+creds)
  pbMessage(_INTL("\\b{1} GC Credits have been awarded to you.", creds))
end

def mayhemChallenge(max,rooms)
  createNew(max)
  pbSet(GCVariables::BEATEN_MAYHEM_TRAINERS,[])
  roomTrainers = []
  for i in 0...rooms
    roomTrainers.push(randomTrainer(max))
  end
  pbSet(GCVariables::MAYHEM_TRAINERS, roomTrainers)
end

def updateMayhem
  pbSet(GCVariables::TRAINER_RANDOMIZER,
    pbGet(GCVariables::MAYHEM_TRAINERS)[pbGet(GCVariables::MAYHEM_ROOM)])
end

def updateMayhemBeaten
  if !pbGet(GCVariables::BEATEN_MAYHEM_TRAINERS).include? pbGet(GCVariables::TRAINER_RANDOMIZER)
    pbGet(GCVariables::BEATEN_MAYHEM_TRAINERS).push(pbGet(GCVariables::TRAINER_RANDOMIZER))
  end
end

def takeBag(diff)
  pbSet(GCVariables::TRAINER_BAG, $PokemonBag)
  $PokemonBag = PokemonBag.new
  items = []
  case diff
  when "Rookie"
    items = [:FULLRESTORE, 25, :MAXPOTION, 25, :LUMBERRY, 20, 
            :MAXETHER, 30, :ETHER, 10, :LEPPABERRY, 10, 
            :REVIVE, 10, :MEGARING, 1, :ZRING, 1, :DYNAMAXBAND, 1]
  when "Veteran"
    items = [:FULLRESTORE, 20, :MAXPOTION, 20, :FULLHEAL, 20, 
            :MAXETHER, 25, :ETHER, 10, :LEPPABERRY, 5,
            :REVIVE, 10, :MEGARING, 1, :ZRING, 1, :DYNAMAXBAND, 1]
  when "Ace"
    items = [:MAXPOTION, 10, :HYPERPOTION, 10, :FULLHEAL, 10,
            :MAXETHER, 20, :ETHER, 10, :LEPPABERRY, 5, 
            :REVIVE, 5, :MEGARING, 1, :ZRING, 1, :DYNAMAXBAND,1]
  end
  for i in 0...items.length/2
    $PokemonBag.pbStoreItem(items[i*2], items[i*2+1], false)
  end
end

def returnBag
  return if !pbGet(GCVariables::TRAINER_BAG).is_a?(PokemonBag)
  $PokemonBag = pbGet(GCVariables::TRAINER_BAG)
end


# Duet Challenge
def getDuetTrainer(number)
  duetTrainersMap = {
  1   => [:SECRET_Brock,"Brock",4,"\\bBrock: They will have a hard time inflicting any damage on us!","\\bBrock: Let me show you my rock-hard willpower!","\\bBrock: Well, I'll see you around!"],
  2   => [:SECRET_Misty,"Misty",4,"\\rMisty: I'll support you with all I got!","\\rMisty: Woohoo! Can't wait to test out our new strength!","\\rMisty: Bye!"],
  3   => [:SECRET_Surge,"Lt. Surge",4,"\\bLt. Surge: Let's join forces.","\\bLt. Surge: I'll shock them into surrender!","\\bLt. Surge: Dismissed."],
  4   => [:SECRET_Erika,"Erika",4,"\\rErika: I'll do my best not to let you down!","\\rErika: Oh my, how lovely!","\\rErika: I'm afraid I might doze off."],
  5   => [:SECRET_Sabrina,"Sabrina",4,"\\rSabrina: I had a vision of this moment.","\\rSabrina: Let's witness the future with our own eyes!","\\rSabrina: I've already foreseen it."],
  6   => [:SECRET_Janine,"Janine",4,"\\rJanine: I'm the real deal!","\\rJanine: Looks like I'm up!","\\rJanine: See ya later!"],
  7   => [:SECRET_Blaine,"Blaine",4,"\\bBlaine: My fiery Pokémon will incinerate all challengers!","\\bBlaine: Yeah, this sets my heart aflame!","\\bBlaine: Until we meet again!"],
  8   => [:SECRET_Bill,"Bill",4,"\\bBill: You've come at the right time.","\\bBill: Can I count on you?","\\bBill: We'll keep in touch!"],
  9   => [:SECRET_Lorelei,"Lorelei",4,"\\rLorelei: May I go with you?","\\rLorelei: They will be at my mercy when they're frozen solid.","\\rLorelei: Pardon."],
  10  => [:SECRET_Ryuki,"Ryuki",4,"\\bRyuki: Awww yeah! I'm all fired up!","\\bRyuki: You're a star, man!","\\bRyuki: Fine by me!"],
  11  => [:SECRET_Agatha,"Agatha",4,"\\rAgatha: I'll show you how a real Trainer battles.","\\rAgatha: You have a good eye, child, asking me to come along.","\\rAgatha: Eheheh!"],
  12  => [:SECRET_Trace,"Trace",4,"\\bTrace: What d'you say? You wanna come with me?","\\bTrace: Th-thanks, pal! It'll be a big relief to have you!","\\bTrace: Right... Then I'll just be here..."],
  13  => [:SECRET_Blue,"Blue",4,"\\bBlue: Just leave everything to me!","\\bBlue: Follow my lead and try to keep up.","\\bBlue: Smell ya later!"],
  14  => [:SECRET_Leaf,"Leaf",4,"\\rLeaf: Nice to meet you!","\\rLeaf: This looks like a job for me!","\\rLeaf: See you around!"],
  15  => [:SECRET_Red,"Red",4,"\\bRed: ...","\\bRed: Hm!","\\bRed: Mmh!"],
  16  => [:SECRET_Oak,"Oak",4,"\\bOak: Are you in need of my expertise?","\\bOak: I've still got strength left in these old bones!","\\bOak: Take care!"],
  17  => [:SECRET_Giovanni,"Giovanni",4,"\\bGiovanni: Underestimate a man like me and you'll be in a world of pain.","\\bGiovanni: Hmm... All according to plan.","\\bGiovanni: It was only a matter of time."],
  18  => [:SECRET_Falkner,"Falkner",4,"\\bFalkner: Let's chase the clouds.","\\bFalkner: The wind is with us! There's no time to lose!","\\bFalkner: See you later."],
  19  => [:SECRET_Bugsy,"Bugsy",4,"\\bBugsy: Let me demonstrate what I've learned from my studies!","\\bBugsy: Up and at 'em!","\\bBugsy: Bye!"],
  20  => [:SECRET_Whitney,"Whitney",4,"\\rWhitney: You just can't help to be infatuated with me, huh?","\\rWhitney: Don't blame me, it's not my fault.","\\rWhitney: Hey!"],
  21  => [:SECRET_Morty,"Morty",4,"\\bMorty: I can see what others cannot.","\\bMorty: We're aiming for number one.","\\bMorty: Later!"],
  22  => [:SECRET_Chuck,"Chuck",4,"\\bChuck: Kyah!","\\bChuck: You better be ready!","\\bChuck: Hoh!"],
  23  => [:SECRET_Jasmine,"Jasmine",4,"\\rJasmine: Steel will hang on to the very end!","\\rJasmine: I'd love to join you!","\\rJasmine: See you!"],
  24  => [:SECRET_Pryce,"Pryce",4,"\\bPryce: I do not lose easily.","\\bPryce: I will lend you my strength, young one.","\\bPryce: Farewell."],
  25  => [:SECRET_Clair,"Clair",4,"\\rClair: I will use my full power against any opponent.","\\rClair: Fine! I suppose I can help you out.","\\rClair: Well, I'll see you later."],
  26  => [:SECRET_Will,"Will",4,"\\bWill: Nothing stands a chance against my psychic powers.","\\bWill: My, oh marvelous.","\\bWill: See you!"],
  27  => [:SECRET_Koga,"Koga",4,"\\bKoga: They shall feel the despair of poison!","\\bKoga: I would be honored to accompany you.","\\bKoga: Begone!"],
  28  => [:SECRET_Bruno,"Bruno",4,"\\bBruno: Believe in our potential!","\\bBruno: Time for some intense training!","\\bBruno: Off you go."],
  29  => [:SECRET_Karen,"Karen",4,"\\rKaren: I'm really a force to be reckoned with!","\\rKaren: I suppose I'm satisfied.","\\rKaren: Till we meet again."],
  30  => [:SECRET_Lance,"Lance",4,"\\bLance: Something tells me the two of us are going to make a first-class team.","\\bLance: Allow me to lend you my strength, whenever you should need it.","\\bLance: Later."],
  31  => [:SECRET_Lyra,"Lyra",4,"\\rLyra: I'm not sure what the future holds, but we'll have fun no matter what!","\\rLyra: Time for an adventure!","\\rLyra: Bye-bye!"],
  32  => [:SECRET_Silver,"Silver",4,"\\bSilver: Oh, it's you. Whatever...","\\bSilver: Let's see what you're made of.","\\bSilver: Yeah."],
  33  => [:SECRET_Ethan,"Ethan",4,"\\bEthan: Let me know if you ever want help, OK?","\\bEthan: We've got your back.","\\bEthan: See you around!"],
  34  => [:SECRET_Elm,"Elm",4,"\\bElm: How's it going?","\\bElm: Try not to overdo it.","\\bElm: Oh?"],
  35  => [:SECRET_Roxanne,"Roxanne",4,"\\rRoxanne: Let's strategize before a battle.","\\rRoxanne: I shall accompany you.","\\rRoxanne: Then excuse me, while I am planning my moves."],
  36  => [:SECRET_Brawly,"Brawly",4,"\\bBrawly: The next big wave! Nice to meet you!","\\bBrawly: I think this will be a good wave to ride!","\\bBrawly: Later."],
  37  => [:SECRET_Wattson,"Wattson",4,"\\bWattson: I'm looking forward to our electrifying battle!","\\bWattson: We'll make sparks fly out from them!","\\bWattson: Wahahahah!"],
  38  => [:SECRET_Flannery,"Flannery",4,"\\rFlannery: Your fiery passion! It's gonna overheat!","\\rFlannery: Wait, we're totally gonna win together, right?","\\rFlannery: Bye-bye!"],
  39  => [:SECRET_Norman,"Norman",4,"\\bNorman: Let me show you my newly honed skills.","\\bNorman: You better give it your best shot!","\\bNorman: Take care."],
  40  => [:SECRET_Winona,"Winona",4,"\\rWinona: Witness our elegant choreography!","\\rWinona: With splendor!","\\rWinona: Until later then."],
  41  => [:SECRET_TateandLiza,"Tate & Liza",4,"\\bTate: We're gonna surprise you! \\rLiza: Our awesome, powerful combination!","\\bTate: I sense we'll work well together!","\\rLiza: See ya!"],
  42  => [:SECRET_Juan,"Juan",4,"\\bJuan: I care about winning beautifully!","\\bJuan: Please, they shall bear witness to our artistry.","\\bJuan: Ahahaha!"],
  43  => [:SECRET_Sidney,"Sidney",4,"\\bSidney: I think we'll have fun with this.","\\bSidney: Nothing's gonna stop us!","\\bSidney: Later!"],
  44  => [:SECRET_Phoebe,"Phoebe",4,"\\rPhoebe: Just see if they can even touch my Pokémon!","\\rPhoebe: I already foresee a bond between us!","\\rPhoebe: See you again!"],
  45  => [:SECRET_Glacia,"Glacia",4,"\\rGlacia: Sigh. So many weak opponents.","\\rGlacia: I sincerely hope you can show me a bit more fun than the last few.","\\rGlacia: Farewell."],
  46  => [:SECRET_Drake,"Drake",4,"\\bDrake: A team's true worth is in the strength of their spirit!","\\bDrake: Let us press onward together!","\\bDrake: Farewell!!"],
  47  => [:SECRET_Steven,"Steven",4,"\\bSteven: When it comes down to it, I'm just the strongest there is right now.","\\bSteven: Imagine what we could do as a team.","\\bSteven: See you around."],
  48  => [:SECRET_Wallace,"Wallace",4,"\\bWallace: I represent beauty as well as intelligence.","\\bWallace: And I want to feel bedazzled by your masterful performance.","\\bWallace: I'll be seeing you."],
  49  => [:SECRET_Wally,"Wally",4,"\\bWally: My Pokémon have given me the courage and strength to fight. I have to win for their sake!","\\bWally: I promise, I won't let you down.","\\bWally: Bye!"],
  50  => [:SECRET_May,"May",4,"\\rMay: I'm going to try to find what I can do to help!","\\rMay: I was hoping you'd decide to take me with you!","\\rMay: Bye!"],
  51  => [:SECRET_Brendan,"Brendan",4,"\\bBrendan: If you ever need help, give me a call! I'm your guy!","\\bBrendan: I'm going with you! Let's show 'em what we're made of!","\\bBrendan: See ya."],
  52  => [:SECRET_Birch,"Birch",4,"\\bBirch: Imagine seeing you here!","\\bBirch: Alright, we will get the hang of this.","\\bBirch: Sure!"],
  53  => [:SECRET_Maxie,"Maxie",4,"\\bMaxie: To propel humanity to greater heights of progress and evolution.","\\bMaxie: I see you require my help. And thus, we become the strongest.","\\bMaxie: Farewell."],
  54  => [:SECRET_Archie,"Archie",4,"\\bArchie: To return everything to its unspoiled beginnings!","\\bArchie: No question about it. Bwahaha! Leave it to me!","\\bArchie: See ya later."],
  55  => [:SECRET_Roark,"Roark",4,"\\bRoark: We will smash our way through any obstacle.","\\bRoark: I'll show you this tough coal miner's true strength.","\\bRoark: See you around."],
  56  => [:SECRET_Gardenia,"Gardenia",4,"\\rGardenia: Today is another day where we can give it our all!","\\rGardenia: When it comes to plant Pokémon, you can't go wrong with me.","\\rGardenia: Bye bye! Catch you later!"],
  57  => [:SECRET_Maylene,"Maylene",4,"\\rMaylene: I'll accept an invitation anytime, anywhere!","\\rMaylene: Can I come with you?","\\rMaylene: Bye."],
  58  => [:SECRET_CrasherWake,"Crasher Wake",4,"\\bCrasher Wake: The torrential masked master will wash them all away!","\\bCrasher Wake: Feast your eyes on the monster wave that I bring!","\\bCrasher Wake: So long!"],
  59  => [:SECRET_Fantina,"Fantina",4,"\\rFantina: You wish to see me dance, yes?","\\rFantina: You choose me? Oh, no, I choose you!","\\rFantina: Au revoir!"],
  60  => [:SECRET_Byron,"Byron",4,"\\bByron: I have the confidence to batter down any defenses!","\\bByron: This is where we make our stand!","\\bByron: Gwahahaha! That's disappointing."],
  61  => [:SECRET_Candice,"Candice",4,"\\rCandice: My focus can melt ice! I'm ready to go.","\\rCandice: I'll show you, so you better be ready!","\\rCandice: Got it!"],
  62  => [:SECRET_Volkner,"Volkner",4,"\\bVolkner: Every one of my Pokémon are top class in potential.","\\bVolkner: You need my help? Ehh, sure.","\\bVolkner: Later."],
  63  => [:SECRET_Aaron,"Aaron",4,"\\bAaron: Bug Pokémon are nasty-mean, and yet they're beautiful, too.","\\bAaron: Let's give it our best shot.","\\bAaron: Later!"],
  64  => [:SECRET_Bertha,"Bertha",4,"\\rBertha: Well, would you show this old lady how much you've learned?","\\rBertha: Don't worry. This old lady has your back.","\\rBertha: Next time then."],
  65  => [:SECRET_Flint,"Flint",4,"\\bFlint: I can feel your determination. Your will is truly on fire!","\\bFlint: How about if I tag along? I bet I can spice things up a bit.","\\bFlint: See ya."],
  66  => [:SECRET_Lucian,"Lucian",4,"\\bLucian: Ah, hello. You're here to pick me, too?","\\bLucian: I'm more than happy to be of assistance.","\\bLucian: Take care!"],
  67  => [:SECRET_Cynthia,"Cynthia",4,"\\rCynthia: It's time to show the world why I'm proud to be a Champion!","\\rCynthia: Heheh, I knew you'd choose me.","\\rCynthia: I'll be seeing you."],
  68  => [:SECRET_Barry,"Barry",4,"\\bBarry: I'm gonna have to fine you a billion if you do not pick me!","\\bBarry: Heh, so happy! I can't even keep a straight face right now!","\\bBarry: I don't get it..."],
  69  => [:SECRET_Dawn,"Dawn",4,"\\rDawn: If you ever need help, I can be your mentor!","\\rDawn: United like this, our dream team has no chance of losing!","\\rDawn: Catch you later!"],
  70  => [:SECRET_Lucas,"Lucas",4,"\\bLucas: You and me are a dream team. Nobody can beat us!","\\bLucas: You can bet I'll do my best!","\\bLucas: Be seein' ya!"],
  71  => [:SECRET_Rowan,"Rowan",4,"\\bRowan: It's been a long while since I battled...","\\bRowan: Let's have a look at this old man now...","\\bRowan: Sure."],
  72  => [:SECRET_Cyrus,"Cyrus",4,"\\bCyrus: The world should be complete. The world must change.","\\bCyrus: Do you need my strength? Very well.","\\bCyrus: Farewell"],
  73  => [:SECRET_Cilan,"Cilan",4,"\\bCilan: So, um, if you're OK with me...","\\bCilan: I'll, um, put everything I've got into being, er, you know, your partner.","\\bCilan: No hard feelings..."],
  74  => [:SECRET_Chili,"Chili",4,"\\bChili: Ta-da! That's me, a scorcher!","\\bChili: Yeeeeooow! Time to play with FIRE!!","\\bChili: Awwww!"],
  75  => [:SECRET_Cress,"Cress",4,"\\bCress: How exceedingly lucky for you to meet me.","\\bCress: What incredible luck for us!","\\bCress: I see..."],
  76  => [:SECRET_Lenora,"Lenora",4,"\\rLenora: I'm going to research how we can seek victory!","\\rLenora: Now, with that, let's start our road to victory!","\\rLenora: No? Ok."],
  77  => [:SECRET_Burgh,"Burgh",4,"\\bBurgh: No matter how many times we meet, I always discover something new about you.","\\bBurgh: My Pokémon's buzzing to come along!","\\bBurgh: See you around."],
  78  => [:SECRET_Elesa,"Elesa",4,"\\rElesa: The world is my stage. Watch how the spotlight follows me.","\\rElesa: Think you can keep up, sweetie?","\\rElesa: Bye!"],
  79  => [:SECRET_Clay,"Clay",4,"\\bClay: I got more grit than anyone.","\\bClay: Got some work to be done? I'm expectin' a bonus for this.","\\bClay: I'll be seein' y'all!"],
  80  => [:SECRET_Skyla,"Skyla",4,"\\rSkyla: Whether you want to fly or blow your opponents away, you can count on me!","\\rSkyla: Ready for takeoff!","\\rSkyla: See you!"],
  81  => [:SECRET_Brycen,"Brycen",4,"\\bBrycen: The time is upon us. Use them to your advantage.","\\bBrycen: I shall be honored to lend you a hand.","\\bBrycen: I bid you farewell!"],
  82  => [:SECRET_Roxie,"Roxie",4,"\\rRoxie: Poison days, poison on the stage!","\\rRoxie: We're gonna wow the crowd together!","\\rRoxie: See ya."],
  83  => [:SECRET_Cheren,"Cheren",4,0,"\\bCheren: I aim to be a wall for them to overcome.","\\bCheren: Maybe I'll follow along for a while.","\\bCheren: See you around."],
  84  => [:SECRET_Drayden,"Drayden",4,"\\bDrayden: I've simply been pursuing greater strength.","\\bDrayden: Show us the bright future.","\\bDrayden: Moving on."],
  85  => [:SECRET_Marlon,"Marlon",4,"\\bMarlon: We should totally go for a swim sometime, dude!","\\bMarlon: Yo, I'll come along for the ride!","\\bMarlon: Catch you later!"],
  86  => [:SECRET_Grimsley,"Grimsley",4,"\\bGrimsley: I guess you could say I'm a bit of a risk taker.","\\bGrimsley: Following your lead seems like a good bet.","\\bGrimsley: Until we meet again."],
  87  => [:SECRET_Shauntal,"Shauntal",4,"\\rShauntal: Would this pairing be the subject of my new novel?","\\rShauntal: This could write a best-seller about us!","\\rShauntal: Bye!"],
  88  => [:SECRET_Marshal,"Marshal",4,"\\bMarshal: I dedicate my life and soul to mastering the art of battle.","\\bMarshal: Count me in.","\\bMarshal: See ya around."],
  89  => [:SECRET_Caitlin,"Caitlin",4,"\\rCaitlin: Who is so uncouth as to disturb my sleep?","\\rCaitlin: Please, try not to bore me.","\\rCaitlin: *giggle*"],
  90  => [:SECRET_Alder,"Alder",4,"\\bAlder: Take deep breaths and relax both your body and spirit.","\\bAlder: Another step further.","\\bAlder: Farewell!"],
  91  => [:SECRET_Benga,"Benga",4,"\\bBenga: Let's pursue our goals together!","\\bBenga: Let's head out!","\\bBenga: Bye!"],
  92  => [:SECRET_Iris,"Iris",4,"\\rIris: People call me the girl who knows the hearts of dragons!","\\rIris: Are you going out now? I wanna go, too!","\\rIris: Later!"],
  93  => [:SECRET_Bianca,"Bianca",4,"\\rBianca: My knowledge of Pokémon will help us get along better!","\\rBianca: Me? Oh! I'd love to join you!","\\rBianca: Bye-bye!!"],
  94  => [:SECRET_Hugh,"Hugh",4,"\\bHugh: Just to let you know... They're about to feel my rage!","\\bHugh: Back me up.","\\bHugh: Sure."],
  95  => [:SECRET_Hilda,"Hilda",4,"\\rHilda: Trust me, I'm really good at this stuff!","\\rHilda: Yup, good choice!","\\rHilda: See ya!"],
  96  => [:SECRET_Hilbert,"Hilbert",4,"\\bHilbert: When we team up, no one can stop us!","\\bHilbert: Ready when you are!","\\bHilbert: See you again!"],
  97  => [:SECRET_Rosa,"Rosa",4,"\\rRosa: We'll keep things exciting for you!","\\rRosa: You can count on me! I always do my best.","\\rRosa: Laters!"],
  98  => [:SECRET_Nate,"Nate",4,"\\bNate: We can't let this awesome opportunity pass us by!","\\bNate: Now let's show them how it's done!","\\bNate: Okay!"],
  99  => [:SECRET_Juniper,"Juniper",4,"\\rJuniper: Will your path be promising?","\\rJuniper: Show them what you have learned!","\\rJuniper: Bye!"],
  100 => [:SECRET_N,"N",4,"\\bN: I will show you that my love for my friends permeates every cell of my body.","\\bN: Show me just what kinds of wonderful dreams you have.","\\bN: Ok!"],
  101 => [:SECRET_Ghetsis,"Ghetsis",4,"\\bGhetsis: Liberate every Pokémon from every person in the world, and release them all.","\\bGhetsis: My beautiful ideals must be realized.","\\bGhetsis: Farewell."],
  102 => [:SECRET_Viola,"Viola",4,"\\rViola: My lens is always focused on victory!","\\rViola: I promise I'll snag some amazing photos in the process!","\\rViola: Well, I'll see you later!"],
  103 => [:SECRET_Grant,"Grant",4,"\\bGrant: Let's climb this wall together.","\\bGrant: It's important that you never give up.","\\bGrant: Until we meet again!"],
  104 => [:SECRET_Korrina,"Korrina",4,"\\rKorrina: Time for Lady Korrina's grand appearance!","\\rKorrina: It's time to get things rolling!","\\rKorrina: See you!"],
  105 => [:SECRET_Ramos,"Ramos",4,"\\bRamos: I'll show dem wizened trees can still blossom! Not that I'm old, mind yeh.","\\bRamos: I may be old, but I'm worth at least five younger Trainers!","\\bRamos: I'll see ya 'round!"],
  106 => [:SECRET_Clemont,"Clemont",4,"\\bClemont: The future is now, thanks to science.","\\bClemont: Me? Okay, I'll do my best!","\\bClemont: Bye for now!"],
  107 => [:SECRET_Valerie,"Valerie",4,"\\rValerie: My Pokémon may appear frail and delicate, but looks can be deceiving.","\\rValerie: Shall I join you?","\\rValerie: See you later."],
  108 => [:SECRET_Olympia,"Olympia",4,"\\rOlympia: So the stars decree. Olympia shall fight by your side.","\\rOlympia: A shared destiny! Let us embark together to face it as one!","\\rOlympia: Farewell."],
  109 => [:SECRET_Wulfric,"Wulfric",4,"\\bWulfric: Know who I am?","\\bWulfric: Y'know, I'm as tough as an iceberg.","\\bWulfric: You take care o' yourself now!"],
  110 => [:SECRET_Malva,"Malva",4,"\\rMalva: I'll handle this.","\\rMalva: I do so hate to be kept waiting.","\\rMalva: Hmph."],
  111 => [:SECRET_Siebold,"Siebold",4,"\\bSiebold: I'm very much looking forward to a night full of exceptional treats and battles.","\\bSiebold: I can count on you to bring the flavor!","\\bSiebold: Excuse me."],
  112 => [:SECRET_Wikstrom,"Wikstrom",4,"\\bWikstrom: Verily am I the famed blade of hardened steel!","\\bWikstrom: And let my body be thy shield!","\\bWikstrom: My word."],
  113 => [:SECRET_Drasna,"Drasna",4,"\\rDrasna: Oh, goodness! Is it my turn already?","\\rDrasna: They'll be satisfied tonight with our performance.","\\rDrasna: Oh, dear me!"],
  114 => [:SECRET_Diantha,"Diantha",4,"\\rDiantha: Allow me to show you how I shine, living up to the title of Champion!","\\rDiantha: It's your time to shine too.","\\rDiantha: See you around!"],
  115 => [:SECRET_Shauna,"Shauna",4,"\\rShauna: Let's make some great memories!","\\rShauna: I never, ever wanna forget this!","\\rShauna: Buh-bye!"],
  116 => [:SECRET_Tierno,"Tierno",4,"\\bTierno: Shall we dance on beatdown?","\\bTierno: Challenge accepted!","\\bTierno: See ya next time!"],
  117 => [:SECRET_Trevor,"Trevor",4,"\\bTrevor: E-excuse me! I believe I could be of help!","\\bTrevor: Thank you so much!","\\bTrevor: Alright."],
  118 => [:SECRET_Serena,"Serena",4,"\\rSerena: Don't cut corners! You have to give it your all.","\\rSerena: Our feelings are one and the same!","\\rSerena: See you!"],
  119 => [:SECRET_Calem,"Calem",4,"\\bCalem: Teaming up with you seems to be the quickest path to getting stronger.","\\bCalem: I'm just getting started!","\\bCalem: See ya!"],
  120 => [:SECRET_Sycamore,"Sycamore",4,"\\bSycamore: How is your Pokémon journey going so far?","\\bSycamore: What sorts of encounters await us today?","\\bSycamore: See you later."],
  121 => [:SECRET_Lysandre,"Lysandre",4,"\\bLysandre: The world must remain beautiful. I can't stand the thought of it becoming uglier.","\\bLysandre: Let's see what potential you have hidden within you.","\\bLysandre: You are not a chosen one!"],
  122 => [:SECRET_Ilima,"Ilima",4,"\\bIlima: Greetings! I have been observing your talents.","\\bIlima: I sincerely look forward to your assistance.","\\bIlima: I'll wait."],
  123 => [:SECRET_Lana,"Lana",4,"\\rLana: Please allow me to join you.","\\rLana: You look like you're well worth catching.","\\rLana: Goodbye!"],
  124 => [:SECRET_Kiawe,"Kiawe",4,"\\bKiawe: The power of a roaring blaze burns within us.","\\bKiawe: We'll fully display our vaunted dancing!","\\bKiawe: No, don't!"],
  125 => [:SECRET_Mallow,"Mallow",4,"\\rMallow: Let me serve them up a plate of my Super Mallow Special!","\\rMallow: Time to start cooking with gas!","\\rMallow: See ya!"],
  126 => [:SECRET_Sophocles,"Sophocles",4,"\\bSophocles: I'm a tough kid. N-no, really! I'm a tough kid!","\\bSophocles: Ooh, I wanna come along!","\\bSophocles: See you later!"],
  127 => [:SECRET_Mina,"Mina",4,"\\rMina: Heyyy, you and your Pokémon would make a real pretty painting.","\\rMina: Let's give 'em a grand trial!","\\rMina: See ya! Alola!"],
  128 => [:SECRET_Acerola,"Acerola",4,"\\rAcerola: You'll be sorry if you don't take me with you!","\\rAcerola: Fright them and fight them with me!","\\rAcerola: Boooo!"],
  129 => [:SECRET_Hapu,"Hapu",4,"\\bHapu: I may be young, but that does not mean I will be outdone!","\\bHapu: I will gladly come to your aid.","\\bHapu: Until we meet again!"],
  130 => [:SECRET_Nanu,"Nanu",4,"\\bNanu: If you don't wanna battle, I'm going home.","\\bNanu: Well, aren't we just merry companions.","\\bNanu: Guess I can take it easy now."],
  131 => [:SECRET_Olivia,"Olivia",4,"\\rOlivia: We'll grind them to dust, with my polished diamonds!","\\rOlivia: You've got to have a certain level of polish to partner with me.","\\rOlivia: Well, I'll see you later."],
  132 => [:SECRET_Kahili,"Kahili",4,"\\rKahili: Let's see how far we can fly for my new personal best.","\\rKahili: We'll be heading toward a hole in one!","\\rKahili: I hope we meet again."],
  133 => [:SECRET_Molayne,"Molayne",4,"\\bMolayne: The stars has always watch over our adventures.","\\bMolayne: To aim for a better tomorrow!","\\bMolayne: See you later."],
  134 => [:SECRET_Hala,"Hala",4,"\\bHala: I'm glad to meet you, child.","\\bHala: Our energy will be uncontained!","\\bHala: See ya later!"],
  135 => [:SECRET_Hau,"Hau",4,"\\bHau: I know you wanna win... And I'm gonna make sure that happens!","\\bHau: I'm totally on board for this!","\\bHau: I'm out!"],
  136 => [:SECRET_Lillie,"Lillie",4,"\\rLillie: I'll do my best so that no Pokémon have to end up getting hurt!","\\rLillie: I'll work hard for the team.","\\rLillie: I'll see you soon, right?"],
  137 => [:SECRET_Gladion,"Gladion",4,"\\bGladion: You can't protect anything if you're weak.","\\bGladion: Alright. Let's go.","\\bGladion: See you around."],
  138 => [:SECRET_Selene,"Selene",4,"\\rSelene: I'm fired up to the max! Bring it on!","\\rSelene: Sweet! Come on, let's go try it out!","\\rSelene: See you later!"],
  139 => [:SECRET_Elio,"Elio",4,"\\bElio: Don't worry, in the end, everything will be all right.","\\bElio: I've got your back!","\\bElio: See ya!"],
  140 => [:SECRET_Kukui,"Kukui",4,"\\bKukui: I wanna research your moves! Can't wait to get in there and battle!","\\bKukui: Give it everything you've got! My body is ready. Woo!","\\bKukui: See ya!"],
  141 => [:SECRET_Lusamine,"Lusamine",4,"\\rLusamine: You may find you have nothing left to protect if you stop caring your Pokemon.","\\rLusamine: I promise I'll keep you safe...","\\rLusamine: I'll see you again."],
  142 => [:SECRET_Guzma,"Guzma",4,"\\bGuzma: Wanna see what destruction looks like? Here it is in human form!","\\bGuzma: It's time to smash! Let's go break some stuff!","\\bGuzma: Later."],
  143 => [:SECRET_Eusine,"Eusine",4,"\\bEusine: I am determined, of my dreams, and victories.","\\bEusine: Yes. Let's go together.","\\bEusine: Farewell."],
  144 => [:SECRET_Cheryl,"Cheryl",4,"\\rCheryl: Winning's all about striking the right balance of offense and defense.","\\rCheryl: We should warn them, my Pokémon can be quite rambunctious.","\\rCheryl: Until we meet again."],
  145 => [:SECRET_Mira,"Mira",4,"\\rMira: Please! Please take me to the exit!","\\rMira: Alright! They will be shocked by what Mira can do!","\\rMira: Oh no!"],
  146 => [:SECRET_Riley,"Riley",4,"\\bRiley: It is a bit odd that I would be training here, but this is a good ground to strengthen myself.","\\bRiley: Let's forego the small talk and proceed right to battle.","\\bRiley: I'll be hanging around here."],
  147 => [:SECRET_Buck,"Buck",4,"\\bBuck: Now this! This is a smoking-hot situation we would enjoy!","\\bBuck: Let's not waste time! Let's do this!","\\bBuck: Huh, what?"],
  148 => [:SECRET_Marley,"Marley",4,"\\rMarley: Don't be mean by leaving me behind. Take me with you.","\\rMarley: I... won't lose...!","\\rMarley: I'm getting to dislike you a little."],
  149 => [:SECRET_Emmet,"Emmet",4,"\\bEmmet: Follow the rules, and our tracks go on forever!","\\bEmmet: Announcement! Full speed ahead!","\\bEmmet: See you next stop!"],
  150 => [:SECRET_Ingo,"Ingo",4,"\\bIngo: Safety protocol's in place, this journey's only just begun!","\\bIngo: Eh-eh-hem. All aboooard!","\\bIngo: Door's closing!"],
  151 => [:SECRET_Noland,"Noland",4,"\\bNoland: Gather up all the knowledge you've got, and show them what we can do!","\\bNoland: I like how you think.","\\bNoland: Hey, hey."],
  152 => [:SECRET_Greta,"Greta",4,"\\rGreta: Are you sure you're up with me?","\\rGreta: Okay! Let's see you ignite my passion for battle!","\\rGreta: Oh, come on!"],
  153 => [:SECRET_Tucker,"Tucker",4,"\\bTucker: Ahahah! Do you hear it? They're all itching to see our partnership!","\\bTucker: Embrace the brilliant glow!","\\bTucker: Oh well!"],
  154 => [:SECRET_Lucy,"Lucy",4,"\\rLucy: I've trampled flowers and braved storms to get to where I am today.","\\rLucy: Your luck... I hope you didn't use it all up.","\\rLucy: Disappear already..."],
  155 => [:SECRET_Spenser,"Spenser",4,"\\bSpenser: The bond you share with your Pokémon! Prove it!","\\bSpenser: Your Pokémon's eyes are truly clear and unclouded.","\\bSpenser: Hahahaha!!"],
  156 => [:SECRET_Anabel,"Anabel",4,"\\rAnabel: Let me see your talent in its entirety.","\\rAnabel: Looks like we have a job to do.","\\rAnabel: Next time!"],
  157 => [:SECRET_Brandon,"Brandon",4,"\\bBrandon: You coming here means you have that much confidence in yourself, am I right?","\\bBrandon: Hahahah! This should be exciting!","\\bBrandon: Well well..."],
  158 => [:SECRET_Palmer,"Palmer",4,"\\bPalmer: We'll have to give them our best effort, as a way of respect!","\\bPalmer: Bravo! I look forward to this on a great deal.","\\bPalmer: No problem!"],
  159 => [:SECRET_Dahlia,"Dahlia",4,"\\rDahlia: No need to worry. Let chance do what it does.","\\rDahlia: Are you incredible because you are so lucky?","\\rDahlia: Swayed by luck."],
  160 => [:SECRET_Thorton,"Thorton",4,"\\bThorton: Just so you know, pleasure to meet me.","\\bThorton: According to my data, battling with me is the optimal choice.","\\bThorton: Calculated."],
  161 => [:SECRET_Darach,"Darach",4,"\\bDarach: Let me assure you, you won't be shortchanged with me.","\\bDarach: Allow me to accompany you.","\\bDarach: Please excuse me."],
  162 => [:SECRET_Argenta,"Argenta",4,"\\rArgenta: I believe I am the most daunting pick here.","\\rArgenta: Oh. You made a good pick. ","\\rArgenta: Fun times seem to last only a moment."],
  163 => [:SECRET_Milo,"Milo",4,"\\bMilo: We're not going to be done in that easy! We're tough as weeds!","\\bMilo: All right. Let's get going!","\\bMilo: All right, then. See you!"],
  164 => [:SECRET_Nessa,"Nessa",4,"\\rNessa: I'll show you why they call me the raging wave!","\\rNessa: Hope you're ready to make some waves!","\\rNessa: Bye! See you soon."],
  165 => [:SECRET_Kabu,"Kabu",4,"\\bKabu: Should you need my help, please do not hesitate to ask. I'll turn up the heat for you!","\\bKabu: I will expend my strength while learning from your example.","\\bKabu: See you again."],
  166 => [:SECRET_Bea,"Bea",4,"\\rBea: I'll use karate along with my Pokémon's moves!","\\rBea: Allow me to fight by your side.","\\rBea: Farewell."],
  167 => [:SECRET_Allister,"Allister",4,"\\bAllister: There are things that... only I can see. D-do you... wanna know about them?","\\bAllister: We can fight... together!","\\bAllister: G-g'bye!"],
  168 => [:SECRET_Opal,"Opal",4,"\\rOpal: You could use some more pink, child.","\\rOpal: Good. Let me show you the power of pink, child.","\\rOpal: On you go, child."],
  169 => [:SECRET_Gordie,"Gordie",4,"\\bGordie: If we team up, our battles are bound to get the crowd going!","\\bGordie: We're a monolith of power!","\\bGordie: Later!"],
  170 => [:SECRET_Melony,"Melony",4,"\\rMelony: I think you'll find my battle style is quite severe.","\\rMelony: Very well, I will lend you my help.","\\rMelony: See you later."],
  171 => [:SECRET_Avery,"Avery",4,"\\bAvery: With my prodigious psychic powers, the idea that anyone should ever be able to defeat us is positively unimaginable!","\\bAvery: Allow me to assist you - with elegance!","\\bAvery: A good day to you, then."],
  172 => [:SECRET_Klara,"Klara",4,"\\rKlara: This seems like a great chance to show off just how toxic we can be!","\\rKlara: Choosing me, eh? You really know what you're doing!","\\rKlara: Buh-bye!"],
  173 => [:SECRET_Piers,"Piers",4,"\\bPiers: Get ready for a mosh pit with me and my partner!","\\bPiers: Now, time to rock!","\\bPiers: Cheers."],
  174 => [:SECRET_Mustard,"Mustard",4,"\\bMustard: I'm just itching for a battle!","\\bMustard: I'm pleased as cheese to join you!","\\bMustard: Catch you around!"],
  175 => [:SECRET_Peony,"Peony",4,"\\bPeony: Let's have ourselves a smashin' adventure!","\\bPeony: Off we go, chief!","\\bPeony: Come on, mate! Don't leave me hangin'!"],
  176 => [:SECRET_Raihan,"Raihan",4,"\\bRaihan: We'll send everyone in the stadium flying!","\\bRaihan: I'll show you what it's like to have a future champ by your side!","\\bRaihan: Cheers!"],
  177 => [:SECRET_Leon,"Leon",4,"\\bLeon: You've got nothing to worry about while I'm around.","\\bLeon: We're going to get the crowd roaring!","\\bLeon: 'Til next time!"],
  178 => [:SECRET_Hop,"Hop",4,"\\bHop: Let's show everyone the greatest battle ever – and set the world on fire!","\\bHop: Let's give 'em a taste of our true power!","\\bHop: Catch you later!"],
  179 => [:SECRET_Bede,"Bede",4,"\\bBede: Let's show them a world they haven't seen before.","\\bBede: Follow my example.","\\bBede: I suppose I must excuse myself."],
  180 => [:SECRET_Marnie,"Marnie",4,"\\rMarnie: My cheers will really get us goin'!","\\rMarnie: Sure, I can lend you a hand.","\\rMarnie: See you 'round."],
  181 => [:SECRET_Victor,"Victor",4,"\\bVictor: I'll show you what I can do!","\\bVictor: Let me join you!","\\bVictor: Later!"],
  182 => [:SECRET_Gloria,"Gloria",4,"\\rGloria: Hullo! You're bringing me along, right?","\\rGloria: Of course you are.","\\rGloria: Aww, see ya!"],
  183 => [:SECRET_Magnolia,"Magnolia",4,"\\rMagnolia: You look like you could you an expert on Dynamax by your side.","\\rMagnolia: I'll give you all the support I can give.","\\rMagnolia: Very well."],
  184 => [:SECRET_Sonia,"Sonia",4,"\\rSonia: Y-you want me on the team?","\\rSonia: All right! I'll count on you if we're in a pinch!","\\rSonia: Alright. Byeee!"],
  185 => [:SECRET_Oleana,"Oleana",4,"\\rOleana: There is beauty, even in trash.","\\rOleana: Ohoho, interesting! Allow me to join you.","\\rOleana: I must excuse myself."],
  186 => [:SECRET_Rose,"Rose",4,"\\bRose: I'm curious to see your potential.","\\bRose: Excellent. I'll give it my all as well!","\\bRose: Goodbye for now!"],
  187 => [:SECRET_Mai,"Mai",4,"\\rMai: Want me to lend you a hand?","\\rMai: Time to investigate!","\\rMai: Later!"],
  188 => [:SECRET_Lian,"Lian",4,"\\bLian: I suppose I shouldn't turn you away before you say anything.","\\bLian: Help? I suppose you recognise my skill.","\\bLian: And it seems we've settled things here."],
  189 => [:SECRET_Arezu,"Arezu",4,"\\rArezu: I'm great at both Pokémon battles and haircuts!","\\rArezu: Count me in! I'd like to learn even more with you!","\\rArezu: Let me know if you'd like a haircut later!"],
  190 => [:SECRET_Calaba,"Calaba",4,"\\rCalaba: I suppose you've come to bother me to ask for my help.","\\rCalaba: I suppose I could lend a whelp like you my guidance.","\\rCalaba: Ho, interesting!"],
  191 => [:SECRET_Iscan,"Iscan",4,"\\bIscan: So, um... you want m-my help?","\\bIscan: Well then... i-if you insist.","\\bIscan: Um... okay."],
  192 => [:SECRET_Palina,"Palina",4,"\\rPalina: I would be happy to see your potential in action, by your side.","\\rPalina: Certainly.","\\rPalina: You'd best be off then."],
  193 => [:SECRET_Melli,"Melli",4,"\\bMelli: So, you want to team up with the great Melli?","\\bMelli: Fine! Be glad and rejoice!","\\bMelli: Oh, for shame! What utter calamity..."],
  194 => [:SECRET_HIngo,"Ingo",4,"\\bIngo: Let's conduct our victory together.","\\bIngo: Onward we roll!","\\bIngo: Until next time."],
  195 => [:SECRET_Sabi,"Sabi",4,"\\rSabi: You'll always be okay if you've got a trusty partner, like me!","\\rSabi: It's nice having someone new to play with! Let's go!","\\rSabi: Aww, you don't want to play with Sabi?"],
  196 => [:SECRET_Gaeric,"Gaeric",4,"\\bGaeric: My musculature is as hard and unyielding as ice!","\\bGaeric: This one's alright. Let's get on with it now!","\\bGaeric: Till next we meet!"],
  197 => [:SECRET_Coin,"Coin",4,"\\rCoin: I'm bored. Wish there were someone to rob...","\\rCoin: Oh? I'll be your good-luck piece, then!","\\rCoin: Guess I lose the coin toss sometimes..."],
  198 => [:SECRET_Charm,"Charm",4,"\\rCharm: You don't appear to be frightened to see me.","\\rCharm: Very well, I'll be your lucky Charm!","\\rCharm: I suppose Charms don't work all the time..."],
  199 => [:SECRET_Clover,"Clover",4,"\\rClover: You saw me out here and didn't even think to turn and run?","\\rClover: Hehe, your luck won't run out with me by your side!","\\rClover: I guess my luck ran out..."],
  200 => [:SECRET_Beni,"Beni",4,"\\bBeni: Oh, you see potential in my ninja techniques?","\\bBeni: Your dream of victory is mine, too.","\\bBeni: It seems my ninja techniques will soon be consigned to history..."],
  201 => [:SECRET_Zisu,"Zisu",4,"\\rZisu: Hey! Did you need something from me?","\\rZisu: Captain Zisu of the Security Corps, reporting for duty!","\\rZisu: Take all the time you need to think it through."],
  202 => [:SECRET_Kamado,"Kamado",4,"\\bKamado: Hrrm. Would you like me to accompany you?","\\bKamado: Hrrm! I shall lend you my strength.","\\bKamado: Hrrm. Very well."],
  203 => [:SECRET_Irida,"Irida",4,"\\rIrida: Let's explore a world we've never seen before!","\\rIrida: Great choice! You won't regret it!","\\rIrida: See you!"],
  204 => [:SECRET_Adaman,"Adaman",4,"\\bAdaman: I'll cut the greetings! We don't have any more time to waste!","\\bAdaman: You can count on me.","\\bAdaman: See ya later!"],
  205 => [:SECRET_Cyllene,"Cyllene",4,"\\rCyllene: You may use my assistance.","\\rCyllene: Let's go.","\\rCyllene: I'll allow it."],
  206 => [:SECRET_Akari,"Akari",4,"\\rAkari: Show me how you make a heart-to-heart connection with Pokémon!","\\rAkari: Okay! Let's do this together!","\\rAkari: I'll see you later."],
  207 => [:SECRET_Rei,"Rei",4,"\\bRei: I still don't know much about this place... mind if I team up with you?","\\bRei: Great. I'll show you my skills!","\\bRei: Okay. See ya."],
  208 => [:SECRET_Laventon,"Laventon",4,"\\bLaventon: Shall we help each other out?","\\bLaventon: Well, that's smashing!","\\bLaventon: Ah, I suppose that can happen."],
  209 => [:SECRET_Cogita,"Cogita",4,"\\rCogita: Oh my, would you like to utilise the power of Sinnoh's myths and legends?","\\rCogita: Very well.","\\rCogita: On with you, then."],
  210 => [:SECRET_Volo,"Volo",4,"\\bVolo: I'll fight to seize my dream, even if I must do it alone!","\\bVolo: Very well. I'll lend you my power.","\\bVolo: Until next time."]
  }
  return duetTrainersMap[number]
end

def nextDuet(max)
  trainers = [randomTrainer(max, 0), randomTrainer(max, 0), randomTrainer(max, 0)]
  pbSet(GCVariables::DUET_TRAINER_NUMS, trainers)
  trainer_ids = (
    [getDuetTrainer(trainers[0])] +
    [getDuetTrainer(trainers[1])] + 
    [getDuetTrainer(trainers[2])])
  pbSet(GCVariables::DUET_TRAINER_OPTIONS, trainer_ids)
  events = [82, 84, 86]
  for i in 0...3
    filename = trainer_ids[i][0][0...]
    event = get_character(events[i])
    event.character_name = filename
  end
end

def setChallengeSprite(vari,event,challenge="Duet",filename="")
  if challenge == "Duet"
    filename = getDuetTrainer(pbGet(vari))[0][0...]
  elsif challenge == "Titan"
    filename = pbGet(vari)[0][0...]
  end
  event = get_character(event)
  event.character_name = filename
end

def makePartner(vari)
  case vari
  when 1
    pbSet(GCVariables::DUET_PARTNER,
      pbGet(GCVariables::DUET_TRAINER_OPTIONS)[0])
    $game_variables[GCVariables::TRAINER_POOL].push(
      pbGet(GCVariables::DUET_TRAINER_NUMS)[1])
    $game_variables[GCVariables::TRAINER_POOL].push(
      pbGet(GCVariables::DUET_TRAINER_NUMS)[2])
    partner_num = pbGet(66)[0]
  when 2
    pbSet(GCVariables::DUET_PARTNER,
      pbGet(GCVariables::DUET_TRAINER_OPTIONS)[1])
    $game_variables[GCVariables::TRAINER_POOL].push(
      pbGet(GCVariables::DUET_TRAINER_NUMS)[0])
    $game_variables[GCVariables::TRAINER_POOL].push(
      pbGet(GCVariables::DUET_TRAINER_NUMS)[2])
    partner_num = pbGet(66)[1]
  when 3
    pbSet(GCVariables::DUET_PARTNER,
      pbGet(GCVariables::DUET_TRAINER_OPTIONS)[2])
    $game_variables[GCVariables::TRAINER_POOL].push(
      pbGet(GCVariables::DUET_TRAINER_NUMS)[0])
    $game_variables[GCVariables::TRAINER_POOL].push(
      pbGet(GCVariables::DUET_TRAINER_NUMS)[1])
    partner_num = pbGet(GCVariables::DUET_TRAINER_NUMS)[2]
  end
  partner = pbGet(GCVariables::DUET_PARTNER)
  pbRegisterPartner(partner[0], partner[1], partner[2])
  pbSet(GCVariables::DUET_PARTNER, partner_num)
  pbSet(GCVariables::DUET_TRAINER_NUMS, 
    randomTrainer(pbGet(GCVariables::MAX_TRAINERS_IN_CHALLENGE), 0))
  pbSet(GCVariables::TRAINER_RANDOMIZER, 
    randomTrainer(pbGet(GCVariables::MAX_TRAINERS_IN_CHALLENGE), 0))
end

def duetBattle
  duetBattleTrainers = [
    getDuetTrainer(pbGet(GCVariables::DUET_TRAINER_NUMS)),
    getDuetTrainer(pbGet(GCVariables::TRAINER_RANDOMIZER))]
  trainer1 = duetBattleTrainers[0]
  trainer2 = duetBattleTrainers[1]
  return pbDoubleTrainerBattle(trainer1[0], trainer1[1], trainer1[2], nil,
                               trainer2[0], trainer2[1], trainer2[2], nil)
end


# Sync Challenge
def randomSyncTrainer(number,increment=0)
  trainers = pbGet(GCVariables::TRAINER_POOL)
  max = trainers.length
  pbSet(GCVariables::TRAINER_RANDOMIZER, rand(number) + 1 + increment)
  check = trainerCheck(trainers)
  while !check
    pbSet(GCVariables::TRAINER_RANDOMIZER, rand(number) + 1 + increment)
    check = trainerCheck(trainers)
  end
  trainers.delete(pbGet(GCVariables::TRAINER_RANDOMIZER))
  pbSet(GCVariables::TRAINER_POOL, trainers)
  return pbGet(GCVariables::TRAINER_RANDOMIZER)
end

def createSygnaArray
  breakPoint = 29
  # round < 3 - max 1 MF, round < 6 - max 2, else anything goes
  round = pbGet(GCVariables::SYGNA_CREDITS) / 5
  trainers = pbGet(GCVariables::TRAINER_POOL)
  selected = []
  mfs = 0 # mf stands for master fair btw lol
  
  3.times do
    trainer = trainers.sample
    while trainer >= breakPoint && pbGet(99) != 11 &&
        ((round < 3 && mfs > 0) || (round < 6 && mfs > 1))
      trainer = trainers.sample
    end
    mfs += 1 if trainer >= breakPoint
    selected.push(getSygnaTrainer(trainers.delete(trainer)))
  end
  pbSet(GCVariables::SYGNA_TRAINERS, selected)
end

def nextSygna(max=pbGet(GCVariables::MAX_TRAINERS_IN_CHALLENGE))
  return if pbGet(GCVariables::TRAINER_POOL).length < 3
  createSygnaArray
end

def getSygnaTrainer(number)
  sygnaTrainersMap = {
  # Standard Trainers
  1   => [:SYGNA_Brock,"Brock","\\bBrock: My Pokémon and I are rock-hard with true-grit determination!"],
  2   => [:SYGNA_Misty,"Misty","\\rMisty: We'll show you an elegant battle!"],
  3   => [:SYGNA_Erika,"Erika","\\rErika: I won't go easy on you!"],
  4   => [:SYGNA_Red,"Red","\\bRed: ..."],
  5   => [:SYGNA_Leaf,"Leaf","\\rLeaf: You think you can get through me?"],
  6   => [:SYGNA_Blue,"Blue","\\bBlue: We're at the top of our game!"],
  7   => [:SYGNA_Giovanni,"Giovanni","\\bGiovanni: Can you handle this?"],
  8   => [:SYGNA_Morty,"Morty","\\bMorty: The future is ours!"],
  9   => [:SYGNA_Brendan,"Brendan","\\bBrendan: See if you can keep up with us!"],
  10  => [:SYGNA_May,"May","\\rMay: We're gonna win this!"],
  11  => [:SYGNA_Steven,"Steven","\\bSteven: Let's get started."],
  12  => [:SYGNA_Cyrus,"Cyrus","\\bCyrus: The human heart is weak."],
  13  => [:SYGNA_Cynthia,"Cynthia","\\rCynthia: No need for words."],
  14  => [:SYGNA_Dawn,"Dawn","\\rDawn: We won't lose to anyone!"],
  15  => [:SYGNA_Elesa,"Elesa","\\rElesa: Think you can keep up with us, sweetie?"],
  16  => [:SYGNA_Grimsley,"Grimsley","\\bGrimsley: Winner takes all!"],
  17  => [:SYGNA_Hilbert,"Hilbert","\\bHilbert: Let's do this!"],
  18  => [:SYGNA_Hilda,"Hilda","\\rHilda: This battle is ours to win!"],
  19  => [:SYGNA_Korrina,"Korrina","\\rKorrina: Let's give it all we've got!"],
  20  => [:SYGNA_Silver,"Silver","\\bSilver: We can't lose here!"],
  21  => [:SYGNA_Lysandre,"Lysandre","\\bLysandre: Conviction without power is meaningless."],
  22  => [:SYGNA_Roxie,"Roxie","\\rRoxie: Up for a jam?"],
  23  => [:SYGNA_Piers,"Piers","\\bPiers: Listen to my soulful melody."],
  24  => [:SYGNA_Ingo,"Ingo","\\bIngo: Ready for an exciting train ride?"],
  25  => [:SYGNA_Emmet,"Emmet","\\bEmmet: Our next stop is: victory!"],
  26  => [:ANNI_May,"May","\\rMay: Let's be friends after this battle, okay?"],
  27  => [:ANNI_Skyla,"Skyla","\\rSkyla: Time for lift-off!"],
  28  => [:ANNI_Raihan,"Raihan","\\bRaihan: You can't tame us!"],
  # Tougher Trainers
  29  => [:SYGNA_Wally,"Wally","\\bWally: We'll win this for sure!"],
  30  => [:SYGNA_N,"N","\\bN: We'll put our hearts into this!"],
  31  => [:SYGNA_Diantha,"Diantha","\\rDiantha: This win will be ours!"],
  32  => [:SYGNA_Leon,"Leon","\\bLeon: Let's have a Champion Time!"],
  33  => [:SYGNA_Hau,"Hau","\\bHau: Bring it on!"],
  34  => [:SYGNA_Lana,"Lana","\\rLana: Let's reel them in!"],
  35  => [:SYGNA_Acerola,"Acerola","\\rAcerola: We're gonna get serious!"],
  36  => [:SYGNA_Mina,"Mina","\\rMina: That's a great composition. Let me sketch it."],
  37  => [:DOJO_Gloria,"Gloria","\\rGloria: Time to unleash the power!"],
  # Master Sync Pairs
  38  => [:SYGNA_Red2,"Red","\\bRed: ..."],
  39  => [:SYGNA_Ethan,"Ethan","\\bEthan: We'll overcome any obstacle like a cyclone!"],
  40  => [:SYGNA_Lyra,"Lyra","\\rLyra: Let's get this battle going!"],
  41  => [:SYGNA_Kris,"Kris","\\rKris: I'll prove that knowledge matters in battles too!"],
  42  => [:SYGNA_Cynthia2,"Cynthia","\\rCynthia: Let the battle begin."],
  43  => [:SYGNA_Cynthia3,"Cynthia","\\rCynthia: We'll give this all we've got!"],
  44  => [:SYGNA_Serena,"Serena","\\rSerena: Let's see what you can do!"],
  45  => [:SYGNA_Lusamine,"Lusamine","\\rLusamine: Feel our blinding light!"],
  46  => [:SYGNA_Gladion,"Gladion","\\bGladion: I'll show you some soul!"],
  47  => [:SYGNA_Giovanni2,"Giovanni","\\bGiovanni: Bear witness to my endless ambition."],
  48  => [:ANNI_Lillie,"Lillie","\\rLillie: This is my Z-powered form!"],
  49  => [:ANNI_N,"N","\\bN: Truth is the strongest form of power."],
  50  => [:ANNI_Steven,"Steven","\\bSteven: I'm the strongest there is!"],
  51  => [:NC_Silver,"Silver","\\bSilver: We can't afford to lose now!"],
  52  => [:NC_Cheren,"Cheren","\\bCheren: We'll show you what we've learnt."],
  53  => [:NC_Bianca,"Bianca","\\bBianca: Time to take the next steps to glory!"],
  54  => [:NC_May,"May","\\rMay: Let's ride this wave!"],
  55  => [:NC_Brendan,"Brendan","\\bBrendan: Let's get heated up!"],
  56  => [:NC_Serena,"Serena","\\rSerena: I'm going to be strong enough to beat my best rival."],
  57  => [:NC_Calem,"Calem","\\bCalem: Want to see what we can do at the beginning of our new journey?"],
  58  => [:NC_Nate,"Nate","\\bNate: Let's have a battle that'll touch everyone's hearts."],
  59  => [:NC_Rosa,"Rosa","\\rRosa: Let's make a beautiful melody!"],
  60  => [:NC_Red,"Red","\\bRed: ..."],
  61  => [:NC_Leaf,"Leaf","\\rLeaf: My love for my Pokémon gives me strength!"],
  62  => [:NC_Blue,"Blue","\\bBlue: Alright guys, follow me and try to keep up!"],
  63  => [:NC_Marnie,"Marnie","\\rMarnie: Wanna battle? I bet'cha do."],
  64  => [:NC_Hop,"Hop","\\bHop: I'll show you what makes a Champion Professor strong!"],
  65  => [:NC_Bede,"Bede","\\bBede: Hmph! You're no match for us."],
  66  => [:NC_Elio,"Elio","\\bElio: We're brighter than the sun!"],
  67  => [:NC_Selene,"Selene","\\rSelene: We're shining brighter than the moon!"],
  99  => [:SECRET_Lucker2,"Luc-ker","\\bLuc-ker: You won't last in the presense of our aura!"]
  }
  trainer = sygnaTrainersMap[number]
  return trainer
end

def setSprites
  trainers = pbGet(GCVariables::SYGNA_TRAINERS)
  events = [131,130,128]
  3.times do |i|
    filename = trainers[i][0][0...]
    event = get_character(events[i])
    event.character_name = filename
  end
end

def sygnaBattle(luc=false)
  $game_variables[GCVariables::SYGNA_TRAINERS][1] = getSygnaTrainer(99) if luc
  trainer1 = pbGet(GCVariables::SYGNA_TRAINERS)[0]
  trainer2 = pbGet(GCVariables::SYGNA_TRAINERS)[1]
  trainer3 = pbGet(GCVariables::SYGNA_TRAINERS)[2]
  pbMessage(_INTL(trainer1[2]))
  pbMessage(_INTL(trainer2[2]))
  pbMessage(_INTL(trainer3[2]))
  pbSet(1, pbTripleTrainerBattle(trainer1[0], trainer1[1], 0, nil,
    trainer2[0], trainer2[1], 0, nil,
    trainer3[0], trainer3[1]))
end

def sygnaHealing
  sygnaHPRestore
  sygnaPPRestore
end

def sygnaRevive
  return if $Trainer.party.length < 3
  while $Trainer.able_pokemon_count < 3
    num = rand($Trainer.party.length)
    pkmn = $Trainer.party[num]
    next if !pkmn.fainted?
    pkmn.hp = (pkmn.totalhp/2).floor
    pkmn.hp = 1 if pkmn.hp<=0
    pkmn.heal_status
    pbMessage(_INTL("{1}'s HP was restored.",pkmn.name))
  end
end

def sygnaHPRestore
  if hasActiveBuff("HP Recovery Lv. 3")
    amt = 1
  elsif hasActiveBuff("HP Recovery Lv. 2")
    amt = 0.5
  elsif hasActiveBuff("HP Recovery Lv. 1")
    amt = 0.25
  else
    amt = 0.1
  end
  $Trainer.party.each do |poke|
    next if poke.egg?
    if poke.fainted?
      poke.hp += poke.totalhp / 10
    else
      restore = [amt * poke.totalhp, poke.totalhp - poke.hp].min
      poke.hp += restore
    end
  end
end

def sygnaPPRestore
  if hasActiveBuff("PP Recovery Lv. 3")
    div = 1
  elsif hasActiveBuff("PP Recovery Lv. 2")
    div = 2
  elsif hasActiveBuff("PP Recovery Lv. 1")
    div = 4
  else
    div = 8
  end
  $Trainer.party.each do |poke|
    next if poke.egg?
    poke.moves.each do |m|
      next if m.pp == m.total_pp
      ppGain = [m.total_pp / div, m.total_pp - m.pp].min
      ppGain = 1 if ppGain < 1
      m.pp += ppGain
    end
  end
end

def sygnaStatusRestore
  return if !hasActiveBuff("Status Recovery")
  $Trainer.party.each do |poke|
    next if poke.egg?
    poke.status = :NONE
  end
end

# Titan Challenge
def titanBattle(var=GCVariables::SYGNA_TRAINERS)
  trainer = pbGet(var)
  pbMessage(_INTL(trainer[2]))
  setBattleRule("3v1")
  pbSet(1, pbTrainerBattle(trainer[0], trainer[1]))
end

def inSyncOrTitan
  return ($game_switches[693] || $game_switches[694])
end


# Despair Challenge
def getArcTrainer(number)
  arcTrainersMap = {
  1  => [:ARC_Cynthia,"Cynthia","\\rCynthia: No need for words.",4],
  2  => [:ARC_Lance,"Lance","\\bLance: We accept your challenge.",16],
  3  => [:ARC_Steven,"Steven","\\bSteven: We're truly the strongest there are now!",8],
  4  => [:ARC_Leon,"Leon","\\bLeon: Let's have a Champion Time!",10],
  5  => [:ARC_N,"N","\\bN: Time for you to face our fully realised ideals.",17],
  6  => [:ARC_Alder,"Alder","\\bAlder: We'll prove we have no limits.",6],
  7  => [:ARC_Silver,"Silver","\\bSilver: To prove that our hearts are stronger than before, we'll crush you.",10],
  8  => [:ARC_Ethan,"Ethan","\\bEthan: We're soaring high!",2],
  9  => [:ARC_Blue,"Blue","\\bBlue: Try to keep up with our mach 2 speed!",2],
  10 => [:ARC_Brock,"Brock","\\bBrock: You won't break our rock-solid bonds!",5],
  11 => [:ARC_Misty,"Misty","\\rMisty: Ready to face my policy for battle?",11],
  }
  trainer = arcTrainersMap[number]
  return trainer
end

def generateArc
  createNew(6)
  trainers = pbGet(GCVariables::TRAINER_POOL).sample(3)
  arceus_events = [152, 154, 158]
  trainer_events = [159, 160, 161]
  for i in 0...3
    trainers[i] = getArcTrainer(trainers[i])
    setChallengeSprite(-1, trainer_events[i], "despair", trainers[i][0][0...])
    setChallengeSprite(-1, arceus_events[i], "despair", "ARCEUS_#{trainers[i][3]}")
  end
  pbSet(GCVariables::SYGNA_TRAINERS, trainers)
end

def arcMessages
  trainer1 = pbGet(GCVariables::SYGNA_TRAINERS)[0]
  trainer2 = pbGet(GCVariables::SYGNA_TRAINERS)[1]
  trainer3 = pbGet(GCVariables::SYGNA_TRAINERS)[2]
  pbMessage(_INTL(trainer1[2]))
  pbMessage(_INTL(trainer2[2]))
  pbMessage(_INTL(trainer3[2]))
end

def arcBattle
  trainer1 = pbGet(GCVariables::SYGNA_TRAINERS)[0]
  trainer2 = pbGet(GCVariables::SYGNA_TRAINERS)[1]
  trainer3 = pbGet(GCVariables::SYGNA_TRAINERS)[2]
  pbSet(1, pbTripleTrainerBattle(trainer1[0], trainer1[1], 0, nil,
    trainer2[0], trainer2[1], 0, nil,
    trainer3[0], trainer3[1]))
end


# Other GC stuff
def creditMoneyExchange
  oldMoney = $Trainer.money
  params = ChooseNumberParams.new
  params.setRange(1, pbGet(GCVariables::GC_CREDITS))
  params.setInitialValue(1)
  params.setCancelValue(0)
  money = pbMessageChooseNumber(_INTL("How many credits would you like to exchange?"), params)
  if money > 0
    pbSet(GCVariables::GC_CREDITS, pbGet(GCVariables::GC_CREDITS) - money)
    money = money * 10000
    $Trainer.money += money
    moneyGained = $Trainer.money - oldMoney
    pbMessage(_INTL("Obtained {1} money!", moneyGained))
  end
end

def grandeurItemExchange(item,itemprice)
  credits = pbGet(GCVariables::GC_CREDITS)
  maxitems = credits/itemprice
  params = ChooseNumberParams.new
  params.setRange(1, maxitems)
  params.setInitialValue(1)
  params.setCancelValue(0)
  items = pbMessageChooseNumber(_INTL("\\CN\\bHow many {1} would you like? (max.{2})",
            GameData::Item.get(item).name_plural, maxitems), params)
  if items > 0
    if $PokemonBag.pbCanStore?(item, items)
      pbSet(GCVariables::GC_CREDITS, credits-itemprice*items)
      pbReceiveItem(item,items)
      pbMessage(_INTL("REDEEM SUCCESSFUL! THANK YOU!"))
    else
      pbMessage(_INTL("\\CN\\bYou have no room in your Bag."))
    end
  end
end

def givePassive
  $Trainer.party.pbChooseNonEggPokemon(1,3)
  poke = $Trainer.party[pbGet(1)]
  passive = [:ACTIVEHEALING, :BRAWNGAIN, :SHIELDINGSTRIKES, :MINDSWELL,
             :ACUMEN, :FLEETFEET, :PRECISIONGAIN, :SHIFTYSTRIKER,
             :EAGLEEYE, :BEEFUP, :TOUGHENUP, :SOUPUP, :TIGHTENUP,
             :LOOKALIVE, :FIERCEENTRY, :SENTRYENTRY, :GRANDENTRY,
             :WISEENTRY, :SPEEDYENTRY, :PINPOINTENTRY, :AGILEENTRY,
             :TERRIFY, :ENFEEBLE, :DISCOURAGE, :BEFUDDLE, :TRIPWIRE,
             :BEDAZZLE, :IMPOSE, :SIMPLESETUP, :ARCTICARRIVAL, :SUNBURST,
             :DOWNPOUR, :CONDUCTIVEPLANT, :VERDANTTURF, :WEIRDSTASIS,
             :PASSIONAURA, :COLDFRONT, :SANDKICKER, :WASTELAND,
             :DOWNTOEARTH, :LANDINGPAD, :WONDERWORLD, :CLIMBTOEDGE,
             :HAUNTEDFALLING, :DRACODOMAIN, :UMBRALCALL,
             :IRONSURROUNDINGS, :ETHEREALENTRANCE].sample
  if poke.unlockPassive || !poke.passive
    pbMessage(_INTL("{1}'s passive ability was unlocked and became {2}!",
              pbGet(3), GameData::Ability.try_get(passive).name))
  else
    pbMessage(_INTL("{1}'s passive ability changed from {2} to {3}!",
              pbGet(3), poke.passive.name, GameData::Ability.try_get(passive).name))
  end
  poke.passive = passive
end
