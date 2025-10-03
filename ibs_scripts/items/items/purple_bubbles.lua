--紫色泡泡水

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local sfx = SFXManager()

local PurpleBubbles = mod.IBS_Class.Item(mod.IBS_ItemID.PurpleBubbles)


--获取数据
function PurpleBubbles:GetData(player)
	local data = self._Players:GetData(player)
	data.PurpleBubbles = data.PurpleBubbles or {
		usedtimes = 0,
		spd = 0,
		tears = 0,
		dmg = 0,
		range = 0,
		sspd = 0
	}

	return data.PurpleBubbles	
end	

--使用
function PurpleBubbles:OnUse(item, rng, player, flags)
	local data = self:GetData(player)
	local chance = rng:RandomInt(100)

	if chance > 20 and chance <= 40 then
		data.spd = data.spd - 0.02
	elseif chance > 40 and chance <= 60 then
		data.tears = data.tears + 0.06
	elseif chance > 60 and chance <= 80 then
		data.dmg = data.dmg + 0.1
	elseif chance > 80 and chance <= 100 then
		data.range = data.range + 0.15
	else
		data.sspd = data.sspd - 0.03
	end

	if data.usedtimes < 25 then
		data.usedtimes = data.usedtimes + 1
		
		if (flags & UseFlag.USE_VOID > 0) then
			data.usedtimes = data.usedtimes + 99
		end
	end
	
	sfx:Play(SoundEffect.SOUND_VAMP_GULP)
	
	return true
end
PurpleBubbles:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', PurpleBubbles.ID)

--重置
function PurpleBubbles:ResetStats()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if not player:HasCollectible(self.ID) then
			local data = self._Players:GetData(player)
			if data.PurpleBubbles and data.PurpleBubbles.usedtimes < 23 then
				data.PurpleBubbles = nil
				player:AddCacheFlags(CacheFlag.CACHE_ALL)
				player:EvaluateItems()
			end
		end
	end
end
PurpleBubbles:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'ResetStats')

--属性改动
function PurpleBubbles:OnEvaluateCache(player, flag)
	local data = self._Players:GetData(player).PurpleBubbles
	
	if data then	
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, data.spd)
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, data.tears)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, data.dmg)
		end
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, data.range)
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, data.sspd)
		end
	end	
end
PurpleBubbles:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return PurpleBubbles