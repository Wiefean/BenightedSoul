--English

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Pocket = mod.IBS_Pocket
local IBS_Player = mod.IBS_Player

local LANG = "en_us"

local function EID_ContentForPlayer(name,content,T,V)
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		if EID:getLanguage() ~= LANG then
			return false
		end
		
		if (Type == T) and (Variant == V) and content[SubType] then
			if content[SubType].player then
				return true
			end	
		end
			
		return false
	end

	local function callback(desc)
		local SubType = desc.ObjSubType
		
		for i = 0, Game():GetNumPlayers(0) - 1 do
			local playerType = Isaac.GetPlayer(i):GetPlayerType()
			local text = content[SubType].player[playerType]
			
			if text then
				local add = "#{{Player"..playerType.."}} "..text
				EID:appendToDescription(desc, add)
			end
		end	

		return desc
	end
	EID:addDescriptionModifier(name.."_"..LANG, condition, callback)
end

local function EID_ContentForGreed(name,content,T,V)
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType		
	
		if EID:getLanguage() ~= LANG then
			return false
		end

		if Game():IsGreedMode() then
			if (Type == T) and (Variant == V) and content[SubType] then
				if content[SubType].greed then
					return true
				end	
			end
		end

		return false
	end

	local function callback(desc)
		local SubType = desc.ObjSubType
		local text = content[SubType].greed
		
		if text then
			local add = "#{{GreedMode}} "..text
			EID:appendToDescription(desc, add)
		end
		
		return desc
	end
	EID:addDescriptionModifier(name.."_"..LANG, condition, callback)
end

--------------------------------------------------------
-----------------------Birthright-----------------------
--------------------------------------------------------
EID:addBirthright(IBS_Player.bisaac, "Grants flight#There are more options in devil/angel room", "Benighted Isaac", LANG)
EID:addBirthright(IBS_Player.bmaggy, "Doubles iron heart recovery when entering a new room or a new greed wave", "Benighted Magdalene", LANG)

--------------------------------------------------------
-------------------------Item---------------------------
--------------------------------------------------------
local itemEID={

[IBS_Item.ld6]={
	name="The Light D6",
	info="Can be used without full charge"..
		 "#Rerolls items with their average quality in the current room"..
		 "Costs charges:"..
		 "#{{Quality0}} and below: 0"..
		 "#{{Quality1}} : 1"..
		 "#{{Quality2}} : 3"..
		 "#{{Quality3}} : 4"..
		 "#{{Quality4}} and above : 6",
	virtue="Wisps that sometimes shoot holy tears#Spawns an extra wisp per rerolled item",
	belial="The quality maybe changed a bit"
},

[IBS_Item.nop]={
	name="No Options",
	info="No optional items",
	player={
		[PlayerType.PLAYER_THELOST]="If there's only {{Player10}}or{{Player31}},free devil deals",
		[PlayerType.PLAYER_THELOST_B]="If there's only {{Player10}}or{{Player31}},free devil deals",
		[PlayerType.PLAYER_JACOB] = "Grants{{Collectible249}}",
		[PlayerType.PLAYER_ESAU] = "Grants{{Collectible414}}"		
	}	
},

[IBS_Item.d4d]={
	name="D4D",
	info="Changes the ID of an item closest to Isaac with relative direction"..
		 "#Left +1 ; Right -1;"..
		 "Up x2 ; Down /2",
	virtue="4 wisps that do not shoot tears",
	belial="Replaces the item with{{Collectible51}} if no corresponding ID"
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
	info="Changed by cleaning rooms"..
		 "#-1{{BrokenHeart}}, if not, +1{{SoulHeart}}",
	virtue="Wisps that sometimes shoot holy tears",
	belial="if no{{BrokenHeart}}, instead, +1{{BlackHeart}}",
	player={[IBS_Player.bmaggy]="+25 iron hearts"}
},

[IBS_Item.pb]={
	name="Purple Bubbles",
	info="Randomly grants:"..
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
	info="Occupies the first active slot，unless holding{{Collectible260}}or{{Collectible584}}"..
		 "#Automatically used and costs 2 charges before taking damage, Isaac will negate it and then begin shadow running",
	virtue="Single room wisp per enemy killed by shadow running#Prevents occupying",
	belial="No special effect",
	player={[PlayerType.PLAYER_JUDAS_B]="Shadow running also grants{{Damage}}"}

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
		 "#{{Freezing}} Freezes a normal enemy that is both burning and slowing"
},

[IBS_Item.cranium]={
	name="Weird Cranium",
	info="Isaac gets lost curse in a new level"..
		 "#After finishing{{BossRoom}}boss room, + 3 {{BlackHeart}} and then removes lost curse"
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
	info="Spawns one of friendly bosses below："..
		 "#Temperance"..
		 "#Fortitude",
	virtue="Common wisps",
	belial="No special effect",		 
},

[IBS_Item.tgoj]={
	name="The Gospel Of Judas",
	info="Discharges gradually, and absorbs projectiles around"..
		 "#Enough absorption, spawns crack of{{Collectible634}}",
	virtue="Enough absorption, spawns a wisp",
	belial="Grants{{Damage}}DMG up for a projectile absorbed",
	trans={"BOOKWORM"}
},

}

for id,item in pairs(itemEID) do
	EID:addCollectible(id, item.info, item.name, LANG)
	
	if item.virtue and EID.descriptions[LANG].bookOfVirtuesWisps then
		EID.descriptions[LANG].bookOfVirtuesWisps[id] = item.virtue
	end
	
	if item.belial and EID.descriptions[LANG].bookOfBelialBuffs then
		EID.descriptions[LANG].bookOfBelialBuffs[id] = item.belial
	end
	
	if item.trans then
		for _, t in pairs(item.trans) do
			EID:assignTransformation("collectible", id, EID.TRANSFORMATION[t])
		end
	end
	
end
EID_ContentForPlayer("ibsItemForPlayer", itemEID, 5,100)

do --D4D
	local function Belial()
		for i = 0, Game():GetNumPlayers(0) - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(59) then
				return true
			end
		end
		return false
	end
	
	local function ToIcon(id)
		local MAX = Isaac.GetItemConfig():GetCollectibles().Size
		local icon = id
		
		id = math.floor(id+0.5)
		if id > 0 and id < MAX then
			id = tostring(id)
			icon = "{{Collectible"..id.."}}"
		elseif Belial() then
			icon = "{{Collectible51}}"
		else
			icon = "N/A"
		end
		
		return icon
	end
	
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		if EID:getLanguage() ~= LANG then
			return false
		end
		
		if (Type == 5) and (Variant == 100) and (SubType > 0) then
			for i = 0, Game():GetNumPlayers(0) - 1 do
				local player = Isaac.GetPlayer(i)
				if player:HasCollectible(IBS_Item.d4d) then
					return true
				end
			end
		end
			
		return false
	end

	local function callback(desc)
		local id = desc.ObjSubType
		local col1 = ToIcon(id+1)
		local col2 = ToIcon(id-1)
		local col3 = ToIcon(id*2)
		local col4 = ToIcon(id/2)
		local L = "{{ButtonDLeft}}"
		local R = "{{ButtonDRight}}"
		local U = "{{ButtonDUp}}"
		local D = "{{ButtonDDown}}"
		
		local add = "#{{Collectible"..IBS_Item.d4d.."}} "..
					L..col1..";"..R..col2..";"..U..col3..";"..D..col4
					
		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier("ibsD4D".."_"..LANG, condition, callback)
end	

do --void/abyss up
	local ToKey = {
		[477] = "voidUp",
		[706] = "abyssUp"
	}
	
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		if EID:getLanguage() ~= LANG then
			return false
		end
		
		if (Type == 5) and (Variant == 100) and (SubType == 477 or SubType == 706) then
			if IBS_Data.Setting[ToKey[SubType]] then
				return true
			end	
		end
			
		return false
	end

	local function callback(desc)
		local id = desc.ObjSubType
		local add = "#{{ColorGold}}Available to trinkets{{CR}}"
					
		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier("ibsVoidAbyssUp".."_"..LANG, condition, callback)
end
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


}

for id,trinket in pairs(trinketEID) do
	EID:addTrinket(id, trinket.info, trinket.name, LANG)
	
	if trinket.mult then
		if trinket.mult.findReplace and (EID.GoldenTrinketData and EID.descriptions[LANG].goldenTrinketEffects) then
			EID.GoldenTrinketData[id] = {findReplace = true}
			EID.descriptions[LANG].goldenTrinketEffects[id] = trinket.mult.findReplace
		else
			local append = trinket.mult.append or nil
			local numberToMultiply = trinket.mult.numberToMultiply or 1
			local maxMultiplier = trinket.mult.maxMultiplier or 3
			EID:addGoldenTrinketMetadata(id, append, numberToMultiply, maxMultiplier, LANG)
		end
	end
	
end
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

}


for id,card in pairs(cardEID) do
	EID:addCard(id, card.info, card.name, LANG)
	
	if card.mimic then
		EID:addCardMetadata(id, card.mimic.charge, card.mimic.isRune)
	end	
end