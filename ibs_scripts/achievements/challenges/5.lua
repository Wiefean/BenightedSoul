--双重释放挑战
--(部分效果在对应角色文件里)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local Memories = mod.IBS_Class.Memories()

local game = Game()
local sfx = SFXManager()

local BC5 = mod.IBS_Class.Challenge(5, {
	PaperNames = {'bxxx_up'},
	Destination = 'BlueBaby'
})

--游戏开始
function BC5:OnGameStart(isContinued)
    if not self:Challenging() or isContinued then return end
	Memories:Add(99)
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end	
end
BC5:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'OnGameStart')

--完成
function BC5:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC5:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC5