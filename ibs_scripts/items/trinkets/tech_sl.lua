--科技SL

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()

local TechSL = mod.IBS_Class.Trinket(mod.IBS_TrinketID.TechSL)

--问心无愧
function TechSL:SL(player)
	player:UseActiveItem(422, false, false)
	self:DelayFunction(function()
		player:AnimateTrinket(self.ID)
	end, 1, nil, true)
end

--死亡崩溃
function TechSL:OnPlayerKilled(ent)
	local player = ent:ToPlayer()
	if player and player:HasTrinket(self.ID) and not player:WillPlayerRevive() then
		--有额外饰品倍率则改为问心无愧
		if player:GetTrinketMultiplier(self.ID) > 1 then
			self:SL(player)
		else
			self:SaveIBSData()
			
			--利用控制台指令崩溃
			Isaac.ExecuteCommand("challenge 112345")
		end
	end
end
TechSL:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnPlayerKilled', EntityType.ENTITY_PLAYER)


return TechSL