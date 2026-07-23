--参孙技能
--倒命运之轮

local mod = Isaac_BenightedSoul
local Damage = mod.IBS_Class.Damage()

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(66, {
	IsReversed = true,
})

--是否应该保护
function Skill:ShouldProtect(player, flag, source)
	local BSamson = mod.IBS_Player.BSamson

	return player:GetPlayerType() == BSamson.ID
		and BSamson:GetState(player) == BSamson.Wrath
		and Damage:CanHurtPlayer(player, flag, source) 
		and not Damage:IsPlayerSelfDamage(player, flag, source)
end

--随机抽牌
function Skill:GetRandomCard(player)
	local Posture = mod.IBS_Item.Posture
	local data = Posture:GetData(player)
	local rng = player:GetCollectibleRNG(Posture.ID)
	local cards = {}

	if rng:RandomInt(100) < 50 then	
		for slot,id in ipairs(data.Cards) do
			if id > 0 then
				table.insert(cards, {Slot = slot, ID = id})
			end
		end	
		
		if #cards <= 0 then
			for slot,id in ipairs(data.Cards2) do
				if id > 0 then
					table.insert(cards, {Slot = slot, ID = id})
				end
			end
		end
	else
		for slot,id in ipairs(data.Cards2) do
			if id > 0 then
				table.insert(cards, {Slot = slot, ID = id})
			end
		end
		
		if #cards <= 0 then
			for slot,id in ipairs(data.Cards) do
				if id > 0 then
					table.insert(cards, {Slot = slot, ID = id})
				end
			end
		end
	end
	
	if #cards > 0 then
		local card = cards[rng:RandomInt(1,#cards)] or cards[1]
		if card then		
			return card.ID, card.Slot, card.ID > 22
		end
	end
	
	return -1, -1, false
end

--在即将受伤时生效
function Skill:PrePlayerTakeDMG(player, dmg, flag, source)
	if dmg <= 0 then return end
	if not self:HasCard(player) then return end
	if not self:ShouldProtect(player, flag, source) then return end
	local id, slot, reversed = self:GetRandomCard(player)
	
	if id > 0 and slot > 0 then
		local Posture = mod.IBS_Item.Posture
		local data = Posture:GetData(player)
		
		if id == self.ID then
			self._Stats:PersisLuck(player, -1)
			sfx:Play(267)
		else
			self._Stats:PersisLuck(player, 0.25)
			Isaac.Spawn(5, 300, (id > 55 and id - 55) or (id + 55), player.Position, RandomVector(), nil)
			sfx:Play(268)
		end
		
		Posture:ConsumeCard(player, slot, reversed)
		player:SetMinDamageCooldown(120)	
		
		return false
	end
end
Skill:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, 1, 'PrePlayerTakeDMG')

return Skill