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
		[IBS_Player.bjudas]="返还",
		[IBS_Player.bcain]="你在哪 ?",
		[IBS_Player.babel]="在你那",
	},
	[IBS_Item.ld6]={
		Name="光辉六面骰",
		Desc="权衡你的命运"
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

	[IBS_Item.hypercube]={
		Name="超立方",
		Desc="复制你的命运"
	},

	[IBS_Item.defined]={
		Name="已定义",
		Desc="旅途愉快"
	},
	
	[IBS_Item.chocolate]={
		Name="瓦伦丁巧克力",
		Desc="双击友好 , 每房间两次机会"
	},
	
	[IBS_Item.diamoond]={
		Name="钻石",
		Desc="超月燃"
	},	

	[IBS_Item.cranium]={
		Name="奇怪的头骨",
		Desc="似曾相识"
	},

	[IBS_Item.ether]={
		Name="以太之云",
		Desc="复仇飞行"
	},

	[IBS_Item.wisper]={
		Name="魂火之灵",
		Desc="魂火们"
	},

	[IBS_Item.bone]={
		Name="节制之骨",
		Desc="愿你保持节制"
	},

	[IBS_Item.guard]={
		Name="坚韧面罩",
		Desc="愿你勇往直前"
	},

	[IBS_Item.v7]={
		Name="美德七面骰",
		Desc="随机的美德"
	},

	[IBS_Item.tgoj]={
		Name="犹大福音",
		Desc="救赎之道 , 自在其中"
	},
	
	[IBS_Item.nail]={
		Name="备用钉子",
		Desc="钉好他们"
	},
	
	[IBS_Item.superb]={
		Name="核能电罐",
		Desc="充能有风险 , 但是管他呢"
	},
	
	[IBS_Item.dreggypie]={
		Name="掉渣饼",
		Desc="体力上升 + 暂时性射速上升 , 搭配红豆汤风味更佳"
	},
	
	[IBS_Item.bonyknife]={
		Name="骨刀",
		Desc="刀他们的骨"
	},
	
	[IBS_Item.circumcision]={
		Name="割礼",
		Desc="移速下降 + 射速和幸运上升"
	},
	
	[IBS_Item.cheart]={
		Name="诅咒之心",
		Desc="诅咒提升"
	},
	
	[IBS_Item.redeath]={
		Name="死亡回放",
		Desc="重置已逝...暂时"
	},
	
	[IBS_Item.dustybomb]={
		Name="尘埃炸弹",
		Desc="第三次爆炸..."
	},
	
	[IBS_Item.nm]={
		Name="金针菇",
		Desc="明天见"
	},
	
	[IBS_Item.minihorn]={
		Name="小小角恶魔",
		Desc="限量款"
	},
	
	[IBS_Item.woa]={
		Name="亚波伦之翼",
		Desc="弹速上升 = 全属性上升"
	},
	
	[IBS_Item.momscheque]={
		Name="妈妈的支票",
		Desc="分期付款"
	},
	
	[IBS_Item.ffruit]={
		Name="禁断之果",
		Desc="原罪"
	},
	
	[IBS_Item.sword]={
		Name="紫电护主之刃",
		Desc="又见面了 , 老伙计"
	},

	[IBS_Item.regret]={
		Name="死不瞑目",
		Desc="杀死你也会让你更强大"
	},
	
	[IBS_Item.sacrifice]={
		Name="不受欢迎的祭品",
		Desc="事实证明 , 上帝不是吃素的"
	},
	
	[IBS_Item.sacrifice2]={
		Name="受欢迎的祭品",
		Desc="致命盛宴"
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

	[IBS_Trinket.divineretaliation]={
		Name="神圣反击",
		Desc="弹火"
	},

	[IBS_Trinket.toughheart]={
		Name="硬的心",
		Desc="抵挡伤害...总会有效"
	},
	
	[IBS_Trinket.chaoticbelief]={
		Name="混沌信仰",
		Desc="信仰提升 ?"
	},
	
	[IBS_Trinket.thronyring]={
		Name="荆棘指环",
		Desc="最后之作"
	},

},

--口袋物品(不包含药丸)
Pocket = {
	[IBS_Pocket.czd6]={
		Name="六面骰黄金典藏版",
		Desc="Cu + Zn"
	},
	[IBS_Pocket.goldenprayer]={
		Name="金色祈者",
		Desc="祈祷 , 为人与和平"
	},


	[IBS_Pocket.falsehood_bisaac]={
		Name="以撒的伪忆",
		Desc="骰符 「二元平衡」"
	},
	[IBS_Pocket.falsehood_bmaggy]={
		Name="抹大拉的伪忆",
		Desc="圣符 「石破天惊」"
	},
	
	[IBS_Pocket.falsehood_bjudas]={
		Name="犹大的伪忆",
		Desc="死符 「灯熄枪响」"
	},

	
	
},

--Boss替换提醒
BossReplaced = {
	["Temperance"]={
		Title="暴食有些不对劲 ?",
		Sub="节制 !"
	},

	["Fortitude"]={
		Title="愤怒有些不对劲 ?",
		Sub="坚韧 !"
	},

},

--镜子提示
MirrorTip = {
	["Isaac"]={
		Title="给以撒的秘语",
		Sub="被撒旦夺走生命后 , 再将生命夺回"
	},

	["Magdalene"]={
		Title="给抹大拉的秘语",
		Sub="不惜生命为上帝献祭 , 之后不断磨炼自己的意志"
	},
	
	["Cain"]={
		Title="给该隐的秘语",
		Sub="以你为祭 , 墓地 , 以兄为弟"
	},
	
	["Judas"]={
		Title="给犹大的秘语",
		Sub="终结玻璃里的伪装者"
	},
	
	
},

}


--英文
Translations["en"] = {

--Boss替换提醒
BossReplaced = {
	["Temperance"]={
		Title="Gluttony ?",
		Sub="Temperance !"
	},

	["Fortitude"]={
		Title="Wrath ?",
		Sub="Fortitude !"
	}

},

--镜子提示
MirrorTip = {
	["Isaac"]={
		Title="For Isaac",
		Sub="Satan takes your life away, you kick back"
	},

	["Magdalene"]={
		Title="For Magdalene",
		Sub="Sacrifice your life for God, then keep honing your will"
	},
	
	["Cain"]={
		Title="For Cain",
		Sub="Be in sacrifice , be in graveyard , be in brother"
	},
	
	["Judas"]={
		Title="For Judas",
		Sub="End the personator in the glass"
	},
	
},

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