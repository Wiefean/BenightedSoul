--钥匙变炸弹挑战
--(部分效果写在角色跟道具的lua文件内)

local mod = Isaac_BenightedSoul

local game = Game()

local BC11 = mod.IBS_Class.Challenge(11, {
	PaperNames = {'blost_up'},
	Destination = 'BlueBaby'
})

--角色初始化
function BC11:OnPlayerInit(player)
    if not self:Challenging() then return end

	self:DelayFunction2(function()
		if not self:IsGameContinued() then
			player:AddSmeltedTrinket(136) --损坏的挂锁
			player:AddTrinket(41) --火柴棍
			player:AddKeys(10)

			--炸弹变钥匙
			local itemPool = game:GetItemPool()
			local pillColor = itemPool:ForceAddPillEffect(3)
			itemPool:IdentifyPill(pillColor)
			player:AddPill(pillColor)
			
			--生成箱子
			local room = game:GetRoom()
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-80), 0, true)	
			Isaac.Spawn(5,50,1, pos, RandomVector(), nil)

		end
	end, 1)
end
BC11:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--完成
function BC11:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC11:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC11