--018

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_FamiliarID = mod.IBS_FamiliarID
local IBS_Compat = mod.IBS_Compat

local game = Game()
local sfx = SFXManager()

local SCP018 = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.SCP018.Variant,
	SubType = IBS_FamiliarID.SCP018.SubType,
	Name = {zh = '018', en = '018'}
}

--获取数据
function SCP018:GetData(familiar)
	local data = self._Ents:GetTempData(familiar)
	data.SCP018 = data.SCP018 or {Scale = 1}
	return data.SCP018
end

--更新体型
function SCP018:UpdateSize(familiar)
	familiar = familiar:ToFamiliar()
	if not familiar then return end
	local data = self:GetData(familiar)
	local spr = familiar:GetSprite()
	local scale = math.min(36, data.Scale)
	local anim = 1
	
	--大宝增加体型
	if familiar.Player:HasCollectible(247) then
		scale = scale + 1
	end	
	
	for i = 13,1,-1 do
		if scale >= i then
			anim = i
			break
		end
	end
	
	familiar:SetSize(6 * scale, Vector(1,1), 6 * scale)
	spr.Scale = Vector(0.75 + 0.25*scale, 0.75 + 0.25*scale)
	spr:Play(tostring(anim))
end

--设置体型
function SCP018:SetScale(familiar, scale)
	local data = self:GetData(familiar)
	data.Scale = scale or data.Scale
	self:UpdateSize(familiar)
end

--重置体型
function SCP018:ResetScale(familiar)
	local data = self:GetData(familiar)
	data.Scale = 1	
	self:UpdateSize(familiar)
end

--增加体型
function SCP018:AddScale(familiar, scale)
	local data = self:GetData(familiar)
	data.Scale = data.Scale + scale
	self:UpdateSize(familiar)
end

--切换房间时重置速度和体型
function SCP018:OnNewRoom()
	for _,ent in ipairs(Isaac.FindByType(3, self.Variant, self.SubType)) do
		self:ResetScale(ent)
		ent.Velocity = RandomVector()
	end
end
SCP018:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--初始化
function SCP018:OnFamiliarInit(familiar)
	familiar.Velocity = RandomVector()
	familiar.GridCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	self:ResetScale(familiar)
end
SCP018:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', SCP018.Variant)

--更新
function SCP018:OnFamiliarUpdate(familiar)
    local player = familiar.Player
	if not player then return end
	self:UpdateSize(familiar)
end
SCP018:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', SCP018.Variant)

--碰撞判定
function SCP018:OnFamiliarCollision(familiar, other)
	local player = familiar.Player
	if not player then return end

	--抵挡子弹
	local proj = other:ToProjectile()
	if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
		proj:Die()
	end	
	
	--对敌人造成伤害
	if self._Ents:IsEnemy(other) and familiar.Velocity:Length() > 1 then
		local data = self:GetData(familiar)
		local mult = 1 + 0.18 * data.Scale
		
		--大宝
		if player:HasCollectible(247) then
			mult = mult + 0.18
		end
		
		local dmg = familiar.Velocity:Length() / 30 * mult
		other:TakeDamage(dmg, 0, EntityRef(familiar), 0)
		other.Velocity = other.Velocity + (familiar.Position - other.Position):Resized(10)
		familiar.Velocity = familiar.Velocity:Rotated(math.random(30,60))
		sfx:Play(math.random(620,622))
	
		--美德书
		if player:HasCollectible(584) then
			player:AddWisp(IBS_ItemID.SCP018, familiar.Position)
		end
	
		--彼列书
		if player:HasCollectible(59) then
			local fire = Isaac.Spawn(1000, EffectVariant.BLUE_FLAME, 0, familiar.Position, Vector.Zero, player):ToEffect()
			fire.Parent = player
			fire.Color = Color(1,1,1,0.5,2,0,0)
			fire.CollisionDamage = math.max(7, player.Damage)
			fire.Timeout = 150
		end
		
		--充能
		for slot = 0,2 do
			if player:GetActiveItem(slot) == (IBS_ItemID.SCP018) then
				local charges = self._Players:GetSlotCharges(player, slot, true, true)
				local maxCharges = 540
			
				if charges < maxCharges then
					self._Players:ChargeSlot(player, slot, 18, true)
					
					if charges + 18 >= maxCharges then
						sfx:Play(SoundEffect.SOUND_BEEP)
						game:GetHUD():FlashChargeBar(player, slot)
					end
				end
			end
		end		
	end
end
SCP018:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, 'OnFamiliarCollision', SCP018.Variant)

--撞到墙体变速
function SCP018:OnFamiliarGridCollision(familiar, gridIdx, gridEnt)
	familiar.Velocity = familiar.Velocity * -2
	familiar.Velocity = familiar.Velocity:Rotated(math.random(1,90))
	
	--限速
	if familiar.Velocity:Length() > 240 then
		familiar.Velocity = familiar.Velocity:Resized(240)
	end
end
SCP018:AddCallback(ModCallbacks.MC_FAMILIAR_GRID_COLLISION, 'OnFamiliarGridCollision', SCP018.Variant)

return SCP018