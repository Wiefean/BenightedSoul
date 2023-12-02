--English

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Pocket = mod.IBS_Pocket
local IBS_Player = mod.IBS_Player

local LANG = "en_us"

--------------------------------------------------------
-----------------------Birthright-----------------------
--------------------------------------------------------
local birthrightEID = {

[IBS_Player.bisaac] = {
	name = "Benighted Isaac",
	info = "Grants flight#There are more options in devil/angel room"
},

[IBS_Player.bmaggy] = {
	name = "Benighted Magdalene",
	info = "Doubles natrual iron heart recovery"
},

[IBS_Player.bcain] = {
	name = "Benighted Cain",
	info = "No control reverse on the second"
},

[IBS_Player.babel] = {
	name = "Benighted Abel",
	info = "No control reverse on the second"
},

[IBS_Player.bjudas] = {
	name = "Benighted Judas",
	info = "{{Collectible"..(IBS_Item.tgoj).."}} Returns tears when absoring projectiles"
},


}
--------------------------------------------------------
-------------------------Item---------------------------
--------------------------------------------------------
local itemEID={

[IBS_Item.ld6]={
	name="The Light D6",
	info="Can be used without full charge"..
		 "#Rerolls items with their average quality in the current room"..
		 "#Costs charges:"..
		 "#{{Quality0}} and below: 0"..
		 "#{{Quality1}} : 1"..
		 "#{{Quality2}} : 2"..
		 "#{{Quality3}} : 3"..
		 "#{{Quality4}} and above : 6",
	virtue="Wisps that sometimes shoot holy tears#Spawns an wisp per charge cost",
	belial="The quality maybe changed a bit",
	seijaNerf="Needs{{HalfSoulHeart}}or{{HalfBlackHeart}}, and the charge cost becomes 6",
	player={[IBS_Player.bisaac]="{{HalfSoulHeart}}or{{HalfBlackHeart}}for each lacking charge"}	
},

[IBS_Item.nop]={
	name="No Options",
	info="No optional items",
	seijaNerf="Curse of the forgotten",
	player={
		[PlayerType.PLAYER_THELOST]="If there's only {{Player10}}or{{Player31}},free devil deals",
		[PlayerType.PLAYER_THELOST_B]="If there's only {{Player10}}or{{Player31}},free devil deals",
		[PlayerType.PLAYER_JACOB] = "Gains{{Collectible249}}",
		[PlayerType.PLAYER_ESAU] = "Gains{{Collectible414}}"		
	}	
},

[IBS_Item.d4d]={
	name="D4D",
	info="Changes the ID of an item closest to Isaac with relative direction"..
		 "#Left +1 ; Right -1;"..
		 "Up x2 ; Down /2",
	virtue="4 wisps that do not shoot tears",
	belial="Replaces the item with{{Collectible51}} if no corresponding ID",
	seijaNerf="Random"
},

[IBS_Item.ssg]={
	name="Shooting Stars Gazer",
	info="Double-tapping a fire key creates a special tear"..
		 "Generates an area with falling tears when the tear hits a target"..
		 "#4 seconds cooldown"
},

[IBS_Item.waster]={
	name="The Waster",
	info="Before taking damage, 25% chance to gain{{HalfSoulHeart}}and temporary{{{Collectible108}}effect in the current room"
}, 

[IBS_Item.envy]={
	name="Ennnnnnvyyyyyy",
	info="↓ {{Speed}} spd - 0.15"..
		 "#↓ {{Tears}} tears - 0.06"..
		 "#↑ {{Damage}} dmg + 1"..
		 "#6% chance to replace later items(Max:60%)"
},

[IBS_Item.gheart]={
	name="Glowing Heart",
	info="Changed by cleaning rooms, unless fully charged twice"..
		 "#-1{{BrokenHeart}}, if not, +1{{SoulHeart}}",
	virtue="Wisps that sometimes shoot holy tears",
	belial="if no{{BrokenHeart}}, instead, +1{{BlackHeart}}",
	player={[IBS_Player.bmaggy]="+20 iron hearts"}
},

[IBS_Item.pb]={
	name="Purple Bubbles",
	info="Randomly gains:"..
		 "#↓ {{Speed}} spd - 0.02"..
		 "#↑ {{Tears}} tears + 0.06"..
		 "#↑ {{Damage}} dmg + 0.1"..
		 "#↑ {{Range}} rng + 0.12"..
		 "#↓ {{Shotspeed}} sspd - 0.03"..
		 "#Reset them in the next level if not carrying this item (Unless using this item 24 times or more)",
	virtue="Wisps that sometimes shoot confusing tears",		 
	belial="No special effect"
},

[IBS_Item.cmantle]={
	name="Cursed Mantle",
	info="No effect when used directly"..
		 "Occupies the first active slot，unless holding{{Collectible260}}or{{Collectible584}}"..
		 "#Automatically used and costs 2 charges before taking damage, Isaac will negate it and then begin shadow running",
	virtue="Single room wisp per enemy killed by shadow running#Prevents occupying",
	belial="No special effect",
	player={[PlayerType.PLAYER_JUDAS_B]="Shadow running also provides{{Damage}}"}

},

[IBS_Item.hypercube]={
	name="Hypercube",
	info="Records the closest item and removes it form pools"..
		 "#If recorded before, transform items in the current room into the recorded item"..
		 "#All{{Collectible"..(IBS_Item.hypercube).."}}".."share the same record",
	virtue="Wisps that sometimes shoot homing tears",
	belial="No special effect"
},

[IBS_Item.defined]={
	name="Defined",
	info="Can be used without full charge"..
		 "#Teleports to a room with selected type"..
		 "#Double-tap "..EID.ButtonToIconMap[ButtonAction.ACTION_MAP].." to select room type",
	virtue="No wisps#Charge cost - 1",
	belial="Charge cost - 1",
	seijaNerf="25% chance to be{{Collectible324}}"
},

[IBS_Item.chocolate]={
	name="Valentinus Chocolate",
	info="{{SoulHeart}} + 2"..
		 "#Double-tapping a fire key creates a special tear that makes a normal enemy friendly with half hp"..
		 "#Two shots for a room"
},

[IBS_Item.diamoond]={
	name="Diamoond",
	info="{{Burning}} 33%Burning tear"..
		 "#{{Slow}} 33%Slowing tear"..
		 "#{{Luck}} Luck has no effect on it"..
		 "#{{Freezing}} Freezes a normal enemy that is both burning and slowing"..
		 "#Grants immunity to explosions"
},

[IBS_Item.cranium]={
	name="Weird Cranium",
	info="Isaac gets lost curse in a new level"..
		 "#Entering{{BossRoom}}boss room, + 1 {{BlackHeart}} and then removes lost curse",
	seijaBuff="10 seconds shield for each room with enemies when the curss exists"
},


[IBS_Item.ether]={
	name="Ether",
	info="Grants flight when Isaac is hurt, and then spawns holy light"..
		 "#Holy light does 2 * Isaac's DMG and ignores armor"..
		 "#The frequency of spawning holy light is attached to hurt times in the current room",
	trans={"LEVIATHAN", "ANGEL"}
},

[IBS_Item.wisper]={
	name="Wisper",
	info="Orbital"..
		 "#Does 3 * Isaac's DMG"..
		 "#30% to spawn a common wisp when killing an enemy",
	trans={"ANGEL"}
},

[IBS_Item.bone]={
	name="Bone of Temperance",
	info="Spectral and piercing tears"..
		 "#Sets tears' falling speed to 0"..
		 "#Double-tap "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].." to stop tears"..
		 "#Each tear will be recycled after 7 seconds"
},

[IBS_Item.guard]={
	name="Guard of Fortitude",
	info="Blocks projectiles facing Isaac"..
		 "#When hurt by a projectile, clear all projectiles"..
		 "Reduces explosive damage taken to half a heart"
},

[IBS_Item.v7]={
	name="V7",
	info="Spawns one of the friendly bosses below："..
		 "#Temperance"..
		 "#Fortitude",
	virtue="Common wisps",
	belial="No special effect",		 
},

[IBS_Item.tgoj]={
	name="The Gospel Of Judas",
	info="Throws a book that absorbs projectiles with collision dmg when flying"..
		 "#Recycles the book if not fully charged"..
		 "#Enough absorption, spawns a crack of{{Collectible634}}",
	virtue="Enough absorption, spawns a wisp",
	belial="Temporary{{Damage}}DMG up for a projectile absorbed",
	player={[IBS_Player.bjudas]="Temporary{{Damage}}DMG up for a projectile absorbed"},
	trans={"BOOKWORM"}
},

[IBS_Item.nail]={
	name="Reserved Nail",
	info="Fires a nail that petrifies and weakens an enemy for 3 seconds"..
		 "#DMG boosts charges",
	virtue="Wisps that do not shoot tears but petrifies and weakens enemies around for 1.5 seconds when killed#Exists only one room",
	belial="Apply fire mind effect to the nail"		 
},

[IBS_Item.superb]={
	name="Super B",
	info="Enough DMG, charges active items, including the extra charge bar"..
		 "#When hurt, keep costing charges from the extra charge bar"..
		 "#If costs charges sufficiently, makes an explosion, or stops costing charges",
	seijaNerf="The explosion may kill you"
},

[IBS_Item.dreggypie]={
	name="Dreggy Pie",
	info="{{Heart}} + 1 health up, heals 1 red heart"..
		 "#↑ {{Tears}}tears + 5 temporarily"..
		 "#Except{{Player20}}, {{Collectible"..(IBS_Item.dreggypie).."}} + {{Collectible621}} = {{Collectible619}}"
},

[IBS_Item.bonyknife]={
	name="Bony Knife",
	info="In the current room, {{Damage}}DMG * 75%(not stackable), gains{{Collectible114}}",
	virtue="Triggers this item on kill",
	belial="Fire mind"	
},

[IBS_Item.circumcision]={
	name="Circumcision",
	info="↓ {{Speed}}spd - 0.7"..
		 "#↑ {{Tears}}tears * 2"..
		 "#↑ {{Luck}}luck + 2"	
},

[IBS_Item.cheart]={
	name="Cursed Heart",
	info="{{CurseRoom}} Spawns an extra item in curse room"
},

[IBS_Item.redeath]={
	name="Re-death",
	info="Rerolls empty pedestals into one of the pickups below:"..
		 "#Chests, grab bags, pocket items, trinkets, collectibles"..
		 "#Pickups rerolled disappear in 6 seconds and are surrounded by spikes",
	virtue="No Wisps#The pickups won't disappear",
	belial="No spikes surround the pickups"	
},

[IBS_Item.dustybomb]={
	name="Dusty Bomb",
	info="+ 3{{Bomb}}Bombs"..
		 "#Isaac's bombs explode when touching an ennemy"..
		 "#When Isaac's bombs explode for the third time in a room, destroy normal enemies and bosses lose 15% health"
},

[IBS_Item.nm]={
	name="Needle Mushroom",
	info="↑ {{Speed}}spd + 0.3"..
		 "#↑ {{Tears}}tear + 0.7"..
		 "#↑ {{Range}}range + 1.25"..
		 "#When attacking, 6% chance to drop this item and the item can not be picked up within 5 seconds",
	trans={"MUSHROOM", "POOP"},
	player={[PlayerType.PLAYER_BLUEBABY_B]="Spawns a poop pickup at the same time"}
},

[IBS_Item.minihorn]={
	name="Mini Horn",
	info="Keeping attacking 6~13 seconds, spawns a troll bomb with 60 dmg under Isaac",
	seijaBuff="Instead, spawns a red bomb in 3 seconds"	
},

[IBS_Item.woa]={
	name="Wings of Apollyon",
	info="↑ {{Shotspeed}}sspd + 0.16"..
		 "#Except{{Shotspeed}}sspd, all stats * ({{Shotspeed}}sspd - 1) (MIN:100%; MAX:150%)",
	player={[PlayerType.PLAYER_APOLLYON] = "Grants flight",
			[PlayerType.PLAYER_APOLLYON_B] = "Grants flight",
	}
},

[IBS_Item.momscheque]={
	name="Mom's Cheque",
	info="No effect when used directly"..
		 "+ 3{{Coin}}"..
		 "#↑ + 1{{Luck}}luck"..
		 "#+ 7{{Coin}} when entering a new level",
	trans={"MOM"}
},

[IBS_Item.ffruit]={
	name="The Forbidden Fruit",
	info="!!! {{ColorYellow}}SINGLE USE{{CR}}"..
		 "#Removes {{Quality1}} or {{Quality3}} items form pools"..
		 "#No {{CurseUnknown}} or {{CurseBlind}} this run",
	virtue="Wisps that shoot poisonous tears",
	belial="Removes {{Quality1}} or {{Quality3}} items form Isaac, providing {{Damage}}dmg up for each item removed"
},

[IBS_Item.sword]={
	name="Sword of Siberite",
	info="Automatical"..
		 "#Blocks projectiles"..
		 "#{{Collectible536}} No effect",
	seijaNerf="Alse targets players"
},

[IBS_Item.regret]={
	name="Everlasting Regret",
	info="When Isaac dies:"..
		 "#↑ {{Speed}}spd + 0.1"..
		 "#↑ {{Tears}}tears + 0.35"..
		 "#↑ {{Damage}}dmg + 1",
	seijaBuff="{{Collectible11}} for each level if not held"		 
},

[IBS_Item.sacrifice]={
	name="Unwelcome Sacrifice",
	info="In 1.7 seconds, lower a big light pillar the spot, and make an explosion"..
		 "#The pillar deals 70% Isaac's {{Damage}} damage per frame, and destroy surrounding obstacles, lasting 3.5 seconds"..
		 "#!!! The pillar can also hurt Isaac"..
		 "#If {{Collectible"..(IBS_Item.sacrifice2).."}} have been used, then the pillar won't hurt Isaac and will follow enemies",
	virtue="No wisps#The pillar won't hurt Isaac and will follow enemies",
	belial="A bigger pillar following Isaac"
},

[IBS_Item.sacrifice2]={
	name="Welcome Sacrifice",
	info="Changed by entering devil/angel room"..
		 "#If {{Collectible"..(IBS_Item.sacrifice).."}} have been used, charge at once"..
		 "#!!! {{ColorYellow}}SINGLE USE{{CR}}"..
		 "#After used, when entering a new room with any pedestal item, additionally spawns one form devil room and one from angel room as options",
	virtue="No wisps#Charge at once",
	belial="Charge at once"
},

}
--------------------------------------------------------
-------------------------Trinket------------------------
--------------------------------------------------------
local trinketEID={

[IBS_Trinket.bottleshard]={
	name="Bottle Shard",
	info="10% chance to bleed damaged enemies with 3 extra damage",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.dadspromise]={
	name="Dad's Promise",
	info="{{BossRoom}} Finishing boss room in 45 + (15*levels) seconds brings {{Card49}}",
	mult={findReplace = {"15","20","25"}},
},

[IBS_Trinket.divineretaliation]={
	name="Divine Retaliation",
	info="10% chance to resist damage from projectiles#When hit by projectiles, transform projectiles around into fire",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}
},

[IBS_Trinket.toughheart]={
	name="Tough Heart",
	info="10% chance to resist damage#When damaged, the chance + 15% until next resistance#No effect on self-damage",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.chaoticbelief]={
	name="Chaotic Belief",
	info="When entering a new level, regarded this as a devil deal, and then angel room chance + 50%"..
		 "#{{Heart}} No devil or angel room chance decrease when red hearts damaged",
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}	
},

[IBS_Trinket.thronyring]={
	name="Throny Ring",
	info="When hurt, 9% chance to trigger:"..
		 "#{{BrokenHeart}} 50% clear a broken heart, if not then trigger next one"..
		 "#{{SoulHeart}} 25% soul heart + 1"..
		 "#{{AngelRoom}} 15% angel room chance + 10%, and remove curses"..
		 "#{{EternalHeart}} 10% eternal heart + 1",
	mult={
		numberToMultiply = 9,
		maxMultiplier = 3,
	}	
},

}
--------------------------------------------------------
--------------------------Card--------------------------
--------------------------------------------------------
local cardEID={

[IBS_Pocket.czd6] = {
	name="The Great Golden Collectible -- D6",
	info="Rerolls items#90% not to disappear, but the chance decrease per used(Also affects others)"
},

[IBS_Pocket.goldenprayer] = {
	name="Golden Prayer",
	info="+ 30 iron hearts#{{BossRoom}} After consumed, it will be spawned whten next boss room is cleared",
	mimic={charge = 6, isRune = false},
},

[IBS_Pocket.falsehood_bisaac] = {
	name="Falsehood of Isaac",
	info="Rerolls items to devil/angel items with their average quality in the current room",
	mimic={charge = 4, isRune = true}
},

[IBS_Pocket.falsehood_bmaggy] = {
	name="Falsehood of Magdalene",
	info="↑ Lasting 7 seconds, Isaac becomes invincible, + 0.7{{Speed}}spd, constantly spawns holy light and shockwave",
	mimic={charge = 6, isRune = true}
},

[IBS_Pocket.falsehood_bjudas] = {
	name="Falsehood of Judas",
	info="Darken surroundings for 3 seconds, during which next attact will fire a spectral, piercing and burning tear with 670% Isaac's{{Damage}}dmg"..
		 "#If the tear successfully hits the first enemy, gain another one {{Card"..(IBS_Pocket.falsehood_bjudas).."}}",
	mimic={charge = 1, isRune = true}
},

}
--------------------------------------------------------


return {
	BirthrightEID = birthrightEID,
	ItemEID = itemEID,
	TrinketEID = trinketEID,
	CardEID = cardEID
}