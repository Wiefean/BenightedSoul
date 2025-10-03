--紫电能量剑

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID
local IBS_Sound = mod.IBS_Sound
local Maths = mod.IBS_Lib.Maths
local IBS_Compat = mod.IBS_Compat

local game = Game()
local sfx = SFXManager()

local Sword = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.Sword.Variant,
	SubType = IBS_FamiliarID.Sword.SubType,
	Name = {zh = '紫电护主之刃', en = 'Sword of Siberite'}
}

Sword.ItemID = mod.IBS_ItemID.Sword

--缝纫机mod兼容
IBS_Compat.Sewn:AddFamiliar(Sword, Sword.ItemID, {
	"额外造成4点伤害和流血效果",
	"伤害 x 1.25#优先攻击角色附近的敌弹",

	"4 extra dmg with bleeding effect",
	"DMG x 1.25#Targets projectiles near Isaac first"
})

--动画
Sword.Anim = {
	[Direction.NO_DIRECTION] = "Right", 
	[Direction.LEFT] = "Left",
	[Direction.UP] = "Left",
	[Direction.RIGHT] = "Right",
	[Direction.DOWN] = "Right"
}

--拖尾
function Sword:ApplyTrail(familiar)
	return self._Ents:ApplyTrail(familiar, Color(0.4, 0.15, 0.38, 0.3, 0.27843, 0, 0.4549), Vector(2,2), 0.07)
end

--初始化
function Sword:OnInit(familiar)
	familiar.IsFollower = true
	self:ApplyTrail(familiar)
end
Sword:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnInit', Sword.Variant)


--新房间拖尾生成,以及位置修正
function Sword:OnNewRoom()
	for _,familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, self.Variant)) do
		local player = familiar:ToFamiliar().Player

		--防止直接出现在具有正邪效果的玩家面前(东方mod)
		if IBS_Compat.THI:SeijaNerf(player) then
			familiar.Position = game:GetRoom():ScreenWrapPosition(player.Position, 25)
		end
		
		self:ApplyTrail(familiar)
	end
end
Sword:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--碰撞判定
function Sword:OnCollision(familiar, other)
	local stage = game:GetLevel():GetStage()
	local player = familiar.Player
	local spr = familiar:GetSprite()
	local dmg = stage * 1.5 + 0.3*player.Damage
	local extra = 1

	if player:HasTrinket(141) then --摇篮曲饰品
		dmg = dmg * 1.2
	end
	
	-- if player:HasCollectible(247) then --大宝
		-- dmg = dmg * 2
	-- end
	
	if IBS_Compat.Sewn:IsUltra(familiar) then
		dmg = dmg * 1.25
	end
	
	if dmg < 7 then dmg = 7 end

	if spr:IsEventTriggered("DMG") or spr:IsEventTriggered("DMG2") then
		if self._Ents:IsEnemy(other) then --造成伤害
			if IBS_Compat.Sewn:IsSuper(familiar) then --缝纫机mod
				other:TakeDamage(4, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(familiar), 0)
				other:AddBleeding(EntityRef(familiar), 90)
			end
			other:TakeDamage(dmg, 0, EntityRef(familiar), 0)
			sfx:Play(540, 0.2, 0, false, 0.8)
			
		--正邪削弱(东方mod)
		--砍死你
		elseif other:ToPlayer() and IBS_Compat.THI:SeijaNerf(other:ToPlayer()) then
			other:TakeDamage(1, 0, EntityRef(other), 0)
		end	
	end
end
Sword:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, 'OnCollision', Sword.Variant)

--目标数据
function Sword:GetTargetData(ent)
	local data = self._Ents:GetTempData(ent)
	data.SwordTarget = data.SwordTarget or {
		SwordPtr = 0,
		Timeout = 1
	}

	return data.SwordTarget
end

--更新目标数据
function Sword:UpdateTargetData(ent)
	local data = self._Ents:GetTempData(ent).SwordTarget
	
	if data then
		if data.Timeout > 0 then
			data.Timeout = data.Timeout - 1
		elseif (data.SwordPtr ~= 0) then
			data.SwordPtr = 0
		end
	end
end
Sword:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'UpdateTargetData')
Sword:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, 'UpdateTargetData')

--是否应该分散攻击
function Sword:ShouldDispersion(pos, ptr)
	local num = 0

	for _,ent in pairs(Isaac.GetRoomEntities()) do
		if self._Ents:IsEnemy(ent) and (ent.Position:Distance(pos) <= 300) then
			local data = self._Ents:GetTempData(ent).SwordTarget
			if data then
				if (data.SwordPtr == 0) or (data.SwordPtr == ptr) then
					num = num + 1
				end
			else
				num = num + 1
			end
		end
	end

	return num > 0
end

--查找目标
function Sword:FindTarget(centerPos, familiar)
	local closestEnt = nil
	local closestDist = 114514
	local ptr = GetPtrHash(familiar)
	local player = familiar.Player
	
	--是否可以瞄准敌弹(宝宝弯勺或缝纫机mod蓝冠)
	local canTargetProj = player:HasTrinket(127) or IBS_Compat.Sewn:IsUltra(familiar)

	for _,ent in pairs(Isaac.GetRoomEntities()) do
		local dist = ent.Position:Distance(centerPos)
		local proj = ent:ToProjectile()
		
		if canTargetProj and (dist <= 200) and proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local data = self:GetTargetData(proj)
			if (data.SwordPtr == 0) or (data.SwordPtr == ptr) then
				if dist < closestDist then
					closestDist = dist
					closestEnt = proj
					data.Timeout = 2
					if (data.SwordPtr == 0) then data.SwordPtr = ptr end
				end
			end
		elseif (dist <= 300) and ((not closestEnt) or closestEnt.Type ~= 9) and self._Ents:IsEnemy(ent) then
			if self:ShouldDispersion(centerPos, ptr) then
				local data = self:GetTargetData(ent)
				
				if (data.SwordPtr == 0) or (data.SwordPtr == ptr) then
					if dist < closestDist then
						closestDist = dist
						closestEnt = ent
						data.Timeout = 2
						if (data.SwordPtr == 0) then data.SwordPtr = ptr end
					end
				end
			elseif dist < closestDist then
				closestDist = dist
				closestEnt = ent
			end
		end
	end

	return closestEnt
end

--更新
function Sword:OnUpdate(familiar)
	local player = familiar.Player
	local spr = familiar:GetSprite()
	local move_dir = player:GetMovementDirection()
	local target = self:FindTarget(player.Position, familiar)
	
	--有目标时
    if (target ~= nil) then
		familiar:FollowPosition(target.Position)
		familiar.Velocity = familiar.Velocity * 3
		
		--攻击动画
		local vec = (target.Position - familiar.Position):Normalized()
		local dir = Maths:VectorToDirection(vec)
		spr:Play("Attack", false)
		familiar.FlipX = (dir == Direction.RIGHT or dir == Direction.DOWN)
	else --无目标时
		familiar:FollowPosition(player.Position)
		
		--正邪削弱,追击玩家(东方mod)
		if IBS_Compat.THI:SeijaNerf(player) then
			local vec = (player.Position - familiar.Position):Normalized()
			local dir = Maths:VectorToDirection(vec)
			spr:Play("Attack", false)
			familiar.FlipX = (dir == Direction.RIGHT or dir == Direction.DOWN)			
			familiar.Velocity = familiar.Velocity * 0.6
		else	
			spr:Play(self.Anim[move_dir] or 'Right', false)
			familiar.FlipX = false
			familiar.Velocity = familiar.Velocity * 6
		end
	end

	--音效与图层修正
	if spr:IsPlaying("Attack") then
		familiar.DepthOffset = 70
		if spr:IsEventTriggered("DMG") then
			sfx:Play(IBS_Sound.Sword1)
		end
		if spr:IsEventTriggered("DMG2") then
			sfx:Play(IBS_Sound.Sword2)
		end
	else
		familiar.DepthOffset = 100
	end
	
	--大宝
	if player:HasCollectible(247) then 
		spr.Scale = Vector(0.8, 0.8) --贴图修正
		
		--攻速翻倍
		if (spr:GetFrame() % 2 == 0) then
			spr:Update()
		end	
	end
	
	--缝纫机mod皇冠位置修正
	IBS_Compat.Sewn:SetCrownOffset(familiar, Vector(0,-20))
end
Sword:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnUpdate', Sword.Variant)



--拖尾更新
function Sword:OnTrailUpdate(effect)
	if effect.SpawnerEntity and effect.SpawnerEntity:ToFamiliar() then
		local familiar = effect.SpawnerEntity:ToFamiliar()
		if familiar.Variant == self.Variant then
			local spr = familiar:GetSprite()

			if spr:IsPlaying("Left") or spr:IsPlaying("Right") then
				local angle = familiar.Velocity:Normalized():GetAngleDegrees()

				if (angle < 45 and angle >= -45) then --右
					effect.ParentOffset = Vector(8,-30)
				elseif (angle < -45 and angle >= -135) then --上
					effect.ParentOffset = Vector(0,-10)
				elseif (angle > 45 and angle <= 135) then --下
					effect.ParentOffset = Vector(0,-30) 
				else --左
					effect.ParentOffset = Vector(-8,-30) 
				end
			elseif spr:IsPlaying("Attack") then
				local frame = spr:GetFrame()
				local offset = Vector.Zero
				
				if frame == 0 then offset = Vector(30,-38) end
				if frame == 1 then offset = Vector(10,-34) end
				if frame == 2 then offset = Vector(8,-34) end
				if frame == 3 then offset = Vector(0,-30) end
				if frame == 4 then offset = Vector(-6,-26) end
				if frame == 5 then offset = Vector(-8,-22) end
				if frame == 6 then offset = Vector(-10,-18) end
				if frame == 7 then offset = Vector(-12,0) end
				if frame == 8 then offset = Vector(-14,20) end
				if frame == 9 then offset = Vector(0,20) end
				if frame == 10 then offset = Vector(-14,20) end
				if frame == 11 then offset = Vector(-12,0) end
				if frame == 12 then offset = Vector(-10,-18) end
				if frame == 13 then offset = Vector(-8,-22) end
				if frame == 14 then offset = Vector(-6,-26) end
				if frame == 15 then offset = Vector(0,-30) end
				if frame == 16 then offset = Vector(8,-34) end
				if frame == 17 then offset = Vector(10,-34) end
				if frame == 18 then offset = Vector(30,-38) end
				
				if familiar.FlipX then offset.X = -offset.X end
				
				effect.ParentOffset = offset
			end			
		end
	end
end
Sword:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, 'OnTrailUpdate', EffectVariant.SPRITE_TRAIL)


return Sword