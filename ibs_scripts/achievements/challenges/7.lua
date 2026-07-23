--背刺挑战
--(部分效果写在角色跟物品的lua文件内)

local mod = Isaac_BenightedSoul

local game = Game()

local BC7 = mod.IBS_Class.Challenge(7, {
	PaperNames = {'bsamson_up'},
	Destination = 'Lamb'
})

--角色初始化
function BC7:OnPlayerInit(player)
    if not self:Challenging() then return end
	player:AddBombs(9)
	
	self:DelayFunction2(function()
		mod.IBS_Player.BSamson:ChangeState(player, 1) --进入暴怒
	
		if not self:IsGameContinued() then
			game:GetItemPool():RemoveCollectible(252) --小药袋移出道具池

			--初始架势给愚者
			mod.IBS_Item.Posture:GetData(player).Cards[1] = 1
			mod.IBS_Item.Posture:RefreshList(player)
		end
	end, 1)
end
BC7:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--完成
function BC7:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC7:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC7