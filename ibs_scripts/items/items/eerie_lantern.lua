--诡异灯笼

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local EerieLantern = mod.IBS_Class.Item(mod.IBS_ItemID.EerieLantern)

--新房间
function EerieLantern:OnNewRoom()
	local room = game:GetRoom()
	
	if room:IsFirstVisit() then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then		
				for slot = 0,2 do
					local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
					if itemConfig and itemConfig.ChargeType == 0 and self._Players:GetSlotCharges(player, slot, true, true) < itemConfig.MaxCharges * 2 then
						self._Players:ChargeSlot(player, slot, 1, false, true, true, true)
					end
				end
			end
		end
	end
end
EerieLantern:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--清理房间失去充能
function EerieLantern:Charge()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then		
			for slot = 0,2 do
				local itemConfig = config:GetCollectible(player:GetActiveItem(slot))
				if itemConfig and itemConfig.ChargeType == 0 and self._Players:GetSlotCharges(player, slot, true, true) > 0 then					
					self:DelayFunction(function()
						if self._Players:DischargeSlot(player, slot, 1, true, false, true, true) then
							local effect = Isaac.Spawn(1000, 49, 3, player.Position, Vector.Zero, nil):ToEffect()
							effect.DepthOffset = player.DepthOffset + 40
							effect:FollowParent(player)
							sfx:Play(493)
						end
					end, 0)
				end
			end
		end
	end	
end
EerieLantern:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Charge')
--EerieLantern:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'Charge') --贪婪模式波次充能

return EerieLantern