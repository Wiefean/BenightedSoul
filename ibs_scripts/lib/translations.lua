--翻译

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Player = mod.IBS_Player
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Pocket = mod.IBS_Pocket

local LANG = Options.Language
if LANG ~= "zh" then LANG = "en" end

local Translations = {}

--中文
Translations["zh"] = {

--道具(包含长子权)
Item = {
	[CollectibleType.COLLECTIBLE_BIRTHRIGHT]={
		["Name"]="长子名分",
		[IBS_Player.bisaac]="飞升",
		[IBS_Player.bmaggy]="更快变硬",
	},
	[IBS_Item.ld6]={
		Name="光辉六面骰",
		Desc="平衡你的命运"
	},

	[IBS_Item.nop]={
		Name="拒绝选择",
		Desc="小孩子的选择"
	},

	[IBS_Item.d4d]={
		Name="四维骰",
		Desc="掌握你的命运",
	},

	[IBS_Item.ssg]={
		Name="仰望星空",
		Desc="双击观星"
	},

	[IBS_Item.waster]={
		Name="剩饼",
		Desc="残余的守护"
	},

	[IBS_Item.envy]={
		Name="女疾女户",
		Desc="你好"
	},

	[IBS_Item.gheart]={
		Name="发光的心",
		Desc="充能型体力回复"
	},

	[IBS_Item.pb]={
		Name="紫色泡泡水",
		Desc="再喝 !"
	},

	[IBS_Item.cmantle]={
		Name="诅咒屏障",
		Desc="绑定诅咒 + 防御反击"
	},

},

--饰品
Trinket = {
	[IBS_Trinket.bottleshard]={
		Name="酒瓶碎片",
		Desc="他离开前干的"
	},

	[IBS_Trinket.dadspromise]={
		Name="爸爸的约定",
		Desc="旧约的结束是新约的开始"
	},

},

--口袋物品(不包含药丸)
Pocket = {
	[IBS_Pocket.czd6]={
		Name=" 六面骰黄金典藏版",
		Desc="Cu + Zn"
	},

},

--Boss替换提醒
BossReplaced = {
	["Temperance"]={
		Title="暴食有些不对劲 ?",
		Sub="节制 !"
	}

},

}


--英文
Translations["en"] = {

BossReplaced = {
	["Temperance"]={
		Title="Gluttony ?",
		Sub="Temperance !"
	}

}

}


----翻译器开始----

--道具
local function Translation_Item(_,player, item)
    if Translations[LANG] and Translations[LANG].Item then
		local info = Translations[LANG].Item[item]	
		if info then
			if item == CollectibleType.COLLECTIBLE_BIRTHRIGHT then --长子权
				local playerType = player:GetPlayerType()
				local desc = info[playerType]
				if desc then
					Game():GetHUD():ShowItemText(info.Name, desc)
				end
			else
				Game():GetHUD():ShowItemText(info.Name, info.Desc)
			end
		end
	end
end
mod:AddCallback(IBS_Callback.PICK_COLLECTIBLE, Translation_Item)

--饰品
local function Translation_Trinket(_,player, trinket)
    if Translations[LANG] and Translations[LANG].Trinket then
		local info = Translations[LANG].Trinket[trinket]
		if info then
			Game():GetHUD():ShowItemText(info.Name, info.Desc)
		end
	end	
end
mod:AddCallback(IBS_Callback.PICK_TRINKET, Translation_Trinket)

--口袋物品(不包含药丸)
local function Translation_Pocket(_,player, card)
    if Translations[LANG] and Translations[LANG].Pocket then
		local info = Translations[LANG].Pocket[card]
		if info then
			Game():GetHUD():ShowItemText(info.Name, info.Desc)
		end
	end
end
mod:AddCallback(IBS_Callback.PICK_CARD, Translation_Pocket)

----翻译器结束----



return Translations