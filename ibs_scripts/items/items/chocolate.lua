--巧克力

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths
local Stats = mod.IBS_Lib.Stats

local sfx = SFXManager()

--临时眼泪数据
local function GetTearData(tear)
	local data = Ents:GetTempData(tear)
	data.CHOCOLATE_TEAR = data.CHOCOLATE_TEAR or {Player = nil}
	
	return data.CHOCOLATE_TEAR
end

--设置特殊眼泪
local function SetTear(tear, player)
	local data = GetTearData(tear)
	data.Player = player
end

--临时玩家数据
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.CHOCOLATE_PLAYER = data.CHOCOLATE_PLAYER or {Left = 0}

	return data.CHOCOLATE_PLAYER
end

--敌人受击变友好
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -300, function(_,target, dmg, flags, source)
	if target:IsEnemy() and target:IsVulnerableEnemy() and not target:IsBoss() and not target:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		if source.Entity then
			if source.Entity:ToTear() then
				local tear = source.Entity
				local data = Ents:GetTempData(tear).CHOCOLATE_TEAR
			
				if data then
					target:AddCharmed(EntityRef(data.Player), -1)
					target.HitPoints = (target.MaxHitPoints)/2
				end	
			end
		end
	end
end)

--方向转向量
local ToVector = {
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}

--双击发射
local function Shoot(_,player, type, dir)
	if (type == 1) and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		if player:HasCollectible(IBS_Item.chocolate) and player:IsExtraAnimationFinished() and not player:IsCoopGhost() then
			local data = GetPlayerData(player)
			if data.Left > 0 then
				data.Left = data.Left - 1
				
				local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, player.Position, ToVector[dir]*10, player):ToTear()
				SetTear(tear, player)
				tear.CollisionDamage = 2.14
				tear.FallingAcceleration = 0.0214
				tear:SetColor(Color(1,0.5,0.3,1),-1,0)
				tear.Scale = 1
				tear:Update()
			end
		end
	end	
end
mod:AddCallback(IBS_Callback.PLAYER_DOUBLE_TAP, Shoot)

--新房间获得机会
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if Game():GetRoom():IsFirstVisit() then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(IBS_Item.chocolate) then
				local data = GetPlayerData(player)
				data.Left = 2
				player:SetColor(Color(92/255, 47/255, 22/255),20,2,true)
				sfx:Play(SoundEffect.SOUND_BIRD_FLAP)
			end
		end
	end	
end)

--新贪婪波次获得机会
mod:AddCallback(IBS_Callback.GREED_NEW_WAVE, function()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(IBS_Item.chocolate) then
			local data = GetPlayerData(player)
			data.Left = 2
			player:SetColor(Color(92/255, 47/255, 22/255),20,2,true)
			sfx:Play(SoundEffect.SOUND_BIRD_FLAP)
		end
	end
end)
