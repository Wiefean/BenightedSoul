--杯满的灿幻庄

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local SangenSummoning = mod.IBS_Class.Item(mod.IBS_ItemID.SangenSummoning)

--在已清理的免疫惩罚性伤害
function SangenSummoning:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end
	if not player:HasCollectible(self.ID) then return end
	if not Damage:IsPenalt(player, flag, source) then return end
	if not Damage:CanHurtPlayer(player, flag, source) then return end
	if game:GetRoom():IsClear() then
		return false
	end
end
SangenSummoning:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 'PrePlayerTakeDMG')


--被移除后伤害翻倍
function SangenSummoning:OnRemoveItem(player, item)
	local data = self._Players:GetData(player)
	if not data.SangenSummoningTriggered then
		data.SangenSummoningTriggered = true
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	end
end
SangenSummoning:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, 'OnRemoveItem', SangenSummoning.ID)


--属性
function SangenSummoning:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_DAMAGE then
			self._Stats:Damage(player, 0.3*num)
		end
	end	
end
SangenSummoning:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

function SangenSummoning:OnEvaluateCache2(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE and not player:HasCollectible(self.ID) then
		local data = self._Players:GetData(player)
		if data.SangenSummoningTriggered then		
			player.Damage = player.Damage * 2
		end
	end
end
SangenSummoning:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, 'OnEvaluateCache2')


return SangenSummoning