--逾越节挑战

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_Curse = mod.IBS_Curse
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID

local game = Game()

local BC4 = mod.IBS_Class.Challenge(4, {
	PaperNames = {'bjudas_up'},
	Destination = 'MegaSatan'
})

--角色初始化
function BC4:OnPlayerInit(player)
	if not self:Challenging() then return end
	player:AddCoins(-3)
	player:AddCollectible(454, 0, false) --多指
	self:DelayFunction2(function()
		if self:Challenging() and not self:IsGameContinued() then
			player:RemoveCollectible(player:GetActiveItem(0), true, 0)
			player:AddCollectible(IBS_ItemID.TGOJ, 135, true , 0)
		end
	end, 1)	
end
BC4:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--新层
function BC4:OnNewLevel()
	if not self:Challenging() then return end

	--动人诅咒
	game:GetLevel():AddCurse(IBS_Curse.Moving.Bitmask, false)
	IBS_Curse:_Emphasize()

	--俩犹大伪忆
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		player:AddCard(IBS_PocketID.BJudas)
		player:AddCard(IBS_PocketID.BJudas)
	end
end
BC4:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--强制动人诅咒
function BC4:OnUpdate()
	if not self:Challenging() then return end
	local level = game:GetLevel()
	if level:GetCurses() & IBS_Curse.Moving.Bitmask <= 0 then
		level:AddCurse(IBS_Curse.Moving.Bitmask, false)
	end
end
BC4:AddCallback(ModCallbacks.MC_POST_UPDATE, 'OnUpdate')

--完成
function BC4:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC4:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'TryFinish', EntityType.ENTITY_MEGA_SATAN_2)
BC4:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'TryFinish', EntityType.ENTITY_MEGA_SATAN_2)


return BC4