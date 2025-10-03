--金针菇

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local sfx = SFXManager()

local NeedleMushroom = mod.IBS_Class.Item(mod.IBS_ItemID.NeedleMushroom)

function NeedleMushroom:OnPlayeUpdate(player)
	if player:IsFrame(30,0) and player:HasCollectible(self.ID, true) and self._Players:IsShooting(player) then
		local playerType = player:GetPlayerType()
		local rng = player:GetCollectibleRNG(self.ID)
		local luck = player.Luck
		local chance = 6 - luck
		if chance < 1 then chance = 1 end

		if rng:RandomInt(100) <= chance then
			player:DropCollectible(self.ID, item, true)
			
			--查找金针菇
			for _,ent in ipairs(Isaac.FindByType(5,100, self.ID)) do
				local pickup = ent:ToPickup()
				pickup:SetColor(Color(92/255, 47/255, 22/255), 200, 2,true)
				pickup.Touched = false
				pickup.Wait = 150 --等5秒才能再捡
			end

			--里蓝人兼容
			if playerType == PlayerType.PLAYER_BLUEBABY_B then
				local variant = 0
				if rng:RandomInt(99) <= 25 then variant = 1 end
				local poop = Isaac.Spawn(5, 42, variant, player.Position, Vector.Zero, player):ToPickup()
				poop.Velocity = RandomVector() * 4
				poop.Wait = 30
			end
			
			game:Fart(player.Position, 85, player, 1, 0, Color(92/255, 47/255, 22/255))
		end
	end
end
NeedleMushroom:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)

function NeedleMushroom:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, 0.3*num)
		end		
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, 0.7*num)
		end
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, 1.25*num)
		end
	end	
end
NeedleMushroom:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')



return NeedleMushroom