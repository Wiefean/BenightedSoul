--网格实体相关回调
--(当然也包含伪网格实体)

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()

local Grid = mod.IBS_Class.Callbacks{
	POOP_BREAK = IBS_CallbackID.POOP_BREAK,
	FIREPLACE_BREAK = IBS_CallbackID.FIREPLACE_BREAK,
}

--破坏大便回调
do

do --网格实体大便
	local _cache = {} --缓存
	mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
		for k,_ in pairs(_cache) do
			_cache[k] = nil
		end
	end)
	function Grid:OnPoopRender(poop)
		local seed = poop:GetSaveState().SpawnSeed
		_cache[seed] = _cache[seed] or poop.State
		if  _cache[seed] ~= poop.State then
			if poop.State == 1000 then
				self:Run(self.IDs.POOP_BREAK, poop, nil, poop:GetVariant())
			end
			_cache[seed] = poop.State
		end
	end
	Grid:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_RENDER, 'OnPoopRender')
end


do --非网格实体大便(大肠杆菌说是)
	local _cache = {} --缓存
	mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
		for k,_ in pairs(_cache) do
			_cache[k] = nil
		end
	end)	
	function Grid:OnEntityPoopRender(poop)
		if (poop.Variant == 0 or poop.Variant == 1) then
			local seed = poop.InitSeed
			_cache[seed] = _cache[seed] or poop.HitPoints
			if  _cache[seed] ~= poop.HitPoints then
				if poop.HitPoints == 1 then
					--实体金大便的Variant是1
					self:Run(self.IDs.POOP_BREAK, nil, poop, (poop.Variant == 1 and 3) or 0)
				end
				_cache[seed] = poop.HitPoints
			end
		end
	end
	Grid:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, 'OnEntityPoopRender', EntityType.ENTITY_POOP)
end


end


--破坏火堆回调
do

local _cache = {} --缓存
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for k,_ in pairs(_cache) do
		_cache[k] = nil
	end
end)	
function Grid:OnFirePlaceRender(npc)
	if npc.Variant >= 0 and npc.Variant <= 4 then	
		local seed = npc.InitSeed
		_cache[seed] = _cache[seed] or npc.State
		if  _cache[seed] ~= npc.State then
			if npc.State == 3 then
				self:Run(self.IDs.FIREPLACE_BREAK, npc, npc.Variant)
			end
			_cache[seed] = npc.State
		end
	end
end
Grid:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, 'OnFirePlaceRender', EntityType.ENTITY_FIREPLACE)


end


return Grid