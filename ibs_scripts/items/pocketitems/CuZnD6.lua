--铜锌合金D6

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Pocket = mod.IBS_Pocket

local sfx = SFXManager()

--获取当前概率
local function GetChance()
	local data = mod:GetIBSData("Temp")
	data.czd6Chance = data.czd6Chance or 100
	data.czd6Chance = data.czd6Chance - 10
	if data.czd6Chance < 0 then data.czd6Chance = 0 end
	
	return data.czd6Chance
end

--使用效果
local function Roll(_,card,player,flag)	
	player:UseActiveItem(105,false,false)
	
	--尝试再给予骰子
	if (flag & UseFlag.USE_MIMIC <= 0) then		
		if player:GetCardRNG(IBS_Pocket.czd6):RandomInt(100) + 1 <= GetChance() then
			player:AddCard(IBS_Pocket.czd6)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Roll, IBS_Pocket.czd6)



--(硬核播放音效)
local TimeOut = 0

--掉落音效
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE,function(_,pickup)
	if pickup.SubType == IBS_Pocket.czd6 then
		local spr = pickup:GetSprite()
		if spr:IsEventTriggered("Drop") then
			sfx:Play(466)
		end
	end
end, PickupVariant.PICKUP_TAROTCARD)

--替换拾取音效
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if TimeOut > 0 then
		sfx:Stop(8)
		TimeOut = TimeOut - 1
    end
end)
mod:AddCallback(IBS_Callback.PICK_CARD, function()
	sfx:Play(252)
	TimeOut = 2
end, IBS_Pocket.czd6)

