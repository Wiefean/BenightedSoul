--数量变动回调


local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()

local NumChange = mod.IBS_Class.Callbacks{
	NUM_CHANGE_COIN = IBS_CallbackID.NUM_CHANGE_COIN,
	NUM_CHANGE_BOMB = IBS_CallbackID.NUM_CHANGE_BOMB,
	NUM_CHANGE_KEY = IBS_CallbackID.NUM_CHANGE_KEY,
}

--获取数据
function NumChange:GetData()
	local data = self:GetIBSData('temp')

	if not data.CALLBACK_NUM_CHANGE then
		data.CALLBACK_NUM_CHANGE = {
			Coin = 0,
			Bomb = 0,
			Key = 0,
		}
	end
	
	return data.CALLBACK_NUM_CHANGE
end

--回调
function NumChange:RunCallbacks()
	local player = Isaac.GetPlayer(0)
    if not player then return end
	
	local data = self:GetData()
	local coin = player:GetNumCoins()
	local bomb = player:GetNumBombs()
	local key = player:GetNumKeys()
	
	if data.Coin ~= coin then
		self:Run(self.IDs.NUM_CHANGE_COIN, coin - data.Coin)
		data.Coin = coin
	end
	if data.Bomb ~= bomb then
		self:Run(self.IDs.NUM_CHANGE_BOMB, bomb - data.Bomb)
		data.Bomb = bomb
	end
	if data.Key ~= key then
		self:Run(self.IDs.NUM_CHANGE_KEY, key - data.Key)
		data.Key = key
	end
end
NumChange:AddCallback(ModCallbacks.MC_POST_UPDATE, 'RunCallbacks')

return NumChange