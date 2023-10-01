--尘埃炸弹

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Ents = mod.IBS_Lib.Ents
local Finds = mod.IBS_Lib.Finds

--不替换贴图的炸弹效果
local ExcludedFlags = {
	TearFlags.TEAR_BLOOD_BOMB,
    TearFlags.TEAR_BRIMSTONE_BOMB
}

--临时炸弹数据
local function GetDustyBombData(bomb)
	local data = Ents:GetTempData(bomb)
	data.DustyBomb = data.DustyBomb or {TimeOutSet = false}
end

--添加爆炸次数
local function DustyExplosion(player, bomb)
	local data = mod:GetIBSData("Room")
	if not data.DustyExplosion then data.DustyExplosion = 0 end
	data.DustyExplosion = data.DustyExplosion + 1
	
	--第三次爆炸消灭所有非Boss敌人,Boss失去15%血量
	if data.DustyExplosion < 3 then
		
		--尘埃特效
		if bomb then
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, bomb.Position, Vector.Zero, bomb):ToEffect()			
			poof.Color = Color(1,1,1,0.5,1,1,1)
			
			SFXManager():Play(SoundEffect.SOUND_BLACK_POOF, 2, 2, false, 0.9)
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

		Game():ShakeScreen(30)
		SFXManager():Play(SoundEffect.SOUND_BLACK_POOF, 4, 2, false, 0.6)
		SFXManager():Play(SoundEffect.SOUND_DEATH_CARD, 2, 2, false)
	end
end

--替换炸弹贴图
local function ApplyBombCostume(bomb)
    for i,flag in pairs(ExcludedFlags) do
        if bomb:HasTearFlags(flag) then
            return
        end
    end

    local spr = bomb:GetSprite()
    local filename = spr:GetFilename()
	
	--检查尺寸(硬核)
    local size = 2
    for i = 0, 3 do
        if (string.reverse(filename)[1] == i) then
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
local function OnBombUpdate(_,bomb)
	local data = Ents:GetTempData(bomb).DustyBomb
	local player = Ents:IsSpawnerPlayer(bomb, true)
	
	if player and player:HasCollectible(IBS_Item.dustybomb) then

		--设置尘埃炸弹
		if (bomb.FrameCount < 2) and (bomb.Variant ~= BombVariant.BOMB_THROWABLE) then
			data = GetDustyBombData(bomb)
			ApplyBombCostume(bomb)
		end

		if data and bomb:IsDead() then
			DustyExplosion(player, bomb)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, OnBombUpdate)

--一触即发
local function OnBombCollision(_,bomb, other)
	local data = Ents:GetTempData(bomb).DustyBomb
	
	if data and Ents:IsEnemy(other) then
		if not data.TimeOutSet then
			data.TimeOutSet = true
			bomb:SetExplosionCountdown(1)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, OnBombCollision)

--史诗胎儿兼容
local function AlsoEpicFetus(_,effect)
	if effect.Timeout == 1 then
		local player = Ents:IsSpawnerPlayer(effect, true)
		
		if player and player:HasCollectible(IBS_Item.dustybomb) then
			DustyExplosion(player, effect)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, AlsoEpicFetus, EffectVariant.ROCKET)

