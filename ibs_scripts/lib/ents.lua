--常规实体相关函数

local mod = Isaac_BenightedSoul
local ModName = mod.Name


local Ents = {}


--临时数据
function Ents:GetTempData(ent)
    local data = ent:GetData()
    data[ModName] = data[ModName] or {}
	
    return data[ModName]
end

--是否为敌人
--[[输入: 实体, 是否包括不能受伤的敌人, 是否包括友好的敌人, 是否忽略Boss]]
function Ents:IsEnemy(ent, includeInvulnerable, includeFriendly, ignoreBoss)
	return ent:IsEnemy() and (ent:IsVulnerableEnemy() or includeInvulnerable) and (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or includeFriendly) and (not ignoreBoss or not ent:IsBoss())
end

--是否为相同实体
function Ents:IsTheSame(entA, entB)
    if (entA and entB) then
        return GetPtrHash(entA) == GetPtrHash(entB)
    end
	
    return false
end

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


--获取自定的实体标志信息
local function GetEntFlags(ent)
	local data = Ents:GetTempData(ent)
	data.EntFlags = data.EntFlags or {}
	
	return data.EntFlags
end

--流血
function Ents:AddBleed(ent, frames)
	local entFlags = GetEntFlags(ent)
	entFlags.Bleed = entFlags.Bleed or {Flag = EntityFlag.FLAG_BLEED_OUT, TimeOut = 0}
	entFlags.Bleed.TimeOut = entFlags.Bleed.TimeOut + frames
end

--虚弱
function Ents:AddWeakness(ent, frames)
	local entFlags = GetEntFlags(ent)
	entFlags.Weakness = entFlags.Weakness or {Flag = EntityFlag.FLAG_WEAKNESS, TimeOut = 0}
	entFlags.Weakness.TimeOut = entFlags.Weakness.TimeOut + frames
end

--执行效果
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, function(_,npc)
	local entFlags = GetEntFlags(npc)
    for k, v in pairs(entFlags) do
        if (v.TimeOut > 0) then
			if not npc:HasEntityFlags(v.Flag) then
				npc:AddEntityFlags(v.Flag)
			end
            v.TimeOut = v.TimeOut - 1
        else
			npc:ClearEntityFlags(v.Flag)
            entFlags[k] = nil
        end 
    end	
end)

return Ents