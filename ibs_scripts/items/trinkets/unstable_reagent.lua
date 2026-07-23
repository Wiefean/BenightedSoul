--不稳定试剂

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local UnstableReagent = mod.IBS_Class.Trinket(mod.IBS_TrinketID.UnstableReagent)

--获取药丸效果
function UnstableReagent:GetPills(seed, num)
	num = num or 1
	local result = {}

	local rng = RNG(seed)
	local MAX = config:GetPillEffects().Size - 1
	
	for i = 1,num do
		local pill = rng:RandomInt(1,MAX)
		local pillConfig = config:GetPillEffect(pill)
		if pillConfig and pillConfig:IsAvailable() then
			table.insert(result, pill)
		end
	end
	
	return result
end

--新层触发药丸效果
function UnstableReagent:OnNewLevel()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasTrinket(self.ID) then
			local mult = player:GetTrinketMultiplier(self.ID)
			local seed = player:GetTrinketRNG(self.ID):Next()
			local pills = self:GetPills(seed, 3*mult)
			local flags = UseFlag.USE_MIMIC | UseFlag.USE_NOANNOUNCER

			if #pills > 0 then			
				for i = 1,#pills do
					local pill = pills[i]
					if pill then					
						self:DelayFunction(function()
							if player:Exists() and not player:IsDead() then					
								player:UsePill(pill, 4, flags)
								player:AnimateTrinket(self.ID)
							end
						end, i*30)
					end
				end
			end
		end	
	end	
end
UnstableReagent:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')


return UnstableReagent