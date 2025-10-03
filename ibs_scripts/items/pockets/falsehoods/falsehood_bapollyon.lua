--亚波伦的伪忆

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local BApollyon = mod.IBS_Class.Pocket(mod.IBS_PocketID.BApollyon)

--获取数据
function BApollyon:GetData()
	local data = self:GetIBSData('temp')
	data.FalsehoodBApollyon = data.FalsehoodBApollyon or {41, 41, 41}
	return data.FalsehoodBApollyon
end

--效果
function BApollyon:OnUseCard(card, player, flag)
	--非收获符文
	if card == 33 then return end

	local data = self:GetData()
	if card ~= BApollyon.ID then
		if flag & UseFlag.USE_MIMIC <= 0 then
			local cardConfig = config:GetCard(card)
		
			--检测是否为符文
			if cardConfig and cardConfig.CardType == ItemConfig.CARDTYPE_RUNE then
				table.insert(data, 1, card)
				if #data >= 4 then
					for i = 4,#data do
						data[i] = nil
					end
				end
			end
		end
	else
		if #data > 0 then
			local room = game:GetRoom()
			for _,id in ipairs(data) do
				local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
				Isaac.Spawn(5, 300, id, pos, Vector.Zero, nil)	
			end
		end
	end
end
BApollyon:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard')

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BApollyon.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bapollyon.png",
		textKey = "FALSEHOOD_BAPOLLYON",
		name = {
			zh = "亚波伦的伪忆",
			en = "Falsehood of Apollyon",
		},
		desc = {
			zh = "回响",
			en = "Echoes",
		}, 
	})
	
	--镶嵌改动
	local oldfn = RuneSword.InsertRune
	function RuneSword:InsertRune(player, rune, ...)
		if rune == BApollyon.ID then
			player:UseCard(BApollyon.ID, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
		return oldfn(self, player, rune, ...)
	end
	
end

return BApollyon