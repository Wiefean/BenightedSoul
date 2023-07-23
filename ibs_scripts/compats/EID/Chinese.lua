--中文

--[[说明书:
新增介绍按格式填入对应表即可
]]

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Pocket = mod.IBS_Pocket
local IBS_Player = mod.IBS_Player

local LANG = "zh_cn"

--为特定角色展示实体的额外内容--
--[[输入:名称(字符串),内容(表),实体大类,实体类]]
local function EID_ContentForPlayer(name,content,T,V)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
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

	--添加额外内容
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
----

--为贪婪模式展示实体的额外内容--
--[[输入:名称(字符串),内容(表),实体大类,实体类]]
local function EID_ContentForGreed(name,content,T,V)

	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType		
	
		--检查语言
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
	
	--添加额外内容
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
----

--------------------------------------------------------
-----------------------角色长子权-----------------------
--------------------------------------------------------
EID:addBirthright(IBS_Player.bisaac, "飞行#恶魔/天使房中道具选择 + 1", "昧化以撒", LANG)
EID:addBirthright(IBS_Player.bmaggy, "进入新房间或贪婪新波次，坚贞之心恢复量翻倍", "昧化抹大拉", LANG)

--------------------------------------------------------
--------------------------道具--------------------------
--------------------------------------------------------
local itemEID={

[IBS_Item.ld6]={
	name="光辉六面骰",
	info="无需满充能即可使用"..
		 "#以房间内道具平均品质重置道具"..
		 "#消耗的充能由平均品质决定:"..
		 "#{{Quality0}} 及以下: 0"..
		 "#{{Quality1}} : 1"..
		 "#{{Quality2}} : 3"..
		 "#{{Quality3}} : 4"..
		 "#{{Quality4}} 及以上 : 6",
	virtue="内层魂火，概率发射圣光眼泪#每重置1个道具额外生成1魂火",
	belial="品质可能上下浮动"	
},

[IBS_Item.nop]={
	name="拒绝选择",
	info="不再单选物品",
	player={
		[PlayerType.PLAYER_THELOST]="若场上只有{{Player10}}或{{Player31}}，恶魔交易免费",
		[PlayerType.PLAYER_THELOST_B]="若场上只有{{Player10}}或{{Player31}}，恶魔交易免费",
		[PlayerType.PLAYER_JACOB] = "额外获得{{Collectible249}}",
		[PlayerType.PLAYER_ESAU] = "额外获得{{Collectible414}}"
	}
},

[IBS_Item.d4d]={
	name="四维骰",
	info="以相对方位改变离角色最近道具的ID#左加;右减;上翻倍;下减半",
	virtue="4个外层魂火，不发射眼泪",
	belial="没有对应道具时，以{{Collectible51}}五芒星代替"
},

[IBS_Item.ssg]={
	name="仰望星空",
	info="双击发射一颗特殊眼泪，命中目标时生成落泪区"..
		 "#4秒冷却"
},

[IBS_Item.waster]={
	name="剩饼",
	info="即将受伤时，25%概率获得{{HalfSoulHeart}}半魂心，之后在本房间获得{{Collectible108}}圣饼效果"
},

[IBS_Item.envy]={
	name="女疾女户",
	info="↓ {{Speed}}移速 - 0.15#"..
		 "#↓ {{Tears}}射速修正 - 0.06"..
		 "#↑ {{Damage}}伤害 + 1"..
		 "#6%概率替换之后的道具(可叠加，最多60%)"
},

[IBS_Item.gheart]={
	name="发光的心",
	info="在清理房间后充能"..
		 "#移除1个{{BrokenHeart}}碎心，若没有，获得1{{SoulHeart}}魂心",
	virtue="内层魂火，概率发射圣光眼泪",
	greed="贪婪模式:波次开始时也会充能",
	belial="无{{BrokenHeart}}碎心时，效果改为获得1{{BlackHeart}}黑心",
	player={[IBS_Player.bmaggy]="同时恢复25可超上限的坚贞之心(切换房间后移除超出上限部分)"}
},

[IBS_Item.pb]={
	name="紫色泡泡水",
	info="随机获得一项以下效果:"..
		 "#↓ {{Speed}}移速 - 0.02"..
		 "#↑ {{Tears}}射速修正 + 0.06"..
		 "#↑ {{Damage}}伤害 + 0.1"..
		 "#↑ {{Range}}射程 + 0.15"..
		 "#↓ {{Shotspeed}}弹速 -0.03"..
		 "#丢弃该道具后，在下一层重置属性变动"..
		 "#使用24次之后，不会重置",
	virtue="内层魂火，概率发射眩晕眼泪",
	belial="无特殊效果",		 
},

[IBS_Item.cmantle]={
	name="诅咒屏障",
	info="强占主动槽，除非持有{{Collectible260}}黑蜡烛或{{Collectible584}}美德之书"..
		 "#直接使用无效果"..
		 "#即将受伤时，消耗2充能，免疫伤害，并进入影遁状态",
	virtue="每用影遁杀死一个敌人生成一个单房间魂火#阻止该道具强占主动槽",
	belial="无特殊效果",
	player={[PlayerType.PLAYER_JUDAS_B]="影遁同样会给予{{Damage}}伤害提升"}

},

[IBS_Item.hypercube]={
	name="超立方",
	info="无记录时，记录距离最近的道具，并将其移出道具池"..
		 "#已有记录时，将房间内的道具重置为记录的道具"..
		 "#所有{{Collectible"..(IBS_Item.hypercube).."}}".."超立方共享记录",
	virtue="外层魂火，发射追踪眼泪",
	belial="无特殊效果"
},

[IBS_Item.defined]={
	name="已定义",
	info="无需满充能即可使用"..
		 "#传送至选定类型的房间"..
		 "#双击 "..EID.ButtonToIconMap[ButtonAction.ACTION_MAP].." 地图键以切换类型",
	virtue="无魂火#充能消耗 - 1",
	belial="充能消耗 - 1",
},

[IBS_Item.chocolate]={
	name="瓦伦丁巧克力",
	info="{{SoulHeart}} 魂心 + 2"..
		 "#双击发射一颗特殊眼泪，将命中的非Boss敌人变为友好状态，但其生命减半"..
		 "#两次机会，进入新房间重置"
},

[IBS_Item.diamoond]={
	name="钻石",
	info="{{Burning}} 33%火焰眼泪"..
		 "#{{Slow}} 33%减速眼泪"..
		 "#{{Luck}} 幸运不会影响概率"..
		 "#{{Freezing}} 冰冻同时被点燃和减速的非Boss敌人"
},

[IBS_Item.cranium]={
	name="奇怪的头骨",
	info="进入新层时，角色获得{{Player10}}游魂诅咒"..
		 "#完成{{BossRoom}}Boss房后，获得3{{BlackHeart}}黑心，并在下一个房间恢复"
},

[IBS_Item.ether]={
	name="以太之云",
	info="受伤后在本房间获得飞行，并降下圣光"..
		 "#圣光造成角色伤害的2倍穿甲伤害"..
		 "#圣光降落频率随角色在本房间的受伤次数递增",
	trans={"LEVIATHAN", "ANGEL"}
},

[IBS_Item.wisper]={
	name="魂火之灵",
	info="抵挡敌弹的环绕物跟班"..
		 "#造成角色伤害3倍的碰撞伤害"..
		 "#击杀敌人有30%概率生成普通魂火({{Luck}}幸运7:100%)",
	trans={"ANGEL"}
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
EID_ContentForGreed("ibsItemForGreed", itemEID, 5,100)

do --D4D
	
	--比列书
	local function Belial()
		for i = 0, Game():GetNumPlayers(0) - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(59) then
				return true
			end
		end
		return false
	end
	
	--ID转EID贴图
	local function ToIcon(id)
		local MAX = Isaac.GetItemConfig():GetCollectibles().Size
		local icon = id
		
		id = math.floor(id+0.5) --四舍五入
		if id > 0 and id < MAX then
			id = tostring(id)
			icon = "{{Collectible"..id.."}}"
		elseif Belial() then
			icon = "{{Collectible51}}"
		else
			icon = "无"
		end
		
		return icon
	end
	
	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
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

	--添加额外内容
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

do --虚空/无底坑增强
	
	--索引
	local ToKey = {
		[477] = "voidUp",
		[706] = "abyssUp"
	}
	
	--触发条件
	local function condition(desc)
		local Type = desc.ObjType
		local Variant = desc.ObjVariant
		local SubType = desc.ObjSubType	
	
		--检查语言
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

	--添加额外内容
	local function callback(desc)
		local id = desc.ObjSubType
		local add = "#{{ColorGold}}对饰品生效{{CR}}"
					
		EID:appendToDescription(desc, add)
		
		return desc
	end
	EID:addDescriptionModifier("ibsVoidAbyssUp".."_"..LANG, condition, callback)
end
--------------------------------------------------------
--------------------------饰品--------------------------
--------------------------------------------------------
local trinketEID={

[IBS_Trinket.bottleshard]={
	name="酒瓶碎片",
	info="10%概率令受伤的敌人额外受到3点伤害，并进入流血状态",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.dadspromise]={
	name="爸爸的约定",
	info="{{BossRoom}} 在进入新层后的45 + 15x楼层数秒内完成Boss房，生成1个{{Card49}}骰子碎片",
	mult={findReplace = {"15","20","25"}}	
},

[IBS_Trinket.divineretaliation]={
	name="神圣反击",
	info="10%概率免疫泪弹伤害#被泪弹击中时，将周围的所有泪弹变为火焰",
	mult={
		numberToMultiply = 10,
		maxMultiplier = 3,
	}	
},

[IBS_Trinket.toughheart]={
	name="硬的心",
	info="10%概率免疫伤害#受伤时，免伤概率增加15%，直到下一次免伤#对自伤无效",
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
--------------------------卡牌--------------------------
--------------------------------------------------------
local cardEID={

[IBS_Pocket.czd6] = {
	name="六面骰黄金典藏版",
	info="重置道具#90%不消失，每使用一次概率降低10%(影响持续一整局)"
},

[IBS_Pocket.goldenprayer] = {
	name="金色祈者",
	info="获得30不可恢复的坚贞之心#消耗后，完成下一个{{BossRoom}}Boss房会再次生成该卡牌",
	mimic={charge = 6, isRune = false},
	player={[IBS_Player.bmaggy]="效果改为恢复30可超上限的坚贞之心(切换房间后移除超出上限部分)"}
},

}


for id,card in pairs(cardEID) do
	EID:addCard(id, card.info, card.name, LANG)
	
	if card.mimic then
		EID:addCardMetadata(id, card.mimic.charge, card.mimic.isRune)
	end	
end
EID_ContentForPlayer("ibsCardForPlayer", cardEID, 5,300)

