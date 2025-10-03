--慷慨模式挑战
--(部分效果在对应道具文件里)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local BC13 = mod.IBS_Class.Challenge(13, {
	PaperNames = {'bkeeper_up'},
	Destination = 'Greed'
})

--游戏开始
function BC13:OnGameStart(isContinued)
    if not self:Challenging() or isContinued then return end
	local BKeeper = (mod.IBS_Player and mod.IBS_Player.BKeeper)
	if BKeeper then
		BKeeper:GetData().HeartTokens = 14
	end
end
BC13:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, 'OnGameStart')

--饰品改为硬币饰品
function BC13:OnTrinketUpdate(pickup)
	if not self:Challenging() then return end
	if pickup.Price ~= 0 then return end
	if not self._Pools:IsPennyTrinket(pickup.SubType) then
		local id = self._Pools:GetRandomPennyTrinket(RNG(pickup.InitSeed))
		Isaac.Spawn(5, 350, id, pickup.Position, Vector.Zero, nil)
		pickup:Remove()
	end
end
BC13:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnTrinketUpdate', PickupVariant.PICKUP_TRINKET)

--完成
function BC13:TryFinish()
	if self:AtDestination() then
		if self:IsUnfinished() then
			self:Finish(true, true)
		end
		
		--把大宝箱替换为奖杯
		self:DelayFunction(function()		
			for _,ent in ipairs(Isaac.FindByType(5,340,0)) do
				Isaac.Spawn(5,370,0, ent.Position, Vector.Zero, nil)
				ent:Remove()
				break
			end
		end, 1)
	end
end
BC13:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC13