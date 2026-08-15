--玩具钥匙

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local ToyKeys = mod.IBS_Class.Item(mod.IBS_ItemID.ToyKeys)

--获取数据
function ToyKeys:GetData()
	local data = self:GetIBSData('level')

	if not data.ToyKeys then
		data.ToyKeys = {Left = 63}
	end
	
	return data.ToyKeys
end

--尝试生成奖励(实则偷懒触发7书)
function ToyKeys:TryBonus(player)
	local data = self:GetData()
	local times = player:GetCollectibleRNG(self.ID):RandomInt(4)
	
	if times > 0 then
		for i = 1,times do
			if data.Left > 0 then
				data.Left = data.Left - 1
				player:UseActiveItem(97, false, false)
			end		
		end
	end
end

--失去钥匙时触发
function ToyKeys:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				self:TryBonus(player)
			end
		end
	end
end
ToyKeys:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')

--普通箱子概率变为金箱子
function ToyKeys:TryReplace(pickup)
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if pickup.SubType == 1 and RNG(pickup.InitSeed):RandomInt(100) < 50 then
		pickup:Morph(5, 60, 1, true, true)
		return true
	end
end
ToyKeys:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'TryReplace', 50)

return ToyKeys