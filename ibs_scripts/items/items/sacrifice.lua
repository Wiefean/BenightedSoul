--该隐的祭品

local mod = Isaac_BenightedSoul
local IBS_API = mod.IBS_API
local IBS_Item = mod.IBS_Item
local Ents = mod.IBS_Lib.Ents
local Finds = mod.IBS_Lib.Finds

--用于昧化该隐&亚伯
mod.IBS_API.BCBA:AddExcludedActiveItem(IBS_Item.sacrifice)

local BigLightVariant = mod.IBS_Effect.BigLight.Variant

--临时数据
local function GetLightData(effect)
	local data = Ents:GetTempData(effect)
	data.BigLight_Effect = data.BigLight_Effect or {
		HurtPlayer = true,
		FollowEnemy = false,
		FollowPlayer = false,
		TimeOut = 135
	}
	
	return data.BigLight_Effect
end

--使用
local function OnUse(_,item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then --拒绝车载电池
		local GameData = mod:GetIBSData("Temp")

		local light = Isaac.Spawn(1000, BigLightVariant, 0, player.Position, Vector.Zero, player):ToEffect()
		local data = GetLightData(light)
		light.CollisionDamage = math.max(2.45, 0.7*(player.Damage))
		light.Scale = 2
		
		--彼列书
		if player:HasCollectible(59) then
			light.Scale = 3
			data.FollowPlayer = true
		end
		
		--美德书
		if player:HasCollectible(584) then
			data.HurtPlayer = false
			data.FollowEnemy = true
		end
		
		--车载电池
		if player:HasCollectible(356) then
			data.TimeOut = 210
		end

		--检测亚伯祭品是否使用过
		if GameData.welcomSacrificeUsed then
			data.HurtPlayer = false
			data.FollowEnemy = true
		end
		
		--记录该隐祭品已使用
		if not GameData.unwelcomSacrificeUsed then GameData.unwelcomSacrificeUsed = true end
		
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, IBS_Item.sacrifice)

--光柱逻辑
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
	local data = Ents:GetTempData(effect).BigLight_Effect

	if data then
		local game = Game()
		local room = game:GetRoom()
		local spr = effect:GetSprite()
		
		spr.Scale = Vector(effect.Scale, effect.Scale) --调整贴图大小
		
		--出现音效
		if spr:IsEventTriggered("sound") then
			SFXManager():Play(SoundEffect.SOUND_DOGMA_LIGHT_APPEAR, 1.5, 30, false, 0.7)
		end

		--切换状态至静止
		if spr:IsFinished("Appear") then 
			spr:Play("Idle", true)
			
			--爆炸
			game:BombExplosionEffects(effect.Position, 100, TearFlags.TEAR_NORMAL, Color(1,1,1,0.5,0.5,0.5,0.5), Ents:IsSpawnerPlayer(effect), effect.Scale / 1.5, true, data.HurtPlayer, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
		end

		if spr:IsPlaying("Idle") then
			SFXManager():Play(SoundEffect.SOUND_HAND_LASERS, 0.5, 9, false, 2, 9)
			
			--对敌人造成伤害
			for _,ent in pairs(Isaac.FindInRadius(effect.Position, effect.Scale * 20, EntityPartition.ENEMY)) do
				if Ents:IsEnemy(ent, true) then
					ent:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 1)
				end
			end
			
			--摧毁障碍物
			local width = room:GetGridWidth()
			local height = room:GetGridHeight()
			for x = 1, width - 1 do
				for y = 1, height - 1 do
					local gridIndex = x + y * width
					local gridEnt = room:GetGridEntity(gridIndex)
					
					if gridEnt and (gridEnt.Position:Distance(effect.Position) <= effect.Scale * 30) then
						room:DestroyGrid(gridIndex, true)
					end
				end
			end
			
			--对玩家造成伤害
			if data.HurtPlayer then
				for _,ent in pairs(Isaac.FindInRadius(effect.Position, effect.Scale * 15, EntityPartition.PLAYER)) do
					local player = ent:ToPlayer()
					player:TakeDamage(2, 0, EntityRef(effect), 120)
					player:SetMinDamageCooldown(120)
				end
			end			
			
			--追踪
			local target = nil
			if data.FollowEnemy then
				target = Finds:ClosestEnemy(effect.Position)
			elseif data.FollowPlayer then
				target = Finds:ClosestPlayer(effect.Position)	
			end
			if target ~= nil then 
				effect.Position = effect.Position + (target.Position - effect.Position):Resized(5.6)
			end
			
			
			if data.TimeOut > 0 then
				data.TimeOut = data.TimeOut - 1
			else
				spr:Play("Disappear", true)
			end
		end
		
		if spr:IsFinished("Disappear") then
			effect:Remove()
		end	
	else
		effect:Remove()
	end
end, BigLightVariant)


