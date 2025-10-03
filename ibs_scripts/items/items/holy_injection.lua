--注射型圣水

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local HolyInjection = mod.IBS_Class.Item(mod.IBS_ItemID.HolyInjection)

--清理房间
function HolyInjection:OnRoomCleared()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local chance = 3
			for id,num in pairs(player:GetCollectiblesList()) do
				local itemConfig = config:GetCollectible(id)
				if itemConfig and num > 0 then
					if itemConfig:HasTags(ItemConfig.TAG_SYRINGE) then
						chance = chance + num
					end
					if itemConfig:HasTags(ItemConfig.TAG_ANGEL) then
						chance = chance + num
					end
				end
			end	
			local int = player:GetCollectibleRNG(self.ID):RandomInt(100)
			if int < chance then
				player:AddBrokenHearts(-1)
				player:AddSoulHearts(1)
				Isaac.Spawn(1000, 49, 4, player.Position, Vector.Zero, nil)
				sfx:Play(54)
			end
		end
	end	
end
HolyInjection:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleared')
HolyInjection:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleared') --贪婪模式新波次

--属性变动
function HolyInjection:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_LUCK then
			self._Stats:Luck(player, 2 * player:GetCollectibleNum(self.ID))
		end
	end	
end
HolyInjection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')


return HolyInjection