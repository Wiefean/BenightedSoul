--昧化遗骸

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Achiev.CharacterLock
local Damage = mod.IBS_Class.Damage()

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BForgotten = mod.IBS_Class.Character(mod.IBS_PlayerID.BForgotten, {
	BossIntroName = 'bforgotten',
	HiddenItems = {20, 213, 597, IBS_ItemID.BOT},
})

--变身
function BForgotten:Benighted(player, fromMenu)
	player:ChangePlayerType(self.ID)
	player:AddBombs(7)

	--骨头环绕物
	for i = 1,6 do
		player:AddBoneOrbital(player.Position)
	end
end
BForgotten:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_THEFORGOTTEN)

--临时数据
function BForgotten:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	
	if not data.BForgotten then
		data.BForgotten = {
			Charge = 0
		}
		
		--充能条
		local bar = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar:SetFrame("Disappear", 99)

		data.BForgotten.ChargeBar = bar
	end
	
	return data.BForgotten
end


--角色更新
function BForgotten:OnPlayerUpDate(player)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetTempData(player)
	
	--没有魂心时,骨心变成魂心
	local bone = player:GetBoneHearts()
	if player:GetSoulHearts() <= 0 and bone > 0 then
		player:AddBoneHearts(-bone)
		player:AddSoulHearts(2*bone)
	end
	
	player.Color = Color(1.5, 1.7, 2, 1, 0.05, 0.12, 0.2)
end
BForgotten:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpDate', 0)

--可替换的眼泪列表
BForgotten.TearToBoneList = {
	[0] = true,
	[1] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[14] = true,
	[15] = true,
	[24] = true,
	[25] = true,
	[37] = true,
	[38] = true,
}

--眼泪特效
function BForgotten:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)

    if player and player:GetPlayerType() == self.ID and self.TearToBoneList[tear.Variant] then	
		tear:ChangeVariant(29)
		tear.Color = Color(0.5, 0.7, 2, 1, 0.05, 0.12, 0.2)
		tear:Update()
    end
end
BForgotten:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'OnFireTear')

--传送
function BForgotten:Teleport(player, radius)
	local targets = {}
	local pos = player.Position
	
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(ent) then
			table.insert(targets, ent)
		end
	end	
	
	if #targets > 0 then	
		self:ShuffleTable(targets, math.random(1,#targets)) --打乱顺序
		local target = targets[1]
		if target then
			local pos = target.Position
			radius = radius + target.Size
		end	
	end
	
	local X = (-1)^math.random(1,2) * radius
	local Y = (-1)^math.random(1,2) * radius
	pos = pos + Vector(X, Y)
	
	self._Players:TeleportToPosition(player, game:GetRoom():FindFreePickupSpawnPosition(pos, 0, false, player.CanFly), true, true, 30)	
end

--心数限制
function BForgotten:HeartLimit(player, limit)
	if not player:HasCollectible(619) then
		return limit - 12
	end
end
BForgotten:AddCallback(mod.IBS_CallbackID.GET_HEART_LIMIT, 'HeartLimit', BForgotten.ID)

--长子权刷新属性
function BForgotten:OnGainBirthright(item, charge, first, slot, varData, player)
	if player:GetPlayerType() == self.ID then
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
BForgotten:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainBirthright', 619)

function BForgotten:OnLoseBirthright(player)
	if player:GetPlayerType() == self.ID then
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end
BForgotten:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, 'OnLoseBirthright', 619)

function BForgotten:OnEvaluateCache(player, flag)
	if player:GetPlayerType() == self.ID and player:HasCollectible(619) then
		if flag == CacheFlag.CACHE_FIREDELAY then
			self._Stats:TearsMultiples(player, 2)
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 0.5
		end
		if flag == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		end
	end	
end
BForgotten:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvaluateCache')

--这是特制的炸弹,懂吗
function BForgotten:OnUseBomb(player, bomb)
	if player:GetPlayerType() == self.ID then
		self:Teleport(player, 200)
		bomb:SetExplosionCountdown(0)
		bomb.ExplosionDamage = bomb.ExplosionDamage * 0.1
		
		local BOT = mod.IBS_Item and mod.IBS_Item.BOT
		if BOT then
			local tear = BOT:SpawnStoppedTear(player, player.Position)
			tear.CollisionDamage = tear.CollisionDamage * 6
			tear.Scale = self._Maths:TearDamageToScale(tear.CollisionDamage / 2)
		end
	end
end
BForgotten:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, -700, 'OnUseBomb')

--修改基础掉落上限
function BForgotten:OnEvaluateCustomCache(player, flag, value)
	if PlayerManager.AnyoneIsPlayerType(self.ID) then
	
		--长子权
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == self.ID and player:HasCollectible(619) then
				return value
			end
		end
	
		if flag == "maxbombs" then
			return value - 90
		end
	end	
end
BForgotten:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, 'OnEvaluateCustomCache')

--清理房间给炸弹
function BForgotten:OnCleanRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			player:AddBombs(2)
		end
	end
end
BForgotten:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnCleanRoom')

--骨头环绕物上色
function BForgotten:OnBoneOrbitalUpDate(familiar)
	local player = familiar.Player
	if not player or player:GetPlayerType() ~= self.ID then return end

	familiar.Color = Color(0.5, 0.7, 2, 1, 0.05, 0.12, 0.2)
end
BForgotten:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnBoneOrbitalUpDate', 128)

--清除尿迹(十分生草)
local function ClearPee(_,effect)
	--if game:GetRoom():GetFrameCount() > 0 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BForgotten.ID then
			if effect.Position:Distance(player.Position) <= 1 then
				effect.Visible = false
				effect:Remove()
				break
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ClearPee, 7)

return BForgotten