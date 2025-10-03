--小麦种子

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local WheatSeeds = mod.IBS_Class.Trinket(mod.IBS_TrinketID.WheatSeeds)

--效果
function WheatSeeds:OnRoomCleaned()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for id,tbl in ipairs(player:GetSmeltedTrinkets()) do
			if id == self.ID then
				for i = 1,tbl.trinketAmount do
					player:TryRemoveSmeltedTrinket(id)
					player:AddCollectible(IBS_ItemID.GrowingWheatI)
				end
				for i = 1,tbl.goldenTrinketAmount do
					player:TryRemoveSmeltedTrinket(id+32768)
					for i = 1,7 do
						player:AddCollectible(IBS_ItemID.GrowingWheatI)			
					end
				end
			end
		end	
	end
end
WheatSeeds:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')
WheatSeeds:AddCallback(mod.IBS_CallbackID.GREED_NEW_WAVE, 'OnRoomCleaned')

--受伤吞下 
function WheatSeeds:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if player then
		for i = 0,1 do
			local trinket = player:GetTrinket(0)
			if (trinket == self.ID) or (trinket == self.ID + 32768) then
				player:TryRemoveTrinket(trinket)
				player:AddSmeltedTrinket(trinket, false)
				SFXManager():Play(157)
			end
		end		
	end
end
WheatSeeds:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--新层吞下
function WheatSeeds:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for slot = 0,1 do
			local trinket = player:GetTrinket(slot)
			if (trinket == self.ID) or (trinket == self.ID + 32768) then
				player:TryRemoveTrinket(trinket)
				player:AddSmeltedTrinket(trinket, false)
				SFXManager():Play(157)
			end
		end	
	end
end
WheatSeeds:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--快速收起
function WheatSeeds:OnPickTrinket(player, trinket)
	player:AnimateTrinket(self.ID, 'UseItem')
end
WheatSeeds:AddCallback(mod.IBS_CallbackID.PICK_TRINKET, 'OnPickTrinket', WheatSeeds.ID)


return WheatSeeds