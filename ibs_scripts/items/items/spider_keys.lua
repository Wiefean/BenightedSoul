--蜘蛛钥匙

local mod = Isaac_BenightedSoul

local game = Game()

local SpiderKeys = mod.IBS_Class.Item(mod.IBS_ItemID.SpiderKeys)

--失去钥匙时触发
function SpiderKeys:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				for i = 1,math.random(3,6) do
					player:ThrowBlueSpider(player.Position, player.Position + 20 * RandomVector())
				end
			end
		end
	end
end
SpiderKeys:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')


--蓝蜘蛛消失检测
function SpiderKeys:OnSpiderRemoved(ent)
	if ent.Variant == 73 and ent.SubType == 0 and PlayerManager.AnyoneHasCollectible(self.ID) then
		if RNG(ent.InitSeed):RandomInt(100) < 10 then
			Isaac.Spawn(5, 30, 0, ent.Position, Vector.Zero, nil)
		end
	end
end
SpiderKeys:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,'OnSpiderRemoved', 3)

return SpiderKeys
