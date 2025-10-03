--店主的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BKeeper = mod.IBS_Class.Pocket(mod.IBS_PocketID.BKeeper)

--获取数据
function BKeeper:GetData()
	local data = self:GetIBSData('temp')
	data.FalsehoodBKeeper =  data.FalsehoodBKeeper or {Points = 0}
	return data.FalsehoodBKeeper
end

--记录乞丐捐赠
function BKeeper:OnBumDonation()
	local data = self:GetData()
	data.Points = data.Points + 1
end
BKeeper:AddCallback(mod.IBS_CallbackID.BUM_DONATION, 'OnBumDonation')

--效果
function BKeeper:OnUse(card, player, flag)
	local data = self:GetData()
	local times = math.min(20, math.floor(data.Points / 3))
	if times <= 0 then return end
	local room = game:GetRoom()

	for i = 1,times do
		local int = player:GetCardRNG(card):RandomInt(100)
		local variant,subType = 20,4 --55%双硬币
		
		if int >= 50 and int < 55 then
			subType = 5 --5%幸运币
		elseif int >= 40 and int < 50 then
			variant,subType = 30,1 --10%钥匙
		elseif int >= 30 and int < 40 then
			variant,subType = 40,1 --10%炸弹
		elseif int >= 20 and int < 30 then
			variant,subType = 10,3 --10%魂心
		elseif int >= 10 and int < 20 then
			variant,subType = 10,5 --10%双红心
		elseif int >= 0 and int < 10 then
			variant,subType = 300,53 --10%先祖召唤
		end

		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(5, variant, subType, pos, Vector.Zero, nil)			
	end
end
BKeeper:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BKeeper.ID)


--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BKeeper.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bkeeper.png",
		textKey = "FALSEHOOD_BKEEPER",
		name = {
			zh = "店主的伪忆",
			en = "Falsehood of the Keeper",
		},
		desc = {
			zh = "慷慨之魂",
			en = "Soul of Generosity",
		}, 
	})
	
	--实际效果判定在\scripts\items\items\generosity_soul.lua
end


return BKeeper