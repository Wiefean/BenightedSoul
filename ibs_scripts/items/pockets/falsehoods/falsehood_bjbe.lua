--雅各和以扫的伪忆

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local BJBE = mod.IBS_Class.Pocket(mod.IBS_PocketID.BJBE)

--使用效果
function BJBE:OnUse(card, player, flag)
	local item = self._Finds:ClosestCollectible(player.Position)
	if item ~= nil and item.SubType ~= 0 then
		local itemConfig = config:GetCollectible(item.SubType)
		if itemConfig then
			local room = game:GetRoom()
			local quality = (itemConfig.Quality or 0) - 1
			local rng = player:GetCardRNG(self.ID)
			local pool = self._Pools:GetRoomPool()

			--把道具变为两个品质减一的道具
			for i = 1,2 do
				local pos = room:FindFreePickupSpawnPosition(item.Position + Vector(40,0) * (-1)^i, 0, true)
				local id = self._Pools:GetCollectibleWithQuality(rng:Next(), quality, pool, true)
				Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil)
				Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
			end

			item:Remove()
		end
	end
end
BJBE:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BJBE.ID)


--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BJBE.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bjbe.png",
		textKey = "FALSEHOOD_BJBE",
		name = {
			zh = "雅各和以扫的伪忆",
			en = "Falsehood of Jacob and Esau",
		},
		desc = {
			zh = "三个臭皮匠",
			en = "The Three Stooges",
		}, 
	})
	
	--镶嵌改动
	local oldfn = RuneSword.InsertRune
	function RuneSword:InsertRune(player, rune, ...)
		if rune == BJBE.ID then
			local BLilith = (mod.IBS_Pocket and mod.IBS_Pocket.BLilith)
			
			--复制品质最低的道具两次(借用莉莉丝伪忆)
			if BLilith then			
				local item,quality = BLilith:GetLowestItem(player, player:GetCardRNG(BJBE.ID):Next())
				if item then				
					for i = 1,2 do
						player:AddCollectible(item)
					end
				end
			end
		end
		return oldfn(self, player, rune, ...)
	end
	
end

return BJBE