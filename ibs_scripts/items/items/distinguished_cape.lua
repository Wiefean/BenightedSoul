--卓越斗篷

local mod = Isaac_BenightedSoul
local Pools = mod.IBS_Lib.Pools
local IBS_CallbackID = mod.IBS_CallbackID
local AbandonedItem = mod.IBS_Effect.AbandonedItem
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local CapeSoul = mod.IBS_Familiar.CapeSoul

local DistinguishedCape = mod.IBS_Class.Item(mod.IBS_ItemID.DistinguishedCape)

--查找灵魂
function DistinguishedCape:FindSoul(player)
	local result = {}
	
	for _,ent in ipairs(Isaac.FindByType(CapeSoul.Type, CapeSoul.Variant, CapeSoul.SubType)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			table.insert(result, familiar)
		end	
	end
	
	return result
end

--补齐灵魂
function DistinguishedCape:RefillSoul(player, num)
	local soulNum = #self:FindSoul(player)
	
	if soulNum < num then
		for i = 1,num - soulNum do
			CapeSoul:Spawn(player)
		end
	end
end

--击杀灵魂
function DistinguishedCape:KillSoul(player)
	local souls = self:FindSoul(player)
	if #souls > 0 then
		local soul = souls[1]
		if soul then
			--死亡动画
			self._Ents:CopyAnimation(soul, soul.Position, 30, "LostDeath")
			soul:Remove()
			sfx:Play(217, 1, 2, false, 2)
			return true
		end
	end
	return false
end

--是否应该保护
function DistinguishedCape:ShouldProtect(player, flag, source)
	return Damage:CanHurtPlayer(player, flag, source)
end

--获得
function DistinguishedCape:OnGainItem(item, charge, first, slot, varData, player)
	local room = game:GetRoom()
	if first then
		self:RefillSoul(player, 3)
	end
end
DistinguishedCape:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', DistinguishedCape.ID)

--新层
function DistinguishedCape:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			self:RefillSoul(player, 3)
		end
	end
end
DistinguishedCape:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


--在即将受伤时生效
function DistinguishedCape:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end
	if not self:ShouldProtect(player, flag, source) then return end
	if not self:KillSoul(player) then return end
		
	player:SetMinDamageCooldown(30)

	return false
end
DistinguishedCape:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 1333, 'PrePlayerTakeDMG')

return DistinguishedCape