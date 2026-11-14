--昧化阿撒泻勒

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local CharacterLock = mod.IBS_Achiev.CharacterLock
local InvertedCrossTear = mod.IBS_Tear.InvertedCrossTear

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local BAzazel = mod.IBS_Class.Character(mod.IBS_PlayerID.BAzazel, {
	BossIntroName = 'bazazel',
	HiddenItems = {673}, --赎罪
})

--双生宝和莉莉宝共享本体完整攻击流程;倍率配置由引弹模块统一持有
local FamiliarAttackInfo = InvertedCrossTear.FamiliarAttackInfo

--初始信息
local InitInfo = {
	ChargeDelayMul = 10,
	OffsetLength = 20,
	PositionOffset = Vector(0, 10),
	ShotSpeedMul = 10,
	RangeMul = 1,
}

--常态与黑色形态使用相同的玩家动画结构,仅切换图集ANM2
local PlayerNormalSpritePath = 'gfx/ibs/characters/player_bazazel.anm2'
local PlayerBlackSpritePath = 'gfx/ibs/characters/player_bazazel_black.anm2'
local BlackWingsCostume = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bazazel_wings_black.anm2')

BAzazel.BlackFormInfo = {
	RequiredSpikeDeals = 3,
	SpikePrice = -5, --兼容忏悔,不依赖Repentance+新增枚举
	RedemptionKillRequirement = 36,
	SacrificeDamageCap = 1,
	SacrificeKillProgress = 6,
	TransitionLightCount = 6,
	TransitionLightRadius = 40,
	SwingKnockback = 3,
	ChargeGainMultiplier = 2,
	ChargeRefillRatio = 0.5,
	SwingColor = Color(1, 0.15, 0.15, 1, 0, 0, 0),
}
BAzazel.ProgressHintDuration = 30

local ProgressHintFont = Font()
ProgressHintFont:Load('font/pftempestasevencondensed.fnt')

--本体和以撒心脏共用状态,获得或失去心脏时保留蓄力及悬浮引弹;复制跟班各自独立
function BAzazel:GetTempData(entity)
	local familiar = entity and entity:ToFamiliar()
	if familiar and familiar.Variant == FamiliarVariant.ISAACS_HEART then
		local spawner = familiar.SpawnerEntity
		local owner = familiar.Player or (spawner and spawner:ToPlayer())
		if owner then entity = owner end
	end

	local data = self._Ents:GetTempData(entity)
	if not data.BAzazel then
		local bar = Sprite('gfx/ibs/ui/chargebar_invertedcross.anm2')
		bar:SetFrame('Disappear', 8)
	
		data.BAzazel = {
			Charge = 0,
			ChargeBar = bar,
			MaxCharge = 0,
			AimAngle = nil,
			AttackMode = false,
			InvertedCrossTears = {},
			ChargeCooldown = 0,
			ProgressHintTimeout = 0,
			ProgressHintType = nil,
		}
	end
	return data.BAzazel
end

function BAzazel:ShowProgressHint(player, hintType)
	local data = self:GetTempData(player)
	data.ProgressHintTimeout = self.ProgressHintDuration
	data.ProgressHintType = hintType
end

--黑色形态属于整局状态,必须存入可随存档恢复的玩家数据
function BAzazel:GetData(player)
	local data = self._Players:GetData(player)
	if not data.BAzazelForm then
		--兼容热重载前仍保存在实体临时数据中的旧状态
		local legacy = self:GetTempData(player)
		data.BAzazelForm = {
			SpikeDealCount = legacy.SpikeDealCount or 0,
			BlackForm = legacy.BlackForm == true,
			RedemptionKillCount = 0,
		}
		legacy.SpikeDealCount = nil
		legacy.BlackForm = nil
	end
	data.BAzazelForm.RedemptionKillCount = data.BAzazelForm.RedemptionKillCount or 0
	return data.BAzazelForm
end

function BAzazel:IsBlackForm(player)
	return player and player:GetPlayerType() == self.ID and self:GetData(player).BlackForm or false
end

function BAzazel:SpawnBlackFormTransitionEffect(player, enteringBlack)
	local pitch = enteringBlack and 0.5 or 1
	sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, pitch, 0)
	game:ShakeScreen(15)

	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1,
		player.Position, Vector.Zero, player)
	local poof = entity and entity:ToEffect()
	if poof and not enteringBlack then
		poof.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.7)
	end

	local info = self.BlackFormInfo
	local color = enteringBlack and Color(1, 0, 0, 1, 0, 0, 0)
		or Color(1, 1, 1, 1, 0, 0, 0)
	local damage = player.Damage
	local scale = 1
	for i = 0, info.TransitionLightCount - 1 do
		local angle = i * 360 / info.TransitionLightCount
		local position = player.Position + Vector.FromAngle(angle) * info.TransitionLightRadius
		position = game:GetRoom():GetClampedPosition(position, 0)
		mod.IBS_Effect.BAzazelCrackTheSky:Spawn(position, player, damage, scale, color)
	end
end

--进入或离开黑色形态时替换玩家动画图集,保留当前动画与帧
function BAzazel:__UpdatePlayerSprite(player, data)
	local blackForm = self:IsBlackForm(player)
	local spriteState = data.BAzazelBlackFormSprite
	if spriteState == blackForm then return end
	if spriteState == nil and not blackForm then
		data.BAzazelBlackFormSprite = false
		return
	end

	data.BAzazelBlackFormSprite = blackForm
	local spritePath = blackForm and PlayerBlackSpritePath or PlayerNormalSpritePath
	self:__ChangeSprite(player, spritePath)

	if BlackWingsCostume and BlackWingsCostume >= 0 then
		if blackForm then
			player:AddNullCostume(BlackWingsCostume)
		else
			player:TryRemoveNullCostume(BlackWingsCostume)
		end
	end

	if spriteState ~= nil then
		self:SpawnBlackFormTransitionEffect(player, blackForm)
	end
end

--以撒心脏只替换本体的攻击中心,不改变其他复制攻击跟班的中心
function BAzazel:GetAttackSource(player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ISAACS_HEART) then
		return player
	end

	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ISAACS_HEART)) do
		local familiar = entity:ToFamiliar()
		if familiar and (self._Ents:IsTheSame(familiar.Player, player)
		or self._Ents:IsTheSame(familiar.SpawnerEntity, player)) then
			return familiar
		end
	end
	return player
end

--接管当前昧az的双生宝和莉莉宝
function BAzazel:GetAttackSources(player)
	local sources = {self:GetAttackSource(player)}
	for _, familiar in ipairs(self._Finds:IncubusFamiliars(player)) do
		if FamiliarAttackInfo[familiar.Variant] then
			table.insert(sources, familiar)
		end
	end
	return sources
end

--鼠标和准星均相对实际攻击中心计算;键盘仍直接读取玩家射击摇杆
function BAzazel:GetAimingVector(player, source, mouseCenter)
	local center = mouseCenter or (source and source.Position) or player.Position
	local marked = player:GetMarkedTarget()
	if marked then
		return (marked.Position - center):Normalized()
	end
	if Options.MouseControl and player.ControllerIndex == 0 and Input.IsMouseBtnPressed(0) then
		return (self._Screens:GetMousePosition(true) - center):Normalized()
	end
	return player:GetShootingJoystick():Normalized()
end

--角色初始化
function BAzazel:OnPlayerInit(player)
	if player:GetPlayerType() ~= self.ID then return end
	local blackForm = self:IsBlackForm(player)
	self:__ChangeSprite(player, blackForm and PlayerBlackSpritePath or PlayerNormalSpritePath)
	self:__GetAnimData(player).BAzazelBlackFormSprite = blackForm
	--player:AddCollectible(643, 0, false)
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

function BAzazel:HasSacrificeRoom(level)
	local rooms = level:GetRooms()
	for i = 0, rooms.Size - 1 do
		local roomDesc = rooms:Get(i)
		if roomDesc and roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_SACRIFICE then
			return true
		end
	end
	return false
end

--昧az每层保底一个献祭房,优先于根系之仪执行
function BAzazel:EnsureSacrificeRoom()
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end

	local level = game:GetLevel()
	if self:HasSacrificeRoom(level) then return end

	local dimension = -1
	local seed = level:GetDungeonPlacementSeed()
	local roomConfig = RoomConfigHolder.GetRoomByStageTypeAndVariant(
		StbType.SPECIAL_ROOMS, RoomType.ROOM_SACRIFICE, 0, -1)
	if not roomConfig then return end

	local options = level:FindValidRoomPlacementLocations(roomConfig, dimension, true, false) or {}
	for _, gridIndex in pairs(options) do
		local neighbors = level:GetNeighboringRooms(gridIndex, roomConfig.Shape, dimension)
		local onlySecretNeighbors = true
		for _, neighborDesc in pairs(neighbors) do
			if neighborDesc.Data and neighborDesc.Data.Type ~= RoomType.ROOM_SECRET then
				onlySecretNeighbors = false
			end
		end

		if not onlySecretNeighbors
		and level:TryPlaceRoom(roomConfig, gridIndex, dimension, seed, true, false, false) then
			return
		end
	end

	local rng = RNG(seed)
	local fallback = {}
	for gridIndex = 0, 168 do
		table.insert(fallback, gridIndex)
	end
	for i = #fallback, 2, -1 do
		local index = rng:RandomInt(i) + 1
		fallback[i], fallback[index] = fallback[index], fallback[i]
	end
	for _, gridIndex in pairs(fallback) do
		if level:TryPlaceRoom(roomConfig, gridIndex, dimension, seed, true, false, true) then
			return
		end
	end
end
BAzazel:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -7000, 'EnsureSacrificeRoom')

--昧az在场时,消耗血量的恶魔交易固定为刺交易
function BAzazel:OnDevilDealPickupUpdate(pickup)
	if pickup.FrameCount > 1 then return end
	if pickup.Price == -5 or pickup.Price < -9 or pickup.Price > -1 then return end
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	pickup.OptionsPickupIndex = 0
	pickup.AutoUpdatePrice = false
	pickup.Price = -5
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnDevilDealPickupUpdate', PickupVariant.PICKUP_COLLECTIBLE)

--购买后回调的price是实际成交价格;只累计完成的刺交易,不通过受伤事件反推
function BAzazel:OnSpikeDealPurchase(pickup, player, price)
	if not player or player:GetPlayerType() ~= self.ID or price ~= self.BlackFormInfo.SpikePrice then return end
	local data = self:GetData(player)
	if data.BlackForm then return end

	data.SpikeDealCount = (data.SpikeDealCount or 0) + 1
	if data.SpikeDealCount >= self.BlackFormInfo.RequiredSpikeDeals then
		data.BlackForm = true
		data.SpikeDealCount = 0
	end
	self:ShowProgressHint(player, 'Spike')
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, 'OnSpikeDealPurchase', PickupVariant.PICKUP_COLLECTIBLE)

--赎罪印记是CollectibleEffect,不是直接添加673道具
function BAzazel:AddRedemptionMark(player)
	local effects = player:GetEffects()
	local redemption = CollectibleType.COLLECTIBLE_REDEMPTION
	if not effects:HasCollectibleEffect(redemption) then
		effects:AddCollectibleEffect(redemption)
		return
	end

	local effect = effects:GetCollectibleEffect(redemption)
	if effect and effect.Count == 1 then
		local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.REDEMPTION, 0,
			player.Position, Vector.Zero, player)
		if entity then
			entity.Parent = player
			local spawned = entity:ToEffect()
			if spawned then
				spawned.State = 2
			end
		end
	elseif effect then
		effect.Count = 1
	end
end

function BAzazel:AddRedemptionKillProgress(player, amount)
	local data = self:GetData(player)
	data.RedemptionKillCount = (data.RedemptionKillCount or 0) + amount
	self:ShowProgressHint(player, 'Kill')
	if data.RedemptionKillCount >= self.BlackFormInfo.RedemptionKillRequirement then
		data.RedemptionKillCount = 0
		self:AddRedemptionMark(player)
	end
end

--黑色形态下,带有昧az圣光印记的敌人死亡时累计赎罪进度
function BAzazel:OnEntityKilled(entity)
	if not mod.IBS_Effect.BAzazelCrackTheSkyMark:GetMark(entity) then return end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self:IsBlackForm(player) then
			self:AddRedemptionKillProgress(player, 1)
		end
	end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

function BAzazel:IsSacrificeSpikeDamage(flag, source)
	if game:GetRoom():GetType() ~= RoomType.ROOM_SACRIFICE then return false end

	local sourceEntity = source and source.Entity
	local sourceType = sourceEntity and sourceEntity.Type or (source and source.Type)
	local sourceVariant = sourceEntity and sourceEntity.Variant or (source and source.Variant)
	local isCalocybeSpike = sourceType == EntityType.ENTITY_EFFECT
		and sourceVariant == EffectVariant.POOF01

	return isCalocybeSpike or (flag & DamageFlag.DAMAGE_SPIKES) > 0
end

--赎罪收藏品效果可能被恶魔房永久保留,必须同时存在由当前昧az生成并绑定的实体
function BAzazel:HasActiveRedemption(player)
	if not player or player:GetPlayerType() ~= self.ID then return false end
	if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_REDEMPTION) then
		return false
	end

	local playerHash = GetPtrHash(player)
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.REDEMPTION)) do
		local spawner = entity.SpawnerEntity
		local parent = entity.Parent
		local spawnerPlayer = spawner and spawner:Exists() and spawner:ToPlayer() or nil
		local parentPlayer = parent and parent:Exists() and parent:ToPlayer() or nil
		if spawnerPlayer and parentPlayer
		and spawnerPlayer:GetPlayerType() == self.ID
		and parentPlayer:GetPlayerType() == self.ID
		and GetPtrHash(spawnerPlayer) == playerHash
		and GetPtrHash(parentPlayer) == playerHash then
			return true
		end
	end
	return false
end

--献祭房刺伤害至多1点;黑色无赎罪时加进度,有赎罪时转为免费献祭
function BAzazel:PrePlayerTakeDMG(entity, amount, flag, source, countdown)
	local player = entity and entity:ToPlayer()
	if not player or player:GetPlayerType() ~= self.ID or amount <= 0 then return end
	if (flag & DamageFlag.DAMAGE_FAKE) > 0 then return end
	if not self:IsSacrificeSpikeDamage(flag, source) then return end

	local hasRedemption = self:HasActiveRedemption(player)
	if not hasRedemption and self:IsBlackForm(player) then
		self:AddRedemptionKillProgress(player, self.BlackFormInfo.SacrificeKillProgress)
	end

	local result = {
		Damage = math.min(amount, self.BlackFormInfo.SacrificeDamageCap),
		DamageFlags = flag,
		DamageCountdown = countdown,
	}
	if hasRedemption then
		result.DamageFlags = flag | DamageFlag.DAMAGE_FAKE
	end
	return result
end
BAzazel:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 7777777, 'PrePlayerTakeDMG')

function BAzazel:GetRedemptionEffectPlayer(effect)
	local parent = effect.Parent
	local player = parent and parent:Exists() and parent:ToPlayer() or nil
	if player then return player end

	local spawner = effect.SpawnerEntity
	player = spawner and spawner:Exists() and spawner:ToPlayer() or nil
	if player then return player end

	--极少数情况下原版特效没有绑定来源时,退回到最近的黑形态昧az
	local closest
	local closestDistance = 100 * 100
	for i = 0, game:GetNumPlayers() - 1 do
		local candidate = Isaac.GetPlayer(i)
		if self:IsBlackForm(candidate) then
			local distance = candidate.Position:DistanceSquared(effect.Position)
			if distance <= closestDistance then
				closest = candidate
				closestDistance = distance
			end
		end
	end
	return closest
end

--赎罪Success动画播完即视为本次赎罪成功触发
function BAzazel:OnRedemptionEffectUpdate(effect)
	local sprite = effect:GetSprite()
	if sprite:GetAnimation() ~= 'Success' or not sprite:IsFinished('Success') then return end

	local data = self._Ents:GetTempData(effect)
	if data.BAzazelRedemptionSuccess then return end
	data.BAzazelRedemptionSuccess = true

	local player = self:GetRedemptionEffectPlayer(effect)
	if player and self:IsBlackForm(player) then
		self:GetData(player).BlackForm = false
	end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnRedemptionEffectUpdate', EffectVariant.REDEMPTION)

--射速修正标准
function BAzazel:GetDelayCorrection(player)
	local delay = player.MaxFireDelay
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)
	and (player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)) then
		delay = delay * 0.5
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
	or (player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
	and not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY)) then
		delay = delay * 0.5
	end
	if (player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)
	and not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE))
	or InvertedCrossTear:HasIpecac(player)
	or InvertedCrossTear:HasDrFetus(player)
	or player:GetPlayerType() == self.ID then
		delay = delay * 0.5
	end
	return math.max(0.05, delay)
end

function BAzazel:GetChargeTime(player)
	return self:GetDelayCorrection(player) * InitInfo.ChargeDelayMul
end

--只翻倍蓄力恢复量,不修改最大蓄力、射速或遥控模式的消耗速度
function BAzazel:GetChargeGain(player, amount)
	if self:IsBlackForm(player) then
		return amount * self.BlackFormInfo.ChargeGainMultiplier
	end
	return amount
end

--黑色形态每组引弹只挥砍一次;普通模式和遥控模式生成时额外补充半条蓄力
function BAzazel:DoBlackFormSwing(player, data, source, aimAngle, replenishHalf)
	if not self:IsBlackForm(player) or not source or not source:Exists() then return end
	local direction = Vector.FromAngle(aimAngle or 0)
	local targets, effect = mod.IBS_Effect.Swing:DoSwing({
		Spawner = player,
		AimingVector = direction,
		Position = source.Position,
		Color = self.BlackFormInfo.SwingColor,
		Scale = 1.5, --判定半径、攻击偏移和特效尺寸同步翻倍
		Damage = player.Damage,
		BounceSpeed = 0,
		SelfBounceSpeed = 0,
		FollowEntity = source,
	})
	--与里ysd发射衣架一致的原版音效(SoundEffect 252)
	sfx:Play(SoundEffect.SOUND_SHELLGAME)
	local hitEnemy = false
	for _, entity in ipairs(targets) do
		if self._Ents:IsEnemy(entity) then
			hitEnemy = true
			mod.IBS_Effect.BAzazelCrackTheSkyMark:Apply(entity, player)
			local knockback = (entity.Position - source.Position):Normalized()
			if knockback:Length() <= 0 then
				knockback = direction
			end
			entity:AddVelocity(knockback * self.BlackFormInfo.SwingKnockback)
		end
	end

	--只有实际命中敌人才补充半条蓄力
	if replenishHalf and hitEnemy and data.MaxCharge > 0 then
		data.Charge = math.min(data.MaxCharge,
			(data.Charge or 0) + data.MaxCharge * self.BlackFormInfo.ChargeRefillRatio)
	end
	return targets, effect
end

--高射速或准星在蓄满时自动释放
function BAzazel:ShouldAutoRelease(player)
	local tears = 30 / (self:GetDelayCorrection(player) + 1)
	return tears > 12
	or player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)
end

--直接读取射击键、鼠标左键和准星
function BAzazel:IsFiring(player)
	local pressed = Input.IsActionPressed
	local controller = player.ControllerIndex
	return pressed(ButtonAction.ACTION_SHOOTLEFT, controller)
	or pressed(ButtonAction.ACTION_SHOOTRIGHT, controller)
	or pressed(ButtonAction.ACTION_SHOOTUP, controller)
	or pressed(ButtonAction.ACTION_SHOOTDOWN, controller)
	or (Input.IsMouseBtnPressed(0) and Options.MouseControl)
	or (player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and player:GetMarkedTarget() ~= nil)
end

--反重力等待复用角色自身的开火判定,避免跨房间或输入方式不同造成误判
InvertedCrossTear.IsPlayerFiring = function(player)
	return BAzazel:IsFiring(player)
end

--洛基角、妈眼和眼瘤的额外方向,每次开始蓄力时只判定一次
function BAzazel:GetSpecialDirections(player)
	local directions = {}
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOKIS_HORNS)

	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then
		table.insert(directions, rng:RandomInt(360))
	end

	local hasLoki = player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS)
	local hasMomsEye = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE)
	local loki = false
	local momsEye = false
	if hasLoki and hasMomsEye then
		local luck = math.max(0, math.min(5, player.Luck)) + 4
		if luck >= rng:RandomInt(10) then
			loki = true
			momsEye = true
		end
	elseif hasLoki then
		local luck = math.max(0, math.min(15, player.Luck)) + 4
		if luck >= rng:RandomInt(20) then
			loki = true
		end
	elseif hasMomsEye then
		local luck = math.max(0, math.min(5, player.Luck)) + 4
		if luck >= rng:RandomInt(10) then
			momsEye = true
		end
	end

	if loki then
		for direction = 90, 270, 90 do
			table.insert(directions, direction)
		end
	end
	if momsEye then
		table.insert(directions, 180)
	end
	return directions
end

--多眼偏移计算
function BAzazel:GetInvertedCrossDirections(player, specialDirections)
	local params = player:GetMultiShotParams(WeaponType.WEAPON_TEARS)
	local lanes = math.max(1, params:GetNumTears() - math.max(0, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) - 1))
	local wizGroupNum = math.max(1, params:GetNumEyesActive())
	local spreadAngle = math.max((params:GetMultiEyeAngle(WeaponType.WEAPON_TEARS) * wizGroupNum) * 2 % 270, 20)
	local move2ToSide = player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY) and not player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ)
	--每份萌肺追加4枚,并将整组普通引弹按10度等距展开
	local lungCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
	lanes = lanes + lungCount * 4

	local directions = {}
	for lane = 1, lanes do
		local index = 0.5 - lanes / 2 + lane - 1
		local direction = 0
		if lungCount > 0 then
			direction = (lanes - 1) * 5 - (lane - 1) * 10
		elseif spreadAngle > 0 then
			direction = index * spreadAngle / lanes
		end
		if move2ToSide and lane > lanes - 2 then
			direction = 45
			if lane == lanes - 1 then
				direction = -45
			end
		end
		table.insert(directions, direction)
	end
	for _, direction in ipairs(specialDirections or {}) do
		table.insert(directions, direction)
	end
	return directions
end

--瞄准角平滑跟随,无模拟摇杆时鼠标方向吸附至最近的正方向
function BAzazel:UpdateAimAngle(player, data, instant, source)
	source = source or self:GetAttackSource(player)
	local vector = self:GetAimingVector(player, source)
	if vector:Length() <= 0 then
		vector = player:GetLastDirection()
	end
	if vector:Length() <= 0 then
		data.AimAngle = data.AimAngle or 0
		return data.AimAngle
	end

	if Options.MouseControl
	and not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
	and not player:GetMarkedTarget() then
		vector = Vector.FromAngle(math.floor((vector:GetAngleDegrees() + 45) / 90) * 90)
	end

	local targetAngle = vector:GetAngleDegrees()
	if instant or data.AimAngle == nil then
		data.AimAngle = targetAngle
		return targetAngle
	end

	local difference = targetAngle - data.AimAngle
	while difference > 180 do difference = difference - 360 end
	while difference < -180 do difference = difference + 360 end
	data.AimAngle = data.AimAngle + difference * 0.3
	return data.AimAngle
end

--清理失效引用,只保留仍在悬浮的引导弹
function BAzazel:GetHeldTears(data)
	local tears = {}
	for _, tear in ipairs(data.InvertedCrossTears) do
		if tear and tear:Exists() and not tear:IsDead() then
			local tearData = InvertedCrossTear:GetData(tear)
			if tearData.IsFloating and not tearData.Disappearing then
				table.insert(tears, tear)
			end
		end
	end
	data.InvertedCrossTears = tears
	return tears
end

--开始蓄力时一次性抽取多射数量与弹道,本次蓄力不再重复随机
function BAzazel:SpawnInvertedCrossTears(player, data, source)
	source = source or self:GetAttackSource(player)
	data.SpecialDirections = self:GetSpecialDirections(player)
	data.DirectionOffsets = self:GetInvertedCrossDirections(player, data.SpecialDirections)
	local aimAngle = self:UpdateAimAngle(player, data, true, source)
	data.InvertedCrossTears = {}

	for _, directionOffset in ipairs(data.DirectionOffsets) do
		local position = source.Position + InitInfo.PositionOffset
			+ Vector.FromAngle(aimAngle + directionOffset) * (InitInfo.OffsetLength + 15)
		local tear = InvertedCrossTear:Spawn(player, position, directionOffset, source)
		if tear then
			table.insert(data.InvertedCrossTears, tear)
		end
	end

	if #data.InvertedCrossTears > 0 then
		data.MaxCharge = self:GetChargeTime(player)
		data.Charge = 0
		self:DoBlackFormSwing(player, data, source, aimAngle, true)
	end
	return data.InvertedCrossTears
end

--悬浮在攻击方向及其多眼偏移方向,只使用蓄力开始时锁定的弹道
function BAzazel:UpdateFloatingTears(player, data, source)
	source = source or self:GetAttackSource(player)
	--兼容热重载前已经开始的蓄力,仅在缺少缓存时补抽一次
	if not data.DirectionOffsets then
		data.DirectionOffsets = self:GetInvertedCrossDirections(player, data.SpecialDirections)
	end
	local directions = data.DirectionOffsets
	local aimAngle = self:UpdateAimAngle(player, data, false, source)
	local chargeRatio = data.MaxCharge > 0 and math.max(0, math.min(1, data.Charge / data.MaxCharge)) or 0
	for index, tear in ipairs(self:GetHeldTears(data)) do
		local tearData = InvertedCrossTear:GetData(tear)
		local directionOffset = directions[index] or directions[#directions] or 0
		local direction = Vector.FromAngle(aimAngle + directionOffset)
		tearData.DirectionOffset = directionOffset
		tearData.AimDirection = direction
		InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
		tear.Position = source.Position + InitInfo.PositionOffset
			+ direction * (InitInfo.OffsetLength + tear.Scale * 15)
		tear.Velocity = Vector.Zero
	end
end

--悬浮科技和玄秘魔眼共用独立指挥状态机,并优先覆盖海王星
local RemoteControlInfo = {
	MoveSpeed = InitInfo.ShotSpeedMul, --与普通引弹一致,不随面板弹速改变
	VelocityInheritance = 0.2, --参考粉毛剑士,保留少量上一帧速度
	ChargePerFrame = 1,
	DischargePerFrame = 1,
}

--海王星独立使用自动蓄力和单发消耗,不进入指挥模式
local NeptuneInfo = {
	ChargePerFrame = 1,
	ChargeCost = 0.2, --每次发射消耗20%最大蓄力
}

--特殊攻击模式;同时持有时,悬浮科技或玄秘魔眼优先于海王星
function BAzazel:GetAttackMode(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
		return 'RemoteControl'
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
		return 'Neptune'
	end
	return false
end

--切换特殊攻击模式时清理当前持有的引弹,避免状态串用
function BAzazel:ChangeAttackMode(player, data, mode)
	for _, tear in ipairs(data.InvertedCrossTears) do
		if tear and tear:Exists() and not tear:IsDead() then
			local tearData = InvertedCrossTear:GetData(tear)
			tearData.IsRemoteControl = false
			tearData.RemoteControlMoving = false
			tearData.RemoteControlEmitLight = false
			InvertedCrossTear:Disappear(tear)
		end
	end

	data.InvertedCrossTears = {}
	data.SpecialDirections = nil
	data.AttackMode = mode
	data.Charge = 0
	data.MaxCharge = mode and self:GetChargeTime(player) or 0
	data.ChargeCooldown = 0
	data.AimAngle = nil
end

--生成一组指挥引弹;多射数量与弹道在生成时锁定,出生方向不做鼠标正方向吸附
function BAzazel:SpawnRemoteControlTears(player, data, source)
	source = source or self:GetAttackSource(player)
	local aim = self:GetAimingVector(player, source, source.Position)
	if aim:Length() <= 0 then
		aim = player:GetLastDirection()
	end
	if aim:Length() <= 0 then return data.InvertedCrossTears end

	data.SpecialDirections = self:GetSpecialDirections(player)
	data.DirectionOffsets = self:GetInvertedCrossDirections(player, data.SpecialDirections)
	data.InvertedCrossTears = {}
	local aimAngle = aim:GetAngleDegrees()
	for _, directionOffset in ipairs(data.DirectionOffsets) do
		local direction = Vector.FromAngle(aimAngle + directionOffset)
		local position = source.Position + InitInfo.PositionOffset
			+ direction * (InitInfo.OffsetLength + 15)
		position = game:GetRoom():GetClampedPosition(position, 0)
		local tear = InvertedCrossTear:Spawn(player, position, directionOffset, source)
		if tear then
			local tearData = InvertedCrossTear:GetData(tear)
			tearData.IsRemoteControl = true
			tearData.RemoteControlMoving = true
			tearData.RemoteControlEmitLight = false
			table.insert(data.InvertedCrossTears, tear)
		end
	end
	if #data.InvertedCrossTears > 0 then
		self:DoBlackFormSwing(player, data, source, aimAngle, true)
	end
	return data.InvertedCrossTears
end

--整组共用一份蓄力;各引弹沿锁定的偏移方向移动,停止后统一消失并进入冷却(英灵剑除外)
function BAzazel:UpdateRemoteControl(player, data, source)
	source = source or self:GetAttackSource(player)
	local ignoreChargeCooldown = (player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK))
	data.MaxCharge = self:GetChargeTime(player)
	data.Charge = math.max(0, math.min(data.MaxCharge, data.Charge or 0))
	if ignoreChargeCooldown then
		data.ChargeCooldown = 0
	else
		data.ChargeCooldown = math.max(0, (data.ChargeCooldown or 0) - 1)
	end

	local firing = self:IsFiring(player)
	--相反射击方向抵消时没有有效指挥方向,视为松手蓄力,避免生成后同帧销毁并循环
	if firing and self:GetAimingVector(player, source, source.Position):Length() <= 0 then
		firing = false
	end
	local hadTears = #data.InvertedCrossTears > 0
	local tears = self:GetHeldTears(data)
	--整组被外部移除时同样进入冷却,且每次消失只设置一次;英灵剑始终跳过
	if hadTears and #tears <= 0 and not ignoreChargeCooldown then
		data.ChargeCooldown = math.max(data.ChargeCooldown, math.max(1, player.MaxFireDelay))
	end

	if firing and #tears <= 0 and data.ChargeCooldown <= 0 then
		tears = self:SpawnRemoteControlTears(player, data, source)
	end

	if #tears <= 0 then
		if not firing and data.ChargeCooldown <= 0 then
			data.Charge = math.min(data.MaxCharge,
				data.Charge + self:GetChargeGain(player, RemoteControlInfo.ChargePerFrame))
		end
		return
	end

	--鼠标和准星以首枚引弹为原点计算共同方向,再叠加每枚引弹的固定偏移
	local aim = firing and self:GetAimingVector(player, source, tears[1].Position) or Vector.Zero
	local moving = firing and aim:Length() > 0
	local chargeRatio = data.MaxCharge > 0 and data.Charge / data.MaxCharge or 0

	if not moving then
		for _, tear in ipairs(tears) do
			local tearData = InvertedCrossTear:GetData(tear)
			InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
			tearData.RemoteControlMoving = false
			tearData.RemoteControlEmitLight = false
			InvertedCrossTear:Disappear(tear)
		end
		data.InvertedCrossTears = {}
		data.SpecialDirections = nil
		data.DirectionOffsets = nil
		data.ChargeCooldown = ignoreChargeCooldown and 0 or math.max(1, player.MaxFireDelay)
		return
	end

	--本帧耗能前仍有充能,就允许整组继续降下圣光;耗尽后仍可自由移动
	local hasCharge = data.Charge > 0
	data.Charge = math.max(0, data.Charge - RemoteControlInfo.DischargePerFrame)
	chargeRatio = data.MaxCharge > 0 and data.Charge / data.MaxCharge or 0
	local room = game:GetRoom()
	local aimAngle = aim:GetAngleDegrees()
	for _, tear in ipairs(tears) do
		local tearData = InvertedCrossTear:GetData(tear)
		local direction = Vector.FromAngle(aimAngle + (tearData.DirectionOffset or 0))
		local velocity = tear.Velocity * RemoteControlInfo.VelocityInheritance
			+ direction * RemoteControlInfo.MoveSpeed

		--每枚引弹分别限制在房间内;已经越界的先钳回最近的合法位置
		local margin = math.max(0, tear.Size)
		if not room:IsPositionInRoom(tear.Position, margin) then
			tear.Position = room:GetClampedPosition(tear.Position, margin)
			velocity = Vector.Zero
		end
		local nextPosition = self._Maths:MoveInRoom(tear.Position, velocity, margin)
		tear.Velocity = nextPosition - tear.Position
		tearData.AimDirection = direction
		tearData.RemoteControlMoving = true
		tearData.RemoteControlEmitLight = hasCharge
		InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
	end
end

--海王星按锁定的多眼弹道整组齐射,所有引弹共用当前蓄力比例
function BAzazel:FireNeptuneTear(player, data, source)
	source = source or self:GetAttackSource(player)
	local chargeRatio = data.MaxCharge > 0
		and math.max(0, math.min(1, data.Charge / data.MaxCharge)) or 0
	local aimAngle = self:UpdateAimAngle(player, data, true, source)
	local fired = false
	for _, directionOffset in ipairs(data.DirectionOffsets or {0}) do
		local direction = Vector.FromAngle(aimAngle + directionOffset)
		local position = source.Position + InitInfo.PositionOffset
			+ direction * (InitInfo.OffsetLength + 15)
		local tear = InvertedCrossTear:Spawn(player, position, directionOffset, source)
		if tear then
			fired = true
			InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
			InvertedCrossTear:Release(tear, direction, InitInfo.ShotSpeedMul,
				player.TearRange * InitInfo.RangeMul * chargeRatio, chargeRatio, player)
		end
	end
	if not fired then return false end

	self:DoBlackFormSwing(player, data, source, aimAngle, false)
	self:QueueTrailingTears(player, data, aimAngle, chargeRatio, source)
	data.InvertedCrossTears = {}
	data.SpecialDirections = nil
	data.DirectionOffsets = nil
	data.Charge = math.max(0, data.Charge - data.MaxCharge * NeptuneInfo.ChargeCost)
	data.ChargeCooldown = math.max(1, player.MaxFireDelay)
	return true
end

--海王星平时自动蓄力,攻击时按射击间隔整组齐射;持续按住不会恢复充能
function BAzazel:UpdateNeptune(player, data, source)
	source = source or self:GetAttackSource(player)
	data.MaxCharge = self:GetChargeTime(player)
	data.Charge = math.max(0, math.min(data.MaxCharge, data.Charge or 0))
	data.ChargeCooldown = math.max(0, (data.ChargeCooldown or 0) - 1)

	--每轮自动蓄力只抽取一次弹道,直到本轮齐射结束后再为下一轮重新抽取
	if not data.DirectionOffsets then
		data.SpecialDirections = self:GetSpecialDirections(player)
		data.DirectionOffsets = self:GetInvertedCrossDirections(player, data.SpecialDirections)
	end

	if self:IsFiring(player) then
		if data.Charge > 0 and data.ChargeCooldown <= 0 then
			self:FireNeptuneTear(player, data, source)
		end
	else
		data.Charge = math.min(data.MaxCharge,
			data.Charge + self:GetChargeGain(player, NeptuneInfo.ChargePerFrame))
	end
end

--铅笔触发时额外释放8枚随机方向的引导弹
function BAzazel:FirePencilTears(player, data, chargeRatio, source, autoRelease)
	source = source or self:GetAttackSource(player)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LEAD_PENCIL)
	for _ = 1, 8 do
		local direction = data.AimAngle + rng:RandomInt(60) - 30
		local scale = (rng:RandomInt(11) + 5) * 0.1
		local speed = InitInfo.ShotSpeedMul * (rng:RandomInt(11) + 5) * 0.1
		local position = source.Position + InitInfo.PositionOffset
			+ Vector.FromAngle(data.AimAngle) * (InitInfo.OffsetLength + 15)
		local tear = InvertedCrossTear:Spawn(player, position, direction - data.AimAngle, source)
		if tear then
			local tearData = InvertedCrossTear:GetData(tear)
			tearData.BaseScale = tearData.BaseScale * scale
			InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
			InvertedCrossTear:Release(tear, Vector.FromAngle(direction), speed,
				player.TearRange * InitInfo.RangeMul * chargeRatio, chargeRatio, player, autoRelease)
		end
	end
end

--诅咒眼和三圣颂只沿主攻击方向追加泪弹,不重复多眼及额外方向
local CursedEyeInfo = {
	MaxExtraTears = 4,
	Interval = 5,
}

local TrisagionInfo = {
	MaxExtraTears = 8,
	Interval = 5,
}

--沿用原版的蓄力档位:越过各档阈值追加,满蓄力再追加最后一枚
function BAzazel:GetTrailingExtraTears(chargeRatio, maxExtraTears)
	chargeRatio = math.max(0, math.min(1, chargeRatio or 0))
	local count = math.max(0, math.ceil(chargeRatio * maxExtraTears) - 1)
	if chargeRatio >= 1 then
		count = count + 1
	end
	return math.min(maxExtraTears, count)
end

function BAzazel:GetCursedEyeExtraTears(chargeRatio)
	return self:GetTrailingExtraTears(chargeRatio, CursedEyeInfo.MaxExtraTears)
end

function BAzazel:GetTrisagionExtraTears(chargeRatio)
	return self:GetTrailingExtraTears(chargeRatio, TrisagionInfo.MaxExtraTears)
end

--为每次释放独立记录追加射击,连续释放不会覆盖上一组尚未发射的引弹
function BAzazel:QueueCursedEyeTears(player, data, aimAngle, chargeRatio, source, autoRelease)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then return end
	source = source or self:GetAttackSource(player)

	local extraTears = self:GetCursedEyeExtraTears(chargeRatio)
	if extraTears <= 0 then return end
	data.CursedEyeShots = data.CursedEyeShots or {}
	for index = 1, extraTears do
		table.insert(data.CursedEyeShots, {
			Delay = index * CursedEyeInfo.Interval,
			AimAngle = aimAngle or 0,
			Range = player.TearRange * InitInfo.RangeMul * chargeRatio,
			ChargeRatio = chargeRatio,
			AutoRelease = autoRelease,
		})
	end
end

function BAzazel:UpdateCursedEyeTears(player, data, source)
	source = source or self:GetAttackSource(player)
	local shots = data.CursedEyeShots
	if not shots then return end
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
		data.CursedEyeShots = nil
		return
	end

	for index = #shots, 1, -1 do
		local shot = shots[index]
		shot.Delay = shot.Delay - 1
		if shot.Delay <= 0 then
			local direction = Vector.FromAngle(shot.AimAngle)
			local position = source.Position + InitInfo.PositionOffset
				+ direction * (InitInfo.OffsetLength + 15)
			local tear = InvertedCrossTear:Spawn(player, position, 0, source)
			if tear then
				InvertedCrossTear:UpdateChargeScale(tear, player, shot.ChargeRatio)
				InvertedCrossTear:Release(tear, direction, InitInfo.ShotSpeedMul,
					shot.Range, shot.ChargeRatio, player, shot.AutoRelease)
				table.remove(shots, index)
			else
				shot.Delay = 1
			end
		end
	end
	if #shots <= 0 then
		data.CursedEyeShots = nil
	end
end

--三圣颂与诅咒眼使用独立队列,即使未持有诅咒眼也会正常尾随发射
function BAzazel:QueueTrisagionTears(player, data, aimAngle, chargeRatio, source)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then return end
	source = source or self:GetAttackSource(player)

	local extraTears = self:GetTrisagionExtraTears(chargeRatio)
	if extraTears <= 0 then return end
	local familiarInfo = InvertedCrossTear:GetFamiliarAttackInfo(source)
	data.TrisagionShots = data.TrisagionShots or {}
	for index = 1, extraTears do
		table.insert(data.TrisagionShots, {
			Delay = index * TrisagionInfo.Interval,
			AimAngle = aimAngle or 0,
			DamageMultiplier = familiarInfo and familiarInfo.DamageMultiplier or 1,
		})
	end
end

function BAzazel:UpdateTrisagionTears(player, data, source)
	source = source or self:GetAttackSource(player)
	local shots = data.TrisagionShots
	if not shots then return end
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
		data.TrisagionShots = nil
		return
	end

	for index = #shots, 1, -1 do
		local shot = shots[index]
		shot.Delay = shot.Delay - 1
		if shot.Delay <= 0 then
			local direction = Vector.FromAngle(shot.AimAngle)
			local position = source.Position + InitInfo.PositionOffset
				+ direction * (InitInfo.OffsetLength + 15)
			local tear = player:FireTear(position, direction * player.ShotSpeed * InitInfo.ShotSpeedMul,
				false, true, true, player, shot.DamageMultiplier)
			if tear then
				tear:AddTearFlags(TearFlags.TEAR_LASERSHOT)
				table.remove(shots, index)
			else
				shot.Delay = 1
			end
		end
	end
	if #shots <= 0 then
		data.TrisagionShots = nil
	end
end

function BAzazel:QueueTrailingTears(player, data, aimAngle, chargeRatio, source, autoRelease)
	self:QueueCursedEyeTears(player, data, aimAngle, chargeRatio, source, autoRelease)
	self:QueueTrisagionTears(player, data, aimAngle, chargeRatio, source)
end

--未满蓄力时只播放引弹自身消失动画,不执行任何移除时兼容
function BAzazel:CancelCharge(player, data)
	for _, tear in ipairs(self:GetHeldTears(data)) do
		InvertedCrossTear:Disappear(tear, false)
	end
	data.InvertedCrossTears = {}
	data.SpecialDirections = nil
	data.DirectionOffsets = nil
	data.Charge = 0
	data.MaxCharge = 0
	data.ChargeCooldown = (player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK))
		and 0 or math.max(1, player.MaxFireDelay)
end

--根据蓄力程度决定飞行距离,释放后进入蓄力冷却;自动释放标记会传递给反重力等待
function BAzazel:ReleaseCharge(player, data, source, autoRelease)
	source = source or self:GetAttackSource(player)
	local tears = self:GetHeldTears(data)
	local speed = InitInfo.ShotSpeedMul
	local maxCharge = data.MaxCharge
	local charge = data.Charge
	local chargeRatio = maxCharge > 0 and math.max(0, math.min(1, charge / maxCharge)) or 0
	if self:IsBlackForm(player) and chargeRatio < 1 then
		self:CancelCharge(player, data)
		return
	end
	for _, tear in ipairs(tears) do
		local tearData = InvertedCrossTear:GetData(tear)
		local direction = Vector.FromAngle(data.AimAngle + tearData.DirectionOffset)
		InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
		InvertedCrossTear:Release(tear, direction, speed, player.TearRange * InitInfo.RangeMul * chargeRatio, chargeRatio, player, autoRelease)

		if player:HasCollectible(CollectibleType.COLLECTIBLE_LEAD_PENCIL) then
			data.PencilCount = (data.PencilCount or 0) + 1
			if data.PencilCount >= 15 then
				data.PencilCount = data.PencilCount - 15
				self:FirePencilTears(player, data, chargeRatio, source, autoRelease)
			end
		end
	end
	if #tears > 0 then
		self:QueueTrailingTears(player, data, data.AimAngle, chargeRatio, source, autoRelease)
	end
	data.InvertedCrossTears = {}
	data.SpecialDirections = nil
	data.DirectionOffsets = nil
	data.Charge = 0
	data.MaxCharge = 0
	data.ChargeCooldown = (player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK))
		and 0 or math.max(1, player.MaxFireDelay)
end

--屏蔽吐根的原版效果并保留自定义兼容,失去后解除屏蔽,重新获得后再次屏蔽
function BAzazel:UpdateIpecacBlockTest(player, data)
	if not REPENTOGON
	or type(player.BlockCollectible) ~= 'function'
	or type(player.UnblockCollectible) ~= 'function'
	or type(player.IsCollectibleBlocked) ~= 'function'
	or type(player.GetCollectiblesList) ~= 'function' then return end

	local id = CollectibleType.COLLECTIBLE_IPECAC
	--屏蔽后HasCollectible为false,真实库存才能区分持有和已经失去
	local owned = (player:GetCollectiblesList()[id] or 0) > 0
	if not owned then
		if data.BlockedIpecac then
			if player:IsCollectibleBlocked(id) then
				player:UnblockCollectible(id)
			end
			data.BlockedIpecac = nil
			data.IpecacBlockTestLogDelay = nil
			data.IpecacBlockTestHasBefore = nil
			data.IpecacBlockTestDamageBefore = nil
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
		end
		return
	end

	if data.IpecacBlockTestLogDelay then
		data.IpecacBlockTestLogDelay = data.IpecacBlockTestLogDelay - 1
		if data.IpecacBlockTestLogDelay <= 0 then
			local inventoryCount = player:GetCollectiblesList()[id] or 0
			Isaac.DebugString(string.format(
				'[IBS] Ipecac block test: HasCollectible %s -> %s; Blocked=%s; Inventory=%d; Damage %.3f -> %.3f',
				tostring(data.IpecacBlockTestHasBefore), tostring(player:HasCollectible(id)),
				tostring(player:IsCollectibleBlocked(id)), inventoryCount,
				data.IpecacBlockTestDamageBefore or 0, player.Damage))
			data.IpecacBlockTestLogDelay = nil
		end
	end
	if data.BlockedIpecac then return end

	data.IpecacBlockTestHasBefore = player:HasCollectible(id)
	data.IpecacBlockTestDamageBefore = player.Damage
	player:BlockCollectible(id)
	data.BlockedIpecac = true
	data.IpecacBlockTestLogDelay = 2
	player:AddCacheFlags(CacheFlag.CACHE_ALL)
	player:EvaluateItems()
end

--屏蔽胎儿博士的原版属性修正;失去后解除,重新获得后再次屏蔽
function BAzazel:UpdateDrFetusBlock(player, data)
	if not REPENTOGON
	or type(player.BlockCollectible) ~= 'function'
	or type(player.UnblockCollectible) ~= 'function'
	or type(player.IsCollectibleBlocked) ~= 'function'
	or type(player.GetCollectiblesList) ~= 'function' then return end

	local id = CollectibleType.COLLECTIBLE_DR_FETUS
	local owned = (player:GetCollectiblesList()[id] or 0) > 0
	if not owned then
		if data.BlockedDrFetus then
			if player:IsCollectibleBlocked(id) then
				player:UnblockCollectible(id)
			end
			data.BlockedDrFetus = nil
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
		end
		return
	end

	if data.BlockedDrFetus then return end
	if not player:IsCollectibleBlocked(id) then
		player:BlockCollectible(id)
	end
	data.BlockedDrFetus = true
	player:AddCacheFlags(CacheFlag.CACHE_ALL)
	player:EvaluateItems()
end

--这两个道具不会替换主武器,只清零其原生蓄力,保留自定义引弹兼容
function BAzazel:SuppressDefaultChargedAttacks(player)
	if player:GetPlayerType() ~= self.ID then return end
	if not REPENTOGON or type(player.GetWeapon) ~= 'function' then return end
	if not player:GetWeapon(1) then return end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_REVELATION)
	and type(player.SetRevelationCharge) == 'function' then
		player:SetRevelationCharge(0)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID)
	and type(player.SetMawOfTheVoidCharge) == 'function' then
		player:SetMawOfTheVoidCharge(0)
	end
end
BAzazel:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, 'SuppressDefaultChargedAttacks')

--所有攻击源执行同一套状态机,输入相同但蓄力、冷却及引弹引用各自独立
function BAzazel:UpdateAttack(player, source)
	local data = self:GetTempData(source)
	--心脏和玩家共用状态;攻击中心变化时同步现有引弹,不重建也不触发释放
	for _, tear in ipairs(data.InvertedCrossTears) do
		if tear and tear:Exists() then
			local tearData = InvertedCrossTear:GetData(tear)
			tearData.SourcePlayer = player
			tearData.SourceEntity = source
			tear.SpawnerEntity = source
		end
	end

	self:UpdateCursedEyeTears(player, data, source)
	self:UpdateTrisagionTears(player, data, source)
	local attackMode = self:GetAttackMode(player)
	if attackMode ~= (data.AttackMode or false) then
		self:ChangeAttackMode(player, data, attackMode)
	end
	if attackMode == 'RemoteControl' then
		self:UpdateRemoteControl(player, data, source)
		return
	elseif attackMode == 'Neptune' then
		self:UpdateNeptune(player, data, source)
		return
	end

	local firing = self:IsFiring(player)
	local tears = self:GetHeldTears(data)
	if (player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)) then
		data.ChargeCooldown = 0
	else
		data.ChargeCooldown = math.max(0, (data.ChargeCooldown or 0) - 1)
	end

	if firing and player:IsExtraAnimationFinished() and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		if #tears <= 0 and data.ChargeCooldown <= 0 then
			tears = self:SpawnInvertedCrossTears(player, data, source)
		end
		if #tears <= 0 then return end

		self:UpdateFloatingTears(player, data, source)
		data.Charge = math.min(data.MaxCharge, data.Charge + self:GetChargeGain(player, 1))

		if data.Charge >= data.MaxCharge and self:ShouldAutoRelease(player) then
			self:ReleaseCharge(player, data, source, true)
		end
	elseif #tears > 0 then
		self:ReleaseCharge(player, data, source)
	else
		data.Charge = 0
		data.MaxCharge = 0
	end
end

--角色更新;在玩家更新中统一驱动复制攻击的跟班
function BAzazel:OnPlayerUpdate(player)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetTempData(player)
	self:UpdateIpecacBlockTest(player, data)
	self:UpdateDrFetusBlock(player, data)
	for _, source in ipairs(self:GetAttackSources(player)) do
		if source and source:Exists() then
			self:UpdateAttack(player, source)
		end
	end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--蓄力条
function BAzazel:OnPlayerRender(player, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetTempData(self:GetAttackSource(player))
	local bar = data.ChargeBar
	local charge, maxCharge
	
	--黑色形态下蓄力条改色
	if self:IsBlackForm(player) then
		data.ChargeBar.Color = Color(1,0,0,1)	
	else
		data.ChargeBar.Color = Color(1,1,1,1)
	end
	
	if data.AttackMode then
		--特殊攻击待机充能时没有引弹,也要直接显示当前充能
		charge = data.Charge or 0
		maxCharge = data.MaxCharge > 0 and data.MaxCharge or self:GetChargeTime(player)
	else
		local charging = #self:GetHeldTears(data) > 0 and data.MaxCharge > 0 and data.Charge > 0
		charge = charging and data.Charge or 0
		maxCharge = charging and data.MaxCharge or self:GetChargeTime(player)
	end

	--特殊攻击模式显示自动蓄力,普通模式只在持有悬浮引弹时显示充能
	if charge > 0 and maxCharge > 0 then
		if charge >= maxCharge then
			local animation = bar:GetAnimation()
			if animation ~= 'StartCharged' and animation ~= 'Charged' then
				bar:Play('StartCharged')
			end
			if bar:IsFinished('StartCharged') then
				bar:Play('Charged')
			end
			if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then bar:Update() end
		else
			bar:SetFrame('Charging', math.min(100, math.floor(100 * charge / maxCharge)))
		end
	else
		bar:Play('Disappear')
		if not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 then bar:Update() end
	end

	local position = self._Screens:GetEntityRenderPosition(player, Vector(-12, -39) + offset)
	bar:Render(position)

	local timeout = data.ProgressHintTimeout or 0
	if timeout > 0 then
		if not game:IsPaused() then
			timeout = timeout - 1
			data.ProgressHintTimeout = timeout
		end

		local alpha = math.min(timeout, 30) / 30
		local headOffset = player.SpriteScale.Y * 48 + 4
		local rise = self.ProgressHintDuration - timeout
		local hintPos = self._Screens:GetEntityRenderPosition(player,
			offset + Vector(-8, -headOffset - rise))
		local formData = self:GetData(player)
		if data.ProgressHintType == 'Spike' then
			local text = string.format('%d/%d',
				math.min(formData.SpikeDealCount, self.BlackFormInfo.RequiredSpikeDeals),
				self.BlackFormInfo.RequiredSpikeDeals)
			ProgressHintFont:DrawString(text, hintPos.X, hintPos.Y,
				KColor(1, 0, 0, alpha, 0, 0, 0), 0, true)
		elseif data.ProgressHintType == 'Kill' then
			local killCount = formData.RedemptionKillCount or 0
			local text = string.format('%d/%d',
				math.min(killCount, self.BlackFormInfo.RedemptionKillRequirement),
				self.BlackFormInfo.RedemptionKillRequirement)
			ProgressHintFont:DrawString(text, hintPos.X, hintPos.Y,
				KColor(1, 1, 1, alpha, 0, 0, 0), 0, true)
		end
	end
end
BAzazel:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerRender', 0)

function BAzazel:OnEvaluateCache(player, flag)
	if player:GetPlayerType() ~= self.ID then return end

	if flag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.1
	elseif flag == CacheFlag.CACHE_FIREDELAY then
		self._Stats:TearsModifier(player, 0.25)
		self._Stats:TearsMultiples(player, 0.3)
		--保留硫磺火原生兼容,以三倍射速补偿其原生射速惩罚
		if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
			self._Stats:TearsMultiples(player, 3)
		end
	elseif flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 1.5
	elseif flag == CacheFlag.CACHE_TEARFLAG then
		player.TearFlags = player.TearFlags & (~InvertedCrossTear.PermanentTearFlags)
	elseif flag == CacheFlag.CACHE_FLYING then
		player.CanFly = true
	end
end
BAzazel:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')

--神秘测伤土豆特殊兼容
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_,npc)
	if npc.Variant == 2 and npc:IsFrame(30,0) and PlayerManager.AnyoneIsPlayerType(BAzazel.ID) then		
		npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
	end
end, 231)


return BAzazel
