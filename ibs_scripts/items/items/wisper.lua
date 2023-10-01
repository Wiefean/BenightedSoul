--魂火之灵

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Ents = mod.IBS_Lib.Ents

local sfx = SFXManager()

local WisperVariant = Isaac.GetEntityVariantByName("IBS_Wisper")

--缝纫机mod介绍
if Sewn_API then	
	Sewn_API:MakeFamiliarAvailable(WisperVariant, IBS_Item.wisper)
	Sewn_API:AddFamiliarDescription(
		 WisperVariant,
		 "+ 10% 伤害#击杀敌人额外生成一个魂火",
		 "+ 20% 伤害#所有魂火额外获得该跟班的碰撞伤害", nil, "魂火之灵","zh_cn"
	 )
	Sewn_API:AddFamiliarDescription(
		 WisperVariant,
		 "+ 10% DMG#Spawns a extra wisp when killing an enemy",
		 "+ 20% DMG#All wisps gain extra DMG that equals to this familiar's collision DMG", nil, "Wisper","en_us"
	 )
end

--临时敌人数据
local function GetNpcData(npc)
	local data = Ents:GetTempData(npc)
	data.Wisper = data.Wisper or {Familiar = nil, Player = nil}

	return data.Wisper
end

--初始化
local function Wisper_Init(_,familiar) 
    familiar:GetSprite():Play("Idle")
    familiar:AddToOrbit(777)
	familiar.OrbitDistance = Vector(80,80)
	familiar.OrbitSpeed = 0.02
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Wisper_Init, WisperVariant)

--更新
local function Wisper_Update(_,familiar)
    local player = familiar.Player
	familiar.OrbitDistance = Vector(80,80)
    familiar.OrbitSpeed = 0.02
    familiar.Velocity = (familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Wisper_Update, WisperVariant)

--碰撞判定
local function Wisper_Collision(_,familiar, other)
	local player = familiar.Player
	if not player then return end
	
	--对敌人造成伤害
	if other:IsEnemy() and other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		if (familiar.FrameCount % 7 == 0) then
			local data = GetNpcData(other)
			data.Familiar = familiar
			data.Player = player
			
			local dmg = 3*(player.Damage)

			if player:HasCollectible(247) then --大宝
				dmg = dmg * 2
			end
			
			--缝纫机mod
			if Sewn_API then 
				if Sewn_API:IsSuper(familiar:GetData()) then
					dmg = dmg * 1.1
				end
				
				if Sewn_API:IsUltra(familiar:GetData()) then
					dmg = dmg * 1.2
				end		
			end
			
			if dmg < 10 then dmg = 10 end		

			other:TakeDamage(dmg, 0, EntityRef(familiar),0)
			SFXManager():Play(43)			
		end
	end

	--抵挡子弹
    if (other.Type == EntityType.ENTITY_PROJECTILE) then
        local proj = other:ToProjectile()
        if not proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
            proj:Die()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, Wisper_Collision, WisperVariant)

--缝纫机蓝冠效果
local function Wisper_Collision(_,familiar, other)
	if Sewn_API then
		if other:IsEnemy() and other:IsVulnerableEnemy() and not other:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			if familiar:IsFrame(7, 0) then
				local dmg = 0
				local wispers = Isaac.FindByType(3, WisperVariant)
				if #wispers > 0 then
					for _,wisper in pairs(wispers) do
						if Sewn_API:IsUltra(wisper:GetData()) then
							dmg = dmg + 1.32*(familiar.Player.Damage)
						end	
					end
				end			

				if familiar.Player:HasCollectible(247) then --大宝
					dmg = dmg * 2
				end
			
				if dmg < 10 then dmg = 10 end			

				if dmg > 0 then
					other:TakeDamage(dmg, 0, EntityRef(familiar),0)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, Wisper_Collision, FamiliarVariant.WISP)

--杀敌生成魂火
local function Wisper_Kill(_,npc)
	local data = Ents:GetTempData(npc).Wisper
	
	if data then
		local familiar = data.Familiar
		local player = data.Player	
		local rng = player:GetCollectibleRNG(IBS_Item.wisper)
		local chance = rng:RandomInt(99) + 1
		local luck = math.min(70, 10*(player.Luck))

		if chance > (70 - luck) then
			player:AddWisp(0, npc.Position, true)
			sfx:Play(483, 0.7)
		end	
	
		--缝纫机mod
		if Sewn_API then 
			if Sewn_API:IsSuper(familiar:GetData()) then
				player:AddWisp(0, npc.Position, true)
				sfx:Play(483, 0.7)
			end	
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Wisper_Kill)

--拾取对应道具生成跟班
local function Wisper_Spawn(_,player, flag)
    if flag == CacheFlag.CACHE_FAMILIARS then
		local boxUse = player:GetEffects():GetCollectibleEffectNum(357) --朋友盒
		local num = player:GetCollectibleNum(IBS_Item.wisper)
		local numFamiliars = (num > 0 and (num + boxUse) or 0)
		
		player:CheckFamiliar(WisperVariant, numFamiliars, player:GetCollectibleRNG(IBS_Item.wisper), Isaac.GetItemConfig():GetCollectible(IBS_Item.wisper))
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Wisper_Spawn)