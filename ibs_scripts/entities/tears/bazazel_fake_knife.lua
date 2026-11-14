--昧az妈刀与硫磺火组合使用的飞刀眼泪
--移植自粉毛剑士的fake_knife,保留分批发射、散布、旋转和碰撞规则

local mod = Isaac_BenightedSoul
local IBS_TearID = mod.IBS_TearID

local sfx = SFXManager()

local BAzazelFakeKnife = mod.IBS_Class.Tear{
	Variant = IBS_TearID.BAzazelFakeKnife.Variant,
	SubType = IBS_TearID.BAzazelFakeKnife.SubType,
	Name = {zh = '昧az飞刀', en = 'BAzazel Fake Knife'}
}

BAzazelFakeKnife.SpriteOffset = Vector(0, 19)
BAzazelFakeKnife.DefaultDamageMultiplier = 2
BAzazelFakeKnife.LifeTime = 60

function BAzazelFakeKnife:GetSourceBAzazel(entity)
	local player = self._Ents:GetSourcePlayer(entity)
	if not player or player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return nil end
	return player
end

--direction使用角度制;请求存入玩家临时数据,由更新回调分批生成
function BAzazelFakeKnife:FireFakeKnife(player, num, direction, mul, position)
	if not player or player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return end

	local data = self._Ents:GetTempData(player)
	data.BAzazelFakeKnifeQueue = data.BAzazelFakeKnifeQueue or {}
	table.insert(data.BAzazelFakeKnifeQueue, {
		Remaining = math.max(0, math.ceil(num or 0)),
		Direction = direction,
		Position = position or player.Position,
		DamageMultiplier = mul or self.DefaultDamageMultiplier,
	})
end

--根据角度翻转并旋转贴图,避免左侧飞行的刀身倒置
function BAzazelFakeKnife:UpdateSpriteRotation(tear)
	local angle = tear.Rotation
	while angle > 360 do angle = angle - 360 end
	while angle < 0 do angle = angle + 360 end

	if angle >= 90 and angle < 270 then
		tear.SpriteRotation = 180 - angle
		tear.SpriteScale = Vector(-math.abs(tear.SpriteScale.X), tear.SpriteScale.Y)
	else
		tear.SpriteRotation = angle
		tear.SpriteScale = Vector(math.abs(tear.SpriteScale.X), tear.SpriteScale.Y)
	end
end

function BAzazelFakeKnife:SpawnKnife(player, request)
	local direction = request.Direction
	if direction == nil then
		local aim = player:GetAimDirection()
		direction = aim:Length() > 0.001 and aim:GetAngleDegrees() or 0
	end

	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
	local position = request.Position + Vector.FromAngle(direction + 90) * (rng:RandomInt(41) - 20)
	local tear = player:FireTear(position, Vector.FromAngle(direction) * 25,
		false, true, true, player, request.DamageMultiplier or self.DefaultDamageMultiplier)
	sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)
	sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
	if not tear then return end

	tear:ChangeVariant(self.Variant)
	tear.SubType = self.SubType
	local animation = player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) and 'SpiritSword' or 'Idle'
	tear:GetSprite():Play(animation, true)
	tear.Rotation = direction
	tear.SpriteOffset = self.SpriteOffset
	tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
	tear.Mass = 0
	tear.Scale = 1
	self:UpdateSpriteRotation(tear)
end

--与参考一致:每2帧处理一次,每次从每个待发队列生成至多2把飞刀
function BAzazelFakeKnife:OnPlayerUpdate(player)
	if player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel or not player:IsFrame(2, 0) then return end

	local data = self._Ents:GetTempData(player)
	local queue = data.BAzazelFakeKnifeQueue
	if not queue then return end

	for key, request in pairs(queue) do
		for _ = 1, 2 do
			if request.Remaining > 0 then
				request.Remaining = request.Remaining - 1
				self:SpawnKnife(player, request)
			end
		end
		if request.Remaining <= 0 then
			queue[key] = nil
		end
	end
end
BAzazelFakeKnife:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--保留参考的手动伤害与后续原生碰撞流程
function BAzazelFakeKnife:PreTearCollision(tear, collider)
	local player = self:GetSourceBAzazel(tear)
	if not player then return end

	local flags = 0
	if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
		if rng:RandomInt(2) > 0 then
			flags = DamageFlag.DAMAGE_SPAWN_FLY
		end
	end

	if collider:IsVulnerableEnemy() then
		collider:TakeDamage(tear.CollisionDamage, flags, EntityRef(tear), 0)
	elseif collider.Type == EntityType.ENTITY_FIREPLACE then
		collider:TakeDamage(1, 0, EntityRef(tear), 0)
	end
end
BAzazelFakeKnife:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 'PreTearCollision', BAzazelFakeKnife.Variant)

function BAzazelFakeKnife:OnTearUpdate(tear)
	local player = self:GetSourceBAzazel(tear)
	if not player then return end

	--扁石沿用参考中的弹跳参数
	if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
		tear.FallingAcceleration = 1.6
		if tear.Height > -8 then
			tear.FallingSpeed = -20
		end
	else
		tear.Height = -45
	end

	self:UpdateSpriteRotation(tear)
	if tear.Velocity:Length() > 0 then
		local angle = tear.Velocity:GetAngleDegrees() - tear.Rotation
		while angle > 180 do angle = angle - 360 end
		while angle < -180 do angle = angle + 360 end
		tear.Rotation = tear.Rotation + angle * 0.5
	end

	if tear.FrameCount > self.LifeTime then
		tear:Remove()
	end
end
BAzazelFakeKnife:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'OnTearUpdate', BAzazelFakeKnife.Variant)

return BAzazelFakeKnife
