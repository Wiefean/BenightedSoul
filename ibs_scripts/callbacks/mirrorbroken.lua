--镜子被破坏回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback

--检查镜子状态记录
local function CheckMirrorRecord()
	local data = mod:GetIBSData("Level")
	data.MirrorBroken = data.MirrorBroken or false
	
	return data.MirrorBroken
end

--炸镜子给人物解锁提示
local function MirrorBrokenCallback()
	local room = Game():GetRoom()
	local level = Game():GetLevel()
	
	local mirror = level:GetStateFlag(LevelStateFlag.STATE_MIRROR_BROKEN)
	local mirror_record = CheckMirrorRecord()
	
	--当前记录与镜子状态不同时触发
	if mirror_record ~= mirror then
		if mirror == true then
			Isaac.RunCallback(IBS_Callback.MIRROR_BROKEN)
			mod:GetIBSData("Temp").MirrorBroken = true
		end
		mod:GetIBSData("Level").MirrorBroken = mirror
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, MirrorBrokenCallback)

