--魂匙

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local SoulKeys = mod.IBS_Class.Item(mod.IBS_ItemID.SoulKeys)

--获取数据
function SoulKeys:GetData() 
	local data = self:GetIBSData('temp')

	if not data.SoulKeys then
		data.SoulKeys = {Num = 0}
	end
	
	return data.SoulKeys
end

--失去钥匙时触发
function SoulKeys:OnKeyNumChange(delta)
	if delta < 0 and PlayerManager.AnyoneHasCollectible(self.ID) then
		local data = self:GetData()
		data.Num = data.Num	+ (-delta)
		
		if data.Num >= 3 then
			data.Num = 0
			
			local rng = Isaac.GetPlayer(0):GetCollectibleRNG(self.ID)
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
			Isaac.Spawn(5, 300, rng:RandomInt(81,97), pos, Vector.Zero, nil)
		end
	end
end
SoulKeys:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')


return SoulKeys