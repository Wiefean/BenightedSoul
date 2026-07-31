--English

local mod = Isaac_BenightedSoul
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID
local IBS_SlotID = mod.IBS_SlotID

local LANG = "en_us"

--------------------------------------------------------
-----------------------Character------------------------
--------------------------------------------------------
local playerEID = {

[IBS_PlayerID.BIsaac] = {
	name="Benighted Isaac",
	info="Skip {{AngelRoom}} Angel Room to transform {{TreasureRoom}} Treasure Room into {{DevilRoom}} Devil Room next level"..
		 "#Skip {{DevilRoom}} Devil Room to transform {{Shop}} Shop into {{AngelRoom}} Angel Room next level",
	br="Grants flight#Two more options in cycle in Devil/Angel Room"..
		 "#If not in Greed Mode, Devil Room / Angel Shop no longer replaces {{TreasureRoom}}Treasure Room / {{Shop}}Shop, but {{SecretRoom}}Secret / {{SuperSecretRoom}}Super Secret Room"
},

[IBS_PlayerID.BMaggy] = {
	name="Benighted Magdalene",
	info="Hearts cap 7"..
		 "#Start with protective {{IBSIronHeart}} Iron Heart"..
		 '#Release shockwave to recover {{IBSIronHeart}} Iron Heart'..
		 '#Kill sins to gain boosts'..
		 '#{{MiniBoss}}Mini-Boss Room will replace {{SacrificeRoom}}Sacrifice Room',
	br="{{IBSIronHeart}} Doubles iron heart recovery from shockwave"
},

[IBS_PlayerID.BCain] = {
	name="Benighted Cain",
	info="Touch to switch Main / Second, and no-switch for too long hurts Second"..
		 "#Holding"..EID.ButtonToIconMap[ButtonAction.ACTION_MAP].."map key stops Main"..
		 "#Holding"..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."drop key stops Second"..
		 "#Second ignores most damage and goes through obstacles, while move and shoot controls are reversed"..
		 "#When dying, if either survives, transform into a ghost player",
	br="No control reverse on Second"
},

[IBS_PlayerID.BAbel] = {
	name="Benighted Abel",
	info="Touch to switch Main / Second, and no-switch for too long hurts Second"..
		 "#Holding "..EID.ButtonToIconMap[ButtonAction.ACTION_MAP].."map key stops Main"..
		 "#Holding "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."drop key stops Second"..
		 "#Second ignores most damage and goes through obstacles, while move and shoot controls are reversed"..
		 "#When dying, if either survives, transform into a ghost player",	
	br="No control reverse on Second"
},

[IBS_PlayerID.BJudas] = {
	name="Benighted Judas",
	br="{{Collectible"..(IBS_ItemID.TGOJ).."}} Duration increases to 13 seconds and returns tears when absoring projectiles"
},

[IBS_PlayerID.BXXX] = {
	name="Benighted ???",
	info="↑ + 1% {{Tears}}tears for every {{IBSMemory}}memory"..
		 "#Tapping "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].."drop key switches the effect of "..EID.ButtonToIconMap[ButtonAction.ACTION_BOMB].."bomb key"..
		 "#Store / use a falsehood"..
		 "#Cosume 21 {{IBSMemory}}memories to spawn 3 falsehoods, but only one can be picked"..
		 "#Decompose some pickups around into {{IBSMemory}}memories"..
		 "#Use {{Bomb}}Bomb",
	br="The maximum of orbs increases to 6"
},

[IBS_PlayerID.BEve] = {
	name='Benighted Eve',
	info='Starts with familiar that blocks projectile and damage enemies'..
		 '#Using pocket {{Collectible'..(IBS_ItemID.MyFruit)..'}}My Fruit turns it into {{Collectible'..(IBS_ItemID.MyFault)..'}}My Fault, and lose the familiar'..
		 '#Return {{Collectible'..(IBS_ItemID.MyFruit)..'}}My Fruit with last used times in a new level, and refill the familiars'..
		 '#!!! {{Collectible'..(IBS_ItemID.MyFruit)..'}}My Fruit can not be returned if exhausted',	
	br='{{Collectible'..(IBS_ItemID.MyFruit)..'}} My Fruit\'s max-charge is fixed at 0#{{Collectible'..(IBS_ItemID.MyFault)..'}} My Fault will be automatically used before taking penalt damage'
},

[IBS_PlayerID.BSamson] = {
	name='Benighted Samson',
	info='Can not pick up trinkets or pocket items, but can still buy tarot cards'..
		 '#After cleaning {{BossRoom}}Boss Room, spawn a tarot card'..
		 '#Change states with {{Collectible'..(IBS_ItemID.Posture)..'}}Posture'..
		 '#{{IBSSamsonCalm}} Calm: When switching to this state, + 3s sheild, not stackable'..
		 '#{{IBSSamsonWrath}} Wrath: 14s duration; Double damage and penal hurt; Can do melee attack of {{Collectible'..(IBS_ItemID.Posture)..'}}Posture'..
		 '#{{IBSSamsonWrath}}Wrath passes 5x faster when standing by'..
		 '#!!! When taking penalt damage in {{IBSSamsonWrath}}Wrath, 50% chance to lose the selected card, except {{Card1}}The Fool ({{Luck}}Luck 10: 10%)',
	br='When enter {{IBSSamsonWrath}} Wrath, + 1 charge for {{Collectible'..(IBS_ItemID.Posture)..'}}Posture'
},


[IBS_PlayerID.BEden] = {
	name="Benighted Eden",
	info="Stats won't be affected by most effects",
	br="To points:"..
		 "#This level, items to points x 300%"..
		 "#Clear {{BrokenHeart}}Broken Hearts"..
		 "#+ 3 {{BoneHeart}}Bone Hearts"..
		 "#{{Heart}} Full health"..
		 "#Next level, DIE after 7 seconds"
},

[IBS_PlayerID.BLost] = {
	name='Benighted Lost',
	info='Flight'..
		 '#Familiar items are removed from pools'..
		 '#Spectral tears'..
		 '#10% chance to fire key tears with +1 damage ({{Luck}}luck 10: 50%)'..
		 '#Can attack at any direction'..
		 '#Non-Lost-Brithright items and some useless items would be decomposed into {{Key}}keys, and spawn chest for Q-2-or-above items'..
		 '#Hold'..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..'drop key to open a chest',
	br='+ 70 {{Key}}keys#Spawn 3 {{EternalChest}}Eternal Chest#Repair speed up'
},

[IBS_PlayerID.BKeeper] = {
	name='Benighted Keeper',
	info='Flight'..
		 '#Fire double tears'..
		 '#Gulp penny trinkets'..
		 '#Penny trinkets may affect beggar pools'..
		 '#Price x 300%, but can be decreased by donations to beggars'..
		 '#Hearts are free, and will be stored when picked; cost 14 for deadly damage and 2 for damage form slots or beggars'..
		 '#Donating to beggars increases the maximum of coin health containers until 7',
	br='Through donations to beggars, the maximum of coin health containers can reach 12; Penny trinkets have 33.3% chance to become golden'
},

}
--------------------------------------------------------
-------------------------Item---------------------------
--------------------------------------------------------
local itemEID={

[IBS_ItemID.LightD6]={
	name="The Light D6",
	info="Can be used without full charge"..
		 "#Rerolls items with their average quality in the current room"..
		 "#Costs charges:"..
		 "#{{Quality0}} 0 and below: 0"..
		 "#{{Quality1}} 1: 1"..
		 "#{{Quality2}} 2: 2"..
		 "#{{Quality3}} 3: 3"..
		 "#{{Quality4}} and above: 6",
	virtue="Inner wisps that sometimes shoot holy tears#Spawns an wisp per charge cost",
	belial="The quality maybe changed a bit",
	void="No effect",
	seijaNerf="Needs{{HalfSoulHeart}}or{{HalfBlackHeart}}, and the charge cost is fixed to 6",
},

[IBS_ItemID.NoOptions]={
	name="No Options",
	info="No optional pickups",
	player={
		[PlayerType.PLAYER_THELOST]="If there's only {{Player10}}or{{Player31}},free devil deals",
		[PlayerType.PLAYER_THELOST_B]="If there's only {{Player10}}or{{Player31}},free devil deals",
		[PlayerType.PLAYER_JACOB] = "Gains{{Collectible249}}",
		[PlayerType.PLAYER_ESAU] = "Gains{{Collectible414}}"		
	}	
},

[IBS_ItemID.D4D]={
	name="D4D",
	info="Changes the ID of an item closest to Isaac with relative direction"..
		 "#Left +1 ; Right -1;"..
		 "Up x2 ; Down /2",
	virtue="4 inner wisps that do not shoot tears",
	belial="Replaces the item with{{Collectible51}} if no corresponding ID",
	void="No effect",
	seijaNerf="Random"
},

[IBS_ItemID.SSG]={
	name="Shooting Stars Gazer",
	info="Double-tapping a fire key creates a special tear"..
		 "Generates an area with falling tears when the tear hits a target"..
		 "#4 seconds cooldown"
},

[IBS_ItemID.Waster]={
	name="The Waster",
	info="Before taking damage, 25% chance to gain{{HalfSoulHeart}}and temporary{{{Collectible108}}effect in the current room"
}, 

[IBS_ItemID.Envy]={
	name="Ennnnnnvyyyyyy",
	info="↑ {{Damage}}dmg x 1.3"..
		 "#↑ {{Luck}}luck x 1.6"..
		 "#Envy level starts at 1 (MAX:4; MIN:0)"..
		 "#When an item picked directly is higher than {{Quality2}}Q2, the level increases; if lower then decreases"..
		 "#If the level reaches:"..
		 "#{{Blank}} 2: ↓{{Luck}}Lose the luck up"..
		 "#{{Blank}} 3: ↓{{Damage}}Lose the dmg up"..
		 "#{{Blank}} 4: An item whose quality is above {{Quality2}}2 will be replaced by this item"
},

[IBS_ItemID.GlowingHeart]={
	name="Glowing Heart",
	info="Charged by cleaning rooms, and can be fully charged twice"..
		 "#-1{{BrokenHeart}}, if not, +1{{SoulHeart}}",
	virtue="Inner wisps that sometimes shoot holy tears",
	belial="if no{{BrokenHeart}}, instead, +1{{BlackHeart}}",
	player={[IBS_PlayerID.BMaggy]="+ 21 extra {{IBSIronHeart}}Iron Heart, and recover 7 lost maximum"}
},

[IBS_ItemID.PurpleBubbles]={
	name="Purple Bubbles",
	info="Randomly gains:"..
		 "#↓ {{Speed}} spd - 0.02"..
		 "#↑ {{Tears}} tears + 0.06"..
		 "#↑ {{Damage}} dmg + 0.1"..
		 "#↑ {{Range}} rng + 0.12"..
		 "#↓ {{Shotspeed}} sspd - 0.03"..
		 "#Reset them in the next level if not carrying this item (Unless using this item 24 times or more)",
	virtue="Inner wisps that sometimes shoot confusing tears",		 
	belial="No special effect",
	void="Does not reset the stats"
},

[IBS_ItemID.CursedMantle]={
	name="Cursed Mantle",
	info="No effect when used directly"..
		 "Occupies the first active slot, unless holding{{Collectible260}}or{{Collectible584}}"..
		 "#Automatically used and costs 2 charges before taking damage, triggering {{Collectible705}} Dark Arts",
	virtue="Prevents occupation",
	belial="No special effect",
	void="After absorbed, adds{{Collectible313}}effect to Isaac",
},

[IBS_ItemID.Hypercube]={
	name="Hypercube",
	info="Records the closest item and removes it form pools"..
		 "#If recorded before, transform items in the current room into the recorded item"..
		 "#All{{Collectible"..(IBS_ItemID.Hypercube).."}}".."share the same record",
	virtue="Outer wisps that shoot homing tears",
	belial="No special effect",
	void="No effect"
},

[IBS_ItemID.Defined]={
	name="Defined",
	info="Charged by cleaning rooms"..
		 "#Can be used without full charge"..
		 "#Teleports to a room with the selected type (Charge cost is related to the type), and won't cost charges when selecting the same type of a entered room this level",
	virtue="No wisps#Charge cost - 1",
	belial="Charge cost - 1",
	void="No effect",
	seijaNerf="20% chance to be {{Collectible324}}Undefined",
	player={[IBS_PlayerID.BEden]='Open the console when in the starting room'}
},

[IBS_ItemID.Chocolate]={
	name="Valentinus Chocolate",
	info="{{SoulHeart}} + 2"..
		 "#Double-tapping a fire key creates a special tear that makes a normal enemy friendly with 2.14 x Hp"..
		 "#Two shots for a room"..
		 '#Can not be triggered with 2 friendly enemies'
},

[IBS_ItemID.Diamoond]={
	name="Diamoond",
	info="Explosion immunity"..
		 "#Tears have 33% chance to become{{Burning}}burning or {{Slow}}slowing tears, + 1 dmg and can destroy obstacle"..
		 "#{{Luck}} Luck has no effect on the chance"..
		 "#{{Freezing}} Freezes normal enemies that are both burning and slowed"
},

[IBS_ItemID.Cranium]={
	name="Weird Cranium",
	info="Isaac gets{{Player10}}lost curse in a new level"..
		 "#Entering{{BossRoom}}Boss Room, + 1 {{BlackHeart}} and then removes lost curse",
	seijaBuff={
		desc = "10 seconds shield for each room with enemies when the curss exists",
		data = {
			append = function(x) 
				return (x > 1 and "#After a {{BossRoom}}Boss Room is cleared, spawn "..(x-1).." health-priced devil item"..(x>2 and 's' or '')) or ''
			end	
		}
	}
},


[IBS_ItemID.Ether]={
	name="Ether",
	info="Grants flight in the current room when Isaac is hurt, and then spawns holy light"..
		 "#Holy light does 2 * Isaac's DMG and ignores armor"..
		 "#The frequency of spawning holy light is attached to hurt times in the current room",
	trans={"LEVIATHAN", "ANGEL"}
},

[IBS_ItemID.Wisper]={
	name="Wisper",
	info="Orbital"..
		 "#Does 3 * Isaac's DMG"..
		 "#30% chance  to spawn a common wisp when killing an enemy touched by this familiar",
	trans={"ANGEL"}
},

[IBS_ItemID.BOT]={
	name="Bone of Temperance",
	info="Bouncing tears"..
		 "#Sets tears' falling speed to 0"..
		 "#Tap "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].." to stop tears, "..
		 "while double-tap to recycle them"..
		 "#↑ Recycling tears provides temporary{{Tears}}tears up (MAX:2)"..
		 "#Each tear will be automatically recycled after 7 seconds"
},

[IBS_ItemID.GOF]={
	name="Guard of Fortitude",
	info="Blocks projectiles facing Isaac"..
		 "#When hurt by a projectile, clear all projectiles"..
		 "Reduces explosive damage taken to half a heart"
},

[IBS_ItemID.V7]={
	name="V7",
	info="In the current room, spawns one of the friendly bosses below with 2x Hp:"..
		 "#Deligence & Diligence"..
		 "#Chastity"..
		 "#Fortitude"..
		 "#Temperance"..
		 "#Generosity"..
		 "#Humility",
	virtue="Common wisps",
	belial="No special effect",		 
},

[IBS_ItemID.TGOJ]={
	name="The Gospel Of Judas",
	info="Throws a book that absorbs projectiles with collision dmg when flying"..
		 "#Recycles the book if not fully charged"..
		 "#Enough absorption, spawns a crack of{{Collectible634}}",
	virtue="Enough absorption, spawns a wisp",
	belial="Temporary{{Damage}}DMG up for a projectile absorbed",
	player={[IBS_PlayerID.BJudas]="When at a distance, swaps positions by dashing with collision dmg and tears automatically fired"},
	trans={"BOOKWORM"}
},

[IBS_ItemID.ReservedNail]={
	name="The Reserved Nail",
	info="Fires a nail that petrifies and weakens an enemy for 3 seconds"..
		 "#Enemies' taking damage boosts the charge",
	virtue="Middle wisps that do not shoot tears but petrifies and weakens enemies around for 1.5 seconds when killed#Exists only one room",
	belial="Apply fire mind effect to the nail"		 
},

[IBS_ItemID.SuperB]={
	name="Super B",
	info="200 DMG charges active items, including the extra charge bar"..
		 "#When hurt by non-self-damage, keep costing charges"..
		 "#If costs charges sufficiently, makes an explosion, or stops costing charges",
	seijaNerf="The explosion hurts you"
},

[IBS_ItemID.DreggyPie]={
	name="Dreggy Pie",
	info="{{Heart}} + 1 health up, and full health"..
		 "#↑ {{Tears}}tears + 5 temporarily"..
		 "#Except{{Player20}}, {{Collectible"..(IBS_ItemID.DreggyPie).."}}Dreggy Pie + {{Collectible621}}Red Stew = {{Collectible619}}Birthright"
},

[IBS_ItemID.BonyKnife]={
	name="Bony Knife",
	info="In the current room, {{Damage}}DMG * 75%(not stackable), gains{{Collectible114}}",
	virtue="Inner wisps that triggers this item when killed",
	belial="Fire mind"
},

[IBS_ItemID.Circumcision]={
	name="Circumcision",
	info="↓ {{Speed}}spd - 0.4"..
		 "#↑ {{Tears}}tears + 2"..
		 "#↑ {{Luck}}luck + 2"	
},

[IBS_ItemID.CursedHeart]={
	name="Cursed Heart",
	info="{{CurseRoom}} Spawns a helth-priced item in Curse Room"
},

[IBS_ItemID.Redeath]={
	name="Re-death",
	info="Rerolls empty pedestals into one of the pickups below:"..
		 "#{{Blank}} Golden Chest, Old Chest, Black Sack, Golden Trinket, Collectible"..
		 "#The rerolled will disappear in 20 seconds and are surrounded by spikes",
	virtue="No Wisps#The pickups won't disappear",
	belial="No spikes surround the pickups"	
},

[IBS_ItemID.DustyBomb]={
	name="Dusty Bomb",
	info="+ 3{{Bomb}}Bombs"..
		 "#Grant immunity to explosion from Isaac's bombs"..
		 "#Isaac's bombs explode immediately when touching an ennemy"..
		 "#In a room, when Isaac's bombs explode for the first three time, enemies lose 12% current Hp; The third one can even destroy non-boss enemies"
},

[IBS_ItemID.NeedleMushroom]={
	name="Needle Mushroom",
	info="↑ {{Speed}}spd + 0.3"..
		 "#↑ {{Tears}}tear + 0.7"..
		 "#↑ {{Range}}range + 1.25"..
		 "#When attacking per second, 6% chance to drop this item and the item can not be picked up within 5 seconds",
	trans={"MUSHROOM", "POOP"},
	player={[PlayerType.PLAYER_BLUEBABY_B]="Spawns a poop pickup at the same time"}
},

[IBS_ItemID.MiniHorn]={
	name="Mini Horn",
	info="Keeping attacking 6~13 seconds, spawns a troll bomb with 60 dmg under Isaac",
	seijaBuff={
		desc = "Instead, spawns a red bomb in 3 seconds",
		data = {
			append = function(x) 
				return (x > 1 and "#Spawn"..(3*(x-1)).." more troll bombs; Provides explosion immunity") or ''
			end			
		}
	}
},

[IBS_ItemID.WOA]={
	name="Wings of Apollyon",
	info="{{Pill}} When gained, spawn a Shot Speed Up pill"..
		 "#↑ {{Shotspeed}}sspd + 0.16"..
		 "#Except{{Shotspeed}}sspd, all stats * ({{Shotspeed}}sspd - 0.3) (MIN:90%; MAX:150%)",
	player={[PlayerType.PLAYER_APOLLYON] = "Grants flight",
			[PlayerType.PLAYER_APOLLYON_B] = "Grants flight",
	}
},

[IBS_ItemID.MomsCheque]={
	name="Mom's Cheque",
	info="No effect when used directly"..
		 "#↑ + 2{{Luck}}luck"..
		 "#+ 10 {{Coin}}coins when entering a new level",
	void="Valid even after absorbed",
	trans={"MOM"}
},

[IBS_ItemID.ForbiddenFruit]={
	name="The Forbidden Fruit",
	info="!!! {{ColorYellow}}SINGLE USE{{CR}}"..
		 "#Removes {{Quality1}}Q1 items and {{Quality3}}Q3 items from pools"..
		 "#No {{CurseUnknown}} and {{CurseBlind}} this run",
	virtue="2 inner wisps that shoot poisonous tears",
	belial="Removes {{Quality1}} or {{Quality3}} items from Isaac, providing {{Damage}}dmg up for each item removed"
},

[IBS_ItemID.Sword]={
	name="Sword of Siberite",
	info="Automatical"..
		 "#Blocks projectiles"..
		 "#{{Collectible536}} No effect",
	seijaNerf="Targets you when no available enemies"
},

[IBS_ItemID.Regret]={
	name="Everlasting Regret",
	info="When Isaac dies:"..
		 "#↑ {{Speed}}spd + 0.1"..
		 "#↑ {{Tears}}tears + 0.35"..
		 "#↑ {{Damage}}dmg + 1",
	seijaBuff={
		desc = "{{Collectible11}} 1 UP for each level if not held",
		data = {
			append = function(x) 
				return (x > 1 and (x-1).."{{Card89}}Soul of Lazarus for each level") or ''
			end			
		}
	}
},

[IBS_ItemID.Sacrifice]={
	name="Unwelcome Sacrifice",
	info="In 1.7 seconds, lower a big light pillar the spot, and make an explosion"..
		 "#The pillar deals 70% Isaac's {{Damage}} damage per frame, and destroy surrounding obstacles, lasting 3.5 seconds"..
		 "#!!! The pillar can also hurt Isaac"..
		 "#If {{Collectible"..(IBS_ItemID.Sacrifice2).."}}Welcome Sacrifice had been used, then the pillar won't hurt Isaac and will follow enemies",
	virtue="No wisps#The pillar won't hurt Isaac and will follow enemies",
	belial="A bigger pillar following Isaac"
},

[IBS_ItemID.Sacrifice2]={
	name="Welcome Sacrifice",
	info="Charged by entering devil/angel room"..
		 "#If {{Collectible"..(IBS_ItemID.Sacrifice).."}}Unwelcome Sacrifice had been used, charge at once"..
		 "#!!! {{ColorYellow}}SINGLE USE{{CR}}"..
		 "#After used:"..
		 "#{{Blank}} For the item that is of the highest quality in a new room, spawns a health-priced devil item and a coin-priced angel item as options",
	virtue="No wisps#Charge at once",
	belial="Charge at once"
},

[IBS_ItemID.Multiplication]={
	name="Multiplication",
	info="The minimums of {{Coin}}Coins, {{Bomb}}bombs and {{Key}}keys become 1",
	seijaNerf="The maximums also become 1, including{{EmptyHeart}}Heart Container",
	player={
		[PlayerType.PLAYER_BLUEBABY_B] = "Also poop pickups",
		[PlayerType.PLAYER_BETHANY] = "Also soul charge",
		[PlayerType.PLAYER_BETHANY_B] = "Also blood charge",
	}
},

[IBS_ItemID.NoTemperance]={
	name="No Temperance?",
	info="For each uninvolved gambling game:"..
		 "#↑ {{Speed}}spd + 0.02"..
		 "#↑ {{Damage}}dmg + 0.2"..
		 "#↓ {{Shotspeed}}sspd - 0.02"..
		 "#↑ {{Luck}}luck + 0.25"..
		 "#For each {{ArcadeRoom}}Arcade Room not entered: 4 x stats above"
},

[IBS_ItemID.GuppysPotty]={
	name="Guppy's Potty",
	info="+ 2 smelted {{Trinket86}}Lil Larva"..
		 '#When a room is cleared, spawn a poop',
	trans={'GUPPY', 'LORD_OF_THE_FLIES', 'POOP'}
},

[IBS_ItemID.LOL]={
	name="Lord of The Locusts",
	info="Clearing a room spawns a random locust (not Abyss's one)"..
		 "#Dealing 50 damage has 50% chance to spawn one"..
		 "#Grants immunity to damage from{{Trinket113}}Locust of War"
},

[IBS_ItemID.Falowerse]={
	name="Falowerse",
	info="Holding "..EID.ButtonToIconMap[ButtonAction.ACTION_DROP].." drop key and touching pickups decomposes them into{{IBSMemory}}memories"..
		 "#Consuming 21{{IBSMemory}}memories spawns 3 falsehoods, but only one can be picked up"..
		 "#When Isaac is dead, revive and transform Isaac's character into {{Player"..(IBS_PlayerID.BXXX).."}}Benighted ???, and remove this item",
	virtue="No wisps",
	belial="No effect",
	player={[IBS_PlayerID.BXXX] = 'Increase the maximum of orbs to 6, and remove this item'}
},

[IBS_ItemID.FalsehoodOfXXX]={
	name="Falsehood of ???",
	info="Spawn a falsehood",
	trans={"GUPPY","LORD_OF_THE_FLIES","MUSHROOM","ANGEL","BOB","SPUN","MOM","CONJOINED","LEVIATHAN","POOP","BOOKWORM","SPIDERBABY"}
},

[IBS_ItemID.GoldExperience]={
	name="Gold Experience",
	info="+ 1{{BrokenHeart}}Broken Heart"..
		 "#Provides Coin Heart Containers that equals in number to{{BrokenHeart}}broken hearts"..
		 " (Similar to{{Player14}}Keeper's, but can only be healed by picking{{Coin}}coins up)"..
		 "#!!! {{ColorYellow}}Can not prevent Isaac from death{{CR}}",
	player={
		[PlayerType.PLAYER_KEEPER] = "Instead, melts{{Trinket156}}Mother's Kiss",
		[PlayerType.PLAYER_KEEPER_B] = "Instead, melts{{Trinket156}}Mother's Kiss"
	}		 
},


[IBS_ItemID.ChubbyCookbook]={
	name="Chubby Cookbook",
	info="Spawns a friendly mascot, one more for each use"..
		 "#Resets at 6th time",
	virtue="Equal numbers of outer wisps that don't fire tears",
	belial="Equal numbers of {{Collectible433}}My Shadow mascots"
},

[IBS_ItemID.ProfaneWeapon]={
	name="Profane Weapon",
	info="1.5x dmg that ignores armor to non-boss enemies"
},

[IBS_ItemID.RulesBook]={
	name="Rules Book",
	info="A random effect:"..
		 "#{{Blank}} spawns a {{Coin}}coin"..
		 "#{{Blank}} spawns a {{Bomb}}bomb"..
		 "#{{Blank}} spawns a paper trinket"..
		 "#{{Blank}} spawns a health-priced shop collectible"..
		 "#{{Blank}} spawns {{Card47}}Get Out Of Jail Free Card"..
		 "#{{Blank}} {{AngelRoom}}Angel chance + 15%"..
		 "#{{Blank}} Gains {{Collectible76}}X-Ray Vision effect"..
		 "#{{Blank}} Game timer decreases by 10 minutes",
	virtue="No special effect",
	belial="No special effect"
},

[IBS_ItemID.CathedralWindow]={
	name="Cathedral Window",
	info="+ 3{{SoulHeart}}Soul Hearts"..
		 "#↑ + 0.7{{Tears}}tears"..
		 "#{{Shop}} Shop: Cards50% to become {{Card51}}Holy Card"..
		 "#{{TreasureRoom}} Treasure: An extra beggar"..
		 "#{{SecretRoom}} Secret: Keeper becomes angel statue"..
		 "#{{ArcadeRoom}} Arcade: A gambling game 50% to become Confessional"..
		 "#{{CurseRoom}} Curse: A red chest 50% to become eternal chest"..
		 "#{{DevilRoom}} Devil: Free collectibles, but only one can be taken"
},

[IBS_ItemID.LeadenHeart]={
	name="Leaden Heart",
	info="+ 1 {{BrokenHeart}}Broken Heart"..
		"#↓ - 0.15 {{Speed}}spd"..
		"#+ 28 temporary {{IBSIronHeart}}Iron Hearts"..
		"#When entering a new level, + 28 temporary {{IBSIronHeart}}Iron Hearts",
	player={[IBS_PlayerID.BMaggy]="+7{{IBSIronHeart}} Iron Heart Limit"}
},

[IBS_ItemID.China]={
	name="China",
	info="When gaining hearts, + 1 temporary {{IBSIronHeart}}Iron Heart",
	player={[IBS_PlayerID.BMaggy]="Extra{{IBSIronHeart}} Iron Hearts instead"}
},

[IBS_ItemID.SilverBracelet]={
	name="Silver Bracelet",
	info="Enemies around get confusion, fear or petrified"..
		 "#Gambling games explode"..
		 "#{{ArcadeRoom}} All slots or beggars in Arcade Room explode",
	virtue="Middle wisps that do not shoot and only exist in one room but trigger this item when killed",
	belial="Burn"
},

[IBS_ItemID.ROH]={
	name="Route of Humility",
	info="When gaining a collectible, a random stat + 2.5% x (4 - quality)"
},

[IBS_ItemID.Tenebrosity]={
	name="Tenebrosity",
	info="When gaining hearts, 22% chance to trigger {{Collectible35}}The Necronomicon ({{Luck}} Luck13: 100%)",
	seijaBuff={
		desc = "↑ + %s dmg when triggered",
		data = {
			args = function(x) return 0.5*x end
		}
	}
},

[IBS_ItemID.HellKitchen]={
	name="Hell Kitchen",
	info='+ 2 {{BlackHeart}}Black Hearts'..
		 "#{{DevilRoom}} An extra item with spikes appears in Devil Room (independent pool)"
},

[IBS_ItemID.StolenDecade]={
	name="Stolen Decade",
	info="Discharge 1"..
		 "#In priority:"..
		 "#A priced pickup exists: Removes the price"..
		 "#Optional pickups exist: No options"..
		 "#In starting room: Dagaz, Ansuz, and {{Collectible76}}X-Ray"..
		 "#Else: - 1 {{BrokenHeart}}Broken Heart, and triggers {{Card51}}Holy Card",
	virtue="Outer wisps that don't fire tears",
	belial="+ 1 {{BlackHeart}}Black Heart",
	void="No Effect"
},

[IBS_ItemID.DiceProjector]={
	name="Dice Projector",
	info="When entering a new room, depending on items in the room, spawns equal numbers of items with equal price for 3 seconds",
},

[IBS_ItemID.Hoarding]={
	name="Hoarding",
	info='↑ {{Luck}}luck + 1'..
		 "#Some transformation components provide extra effects",
},

[IBS_ItemID.SuperPanicButton]={
	name="Super Panic Button",
	info="Every level, the active form will be spawned in the starting room:"..
		 "#Disappear when changing rooms"..
		 "#!!! {{ColorYellow}}SINGLE USE{{CR}}"..
		 "#Remove the passive form"..
		 "#Invincibility next 75 seconds"..
		 "#+ 1 {{BoneHeart}}Bone Heart"..
		 "#Heal 3 {{Heart}}Red Heart"..
		 "#Hearts can't be picked up this level",
	greed="Disappear when waves start",	
	virtue="6 inner wisps with high Hp",
	belial="↑{{Damage}}DMG + 2",
	void="No effect"
},

[IBS_ItemID.SuperPanicButton_Active]={
	name="Super Panic Button (Active)",
	info="Disappear when changing rooms"..
		 "#!!! {{ColorYellow}}SINGLE USE{{CR}}"..
		 "#Remove the passive form"..
		 "#Invincibility next 75 seconds"..
		 "#+ 1 {{BoneHeart}}Bone Heart"..
		 "#Heal 3 {{Heart}}Red Heart"..
		 "#Hearts can't be picked up this level",
	greed="Disappear when waves start",	 	 
	virtue="6 inner wisps with high Hp",
	belial="↑{{Damage}}DMG + 2",
	void="No effect"
},

[IBS_ItemID.Blackjack]={
	name="Blackjack",
	info='When a room is cleaned, 10% chance to spawn a common tarot card'..
		 "#When consuming a tarot card, increase the counts by the corresponding number; For the reverse one, decrease"..
		 "#!!! {{ColorYellow}}Any number more than 10 counts as 10{{CR}}"..
		 "#If the counts was less than 0 or more than 21, gain a card whose ID is the absolute value, and then reset"..
		 "#If the counts was 21, spawn {{Collectible624}}Booster Pack, and then reset",
},

[IBS_ItemID.Sketch]={
	name="Sketch",
	info="Discharge 4"..
		 "#In order of priority, record a tag of the nearest item: "..
		 "Dead, Syringe, Mom, Tech, Battery, Guppy, Fly, "..
		 "Bob, Mushroom, Baby, Angel, Devil, Poop, Book, Spider, "..
		 "Food, Offensive, Stars"..
		 '#No corresponding tags or duplicated tags is recorded as "None"'..
		 "#After recording two tags, two more uses can spawn a passive item with the tags"..
		 "#!!! Affect item pools",
	virtue="No wisps#At least {{Quality2}}quality 2",
	belial="Replaces the item with{{Collectible51}} if no corresponding item",
	void="No effect",
	seijaNerf="75% not to draw",	
},

[IBS_ItemID.Molekale]={
	name="Molekale",
	info="The effect is determined by the last gained item's quality except it self:"..
		 '#{{Quality0}} 0 and below: A {{Bomb}}bomb and a key {{Key}} for any new item gained'..
		 '#{{Quality1}} 1: 6 killed enemies spawn a {{Coin}}coin; 3 picked coins heal half a heart{{HalfHeart}}'..
		 '#{{Quality2}} 2: When hurt or entering a new {{BossRoom}}Boss Room, spawn a Blood Baby'..
		 '#{{Quality3}} 3: When changing rooms, become invincible for 5 seconds'..
		 '#{{Quality4}} 4 and above: Enemies around get {{BrimstoneCurse}}Brimstone Mark; Attacking is accompanied with homing brimestone',
},

[IBS_ItemID.Ssstew]={
	name="Ssstew",
	info="When gained, {{EmptyHeart}}Heart Containers become {{BoneHeart}}Bone Hearts, {{SoulHeart}} Soul Hearts become {{BlackHeart}}Black Heart"..
		 '#The No.(6 - {{BlackHeart}}) tear gets + 2 damage and becomes slowing, poisonous and piercing'..
		 '#{{SoulHeart}} Soul Heart touched will become {{BlackHeart}}Black Heart',
	trans={'LEVIATHAN'}
},

[IBS_ItemID.BookOfSeen]={
	name="Book of Seen",
	info="An extra book item will appear in {{TreasureRoom}}Treasure Room"..
		 "#When used, record active book items in the current room, and then trigger the recorded ones"..
		 "#All{{Collectible"..(IBS_ItemID.BookOfSeen).."}}".."share the same record",
	virtue="Corresponding wisps",
	belial="No special effect",
	trans={'BOOKWORM'}
},

[IBS_ItemID.PortableFarm]={
	name="PortableFarm",
	info='Gulp {{Trinket'..(IBS_TrinketID.WheatSeeds)..'}}'..'Wheat Seeds',
	virtue='Middle wisps that do not shoot tears and spawn {{Trinket'..(IBS_TrinketID.WheatSeeds)..'}}'..'Wheat Seeds when killed',
	belial='No special effect',
},

[IBS_ItemID.Wheat]={
	name='Wheat',
	info='↑ {{Speed}}spd + 0.2'..
		 '#3 ones to {{Collectible'..(IBS_ItemID.Bread)..'}}Bread, its effect:'..
		 '#Heal 3{{Heart}}Red Hearts'..
		 '#+ 1{{SoulHeart}}Soul Heart'..
		 '#↓ {{Speed}}spd - 0.02'..
		 '#↑ {{Damage}}dmg + 0.3'..
		 '#↑ {{Luck}}luck + 0.5'..
		 '#↓ {{Shotspeed}}sspd - 0.03'		 
},
[IBS_ItemID.Bread]={
	name='Bread',
	info='Heal 3{{Heart}}Red Hearts'..
		 '#+ 1{{SoulHeart}}Soul Heart'..
		 '#↓ {{Speed}}spd - 0.02'..
		 '#↑ {{Damage}}dmg + 0.3'..
		 '#↑ {{Luck}}luck + 0.5'..
		 '#↓ {{Shotspeed}}sspd - 0.03'
},

[IBS_ItemID.Goatify]={
	name='Goatify',
	info='Goats became friendly, gain fire, spikes and explosion immunity and will not be hurt in a cleared room'..
		 '#When hurt, transform the non-boss attacker to a Goat'..
		 "#When used, spawn a Goat with double Hp, and then consume 1 {{Collectible'..(IBS_ItemID.Wheat)..'}}Wheat from anyone to full Goats' Hp",
	virtue='Middle wisps that do not shoot tears and spawn a Goat when killed',
	belial='No special effect',
},

[IBS_ItemID.ElegiastWinter]={
	name='Elegiast Winter',
	info='Spawn {{Card10}}The Hermit'..
		 '#When the room is cleared, 10% chance to spawn {{Card10}}The Hermit'..
		 '#Using {{Card10}}The Hermit for the first time in a level teleports to a special Shop in which only one item can be bought'
},

[IBS_ItemID.GHD]={
	name='GHD',
	info='{{Bomb}} Bombs + 2'..
		 '#Spawn {{Card72}}Tower?'..
		 '#Some obstacles will spawn extra pickups when destroyed '..
		 '#Highlight Tinted Rock and Dungeon Rock'
},

[IBS_ItemID.Grail]={
	name='Grail',
	info='+ 1 {{EmptyHeart}} Empty Container'..
		 '#Spawn {{Card16}}Devil'..
		 '#After using {{Card16}}Devil, + 0.15{{Damage}} dmg, and enemies will drop temporary hearts when killed in the current room'..
		 '#When a room is cleared, 5% change to spawn {{Card16}}Devil, + 5% chance for each different kind of hearts',
	greed='Half chance'
},

[IBS_ItemID.Moth]={
	name='Moth',
	info='#Spawn {{Card1}}The Fool'..
		 '#When another tarot is used, spawn {{Card1}}The Fool'..
		 '#Every level, change the effect of {{Card1}}The Fool by used times:'..
		 '#{{Blank}} 2: Teleport to {{SecretRoom}}Secret'..
		 '#{{Blank}} 3: Teleport to {{SuperSecretRoom}}Super Secret'..
		 '#{{Blank}} 4: Teleport to {{UltraSecretRoom}}Ultra Secret'..
		 '#{{Blank}} 5 or above: Rerolls pedestal items in the current room',
},

[IBS_ItemID.Edge]={
	name='Edge',
	info='#Spawn {{Collectible'..(IBS_ItemID.Edge2)..'}}Colonel Edge and {{Collectible'..(IBS_ItemID.Edge3)..'}}Lionsmith Edge'..
		 '#!!! Only one can be picked up',
},

[IBS_ItemID.Edge2]={
	name='Colonel Edge',
	info='Spawn {{Card8}}Chariot'..
		 '#↑ + 0.5 {{Tears}}tears'..
		 '#When entering a new level, spawn {{Card8}}Chariot, and + 1 {{BrokenHeart}}Broken Heart until 4'..
		 '#Explosion and collision immunity'..
		 '#Keep firing two tears when attacking and moving, which deal 33%{{Damage}}dmg of Isaac;'..
		 'When hurt or using {{Card8}}Chariot, those tears get 2x dmg and homing effect for a while',
	seijaNerf='Rush!'
},

[IBS_ItemID.Edge3]={
	name='Lionsmith Edge',
	info='Spawn {{Card12}}Strength'..
		 '#↑ + 8 {{Damage}}dmg'..
		 '#When entering a new level, spawn {{Card12}}Strength'..
		 '#When using {{Card12}}Strength, get a {{SoulHeart}}Soul Heart and 8% {{Damage}}dmg up, and clear 1 {{BrokenHeart}}Broken Heart',
	seijaNerf='The {{Damage}}dmg up decreases to 0.8; When using {{Card12}}Strength, lose 2.5% {{Tears}}tears until zero'
},

[IBS_ItemID.Forge]={
	name='Forge',
	info='#When gained, spawn {{Card21}}Judgement'..
		 '#When using {{Card21}}Judgement, trinkets held become golden and smelt it'..
		 '#Machines have 60% chance to spawn {{Card21}}Judgement when destroyed, or spawn a {{Bomb}}Bomb'..
		 '#Beggars have 60% chance to spawn a machine when destroyed, or spawn a {{Bomb}}Bomb',
},

[IBS_ItemID.SecretHistories]={
	name='Secret Histories',
	info='#When gained, spawn {{Card18}}The Stars'..
		 '#When entering a new level, spawn {{Card18}}The Stars'..
		 '#{{Card18}}The Stars consumed can not teleport, instead gain an item-wisp randomly with a corresponding card:'..
		 '#{{Card1}} '..'{{Collectible'..(IBS_ItemID.Moth)..'}}Moth'..
		 '#{{Card6}} '..'{{Collectible'..(IBS_ItemID.Knock)..'}}Knock'..
		 '#{{Card8}} '..'{{Collectible'..(IBS_ItemID.Edge2)..'}}Colonel Edge'..
		 '#{{Card12}} '..'{{Collectible'..(IBS_ItemID.Edge3)..'}}Lionsmith Edge'..
		 '#{{Card16}} '..'{{Collectible'..(IBS_ItemID.Grail)..'}}Grail'..
		 '#{{Card21}} '..'{{Collectible'..(IBS_ItemID.Forge)..'}}Forge',
	greed='Skip non-Greed ones',
	player={
		[PlayerType.PLAYER_KEEPER]='Skip non-Keeper ones',
		[PlayerType.PLAYER_KEEPER_B]='Skip non-Keeper ones',
	}		 
},

[IBS_ItemID.AnotherKarma]={
	name='Another Karma',
	info='Transform the coin-priced or free closest item (including items that are being held) into a random beggar and 3~5 {{Coin}}coins, with 50% chance to spawn a penny trinket'..
		 '#!!! Won\'t spawn beggars if there were 7 machines / beggars or more',
	virtue='#3 middle wisps that have a chance to spawn coins when killed',
	belial='#The beggar must be devil beggar',
	void='No effect',
	player={[IBS_PlayerID.BKeeper]='If there\'s not any item, select a penny trinket to be consumed instead; If that is a golden one, triggers double effect'}
},

[IBS_ItemID.Alms]={
	name='Alms',
	info='When gained, + 3 {{Coin}}coins, and spawn a {{Card21}}Judgement'..
		 '#Items form beggar pools become free with an extra option in cycle',
},

[IBS_ItemID.NotchedSword]={
	name='Notched Sword',
	info='↑ {{Damage}}dmg + 1'..
		 '#Ignore armor'..
		 '#When a room is cleared, 33.3% chance to open doors, including some special doors'..
		 '#Valid even Isaac loses this item',
	seijaNerf='+ 3 {{BrokenHeart}}Broken Hearts; Enemies have 50% chance to ignore any damage'
},

[IBS_ItemID.Troposphere]={
	name='Troposphere',
	info='In a new room, 33% chance to gain an extra vanilla active item (Similar to {{Trinket154}}Dice Bag)'..
		 '#!!! When hurt, 33% chance to swap the first active item with the extra item, and lose Troposphere'..
		 '#Only available to few vanilla items',
},

[IBS_ItemID.MODE]={
	name='Model of Deligence',
	info='+ 1{{Luck}}luck'..
		 'Spawn red wheat continually in any uncleared room'..
		 '#↑ For every 4 red wheat picked, spawn a heart wisp, and gain 0.15{{Speed}}spd and 0.25{{Tears}} tears in the current room',
},

[IBS_ItemID.LODI]={
	name='Lamp of Diligence',
	info='Fill pits'..
		 '#Spawn a lamp in any uncleared room:'..
		 '#When touched, becomes lit for 7 seconds'..
		 '#When lit for 3.5 seconds, spawn a wisp that runs after enemies'..
		 '#When lit, 50% tears crossing get + 1 damage, homing and {{Collectible533}}Trisagion effect',
},

[IBS_ItemID.ContactC]={
	name='Contact C',
	info='When directly picking up an item, record the item pool of the current room'..
		 '#Next pedestal item will be rerolled into one in the recorded pool'..
		 '#No effect on error or quest items',
},

[IBS_ItemID.MaxxC]={
	name='Maxx C',
	info='Discharge 1'..
		 '#For every enemy newly appears in the current room, gain a random item-wisp whose quality is not below {{Quality2}}2',
	virtue='No wisps#Increase HP of the item-wisps',
	belial='Item-wisps come from devil pool',
	void='No effect',
},

[IBS_ItemID.Multiply]={
	name='Multiply',
	info='Discharge 1'..
		 '#Charged by clearing {{BossRoom}}Boss Room'..
		 '#Destroy non-boss enemies, and spawn equal friendly Dark Balls'..
		 '#When held, enemies damaged by Dark Balls will spawn friendly Dark Balls when killed until 13',
	virtue='4 middle wisps that spawn a friendly Dark Ball when killed',
	belial='When used, 6 at least Dark Balls will be spawn',
	void='After absorbed, only the effect on held is valid'
},

[IBS_ItemID.SCP018]={
	name='018',
	info='When held, gain a ball familiar:'..
		 '#{{Blank}} Blocks projectiles'..
		 '#{{Blank}} Double speed after colliding with obstacles'..
		 '#{{Blank}} Damage is related to speed and scale'..
		 '#{{Blank}} Hitting enemies boosts charges'..
		 '#{{Blank}} Reset speed and scale next room'..
		 '#When used, increases the ball\'s scale and speed in the current room',
	virtue='The ball\'s hitting spawns an outer wisp in 4 seconds',
	belial='The ball\'s hitting spawns a flame in 5 seconds',
	void='After absorbed, the ball can still exist',
},

[IBS_ItemID.SneakyC]={
	name='Sneaky C',
	info='Spawn {{Trinket113}}Locust of War trinket'..
		 '#Auto-smelt {{Trinket113}}Locust of War trinket'..
		 '#Double-tapping '..EID.ButtonToIconMap[ButtonAction.ACTION_DROP]..' drop key drops all smelted {{Trinket113}}Locust of War trinkets'..
		 '#In an uncleared room, every 4 seconds, {{Trinket113}}Locust of War trinket spawns a Locust of War entity'..
		 '#In the current room, for every enemy newly appears, 25% chance to spawn a Locust of War entity',
},

[IBS_ItemID.ConfrontingC]={
	name='Confronting C',
	info='In the current room, for every enemy newly appears, spawn 2 locusts (not Abyss\'s one)'..
		 '#Blue flies and locusts can block projectiles',
},

[IBS_ItemID.RetaliatingC]={
	name='Retaliating C',
	info='Gain a fly item-wisp'..
		 '#When a item below {{Quality2}}Q2 appears, remove an item with the same quality from pools, and gain a fly item-wisp'..
		 '#No effect on error items',
},

[IBS_ItemID.MasterRound]={
	name='Master Round',
	info='{{Heart}} + 1 health up, full health'..
		 '#Secret Exit keeps open'..
		 '#Clearing {{BossRoom}}Boss Room without hurt by penal damage spawns another {{Collectible'..(IBS_ItemID.MasterRound)..'}}Master Round'..
		 '#Changing rooms will reset the hurt record',
},

[IBS_ItemID.MasterPack]={
	name='Master Pack',
	info='Spawn 4 cards, excluding tarot, reverse tarot，{{Card44}}Rules Card and {{Card46}}Suicide King'..
		 '#{{Shop}} One of cards in Shop will be replaced by this item',
},

[IBS_ItemID.RichMines]={
	name='Rich Mines',
	info='Spawn all mineral wisps'..
		 '#When a rock is destroyed, 25% chance to spawn a mineral wisp'..
		 '#Some rocks will spawn extra wisps when destroyed'..
		 '#9 same mineral wisps = 1 corresponding item-wisp'..
		 '({{Collectible132}}{{Collectible201}}{{Collectible202}}{{Collectible68}}'..
		 '{{Collectible'..(IBS_ItemID.Diamoond)..'}})',
},

[IBS_ItemID.Panacea]={
	name='Panacea',
	info='!!! {{ColorYellow}}SINGLE USE{{CR}}'..
		 '#{{Heart}} Full health'..
		 '#Removes all {{BrokenHeart}}Broken Hearts'..
		 '#Stats won\'t be below the standard'..
		 '#Remove all disease items from pools'..
		 '#Remove all disease items from Isaac, and spawn equal numbers of items from {{TreasureRoom}}Treasure Pool',
	virtue='No wisps#{{AngelRoom}}Angel Pool instead',
	belial='{{DevilRoom}}Devil Pool instead',
},

[IBS_ItemID.SmileWorld]={
	name='Smile World',
	info='Enemies take extra (0.1 x total items) damage',
},

[IBS_ItemID.FGHD]={
	name='False GHD',
	info='{{Bomb}} Bombs + 2'..
		 '#Spawn {{Card17}}Tower'..
		 '#When entering a new room, destroy all common rocks, and spawn Spiked Rocks or Bomb Rocks instead'..
		 '#↑ When destroying an obstacle, gain 0.02 {{Damage}}dmg this level, with 3% chance to spawn a Tinted Rock Spider'
},

[IBS_ItemID.SOG]={
	name='Soul of Generosity',
	info='+ 2 {{SoulHeart}}Soul Hearts'..
		 '#Beggars tend to appear in some special rooms'..
		 '#Beggars have 42% chance to return the resources'..
		 '#For every 14 donations to beggars, trigger {{Card51}}Holy Card, and remove a {{BrokenHeart}}Broken Heart'..
		 '#And if no {{BrokenHeart}}Broken Heart, + 0.5 {{Luck}}luck'
},

[IBS_ItemID.Clash]={
	name='Clash',
	info='↑ + 0.3 {{Damage}} dmg for every offensive item'..
		 '#↓ - 1 {{Damage}} dmg from this item for every non-offensive item'..
		 '#Only count items that Isaac truely holds'
},

[IBS_ItemID.TheBestWeapon]={
	name='The Best Weapon',
	info='+ 5 {{Damage}}dmg'..
		 '#Enemies take 4 less damage',
	seijaBuff={
		desc = 'Enemies take %s more damage',
		data = {
			args = function(x) return 4*x end		
		}
	},
},

[IBS_ItemID.ThreeWishes]={
	name='Three Wishes',
	info='Spawn 3 pickups as the circumstances may require',
	virtue="3 middle wisps that fire homing tears",
	belial="Pickups may include health-priced items when not in {{DevilRoom}} Devil Room"
},

[IBS_ItemID.ChestChest]={
	name='Chest Chest',
	info='Absorb all non-empty chests in the current room'..
		 '#2x new chests will be spawned next level or next run',
	virtue="A common wisp for every absorbed chest",
	belial="Common Chest spawned may become Red Chest",
	void='No effect',
	player={[IBS_PlayerID.BLost]='Instead, hold to do: transform chests into weapons/armors/floats or repair them'},
},

[IBS_ItemID.CheeseCutter]={
	name='Cheese Cutter',
	info='Bosses have 10% chance to take 18 extra damage ({{Luck}}Luck 45: 50%)'..
		 '#Clearing {{BossRoom}}Boss Room spawns a half-coin-priced item (independent pool)',
},

[IBS_ItemID.Turbo]={
	name='Turbo',
	info='When gained, full charge till the extra charge bar for active items'..
		 '#Next pedestal item will be replaced by another {{Collectible'..(IBS_ItemID.Turbo)..'}}Turbo, and then remove all {{Collectible'..(IBS_ItemID.Turbo)..'}}Turbo from Isaac'..
		 '#No effect on error or quest items',
	seijaBuff={
		desc = 'Instead, do not replace, but spawn {{Collectible'..(IBS_ItemID.Turbo)..'}}Turbo',
		data = {
			append = function(x) 
				return (x > 1 and "#Spawn "..(x-1).." battery at the same time"..(x>2 and 's' or '')) or ''
			end	
		}
	},
},

[IBS_ItemID.TreasureKey]={
	name='Treasure Key',
	info='Teleport to a temporary {{ChestRoom}}Chest Room'..
		 '#Gain {{GoldenKey}}Golden Key',
	virtue="Inner wisps that do not shoot tears#Spawn a chest when killed",
	belial="Instead, teleport to {{CurseRoom}}Curse Room",
	void="Do not teleport",
	greed="Instead, teleport to Error Room",
},

[IBS_ItemID.AKEY47]={
	name='AKEY-47',
	info='Gain a gun:'..
		 '#Fire key tears with 50% Isaac\'s damage'..
		 '#Fire speed is the double of Isaac'..
		 '#Has the same tear effects of Isaac',
	seijaNerf='Can not attack without {{Key}}keys; 5% chance to lose a {{Key}}key every attack',
},

[IBS_ItemID.SilverKey]={
	name='The Silver Key',
	info="Charged by cleaning rooms, and can be fully charged twice"..
		 '#Record the current room (only a few can be recorded) and game timer'..
		 '#If recorded, try reset the closest room into recorded one, make game timer become recorded one, and reset the record'..
		 '#!!! In a new level, all rooms with the last-recorded type will be rerolled into normal rooms'..
		 '#All {{Collectible'..(IBS_ItemID.SilverKey)..'}}'..'The Silver Key share the same record',
	virtue='No wisps#Can record {{AngelRoom}}Angel Room',
	belial='Can record {{DevilRoom}}Devil Room',
	void='No effect',
	greed='No effect',
},

[IBS_ItemID.TruthChest]={
	name='Truth Chest',
	info='↑ {{Range}}range + 1.5'..
		 '#↑ {{Luck}}luck + 3'..
		 '#Brother Albern must be in {{SuperSecretRoom}}Super Secret Room'..
		 '#Brother Albern can be woke up at any touch',
},

[IBS_ItemID.Knock]={
	name='Knock',
	info='When gained, spawn {{Card6}}The Hierophant'..
		 '#30% chance to spawn {{Card6}}The Hierophant for hurt every 5 times'..
		 '#When using {{Card6}}The Hierophant, try to open red special rooms, and gain a {{BrokenHeart}}Broken Heart for every special room opened'..
		 '#When entering {{UltraSecretRoom}}Ultra Secret Room, remove 5 {{BrokenHeart}}Broken Heart',
},

[IBS_ItemID.WilderingMirror]={
	name='Wildering Mirror',
	info='When entering a new level, generate red rooms around special rooms excepting {{BossRoom}}Boss Room and {{UltraSecretRoom}}Ultra Secret Room, and then reveal all red rooms'..
		 '#Damage with penalty has 30% chance to remove this item, get {{CurseLost}}Curse of the Lost, and spawn {{Collectible'..(IBS_ItemID.WilderingMirror2)..'}} Broken Wildering Mirror',
},

[IBS_ItemID.WilderingMirror2]={
	name='Broken Wildering Mirror',
	info='!!! {{ColorYellow}}SINGLE USE{{CR}}'..
		 '#Cost 10 {{Coins}}coins to remove {{CurseLost}}Curse of the Lost and gain {{Collectible'..(IBS_ItemID.WilderingMirror)..'}}Wildering Mirror',
	virtue='No wisps',
	belial='No effect',
},

[IBS_ItemID.MoonStreets]={
	name='Moon Streets',
	info='When entering a normal room (not the starting room), teleport to a random special room'..
		 '#Can not teleport to {{UltraSecretRoom}}Ultra Secret Room'..
		 '#Grants {{CurseRoom}}Curse Room door immunity',
},

[IBS_ItemID.Fomalhaut]={
	name='Fomalhaut',
	info='Grants fire and explosion immunity'..
		 '#When an enemy is hurt for the first time, spawn a blue flame lasting for 18 seconds',
},

[IBS_ItemID.LuckEnchantment]={
	name='Luck Enchantment',
	info='↑ {{Luck}}luck + 3'..
		 '#Enemies take extra 20% x {{Luck}}luck damage (absolute value)'
},

[IBS_ItemID.TheHornedAxe]={
	name='The Horned-Axe',
	info='↑ {{Damage}}dmg + 1.3'..
		'#Every 13 seconds, if any enemy exist in the current room, trigger {{Card14}}Death and {{Card69}}Death?'
},

[IBS_ItemID.LightBarrier]={
	name='Light Barrier',
	info='When gained, spawn a common tarot and a reversed tarot'..
		'#When a room is cleared, reverse tarot cards on Isaac'..
		'#When entering a new level, spawn a tarot card; If the one is reversed tarot, disable this item for the current level'
},

[IBS_ItemID.ChillMind]={
	name='Chill Mind',
	info='↓ {{Shotspeed}}sspd x 89%'..
		 '#{{Shop}} Spawn coin-priced two shop items and {{Collectible76}}X-Ray Vision in Shop'..
		 '#!!! {{Shop}}Can not buy items if {{Collectible76}}X-Ray Vision exists in Shop'
},

[IBS_ItemID.LownTea]={
	name='Lown Tea',
	info='+ 1 {{Heart}}Heart Container'..
		 '#Heal 1 {{Heart}}Red Heart',
	eater='↑ + 0.5 {{Damage}}dmg'..
		  '#↓ - 0.03 {{Speed}}spd'..
		  '#Spawn a blue fly per second when the number of blue flies is below 4x this item'
},

[IBS_ItemID.TheEyeofTruth]={
	name='The Eye of Truth',
	info='+ 1 {{SoulHeart}}Soul Heart'..
		 '#↑ + 2 {{Range}}rng'..
		 '#Show Ids of enemies and pickups'
},

[IBS_ItemID.Turbine]={
	name='Turbine',
	info='Trigger effects according to machines:'..
		 '#{{Slotmachine}}Slot: Spawn 2 pickups'..
		 '#{{BloodDonationMachine}} Blood Donation: Spawn 2 hearts'..
		 '#{{FortuneTeller}} Fortune: Spawn {{SoulHeart}}Soul Heart or a trinket'..
		 '#{{RestockMachine}} Restock：Reroll items or restock'..
		 '#{{CraneGame}} Crane: Destroy it, and spawn the shown item'..
		 '#Else: Gain {{Card11}}Wheel of Fortune',
	virtue='Inner wisps that fire {{Collectible494}} laser tears',
	belial='No special effect',
},

[IBS_ItemID.RedHook]={
	name='Red Hook',
	info='+ 0.3 {{Damage}}dmg'..
		 '#Get {{CurseDarkness}}Curse of Darkness at a new level without other curses'..
		 '#With {{CurseDarkness}}Curse of Darkness:'..
		 '#{{Blank}} Enemies have (16 + 8 x levels)% chance to take double damage'..
		 '#!!! Isaac has half the chance to take double penalt damage',
},

[IBS_ItemID.OvO]={
	name='OvO',
	info='↑ + 0.3 {{Speed}}spd'..
		 '#Attack and petrifies a enemy close with 66.6% Isaac\'s dmg until 20 times'..
		 '#Reset the times when changing rooms',
	greed='Reset the times when changing waves'
},

[IBS_ItemID.DanishGambit]={
	name='Danish Gambit',
	info='Can be used without full charge'..
		 '#When used without full charge, absorb trinkets and {{Quality1}}Q-1-or-below items to charge itself (including those being held)'..
		 '#Can be fully charged twice'..
		 '#When used with full charge, reroll {{Quality3}}Q-3-or-below items into quality + 1 random items, but not higher than 3',
	virtue='No wisps#{{AngelRoom}}Angel pool',
	belial='{{DevilRoom}}Devil pool',
	void='No effect',
},

[IBS_ItemID.HyperBlock]={
	name='Hyper Block',
	info='Gain 3-second sheild, and a soul or falsehood'..
		 '#Before taking damage, charge 1~3 meters; If the damage is penalt and the charge is full, automatically trigger this item'..
		 '#3 times limit; Recover 1 when clearing {{BossRoom}}Boss Room'..
		 '#!!! {{ColorYellow}}Remove when exhausted{{CR}}',
	virtue='No wisps#Before taking damage, charge 1 meter more',
	belial='No special effect',
	void='No use times limit',
},

[IBS_ItemID.FusionHammer]={
	name='Fusion Hammer',
	info='↑ + 0.75 {{Damage}}dmg'..
		 '#When gained, smelt the current trinkets and make them golden'..
		 '#All trinket pickups become golden'..
		 '#!!! Can not replace or drop trinkets',
},

[IBS_ItemID.SangenSummoning]={
	name='Sangen Summoning',
	info='↑ + 0.5 {{Damage}}dmg'..
		 '#Ignore any penalt damage in a cleared room'..
		 '#After removed from Isaac, Isaac gets double {{damage}}dmg'
},

[IBS_ItemID.PeacePipe]={
	name='Peace Pipe',
	info='+ 3 counts when a room is cleared (6 for big rooms)'..
		 'Costing 1 count, select an item to remove from pools, and decrease game timer by 5 seconds'..
		 '#!!! Also from Isaac, but return (quality^2 + 1) counts',
	virtue='No wisps#↑ + 0.005 {{Tears}}tears',
	belial='↑ + 0.01 {{Damage}}dmg',
	void='No effect'
},

[IBS_ItemID.Yongle]={
	name='Yongle',
	info='Trigger some of book active items, whose sum of charges is at least 20'..
		 '#The sequence is fixed in every run',
	virtue="Corresponding wisps",
	belial="No special effect",
},

[IBS_ItemID.HexaVessel]={
	name='Hexa Vessel',
	info='When attacking, spawn a special wisp every 1.2 seconds up to 6'..
		 '#If stop attacking, kill the wisps and fire flames'
},

[IBS_ItemID.Flex]={
	name='Flex',
	info='↑ + 2.5 {{Damage}}dmg'..
		 '#When a room is cleared, remove or resume 2 dmg up'
},

[IBS_ItemID.SignatureMove]={
	name='Signature Move',
	info='↑ + (30 / offensive - nonOffensive items) {{Damage}}dmg'..
		 '#Only count items that Isaac truely holds'..
		 '#Offensive items will be with a non-offensive option in cycle',
	seijaNerf='Offensive items will be replaced instead'
},

[IBS_ItemID.DoubleDosage]={
	name='Double Dosage',
	info='#Duplicate other passive syringe items, including items gained after'..
		 '#!!! After picking up a syringe item, if Isaac has over 11 syringe items, dies',
},

[IBS_ItemID.HolyInjection]={
	name='Holy Injection',
	info='#↑ + 2 {{Luck}}luck'..
		 '#When a room is cleared, 3% chance to remove a {{BrokenHeart}}Broken Heart, and gain a {{HalfSoulHeart}}Half Soul Heart'..
		 '#+ 1% chance for each {{Spun}}syringe or {{Seraphim}}angel item',
},

[IBS_ItemID.KilleR]={
	name='Kille R',
	info='↑ + 0.16 {{Damage}}dmg'..
		 '#Holding restart key providing {{Damage}}damage multiplier up to 230%, decreasing if release'..
		 '#Grants homing tears when the multiplier reaches 130%',
},

[IBS_ItemID.VeinMiner]={
	name='Vein Miner',
	info='#{{Bomb}} Bombs + 5'..
		 '#When a rock, poop, or fire place is destroyed, destroy the same type in the current room',		 
},

[IBS_ItemID.VainMiner]={
	name='Vain Miner',
	info='#The first empty pedestal from picked items will be rerolled into non-quest items with neighbor id'..
		 '#10.9% chance to fail; Also fails if no corresponding id'..
		 '#Failed pedestals will become error items',
},

[IBS_ItemID.PUC]={
	name='PUC',
	info='#35% chance to add an item from {{IBSMOD}}IBS into cycle for a pedestal item'..
		 '#Anyone with {{Collectible'..(IBS_ItemID.Goatify)..'}} Goatify doubles the chance'..
		 '#No effect on quest items',
},

[IBS_ItemID.SaleBomb]={
	name='Sale Bomb',
	info='{{Bomb}} Bombs from Isaac will make coin price decrease 1~2, and spawn {{Coin}}coins with the same number'
},

[IBS_ItemID.Diecry]={
	name='Diecry',
	info='Grant {{Collectible1}}Sad Onion effect in the current room',
	virtue='Inner wisps with less fire delay',
	belial='Double effect',
},

[IBS_ItemID.ReusedStory]={
	name='Reused Story',
	info='Record the last entered non-red-room special room'..
		 '#Generate a red room from record in a new level, and reveal it'..
		 '#Can record: '..
		 '{{Shop}}'..
		 '{{TreasureRoom}}'..
		 '{{Planetarium}}'..
		 '{{SecretRoom}}'..
		 '{{SuperSecretRoom}}'..
		 '{{UltraSecretRoom}}'..
		 '{{Library}}'..
		 '{{AngelRoom}}'..
		 '{{DevilRoom}}'..
		 '{{CursedRoom}}'..
		 '{{ArcadeRoom}}'..
		 '{{DiceRoom}}'..
		 '{{ChestRoom}}'..
		 '{{IsaacsRoom}}'..
		 '{{BarrenRoom}}'..
		 '{{SacrificeRoom}}'..
		 '{{ErrorRoom}}',		 
},

[IBS_ItemID.Zoth]={
	name='Zoth',
	info='Every level, when entering the first {{BossRoom}}Boos Room, reroll room types of the unexplored special rooms'..
		  '#{{BossRoom}}Boss Room and {{UltraSecretRoom}}Ultra Secret Room can not be rerolled'
},

[IBS_ItemID.PageantFather]={
	name='Pageant Father',
	info='Gulp 6 golden penny trinkets (Excluding {{Trinket24}}Butt Penny and {{Trinket172}}Cursed Penny)'..
		 '#Spawn a {{Crafting26}}Golden Penny'
},

[IBS_ItemID.DeciduousMeat]={
	name='Deciduous Meat',
	info='+ 1 {{Heart}}Heart Container'..
		 '#+ 12 {{RottenHeart}}Rotten Hearts'..
		 '#When hurt, 25% chance to spawn a {{RottenHeart}}Rotten Heart',
	player={[PlayerType.PLAYER_BETHANY_B]='+ 12 {{Heart}}Blood Charge'}
},

[IBS_ItemID.CurseSyringe]={
	name='Curse Syringe',
	info='↑ + 0.3 {{Damage}}dmg'..
		 '#↑ For each type of curse encountered in this run, + 0.3{{Damage}}dmg'
},

[IBS_ItemID.AstroVera]={
	name='Astro Vera',
	info='Heart limit + 10, only for Red Heart or Soul Heart characters (Except {{Player17}}Soul of the Forgotten)'..
		 '#+ 10 {{SoulHeart}}Soul Hearts'
},

[IBS_ItemID.SecretAgent]={
	name='Secret Agent',
	info='Select an item from Isaac to remove'..
		 '#Using again to spawn the removed item',
	virtue='Selecting empty slot as {{Collectible33}}Bible',
	belial='Selecting empty slot as {{Collectible51}}Pentagram',
	void='No effect',
},

[IBS_ItemID.CurseoftheFool]={
	name='Curse of the Fool',
	info='When take damage 11 times, trigger {{Card'..Card.CARD_REVERSE_FOOL..'}}The Fool? and {{Card'..Card.CARD_FOOL..'}}The Fool',
	seijaBuff={
		desc = 'Spawn {{Card'..Card.CARD_DICE_SHARD..'}}Dice Shard as bonus',
		data = {
			append = function(x) 
				return (x > 1 and "#Spawn"..(x-1).."{{Card"..Card.CARD_DICE_SHARD.."}}Dice Shard as bonus") or ''
			end
		},
	},	
},

[IBS_ItemID.UnburntGod]={
	name='Burning of Unburnt God',
	info='When used, smelt a gold trinket and spawn a wisp that does not shoot'..
		 '#If the wisp is killed, remove the last smelted golden trinket',
	virtue='Double wisp Hp',
	belial='No special effect',
},

[IBS_ItemID.MyFruit]={
	name='My Fruit',
	info='Charged by cleaning non-red rooms'..
		 '#When used:'..
		 '#+ 2 {{SoulHeart}}Soul Hearts'..
		 '#Pause the time counter this level'..
		 '#Remove curses and gain a blessing'..
		 '#Reveal and reset all rooms to red rooms, excepting some rooms'..
		 '#!!! Remove this item after 4 uses'..
		 '#{{Blank}}(Tap '..EID.ButtonToIconMap[ButtonAction.ACTION_MAP]..' map key to view blessings)',
	virtue='Middle wisps that do not shoot#The wisps can not be hurt when holding this item',
	belial='No special effect',
	void='!!! {{ColorYellow}}SINGLE USE{{CR}}',
	greed='Reload the current level, and then teleport to the starting room',
},

[IBS_ItemID.MyFault]={
	name='My Fault',
	info='Provide 0.5s invincibility'..
		 '#Spawn blood wave, enemies around it will lose 2x Isaac\'s {{Damage}}dmg Hp, and gain bleeding for 8s'..
		 '#Hitting bleeding enemies spawns blood wave again on where they stand',
	virtue='Outer wisps that do not shoot and exist only one room',
	belial='Invincible time increases to 1s',
},

[IBS_ItemID.Memento]={
	name='Memento',
	info='{{Damage}} Set min-dmg to 7',
},

[IBS_ItemID.RubbishBook]={
	name='DEEP MYSTERIES',
	info='Something something DEEP MYSTERIES something',
	virtue='No wisps',
	belial='No effect',	
	seijaBuff={
		desc = '+ %s{{Coin}}Coin',
		data = {
			args = function(x) return x end		
		}
	},	
},

[IBS_ItemID.MawBank]={
	name='Maw Bank',
	info='When a room is cleared, spawn 2 {{Coin}}coins'..
		 '#!!! Paying any {{Coin}}coin at pickups removes this item',
},

[IBS_ItemID.FolkPrescription]={
	name='Folk Prescription',
	info='Ground decorations have 13% chance to be harvestable, standing by which turns it into a {{Pill}}pill'..
		 '#!!! The effect of the pill becomes unidentified'..
		 '#{{Pill}} Using non-negative pill heals 1 {{Hearts}}Red Hearts',
},

[IBS_ItemID.WhiteQBall]={
	name='White Q Ball',
	info='When gained, spawn a {{Rune}}rune'..
		 '#↓ - 0.16 {{Shotspeed}}sspd'..
		 '#{{AngelDevilChance}} + 15% {{DevilRoom}}devil chance, + 100% {{AngelRoom}}angel chance, till next {{AngelRoom}}Angel Room showing up',
},

[IBS_ItemID.DonaldDollar]={
	name='Donald Dollar',
	info='Most coins are {{Crafting3}}Dime'..
		 '#!!! Collectible price x 7',
},

[IBS_ItemID.TempFolder]={
	name='Temp Folder',
	info='When gained, + 1 {{EmptyBoneHeart}}Bone Heart, and smelt copies of the current trinkets'..
		 '#↑ The maximum of {{Coin}}coins, {{Key}}keys, and {{Bomb}}bombs + 49'..
		 '#When entering a new level, drops the over-99 part up to 49'..
		 '#If enough, spawn collectibles instead, each kind can be spawned at most one:'..
		 '#{{Collectible74}}(25{{Coin}})，{{Collectibl623}}(5{{Key}})，{{Collectible19}}(10{{Bomb}})'
},

[IBS_ItemID.Loong]={
	name='Loong',
	info='Grant flight'..
		 '#When attacking, spawn flames under Isaac',
},

[IBS_ItemID.OOC]={
	name='Oath of CHastity',
	info='When gained, + 2 {{SoulHeart}}Soul Hearts'..
		 '#↑ + 3 {{Luck}}luck'..
		 '#Kill Uriel and Gabriel instantly'..
		 '#For every level, the first 7 times penal damage become non-penalt and hurt only half a heart'..
		 '#!!! Lose this item when taking penal damage',
},

[IBS_ItemID.MM]={
	name='MM',
	info='↑ + 0.3 {{Damage}}dmg'..
		 '#↑ + 0.1 {{Speed}}spd'..
		 '#If picked up directly in {{AngelRoom}}Angel Room, gain two more',
},

[IBS_ItemID.MimicInfestation]={
	name='Mimic Infestation',
	info='Apply {{HauntedChest}}Haunted Chest effect to all chests'..
		 '#When entering a new room, 6% chance to spawn a {{GoldenChest}}Golden Chest',
	seijaBuff={
		desc = '+ 6% chance; Be invincible when Polty exists',
		data = {
			append = function(x) 
				return (x > 1 and "#+ "..(10*(x-1)).."% chance") or ''
			end
		},	
	}		 
},

[IBS_ItemID.CardboardMush]={
	name='Cardboard Mush',
	info='When gained, spawn 3 cards'..
		 '#When consuming cards, trigger {{Card12}}Strength',
},

[IBS_ItemID.Transmogrify]={
	name='Transmogrify',
	info='Reroll the closest item to {{Quality1}}Q1 item'..
		 '#1% chance to {{Collectible'..(IBS_ItemID.CheeseCutter)..'}}Cheese Cutter',
	virtue='Middle wisps that do not shoot; 10 % chance turns collided enemies to Fly',
	belial='No special effect',
	void='No effect',
},

[IBS_ItemID.SpiritPoop]={
	name='Spirit Poop',
	info='{{CurseRoom}}Curse Room will be replaced by {{SuperSecretRoom}} Super Secret Room'..
		 '#{{SuperSecretRoom}} Open doors of Super Secret Room',
},

[IBS_ItemID.CalocybeGambosa]={
	name='Calocybe gambosa',
	info='When gained, + 3 {{SoulHeart}}Soul Hearts'..
		 '#{{SacrificeRoom}} Spawn 2 extra spikes in Sacrifice Room',
},

[IBS_ItemID.AFaces]={
	name='A Faces',
	info='When gained, smelt one of trinkets below:',
},

[IBS_ItemID.BigSlurp]={
	name='Big Slurp',
	info='When gained, spawn 2 {{Collectible197}}Jesus Juice',
},

[IBS_ItemID.BobsRottenHand]={
	name="Bob's Rotten Hand",
	info="When attacking, fire an explosive tear with 100%{{Damage}}Isaac's dmg"..
		 '#Needs stop attacking to fire next one',
},

[IBS_ItemID.Armageddon]={
	name='Armageddon',
	info='Spawn and reveal Boss Rush as a room for each level if possible'..
		 '#In Boss Rush:'..
		 '#{{Blank}} All items can be picked up'..
		 '#{{Blank}} One more option in cycle for items'..
		 '#{{Blank}} Enemies lose 12% HP per second',
	seijaNerf="Do not spawn Boss Rush"
},

[IBS_ItemID.MomsOldKey]={
	name="Mom's Old Key",
	info='+ 2 {{Key}}keys in a new level'..
		 '#50% {{Chest}}Common Chest turns into {{DirtyChest}}Old Chest',
},

[IBS_ItemID.BeggarMedal]={
	name='Beggar Medal',
	info='!!! {{ColorYellow}}SINGLE USE{{CR}}'..
		 '#Gain {{Collectible144}}{{Collectible278}}{{Collectible388}}'..
		 '#Lose them in a new level',
	virtue='Gain item-wisp of {{Collectible'..(IBS_ItemID.SOG)..'}}Soul of Generosity',
	belial='Keep {{Collectible278}}',
},

[IBS_ItemID.SlowStart]={
	name='Slow Start',
	info='↓ {{Speed}}spd - 0.5'..
		 '#↑ 5 minutes later, {{Speed}}spd + 0.5, {{Damage}}dmg x 150%'..
		 '#Reset the counter in a new level, the counter will decrease by 20s x level',
},

[IBS_ItemID.BrokenRKey]={
	name='Broken R Key',
	info='!!! {{ColorYellow}}SINGLE USE{{CR}}'..
		 '#Drop level-num passive items with random items in cycle'..
		 '#Reset game timer and item pools'..
		 '#No effect on quest or error items',
	virtue='No wisps#28% angel item in cycle',
	belial='Gain {{Collectible51}}Pentagram',
},

[IBS_ItemID.ADTime]={
	name='AD Time',
	info='When Isaac dies, play the Credits, then revive Isaac with full health'..
		 '#!!! Exiting before finished fails the revival',
},

[IBS_ItemID.DMGTransmitter]={
	name='DMG Transmitter',
	info='When used, lose 1 {{Damage}}dmg, enemies take 2 extra damage in the run'..
		 '#!!! To use, {{Damage}}dmg must be above 3.5',
	virtue='Inner wisps that fire {{Collectible494}} laser tears',
	belial='Enemies take 1.3 extra damage in the run',
},

[IBS_ItemID.Posture]={
	name='Posture！',
	info='When gained, spawn {{Card1}}The Fool'..
		 '#Charged by cleaning rooms, dealing damage or being hurt, and can be charged twice'..
		 '#Collect tarot cards in a cleared room, most to 5'..
		 '#When used, grant additional melee attack in 14 seconds',
	virtue='No effect',
	belial='No effect',		 
	player={[IBS_PlayerID.BSamson] = "Switch to next card, different effects in different states; Grant extra slots for reversed tarot"}
},

[IBS_ItemID.BlessingOfMichael]={
	name='Blessing of Michael',
	info='When gained, remove {{AngelRoom}}angel items whose quality below {{Quality4}}4 from pools and spawn a {{Quality4}}Q4 {{AngelRoom}}angel item'..
		 '#Boost vanilla {{Quality4}}Q4 {{AngelRoom}}angel item'..
		 '#!!! In {{DevilRoom}}Devil Room, health-priced items can not be picked up',
	seijaNerf='Gain the item inserted of spawning',
},

[IBS_ItemID.LordsParasol]={
	name="Lord's Parasol",
	info='{{Shop}} When entering a Shop for the first time, gain all priced items in it continually'..
		 '#!!! {{ColorRed}}Active items will replace each other{{CR}}',
},

[IBS_ItemID.BloodyRose]={
	name='Bloody Rose',
	info='In a new room, spawn spiked items as options of items in it'..
		 '#!!! {{ColorRed}}If there\'s a {{Quality2}}Q2 item, items with other quality can not be picked up{{CR}}',
},

[IBS_ItemID.PreservedFog]={
	name='Preserved Fog',
	info='When directly picking items up, remove 3 items with lowest and below-{{Quality3}}Q3 quality from pools (Activated also when picking up this item)'..
		 '#!!! {{ColorRed}}The first item in a level will be replaced by {{Card41}}Black Rune{{CR}}',
},

[IBS_ItemID.Fiddle]={
	name='Fiddle',
	info='When entering a new level, spawn 2 random passive items'..
		 '#!!! {{ColorRed}}Non-Quest items appear after entering in a room for 0.1 seconds will be removed, except in {{BossRoom}}Boss Room{{CR}}',
},

[IBS_ItemID.WhisperingEarring]={
	name='Whispering Earring',
	info='↑ {{Damage}} dmg x 1.5'..
		 '#!!! {{ColorRed}}During the first 13 seconds in an uncleared room, reverse shooting controls randomly{{CR}}',
},

[IBS_ItemID.SereTalon]={
	name='Sere Talon',
	info="When gained, spawn 3 {{Card49}}Dice Shard"..
		 '#{{Card49}} Dice Shard changes: Reroll items into {{Quality2}}Q2-or-above ones'..
		 '#!!! {{ColorRed}}When using {{Card49}}Dice Shard, gain a random {{Quality0}}Q0 passive item{{CR}}',
},

[IBS_ItemID.MusicBox]={
	name='Music Box',
	info='When directly picking a passive offensive item up, spawn the corresponding item-wisp'..
		 "#No effect on error or quest items",
},

[IBS_ItemID.JeweledMask]={
	name='Jeweled Mask',
	info='When entering a new level, spawn a copy of a passive item from Isaac (Items not turely held included)'..
		 '#No effect on error or quest items'
},

[IBS_ItemID.ChoicesParadox]={
	name='Choices Paradox',
	info='When entering a new level, spawn 5 runes, but only one can be picked',
},

[IBS_ItemID.DistinguishedCape]={
	name='Distinguished Cape',
	info='Gain 3 soul familiars who mimic Isaac\'s tears with 30% {{Damage}}damage'..
		 '#Before taking damage, kill a soul familiar inserted'..
		 '#When entering a new level, refill 3 soul familiars',
},

[IBS_ItemID.AzazelTheWild]={
	name='Azazel The Wild',
	info='{{Collectible118}} When attacking, fire short brimestone every 3s'
},

[IBS_ItemID.Kindness]={
	name='Kindness',
	info='When attacking, randomly gain 1s sheild, but with 0.5s no control',
	seijaBuff={
		desc = 'Enable control when triggered',
		data = {
			append = function(x) 
				return ''
			end
		},
	},	
},

[IBS_ItemID.Beg]={
	name='I Beg',
	info='5% chance to remove a non-boss enemy, and then leave a {{Coin}}coin',
	virtue='Spawn a common wisp if succeed',
	belial='Spawn a {{Bomb}}bomb if succeed',
},

[IBS_ItemID.BrokenTV]={
	name='Broken TV',
	info='When used, dorp this item'..
		 '#When entering {{Shop}}shop, 10% chance to cost all {{Coin}}coins, and turn this item into {{Collectible633}}Dogma'..
		 '#{{Blank}} (At least 1 {{Coin}}coin to be triggered)',
	virtue='Double chance',
	belial='When used, lose this item and gain 1 {{Damage}}dmg',
},

[IBS_ItemID.FamilyPortrayal]={
	name='Family Portrayal',
	info='Gain all passive quest items, except {{Collectible668}}#{{HardMode}}This item will be rerolled automatically if not on Hard Mode',
},

[IBS_ItemID.RitesOfTheRoots]={
	name='Rites of The Roots',
	info='{{SacrificeRoom}} Add an extra sacrificial room on new level'..
	'#The added sacrificial room extra includes {{Confessional}}confessional and {{Beggar}}beggars.',
},

[IBS_ItemID.RageOfSwarm]={
	name='Rage of Swarm',
	info='50% blue flies become {{Trinket113}}Locust of War'..
	'#Locust trinkets and fly items with quality {{Quality2}}2 or below will be replaced by golden {{Trinket186}}Apollyons Best Friend'..
	'#!!! Effective on items owned'..
	'#Auto-smelt {{Trinket186}}Apollyons Best Friend',
},

[IBS_ItemID.Nectars]={
	name='Insects and Nectars',
	info='{{Collectible9}} Spawn blue flies equal to the number of fly items owned after entering new room.'..
	'#10% chance to spawn a temporary {{HalfHeart}}half heart when Blue Fly disappears',
},

[IBS_ItemID.Orichaliron]={
	name='Orichaliron',
	info='{{Luck}} Luck + 2'..
	'#{{SoulHeart}} If skipped Soul Heart pickups ({{BlackHeart}}Black Heart excluded) throughout the level, + 4 {{SoulHeart}}Soul Hearts next level',
},

[IBS_ItemID.DisasterOfSodom]={
	name='Disaster of Sodom',
	info='!!! {{ColorYellow}}SINGLE USE{{CR}}'..
	'#!!! Remove items from the current pool until only one item of each quality remains',
	virtue='1 petrified tear wisp and 1 common wisp',
	belial='No SINGLE USE anymore!',
},

[IBS_ItemID.Monocle]={
	name='Monocle',
	info='↑ +1.5{{Range}}Range'..
	'#Gain 2 more {{Collectible'..IBS_ItemID.Monocle..'}} Monocle when picked up',
},

}
--------------------------------------------------------
-------------------------Trinket------------------------
--------------------------------------------------------
local trinketEID={

[IBS_TrinketID.BottleShard]={
	name="Bottle Shard",
	info="10% chance to bleed damaged enemies for 6 seconds with 3 extra damage",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.DadsPromise]={
	name="Dad's Promise",
	info="{{BossRoom}} Finishing Boss Room in (60 + 15 x stages) seconds spawns {{Card49}}",
	mult={findReplace = {"15","20","25"}},
},

[IBS_TrinketID.GamblersEye]={
	name="GamblersEye",
	info="Touching a non-quest collectible whose quality belows {{Quality1}}1 rerolls it, but 20% chance to remove it",
	mult={findReplace = {'{{Quality1}}1', '{{Quality2}}2', '{{Quality2}}2'}}
},

[IBS_TrinketID.BaconSaver]={
	name="BaconSaver",
	info="Damage with penalty will remove this trinket, and trigger {{Card56}}Fool? and {{Card49}}Dice Shard",
},

[IBS_TrinketID.DivineRetaliation]={
	name="Divine Retaliation",
	info="30% chance to resist damage from projectiles#When hit by projectiles, transform projectiles around into fire",
	mult={
		numberToMultiply = 30,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.ToughHeart]={
	name="Tough Heart",
	info="15% chance to resist damage#When hurt, the chance + 25% until next resistance#No effect on self-damage",
	mult={
		numberToMultiply = 25,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.ChaoticBelief]={
	name="Chaotic Belief",
	info="For the first time, getting this trinket is regarded as a devil deal, but + 100%{{AngelRoom}}angel chance, + 1{{EternalHeart}}Eternal Heart and + 1{{BlackHeart}}Black Heart"..
		 "#{{AngelRoom}} angel chance + 50%"..
		 "#No devil or angel room chance decrease when{{Heart}}Red Hearts are damaged in normal rooms",
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}	
},

[IBS_TrinketID.ThronyRing]={
	name="Throny Ring",
	info="When hurt, 13% chance to trigger:"..
		 "#{{BrokenHeart}} 50% clear a broken heart, if not then skips to next one"..
		 "#{{SoulHeart}} 25% soul heart + 1"..
		 "#{{AngelRoom}} 15% angel chance + 10%, and remove curses"..
		 "#{{EternalHeart}} 10% eternal heart + 1",
	mult={
		numberToMultiply = 13,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.PresentationalMind]={
	name="Presentational Mind",
	info="For every 3 {{Coin}}coins, + 1.3% {{DevilRoom}}devil chance",
	mult={
		numberToMultiply = 1.3,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.Export]={
	name="Export",
	info="50% chance to spawn a coin-priced angel item in Devil Room, or a health-priced devil item in Angel Room (not devil deal)",
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}	
},

[IBS_TrinketID.Nemesis]={
	name="Nemesis",
	info="{{Damage}} When hurt, Do 7 x Isaac's dmg to the attacker",
	mult={
		numberToMultiply = 7,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.Barren]={
	name="Barren",
	info="Enemies take extra 50% damage"..
		 "#Isaac takes extra half a heart damage"..
		 "#Heart, coin, key and bomb pickups will disappear in 3 seconds",
	mult={
		numberToMultiply = 3,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.LeftFoot]={
	name="The Left Foot",
	info="When entering a new level, spawns 2 red chest and loses 0.06{{Speed}}spd"..
		 "#{{Speed}} spd must be above 0.66, or it does nothing",
	mult={
		numberToMultiply = 2,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.RabbitHead]={
	name="Rabbit Head",
	info="↑ {{Luck}}luck + 3.5 in normal rooms",
	mult={
		numberToMultiply = 3.5,
		maxMultiplier = 3,
	}	
},

[IBS_TrinketID.LunarTwigs]={
	name="Lunar Twigs",
	info="When entering a new room, + 1 temporary {{IBSIronHeart}}Iron Hearts",
	player={[IBS_PlayerID.BMaggy]="Extra{{IBSIronHeart}} Iron Hearts instead"},
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.Interval]={
	name="Interval",
	info="Do extra damage of 0.5% x the difference between the first-slot active item's ID and the last-got item's ID",
	mult={
		numberToMultiply = 0.5,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.NumeronForce]={
	name="Numeron Force",
	info="Before consuming a card, cancel its effect, "..
		 "and then decide the effect with the number of {{Heart}}Red Hearts, {{SoulHeart}}Soul Hearts and {{BlackHeart}}Black Hearts:"..
		 "#{{Blank}} >6: Original effect"..
		 '#{{Blank}} [4,6): {{Card14}}Death + {{Card69}}Death?'..
		 '#{{Blank}} [3,4): {{Card4}}Empress + {{Card16}}Devil'..
		 '#{{Blank}} [2,3): {{Card12}}Strength + {{Card52}}Huge Growth'..
		 '#{{Blank}} [0,2): {{Card51}}Holy Card + {{Card67}}Strength?',
	mult={append = "Double card's effect"}
},

[IBS_TrinketID.WheatSeeds]={
	name="Wheat Seeds",
	info="When smelted and a room is cleared, it became{{"..(IBS_ItemID.GrowingWheatI).."}}Growing Wheat I"..
		 '#Smelts this when hurt or in a new level',
},

[IBS_TrinketID.CorruptedDeck]={
	name='Corrupted Deck',
	info='When gained, spawn two common tarot cards'..
		 '#When a room is cleared, 6% chance to spawn a common tarot card'..
		 "#When comsuming any tarot card, common tarot cards whose number is below that one's became reversed ones",
	mult={
		numberToMultiply = 6,
		maxMultiplier = 3,
	}		 
},

[IBS_TrinketID.GlitchedPenny]={
	name='Glitched Penny',
	info='When picking up a common coin, 5~100% chance to reroll it into a random coin',
	mult={findReplace = {'5','10','15'}}
},

[IBS_TrinketID.StarryPenny]={
	name='Starry Penny',
	info='When picking up a coin, {{Planetarium}}Planetarium chance + 0.1%, and (20 + 5 x value)% chance to spawn a {{Card55}}Rune Shard',
	mult={findReplace = {'20','30','40'}}
},

[IBS_TrinketID.PaperPenny]={
	name='Paper Penny',
	info='When picking up a coin, (15 + 3 x value)% chance to spawn a wisp of a book active item',
	mult={
		append = {'Try twice', 'Try three times'}
	}
},

[IBS_TrinketID.CultistMask]={
	name='Cultist Mask',
	info='You feel more talkative',
	mult={
		append = {'You feel more more talkative', 'You feel more more talkative#{{ColorGold}}You feel more more more talkative{{CR}}'}
	}
},

[IBS_TrinketID.SsserpentHead]={
	name='Ssserpent Head',
	info='When entering a new {{SecretRoom}} Secret, {{SuperSecretRoom}}Super Secret or {{UltraSecretRoom}}Ultra Secret Room, '..
		 'spawn 5 coins',
	mult={
		numberToMultiply = 5,
		maxMultiplier = 3,
	}		
},

[IBS_TrinketID.ClericFace]={
	name='Cleric Face',
	info='After clearing 14 rooms, if the number of {{Heart}}Heart Container is below 5, + 1 {{EternalHeart}}Eternal Heart; or + 1 {{HalfSoulHeart}}Half Soul Heart'..
		 '#And spawn {{Card51}}Holy Card',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,	
		append = {'Double efficiency', 'Triple efficiency'}
	},
},

[IBS_TrinketID.NlothsMask]={
	name='Nloths Mask',
	info='Next pedestal item will be replaced by 1 {{Collectible515}}Mystery Gift, and then remove this trinket'..
		 '#No effect on error or quest items',
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	},
},

[IBS_TrinketID.GremlinMask]={
	name='Gremlin Mask',
	info='When entering a room with enemies, Isaac gets fear for 1 second, enemies get fear for 5 seconds and weakness for 4 seconds',
	mult={
		numberToMultiply = 4,
		maxMultiplier = 3,
	},
},

[IBS_TrinketID.OldPenny]={
	name='Old Penny',
	info='When picking up a coin, game timer decreases by (5 x value) seconds, and if it is below 10 minutes, 25% chance to spawn a random pickup',
	mult={
		numberToMultiply = 5,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.CrackCallback]={
	name='Crack Callback',
	info='Grants immunity from stomp and falling rocks'..
		 '#When hurt, 30% chance to trigger {{Card3}} The High Priestess',
	mult={
		numberToMultiply = 30,
		maxMultiplier = 2,
	}
},

[IBS_TrinketID.Foe]={
	name='Foe',
	info='This trinket can block projectiles when on the ground',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'Bigger', 'Bigger than Bigger'}
	}
},

[IBS_TrinketID.OddKey]={
	name='Odd Key',
	info='Boss Rush keeps open'..
		 '#When Boss Rush is finished, spawn 1 {{Collectible297}}Pandora\'s Box, and then lose this trinket',
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.Neopolitan]={
	name='Neopolitan',
	info='For every new 3 special rooms entered this level:'..
		 '#↑ {{Speed}} spd + 0.1'..
		 '#↑ {{Tears}} tears + 0.35'..
		 '#↑ {{Damage}} dmg + 0.5',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'Double efficiency', 'Triple efficiency'}
	}
},

[IBS_TrinketID.WildMilk]={
	name='Wild Milk',
	info='The first penalt damage taken in a room decreases by 1, and becomes non-penalty with no invincible time',
	mult={
		numberToMultiply = 1,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.BlackCharm]={
	name='Black Charm',
	info='↑ + 0.6 {{Damage}}dmg when having entered {{CurseRoom}}Curse Room in the current level'..
		 '#↑ + 2.4 {{Damage}}dmg when the current level is cursed',
	mult={
		numberToMultiply = 3,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.WarHospital]={
	name='War Hospital',
	info='When on the ground, heals a friendly monster or familiar whose hp is below 75% nearby for 5% hp continually'..
		 '#This trinket can not be picked up when in a uncleared room',
	mult={
		numberToMultiply = 5,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.SporeCloud]={
	name='Spore Cloud',
	info='When hurt, fire {{Collectible553}}spore tears with 100% Isaac\'s damage at 8 directions',
	mult={
		numberToMultiply = 100,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.ForScreenshot]={
	name='For Screenshot',
	info='When gained, replace the appearance of items in the current room with {{Quality4}}Q4 ones'..
		 '#Losing this trinket or approaching the items to recover the appearance'..
		 '#Grant {{Player23}}Tainted Cain costume'..
		 '#Show {{Collectible710}}Bag of crafting UI (Useless)',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'Isaac will revive as {{Player23}}Tainted Cain when dying if not Tainted Cain'}
	}
},

[IBS_TrinketID.TheLunatic]={
	name='The Lunatic',
	info='10% chance to add {{Collectible358}}The Wiz in cycle for items newly appeared'..
		 '#No effect to quest items',
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.MMS]={
	name='MMS',
	info='↑ When Uriel / Gabriel is killed, + 4 {{Damage}}dmg in the current level (Only count once)',
	mult={
		numberToMultiply = 4,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.TechSL]={
	name='Tech SL',
	info='When Isaac dies, crash the game (SERIOUSLY)',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		append = {'Trigger {{Collectible422}}Glowing Hourglass instead'}
	}
},

[IBS_TrinketID.UnstableReagent]={
	name='Unstable Reagent',
	info='In a new level, trigger 3 pill effects randomly',
	mult={
		numberToMultiply = 3,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.EnvyToWin]={
	name='Envy To Win',
	info='When entering an uncleared {{BossRoom}}Boss or {{MiniBoss}}Mini-Boss Room, spawn Super Envy'..
		 '#Killing envys has 50% chance to spawn coins',
	mult={
		numberToMultiply = 50,
		maxMultiplier = 2,
	}
},

[IBS_TrinketID.BulkyWorm]={
	name='Bulky Worm',
	info='+ 100% Tear scale',
	mult={
		numberToMultiply = 100,
		maxMultiplier = 3,
	}
},

[IBS_TrinketID.ModelingClay]={
	name='ModelingClay II',
	info='Put down near a passive item with {{Quality2}}Q2 or below to copy its effect'..
		 '#No effect on error or quest items'..
		 '#All {{Trinket'..(IBS_TrinketID.ModelingClay)..'}}Modeling Clay II share the effect',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		findReplace = {'{{Quality2}}Q2', '{{Quality3}}Q3', '{{Quality4}}Q4'},
	}
},

[IBS_TrinketID.SamsonState]={
	name='Samson State',
	info='Show state',
},

[IBS_TrinketID.LithiumBattery]={
	name='Lithium Battery',
	info='When paying 5 {{Coin}}coins or more to buy a pickup, spawn Micro Battery',
	mult={
		numberToMultiply = 114514,
		maxMultiplier = 3,
		findReplace = {'5', '3', '1'},
	}	
},

}
--------------------------------------------------------
--------------------------Card--------------------------
--------------------------------------------------------
local cardEID={

[IBS_PocketID.CuZnD6] = {
	name="The Great Golden Collectible -- D6",
	info="Rerolls items#99% not to disappear, but the chance decrease by 10 per used"
},

[IBS_PocketID.GoldenPrayer] = {
	name="Golden Prayer",
	info="+ 28 temporary {{IBSIronHeart}}Iron Hearts#{{BossRoom}} After consumed, this card will be spawned whten next Boss Room is cleared",
	mimic={charge = 6, isRune = false},
	player={[IBS_PlayerID.BMaggy]='Recover lost {{IBSIronHeart}} Iron Heart maximum'}
},

[IBS_PocketID.StolenYear] = {
	name="Stolen Year",
	info="In priority:"..
		 "#Priced pickups exist: Removes the price"..
		 "#Optional pickups exist: No options"..
		 "#In starting room: Dagaz, Ansuz, and {{Collectible76}}X-Ray"..
		 "#Else: Removes 1{{BrokenHeart}}Broken Heart, and triggers {{Card51}}Holy Card",
	mimic={charge = 6, isRune = false},
},

[IBS_PocketID.NeniaDea] = {
	name='Nenia Dea',
	info='Falsehoods <=> Souls, or spawn a falsehood or soul',
	mimic={charge = 6, isRune = false},
},

[IBS_PocketID.BIsaac] = {
	name="Falsehood of Isaac",
	info="Rerolls items to devil/angel items with their average quality in the current room",
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: If a touched item's quality is less than or equal to the numbers of this kind, then consume 3 {{IBSMemory}}Memories to reroll the item with the same quality"},
	runeSword='Two more options in cycle in Devil/Angel Room; Unstackable'
},

[IBS_PocketID.BMaggy] = {
	name="Falsehood of Magdalene",
	info="↑ In 7 seconds, Isaac becomes invincible, + 0.7{{Speed}}spd, constantly spawns holy light and shockwave",
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: When the room is cleared or Isaac is hurt, + 1 temporary {{IBSIronHeart}}Iron Heart"},
	runeSword='When cleaning a new room, + 1 temporary {{IBSIronHeart}}Iron Heart'
},

[IBS_PocketID.BCain] = {
	name="Falsehood of Cain",
	info="Gulp 4 {{Trinket"..(IBS_TrinketID.WheatSeeds).."}}Wheat Seeds",
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: When the room is cleared, 33% chance to gulp {{Trinket"..(IBS_TrinketID.WheatSeeds).."}}Wheat Seeds, or spawn one"},
	runeSword='Seed Bag has 40% chance to replace Grab Bag or Black Sack, up to 80%',
},

[IBS_PocketID.BAbel] = {
	name="Falsehood of Abel",
	info='Spawn 3 friendly Goats with 2x Hp',
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: Every 7 seconds, spawn a tiny friendly goat if not already"},
	runeSword='When hurt, transform the non-boss attacker to a Goat',
},

[IBS_PocketID.BJudas] = {
	name="Falsehood of Judas",
	info="In 3 seconds, the next attack will fire a spectral, piercing and burning tear with 1300% Isaac's{{Damage}}dmg"..
		 "#If the tear hits, gain another one {{Card"..(IBS_PocketID.BJudas).."}}",
	mimic={charge = 1, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: Every 2 seconds, weaken enemies around for 1.5 seconds"},
	runeSword='Every 3 seconds, weaken enemies around for 1.5 seconds',
},

[IBS_PocketID.BEve] = {
	name="Falsehood of Eve",
	info="Clear curses, and gain a bless"..
		 '#If all blesses exist, remove a {{BrokenHeart}}Broken Heart',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: Every 0.4 seconds, clear a projectile near Isaac"},
	runeSword='Clearing {{BossRoom}}Boss Room clears curses',
},

[IBS_PocketID.BSamson] = {
	name="Falsehood of Samson",
	info="Record times of taking damage"..
		 '#Stop recording at mext {{BossRoom}}Boss Room, and gain:'..
		 '#↑ {{Tears}}tears and {{Damage}}dmg x (100% + 15% x times), MAX:300%, decreasing'..
		 '#↑ {{Shotspeed}}sspd + 1, until stats above decrease to normal'..
		 '#Using this in {{BossRoom}}Boss Room will recover decreased stats above',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: Attack an enemy for 14 dmg or a projectile nearby; The larger the accumulated counter, the faster it attacks"},
	runeSword='When entering an uncleared {{BossRoom}}Boss Room, trigger the effect of this rune',	
},

[IBS_PocketID.BAzazel] = {
	name="Falsehood of Azazel",
	info="Get one-heart hurt, gain another this falsehood, and increase the counter"..
		 "#Every time the counter increases, bonus comes, similar to {{SacrificeRoom}}Sacrifice Room"..
		 "#Remove this in a new level unless the counter is above 11, and reset the counter",
	mimic={charge = 1, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: Has (7 + current counter) collision damage; Every 2 seconds, bleeds enemies around for 3 seconds"},
	runeSword='When hurt by gound spikes, increase the counter by 1; Unstackable',
},

[IBS_PocketID.BLazarus] = {
	name='Falsehood of Lazarus',
	info='Teleport to a qualified but temporary room:'..
		 '#{{Shop}} <-> {{TreasureRoom}}'..
		 '#{{SecretRoom}} <-> {{SuperSecretRoom}}'..
		 '#{{ArcadeRoom}} <-> {{CurseRoom}}'..
		 '#{{UltraSecretRoom}} <-> {{Planetarium}}'..
		 '#If successfully teleported, gain a {{BrokenHeart}}Broken Heart, or gain 2 {{SoulHeart}}Soul Hearts'..
		 '#!!! {{Collectible263}}If triggered by Clear Rune or others, or already in the temporary room, it can not teleport',
	mimic={charge = 12, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: + 5 {{IBSMemory}}Memories when entering a new special room'},
	runeSword='When entering a new special room, + 1{{HalfSoulHeart}}Half Soul Heart',	
},

[IBS_PocketID.BEden] = {
	name="Falsehood of Eden",
	info="Teleport to Error Room; if already in, then spawn a random item"..
		 "#Spawn a purple portal in every Error Room",
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: When a room is cleared, reveal a special room, or + 3 {{IBSMemory}}Memories'},
	runeSword='When entering a new level, spawn{{Card'..(IBS_PocketID.BEden)..'}}Falsehood of Eden',
},

[IBS_PocketID.BLost] = {
	name="Falsehood of the Lost",
	info="Transform chests even opened into Eternal Chests"..
		 "#No effect on Eternal Chest",
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: When a room is cleared, 20% chance to spawn a common chest"},
	runeSword='25% chance to fire key tears',	
},

[IBS_PocketID.BLilith] = {
	name='Falsehood of Lilith',
	info='Remove a passive item with lowest quality from Isaac'..
		 '#Remove 15 items with the lowest quality from pools, and spawn one with the same quality'..
		 '#No effect on quest items',
	mimic={charge = 3, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: When entering a new room, remove an item with lowest quality from pools'},
	runeSword='When inserted, remove 30 below-{{Quality2}}Q2 items from pools',
},

[IBS_PocketID.BKeeper] = {
	name="Falsehood of the Keeper",
	info="For every 3 donations to beggars, spawn pickups up to 20"..
		 '#55%{{Coin}}Double Coins'..
		 '#10%{{Bomb}}bomb'..
		 '#10%{{Key}}key'..
		 '#10%{{SoulHeart}}Soul Heart'..
		 '#10%{{Heart}}{{Heart}}Double Hearts'..
		 '#10%{{Card53}}Ancient Recall'..
		 '#5%{{Crafting11}}Lucky Penny',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: Every second, fire a tear with (1 + 0.1 x donations) damage to the closest enemy'},
	runeSword='Grant effect of {{Collectible'..(IBS_ItemID.SOG)..'}}Soul of Generosity',
},

[IBS_PocketID.BApollyon] = {
	name='Falsehood of Apollyon',
	info='Spawn 3 other runes consumed recently, if not enough, spawn {{Card41}}Black Rune instead#No effect on Jera',
	mimic={charge = 12, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: When cosuming other runes, cost 5{{IBSMemory}}Memories to trigger its effect once more'},
	runeSword='When inserted, trigger the effect of this rune',
},

[IBS_PocketID.BForgotten] = {
	name="Falsehood of the Forgotten",
	info='Spawn 12 bone orbitals and 3 item-wisps of {{Quality2}}Q-2-or-above items that have been removed from pools',
	mimic={charge = 4, isRune = true},
	player={[IBS_PlayerID.BXXX] = "Orb: Every 5 seconds, bone orbital up to six"},
	runeSword='When killing enemies, 18% chance to spawn a friendly Bony',	
},

[IBS_PocketID.BBeth] = {
	name='Falsehood of Bethany',
	info='When held, a phantom active item will appear in a new room, which will be recorded when picked up'..
		 '#Trigger 4 effects recorded lately'..
		 '#Next level, clear records, if there are 4 records, gain another one {{Card'..(IBS_PocketID.BBeth)..'}}',
	greed='Clear records and try gain another one directly',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: Consume 1 {{IBSMemory}}memories to record a phantom item'},
	runeSword='When using Rune Sword, randomly trigger the effect of two of the phantom items',
},

[IBS_PocketID.BJBE] = {
	name='Falsehood of Jacob and Esau',
	info='Transform the closest item into two items with quality - 1',
	mimic={charge = 6, isRune = true},
	player={[IBS_PlayerID.BXXX] = 'Orb: Copy abilities of two other orbs of two falsehoods used recently'},
	runeSword='When inserted, copy a non=quest item from Isaac with the lowest quality twice'
},

}
--------------------------------------------------------
--------------------------Slot--------------------------
--------------------------------------------------------
local slotEID = {

[IBS_SlotID.CollectionBox.Variant] = {
	name='Collection Box',
	info=''
},

[IBS_SlotID.Albern.Variant] = {
	name='Brother Albern',
	info='When destroyed, spawn a touched {{Collectible504}}Brown Nugget'..
		 '#May be woke up when touched'..
		 '#When woke up, 30% chance to spawn an item from {{KeyBeggar}}Key Master Pool, or spawn an uncommon chest'
},

[IBS_SlotID.Facer.Variant] = {
	name='Facer',
	info='When touched for 1 second, Isaac takes 1 heart damage (Red Heart first), and spawn 5 coins'..
		 '#36% chance to leave; Also leaves when touched for 4 times'..
		 '#Spawn {{Collectible'..(IBS_ItemID.AFaces)..'}} A Faces when leaving:'..
		 '#The effect, smelt one of trinkets: ',
},

[IBS_SlotID.Envoy.Variant] = {
	name='Envoy',
	info='{{Coin}}After receiving 30 coins, return all coins, and triggers {{Collectible585}}Alabaster Box'..
		 '#When destroyed, spawns Uriel / Gabriel who drops Key Piece'..
		 '#!!! {{Player3}}{{Collectible619}}Judas with Birthright: Coins given will not be counted',
},

}

--------------------------------------------------------

local hoardingEID = {

	FormList = {
		[ItemConfig.TAG_GUPPY] = '{{Guppy}} 10% chance to spawn a blue fly when hurting an enemy',
		
		[ItemConfig.TAG_FLY] = '{{LordoftheFlies}} 50% chance to spawn a blue fly when killing an enemy',
		
		[ItemConfig.TAG_MUSHROOM] = '{{FunGuy}} When gained, 50% chance to gain {{Heart}}Health up',
		
		[ItemConfig.TAG_ANGEL] = '{{Seraphim}} When gained, + 1 {{SoulHeart}}Soul Heart',
		
		[ItemConfig.TAG_BOB] = '{{Bob}} Grants explosion immunity when this transformation is done',
		
		[ItemConfig.TAG_SYRINGE] = '{{Spun}} + 0.25 {{Damage}}dmg',
		
		[ItemConfig.TAG_MOM] = '{{Mom}} Enemies take 0.25 more damage',
		
		[ItemConfig.TAG_BABY] = '{{Conjoined}} + 0.15 {{Tears}}tears',
		
		[ItemConfig.TAG_DEVIL] = '{{Leviathan}} When gained, + 1 {{HalfBlackHeart}}Half Black Heart',
		
		[ItemConfig.TAG_POOP] = '{{OhCrap}} When this transformation is done, heal an extra {{Heart}}Heart from destroying a poop',

		[ItemConfig.TAG_BOOK] = '{{Bookworm}} Provides (0.5 x maxCharges x componentNum) shield when using a book',
		
		[ItemConfig.TAG_SPIDER] = '{{SpiderBaby}} Spawns 2 blue spiders in a new room or a new greed wave',
	},

	StompyFrom = {
		info = '{{Stompy}} + 20 collision damage',
		[12] = true,
		[302] = true,
	},

}

BSamsonEID = {

	[0] = {
		Common = '(Unfinished)',
		Calm = '(Unfinished)',
		Wrath = '(Unfinished)',
	},

	[1] = {
		Common = 'No effect',
		BSamson = 'When changing rooms, select the last card',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[2] = {
		Common = '↓{{Damage}}DMG x 50% (not stackable); Apply a mark to enemies hit by swing; Each mark let enemies take 1 more damage',
		Calm = '{{Battery}}{{2}} Apply 10 marks to all enemies; Gain homing effect in the current room',
		Wrath = '{{Battery}}{{2}} All enemies lose Hp equalling to 10x marks',
	},

	[3] = {
		Common = 'Swing can destroy obstacles and doors',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{2}} Fire 8-dir shockwaves',
	},

	[4] = {
		Common = 'Swing applies bleeding, 25% faster but in 10% smaller range',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath; Gain {{Card4}}The Empress effect, if already then cost 1 charge inserted',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonWrath}}Wrath',
	},

	[5] = {
		Common = 'Swing 25% slower, + 1s sheild when hitting enemies, not stackable during sheilded',
		Calm = '{{Battery}}{{2}} + 5s sheild',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[6] = {
		Common = 'Petrify enemies firstly hit for 1s',
		Calm = '{{Battery}}{{2}} Petrify all enemies for 5s',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[7] = {
		Common = 'Swing num + 1; Enemies hit by plural swing have 6% chance to drop temporary {{HalfHeart}}Half Heart ({{Luck}}Luck 6: 12%)',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{3}} Enter {{IBSSamsonWrath}}Wrath, spawn a random temporary heart',
	},

	[8] = {
		Common = 'Swing damage, size and distance will gradually increase until stopping attack or hitting border',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
	},

	[9] = {
		Common = 'Swing with 50% lower damage (not stackable), fire tears to enemies hit',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, next card costs 0 charge',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Calm, + 1 charge',
	},

	[10] = {
		Common = '(Not stackable) Swing num + 2, but 50% slower',
		Calm = '{{Battery}}{{3}} Fire 30 bouncing coin tears in random direction',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Calm',
	},

	[11] = {
		Common = 'Swing in 10% wider range; Grant Flight',
		Calm = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Wrath, teleport to a random enemy and swing',
		Wrath = '{{Battery}}{{3}} Ditto, may repeat for a while',
	},
	
	[12] = {
		Common = 'Isaac becomes 10% bigger (not stackable)',
		Calm = '{{Battery}}{{1}} Enter{{IBSSamsonWrath}} Wrath',
		Wrath = '{{Battery}}{{3}} Enter {{IBSSamsonWrath}}Wrath, gain {{Card12}}Strength effect, up to 2',
	},

	[13] = {
		Common = 'Grant flight',
		Calm = '{{Battery}}{{0}} Switch to the last card',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonWrath}}Wrath, switch to the last card',
	},

	[14] = {
		Common = 'While swinging, deal 13%{{Damage}}damage to all enemies in {{Range}}range',
		Calm = '{{Battery}}{{2}} Trigger {{Card14}}Death',
		Wrath = '{{Battery}}{{2}} Ditto',
	},

	[15] = {
		Common = 'Stopping swinging for 3s makes next swing in 25% wider range with 100% higher damage',
		Calm = '{{Battery}}{{0}} + 1 charge, + 4s cooldown',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Calm, + 1 charge, + 3s cooldown',
	},

	[16] = {
		Common = '(Not stackable) Swing applies brimestone mark, 33% slower; Enemies with brimestone mark take extra 66% damage',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, gain {{Card15}}The Devil effect',
	},

	[17] = {
		Common = 'Explosion immunity; Swing has 16% chance to explode when hitting enemies, 200%{{Damage}}damage ({{Luck}}Luck 17：50%)',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, and explode',
		Wrath = '{{Battery}}{{2}} Ditto',
	},

	[18] = {
		Common = '↑{{Luck}}Luck + 1;Swing deals extra 200%{{Luck}}luck damage, fire a tear with the same damage (Invalid when luck is below 1)',
		Calm = '{{Battery}}{{3}} Enter {{IBSSamsonWrath}}Wrath, + 1 {{Luck}}luck in the current level',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Calm',
	},

	[19] = {
		Common = 'Swing applies slowing, freezes enemies killed, 18% chance to directly freeze non-boss enemies ({{Luck}}41: 100%)',
		Calm = '{{Battery}}{{0}} Next swing freezes non-boss enemies',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[20] = {
		Common = 'Swing applies burning; Swing has 25% chance to fire a flame ({{Luck}}Luck 15: 100%)',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, fire flames around',
		Wrath = '{{Battery}}{{2}} Ditto',
	},

	[21] = {
		Common = 'Swing with 50% lower damage, enemies hit lose equal Hp, if below 20%, be killed instantly',
		Calm = '{{Battery}}{{0}} Enter {{IBSSamsonWrath}}Wrath, + 2s cooldown',
		Wrath = '{{Battery}}{{0}} Enter{{IBSSamsonCalm}}Calm, + 2s cooldown',
	},

	[22] = {
		Common = 'No effect',
		Calm = '{{Battery}}{{6}} Cosnume this card, spawn 5 other tarot cards',
		Wrath = '{{Battery}}{{6}} Ditto',
	},

	[56] = {
		Common = '↑ + 1 {{Damage}}dmg and {{Tears}}trans for each empty reversed tarot slot',
	},

	[57] = {
		Common = '↑ {{Damage}}dmg x 200%; !!! When taking penal damage, gain 1 mark in the current level; Each mark cause extra half a heart hurt',
	},

	[58] = {
		Common = 'Fire shockwaves after every 5 swing',
	},

	[59] = {
		Common = 'Disable double {{Damage}}dmg and hurt from {{IBSSamsonWrath}}Wrath',
	},
	
	[60] = {
		Common = 'Stackable shield from {{IBSSamsonCalm}}Calm, but with less 1s',
	},
	
	[61] = {
		Common = '{{IBSSamsonCalm}}Calm provides invincibility inserted of sheild',
	},

	[62] = {
		Common = '(Not stackable) Swing num - 2; Swing in 5% wider range with 20% higher damage for each kind of hearts',
	},

	[63] = {
		Common = 'Swing 60% faster when standing by',
	},

	[64] = {
		Common = '(Not stackable) Double charge from damage for {{Collectible'..(IBS_ItemID.Posture)..'}}Posture, but none form cleaning rooms anymore',
	},

	[65] = {
		Common = '↑ For each {{Coin}}coin, + 0.04 {{Damage}}dmg',
	},

	[66] = {
		Common = 'Before taking penal damage in {{IBSSamsonWrath}}Wrath, consume a random card instead; ↓If this one, - 1 {{Luck}}luck; ↑If another, + 0.25 {{Luck}}luck, and spawn the reversed version',
	},

	[67] = {
		Common = '↓ {{Damage}}dmg x 75% (not stackable); Swing applies weakness',
	},
	
	[68] = {
		Common = 'The first swing applies midas after changing rooms',
	},

	[69] = {
		Common = 'When taking penal damage in {{IBSSamsonWrath}}Wrath, do not lose cards anymore',
	},

	[70] = {
		Common = 'Infinite {{IBSSamsonWrath}}Wrath duration',
	},	

	[71] = {
		Common = ' Shield from {{IBSSamsonCalm}}Calm lasts 0.5s longer; Half {{IBSSamsonWrath}}Wrath duration (not stackable); When changing rooms, enter {{IBSSamsonCalm}}Calm and gain sheild',
	},

	[72] = {
		Common = 'Explosion heals Isaac',
	},	

	[73] = {
		Common = '↓ - 7 {{Luck}}luck; ↑ For each lost tarot, + 1 {{Luck}}luck; Enemies take extra 20% x {{Luck}}luck damage (absolute value)',
	},

	[74] = {
		Common = 'When changing rooms, enter {{IBSSamsonWrath}}Wrath',
	},

	[75] = {
		Common = '↑ When changing states, + 190% decaying {{Tears}}tears multiplier',
	},

	[76] = {
		Common = 'When entering {{IBSSamsonWrath}}Calm, lower a light pillar following Isaac (no hurt), not available if exists',
	},

	[77] = {
		Common = '↑ Automatically consume reversed tarot in other slots, + 0.5 {{Damage}}dmg and 21% {{Devil}}devil chance for each; Secret Exit keeps open',
	},

}

local BlessingOfMichaelEID = {

	[108] = 'Before taking damage, 25% chance to gain {{HalfSoulHeart}} Half Soul Heart',
	
	[313] = 'Gain an extra chance',
	
	[182] = '↑ {{Damage}}dmg x 140%',
	
	[331] = 'Enemies take extra 30% {{Damage}}Isaac\'s damage',
	
	[415] = 'When hurt or changing rooms, regain this item',
	
	[477] = 'Max-charge - 2',
	
	[643] = 'Every 2.5s, automatically fire beam with 50% damage but homing',
	
	[691] = 'When gained, remove items whose quality is below {{Quality2}} from pools',

}

--------------------------------------------------------

return {
	PlayerEID = playerEID,
	ItemEID = itemEID,
	TrinketEID = trinketEID,
	CardEID = cardEID,
	SlotEID = slotEID,
	
	HoardingEID = hoardingEID,
	BSamsonEID = BSamsonEID,
	BlessingOfMichaelEID = BlessingOfMichaelEID,
}