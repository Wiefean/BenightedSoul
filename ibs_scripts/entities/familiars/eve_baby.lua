--夏娃宝

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID

local game = Game()
local sfx = SFXManager()

local EveBaby = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.EveBaby.Variant,
	SubType = IBS_FamiliarID.EveBaby.SubType,
	Name = {zh = '夏娃宝', en = 'Eve Baby'}
}

--初始化
function EveBaby:OnFamiliarInit(familiar) 
    familiar:GetSprite():Play('Idle')
    familiar:GetSprite():PlayOverlay('Halo')
	
	if familiar.SubType == self.SubType.Twin then
		familiar:AddToOrbit(233)
		familiar.OrbitDistance = Vector(70,70)
		familiar.OrbitSpeed = 0.03	
	else
		familiar:AddToFollowers()
	end
end
EveBaby:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', EveBaby.Variant)

--更新
function EveBaby:OnFamiliarUpdate(familiar)
    local player = familiar.Player
	if not player then return end
	local Single = familiar.SubType == self.SubType.Single
	local bff = player:HasCollectible(247) --大宝
	local radius = 70

	if bff then
		radius = 90
	end
	
	if Single then
		local target = self._Finds:ClosestEnemy(player.Position)
		if target and target.Position:Distance(player.Position) < 200 + target.Size then
			local offset = (player.Position - target.Position):Resized(40 + target.Size / 2)
			familiar:FollowPosition(target.Position + offset)
			familiar.Velocity = familiar.Velocity * 0.5
		else
			familiar:FollowParent()
		end
	
		if familiar:IsFrame(2,0) then
			local dmg = math.max(2, player.Damage * 0.3)
			if bff then
				dmg = dmg * 2
			end
		
			for _,ent in ipairs(Isaac.GetRoomEntities()) do
				if ent.Position:Distance(familiar.Position) <= radius + ent.Size then
					if self._Ents:IsEnemy(ent) then
						ent:TakeDamage(dmg, 0, EntityRef(familiar), 0)
						ent.Velocity = ent.Velocity * 0.5
					else			
						--抵挡子弹
						local proj = ent:ToProjectile()
						if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
							proj.Velocity = proj.Velocity * 0.01 * math.random(80, 90)
							if proj.Velocity:Length() <= 1 then
								proj:Die()
							end
						end
					end
				end
			end
		end
	else
		familiar.OrbitDistance = Vector(70,70)
		familiar.OrbitSpeed = 0.03
		familiar.Velocity = (familiar:GetOrbitPosition(player.Position) - familiar.Position)	
	
		if familiar:IsFrame(2,0) then
			local dmg = 2
			if bff then
				dmg = dmg * 2
			end		
		
			for _,ent in ipairs(Isaac.GetRoomEntities()) do
				if ent.Position:Distance(familiar.Position) <= radius + ent.Size then
					--对敌人造成伤害
					if self._Ents:IsEnemy(ent) then
						ent:TakeDamage(dmg, 0, EntityRef(familiar), 0)
						ent.Velocity = ent.Velocity * 0.5
					else			
						--抵挡子弹
						local proj = ent:ToProjectile()
						if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
							proj.Velocity = proj.Velocity * 0.01 * math.random(80, 90)
							if proj.Velocity:Length() <= 1 then
								proj:Die()
							end
						end		
					end
				end
			end
		end
	end	
	
end
EveBaby:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', EveBaby.Variant)


return EveBaby