--防卫王冠

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local DefensiveCrown = mod.IBS_Class.Trinket(mod.IBS_TrinketID.DefensiveCrown)

--道具首次出现时触发
function DefensiveCrown:OnPickupFirstAppear(pickup)
	if pickup.SubType <= 0 then return end --非错误道具和空底座
	--if pickup.Charge <= 0 then return end --没有充能(注意-1表示满充能)
	if pickup.Charge == 0 then return end --没有充能
	local itemConfig = config:GetCollectible(pickup.SubType)

	--常规充能主动
	if itemConfig and itemConfig.Type == 3 and itemConfig.ChargeType == 0 and itemConfig.MaxCharges > 0 then
		local has = false
	
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasTrinket(self.ID) then
				player:AddSoulHearts(player:GetTrinketMultiplier(self.ID))
				local effect = Isaac.Spawn(1000, 49, 4, player.Position, Vector.Zero, nil):ToEffect()
				effect.DepthOffset = player.DepthOffset + 40
				effect:FollowParent(player)
				sfx:Play(54)				
				has = true
			end
		end
		
		if has then
			self:DelayFunction(function()			
				pickup.Charge = 0
			end, 0)
			local effect = Isaac.Spawn(1000, 49, 3, pickup.Position, Vector.Zero, nil):ToEffect()
			effect.DepthOffset = pickup.DepthOffset + 40
			sfx:Play(493)
		end
	end
end
DefensiveCrown:AddPriorityCallback(IBS_CallbackID.PICKUP_FIRST_APPEAR, -100, 'OnPickupFirstAppear', 100)

return DefensiveCrown