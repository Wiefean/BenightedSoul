--该隐的祭品

local mod = Isaac_BenightedSoul

local BigLight = mod.IBS_Effect.BigLight
local Sacrifice = mod.IBS_Class.Item(mod.IBS_ItemID.Sacrifice)


--使用
function Sacrifice:OnUse(item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then --拒绝车载电池
		local GameData = self:GetIBSData('temp')
		local dmg = math.max(2.45, 0.7*(player.Damage))
		local scale = 2
		local hurtPlayer = true
		local followEnemy = false
		local followPlayer = false
		local timeout = 135
		
		--彼列书
		if player:HasCollectible(59) then
			scale = 3
			followPlayer = true
		end
		
		--美德书
		if player:HasCollectible(584) then
			hurtPlayer = false
			followEnemy = true
		end
		
		--车载电池
		if player:HasCollectible(356) then
			timeout = 210
		end

		--检测亚伯祭品是否使用过
		if GameData.welcomSacrificeUsed then
			hurtPlayer = false
			followEnemy = true
		end
		
		--生成光柱
		BigLight:Spawn(player, dmg, scale, hurtPlayer, followEnemy, followPlayer, timeout)
		
		--记录该隐祭品已使用
		GameData.unwelcomSacrificeUsed = true
		
		return true
	end
end
Sacrifice:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Sacrifice.ID)



return Sacrifice
