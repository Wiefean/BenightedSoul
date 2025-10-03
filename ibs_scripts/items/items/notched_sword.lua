--残损之剑

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local NotchedSword = mod.IBS_Class.Item(mod.IBS_ItemID.NotchedSword)

--获得
function NotchedSword:OnGain(item, charge, first, slot, varData, player)
	self:GetIBSData('temp').NotchedSword = true
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
	
	--正邪削弱(东方mod)
	if mod.IBS_Compat.THI:SeijaNerf(player) then
		player:AddBrokenHearts(3)
	end
end
NotchedSword:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', NotchedSword.ID)

--无视护甲
function NotchedSword:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) and self:GetIBSData('temp').NotchedSword then
	
		
		--正邪削弱(东方mod)
		--概率不造成伤害
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)			
			if mod.IBS_Compat.THI:SeijaNerf(player) then
				if player:GetCollectibleRNG(self.ID):RandomInt(100) < 50 then	
					return false
				end
			end
		end
		
		return {Damage = dmg, DamageFlags = flag | DamageFlag.DAMAGE_IGNORE_ARMOR, DamageCountdown = cd}
	end
end
NotchedSword:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 100000, 'OnTakeDMG')

--开门
function NotchedSword:OnRoomCleaned()
	local room = game:GetRoom()
	if not room:IsFirstVisit() then return end
	local seed = self._Levels:GetRoomUniqueSeed()
	
	if self:GetIBSData('temp').NotchedSword and RNG(seed):RandomInt(3) == 1 then
		--该隐魂偷懒
		Isaac.GetPlayer(0):UseCard(83, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		sfx:Stop(204)

		--破门效果
		for slot = 0,7 do
			local door = room:GetDoor(slot)
			if door ~= nil then
				door:GetSprite():Play('BrokenOpen')
				door:SpawnDust()
			end
		end
		sfx:Play(137)
		
		--尝试打开特殊门
		room:TrySpawnDevilRoomDoor()
		room:TrySpawnBossRushDoor()
		room:TrySpawnBlueWombDoor()
	end
end
NotchedSword:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--属性
function NotchedSword:OnEvaluateCache(player, flag)
	if self:GetIBSData('temp').NotchedSword then	
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1
		end
	end	
end
NotchedSword:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, 'OnEvaluateCache')

return NotchedSword