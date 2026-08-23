--解锁昧化遗骸

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()

local BForgotten = CharacterLock(mod.IBS_PlayerID.BForgotten, {})

--与昧化以撒全完成同步
function BForgotten:OnUpdate()
	local data = self:GetIBSData('persis')
	if data[IBS_PlayerKey.BIsaac] and data[IBS_PlayerKey.BForgotten] then
		if data[IBS_PlayerKey.BIsaac].FINISHED then
			data[IBS_PlayerKey.BForgotten].Unlocked = true
		else
			data[IBS_PlayerKey.BForgotten].Unlocked = false
		end
	end
end
BForgotten:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')
BForgotten:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, 'OnUpdate')

--锁
function BForgotten:Lock()
end

--解锁
function BForgotten:Unlock()
end


return BForgotten