--模组兼容

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID
local IBS_SlotID = mod.IBS_SlotID
local Ents = mod.IBS_Lib.Ents
local Pools = mod.IBS_Lib.Pools

local game = Game()
local config = Isaac.GetItemConfig()

mod.IBS_Compat = {}
local IBS_Compat = mod.IBS_Compat

--时间机器(机器加速)
if tmmc then
	--使者是否加速同普通乞丐设置
	tmmc.enable[IBS_SlotID.Envoy.Variant] = tmmc.enable[4] or false
end

--GoodTrip
if gt then

--牺牲一些严谨性换来稳定性
function gt:pre_secret_room()
end

end

--东方幻想曲
do

IBS_Compat.THI = {}

--检查东方mod及其前置mod的开启情况
function IBS_Compat.THI:IsEnabled()
	if CuerLib and THI then
		return true
	end
	return false
end

--玩家是否使用正邪的增强道具方案
function IBS_Compat.THI:SeijaBuff(player)
	if self:IsEnabled() then
		return THI.Players.Seija:WillPlayerBuff(player)
	end
	return false
end

--玩家是否使用正邪的削弱道具方案
function IBS_Compat.THI:SeijaNerf(player)
	if self:IsEnabled() then
		return THI.Players.Seija:WillPlayerNerf(player)
	end
	return false
end

--获取里正邪等级
function IBS_Compat.THI:GetSeijaBLevel(player)
	if self:IsEnabled() then
		return THI.Players.SeijaB:GetUpgradeLevel(player)
	end
	return 0
end


--添加符文佩剑兼容
function IBS_Compat.THI:AddRuneSwordCompat(id, infoTbl)
	if not self:IsEnabled() then return end
	local Translations = CuerLib.Translations
	local RuneSword = THI.Collectibles.RuneSword
	local textKey = "#RUNE_SWORD_IBS"..infoTbl.textKey
	RuneSword:AddCustomRune(id, {TextKey = textKey, GfxFilename = infoTbl.png})
	Translations:SetText(THI, "zh", textKey.."_NAME", infoTbl.name.zh)
	Translations:SetText(THI, "zh", textKey.."_DESCRIPTION", infoTbl.desc.zh)
	Translations:SetText(THI, "en", textKey.."_NAME", infoTbl.name.en)
	Translations:SetText(THI, "en", textKey.."_DESCRIPTION", infoTbl.desc.en)
end
--[[
"infoTbl"举例:
{
	png = "gfx/ibs/items/pick ups/bisaac.png", --贴图路径
	textKey = "FALSEHOOD_BISAAC", --文本索引
	
	--名称
	name = {
		zh = "以撒的伪忆",
		en = "Falsehood of Isaac",
	},
	
	--描述
	desc = {
		zh = "更多选择 , 仅限二元",
		en = "More options, dualism only",
	}, 
}
]]


--上限骰相关
do
	local PlayerFields = {
		SelectedItem = "SelectedItem",
		MaxChargeAfterUse = "MaxChargeAfterUse",
		ChargesAfterUse = "ChargesAfterUse",
		Choice = "Choice",
		Page = "Page",
	}
	local TempPlayerFields = {
		UsedItem = "UsedItem",
		UsedItemSlot = "UsedItemSlot",
		UsedItemCharge = "UsedItemCharge",

		StateItem = "StateItem",    
		StateItemSlot = "StateItemSlot",
		StateItemCharge = "StateItemCharge",
		StateItemEffectNum = "StateItemEffectNum",

		HeldItem = "HeldItem",
		HeldItemSlot = "HeldItemSlot",
		HeldItemCharge = "HeldItemCharge",

		Sprites = "Sprites",

		UsedThisFrame = "UsedThisFrame",
	}	

	--尝试恢复上限骰
	function IBS_Compat.THI:TryRestoreDice(player, item, slot)
		if not self:IsEnabled() then return false end
		local Dice = THI.Collectibles.D2147483647
		local Data = {}

		local function GetPlayerField(player, ...)
			return Dice:GetPlayerField(player, ...)
		end
		local function SetPlayerField(player, value, ...)
			Dice:SetPlayerField(player, value, ...)
		end
		local function GetTempPlayerField(player, ...)
			return Dice:GetTempField(player, ...)
		end
		local function SetTempPlayerField(player, value, ...)
			Dice:SetTempField(player, value, ...)
		end

		function Data:ClearUsedItemData(player)
			SetTempPlayerField(player, nil, TempPlayerFields.UsedItem)
			SetTempPlayerField(player, nil, TempPlayerFields.UsedItemSlot)
			SetTempPlayerField(player, nil, TempPlayerFields.UsedItemCharge)
		end
		function Data:ClearHeldItemData(player)
			SetTempPlayerField(player, nil, TempPlayerFields.HeldItem)
			SetTempPlayerField(player, nil, TempPlayerFields.HeldItemSlot)
			SetTempPlayerField(player, nil, TempPlayerFields.HeldItemCharge)
		end
		function Data:ClearStateItemData(player)
			SetTempPlayerField(player, nil, TempPlayerFields.StateItem)
			SetTempPlayerField(player, nil, TempPlayerFields.StateItemSlot)
			SetTempPlayerField(player, nil, TempPlayerFields.StateItemCharge)
			SetTempPlayerField(player, nil, "StateItemHeldTime")
		end
		function Data:ClearTransformation(player)
			SetPlayerField(player, nil, PlayerFields.SelectedItem)
		end

		local selectedItem = GetPlayerField(player, PlayerFields.SelectedItem) or -1
		if selectedItem == item then
			local maxChargeAfterUse = GetPlayerField(player, PlayerFields.MaxChargeAfterUse) or 0
			local chargesAfterUse = GetPlayerField(player, PlayerFields.ChargesAfterUse) or 0
			local col = config:GetCollectible(item)
			if (col and col.Type == ItemType.ITEM_ACTIVE and col.ChargeType == ItemConfig.CHARGE_NORMAL) then
				chargesAfterUse = math.min(maxChargeAfterUse, chargesAfterUse + player:GetActiveCharge(slot))
			end
			player:RemoveCollectible(item, true, slot, true)
			player:AddCollectible(Dice.Item, chargesAfterUse, false, slot)
			Data:ClearTransformation(player)
			Data:ClearUsedItemData(player)
			Data:ClearStateItemData(player)
			Data:ClearHeldItemData(player)
			return true
		end
		
		return false
	end
	
end

--加载项
local THILoaded = false
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, function()
	if (not THILoaded) and mod.IBS_Compat.THI:IsEnabled() then
		THILoaded = true

		do --永乐大典
			local Yongle = mod.IBS_Item.Yongle
			Yongle.BlackList[THI.Collectibles.BookOfYears.Item] = true
		end

		do --镜像骰固定转换
			local d = THI.Collectibles.DFlip

			--圣饼<=>剩饼
			d:AddFixedPair(5,100,108, 5,100,IBS_ItemID.Waster)

			--钉子<=>备用钉子
			d:AddFixedPair(5,100,83, 5,100,IBS_ItemID.ReservedNail)
			
			--诅咒屏障<=>神圣屏障
			d:AddFixedPair(5,100,313, 5,100,IBS_ItemID.CursedMantle)

			--该隐祭品<=>亚伯祭品
			d:AddFixedPair(5,100,IBS_ItemID.Sacrifice, 5,100,IBS_ItemID.Sacrifice2)
			
			--未定义<=>已定义
			d:AddFixedPair(5,100,324, 5,100,IBS_ItemID.Defined)
			
			--发光的心<=>诅咒之心
			d:AddFixedPair(5,100,IBS_ItemID.GlowingHeart, 5,100,IBS_ItemID.CursedHeart)
			
			--规则卡<=>规则书
			d:AddFixedPair(5,300,44, 5,100,IBS_ItemID.RulesBook)
	
			--GHD<=>DHG
			d:AddFixedPair(5,100,IBS_ItemID.GHD, 5,100,IBS_ItemID.FGHD)
	
			--伤疤之秘<=>破碎之秘
			d:AddFixedPair(5,100,IBS_ItemID.Edge2, 5,100,IBS_ItemID.Edge3)
			
			--连锁挖掘<=>帘锁挖掘
			d:AddFixedPair(5,100,IBS_ItemID.VeinMiner, 5,100,IBS_ItemID.VainMiner)
			
			--盛装男孩<=>盛装教父
			d:AddFixedPair(5,100,141, 5,100,IBS_ItemID.PageantFather)
			
			--肉<=>剥落古老肉
			d:AddFixedPair(5,100,193, 5,100,IBS_ItemID.DeciduousMeat)
			
			--注射型圣水<=>诅咒针剂
			d:AddFixedPair(5,100,IBS_ItemID.HolyInjection, 5,100,IBS_ItemID.CurseSyringe)
			
			--禁断之果<=>夏娃的伪忆
			d:AddFixedPair(5,100,IBS_ItemID.ForbiddenFruit, 5,300,IBS_PocketID.BEve)
			
			--我果<=>我过
			d:AddFixedPair(5,100,IBS_ItemID.MyFruit, 5,100,IBS_ItemID.MyFault)
		end

		do --疾病道具
			table.insert(Pools.DiseaseItemList, THI.Collectibles.Asthma.Item)
			table.insert(Pools.DiseaseItemList, THI.Collectibles.ZombieInfestation.Item)
		end
		
		do --饥饿
			local Hunger = THI.Collectibles.Hunger
			Hunger:SetCollectibleHunger(IBS_ItemID.Waster, 2)
			Hunger:SetCollectibleHunger(IBS_ItemID.PurpleBubbles, 2)
			Hunger:SetCollectibleHunger(IBS_ItemID.DreggyPie, 10)
			Hunger:SetCollectibleHunger(IBS_ItemID.NeedleMushroom, 1)
			Hunger:SetCollectibleHunger(IBS_ItemID.ForbiddenFruit, 6)
			Hunger:SetCollectibleHunger(IBS_ItemID.Sacrifice, 5)
			Hunger:SetCollectibleHunger(IBS_ItemID.Sacrifice2, 10)
			Hunger:SetCollectibleHunger(IBS_ItemID.Ssstew, 6)
			Hunger:SetCollectibleHunger(IBS_ItemID.Bread, 5)
			Hunger:SetCollectibleHunger(IBS_ItemID.Alms, 3)
			Hunger:SetCollectibleHunger(IBS_ItemID.CheeseCutter, 3)
			Hunger:SetTrinketHunger(IBS_ItemID.LownTea, 3)
			Hunger:SetTrinketHunger(IBS_TrinketID.RabbitHead, 4)
			Hunger:SetTrinketHunger(IBS_TrinketID.WheatSeeds, 1)
			Hunger:SetTrinketHunger(IBS_TrinketID.Neopolitan, 2)
		end
		
		do --复印机
			local PortableCopier = THI.Collectibles.PortableCopier
			PortableCopier:AddPaperCollectible(IBS_ItemID.Blackjack)
			PortableCopier:AddPaperTrinket(IBS_TrinketID.PaperPenny)
		end
		
	end
end)


end

--东方拾遗
do
	mod.IBS_Compat.MGO = {}
	
	--检查mod及其前置mod的开启情况
	function IBS_Compat.MGO:IsEnabled()
		if CuerLib and THI and ReverieMGO then
			return true
		end
		return false
	end
	
	--加载项
	local MGOLoaded = false
	mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.IMPORTANT, function()
		if (not MGOLoaded) and mod.IBS_Compat.MGO:IsEnabled() then
			MGOLoaded = true
			
			do --冰霜充能球
				local FrostOrb = ReverieMGO.Collectibles.FrostOrb
				table.insert(FrostOrb.IceItems, IBS_ItemID.ChillMind)
			end
			
		end
	end)	

end


--EID
if EID then
	include("ibs_scripts.compats.EID.main")

	--设置模组名称
	if EID:getLanguage() == "zh_cn" then
		EID:setModIndicatorName("愚昧")
	else
		EID:setModIndicatorName("IBS")
	end

	--设置模组图标
	EID:setModIndicatorIcon("IBSMOD")
end


--缝纫机(跟班升级)
do
	IBS_Compat.Sewn = {}

	--让跟班可升级
	function IBS_Compat.Sewn:AddFamiliar(familiarClass, itemID, desc)
		if Sewn_API then
			local variant = familiarClass.Variant
			Sewn_API:MakeFamiliarAvailable(variant, itemID)
			Sewn_API:AddFamiliarDescription(
				 variant,
				 desc[1],
				 desc[2],
				 nil,
				 familiarClass.Name.zh,
				 'zh_cn'
			 )
			Sewn_API:AddFamiliarDescription(
				 variant,
				 desc[3],
				 desc[4],
				 nil,
				 familiarClass.Name.en,
				 'en_us'
			 )
		end
	end	

	--是否为黄冠
	function IBS_Compat.Sewn:IsSuper(familiar)
		if Sewn_API and Sewn_API:IsSuper(familiar:GetData()) then
			return true
		end
		return false
	end
	
	--是否为蓝冠
	function IBS_Compat.Sewn:IsUltra(familiar)
		if Sewn_API and Sewn_API:IsUltra(familiar:GetData()) then
			return true
		end
		return false
	end

	--皇冠位置修正
	function IBS_Compat.Sewn:SetCrownOffset(familiar, offset)
		if Sewn_API then
			familiar:GetData().Sewn_crownPositionOffset = offset
		end
	end
end


--好道具跳舞
do

local EpicLoaded = false
mod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, CallbackPriority.LATE, function()
	if (not EpicLoaded) and Epic then
	
		
		do
			local oldfunc = Epic.OnPogMoment or function()end
			function Epic:OnPogMoment(itemCount)
				local result = oldfunc(Epic, itemCount)

				--女疾女户兼容
				if #Isaac.FindByType(5,100,IBS_ItemID.Envy) > 0 then
					Epic:DoCostume(true)
					return true
				end
				
				return result
			end
		end
		
		--截图用具兼容
		do
			local oldfunc = Epic.DoCostume
			function Epic:DoCostume(apply)
				local result = oldfunc(Epic, apply)
				
				for i = 0, game:GetNumPlayers() - 1 do
					local player = Isaac.GetPlayer(i)
					if player:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B then
						--选用里该隐装扮
						local pogCostume = Isaac.GetCostumeIdByPath("the/specialist_t_cain.anm2")

						if pogCostume > 0 then
							if apply and player:HasTrinket(IBS_TrinketID.ForScreenshot) then
								player:AddNullCostume(pogCostume)

								--BGM
								local paincialist = Isaac.GetMusicIdByName("paincialist")
								if MusicManager():GetCurrentMusicID() ~= paincialist then
									MusicManager():Crossfade(paincialist, 1)
								end
							else
								player:TryRemoveNullCostume(pogCostume)
							end
						end
					end
				end
				
				return result
			end		
		end
		
		EpicLoaded = true
	end
end)
mod:AddCallback("PRE_CHECK_DANCE", function(_,pickup) --老鼠舞
    if pickup.SubType == IBS_ItemID.Envy then
		return 4
	end
end)


--截图用具兼容
local function OnGainTrinket(_,player)
	if Epic then
		local no = true
		for _,ent in ipairs(Isaac.FindByType(5,100)) do
			if ent.SubType > 0 then
				no = false
				break
			end
		end
		if not no then
			Epic:DoCostume(true)
		end			
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, OnGainTrinket, IBS_TrinketID.ForScreenshot)
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, OnGainTrinket, IBS_TrinketID.ForScreenshot+32768)

local function OnLoseTrinket(_,player)
	if Epic and not PlayerManager.AnyoneHasTrinket(IBS_TrinketID.ForScreenshot) then
		Epic:DoCostume(false)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, OnLoseTrinket, IBS_TrinketID.ForScreenshot)
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, OnLoseTrinket, IBS_TrinketID.ForScreenshot+32768)


end

