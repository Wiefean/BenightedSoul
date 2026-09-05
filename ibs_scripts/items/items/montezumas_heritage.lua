--蒙特祖玛的遗产

local mod = Isaac_BenightedSoul

local game = Game()

local MontezumasHeritage = mod.IBS_Class.Item(mod.IBS_ItemID.MontezumasHeritage)

--失去钥匙时触发
function MontezumasHeritage:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				player:UseActiveItem(36, false, false)
			end
		end
	end
end
MontezumasHeritage:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')

--摧毁大便触发
function MontezumasHeritage:OnPoopBreak(gridEnt, ent, variant)	
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local pos = (gridEnt and gridEnt.Position) or ent.Position
		Isaac.Spawn(5, 30, 0, pos, Vector.Zero, nil)
		Isaac.Spawn(217, 3, 0, pos, Vector.Zero, nil)
		Isaac.Spawn(1000, 15, 0 ,pos, Vector.Zero, nil)
	end
end
MontezumasHeritage:AddCallback(mod.IBS_CallbackID.POOP_BREAK, 'OnPoopBreak')

return MontezumasHeritage