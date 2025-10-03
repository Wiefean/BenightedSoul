--区间

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local Interval = mod.IBS_Class.Trinket(mod.IBS_TrinketID.Interval)

function Interval:OnGainItem(item, charge, first, slot, varData, player)
	if slot > 1 then return end
	self._Players:GetData(player).Interval_LastOne = item
end
Interval:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')


--效果
function Interval:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end

	if self._Ents:IsEnemy(ent) then
		local extra = 0

		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local last = self._Players:GetData(player).Interval_LastOne

			if last ~= nil and player:HasTrinket(self.ID) then
				local item = player:GetActiveItem(0)
				if item ~= 0 and item ~= last then
					extra = extra + 0.005 * math.abs(item - last) * player:GetTrinketMultiplier(self.ID)
				end
			end
		end		
	
		if extra > 0 then
			return {Damage = dmg + extra, DamageFlags = flag , DamageCountdown = cd}
		end
	end
end
Interval:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 100000, 'OnTakeDMG')

local fnt = Font('font/terminus8.fnt')

--提示
function Interval:OnTrinketRender(slot, pos, scale, player)
	local trinket = player:GetTrinket(slot)
	if trinket ~= self.ID and trinket ~= self.ID + 32768 then return end
	local item = player:GetActiveItem(0) if item == 0 then item = 'nil' end
	local last = self._Players:GetData(player).Interval_LastOne if last == nil then last = 'nil' end
	local left = item
	local right = last
	
	if type(left) == 'number'and type(right) == 'number' then
		if left > right then
			left = last
			right = item
		end
	end
	
	local color = (trinket == self.ID + 32768 and KColor(1,1,0,1)) or KColor(1,1,1,1)
	fnt:DrawStringScaled('('..left..','..right..')', pos.X - 32*scale, pos.Y + 12*scale, scale, scale, color, 144, true)

	return true
end
Interval:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_TRINKET_RENDER, 'OnTrinketRender')


return Interval