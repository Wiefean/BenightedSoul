--促销炸弹

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local game = Game()
local sfx = SFXManager()

local SaleBomb = mod.IBS_Class.Item(mod.IBS_ItemID.SaleBomb)

--减少物品价格
function SaleBomb:DoSale(pos, radius, player)
	for _,ent in ipairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup and pickup.Price > 0 and pickup.Position:Distance(pos) ^ 2 < radius ^ 2 then
			pickup.AutoUpdatePrice = false
			
			--减价格并生成硬币
			local times = (player and player:GetCollectibleRNG(self.ID):RandomInt(1,2)) or 1
			for i = 1,times do			
				pickup.Price = pickup.Price - 1
				Isaac.Spawn(5, 20, 0, pickup.Position, 2*RandomVector(), nil)
				if pickup.Price <= 0 then pickup.Price = -1000 end --零元购
			end
		end
	end
end

--玩家炸弹爆炸
function SaleBomb:OnBombUpdate(bomb)
	if bomb:IsDead() then	
		local player = Ents:IsSpawnerPlayer(bomb, true)
		if player and player:HasCollectible(self.ID) then
			self:DoSale(bomb.Position, 70*bomb.RadiusMultiplier, player)
		end
	end
end
SaleBomb:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, 'OnBombUpdate')


--史诗胎儿兼容
function SaleBomb:AlsoEpicFetus(effect)
	if effect.Timeout == 1 then
		local player = Ents:IsSpawnerPlayer(effect, true)
		if player and player:HasCollectible(self.ID) then
			self:DoSale(effect.Position, 70, player)
		end
	end
end
SaleBomb:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'AlsoEpicFetus', EffectVariant.ROCKET)


return SaleBomb