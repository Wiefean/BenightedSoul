--铜锌合金D6

local mod = Isaac_BenightedSoul

local sfx = SFXManager()

local CuZnD6 = mod.IBS_Class.Pocket(mod.IBS_PocketID.CuZnD6)

--获取当前概率
function CuZnD6:GetChance()
	local data = self:GetIBSData('temp')
	data.czd6Chance = data.czd6Chance or 109
	data.czd6Chance = data.czd6Chance - 10
	if data.czd6Chance < 0 then data.czd6Chance = 0 end
	
	return data.czd6Chance
end

--使用效果
function CuZnD6:OnUse(card,player,flag)	
	player:UseActiveItem(105,false,false) --D6
	
	--尝试再给予骰子
	if (flag & UseFlag.USE_MIMIC <= 0) then		
		if player:GetCardRNG(self.ID):RandomInt(100) < self:GetChance() then
			player:AddCard(self.ID)
		end
	end	
end
CuZnD6:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', CuZnD6.ID)



--(硬核播放音效)
local Timeout = 0

--掉落音效
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE,function(_,pickup)
	if pickup.SubType == CuZnD6.ID then
		local spr = pickup:GetSprite()
		if spr:IsEventTriggered("Drop") then
			sfx:Play(466)
		end
	end
end, PickupVariant.PICKUP_TAROTCARD)

--替换拾取音效
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if Timeout > 0 then
		sfx:Stop(8)
		Timeout = Timeout - 1
    end
end)
mod:AddCallback(mod.IBS_CallbackID.PICK_CARD, function()
	sfx:Play(252)
	Timeout = 2
end, CuZnD6.ID)



return CuZnD6