--昧化阿撒泻勒(目前为阿撒谢特)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local CharacterLock = mod.IBS_Achiev.CharacterLock

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()
local mus = MusicManager()
local music = Isaac.GetMusicIdByName('神秘')

local BAzazel = mod.IBS_Class.Character(mod.IBS_PlayerID.BAzazel, {
	BossIntroName = 'bazazel',
})

--临时数据
function BAzazel:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	data.BAzazel = data.BAzazel or {
		CanWTF = false,
		FirstWTF = false,
		WTFCD = 0,
	}
	return data.BAzazel
end

--新房间重置数据
function BAzazel:OnNewRoom(player)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local data = self:GetTempData(player)
			data.CanWTF = false
			data.FirstWTF = false
		end
	end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--角色初始化
function BAzazel:OnPlayerInit(player)
	if player:GetPlayerType() ~= self.ID then return end
	--player:AddCollectible(643, 0, false)
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')


--神秘动静
function BAzazel:WTF(player)
	local target = self._Finds:ClosestEnemy(player.Position)

	if target and target:IsActiveEnemy() then
		local data = self:GetTempData(player)

		if not data.FirstWTF or (self._Players:IsShooting(player) and target.Position:Distance(player.Position) < 150 + target.Size) then
			data.FirstWTF = true
			player:AddVelocity((target.Position - player.Position):Resized(20))
			player:UseActiveItem(160, false, false)
			player:UseActiveItem(160, false, false)
			player:UseActiveItem(181, false, false)
			player:RemoveCostume(config:GetCollectible(181))
			player:SetMinDamageCooldown(120)
			
			game:GetRoom():MamaMegaExplosion(player.Position)
			
			local data = self:GetTempData(player)
			data.WTFCD = 60
		
			local current = mus:GetCurrentMusicID()
			if current ~= music then
				mus:Play(music)
			end
		end
	end
end

--神秘圣光
function BAzazel:WTFLight(laser)
	local player = self._Ents:IsSpawnerPlayer(laser)
    if player and player:GetPlayerType() == self.ID then
		laser:AddTearFlags(TearFlags.TEAR_HOMING)
		laser:SetScale(10)
		laser:SetHomingType(1)
		
		local data = self:GetTempData(player)
		data.CanWTF = true
		data.FirstWTF = false
		data.WTFCD = 0
    end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_LASER_INIT, 'WTFLight', 5)

--角色更新
function BAzazel:OnUpdate(player)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetTempData(player)

	if data.WTFCD > 0 then
		data.WTFCD = data.WTFCD - 1
	elseif data.CanWTF then
		self:WTF(player)
	end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnUpdate')

--飞行
function BAzazel:OnEvaluateCache(player, flag)
	if flag == CacheFlag.CACHE_FLYING and player:GetPlayerType() == self.ID then
		player.CanFly = true
	end
end
BAzazel:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--翅膀装饰
function BAzazel:ApplyFlyCostume(player)
	if player:GetPlayerType() == self.ID then
		local effect = player:GetEffects()
		if not effect:HasCollectibleEffect(179) then
			effect:AddCollectibleEffect(179, true)
		end	
		if not effect:HasCollectibleEffect(216) then
			effect:AddCollectibleEffect(216, true)
		end
		if not player:HasCollectible(643) then
			player:AddInnateCollectible(643, 1)
			player:RemoveCostume(config:GetCollectible(643))
		end			
	end	
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'ApplyFlyCostume')

--敌人减伤
function BAzazel:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) and PlayerManager.AnyoneIsPlayerType(self.ID) then	
		local mult = 0.01 * (game:GetRoom():GetFrameCount() / 300)
		if ent:IsBoss() then
			return {Damage = dmg * mult, DamageFlags = flag | DamageFlag.DAMAGE_IGNORE_ARMOR}
		else		
			return {Damage = dmg * mult}
		end
	end
end
BAzazel:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -67676767, 'OnTakeDMG')

return BAzazel