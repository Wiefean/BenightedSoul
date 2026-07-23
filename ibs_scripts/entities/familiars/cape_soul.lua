--卓越斗篷灵魂

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID
local IBS_Compat = mod.IBS_Compat

local game = Game()
local sfx = SFXManager()

local CapeSoul = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.CapeSoul.Variant,
	SubType = IBS_FamiliarID.CapeSoul.SubType,
	Name = {zh = '卓越斗篷灵魂', en = 'Cape Soul'}
}

--生成
function CapeSoul:Spawn(player)
	local familiar = Isaac.Spawn(3, self.Variant, self.SubType, player.Position, Vector.Zero, player):ToFamiliar()
	familiar.Player = player
	return familiar
end

--初始化
function CapeSoul:OnFamiliarInit(familiar) 
    familiar:GetSprite():Play('GhostAppear')
    familiar:AddToOrbit(1333)
	familiar.OrbitDistance = Vector(30,30)
	familiar.OrbitSpeed = 0.03
end
CapeSoul:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', CapeSoul.Variant)

--更新
function CapeSoul:OnFamiliarUpdate(familiar)
	familiar.OrbitDistance = Vector(30,30)
    familiar.OrbitSpeed = 0.03
    local player = familiar.Player; if not player then return end
	local spr = familiar:GetSprite()

    familiar.Velocity = (familiar:GetOrbitPosition(player.Position) - familiar.Position)
	
	if not spr:IsPlaying('GhostAppear') then
		spr:Play('Dripping')
		
		local vec = self._Players:GetAimingVector(player)
		local isShooting = self._Players:IsShooting(player)
		local dir = (isShooting and self._Maths:VectorToDirection(vec)) or -1
		local headFrame = 0
			
		if familiar.FireCooldown > 0 then
			familiar.FireCooldown = familiar.FireCooldown - 1
			
			--摇篮曲
			if player:HasTrinket(141) then
				familiar.FireCooldown = familiar.FireCooldown - 1
			end
		elseif isShooting then
			familiar.FireCooldown = math.max(0, math.ceil(player.MaxFireDelay)) --取角色射速
			familiar.HeadFrameDelay = 2
			
			local tearflags = TearFlags.TEAR_SPECTRAL
			local color = Color(1,1,1,0.5)
			
			--儿童弯勺
			if player:HasTrinket(127) and not player:HasCollectible(3) then
				tearflags = tearflags | TearFlags.TEAR_HOMING
				color = Color(0.4, 0.15, 0.38, 0.5, 0.27843, 0, 0.4549)
			end
			
			--大宝
			local mult = (player:HasCollectible(247) and 0.6) or 0.3
			
			--发射眼泪
			self._Players:FireTears(player, function(tear)
				tear:AddTearFlags(tearflags)
				tear.Color = tear.Color * color		
			end, familiar.Position, vec:Resized(10*player.ShotSpeed), true, false, false, player, mult)
		end
		
		if familiar.HeadFrameDelay > 0 then
			familiar.HeadFrameDelay = familiar.HeadFrameDelay - 1
			headFrame = 2
		end
		
		--头部动画
		if dir == Direction.UP then
			spr:SetOverlayFrame("HeadUp", headFrame)
		elseif dir == Direction.LEFT then		
			spr:SetOverlayFrame("HeadLeft", headFrame)
		elseif dir == Direction.RIGHT then			
			spr:SetOverlayFrame("HeadRight", headFrame)
		else
			spr:SetOverlayFrame("HeadDown", headFrame)
		end
	end
end
CapeSoul:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', CapeSoul.Variant)



return CapeSoul