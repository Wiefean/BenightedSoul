--尘埃炸弹

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local game = Game()
local sfx = SFXManager()

local DustyBomb = mod.IBS_Class.Item(mod.IBS_ItemID.DustyBomb)


--不替换贴图的炸弹效果
DustyBomb.ExcludedFlags = {
	TearFlags.TEAR_BLOOD_BOMB,
    TearFlags.TEAR_BRIMSTONE_BOMB
}

--临时炸弹数据
function DustyBomb:GetBombData(bomb)
	local data = Ents:GetTempData(bomb)
	data.DustyBomb = data.DustyBomb or {TimeoutSet = false}
end

--添加爆炸次数
function DustyBomb:DustyExplosion(player, bomb)
	local data = self:GetIBSData('room')
	if not data.DustyExplosion then data.DustyExplosion = 0 end
	data.DustyExplosion = data.DustyExplosion + 1
	
	--第三次爆炸消灭所有非Boss敌人,Boss失去15%血量
	if data.DustyExplosion < 3 then
		
		--尘埃特效
		if bomb then
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, bomb.Position, Vector.Zero, bomb):ToEffect()			
			poof.Color = Color(1,1,1,0.5,1,1,1)
			
			sfx:Play(SoundEffect.SOUND_BLACK_POOF, 2, 2, false, 0.9)
		end		
	elseif data.DustyExplosion == 3 then
		for _,ent in pairs(Isaac.GetRoomEntities()) do
			if ent:IsEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				if ent:IsBoss() then
					ent:TakeDamage(0.15*(ent.MaxHitPoints), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
				else
					ent:Remove()
				end

				--尘埃特效
				for subType = 1,2 do				
					local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, subType, ent.Position, Vector.Zero, player):ToEffect()			
					local size = ent.Size / 20
					poof.SpriteScale = Vector(size,size)
					poof.Color = Color(1,1,1,0.5,1,1,1)
				end
			end
		end
		
		--尘埃特效
		if bomb then
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, bomb.Position, Vector.Zero, bomb):ToEffect()			
			poof.SpriteScale = Vector(1.5,1.5)
			poof.Color = Color(1,1,1,0.5,1,1,1)
		end

		game:ShakeScreen(15)
		sfx:Play(SoundEffect.SOUND_BLACK_POOF, 4, 2, false, 0.6)
		sfx:Play(SoundEffect.SOUND_DEATH_CARD, 2, 2, false)
	end
end

--替换炸弹贴图
function DustyBomb:ApplyBombCostume(bomb)
    for i,flag in pairs(self.ExcludedFlags) do
        if bomb:HasTearFlags(flag) then
            return
        end
    end

    local spr = bomb:GetSprite()
    local name = tonumber(string.sub(string.reverse(spr:GetFilename()), 6, 6))

	--检查尺寸(硬核)
    local size = 2
    for i = 0, 3 do
        if (name == i) then
            size = i
            break
        end
    end

	--金炸弹
    local suffix = ""
    if bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
        suffix = "_golden"
    end
	
    spr:Load("gfx/ibs/items/pick ups/bombs/dusty"..suffix..size..".anm2", true)
    spr:Play("Pulse", true)
end

--尘埃炸弹行为
function DustyBomb:OnBombUpdate(bomb)
	local data = Ents:GetTempData(bomb).DustyBomb
	local player = Ents:IsSpawnerPlayer(bomb, true)
	
	if player and player:HasCollectible(self.ID) then

		--设置尘埃炸弹
		if (bomb.FrameCount < 2) and (bomb.Variant ~= BombVariant.BOMB_THROWABLE) then
			data = self:GetBombData(bomb)
			self:ApplyBombCostume(bomb)
		end

		if data and bomb:IsDead() then
			self:DustyExplosion(player, bomb)
		end
	end
end
DustyBomb:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, 'OnBombUpdate')

--一触即发
function DustyBomb:OnBombCollision(bomb, other)
	local data = Ents:GetTempData(bomb).DustyBomb
	
	if data and Ents:IsEnemy(other) then
		if not data.TimeoutSet then
			data.TimeoutSet = true
			bomb:SetExplosionCountdown(1)
		end
	end	
end
DustyBomb:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, 'OnBombCollision')

--史诗胎儿兼容
function DustyBomb:AlsoEpicFetus(effect)
	if effect.Timeout == 1 then
		local player = Ents:IsSpawnerPlayer(effect, true)
		
		if player and player:HasCollectible(self.ID) then
			self:DustyExplosion(player, effect)
		end
	end
end
DustyBomb:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'AlsoEpicFetus', EffectVariant.ROCKET)


--免疫角色炸弹
function DustyBomb:PrePlayerTakeDMG(player, dmg, flag, source)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
		if source and source.Entity and source.Entity:ToBomb() and self._Ents:IsSpawnerPlayer(source.Entity, true) then
			return false
		end
	end
end
DustyBomb:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')


return DustyBomb