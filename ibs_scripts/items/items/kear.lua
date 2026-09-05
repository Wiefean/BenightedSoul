--钥湿

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Kear = mod.IBS_Class.Item(mod.IBS_ItemID.Kear)

--失去钥匙时触发
function Kear:OnKeyNumChange(delta)
	if delta < 0 then
		--偷懒用掉渣饼的临时射速
		local DreggyPie = (mod.IBS_Item and mod.IBS_Item.DreggyPie)
		if DreggyPie then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				if player:HasCollectible(self.ID) then
					local data = DreggyPie:GetData(player)
					data.TearsUp = data.TearsUp + 1
					player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
				end
			end
		end
	end
end
Kear:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')

return Kear