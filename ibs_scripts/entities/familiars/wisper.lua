--魂火之灵

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID
local IBS_Compat = mod.IBS_Compat

local game = Game()
local sfx = SFXManager()

local Wisper = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.Wisper.Variant,
	SubType = IBS_FamiliarID.Wisper.SubType,
	Name = {zh = '魂火之灵', en = 'Wisper'}
}

Wisper.ItemID = mod.IBS_ItemID.Wisper

--缝纫机mod兼容
IBS_Compat.Sewn:AddFamiliar(Wisper, Wisper.ItemID, {
	"+ 10% 伤害#击杀敌人额外生成一个魂火",
	"+ 20% 伤害#所有魂火额外获得该跟班的碰撞伤害",

	"+ 10% DMG#Spawns a extra wisp when killing an enemy",
	"+ 20% DMG#All wisps gain extra DMG that equals to this familiar's collision DMG"
})

--临时敌人数据
function Wisper:GetNpcData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Wisper = data.Wisper or {SewnDamage = 0, Familiar = nil}

	return data.Wisper
end

--初始化
function Wisper:OnFamiliarInit(familiar) 
    familiar:GetSprite():Play('Idle')
    familiar:AddToOrbit(777)
	familiar.OrbitDistance = Vector(80,80)
	familiar.OrbitSpeed = 0.02
	self._Ents:ApplyLight(familiar, 1.2, Color(0,1,1,1.8))
end
Wisper:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', Wisper.Variant)

--更新
function Wisper:OnFamiliarUpdate(familiar)
	familiar.OrbitDistance = Vector(80,80)
    familiar.OrbitSpeed = 0.02
	familiar.SpriteScale = Vector(1.2,1.2)

    local player = familiar.Player
	if not player then return end
    familiar.Velocity = (familiar:GetOrbitPosition(player.Position) - familiar.Position)
end
Wisper:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', Wisper.Variant)

--碰撞判定
function Wisper:OnFamiliarCollision(familiar, other)
	local player = familiar.Player
	if not player then return end
	
	--对敌人造成伤害
	if familiar:IsFrame(7,0) and self._Ents:IsEnemy(other) then
		local data = self:GetNpcData(other)
		local dmg = 3*(player.Damage)

		if player:HasCollectible(247) then --大宝
			dmg = dmg * 2
		end

		if dmg < 14 then dmg = 14 end	

		do --缝纫机mod兼容
			local super = IBS_Compat.Sewn:IsSuper(familiar)
			local ultra = IBS_Compat.Sewn:IsUltra(familiar)
			if super then
				dmg = dmg * 1.1
			end
			if ultra then
				dmg = dmg * 1.2
			end
			if super or ultra then
				data.SewnDamage = dmg
			else
				data.SewnDamage = 0
			end
		end

		other:TakeDamage(dmg, 0, EntityRef(familiar),0)
		data.Familiar = familiar
		sfx:Play(43)
	end

	--抵挡子弹
	local proj = other:ToProjectile()
	if proj and not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
		proj:Die()
	end
end
Wisper:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, 'OnFamiliarCollision', Wisper.Variant)

--缝纫机蓝冠效果
function Wisper:OnWispCollision(familiar, other)
	if not self._Ents:IsEnemy(other) or not familiar:IsFrame(7, 0) then return end
	local data = self._Ents:GetTempData(other).Wisper
	if data and data.SewnDamage > 0 then
		other:TakeDamage(data.SewnDamage, 0, EntityRef(familiar), 0)
	end
end
Wisper:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, 'OnWispCollision', FamiliarVariant.WISP)

--杀敌生成魂火
function Wisper:OnEntityKilled(ent)
	local data = self._Ents:GetTempData(ent).Wisper
	
	if data and data.Familiar and data.Familiar.Player then
		local familiar = data.Familiar
		local player = familiar.Player	
		local luck = math.min(70, 10*(player.Luck))

		if player:GetCollectibleRNG(self.ItemID):RandomInt(100) > (70 - luck) then
			player:AddWisp(0, ent.Position, true)
			sfx:Play(483, 0.7)
		end	
	
		--缝纫机mod兼容
		if IBS_Compat.Sewn:IsSuper(familiar) then 
			player:AddWisp(0, ent.Position, true)
			sfx:Play(483, 0.7)
		end	
	end
end
Wisper:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')


return Wisper