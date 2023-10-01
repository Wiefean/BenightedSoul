--紫电能量剑

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Sound = mod.IBS_Sound
local Ents = mod.IBS_Lib.Ents
local Finds = mod.IBS_Lib.Finds
local Maths = mod.IBS_Lib.Maths
local Spawns = mod.IBS_Lib.Spawns
local Ents = mod.IBS_Lib.Ents

local sfx = SFXManager()

local SwordVariant = Isaac.GetEntityVariantByName("IBS_Sword")

--缝纫机mod
if Sewn_API then	
	Sewn_API:MakeFamiliarAvailable(SwordVariant, IBS_Item.sword)
	Sewn_API:AddFamiliarDescription(
		 SwordVariant,
		 "额外造成4点伤害和流血效果",
		 "+25%伤害#优先攻击敌弹", nil, "紫电","zh_cn"
	 )
	Sewn_API:AddFamiliarDescription(
		 SwordVariant,
		 "4 extra dmg with bleeding effect",
		 "+ 20% DMG#Targets projectiles first", nil, "Wisper","en_us"
	 )
end

local SWORD_FLOAT_ANIM = {
	[Direction.NO_DIRECTION] = "Right", 
	[Direction.LEFT] = "Left",
	[Direction.UP] = "Left",
	[Direction.RIGHT] = "Right",
	[Direction.DOWN] = "Right"
}

--拖尾
local function Trail(familiar)
	local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, familiar.Position, Vector(0,0), familiar):ToEffect()
	trail:FollowParent(familiar)
	trail:GetSprite().Color = Color(0.4, 0.15, 0.38, 0.3, 0.27843, 0, 0.4549) --颜色
	trail.MinRadius = 0.07 --淡化速率
	trail.SpriteScale = Vector(2,2) --尺寸
	trail:Update()	
end

--初始化
local function OnInit(_,familiar)
	familiar.IsFollower = true
	Trail(familiar)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, OnInit, SwordVariant)

--碰撞判定
local function OnCollision(_,familiar, other)
	local game = Game()
	local stage = game:GetLevel():GetStage()
	local player = familiar.Player
	local spr = familiar:GetSprite()
	local dmg = stage * 1.5
	local extra = 1

	if player:HasTrinket(141) then --摇篮曲饰品
		dmg = dmg * 1.2
	end
	
	if (player:HasCollectible(247)) then --大宝
		dmg = dmg * 2
	end
	
	--缝纫机mod
	if Sewn_API then 
		if Sewn_API:IsUltra(familiar:GetData()) then
			dmg = dmg * 1.25
		end		
	end
	
	if dmg < 6 then dmg = 6 end
	
	--抵挡敌弹
	if other.Type == EntityType.ENTITY_PROJECTILE then
		local proj = other:ToProjectile()
		if not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			proj:Die()
		end
	elseif Ents:IsEnemy(other) then --造成伤害
		if spr:IsEventTriggered("DMG") or spr:IsEventTriggered("DMG2") then
			other:TakeDamage(dmg, 0, EntityRef(familiar), 0)
			sfx:Play(540, 0.2, 0, false, 0.8)
			
			if Sewn_API then--缝纫机mod
				if Sewn_API:IsSuper(familiar:GetData()) then
					other:TakeDamage(4, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(familiar), 0)
					Ents:AddBleed(other, 90)
				end
			end
		end
	elseif other:ToPlayer() and mod:THI_WillSeijaNerf(other:ToPlayer()) then --正邪削弱(东方mod)
		if spr:IsEventTriggered("DMG") or spr:IsEventTriggered("DMG2") then
			other:TakeDamage(1, 0, EntityRef(other), 0)
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, OnCollision, SwordVariant)

--更新
local function OnUpdate(_,familiar)
	local player = familiar.Player
	local spr = familiar:GetSprite()
	local move_dir = player:GetMovementDirection()
	local target = nil

	--缝纫机mod
	if Sewn_API then
		if Sewn_API:IsUltra(familiar:GetData()) then
			target = Finds:ClosestEntity(player.Position, 9)
			
			if (target == nil) or target:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) or (target.Position:Distance(player.Position) > 200) then
				target = Finds:ClosestEnemy(player.Position)
			end
		else
			target = Finds:ClosestEnemy(player.Position)
		end
	else
		target = Finds:ClosestEnemy(player.Position)
	end
	
	--有目标时
    if (target ~= nil) and (target.Position:Distance(player.Position) <= 300) then
		familiar:FollowPosition(target.Position)
		familiar.Velocity = familiar.Velocity * 3
		
		--攻击动画
		local vec = (target.Position - familiar.Position):Normalized()
		local dir = Maths:VectorToDirection(vec)
		spr:Play("Attack", false)
		familiar.FlipX = (dir == Direction.RIGHT or dir == Direction.DOWN)
	else --无目标时
		familiar:FollowPosition(player.Position)
		
		--正邪削弱
		if mod:THI_WillSeijaNerf(player) then
			local vec = (player.Position - familiar.Position):Normalized()
			local dir = Maths:VectorToDirection(vec)
			spr:Play("Attack", false)
			familiar.FlipX = (dir == Direction.RIGHT or dir == Direction.DOWN)			
			familiar.Velocity = familiar.Velocity * 0.6
		else	
			spr:Play(SWORD_FLOAT_ANIM[move_dir], false)
			familiar.FlipX = false
			familiar.Velocity = familiar.Velocity * 6
		end
	end

	--音效与图层修正
	if spr:IsPlaying("Attack") then
		familiar.DepthOffset = 70
		if spr:IsEventTriggered("DMG") then
			sfx:Play(IBS_Sound.sword1)
		end
		if spr:IsEventTriggered("DMG2") then
			sfx:Play(IBS_Sound.sword2)
		end
	else
		familiar.DepthOffset = 0
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, OnUpdate, SwordVariant)

local function OnSpawn(_,player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
		local num = player:GetCollectibleNum(IBS_Item.sword)
		local numFamiliars = (num > 0 and 1) or 0
		
		player:CheckFamiliar(SwordVariant, numFamiliars, player:GetCollectibleRNG(IBS_Item.sword), Isaac.GetItemConfig():GetCollectible(IBS_Item.sword))
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OnSpawn)

--新房间拖尾生成,以及位置修正
local function NewRoomTrail()
	for _,familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, SwordVariant)) do
		local player = familiar:ToFamiliar().Player

		--防止直接出现在玩家面前
		if mod:THI_WillSeijaNerf(player) then
			familiar.Position = Game():GetRoom():ScreenWrapPosition(player.Position, 25)
		end
		
		Trail(familiar)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoomTrail)

--拖尾更新
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_,effect)
	if effect.SpawnerEntity and effect.SpawnerEntity:ToFamiliar() then
		local familiar = effect.SpawnerEntity:ToFamiliar()
		if familiar.Variant == SwordVariant then
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
end, EffectVariant.SPRITE_TRAIL)
