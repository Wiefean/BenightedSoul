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
mod:AddCallback(ModCallbacks.MC_USE_CARD,function()
	local entities = Isaac.GetRoomEntities()
	for i = 1, #entities do
		if entities[i]:IsEnemy() and entities[i]:IsVulnerableEnemy() and entities[i]:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
			Ents:AddWeakness(entities[i], 1800)
		end
	end
end, Card.CARD_REVERSE_STRENGTH) --倒力量兼容

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