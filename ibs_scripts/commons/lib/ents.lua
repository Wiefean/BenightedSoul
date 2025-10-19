--常规实体相关函数

local mod = Isaac_BenightedSoul
local ModName = mod.Name

local game = Game()

local Ents = {}


--临时实体数据
--[[
对于玩家,跟班和具有实体标签"EntityFlag.FLAG_PERSISTENT"的实体,
其临时数据在关闭游戏后清除;
除他们之外的所有实体,其临时数据在离开房间后清除

"noRewind"为true时,获取的是不与发光沙漏兼容的另一独立的临时实体数据
发光沙漏兼容在 /ibs_scripts/ibs_commons.lua
]]
function Ents:GetTempData(ent, noRewind)
	if ent.GetData then
		local data = ent:GetData()
		if noRewind then
			data[ModName.." NoRewind"] = data[ModName.." NoRewind"] or {}
			return data[ModName.." NoRewind"]
		else
			data[ModName] = data[ModName] or {}
			return data[ModName]
		end
	end
	return {}
end

--是否为敌人
--[[输入: 实体, 是否包括不能受伤的敌人, 是否包括友好的敌人, 是否忽略Boss]]
function Ents:IsEnemy(ent, includeInvulnerable, includeFriendly, ignoreBoss)
	--白火
	if ent and ent.Type == 33 and ent.Variant == 4 then
		return false
	end

	if ent and ent:IsEnemy() then
		if (not ent:IsVulnerableEnemy()) and (not includeInvulnerable) then
			return false
		end

		if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not includeFriendly then
			return false
		end
		
		if ent:IsBoss() and ignoreBoss then
			return false
		end
		
		return true
	end

	return false
end

--获取来源敌人
--[[
返回空值或敌人
输入的实体已经是敌人时,返回输入的实体
一般用于判断敌弹来源敌人
配合上面的"是否为敌人"函数可以进一步判断
]]
function Ents:GetSourceEnemy(ent)
	if not ent then return nil end
	local enemy = ent

	while (not enemy:IsEnemy()) and enemy.SpawnerEntity do
		enemy = enemy.SpawnerEntity
	end
	
	if enemy:IsEnemy() then
		return enemy
	end
	
	return nil
end

--获取来源玩家
--[[
返回空值或玩家
跟上一个函数类似
]]
function Ents:GetSourcePlayer(ent)
	if not ent then return nil end
	local player = ent

	while (not player:ToPlayer()) and player.SpawnerEntity do
		player = player.SpawnerEntity
	end
	
	if player:ToPlayer() then
		return player:ToPlayer()
	end
	
	return nil
end


--是否为相同实体
function Ents:IsTheSame(entA, entB)
    if (entA and entB) then
        return GetPtrHash(entA) == GetPtrHash(entB)
    end
	
    return false
end


--两实体是否碰撞(赞美忏悔龙)
function Ents:AreColliding(entA, entB)
	if not (entA and entB) then return false end
	if entA:GetCollisionCapsule():Collide(entB:GetCollisionCapsule(), entB.Position) then
		return true
	end
	return false
end

--[[
两实体是否碰撞(旧版,并不完善,但无需忏悔龙)
function Ents:AreColliding(entA, entB, ignoreSizeMultA, ignoreSizeMultB)
	if not (entA and entB) then return false end

	local posA = entA.Position
	local posB = entB.Position
	local multA = (ignoreSizeMultA and Vector(1,1)) or entA.SizeMulti
	local multB = (ignoreSizeMultB and Vector(1,1)) or entB.SizeMulti
	
	if (multA.X ~= 1 or multA.Y ~= 1) or (multB.X ~= 1 or multB.Y ~= 1) then
		if (math.abs(posA.X - posB.X) <= math.abs((multA.X * entA.Size) + (multB.X * entB.Size))) and (math.abs(posA.Y - posB.Y) <= math.abs((multA.Y * entA.Size) + (multB.Y * entB.Size))) then
			return true
		end
	else
		if (posA:DistanceSquared(posB) <= (entA.Size + entB.Size) ^ 2) then
			return true
		end
	end
	
	return false
end
]]

--生成者是否为玩家(返回空值或玩家)
--[[输入: 实体, 是否包括莉莉宝/作孽双子]]
function Ents:IsSpawnerPlayer(ent, includeIncubus)
    local player = nil
	
    if ent.SpawnerEntity then
        player = ent.SpawnerEntity:ToPlayer()
    end
	
	if (not player and includeIncubus) then
		local spawner = ent.SpawnerEntity
		if spawner and (spawner.Type == EntityType.ENTITY_FAMILIAR) then
			if (spawner.Variant == FamiliarVariant.INCUBUS) or (spawner.Variant == FamiliarVariant.TWISTED_BABY) then
				player = spawner:ToFamiliar().Player
			end
		end
	end
	
    return player
end

--复制动画(实为生成空实体效果)
function Ents:CopyAnimation(ent, pos, duration, anim)
	local EmptyVariant = (mod.IBS_Effect and mod.IBS_Effect.Empty.Variant) or Isaac.GetEntityVariantByName('IBS_Empty')
	local effect = Isaac.Spawn(1000, EmptyVariant, 0, pos or ent.Position, Vector.Zero, ent):ToEffect()
	local spr = effect:GetSprite()
	spr:Load(ent:GetSprite():GetFilename(), true)
	spr.Scale = ent.SpriteScale
	effect.Color = ent.Color
	effect.Size = ent.Size
	effect.SizeMulti = ent.SizeMulti
	effect.Timeout = duration or -1

	if anim then spr:Play(anim) end

	return effect
end

--为实体应用拖尾
function Ents:ApplyTrail(ent, color, scale, fadeRate, timeout)
	local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, ent.Position, Vector.Zero, ent):ToEffect()
	trail:FollowParent(ent)
	trail:GetSprite().Color = color
	trail.SpriteScale = scale or Vector(1,1)
	trail.MinRadius = fadeRate or 0.06 --淡化速率
	trail.Timeout = timeout or -1
	trail:Update()
	
	return trail
end


--为实体应用光效
function Ents:ApplyLight(ent, scale, color, updateFunc)
	posOffset = posOffset or Vector.Zero
	updateFunc = updateFunc or function() end

	local effect = EntityEffect.CreateLight(ent.Position, scale, -1, 6, color)
	effect:FollowParent(ent)
	Ents:GetTempData(effect).LIGHTEFFECTUPDATEFUNCTION = updateFunc

	if not Ents:GetTempData(ent).LIGHTEFFECT then
		Ents:GetTempData(ent).LIGHTEFFECT = {
			Current = effect,
			UpdateFunction = function()
				if ent:Exists() and not ent:IsDead() then
					local data = Ents:GetTempData(ent).LIGHTEFFECT
					if data and data.Current then
						if data.Current:IsDead() or not data.Current:Exists() then
							local new = EntityEffect.CreateLight(ent.Position, scale, -1, 6, color)
							new:FollowParent(ent)
							data.Current = new
							Ents:GetTempData(new).LIGHTEFFECTUPDATEFUNCTION = updateFunc
						end
					end
				end
			end
		}
	end
	
	return effect
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		local data = Ents:GetTempData(ent).LIGHTEFFECT
		if data and data.UpdateFunction then
			data.UpdateFunction()
		end
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_,effect)
	local func = Ents:GetTempData(effect).LIGHTEFFECTUPDATEFUNCTION
	if func then
		func(effect)
	end
end)


--长久实体数据(利用了种子,缺陷是种子可能变更)
function Ents:GetDataBySeed(entSeed)
	local data = mod:GetIBSData('temp')
	local key = tostring(entSeed)

	if not data.IBS_LIB_ENTS_SEEDS_DATA then
		data.IBS_LIB_ENTS_SEEDS_DATA = {}
	end
	
	if not data.IBS_LIB_ENTS_SEEDS_DATA[key] then
		data.IBS_LIB_ENTS_SEEDS_DATA[key] = {}
	end
	
	return data.IBS_LIB_ENTS_SEEDS_DATA[key]
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() --新层清空数据
	local data = mod:GetIBSData('temp').IBS_LIB_ENTS_SEEDS_DATA
	if data then
		for k,_ in pairs(data) do
			data[k] = nil
		end
		mod:GetIBSData('temp').IBS_LIB_ENTS_SEEDS_DATA = nil
	end
end)


do

--缓存
local cache = {}
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for k,_ in pairs(cache) do
		cache[k] = nil
	end
end)

--用于让天使在其他房间也掉落钥匙碎片
function Ents:SetKeyPieceAngel(ent)
	cache[ent.InitSeed] = true
end

--生成会掉落钥匙碎片的天使(乌列/加百列)
function Ents:SpawnKeyPieceAngel(pos, seed, forceBlue, forceRed)
	local Type = 271

	if forceBlue or forceRed then
		Type = (forceBlue and 271) or (forceRed or 272) or Type
	else
		local k1 = PlayerManager.AnyoneHasCollectible(238)
		local k2 = PlayerManager.AnyoneHasCollectible(239)
		
		--根据钥匙碎片持有情况更改生成的天使
		if (k1 and k2) or (not k1 and not k2) then
			--都有或都没有时,随机挑一个
			Type = (RNG(seed):RandomInt(100) < 50 and 271) or 272
		else
			if k1 then
				Type = 272
			end
			if k2 then
				Type = 271
			end
		end
	end
	
	local ent = Isaac.Spawn(Type, 0, 0, pos, Vector.Zero, nil)
	self:SetKeyPieceAngel(ent)
	
	return ent
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_,npc)
	if not cache[npc.InitSeed] then return end
	local blue = (npc.Type == 271)
	local red = (npc.Type == 272)
	if not (blue or red) then return end
	local room = game:GetRoom()

	--排除天使本来就会掉钥匙的房间
	--(超隐,献祭,天使)
	local roomType = room:GetType()
	if roomType == 8 or roomType == 13 or roomType == 15 then
		return
	end
	
	--乌列默认掉碎片1,加百列默认掉碎片2
	local piece = (blue and 238) or 239
	
	--有羽毛时,改为掉落天使房道具
	if PlayerManager.AnyoneHasTrinket(123) then
		piece = game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, true, npc.InitSeed)
	else	
		local k1 = PlayerManager.AnyoneHasCollectible(238)
		local k2 = PlayerManager.AnyoneHasCollectible(239)

		--根据钥匙碎片持有情况更改生成的碎片
		if (k1 and k2) or (not k1 and not k2) then
			
		else
			if k1 then
				piece = 239
			end
			if k2 then
				piece = 238
			end
		end	
	end

	Isaac.Spawn(5, 100, piece, npc.Position, Vector.Zero, npc)
	cache[npc.InitSeed] = nil
end)

end

return Ents