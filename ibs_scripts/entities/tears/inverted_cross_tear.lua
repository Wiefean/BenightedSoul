--倒十字架眼泪

local mod = Isaac_BenightedSoul
local IBS_TearID = mod.IBS_TearID

local sfx = SFXManager()

local InvertedCrossTear = mod.IBS_Class.Tear{
	Variant = IBS_TearID.InvertedCrossTear.Variant,
	SubType = IBS_TearID.InvertedCrossTear.SubType,
	Name = {zh = '倒十字架眼泪', en = 'Inverted Cross Tear'}
}

--双生宝和莉莉宝的攻击倍率;角色模块直接引用此表,避免两处配置不一致
InvertedCrossTear.FamiliarAttackInfo = {
	[FamiliarVariant.INCUBUS] = {Scale = 0.8, DamageMultiplier = 0.75},
	[FamiliarVariant.TWISTED_BABY] = {Scale = 0.8, DamageMultiplier = 0.375},
}

--显式记录攻击中心;原生生成链经过跟班时也能找回所属玩家
function InvertedCrossTear:GetPlayer(tear)
	local data = self._Ents:GetTempData(tear).InvertedCrossTear
	if data and data.SourcePlayer and data.SourcePlayer:Exists() then
		return data.SourcePlayer
	end

	local spawner = tear.SpawnerEntity
	while spawner and spawner:Exists() do
		local player = spawner:ToPlayer()
		if player then return player end
		local familiar = spawner:ToFamiliar()
		if familiar and familiar.Player then return familiar.Player end
		spawner = spawner.SpawnerEntity
	end
	return self._Ents:GetSourcePlayer(tear)
end

function InvertedCrossTear:GetSourceEntity(tear)
	local data = self._Ents:GetTempData(tear).InvertedCrossTear
	if data and data.SourceEntity and data.SourceEntity:Exists() then
		return data.SourceEntity
	end
	local spawner = tear.SpawnerEntity
	if spawner and spawner:Exists() and (spawner:ToPlayer() or spawner:ToFamiliar()) then
		return spawner
	end
	return self:GetPlayer(tear) or tear
end

function InvertedCrossTear:SetTouchedFlags(tear, touched)
	if not tear then return end
	if type(tear.SetMultidimensionalTouched) == 'function' then
		tear:SetMultidimensionalTouched(touched)
	end
	if type(tear.SetPrismTouched) == 'function' then
		tear:SetPrismTouched(touched)
	end
end

function InvertedCrossTear:GetFamiliarAttackInfo(source)
	local familiar = source and source:ToFamiliar()
	return familiar and self.FamiliarAttackInfo[familiar.Variant] or nil
end

--true:从角色和引导弹上永久清除;false:先捕获,释放时按LightOnlyTearFlags决定是否恢复
local NeedClearedFlags = {
	[TearFlags.TEAR_OCCULT] = false,
	[TearFlags.TEAR_SHRINK] = true,
	[TearFlags.TEAR_GROW] = true,
	[TearFlags.TEAR_LASERSHOT] = true,
	[TearFlags.TEAR_ABSORB] = false,
	[TearFlags.TEAR_POP] = false,
	[TearFlags.TEAR_BOOMERANG] = false,
	[TearFlags.TEAR_EXPLOSIVE] = true,
	[TearFlags.TEAR_ORBIT] = false,
	[TearFlags.TEAR_SPLIT] = true,
	[TearFlags.TEAR_HOMING] = false,
	[TearFlags.TEAR_PULSE] = false,
	[TearFlags.TEAR_TURN_HORIZONTAL] = false,
	[TearFlags.TEAR_WIGGLE] = false,
	[TearFlags.TEAR_SQUARE] = false,
	[TearFlags.TEAR_SPIRAL] = false,
	[TearFlags.TEAR_BIG_SPIRAL] = false,
	[TearFlags.TEAR_LIGHT_FROM_HEAVEN] = true,
	[TearFlags.TEAR_BOUNCE] = false,
}

--这些旗标由引弹状态机接管,释放时不能恢复为原生泪弹行为
InvertedCrossTear.NeverRestoreTearFlags =
	TearFlags.TEAR_HOMING
	| TearFlags.TEAR_WIGGLE
	| TearFlags.TEAR_SQUARE
	| TearFlags.TEAR_SPIRAL
	| TearFlags.TEAR_BIG_SPIRAL
	| TearFlags.TEAR_ORBIT
	| TearFlags.TEAR_BOOMERANG

InvertedCrossTear.PermanentTearFlags = 0
for flag, permanent in pairs(NeedClearedFlags) do
	if permanent then
		InvertedCrossTear.PermanentTearFlags = InvertedCrossTear.PermanentTearFlags | flag
	end
end

InvertedCrossTear.WormPatterns = {
	{Flag = TearFlags.TEAR_BIG_SPIRAL, Pattern = 'Spiral'},
	{Flag = TearFlags.TEAR_SPIRAL, Pattern = 'SmallSpiral'},
	{Flag = TearFlags.TEAR_SQUARE, Pattern = 'Square'},
	{Flag = TearFlags.TEAR_WIGGLE, Pattern = 'Wiggle'},
}

--这些玩家泪弹variant会自动转换为引弹
InvertedCrossTear.ConvertibleVariants = {
	[TearVariant.EXPLOSIVO] = true,
	--[TearVariant.BONE] = true,
	[TearVariant.MULTIDIMENSIONAL] = true,
	[TearVariant.BELIAL] = true,
}

InvertedCrossTear.EyeOfBelialInfo = {
	DamageMultiplier = 2,
	ScaleMultiplier = 1.5,
	Color = Color(1, 0, 0, 1, 0, 0, 0),
}

InvertedCrossTear.BlackFormInfo = {
	ScaleMultiplier = 0.75,
	SpeedMultiplier = 3,
	FlightFrames = 60,
	TearColor = Color(1, 0, 0, 1, 0, 0, 0),
}

InvertedCrossTear.MyReflectionInfo = {
	CopyAlpha = 0.3,
}

--直接读取角色整局数据,避免角色模块与引弹模块相互加载
function InvertedCrossTear:IsBlackForm(player)
	if not player or player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return false end
	local data = self._Players:GetData(player).BAzazelForm
	return data ~= nil and data.BlackForm == true
end

--初始Scale倍率;同组道具只生效一个
InvertedCrossTear.ScaleMultipliers = {
	[CollectibleType.COLLECTIBLE_SOY_MILK] = 0.5,
	[CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.5,
	[CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
	[CollectibleType.COLLECTIBLE_SPIRIT_SWORD] = 1.5,
	[CollectibleType.COLLECTIBLE_SACRED_HEART] = 1.5,
}
InvertedCrossTear.ScaleMultiplierGroups = {
	[CollectibleType.COLLECTIBLE_SOY_MILK] = 'Milk',
	[CollectibleType.COLLECTIBLE_ALMOND_MILK] = 'Milk',
}
InvertedCrossTear.PulseWormScaleMultiplier = 1.5

function InvertedCrossTear:GetInitialScaleMultiplier(player)
	local result = 1
	if not player then return result end

	local usedGroups = {}
	for collectible, multiplier in pairs(self.ScaleMultipliers) do
		local group = self.ScaleMultiplierGroups[collectible]
		if player:HasCollectible(collectible) and (not group or not usedGroups[group]) then
			result = result * multiplier
			if group then usedGroups[group] = true end
		end
	end
	if self:IsBlackForm(player) then
		result = result * self.BlackFormInfo.ScaleMultiplier
	end
	if player:HasTrinket(TrinketType.TRINKET_PULSE_WORM) then
		result = result * self.PulseWormScaleMultiplier
	end
	return result
end

--巧克力牛奶:蓄力体积在0.5至2倍间线性增长
function InvertedCrossTear:GetChargeScaleMultiplier(player, chargeRatio)
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
		chargeRatio = math.max(0, math.min(1, chargeRatio or 0))
		return 0.5 + chargeRatio * 1.5
	end
	return 1
end

InvertedCrossTear.ProptosisInfo = {
	InitialDamageMultiplier = 3,
	InitialScaleMultiplier = 2,
	MinimumMultiplier = 0.3,
	DistanceBase = 500,
}

InvertedCrossTear.LumpOfCoalInfo = {
	DistanceBase = 500,
}

--同时持有时保留眼球突出的初始增益,但不再随距离缩放
function InvertedCrossTear:GetDistanceMultipliers(tear, player)
	if not player then return 1, 1 end
	local hasProptosis = player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS)
	local hasCoal = player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
	local proptosisInfo = self.ProptosisInfo
	if hasProptosis and hasCoal then
		return proptosisInfo.InitialDamageMultiplier, proptosisInfo.InitialScaleMultiplier
	elseif not hasProptosis and not hasCoal then
		return 1, 1
	end

	local distanceBase = hasProptosis and proptosisInfo.DistanceBase or self.LumpOfCoalInfo.DistanceBase
	local distance = tear.Position:Distance(player.Position)
	if hasProptosis then
		local distanceMultiplier = distanceBase / (distanceBase + distance)
		return math.max(proptosisInfo.MinimumMultiplier, proptosisInfo.InitialDamageMultiplier * distanceMultiplier),
			math.max(proptosisInfo.MinimumMultiplier, proptosisInfo.InitialScaleMultiplier * distanceMultiplier)
	end

	local distanceMultiplier = (distanceBase + distance) / distanceBase
	return distanceMultiplier, distanceMultiplier
end

function InvertedCrossTear:GetDistanceDamageMultiplier(tear, player)
	local damageMultiplier = self:GetDistanceMultipliers(tear, player)
	return damageMultiplier
end

function InvertedCrossTear:InitializeDistanceItems(tear, player)
	local data = self:GetData(tear)
	data.DistanceDamageMultiplier, data.DistanceScaleMultiplier = self:GetDistanceMultipliers(tear, player)
end

--以初始尺寸为基准更新蓄力及距离道具尺寸,避免逐帧重复叠乘
function InvertedCrossTear:UpdateChargeScale(tear, player, chargeRatio)
	local data = self:GetData(tear)
	chargeRatio = math.max(0, math.min(1, chargeRatio or 0))
	data.ChargeRatio = chargeRatio
	data.BaseScale = data.BaseScale or tear.Scale
	tear.Scale = data.BaseScale * self:GetChargeScaleMultiplier(player, chargeRatio)
		* (data.DistanceScaleMultiplier or 1)
		* (data.BelialScaleMultiplier or 1)
		* (data.AlternateScaleMultiplier or 1)
end

--眼球突出/煤块与巧克力牛奶分别作用于周期圣光伤害,可相互叠乘;不直接绑定引弹Scale
--巧克力奶蓄力倍率从0.5线性增长至4
function InvertedCrossTear:GetHolyLightDamageMultiplier(tear, player)
	local data = self:GetData(tear)
	local multiplier = self:GetDistanceDamageMultiplier(tear, player)
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
		local chargeRatio = math.max(0, math.min(1, data.ChargeRatio or 0))
		multiplier = multiplier * (0.5 + chargeRatio * 3.5)
	end
	return multiplier
end

--悬浮、飞行、妈刀返程及遥控状态都按当前距离更新,不再随时间单向变化
function InvertedCrossTear:UpdateDistanceItems(tear)
	local data = self:GetData(tear)
	local player = self:GetPlayer(tear)
	local hasDistanceScaleItem = player and (
		player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
	)
	local isFlying = not data.IsFloating
		or (data.IsRemoteControl and data.RemoteControlMoving)
	if isFlying and not hasDistanceScaleItem then return end

	data.DistanceDamageMultiplier, data.DistanceScaleMultiplier = self:GetDistanceMultipliers(tear, player)
	self:UpdateChargeScale(tear, player, data.ChargeRatio)
end

--缺少释放参数时使用的默认飞行配置
InvertedCrossTear.FlightInfo = {
	DefaultSpeed = 10,
	DefaultRange = 260, --初始射程的满蓄力飞行距离
	DefaultChargeRatio = 1,
	PopResumeSpeedFactor = 0.5,
	InitialSpeedMultiplier = 1.5,
}

InvertedCrossTear.BloodClotInfo = {
	Color = Color(1, 0.55, 0.55, 1, 0, 0, 0),
	ScaleMultiplier = 1.1,
	HolyLightDamageBonus = 1,
}

InvertedCrossTear.ChemicalPeelInfo = {
	Color = Color(0.55, 1, 0.55, 1, 0, 0, 0),
	ScaleMultiplier = 1.1,
	HolyLightDamageBonus = 2,
}

InvertedCrossTear.BloodClotChemicalPeelInfo = {
	Color = Color(0.65, 0.05, 0.05, 1, 0, 0, 0),
	ScaleMultiplier = 1.1,
	HolyLightDamageBonus = 3,
}

InvertedCrossTear.DeadEyeInfo = {
	MaxCharge = 8,
}

--正值表示房间判定向外扩展的距离;炸弹落点和遥控移动不适用
InvertedCrossTear.RoomCheckExpansion = 100

function InvertedCrossTear:GetRoomCheckMargin(baseMargin)
	return (baseMargin or 0) - self.RoomCheckExpansion
end

function InvertedCrossTear:GetDefaultFlightTime()
	local info = self.FlightInfo
	return math.max(1, math.ceil(info.DefaultRange / math.max(1, info.DefaultSpeed)))
end

--引导圣光配置,频率只受玩家面板弹速影响
InvertedCrossTear.HolyLightInfo = {
	DefaultInterval = 3, --找不到来源玩家时的生成间隔(帧)
	BaseInterval = 3, --弹速为1时的生成间隔(帧)
	MinInterval = 1, --弹速达到最大时的生成间隔(帧)
	BaseShotSpeed = 1,
	MaxShotSpeed = 3,
	DamageMul = 2, --玩家面板伤害倍率
	AlphaMultiplier = 0.5, --圣光最终透明度倍率
}

function InvertedCrossTear:GetHolyLightColor(color)
	color = color or Color(1, 1, 1, 1, 0, 0, 0)
	return Color(color.R, color.G, color.B,
		color.A * self.HolyLightInfo.AlphaMultiplier,
		color.RO, color.GO, color.BO)
end

--断魂椒与鸟眼椒的火焰
InvertedCrossTear.PepperFlameInfo = {
	{
		Item = CollectibleType.COLLECTIBLE_GHOST_PEPPER,
		Variant = EffectVariant.BLUE_FLAME,
		DamageMul = 6,
		Timeout = 60,
	},
	{
		Item = CollectibleType.COLLECTIBLE_BIRDS_EYE,
		Variant = EffectVariant.RED_CANDLE_FLAME,
		DamageMul = 4,
		Timeout = 600,
	},
}

InvertedCrossTear.FireMindInfo = {
	DamageMul = 4,
	Timeout = 600,
	ScaleMul = 0.8,
}

InvertedCrossTear.BrimstoneInfo = {
	Color = Color(0.5, 0.05, 0.05, 1, 0, 0, 0),
}

--每次圣光独立判定两种椒,从实际攻击中心朝引弹方向发射火焰
function InvertedCrossTear:SpawnPepperFlames(tear, player)
	if not player then return end

	local source = self:GetSourceEntity(tear)
	local direction = (tear.Position - source.Position):Normalized()
	for _, info in ipairs(self.PepperFlameInfo) do
		if player:HasCollectible(info.Item) then
			local rng = player:GetCollectibleRNG(info.Item)
			local luck = math.max(1, math.min(6, player.Luck))
			if luck > rng:RandomInt(12) then
				local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, info.Variant, 0,
					source.Position, direction * player.ShotSpeed * 9, source)
				local flame = entity and entity:ToEffect()
				if flame then
					flame.Parent = source
					flame.CollisionDamage = player.Damage * self:GetData(tear).DamageMultiplier * info.DamageMul
					flame:SetTimeout(info.Timeout)
					local scale = player.Damage * 0.25
					flame.SpriteScale = Vector(scale, scale)
				end
			end
		end
	end
end

--燃烧引弹:每次引导圣光生成原地红火
function InvertedCrossTear:SpawnFireMindFlame(tear, player)
	if not player or not tear or not tear:HasTearFlags(TearFlags.TEAR_BURN) then return end

	local info = self.FireMindInfo
	local data = self:GetData(tear)
	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0,
		tear.Position, Vector.Zero, player)
	local flame = entity and entity:ToEffect()
	if not flame then return end

	flame.CollisionDamage = player.Damage * data.DamageMultiplier * info.DamageMul
	flame:SetTimeout(info.Timeout)
	local scale = tear.Scale * info.ScaleMul
	flame.SpriteScale = Vector(scale, scale)
end

--蠕虫兼容:初速10、圣光间隔3帧,相邻落点相距30;每周期8点约对应240空间长度
InvertedCrossTear.WormInfo = {
	WaveAmplitude = 50,
	SmallSpiralRadius = 25,
	SpiralRadius = 75,
	HomingRadius = 75,
	HomingLockRadius = 25,
	PhaseStepDegrees = 45,
	SquareTransitionSteps = 5,
	FlatWormSpacing = 25,
}

function InvertedCrossTear:InitializeWormCompatibility(tear, data)
	data.ActiveWormPatterns = {}
	for _, info in ipairs(self.WormPatterns) do
		if tear:HasTearFlags(info.Flag) then
			table.insert(data.ActiveWormPatterns, info.Pattern)
		end
	end
end

function InvertedCrossTear:GetWormFlightDirection(tear)
	local data = self:GetData(tear)
	local direction = data.AimDirection
	if data.MomsKnifeFlight then
		direction = data.MomsKnifeDirection or direction
	elseif data.IsRemoteControl and tear.Velocity:Length() > 0 then
		direction = tear.Velocity
	end
	direction = direction or tear.Velocity
	if not direction or direction:Length() <= 0 then return Vector(1, 0) end
	return direction:Normalized()
end

function InvertedCrossTear:GetFlatWormOffsets(tear, perpendicular, multiplier)
	local multiplierCount = math.max(1, math.floor(multiplier))
	local spacing = self.WormInfo.FlatWormSpacing * tear.Scale
	local offsets = {}
	local lightCount = multiplierCount + 1
	local firstIndex = -(lightCount - 1) / 2
	for index = 0, lightCount - 1 do
		table.insert(offsets, perpendicular * (spacing * (firstIndex + index)))
	end
	return offsets
end

function InvertedCrossTear:GetWormSpawnPositions(tear)
	local data = self:GetData(tear)
	local info = self.WormInfo
	local sampleIndex = data.WormSampleIndex or 0
	data.WormSampleIndex = sampleIndex + 1
	local phaseDegrees = sampleIndex * info.PhaseStepDegrees
	local phaseRadians = math.rad(phaseDegrees)
	local direction = self:GetWormFlightDirection(tear)
	local perpendicular = Vector(-direction.Y, direction.X)
	local amplitude = info.WaveAmplitude * tear.Scale

	local player = self:GetPlayer(tear)
	local flatWormMultiplier = player
		and player:GetTrinketMultiplier(TrinketType.TRINKET_FLAT_WORM) or 0
	local offsets = flatWormMultiplier > 0
		and self:GetFlatWormOffsets(tear, perpendicular, flatWormMultiplier)
		or {Vector.Zero}

	local function StackOffsets(extraOffsets)
		local stacked = {}
		for _, base in ipairs(offsets) do
			for _, extra in ipairs(extraOffsets) do
				table.insert(stacked, base + extra)
			end
		end
		offsets = stacked
	end

	local function HasPattern(pattern)
		for _, active in ipairs(data.ActiveWormPatterns or {}) do
			if active == pattern then return true end
		end
		return false
	end

	if HasPattern('Wiggle') then
		StackOffsets({perpendicular * (math.sin(phaseRadians) * amplitude)})
	end

	if HasPattern('Square') then
		local sign = math.cos(phaseRadians) >= 0 and 1 or -1
		local previousSign = data.SquareLastSign or sign
		local squareOffsets = {}
		if previousSign ~= sign then
			for step = 1, info.SquareTransitionSteps do
				local progress = step / (info.SquareTransitionSteps + 1)
				local transitionSign = previousSign + (sign - previousSign) * progress
				table.insert(squareOffsets, perpendicular * (amplitude * transitionSign))
			end
		end
		data.SquareLastSign = sign
		table.insert(squareOffsets, perpendicular * (amplitude * sign))
		StackOffsets(squareOffsets)
	end

	if HasPattern('SmallSpiral') then
		local radius = info.SmallSpiralRadius * tear.Scale
		StackOffsets({Vector.FromAngle(phaseDegrees) * radius})
	end

	if HasPattern('Spiral') then
		local radius = info.SpiralRadius * tear.Scale
		--Isaac的坐标轴y向下,FromAngle使用角度,正角度在屏幕空间表现为顺时针
		StackOffsets({Vector.FromAngle(phaseDegrees) * radius})
	end

	local positions = {}
	for _, offset in ipairs(offsets) do
		table.insert(positions, tear.Position + offset)
	end
	return positions
end

function InvertedCrossTear:ResolveHolyLightHomingPosition(tear, position)
	local data = self:GetData(tear)
	if not data.HolyLightHoming then return position end

	local info = self.WormInfo
	local maxRadius = info.HomingRadius * tear.Scale
	local lockRadius = info.HomingLockRadius * tear.Scale
	local enemy = self._Finds:ClosestEnemy(position)
	if not enemy then return position end

	local distanceSquared = enemy.Position:DistanceSquared(position)
	if distanceSquared > maxRadius * maxRadius then return position end
	if distanceSquared <= lockRadius * lockRadius then return enemy.Position end

	local distance = math.sqrt(distanceSquared)
	local weight = (maxRadius - distance) / (maxRadius - lockRadius)
	weight = math.max(0, math.min(1, weight))
	return position + (enemy.Position - position) * weight
end

--神秘液体:每次引导圣光生成一份绿色液体
function InvertedCrossTear:SpawnMysteriousLiquid(tear)
	if not tear or not tear:HasTearFlags(TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP) then return end

	local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0,
		tear.Position, Vector.Zero, tear)
	local liquid = entity and entity:ToEffect()
	if not liquid then return end

	liquid.CollisionDamage = 1
end

--吐根:每3帧检测接触,爆炸和每次毒伤均固定为当前面板伤害
InvertedCrossTear.IpecacInfo = {
	Interval = 3,
	PoisonRadius = 80,
	PoisonDuration = 60,
	ExplosionRadiusMultiplier = 1,
	Color = Color(0.45, 0.9, 0.45, 1, 0, 0.1, 0),
}

--使用原版尺寸进行接触判定,不依赖忏悔龙的碰撞胶囊接口
function InvertedCrossTear:HasContactCollision(tear)
	local radiusX = math.max(1, tear.Size * tear.SizeMulti.X)
	local radiusY = math.max(1, tear.Size * tear.SizeMulti.Y)
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(entity) then
			local offset = entity.Position - tear.Position
			local combinedX = radiusX + entity.Size * entity.SizeMulti.X
			local combinedY = radiusY + entity.Size * entity.SizeMulti.Y
			if (offset.X / combinedX) ^ 2 + (offset.Y / combinedY) ^ 2 <= 1 then
				return true
			end
		end
	end

	local room = Game():GetRoom()
	--IsPositionInRoom额外覆盖没有GridEntity的房间外墙和边界
	local margin = self:GetRoomCheckMargin(math.min(radiusX, radiusY))
	if not room:IsPositionInRoom(tear.Position, margin) then
		return true
	end

	local collision = room:GetGridCollisionAtPos(tear.Position)
	return collision == GridCollisionClass.COLLISION_OBJECT
		or collision == GridCollisionClass.COLLISION_SOLID
		or collision == GridCollisionClass.COLLISION_WALL
		or collision == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
end

--原版爆炸接口不会继承玩家的额外泪弹特效;中毒单独设置伤害和持续时间
function InvertedCrossTear:SpawnIpecacExplosion(tear, player)
	local info = self.IpecacInfo
	local damage = player.Damage * self:GetData(tear).DamageMultiplier
	Game():BombExplosionEffects(tear.Position, damage, TearFlags.TEAR_NORMAL,
		info.Color, player, info.ExplosionRadiusMultiplier, true)

	for _, entity in ipairs(Isaac.FindInRadius(tear.Position, info.PoisonRadius, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(entity) then
			entity:AddPoison(EntityRef(player), info.PoisonDuration, damage)
		end
	end
end

--BlockCollectible会隐藏持有状态;只有真实库存仍存在时才维持自定义兼容
function InvertedCrossTear:HasCollectibleIncludingBlocked(player, id)
	if not player or not id then return false end
	if player:HasCollectible(id) then return true end
	if not REPENTOGON
	or type(player.IsCollectibleBlocked) ~= 'function'
	or type(player.GetCollectiblesList) ~= 'function'
	or not player:IsCollectibleBlocked(id) then return false end
	return (player:GetCollectiblesList()[id] or 0) > 0
end

function InvertedCrossTear:HasIpecac(player)
	return self:HasCollectibleIncludingBlocked(player, CollectibleType.COLLECTIBLE_IPECAC)
end

function InvertedCrossTear:HasDrFetus(player)
	return self:HasCollectibleIncludingBlocked(player, CollectibleType.COLLECTIBLE_DR_FETUS)
end

function InvertedCrossTear:RefreshItemCompatData(tear, player, suppressHaemolacria)
	local data = self:GetData(tear)
	data.HasRevelation = self:HasCollectibleIncludingBlocked(
		player, CollectibleType.COLLECTIBLE_REVELATION)
	data.HasMawOfTheVoid = self:HasCollectibleIncludingBlocked(
		player, CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID)
	data.HasHaemolacria = not suppressHaemolacria
		and self:HasCollectibleIncludingBlocked(
			player, CollectibleType.COLLECTIBLE_HAEMOLACRIA)
	return data
end

function InvertedCrossTear:UpdateIpecac(tear)
	local player = self:GetPlayer(tear)
	local data = self:GetData(tear)
	--指挥引弹生成时仍带IsFloating,需额外允许实际移动中的指挥状态
	local isFlying = not data.IsFloating or (data.IsRemoteControl and data.RemoteControlMoving)
	if not isFlying or not self:HasIpecac(player) then return end
	if not tear:IsFrame(self.IpecacInfo.Interval, 0) then return end

	if self:HasContactCollision(tear) then
		self:SpawnIpecacExplosion(tear, player)
	end
end

InvertedCrossTear.DrFetusInfo = {
	Interval = 3,
	FallStartOffsetY = -200,
	FallingSpeed = 10, --Offset.Y每帧增加10,约20帧落地
	FallingFuse = 45, --仅用于下落期间暂停引信,落地立即爆炸
	RocketSpeedMultiplier = 20,
}

--无罐中火箭:固定落点,仅通过Sprite.Offset.Y让炸弹从上向下落
function InvertedCrossTear:SpawnDrFetusBomb(tear, player)
	if not Game():GetRoom():IsPositionInRoom(tear.Position, 0) then return nil end
	local bomb = player:FireBomb(tear.Position, Vector.Zero, player)
	if not bomb then return nil end
	bomb.IsFetus = true
	bomb.ExplosionDamage = bomb.ExplosionDamage * self:GetData(tear).DamageMultiplier

	local info = self.DrFetusInfo
	self._Ents:GetTempData(bomb).InvertedCrossTearDrFetusFall = {
		Position = Vector(tear.Position.X, tear.Position.Y),
		OffsetY = info.FallStartOffsetY,
		EntityCollisionClass = bomb.EntityCollisionClass,
		GridCollisionClass = bomb.GridCollisionClass,
	}
	bomb.Velocity = Vector.Zero
	bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	bomb:SetExplosionCountdown(info.FallingFuse)
	local sprite = bomb:GetSprite()
	local offset = sprite.Offset
	offset.Y = info.FallStartOffsetY
	sprite.Offset = offset
	return bomb
end

function InvertedCrossTear:OnDrFetusBombRender(bomb)
	local tempData = self._Ents:GetTempData(bomb)
	local data = tempData.InvertedCrossTearDrFetusFall
	if not data then return end
	if bomb:IsDead() then
		tempData.InvertedCrossTearDrFetusFall = nil
		return
	end

	bomb.Position = data.Position
	bomb.Velocity = Vector.Zero
	bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	bomb:SetExplosionCountdown(self.DrFetusInfo.FallingFuse)

	data.OffsetY = math.min(0, data.OffsetY + self.DrFetusInfo.FallingSpeed)
	local sprite = bomb:GetSprite()
	local offset = sprite.Offset
	offset.Y = data.OffsetY
	sprite.Offset = offset

	if data.OffsetY >= 0 then
		--落地后仍不与地形或敌人碰撞,直接爆炸
		bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		bomb.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		bomb:SetExplosionCountdown(10)
		tempData.InvertedCrossTearDrFetusFall = nil
	end
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, 'OnDrFetusBombRender')

--罐中火箭:沿用自定义硫磺火兼容的攻击中心和落点修正发射火箭雷
function InvertedCrossTear:SpawnDrFetusRocket(tear, player, position)
	position = position or tear.Position
	if not Game():GetRoom():IsPositionInRoom(position, 0) then return nil end
	local source = self:GetSourceEntity(tear)
	local sourcePosition = source.Position
	local target = position + Vector(0, -10)
	local direction = (target - sourcePosition):Normalized()
	if direction:Length() <= 0 then return nil end

	local velocity = direction * player.ShotSpeed * self.DrFetusInfo.RocketSpeedMultiplier
	local bomb = player:FireBomb(sourcePosition, velocity, player)
	if not bomb then return nil end
	bomb.PositionOffset = Vector.Zero
	bomb.ExplosionDamage = bomb.ExplosionDamage * self:GetData(tear).DamageMultiplier
	return bomb
end

function InvertedCrossTear:UpdateDrFetus(tear)
	local player = self:GetPlayer(tear)
	if not player or not self:HasDrFetus(player) then return end
	local data = self:GetData(tear)
	local isFlying = not data.IsFloating or (data.IsRemoteControl and data.RemoteControlMoving)
	if not isFlying or not tear:IsFrame(self.DrFetusInfo.Interval, 0) then return end

	--罐中火箭不参与碰撞连续生成,只在引弹消失兼容中发射一次
	if self:HasContactCollision(tear)
	and not player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) then
		self:SpawnDrFetusBomb(tear, player)
	end
end

--根据当前攻击逻辑和玩家弹速计算圣光间隔
function InvertedCrossTear:GetHolyLightInterval(player, tear)
	local info = self.HolyLightInfo
	if not player then return info.DefaultInterval end

	local speedRange = math.max(0.001, info.MaxShotSpeed - info.BaseShotSpeed)
	local progress = (player.ShotSpeed - info.BaseShotSpeed) / speedRange
	progress = math.min(1, progress)
	local normalInterval = info.BaseInterval
		+ (info.MinInterval - info.BaseInterval) * progress
	if not self:IsBlackForm(player) then return normalInterval end

	local data = tear and self:GetData(tear)
	if data and (data.MomsKnifeFlight
	or data.IsRemoteControl
	or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then
		return normalInterval
	end
	return 1
end

InvertedCrossTear.EpicFetusInfo = {
	TargetInterval = 2, --每两次圣光结算召唤一次信标,即圣光频率的一半
	MarkedEnemyRadius = 96,
	TargetTimeout = 10,
	RocketTimeout = 10,
}

--在引弹周围选取最近的有效圣光标记敌人
function InvertedCrossTear:GetNearestMarkedEnemy(tear)
	local radius = self.EpicFetusInfo.MarkedEnemyRadius * tear.Scale
	local mark = mod.IBS_Effect.BAzazelCrackTheSkyMark
	local closestEnemy, closestDistance = nil, nil
	for _, enemy in ipairs(Isaac.FindInRadius(tear.Position, radius, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(enemy) and mark:GetMark(enemy) then
			local distance = (enemy.Position - tear.Position):LengthSquared()
			if not closestDistance or distance < closestDistance then
				closestEnemy = enemy
				closestDistance = distance
			end
		end
	end
	return closestEnemy
end

--原版信标与导弹组合,由信标引导导弹落点;可选锁定敌人由更新回调持续追踪
function InvertedCrossTear:SpawnEpicFetusTarget(position, player, damageMultiplier, lockedEnemy)
	local info = self.EpicFetusInfo
	local targetEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0,
		position, Vector.Zero, player)
	local target = targetEntity and targetEntity:ToEffect()
	if not target then return nil end

	if lockedEnemy then
		self._Ents:GetTempData(target).InvertedCrossTearEpicFetusLock = lockedEnemy
	end
	local rocketEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCKET, 0,
		position, Vector.Zero, player)
	local rocket = rocketEntity and rocketEntity:ToEffect()
	target:SetTimeout(info.TargetTimeout)
	if rocket then
		rocket.Parent = target
		rocket.CollisionDamage = rocket.CollisionDamage * (damageMultiplier or 1)
		rocket:SetTimeout(info.RocketTimeout)
		rocket.Visible = false
		self._Ents:GetTempData(rocket).InvertedCrossTearEpicFetusHideFirstFrame = true
	end
	return target, rocket
end

--只追踪本模块生成时锁定的敌人,不影响其他来源的史诗信标
function InvertedCrossTear:OnEpicFetusTargetUpdate(effect)
	local enemy = self._Ents:GetTempData(effect).InvertedCrossTearEpicFetusLock
	if enemy and enemy:Exists() and not enemy:IsDead() then
		effect.Position = enemy.Position
		effect.Velocity = Vector.Zero
	end
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEpicFetusTargetUpdate', EffectVariant.TARGET)

--本模块的史诗导弹仅在首帧隐藏,之后恢复原生显示与更新
function InvertedCrossTear:OnEpicFetusRocketUpdate(effect)
	local data = self._Ents:GetTempData(effect)
	if not data.InvertedCrossTearEpicFetusHideFirstFrame then return end
	if effect.FrameCount > 0 then
		effect.Visible = true
		data.InvertedCrossTearEpicFetusHideFirstFrame = nil
	else
		effect.Visible = false
	end
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEpicFetusRocketUpdate', EffectVariant.ROCKET)

InvertedCrossTear.CSectionInfo = {
	DamageMultiplier = 1,
	ShotSpeedMultiplier = 10,
}

--优先射向最近敌人,没有目标时随机发射
function InvertedCrossTear:SpawnCSection(tear, player)
	local info = self.CSectionInfo
	local target = self._Finds:ClosestEnemy(tear.Position)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_C_SECTION)
	local direction = target and (target.Position - tear.Position):Normalized()
		or Vector.FromAngle(rng:RandomInt(360))
	local fetus = player:FireTear(tear.Position, direction * player.ShotSpeed * info.ShotSpeedMultiplier,
		false, true, true, player, info.DamageMultiplier * self:GetData(tear).DamageMultiplier)
	if not fetus then return nil end

	self._Tears:ToFetus(fetus, player)
	self:SetTouchedFlags(fetus, true)
	fetus:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
	--项目库保留了额外条件
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
		fetus:AddTearFlags(TearFlags.TEAR_FETUS_BRIMSTONE)
	end
	if self:HasDrFetus(player) then
		fetus:AddTearFlags(TearFlags.TEAR_FETUS_BOMBER)
	end
	return fetus
end

InvertedCrossTear.JacobsLadderInfo = {
	DamageMultiplier = 1,
}

--发射普通科技激光,优先瞄准最近敌人,没有目标时随机发射
function InvertedCrossTear:SpawnJacobsLadderLaser(tear, player)
	local info = self.JacobsLadderInfo
	local target = self._Finds:ClosestEnemy(tear.Position)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_JACOBS_LADDER)
	local direction = target and (target.Position - tear.Position):Normalized()
		or Vector.FromAngle(rng:RandomInt(360))
	local laser = player:FireTechLaser(tear.Position, LaserOffset.LASER_TECH1_OFFSET,
		direction, false, true, player, info.DamageMultiplier * self:GetData(tear).DamageMultiplier)
	if not laser then return nil end

	laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	return laser
end

InvertedCrossTear.OcularRiftInfo = {
	DamageMultiplier = 0.5,
	Timeout = 120,
}

InvertedCrossTear.JupiterInfo = {
	DamageMultiplier = 0.5,
	Timeout = 60,
	ScaleMultiplier = 0.7, --里ysd木星毒气尺寸的一半
}

--木星:引弹折返或落地时留下毒气云
function InvertedCrossTear:SpawnJupiterCloud(tear, player, position)
	if not player then return end

	local cloudEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0,
		position or tear.Position, Vector.Zero, player)
	local cloud = cloudEntity and cloudEntity:ToEffect()
	if not cloud then return end

	local info = self.JupiterInfo
	cloud.CollisionDamage = player.Damage * self:GetData(tear).DamageMultiplier * info.DamageMultiplier
	cloud.SpriteScale = Vector(tear.Scale * info.ScaleMultiplier, tear.Scale * info.ScaleMultiplier)
	cloud:SetTimeout(info.Timeout)
end

--原版裂眼,继承引弹尺寸
function InvertedCrossTear:SpawnOcularRift(tear, player)
	local info = self.OcularRiftInfo
	local riftEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0,
		tear.Position, Vector.Zero, player)
	local rift = riftEntity and riftEntity:ToEffect()
	if not rift then return nil end

	rift.CollisionDamage = player.Damage * self:GetData(tear).DamageMultiplier * info.DamageMultiplier
	rift.SpriteScale = Vector(tear.Scale, tear.Scale)
	rift:SetTimeout(info.Timeout)
	return rift
end

--科技逻辑:每次圣光结算时从实际攻击中心射向当前圣光落点;硫磺火替换激光,再持有妈刀时替换为飞刀
function InvertedCrossTear:SpawnTechnologyLaser(tear, player)
	local data = self:GetData(tear)
	local source = self:GetSourceEntity(tear)
	local target = tear.Position + Vector(0, -10)
	local direction = (target - source.Position):Normalized()
	local damageMultiplier = data.DamageMultiplier * (data.ChargeRatio or 0) *
		(player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) and 4 or 1)
	local laser
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
		if player:GetPlayerType() == mod.IBS_PlayerID.BAzazel
		and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
			mod.IBS_Tear.BAzazelFakeKnife:FireFakeKnife(player, math.ceil(13 * (data.ChargeRatio or 0)),
				direction:GetAngleDegrees(), 2 * data.DamageMultiplier, source.Position)
			return nil
		end
		laser = player:FireBrimstone(direction, player, damageMultiplier)
		if not laser then return nil end
		laser.Position = source.Position
		laser.Parent = source
	else
		laser = player:FireTechLaser(source.Position, LaserOffset.LASER_TECH1_OFFSET,
			direction, false, false, player, damageMultiplier)
	end
	if not laser then return nil end

	self._Ents:GetTempData(laser).InvertedCrossTearLaserTarget = target
	return laser
end

--周期圣光与长子权重复印记落光共用同一份伤害计算,避免倍率规则分叉
function InvertedCrossTear:GetHolyLightDamage(tear, player)
	if not player then return 0 end
	local data = self:GetData(tear)
	local baseMultiplier = self.HolyLightInfo.DamageMul
	if self:IsBlackForm(player) then
		baseMultiplier = 1.5
	end
	return player.Damage * data.DamageMultiplier * baseMultiplier
		* self:GetHolyLightDamageMultiplier(tear, player)
		+ (data.HolyLightDamageBonus or 0)
end

--在引导弹位置生成自定义圣光,继承眼泪颜色;没有来源玩家时仍生成视觉圣光
function InvertedCrossTear:SpawnHolyLight(tear, player)
	if not Game():GetRoom():IsPositionInRoom(tear.Position,
		self:GetRoomCheckMargin()) then return nil end

	local data = self:GetData(tear)
	data.HolyLightCount = (data.HolyLightCount or 0) + 1
	local lightPositions = self:GetWormSpawnPositions(tear)

	--这些效果与每次圣光结算同步,彼此共存且不受史诗胎儿替换影响
	if player then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
			self:SpawnTechnologyLaser(tear, player)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
			self:SpawnCSection(tear, player)
		end
		if tear:HasTearFlags(TearFlags.TEAR_JACOBS) then
			self:SpawnJacobsLadderLaser(tear, player)
		end
		if tear:HasTearFlags(TearFlags.TEAR_RIFT) then
			self:SpawnOcularRift(tear, player)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_JUPITER) then
			self:SpawnJupiterCloud(tear, player)
		end
	end

	self:SpawnMysteriousLiquid(tear)

	--史诗胎儿吞掉所有圣光,仅以一半频率召唤信标;优先锁定范围内最近的标记敌人
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
		if data.HolyLightCount % self.EpicFetusInfo.TargetInterval == 0 then
			local enemy = self:GetNearestMarkedEnemy(tear)
			local position = lightPositions[#lightPositions] or tear.Position
			position = self:ResolveHolyLightHomingPosition(tear, position)
			self:SpawnEpicFetusTarget(enemy and enemy.Position or position,
				player, data.DamageMultiplier, enemy)
		end
		return nil
	end

	local damage = self:GetHolyLightDamage(tear, player)
	local lightColor = self:GetHolyLightColor(tear.Color)
	local firstLight
	for _, position in ipairs(lightPositions) do
		position = self:ResolveHolyLightHomingPosition(tear, position)
		if Game():GetRoom():IsPositionInRoom(position, self:GetRoomCheckMargin()) then
			local light = mod.IBS_Effect.BAzazelCrackTheSky:Spawn(
				position, player or tear, damage, tear.Scale, lightColor)
			if light then
				light.Parent = player
				firstLight = firstLight or light
			end
		end
	end
	if not firstLight then return nil end

	self:SpawnPepperFlames(tear, player)
	self:SpawnFireMindFlame(tear, player)
	return firstLight
end

--临时数据;外部直接生成时默认进入飞行状态
function InvertedCrossTear:GetData(tear)
	local data = self._Ents:GetTempData(tear)
	data.InvertedCrossTear = data.InvertedCrossTear or {
		IsFloating = false, --true:悬浮; false:飞行
		DirectionOffset = 0,
		FlightTime = self:GetDefaultFlightTime(),
		Disappearing = false,
		SuspendedFlags = 0,
		HolyLightCooldown = 0,
		HolyLightCount = 0,
		ChargeRatio = self.FlightInfo.DefaultChargeRatio,
		DamageMultiplier = 1, --跟班攻击等独立来源的伤害倍率,不改变玩家面板
		AlternateScaleMultiplier = 1,
		HolyLightDamageBonus = 0,
		HolyLightHoming = false,
		HasRevelation = false,
		HasMawOfTheVoid = false,
		HasHaemolacria = false,
		MyReflection = false,
		SplitTriggered = false,
		HolyLightTriggered = false,
		RevelationTriggered = false,
		ImpactCompatTriggered = false,
	}
	--兼容热重载前已经存在的引弹数据
	data.InvertedCrossTear.DamageMultiplier = data.InvertedCrossTear.DamageMultiplier or 1
	return data.InvertedCrossTear
end

--记录命中来源;接触敌人时持续追踪实体,落地时只保存固定坐标
function InvertedCrossTear:CreateImpactTarget(position, targetEntity)
	local targetInfo = {
		Position = position,
	}
	if targetEntity and targetEntity:Exists() and self._Ents:IsEnemy(targetEntity, true) then
		targetInfo.Entity = targetEntity
		targetInfo.Position = targetEntity.Position
	end
	return targetInfo
end

function InvertedCrossTear:ResolveImpactTarget(targetInfo)
	if not targetInfo then return nil end
	local entity = targetInfo.Entity
	if entity and entity:Exists() and not entity:IsDead() then
		targetInfo.Position = entity.Position
	end
	return targetInfo.Position
end

--巨大圣光每次引弹最多触发一次:首次命中敌人或最终落地
function InvertedCrossTear:TrySpawnHolyLightImpact(tear, player, position, targetInfo)
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
		return false
	end

	local data = self:GetData(tear)
	if data.HolyLightTriggered then return false end
	data.HolyLightTriggered = true

	local spawnPosition = (targetInfo and targetInfo.Position) or position or tear.Position
	if not Game():GetRoom():IsPositionInRoom(spawnPosition,
		self:GetRoomCheckMargin()) then return false end
	local timeout = math.min(15, math.max(1, math.ceil(15 * (data.ChargeRatio or 0))))
	local light = mod.IBS_Effect.BigLight:Spawn(player, player.Damage * data.DamageMultiplier,
		2 * tear.Scale, false, false, false, timeout, spawnPosition, 0.2)
	if light and targetInfo then
		self._Ents:GetTempData(light).InvertedCrossImpactTarget = targetInfo
	end
	return true
end

InvertedCrossTear.RevelationOrbInfo = {
	TravelFactor = 0.05,
	ArrivalDistance = 0.5,
}

--终末天启:与巨大圣光相同,首次命中敌人或最终落地时触发一次
function InvertedCrossTear:TrySpawnRevelationImpact(tear, player, position, targetInfo)
	local data = self:GetData(tear)
	if not player or not data.HasRevelation then return false end
	if data.RevelationTriggered then return false end
	data.RevelationTriggered = true

	local source = self:GetSourceEntity(tear)
	local startPosition = source.Position + Vector(0, -10)
	local targetPosition = ((targetInfo and targetInfo.Position)
		or position or tear.Position) + Vector(0, -40)
	local chargeRatio = math.max(0, math.min(1, data.ChargeRatio or 0))
	local orb = mod.IBS_Effect.BAzazelDogmaOrb:Spawn(startPosition, player, {
		Damage = player.Damage * data.DamageMultiplier * chargeRatio,
		Scale = tear.Scale,
		LaserDuration = 30,
		IdleFrames = 30,
	})
	if not orb then return false end

	self._Ents:GetTempData(orb).InvertedCrossRevelationOrb = {
		TargetPosition = targetPosition,
		TargetInfo = targetInfo,
	}
	return true
end

InvertedCrossTear.MawOfTheVoidInfo = {
	Color = Color(0, 0, 0, 1, 0, 0, 0),
	Radii = {30, 60, 90, 120},
	MaxCount = 4,
	RingDelay = 2,
}

--虚空之喉:命中或消失时按蓄力生成一至四层黑圈激光
function InvertedCrossTear:TrySpawnMawOfTheVoidImpact(tear, player, position)
	local info = self.MawOfTheVoidInfo
	local data = self:GetData(tear)
	if not player or not data.HasMawOfTheVoid then return false end
	local chargeRatio = math.max(0, math.min(1, data.ChargeRatio or 0))
	local count = math.min(info.MaxCount, math.max(1, math.ceil(chargeRatio * info.MaxCount)))
	local spawnPosition = position + Vector(0, -40)
	local tearScale = tear.Scale
	local function SpawnRing(index)
		if not player:Exists() or not data.HasMawOfTheVoid then return end
		local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED,
			LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, spawnPosition, Vector.Zero, player):ToLaser()
		if laser then
			laser:SetTimeout(45)
			laser.DisableFollowParent = true
			laser.Parent = player
			laser.Radius = tearScale * info.Radii[index]
			laser.CollisionDamage = player.Damage
		end
	end
	SpawnRing(1)
	for i = 2, count do
		local ringIndex = i
		self:DelayFunction(function()
			SpawnRing(ringIndex)
		end, (i - 1) * info.RingDelay)
	end
	sfx:Play(SoundEffect.SOUND_MAW_OF_VOID)
	return true
end

InvertedCrossTear.HaemolacriaInfo = {
	ScaleMultiplier = 1.5,
	Color = Color(1, 0.05, 0.05, 1, 0, 0, 0),
	MaxBurstCount = 5,
	MinRandomMultiplier = 0.5,
	MaxRandomMultiplier = 1,
	RangeMultiplier = 0.5,
}

function InvertedCrossTear:SpawnHaemolacriaChildren(tear, player)
	local data = self:GetData(tear)
	data.SplitTriggered = true
	local info = self.HaemolacriaInfo
	local chargeRatio = math.max(0, math.min(1, data.ChargeRatio or 0))
	local count = math.max(0, math.min(info.MaxBurstCount,
		math.floor(chargeRatio * info.MaxBurstCount + 0.5)))
	if count <= 0 or not player then return end

	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
	local directions = {}
	for index = 1, info.MaxBurstCount do
		directions[index] = Vector.FromAngle(rng:RandomFloat() * 360)
	end

	local source = self:GetSourceEntity(tear)
	local speed = self.FlightInfo.DefaultSpeed
	local range = self.FlightInfo.DefaultRange * chargeRatio * info.RangeMultiplier
	for index = 1, count do
		local child = self:Spawn(player, tear.Position, 0, source, true)
		if child then
			local childData = self:GetData(child)
			childData.SplitTriggered = true
			local scaleMultiplier = info.MinRandomMultiplier
				+ rng:RandomFloat() * (info.MaxRandomMultiplier - info.MinRandomMultiplier)
			local damageMultiplier = info.MinRandomMultiplier
				+ rng:RandomFloat() * (info.MaxRandomMultiplier - info.MinRandomMultiplier)
			child.Scale = tear.Scale * scaleMultiplier
			childData.BaseScale = child.Scale
			childData.DamageMultiplier = data.DamageMultiplier * damageMultiplier
			childData.HasHaemolacria = false
			childData.TinyPlanetOrbit = false
			self:Release(child, directions[index], speed, range, chargeRatio, player, false, true)
			childData.MomsKnifeFlight = false
			child.Velocity = directions[index] * (childData.FlightSpeed or speed)
		end
	end
end

function InvertedCrossTear:TryTriggerHaemolacriaImpact(tear, player)
	local data = self:GetData(tear)
	if not player or not data.HasHaemolacria or data.SplitTriggered then
		return false
	end

	data.FlightTime = 0
	self:SpawnHaemolacriaChildren(tear, player)
	self:Disappear(tear)
	return true
end

--兼容层只移动光球位置;光球自身的动画和发射逻辑保持原样
function InvertedCrossTear:OnRevelationOrbUpdate(orb)
	local moveData = self._Ents:GetTempData(orb).InvertedCrossRevelationOrb
	if not moveData then return end

	local info = self.RevelationOrbInfo
	local targetPosition = self:ResolveImpactTarget(moveData.TargetInfo)
	if targetPosition then
		moveData.TargetPosition = targetPosition + Vector(0, -40)
	end
	local offset = moveData.TargetPosition - orb.Position
	local sprite = orb:GetSprite()
	local shotReady = (sprite:IsPlaying('Death') or sprite:IsFinished('Death'))
		and (sprite:IsEventTriggered('Shoot') or sprite:WasEventTriggered('Shoot')
			or sprite:GetFrame() >= 12)

	if offset:Length() <= info.ArrivalDistance or shotReady then
		orb.Position = moveData.TargetPosition
		orb.Velocity = Vector.Zero
		return
	end

	orb.Position = orb.Position + offset * info.TravelFactor
end
InvertedCrossTear:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_UPDATE,
	CallbackPriority.EARLY, 'OnRevelationOrbUpdate', mod.IBS_EffectID.BAzazelDogmaOrb.Variant)

--巨大圣光只跟随兼容层记录的目标,不再自行选择最近的敌人
function InvertedCrossTear:OnTrackedImpactEffectUpdate(effect)
	local targetInfo = self._Ents:GetTempData(effect).InvertedCrossImpactTarget
	if not targetInfo then return end
	effect.Position = self:ResolveImpactTarget(targetInfo)
end
InvertedCrossTear:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_UPDATE,
	CallbackPriority.EARLY, 'OnTrackedImpactEffectUpdate', mod.IBS_EffectID.BigLight.Variant)

--科技家族持续效果;普通科技随圣光结算,硫磺火的落点爆发单独结算
InvertedCrossTear.TechnologyInfo = {
	Tech2DamageMultiplier = 0.2,
	Tech2PositionOffset = 0,
	TechPoint5Interval = 8,
	TechPoint5RandomRange = 3,
	TechPoint5DamageMultiplier = 1,
	TechXRadius = 75,
	TechXDamageMultiplier = 1,
	TechZeroDamageMultiplier = 1,
	TechZeroEndPadding = 20,
}

--悬浮时取瞄准方向,飞行时取实际速度,静止时保留最后可用方向
function InvertedCrossTear:GetTechnologyAimDirection(tear)
	local data = self:GetData(tear)
	local direction
	if data.IsFloating and not data.IsRemoteControl then
		direction = data.AimDirection
	elseif tear.Velocity:Length() > 0.001 then
		direction = tear.Velocity
	elseif data.MomsKnifeFlight then
		direction = data.MomsKnifeDirection
	end
	direction = direction or data.AimDirection or data.MomsKnifeDirection
	if not direction or direction:Length() <= 0.001 then
		return Vector(1, 0)
	end
	return direction:Normalized()
end

function InvertedCrossTear:RemoveTechnologyLaser(data, key)
	local laser = data[key]
	if laser and laser:Exists() then
		laser:Remove()
	end
	data[key] = nil
end

function InvertedCrossTear:ClearTechnologyLasers(data)
	self:RemoveTechnologyLaser(data, 'Tech2Laser')
	self:RemoveTechnologyLaser(data, 'TechXLaser')
	self:RemoveTechnologyLaser(data, 'TechnologyZeroLaser')
end

function InvertedCrossTear:BindTechnologyLaser(tear, laser)
	self._Ents:GetTempData(laser).InvertedCrossTearTechnologySource = tear
end

function InvertedCrossTear:RemoveDeadToothRing(data)
	local ring = data.DeadToothRing
	if ring and ring:Exists() then
		ring:Remove()
	end
	data.DeadToothRing = nil
end

--烂牙:仅在引弹实际飞行期间维持一个跟随引弹的屁环
function InvertedCrossTear:UpdateDeadTooth(tear)
	local data = self:GetData(tear)
	local player = self:GetPlayer(tear)
	local isFlying = not data.IsFloating or (data.IsRemoteControl and data.RemoteControlMoving)
	if data.Disappearing or data.WaitingForNaturalDeath or not isFlying
	or not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_TOOTH) then
		self:RemoveDeadToothRing(data)
		return
	end

	local ring = data.DeadToothRing
	if not ring or not ring:Exists() then
		ring = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART_RING, 0,
			tear.Position, Vector.Zero, player):ToEffect()
		if not ring then return end
		ring.Parent = tear
		data.DeadToothRing = ring
	end
end

function InvertedCrossTear:UpdateTechnology(tear)
	local data = self:GetData(tear)
	if data.Disappearing then
		self:ClearTechnologyLasers(data)
		return
	end

	local player = self:GetPlayer(tear)
	if not player then
		self:ClearTechnologyLasers(data)
		return
	end

	local info = self.TechnologyInfo
	local damageMultiplier = data.DamageMultiplier
	local direction = self:GetTechnologyAimDirection(tear)
	local angle = direction:GetAngleDegrees()

	--科技II:引弹侧向偏移20像素,维持0.2倍面板的持续激光
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
		local laserPosition = tear.Position + Vector.FromAngle(angle + 90) * info.Tech2PositionOffset
		local laser = data.Tech2Laser
		if not laser or not laser:Exists() then
			laser = player:FireTechLaser(laserPosition, LaserOffset.LASER_TECH1_OFFSET,
				direction, false, false, player, info.Tech2DamageMultiplier * damageMultiplier)
			laser.Timeout = -1
			laser.GridHit = false
			data.Tech2Laser = laser
			self:BindTechnologyLaser(tear, laser)
		else
			laser.Position = laserPosition
		end
		laser.Angle = angle
		laser.AngleDegrees = angle
	else
		self:RemoveTechnologyLaser(data, 'Tech2Laser')
	end

	--科技0.5:每8帧进行一次1/3概率判定,由引弹朝当前方向发射
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5)
	and tear:IsFrame(info.TechPoint5Interval, 0) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TECH_5)
		if rng:RandomInt(info.TechPoint5RandomRange) == 0 then
			local laser = player:FireTechLaser(tear.Position + Vector(-7, -15), LaserOffset.LASER_TECH1_OFFSET,
				direction, false, true, player, info.TechPoint5DamageMultiplier * damageMultiplier)
			laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
			
		end
	end

	--科技X:跟随引弹的光环,半径和伤害随引弹尺寸及玩家面板更新
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
		local laser = data.TechXLaser
		if not laser or not laser:Exists() then
			laser = player:FireTechXLaser(tear.Position, Vector.Zero,
				tear.Scale * info.TechXRadius, player, info.TechXDamageMultiplier * damageMultiplier)
			laser.SubType = LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT
			laser:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
			laser.Parent = tear
			laser.Timeout = 99999
			data.TechXLaser = laser
			self:BindTechnologyLaser(tear, laser)
		end
		laser.Radius = tear.Scale * info.TechXRadius
		laser.CollisionDamage = player.Damage * info.TechXDamageMultiplier * damageMultiplier
	else
		self:RemoveTechnologyLaser(data, 'TechXLaser')
	end

	--科技零:连接实际攻击中心与引弹,逐帧更新长度和两端方向
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) then
		local source = self:GetSourceEntity(tear)
		local offset = tear.Position - source.Position
		local laser = data.TechnologyZeroLaser
		if not laser or not laser:Exists() then
			laser = player:FireTechLaser(source.Position, LaserOffset.LASER_TECH1_OFFSET,
				offset, false, false, player, info.TechZeroDamageMultiplier * damageMultiplier)
			laser.Timeout = -1
			laser.GridHit = false
			laser.Parent = tear
			data.TechnologyZeroLaser = laser
			self:BindTechnologyLaser(tear, laser)
		end
		local connectionAngle = offset:GetAngleDegrees()
		laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		laser.MaxDistance = math.max(0, offset:Length() - info.TechZeroEndPadding)
		laser.Position = source.Position
		laser.Angle = connectionAngle
		laser.AngleDegrees = connectionAngle
	else
		self:RemoveTechnologyLaser(data, 'TechnologyZeroLaser')
	end
end

--生成引导眼泪;可指定以撒心脏或复制攻击跟班作为实际攻击中心
function InvertedCrossTear:Spawn(player, position, directionOffset, source, suppressHaemolacria)
	local id = IBS_TearID.InvertedCrossTear
	local tear
	source = source or player
	if player then
		position = position or source.Position
		--始终按玩家面板生成基础泪弹,再由自定义倍率结算,避免重复应用跟班伤害
		tear = player:FireTear(position, Vector.Zero, false, false, true, player)
		--取消FireTear固定播放的默认发射音效
		sfx:Stop(SoundEffect.SOUND_TEARIMPACTS)
		sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
		if not tear then return nil end
		sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE, 1, 2, false, 1, 0)
		tear.SpawnerEntity = source
		tear:ChangeVariant(id.Variant)
	else
		position = position or Vector.Zero
		local entity = Isaac.Spawn(EntityType.ENTITY_TEAR, id.Variant, id.SubType, position, Vector.Zero, nil)
		tear = entity and entity:ToTear()
		if not tear then return nil end
	end

	tear.SubType = id.SubType
	self:OnTearInit(tear)

	local data = self:GetData(tear)
	local familiarInfo = self:GetFamiliarAttackInfo(source)
	data.SourcePlayer = player
	data.SourceEntity = source
	self:RefreshItemCompatData(tear, player, suppressHaemolacria)
	if data.HasMawOfTheVoid then
		tear.Color = self.MawOfTheVoidInfo.Color
	elseif data.HasHaemolacria then
		tear.Color = self.HaemolacriaInfo.Color
	end
	data.DamageMultiplier = familiarInfo and familiarInfo.DamageMultiplier or 1
	data.IsFloating = not not player
	if data.IsFloating then
		tear:ClearTearFlags(TearFlags.TEAR_HOMING)
	end
	data.DirectionOffset = directionOffset or 0
	data.FlightTime = self:GetDefaultFlightTime()
	data.ChargeRatio = player and 0 or self.FlightInfo.DefaultChargeRatio
	tear.Scale = self:GetInitialScaleMultiplier(player) * (familiarInfo and familiarInfo.Scale or 1)
	--萌肺:每枚独立随机0.5至2倍伤害、0.5至1.5倍尺寸
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
		data.DamageMultiplier = data.DamageMultiplier * (rng:RandomInt(16) + 5) * 0.1
		tear.Scale = tear.Scale * (rng:RandomInt(11) + 5) * 0.1
	end
	if data.HasHaemolacria then
		tear.Scale = tear.Scale * self.HaemolacriaInfo.ScaleMultiplier
	end
	data.BaseScale = tear.Scale
	self:ApplyAlternatingShot(tear, player)
	self:UpdateChargeScale(tear, player, data.ChargeRatio)

	--准星持续瞄准时不保留,其余悬浮引导弹可跟随角色跨房间
	if player and not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
		tear:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	end

	return tear
end

function InvertedCrossTear:TryTriggerImpactCompatibilities(tear, player, position, targetEntity)
	if not player then return false end

	local data = self:GetData(tear)
	local hasRocket = self:HasDrFetus(player)
		and player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR)
	local hasBrimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)
		and not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY)
	local hasHolyLight = player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT)
	local hasRevelation = data.HasRevelation
	local hasMawOfTheVoid = data.HasMawOfTheVoid
	local hasHaemolacria = data.HasHaemolacria and not data.SplitTriggered
	if not hasRocket and not hasBrimstone and not hasHolyLight and not hasRevelation
	and not hasMawOfTheVoid and not hasHaemolacria then return false end

	if data.ImpactCompatTriggered then return false end
	data.ImpactCompatTriggered = true

	position = position or tear.Position
	local source = self:GetSourceEntity(tear)
	local targetInfo = self:CreateImpactTarget(position, targetEntity)
	if hasRocket then
		self:SpawnDrFetusRocket(tear, player, position)
	end

	if hasBrimstone then
		for _, entity in ipairs(Isaac.FindInRadius(position, 75 * tear.Scale, EntityPartition.ENEMY)) do
			if self._Ents:IsEnemy(entity) then
				entity:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
			end
		end

		local target = self:ResolveImpactTarget(targetInfo) + Vector(0, -10)
		local direction = (target - source.Position):Normalized()
		local useFakeKnife = player:GetPlayerType() == mod.IBS_PlayerID.BAzazel
			and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
		if useFakeKnife then
			mod.IBS_Tear.BAzazelFakeKnife:FireFakeKnife(player,
				math.ceil(13 * (data.ChargeRatio or 0)), direction:GetAngleDegrees(),
				2 * data.DamageMultiplier, source.Position)
		else
			local damageMultiplier = data.DamageMultiplier * (data.ChargeRatio or 0) *
				(player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) and 4 or 1)
			local laser = player:FireBrimstone(direction, player, damageMultiplier)
			laser.Position = source.Position
			laser.Parent = source
			self._Ents:GetTempData(laser).InvertedCrossTearLaserTarget = targetInfo
		end
	end

	if hasHolyLight then
		self:TrySpawnHolyLightImpact(tear, player, position, targetInfo)
	end
	if hasRevelation then
		self:TrySpawnRevelationImpact(tear, player, position, targetInfo)
	end
	if hasMawOfTheVoid then
		self:TrySpawnMawOfTheVoidImpact(tear, player, position)
	end
	if hasHaemolacria then
		self:SpawnHaemolacriaChildren(tear, player)
	end
	return true
end

--死亡之眼:每枚引弹首次接触敌人时只增加一点,原生上限为8点
function InvertedCrossTear:TryAddDeadEyeCharge(tear, player)
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then return end

	local data = self:GetData(tear)
	if data.DeadEyeHit then return end
	data.DeadEyeHit = true

	if player:GetDeadEyeCharge() < self.DeadEyeInfo.MaxCharge then
		player:AddDeadEyeCharge()
	end
end

--引弹触发消失结算时若从未接触敌人,清空死亡之眼全部进度
function InvertedCrossTear:TryResetDeadEyeCharge(tear, player)
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then return end

	local data = self:GetData(tear)
	if data.DeadEyeHit or data.DeadEyeMissHandled then return end
	data.DeadEyeMissHandled = true
	player:ClearDeadEyeCharge()
end

--结算落点兼容;妈刀折返点会调用一次,但不播放消失动画或移除引弹
function InvertedCrossTear:TriggerDisappearEffect(tear)
	local data = self:GetData(tear)

	local player = self:GetPlayer(tear)
	self:TryResetDeadEyeCharge(tear, player)
	--普通形态引弹消失结算时施加圣光标记;黑色形态改由红色挥砍施加
	if player and player:GetPlayerType() == mod.IBS_PlayerID.BAzazel
	and not self:IsBlackForm(player) then
		for _, entity in ipairs(Isaac.FindInRadius(tear.Position, 75 * tear.Scale, EntityPartition.ENEMY)) do
			if self._Ents:IsEnemy(entity) then
				mod.IBS_Effect.BAzazelCrackTheSkyMark:Apply(entity, player, tear)
			end
		end
	end

	--持有圣光时不再生成默认Poof;巨大圣光由命中或落地路径单独触发
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
		if not self:HasSpiritSword(tear) then
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, tear.Position, Vector.Zero, tear):ToEffect()
			poof.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.7)
			local spr = poof:GetSprite()
			spr.Scale = Vector(0.5, 0.5)
			spr.Offset = Vector(0, -15)
		end
	end

	sfx:Play(SoundEffect.SOUND_DIVINE_INTERVENTION, 1, 2, false, 1, 0)
end

InvertedCrossTear.SpiritSwordInfo = {
	Animations = {
		Spawn = 'SwordSpawn',
		Idle = 'SwordIdle',
		Disappear = 'SwordDisappear',
	},
	RotationOffset = 90, --剑图朝上,相对方向角额外顺时针旋转90度
	DamageMultiplier = 3,
	HitInterval = 3,
}

function InvertedCrossTear:HasSpiritSword(tear)
	local player = self:GetPlayer(tear)
	return player ~= nil and player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
end

function InvertedCrossTear:GetAnimationName(tear, animation)
	if self:HasSpiritSword(tear) then
		return self.SpiritSwordInfo.Animations[animation] or animation
	end
	return animation
end

--悬浮时使用角色记录的瞄准方向,飞行时使用实际速度;先写Rotation再同步SpriteRotation
function InvertedCrossTear:UpdateSpiritSwordRotation(tear)
	if not self:HasSpiritSword(tear) then return end
	local data = self:GetData(tear)
	local direction
	if data.IsFloating and not data.IsRemoteControl then
		direction = data.AimDirection
	elseif tear.Velocity:Length() > 0.001 then
		direction = tear.Velocity
	elseif data.MomsKnifeFlight and data.MomsKnifeDirection then
		direction = data.MomsKnifeDirection
	end

	if direction and direction:Length() > 0.001 then
		tear.Rotation = direction:GetAngleDegrees() + self.SpiritSwordInfo.RotationOffset
	end
	tear.SpriteRotation = tear.Rotation
end

function InvertedCrossTear:SpawnMyReflectionCopy(tear)
	local data = self:GetData(tear)
	if data.SplitTriggered then return false end

	local player = self:GetPlayer(tear)
	if not player then return false end
	if not data.MyReflection
	and not player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION) then
		return false
	end
	data.SplitTriggered = true

	local direction = (player.Position - tear.Position):Normalized()
	if direction:Length() <= 0.001 then
		direction = (data.AimDirection or Vector(1, 0)):Normalized()
	end

	local child = self:Spawn(player, tear.Position, 0, self:GetSourceEntity(tear))
	if not child then return false end
	local childData = self:GetData(child)
	childData.MyReflection = false
	childData.SplitTriggered = true
	childData.TinyPlanetOrbit = false
	child.Scale = tear.Scale
	childData.BaseScale = tear.Scale
	childData.ChargeRatio = data.ChargeRatio
	childData.DamageMultiplier = data.DamageMultiplier

	local color = tear.Color
	child.Color = Color(color.R, color.G, color.B, self.MyReflectionInfo.CopyAlpha,
		color.RO, color.GO, color.BO)

	local speed = data.ReleaseSpeed or self.FlightInfo.DefaultSpeed
	local chargeRatio = math.max(0, math.min(1, data.ChargeRatio or 0))
	local range = data.ReleaseRange or self.FlightInfo.DefaultRange * chargeRatio
	self:Release(child, direction, speed, range, chargeRatio, player, false, true)
	childData.MomsKnifeFlight = false
	child.Velocity = direction * (childData.FlightSpeed or speed)
	return true
end

--飞行结束或主动消失;triggerEffect传false时只执行引弹自身消失流程
function InvertedCrossTear:Disappear(tear, triggerEffect)
	local data = self:GetData(tear)
	if data.Disappearing then return end

	data.Disappearing = true
	if triggerEffect ~= false then
		self:TryTriggerImpactCompatibilities(tear, self:GetPlayer(tear))
		self:TryTriggerParasiteSplit(tear)
		self:SpawnMyReflectionCopy(tear)
	end
	data.MomsKnifeFlight = false
	if data.TinyPlanetOrbitActive then
		self:EndTinyPlanetOrbit(tear)
	end
	tear.Velocity = Vector.Zero
	tear:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)
	tear:GetSprite():Play(self:GetAnimationName(tear, 'Disappear'), true)
	if triggerEffect ~= false then
		self:TriggerDisappearEffect(tear)
	end
end

InvertedCrossTear.AntiGravityInfo = {
	Delay = 30, --非自动释放时原地等待一秒
}

--妈刀接管往返飞行,与准星一样优先于反重力等待
function InvertedCrossTear:ShouldAntiGravityWait(player, tear)
	local data = tear and self:GetData(tear)
	return player and player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY)
		and not player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
		and not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
		and not (data and data.TinyPlanetOrbit)
end

InvertedCrossTear.TinyPlanetInfo = {
	OrbitFrames = 20,
}

function InvertedCrossTear:StartTinyPlanetOrbit(tear, player, direction, speed)
	local data = self:GetData(tear)
	if not data.TinyPlanetOrbit or data.IsRemoteControl or not player then return false end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then return false end

	local center = player.Position
	local offset = tear.Position - center
	local radius = offset:Length()
	local angle = radius > 0 and offset:GetAngleDegrees() or direction:GetAngleDegrees()
	local playerData = self._Ents:GetTempData(player)
	local clockwise = playerData.InvertedCrossTinyPlanetClockwise
	if clockwise == nil then
		clockwise = true
	else
		clockwise = not clockwise
	end
	playerData.InvertedCrossTinyPlanetClockwise = clockwise

	data.TinyPlanetOrbitActive = true
	data.TinyPlanetCenter = center
	data.TinyPlanetFollowPlayer = not player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY)
	data.TinyPlanetRadius = radius
	data.TinyPlanetAngle = angle
	data.TinyPlanetTravelled = 0
	data.TinyPlanetAngleStep = 360 / self.TinyPlanetInfo.OrbitFrames * (clockwise and 1 or -1)
	data.TinyPlanetDirection = direction
	data.TinyPlanetSpeed = speed
	return true
end

function InvertedCrossTear:EndTinyPlanetOrbit(tear)
	local data = self:GetData(tear)
	data.TinyPlanetOrbitActive = false
end

--返回true表示本帧仍处于绕行阶段,返回false表示已被遥控或妈刀覆盖
function InvertedCrossTear:UpdateTinyPlanetOrbit(tear)
	local data = self:GetData(tear)
	if not data.TinyPlanetOrbitActive then return false end

	local player = self:GetPlayer(tear)
	if data.IsRemoteControl
	or (player and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then
		self:EndTinyPlanetOrbit(tear)
		tear.Velocity = (data.TinyPlanetDirection or data.AimDirection) * (data.TinyPlanetSpeed or self.FlightInfo.DefaultSpeed)
		return false
	end

	if data.TinyPlanetFollowPlayer and player and player:Exists() then
		data.TinyPlanetCenter = player.Position
	end

	local remaining = 360 - (data.TinyPlanetTravelled or 0)
	local step = data.TinyPlanetAngleStep or 0
	if math.abs(step) >= remaining then
		step = step > 0 and remaining or -remaining
		self:EndTinyPlanetOrbit(tear)
	end

	data.TinyPlanetAngle = (data.TinyPlanetAngle or 0) + step
	data.TinyPlanetTravelled = (data.TinyPlanetTravelled or 0) + math.abs(step)
	local target = data.TinyPlanetCenter + Vector.FromAngle(data.TinyPlanetAngle) * data.TinyPlanetRadius
	tear.Velocity = target - tear.Position

	if not data.TinyPlanetOrbitActive then
		tear.Position = target
		tear.Velocity = data.TinyPlanetDirection * data.TinyPlanetSpeed
	end
	return true
end

--血块/化学剥皮法按引弹生成顺序交替强化;偶数发使用对应颜色和圣光加成
function InvertedCrossTear:GetAlternatingShotInfo(player)
	if not player then return nil end

	local hasBloodClot = player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_CLOT)
	local hasChemicalPeel = player:HasCollectible(CollectibleType.COLLECTIBLE_CHEMICAL_PEEL)
	if not hasBloodClot and not hasChemicalPeel then return nil end

	local playerData = self._Ents:GetTempData(player)
	local count = (playerData.InvertedCrossAlternatingShotCount or 0) + 1
	playerData.InvertedCrossAlternatingShotCount = count
	if count % 2 ~= 0 then return nil end

	if hasBloodClot and hasChemicalPeel then
		return self.BloodClotChemicalPeelInfo
	elseif hasBloodClot then
		return self.BloodClotInfo
	end
	return self.ChemicalPeelInfo
end

function InvertedCrossTear:ApplyAlternatingShot(tear, player)
	local info = self:GetAlternatingShotInfo(player)
	if not info then return end

	local data = self:GetData(tear)
	data.AlternateScaleMultiplier = info.ScaleMultiplier
	data.HolyLightDamageBonus = info.HolyLightDamageBonus
	tear.Color = info.Color
end

--玩家亲手释放时解除触碰保护;复制和效果生成物由调用方省略playerFired
function InvertedCrossTear:Release(tear, direction, speed, range, chargeRatio, player, autoRelease, bypassAntiGravity, playerFired)
	local data = self:GetData(tear)
	if data.Disappearing or not data.IsFloating then return end
	if data.AntiGravityWaiting and not bypassAntiGravity then return end

	local info = self.FlightInfo
	player = player or self:GetPlayer(tear)
	direction = (direction or tear.Velocity):Normalized()
	local baseSpeed = math.max(1, speed or info.DefaultSpeed)
	data.ReleaseSpeed = baseSpeed
	if chargeRatio == nil then chargeRatio = info.DefaultChargeRatio end
	data.AimDirection = direction
	local releaseRange = range or info.DefaultRange
	data.ReleaseRange = releaseRange
	if playerFired then
		self:SetTouchedFlags(tear, false)
	end

	--反重力先保留全部释放参数;自动释放等待松手,普通释放等待固定一秒
	if not bypassAntiGravity and self:ShouldAntiGravityWait(player, tear) then
		data.AntiGravityWaiting = true
		data.AntiGravityWaitForRelease = not not autoRelease
		data.AntiGravityWaitTime = autoRelease and nil or self.AntiGravityInfo.Delay
		data.AntiGravityDirection = direction
		data.AntiGravitySpeed = baseSpeed
		data.AntiGravityRange = range
		data.AntiGravityChargeRatio = chargeRatio
		data.AntiGravityPlayer = player
		tear.Velocity = Vector.Zero
		return
	end

	data.AntiGravityWaiting = nil
	data.AntiGravityWaitForRelease = nil
	data.AntiGravityWaitTime = nil
	data.AntiGravityDirection = nil
	data.AntiGravitySpeed = nil
	data.AntiGravityRange = nil
	data.AntiGravityChargeRatio = nil
	data.AntiGravityPlayer = nil
	speed = baseSpeed
	data.FlightSpeed = speed
	data.IsFloating = false
	data.WormSampleIndex = 0
	data.SquareLastSign = nil
	data.ChargeRatio = math.max(0, math.min(1, chargeRatio))
	tear:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)
	if (data.SuspendedFlags or 0) > 0 then
		local restoreFlags = data.SuspendedFlags & (~self.NeverRestoreTearFlags)
		if restoreFlags > 0 then
			tear:AddTearFlags(restoreFlags)
		end
		data.SuspendedFlags = 0
	end

	local hasMomsKnife = player and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
	local shouldBoostInitialSpeed = hasMomsKnife
	if shouldBoostInitialSpeed then
		speed = speed * info.InitialSpeedMultiplier
		data.FlightSpeed = speed
	end

	local flightTime = math.max(1, math.ceil(releaseRange / speed))
	--黑色形态不再按蓄力射程提前消失,普通飞行统一保留至5秒计时结束
	if self:IsBlackForm(player) then
		flightTime = math.max(flightTime, self.BlackFormInfo.FlightFrames)
	end
	data.FlightTime = flightTime
	data.BlackFlightTime = self.BlackFormInfo.FlightFrames
	local customMotionSpeed = self:IsBlackForm(player)
		and speed * self.BlackFormInfo.SpeedMultiplier or speed

	if hasMomsKnife then
		local originOffset = tear.Position - self:GetSourceEntity(tear).Position
		local initialDistance = originOffset:Length()
		local maxDistance = math.max(1, releaseRange - initialDistance)
		data.MomsKnifeFlight = true
		data.MomsKnifeReturning = false
		data.MomsKnifeAtOrigin = false
		data.MomsKnifeOriginOffset = originOffset
		data.MomsKnifeDirection = direction
		data.MomsKnifeDistance = 0
		data.MomsKnifeMaxDistance = maxDistance
		--妈刀保留常驻形态速度,不参与堕落形态三倍速
		data.MomsKnifeSpeed = speed
		data.MomsKnifeAcceleration = -(speed * speed) / (2 * maxDistance)
		data.FlightSpeed = speed
		--清除小星球标记,避免与妈刀的自定义相对距离运动叠加
		tear:ClearTearFlags(TearFlags.TEAR_ORBIT)
		tear.Velocity = Vector.Zero
	elseif self:StartTinyPlanetOrbit(tear, player, direction, customMotionSpeed) then
		data.MomsKnifeFlight = false
		data.FlightSpeed = customMotionSpeed
		tear.Velocity = Vector.Zero
	else
		data.MomsKnifeFlight = false
		tear.Velocity = direction * speed
	end
end

function InvertedCrossTear:LaunchAntiGravityTear(tear)
	local data = self:GetData(tear)
	local player = data.AntiGravityPlayer
	if player and not player:Exists() then player = nil end
	self:Release(tear, data.AntiGravityDirection, data.AntiGravitySpeed,
		data.AntiGravityRange, data.AntiGravityChargeRatio, player, false, true)
end

--返回true表示仍在等待;准星或失去反重力会立即解除等待
function InvertedCrossTear:UpdateAntiGravity(tear)
	local data = self:GetData(tear)
	if not data.AntiGravityWaiting then return false end
	tear.Velocity = Vector.Zero
	local player = data.AntiGravityPlayer
	if player and not player:Exists() then player = nil end
	if not self:ShouldAntiGravityWait(player, tear) then
		self:LaunchAntiGravityTear(tear)
		return false
	end

	if data.AntiGravityWaitForRelease then
		local firing = self.IsPlayerFiring and self.IsPlayerFiring(player) or false
		if not firing then
			self:LaunchAntiGravityTear(tear)
			return false
		end
	else
		data.AntiGravityWaitTime = (data.AntiGravityWaitTime or self.AntiGravityInfo.Delay) - 1
		if data.AntiGravityWaitTime <= 0 then
			self:LaunchAntiGravityTear(tear)
			return false
		end
	end
	return true
end

--妈刀:由本帧目标位置与实际位置的差计算速度,返程终点为相对实际攻击中心的出发点
function InvertedCrossTear:UpdateMomsKnifeFlight(tear)
	local data = self:GetData(tear)
	local player = self:GetPlayer(tear)
	if not player then
		self:Disappear(tear)
		return false
	end

	--上一帧已朝出发点飞行,本帧到达后直接移除,不再触发消失兼容
	if data.MomsKnifeAtOrigin then
		data.MomsKnifeFlight = false
		self:RemoveDeadToothRing(data)
		tear:Remove()
		return false
	end

	local distance = data.MomsKnifeDistance or 0
	local speed = data.MomsKnifeSpeed or self.FlightInfo.DefaultSpeed
	local acceleration = data.MomsKnifeAcceleration or 0
	local maxDistance = data.MomsKnifeMaxDistance or distance
	local direction = data.MomsKnifeDirection or Vector.Zero
	local originOffset = data.MomsKnifeOriginOffset or Vector.Zero
	local reachedTurningPoint = false

	speed = speed + acceleration
	distance = distance + speed

	if not data.MomsKnifeReturning then
		--离散运动中速度先越过零点时,也把飞行距离钳到预定最远点
		if speed <= 0 or distance >= maxDistance then
			distance = maxDistance
			speed = 0
			data.MomsKnifeReturning = true
			reachedTurningPoint = true
		end
	elseif distance <= 0 then
		--先飞向相对玩家的出发点,下一帧到达后再移除
		distance = 0
		speed = 0
		data.MomsKnifeAtOrigin = true
	end

	data.MomsKnifeSpeed = speed
	data.MomsKnifeDistance = distance
	local source = self:GetSourceEntity(tear)
	local aimPosition = source.Position + originOffset + direction * distance
	tear.Velocity = aimPosition - tear.Position

	if reachedTurningPoint then
		self:TryTriggerImpactCompatibilities(tear, player, aimPosition)
		self:TriggerDisappearEffect(tear)
	end
	return true
end

--初始化;外部直接生成的引弹默认飞行,主动生成入口会随后切换为悬浮
function InvertedCrossTear:OnTearInit(tear)
	local data = self:GetData(tear)
	data.IsFloating = false
	self:SetTouchedFlags(tear, true)
	self:InitializeWormCompatibility(tear, data)
	if tear:HasTearFlags(TearFlags.TEAR_HOMING) then
		data.HolyLightHoming = true
	end
	if tear:HasTearFlags(TearFlags.TEAR_ORBIT) then
		data.TinyPlanetOrbit = true
	end
	if tear:HasTearFlags(TearFlags.TEAR_BOOMERANG) then
		data.MyReflection = true
	end

	for flag, permanent in pairs(NeedClearedFlags) do
		if tear:HasTearFlags(flag) then
			if not permanent then
				data.SuspendedFlags = (data.SuspendedFlags or 0) | flag
			end
			tear:ClearTearFlags(flag)
		end
	end
	--只在引弹上关闭原生反重力,角色其他泪弹仍保留原版效果
	tear:ClearTearFlags(TearFlags.TEAR_WAIT)

	tear.CollisionDamage = 0
	tear.Mass = 0
	local player = self:GetPlayer(tear)
	self:RefreshItemCompatData(tear, player)
	--长子权是唯一允许引弹获得真实追踪的来源
	if player and player:GetPlayerType() == mod.IBS_PlayerID.BAzazel
	and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		data.BirthrightHoming = true
	end
	--虚空之喉固定黑色,其次血泪固定红色
	if data.HasMawOfTheVoid then
		tear.Color = self.MawOfTheVoidInfo.Color
	elseif data.HasHaemolacria then
		tear.Color = self.HaemolacriaInfo.Color
	elseif self:IsBlackForm(player) then
		tear.Color = self.BlackFormInfo.TearColor
	elseif player and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
		tear.Color = Color(0.75, 0.75, 0.75, 1, 0, 0, 0)
	elseif player and player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
		tear.Color = self.BrimstoneInfo.Color
	elseif player and (self:HasDrFetus(player)
	or player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)) then
		tear.Color = Color(0.3, 0.3, 0.3, 1, 0, 0, 0)
	elseif self:HasIpecac(player) then
		tear.Color = self.IpecacInfo.Color
	end
	self:InitializeDistanceItems(tear, player)
	data.BaseScale = data.BaseScale or self:GetInitialScaleMultiplier(player)
	self:UpdateChargeScale(tear, player, data.ChargeRatio)
	tear.Height = -45
	tear.FallingSpeed = 0
	tear.FallingAcceleration = -0.1
	tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
	tear:GetSprite():Play(self:GetAnimationName(tear, 'Spawn'), true)
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, 'OnTearInit', InvertedCrossTear.Variant)

function InvertedCrossTear:ConvertToInvertedCross(tear)
	if tear.Variant == self.Variant then return end

	--多维宝宝等效果会先把原引弹改成原生variant;转换回来时保留原蓄力状态
	local oldData = self._Ents:GetTempData(tear).InvertedCrossTear
	local preservedState
	if oldData then
		preservedState = {}
		for key, value in pairs(oldData) do
			preservedState[key] = value
		end
	end

	tear:ChangeVariant(self.Variant)
	tear.SubType = self.SubType
	self:OnTearInit(tear)

	if preservedState then
		local data = self:GetData(tear)
		for key, value in pairs(preservedState) do
			data[key] = value
		end
		self:UpdateChargeScale(tear, self:GetPlayer(tear), data.ChargeRatio)
	end
end

--沿SpawnerEntity向上查找;遇到双生宝/莉莉宝以外的跟班时阻止转换
function InvertedCrossTear:HasUnsupportedFamiliarInSpawnerChain(tear)
	local spawner = tear and tear.SpawnerEntity
	for _ = 1, 32 do
		if not spawner or not spawner:Exists() then return false end
		local familiar = spawner:ToFamiliar()
		if familiar and not self.FamiliarAttackInfo[familiar.Variant] then return true end
		spawner = spawner.SpawnerEntity
	end
	return false
end

--恢复白名单泪弹转换,但排除Spawner链中出现其他跟班的泪弹
function InvertedCrossTear:AutoConvert(tear)
	if not self.ConvertibleVariants[tear.Variant] then return end

	--已带有引弹状态的实体是被外部效果临时改回原生variant,必须恢复
	local hasExistingState = self._Ents:GetTempData(tear).InvertedCrossTear ~= nil
	if not hasExistingState and self:HasUnsupportedFamiliarInSpawnerChain(tear) then return end

	local player = self:GetPlayer(tear)
	if not player or player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return end

	self:ConvertToInvertedCross(tear)
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'AutoConvert')

--眼泪引爆器转换,保留主动道具原本的效果与充能消耗
function InvertedCrossTear:ConvertPlayerTears(player)
	if player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return end

	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
		local tear = entity:ToTear()
		local spawner = tear and tear.SpawnerEntity
		if tear and spawner and GetPtrHash(spawner) == GetPtrHash(player) then
			self:ConvertToInvertedCross(tear)
		end
	end
end

--记录主动道具使用的TimeCounter,在后续眼泪生成回调中直接转换
function InvertedCrossTear:PreUseTammysHead(item, rng, player, flag, slot)
	if player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return end
	self._Ents:GetTempData(player).InvertedCrossTammyHeadTime = Game().TimeCounter
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, 'PreUseTammysHead', CollectibleType.COLLECTIBLE_TAMMYS_HEAD)

function InvertedCrossTear:OnTammyHeadTearInit(tear)
	local player = self:GetPlayer(tear)
	if not player or player:GetPlayerType() ~= mod.IBS_PlayerID.BAzazel then return end

	local data = self._Ents:GetTempData(player)
	if data.InvertedCrossTammyHeadTime ~= Game().TimeCounter then return end
	self:ConvertToInvertedCross(tear)
end
InvertedCrossTear:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_INIT, CallbackPriority.LATE, 'OnTammyHeadTearInit')

function InvertedCrossTear:OnUseTearDetonator(item, rng, player)
	self:ConvertPlayerTears(player)
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUseTearDetonator', CollectibleType.COLLECTIBLE_TEAR_DETONATOR)

--引弹进入大便所在网格时立即摧毁,不影响引弹继续移动
function InvertedCrossTear:DestroyPoop(tear)
	local room = Game():GetRoom()
	local gridIndex = room:GetGridIndex(tear.Position)
	local grid = room:GetGridEntity(gridIndex)
	if grid and grid:GetType() == GridEntityType.GRID_POOP then
		room:DestroyGrid(gridIndex, true)
	end
end

InvertedCrossTear.ParasiteInfo = {
	DamageMultiplier = 0.5,
	ScaleMultiplier = 0.5,
}

--寄生虫:从碰撞点向飞行方向两侧各发射一颗小型引弹
function InvertedCrossTear:SpawnParasiteTears(tear, player)
	local parentData = self:GetData(tear)
	local direction = tear.Velocity
	if direction:Length() <= 0.001 then
		direction = parentData.MomsKnifeDirection or parentData.AimDirection or Vector(1, 0)
	end
	if direction:Length() <= 0.001 then return end

	local info = self.ParasiteInfo
	local angle = direction:GetAngleDegrees()
	local speed = self.FlightInfo.DefaultSpeed
	local chargeRatio = math.max(0, math.min(1, parentData.ChargeRatio or self.FlightInfo.DefaultChargeRatio))
	local range = self.FlightInfo.DefaultRange * chargeRatio
	local source = self:GetSourceEntity(tear)

	for _, directionOffset in ipairs({-90, 90}) do
		local childDirection = Vector.FromAngle(angle + directionOffset)
		local child = self:Spawn(player, tear.Position, 0, source)
		if child then
			local childData = self:GetData(child)
			child.Color = tear.Color
			child.Scale = tear.Scale * info.ScaleMultiplier
			childData.BaseScale = child.Scale
			childData.DamageMultiplier = parentData.DamageMultiplier * info.DamageMultiplier
			--所有分裂子引弹共用同一标记,永远不会再次触发任何分裂
			childData.SplitTriggered = true
			child:ClearTearFlags(TearFlags.TEAR_SPLIT)
			self:Release(child, childDirection, speed, range, chargeRatio, player)
			if childData.MomsKnifeFlight then
				childData.MomsKnifeFlight = false
				child.Velocity = childDirection * (childData.FlightSpeed or speed)
			end
		end
	end
end

function InvertedCrossTear:TryTriggerParasiteSplit(tear)
	local data = self:GetData(tear)
	if data.SplitTriggered then return false end

	local player = self:GetPlayer(tear)
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then return false end
	local isFlying = not data.IsFloating or (data.IsRemoteControl and data.RemoteControlMoving)
	if not isFlying or not self:HasContactCollision(tear) then return false end

	--血泪优先级高于寄生虫;这里同时覆盖敌人接触和落地接触
	if data.HasHaemolacria and self:TryTriggerHaemolacriaImpact(tear, player) then
		return false
	end

	--无论后续生成是否成功,每颗父引弹只在第一次接触时结算一次
	data.SplitTriggered = true
	self:SpawnParasiteTears(tear, player)
	return true
end

function InvertedCrossTear:UpdateParasite(tear)
	self:TryTriggerParasiteSplit(tear)
end

InvertedCrossTear.FlatStoneInfo = {
	FallingAcceleration = 1.65,
	LandingHeight = -9,
	BounceSpeed = -20,
}

--扁石:每次落地只结算移除兼容
function InvertedCrossTear:UpdateFlatStone(tear)
	local data = self:GetData(tear)
	local isFlying = not data.IsFloating or (data.IsRemoteControl and data.RemoteControlMoving)
	if not isFlying or not tear:HasTearFlags(TearFlags.TEAR_HYDROBOUNCE) then
		--标记被移除或指挥引弹停下时,恢复普通引弹的固定高度
		if data.FlatStoneBouncing then
			tear.Height = -45
			tear.FallingSpeed = 0
			tear.FallingAcceleration = -0.1
			data.FlatStoneBouncing = nil
		end
		return
	end

	local info = self.FlatStoneInfo
	data.FlatStoneBouncing = true
	tear.FallingAcceleration = info.FallingAcceleration
	if tear.Height > info.LandingHeight then
		tear.FallingSpeed = info.BounceSpeed
		self:TryTriggerImpactCompatibilities(tear, player)
		self:TriggerDisappearEffect(tear)
	end
end

--长子权是唯一允许引弹获得真实追踪的来源,仅在实际存在时清理其它追踪
function InvertedCrossTear:UpdateBirthrightHoming(tear)
	local data = self:GetData(tear)
	if not data.BirthrightHoming then
		if tear:HasTearFlags(TearFlags.TEAR_HOMING) then
			tear:ClearTearFlags(TearFlags.TEAR_HOMING)
		end
		return
	end

	local isFlying = not data.IsFloating or (data.IsRemoteControl and data.RemoteControlMoving)
	if isFlying and not data.AntiGravityWaiting and not data.Disappearing
	and not data.WaitingForNaturalDeath then
		if not tear:HasTearFlags(TearFlags.TEAR_HOMING) then
			tear:AddTearFlags(TearFlags.TEAR_HOMING)
		end
	elseif tear:HasTearFlags(TearFlags.TEAR_HOMING) then
		tear:ClearTearFlags(TearFlags.TEAR_HOMING)
	end
end

--飞行引弹按当前外扩参数越过房间边界后立即消失;堕落形态另受5秒寿命限制
function InvertedCrossTear:UpdateFlightLifetime(tear)
	local data = self:GetData(tear)
	if data.IsFloating or data.IsRemoteControl then
		return false
	end

	if not Game():GetRoom():IsPositionInRoom(tear.Position, self:GetRoomCheckMargin()) then
		self:Disappear(tear)
		return true
	end

	local player = self:GetPlayer(tear)
	if not self:IsBlackForm(player) then return false end

	local blackInfo = self.BlackFormInfo
	data.BlackFlightTime = (data.BlackFlightTime or blackInfo.FlightFrames) - 1
	if data.BlackFlightTime <= 0 then
		self:Disappear(tear)
		return true
	end
	return false
end

--POP在自然消失等待状态下速度上升并超过阈值时,重新进入一轮默认距离的飞行
function InvertedCrossTear:TryResumePopFlight(tear)
	local data = self:GetData(tear)
	if not data.WaitingForNaturalDeath or not tear:HasTearFlags(TearFlags.TEAR_POP) then
		return false
	end

	local currentSpeed = tear.Velocity:Length()
	local previousSpeed = data.PopLastSpeed
	data.PopLastSpeed = currentSpeed
	if not previousSpeed
	or currentSpeed <= self.FlightInfo.DefaultSpeed * self.FlightInfo.PopResumeSpeedFactor
	or currentSpeed <= previousSpeed then
		return false
	end

	local direction = tear.Velocity:Normalized()
	local speed = self.FlightInfo.DefaultSpeed
	data.WaitingForNaturalDeath = nil
	data.PopLastSpeed = nil
	data.IsFloating = false
	data.FlightSpeed = speed
	data.FlightTime = self:GetDefaultFlightTime()
	tear.Velocity = direction * speed
	tear.FallingAcceleration = -0.1
	return true
end

--眼泪状态更新
function InvertedCrossTear:UpdateTearState(tear)
	local data = self:GetData(tear)
	local spr = tear:GetSprite()
	if tear:HasTearFlags(TearFlags.TEAR_BOOMERANG) then
		if not data.SplitTriggered then
			data.MyReflection = true
		end
		tear:ClearTearFlags(TearFlags.TEAR_BOOMERANG)
	end
	if tear:HasTearFlags(TearFlags.TEAR_ORBIT) then
		tear:ClearTearFlags(TearFlags.TEAR_ORBIT)
	end
	self:UpdateBirthrightHoming(tear)
	self:DestroyPoop(tear)
	self:UpdateSpiritSwordRotation(tear)
	self:UpdateTechnology(tear)
	self:UpdateDeadTooth(tear)

	if data.Disappearing then
		tear.Velocity = Vector.Zero
		if spr:IsFinished(self:GetAnimationName(tear, 'Disappear')) then
			tear:Die()
		end
		return
	end

	--食泪症及科技零/科技X等待原版自然消失
	if data.WaitingForNaturalDeath then
		if self:TryResumePopFlight(tear) then return end
		tear.FallingAcceleration = 0
		return
	end

	--Spawn结束后切换至Idle
	if spr:IsFinished(self:GetAnimationName(tear, 'Spawn')) then
		spr:Play(self:GetAnimationName(tear, 'Idle'), true)
	end

	--反重力等待不触发飞行碰撞、圣光、距离缩放或FlightTime消耗
	if self:UpdateAntiGravity(tear) then return end
	if self:UpdateFlightLifetime(tear) then return end

	--统一入口覆盖悬浮、普通飞行、指挥和妈刀往返
	self:UpdateParasite(tear)
	if data.Disappearing then return end
	self:UpdateIpecac(tear)
	self:UpdateDrFetus(tear)
	self:UpdateFlatStone(tear)
	self:UpdateDistanceItems(tear)

	if data.TinyPlanetOrbitActive and self:UpdateTinyPlanetOrbit(tear) then
		data.HolyLightCooldown = (data.HolyLightCooldown or 0) - 1
		if data.HolyLightCooldown <= 0 then
			local player = self:GetPlayer(tear)
			self:SpawnHolyLight(tear, player)
			data.HolyLightCooldown = self:GetHolyLightInterval(player, tear)
		end
		return
	end

	--悬浮科技和玄秘魔眼:独立持续飞行,不消耗普通FlightTime,也不因耗尽充能而消失
	if data.IsRemoteControl then
		if tear:CollidesWithGrid() then
			tear.Velocity = Vector.Zero
		end

		if data.RemoteControlMoving and data.RemoteControlEmitLight then
			data.HolyLightCooldown = (data.HolyLightCooldown or 0) - 1
			if data.HolyLightCooldown <= 0 then
				local player = self:GetPlayer(tear)
				self:SpawnHolyLight(tear, player)
				data.HolyLightCooldown = self:GetHolyLightInterval(player, tear)
			end
		else
			--停止或耗尽后重置冷却,恢复有效充能的移动帧可立即降下圣光
			data.HolyLightCooldown = 0
		end
		return
	end

	--妈刀只接管普通释放后的飞行,往返两路持续召唤圣光
	if data.MomsKnifeFlight then
		if not self:UpdateMomsKnifeFlight(tear) then return end

		data.HolyLightCooldown = (data.HolyLightCooldown or 0) - 1
		if data.HolyLightCooldown <= 0 then
			local player = self:GetPlayer(tear)
			self:SpawnHolyLight(tear, player)
			data.HolyLightCooldown = self:GetHolyLightInterval(player, tear)
		end
		return
	end

	if data.IsFloating then
		tear.Velocity = Vector.Zero
	else
		data.FlightTime = data.FlightTime - 1
		if data.FlightTime <= 0 then
			local player = self:GetPlayer(tear)
			if tear:HasTearFlags(TearFlags.TEAR_ABSORB) or tear:HasTearFlags(TearFlags.TEAR_POP) then
				--食泪症与POP进入自然消失等待前只结算一次移除兼容,不播放消失动画或主动移除
				self:TryTriggerImpactCompatibilities(tear, player)
				self:TriggerDisappearEffect(tear)
				data.WaitingForNaturalDeath = true
				data.PopLastSpeed = tear:HasTearFlags(TearFlags.TEAR_POP) and tear.Velocity:Length() or nil
				tear.FallingAcceleration = 0
			elseif player and (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO)
			or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) then
				--进入自然消失等待前只结算一次移除兼容,不播放消失动画或主动移除
				self:TryTriggerImpactCompatibilities(tear, player)
				self:TriggerDisappearEffect(tear)
				data.WaitingForNaturalDeath = true
				tear.Velocity = Vector.Zero
				tear.FallingAcceleration = 0
			else
				self:Disappear(tear)
			end
		else
			data.HolyLightCooldown = (data.HolyLightCooldown or 0) - 1
			if data.HolyLightCooldown <= 0 then
				local player = self:GetPlayer(tear)
				self:SpawnHolyLight(tear, player)
				data.HolyLightCooldown = self:GetHolyLightInterval(player, tear)
			end
		end
	end
end

--堕落形态下,飞行中的引弹每帧都恢复为初始速度的三倍
function InvertedCrossTear:EnforceBlackFormFlightSpeed(tear)
	local data = self:GetData(tear)
	if data.Disappearing or data.WaitingForNaturalDeath then return end
	local isFlying = not data.IsFloating
		or (data.IsRemoteControl and data.RemoteControlMoving)
	if not isFlying then return end

	local player = self:GetPlayer(tear)
	if not self:IsBlackForm(player) then return end
	if data.MomsKnifeFlight or data.TinyPlanetOrbitActive
	or (not data.IsRemoteControl
	and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)) then return end
	local direction = tear.Velocity
	if direction:Length() <= 0.001 then
		direction = data.AimDirection or data.TinyPlanetDirection
			or data.MomsKnifeDirection or Vector(1, 0)
	end
	if direction:Length() <= 0.001 then return end

	local speed = math.max(1, data.ReleaseSpeed or self.FlightInfo.DefaultSpeed)
		* self.BlackFormInfo.SpeedMultiplier
	data.FlightSpeed = speed
	tear.Velocity = direction:Normalized() * speed
end

function InvertedCrossTear:OnTearUpdate(tear)
	self:UpdateTearState(tear)
	self:EnforceBlackFormFlightSpeed(tear)
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, 'OnTearUpdate', InvertedCrossTear.Variant)

--彼列之眼:首次接触敌人后永久提高本枚引弹的伤害和尺寸,并染红
function InvertedCrossTear:TryApplyEyeOfBelial(tear, player)
	if not player or not player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_BELIAL) then return end

	local data = self:GetData(tear)
	if data.BelialTriggered then return end
	data.BelialTriggered = true

	local info = self.EyeOfBelialInfo
	data.DamageMultiplier = data.DamageMultiplier * info.DamageMultiplier
	data.BelialScaleMultiplier = info.ScaleMultiplier
	self:UpdateChargeScale(tear, player, data.ChargeRatio)
	tear.Color = info.Color
	data.HolyLightHoming = true
end

--仅作引导,不执行原版眼泪碰撞伤害;普通火和红火除外
function InvertedCrossTear:PreTearCollision(tear, collider)
	if collider.Type == EntityType.ENTITY_FIREPLACE and collider.Variant >= 0 and collider.Variant <= 1 then
		collider:TakeDamage(math.max(1, collider.HitPoints), 0, EntityRef(tear), 0)
	end

	if self._Ents:IsEnemy(collider) then
		local player = self:GetPlayer(tear)
		self:TryAddDeadEyeCharge(tear, player)
		if self:TryTriggerHaemolacriaImpact(tear, player) then return end
		self:TryTriggerImpactCompatibilities(tear, player, collider.Position, collider)
		self:TryApplyEyeOfBelial(tear, player)
	end

	--妈刀每帧结算并优先覆盖英灵剑;英灵剑独立每3帧结算;两者均继承眼球突出/煤块的距离倍率
	local player = self:GetPlayer(tear)
	local distanceDamageMultiplier = player and self:GetDistanceDamageMultiplier(tear, player) or 1
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
	and collider:IsVulnerableEnemy() then
		local data = self:GetData(tear)
		data.MomsKnifeHitFrames = data.MomsKnifeHitFrames or {}
		local hash = GetPtrHash(collider)
		local frame = Game():GetFrameCount()
		if data.MomsKnifeHitFrames[hash] ~= frame then
			data.MomsKnifeHitFrames[hash] = frame
			collider:TakeDamage(player.Damage * data.DamageMultiplier * 3 * distanceDamageMultiplier, 0, EntityRef(tear), 0)
		end
	elseif player and player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
	and collider:IsVulnerableEnemy() then
		local data = self:GetData(tear)
		local info = self.SpiritSwordInfo
		data.SpiritSwordHitFrames = data.SpiritSwordHitFrames or {}
		local hash = GetPtrHash(collider)
		local frame = Game():GetFrameCount()
		local lastHit = data.SpiritSwordHitFrames[hash]
		if lastHit == nil or frame - lastHit >= info.HitInterval then
			data.SpiritSwordHitFrames[hash] = frame
			collider:TakeDamage(player.Damage * data.DamageMultiplier * info.DamageMultiplier * distanceDamageMultiplier, 0, EntityRef(tear), 0)
		end
	end
	return true
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 'PreTearCollision', InvertedCrossTear.Variant)

--锚定激光持续瞄准兼容目标;实体目标会实时移动,目标消失后停在最后位置
function InvertedCrossTear:OnAnchoredLaserUpdate(laser)
	local targetData = self._Ents:GetTempData(laser).InvertedCrossTearLaserTarget
	local target = targetData
	if type(targetData) == 'table' then
		target = self:ResolveImpactTarget(targetData)
		if target then target = target + Vector(0, -10) end
	end
	if target then
		local angle = (target - laser.Position):GetAngleDegrees()
		laser.Angle = angle
		laser.AngleDegrees = angle
	end
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, 'OnAnchoredLaserUpdate')

--持续科技激光只跟随来源生命周期,不再改写激光颜色
function InvertedCrossTear:OnTechnologyLaserUpdate(laser)
	local tear = self._Ents:GetTempData(laser).InvertedCrossTearTechnologySource
	if not tear then return end
	if not tear:Exists() or tear:IsDead() or self:GetData(tear).Disappearing then
		laser:Remove()
	end
end
InvertedCrossTear:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, 'OnTechnologyLaserUpdate')

return InvertedCrossTear
