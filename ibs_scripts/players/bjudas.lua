--昧化犹大

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_TrinketID = mod.IBS_TrinketID
local CharacterLock = mod.IBS_Achiev.CharacterLock

local game = Game()
local sfx = SFXManager()

local BJudas = mod.IBS_Class.Character(mod.IBS_PlayerID.BJudas, {
	BossIntroName = 'bjudas',
	SpritePath = 'gfx/ibs/characters/player_bjudas.anm2',
	SpritePathFlight = 'gfx/ibs/characters/player_bjudas.anm2',
	PocketActive = mod.IBS_ItemID.TGOJ,
	TearsModifier = 0.6	
})


--初始化角色
function BJudas:OnPlayerInit(player)
	--混沌信仰
	if player:GetPlayerType() == self.ID and self:GetIBSData('persis')['bc4'] then
		player:AddTrinket(IBS_TrinketID.ChaoticBelief, false)
	end
end
BJudas:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit', 0)


--变身
function BJudas:Benighted(player, fromMenu)
	local CAN = false 

	--检测彼列书和三块钱
	if player:GetNumCoins() >= 3 then
		for slot = 0,1 do
			if player:GetActiveItem(slot) == 34 then
				player:RemoveCollectible(34, true, slot)
				CAN = true
				break
			end	
		end
		if player:GetActiveItem(2) == 34 then CAN = true end
	end
	
	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)
		player:AddCoins(-3)
		player:AddBlackHearts(2)
		player:AddMaxHearts(-2)
		player:AddEternalHearts(1)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		player:SetMinDamageCooldown(76)
		
		--混沌信仰
		if self:GetIBSData('persis')['bc4'] then
			player:AddTrinket(IBS_TrinketID.ChaoticBelief, false)
			game:AddDevilRoomDeal()
		end
		
		--我释放恶魂
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
		for i = 1,7 do
			Isaac.Spawn(1000, 189, 1, player.Position + 20*RandomVector(), Vector.Zero, player)
		end
		if not fromMenu then
			sfx:Play(266)
			sfx:Play(468)
		end
	end
end
BJudas:AddCallback(mod.IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_JUDAS)

--清除尿迹(十分生草)
local function ClearPee(_,effect)
	if game:GetRoom():GetFrameCount() > 0 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BJudas.ID then
			if effect.Position:Distance(player.Position) <= 1 then
				effect:Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ClearPee, 7)

return BJudas