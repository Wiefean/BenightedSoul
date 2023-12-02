--节制之骨

local mod = Isaac_BenightedSoul
local IBS_API = mod.IBS_API
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths
local Stats = mod.IBS_Lib.Stats

local sfx = SFXManager()

local ErrorTipName = "IBS_API.BOT"
IBS_API.BOT = {}

--来自其他模组的条件,用于判断是否让眼泪获得节制之骨的效果
local ModTearCondition = {}

--添加条件
function IBS_API.BOT:AddTearCondition(condition, name)
	local err,mes = mod:CheckArgType(condition, "function", nil, 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(name, "string", nil, 2, ErrorTipName)
	if err then error(mes, 2) end

	ModTearCondition[name] = condition
end

--眼泪特效黑名单
local TearFlagBlacklist = {
	--环绕(小星球,木星,无暇圣心)
	TearFlags.TEAR_ORBIT,
	TearFlags.TEAR_ORBIT_ADVANCED,
	
	--剖腹产
	TearFlags.TEAR_FETUS_SWORD,
	TearFlags.TEAR_FETUS_BONE,
	TearFlags.TEAR_FETUS_KNIFE,
	TearFlags.TEAR_FETUS_TECHX,
	TearFlags.TEAR_FETUS_TECH,
	TearFlags.TEAR_FETUS_BRIMSTONE,
	TearFlags.TEAR_FETUS_BOMBER,
	TearFlags.TEAR_FETUS,
	
	--锁链(遗骸等)
	TearFlags.TEAR_CHAIN,
	
	--悬浮科技
	TearFlags.TEAR_LUDOVICO
}

--检查条件
local function CheckTearCondition(tear)
	for _,flag in pairs(TearFlagBlacklist) do
		if tear:HasTearFlags(flag) then return false end
	end

	if IBS_API.SSG:IsFallingTear(tear) then return false end --判断是否为仰望星空的下落眼泪

	--检查来自其他模组的条件
	for k,v in ipairs(ModTearCondition) do
		local result = v.Condition(tear)
		if (result ~= nil) and (result == false) then return false end
	end

	return true
end

--临时眼泪数据(科X激光也可使用)
local function GetTearData(tear)
	local data = Ents:GetTempData(tear)
	data.BoneOfTemperance_Tear = data.BoneOfTemperance_Tear or {
		Stop = false,
		Recycle = false,
		TimeOut = 210
	}
	return data.BoneOfTemperance_Tear
end

--临时妈刀数据(常规激光也可使用)
local function GetKnifeData(knife)
	local data = Ents:GetTempData(knife)
	data.BoneOfTemperance_Knife = data.BoneOfTemperance_Knife or {Wait = 0}

	return data.BoneOfTemperance_Knife
end

--眼泪逻辑
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_,tear)
	local player = Ents:IsSpawnerPlayer(tear, true)
	
    if player and player:HasCollectible(IBS_Item.bone) and CheckTearCondition(tear) then
		local data = GetTearData(tear)

		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		tear:AddTearFlags(TearFlags.TEAR_PIERCING)
		tear:SetColor(Color(1,1,1,0.1), -1, 1)
		
		--突眼
		if tear:HasTearFlags(TearFlags.TEAR_SHRINK) then
			tear:ClearTearFlags(TearFlags.TEAR_SHRINK) 
		end
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_,tear)
	local data = Ents:GetTempData(tear).BoneOfTemperance_Tear
	local player = Ents:IsSpawnerPlayer(tear, true)

	if data and player then
		tear.FallingSpeed = 0
		tear.FallingAcceleration = -0.1
		tear:SetColor(Color(1,1,1,0.1), -1, 1)
		
		if data.Stop and not data.Recycle then
			tear.Velocity = Vector.Zero
		elseif data.Recycle then
			tear.Velocity = 30*((player.Position - tear.Position):Normalized())
			if (tear.Position - player.Position):Length() <= 2*(player.Size) then
				tear:Remove()
			end
		end
		
		if data.TimeOut > 0 then
			data.TimeOut = data.TimeOut - 1
		elseif not data.Recycle then
			data.Recycle = true
		end
	end
end)

--科技X兼容
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_,laser)
	if laser.SubType == 2 then
		local data = Ents:GetTempData(laser).BoneOfTemperance_Tear
		local player = Ents:IsSpawnerPlayer(laser, true)
			
		if data and player then
			if data.Stop and not data.Recycle then
				laser.Velocity = Vector.Zero
			elseif data.Recycle then
				laser.Velocity = 30*((player.Position - laser.Position):Normalized())
				if (laser.Position - player.Position):Length() <= 2*(player.Size) then
					laser:Remove()
				end
			end
			
			if data.TimeOut > 0 then
				data.TimeOut = data.TimeOut - 1
			elseif not data.Recycle then
				data.Recycle = true
			end
		end	
	end
end)

--生成停滞的眼泪
local function SpawnTear(player, position)
	local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, position, Vector.Zero, player):ToTear()
	local tdata = GetTearData(tear)
	tdata.Stop = true
	
	tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
	tear:AddTearFlags(TearFlags.TEAR_PIERCING)	
	tear:SetColor(Color(1,1,1,0.1), -1, 1)
	tear.CollisionDamage = math.max(3.5, player.Damage)
	tear.FallingSpeed = 0
	tear.FallingAcceleration = -0.1	
	
	return tear
end

--常规激光兼容(包括硫磺火,不包括牵引光束)
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_,laser)
	if (laser.Variant ~= 7) and (laser.SubType == 0) then
		local player = Ents:IsSpawnerPlayer(laser, true)
		
		if player and player:HasCollectible(IBS_Item.bone) then
			local data = GetKnifeData(laser)

			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			else
				data.Wait = 9
				local tear = SpawnTear(player, laser.EndPoint + 20 * RandomVector())
				tear.Scale = 0.7
				tear:ChangeVariant(37)
				tear:Update()
			end			
		end	
	end
end)

--妈刀等兼容
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_,knife)
	local player = Ents:IsSpawnerPlayer(knife, true)
	
	if player and player:HasCollectible(IBS_Item.bone) then
		local data = GetKnifeData(knife)

		if data.Wait > 0 then
			data.Wait = data.Wait - 1
		else
			data.Wait = 10
			if knife:IsFlying() then
				local tear = SpawnTear(player, knife.Position)
				tear.Scale = 1
				
				if (knife.Variant == 0) then --经典妈刀对应金属子弹
					tear:ChangeVariant(3)
				elseif (knife.Variant == 2) then --骨刀棒对应镰刀子弹(骨棒对应骨头子弹，不知为何自动设置了)
					tear:ChangeVariant(8)
				elseif (knife.Variant == 3) or (knife.Variant == 5) then --驴骨棒和血吸管对应血泪
					tear:ChangeVariant(1)
				elseif (knife.Variant == 10) then --妈刀配英灵剑对应剑气
					tear:ChangeVariant(47)
				elseif (knife.Variant == 11) then --妈刀配英灵剑配科技对应激光剑气
					tear:ChangeVariant(49)	
				end	
				
				tear:Update()
			end			
		end
	end
end)

--双击
mod:AddCallback(IBS_Callback.PLAYER_DOUBLE_TAP, function(_,player, type, action)
	if (type == 2) and (action == ButtonAction.ACTION_DROP) then
		if player:HasCollectible(IBS_Item.bone) then
			local game = Game()
			if (not game:IsPaused()) and (player:AreControlsEnabled()) then
				for _,tear in pairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
					tear = tear:ToTear()
					local tearPlayer = Ents:IsSpawnerPlayer(tear, true)
					
					if Ents:IsTheSame(tearPlayer, player) and CheckTearCondition(tear) then
						local data = GetTearData(tear)
						if not data.Stop then data.Stop = true end
					end	
				end	
				for _,laser in pairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
					local laserPlayer = Ents:IsSpawnerPlayer(laser, true)
					
					if Ents:IsTheSame(laserPlayer, player) then
						local data = GetTearData(laser)
						if not data.Stop then data.Stop = true end
					end	
				end
			end
		end
	end	
end)


--眼泪/科X激光是否有节制之骨的效果
function IBS_API.BOT:TearHasEffect(tear)
	local err,mes = mod:CheckArgType(tear, "userdata", "tear or laser", 1, ErrorTipName)
	if err then error(mes, 2) end
	
	local data = Ents:GetTempData(tear).BoneOfTemperance_Tear
	if data and Ents:IsSpawnerPlayer(tear, true) then
		return true
	end
	
	return false
end	

--获取节制之骨效果的持续时间
function IBS_API.BOT:GetTearTimeOut(tear)
	local err,mes = mod:CheckArgType(tear, "userdata", "tear or laser", 1, ErrorTipName)
	if err then error(mes, 2) end
	
	local data = Ents:GetTempData(tear).BoneOfTemperance_Tear
	
	return (data and data.TimeOut) or 0
end	

--设置节制之骨效果的持续时间,若没有效果则添加效果
function IBS_API.BOT:SetTearTimeOut(tear, frames)
	local err,mes = mod:CheckArgType(tear, "userdata", "tear or laser", 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(frames, "number", nil, 2, ErrorTipName, true)
	if err then error(mes, 2) end
	
	frames = frames or 210
	
	local data = GetTearData(tear)
	data.TimeOut = frames
end	

--添加节制之骨效果的持续时间,若没有效果则添加效果
function IBS_API.BOT:AddTearTimeOut(tear, frames)
	local err,mes = mod:CheckArgType(tear, "userdata", "tear or laser", 1, ErrorTipName)
	if err then error(mes, 2) end
	err,mes = mod:CheckArgType(frames, "number", nil, 2, ErrorTipName)
	if err then error(mes, 2) end
	
	local data = GetTearData(tear)
	data.TimeOut = data.TimeOut + frames
end	

--让眼泪停滞,若没有节制之骨的效果则添加效果
function IBS_API.BOT:StopTear(tear)
	local err,mes = mod:CheckArgType(tear, "userdata", "tear or laser", 1, ErrorTipName)
	if err then error(mes, 2) end
	
	local data = GetTearData(tear)
	data.Stop = true
end	

