--阿撒泻勒的伪忆

local mod = Isaac_BenightedSoul

local game = Game()

local BAzazel = mod.IBS_Class.Pocket(mod.IBS_PocketID.BAzazel)

--获取数据
function BAzazel:GetData()
	local data = self:GetIBSData('temp')
	data.FalsehoodBAzazel = data.FalsehoodBAzazel or {
		Sacrifice = 0,
	}
	return data.FalsehoodBAzazel
end

--生成
local function Spawn(T, V, S)
	local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
	Isaac.Spawn(T, V, S, pos, Vector.Zero, nil)
end

--奖励
function BAzazel:Bonus(sacrifice, seed, player)
	local level = game:GetLevel()

	if sacrifice == 1 or sacrifice == 2 then
		Spawn(5, 20, 0) --随机硬币
	elseif sacrifice == 3 then
		if RNG(seed):RandomInt(4) > 0 then
			game:GetLevel():AddAngelRoomChance(0.15)
			game:GetHUD():ShowFortuneText(self:ChooseLanguage('你被祝福了 !', 'You Feel Blessed!'))
		end
	elseif sacrifice == 4 then
		Spawn(5, 51, 0) --石箱子
	elseif sacrifice == 5 then
		if RNG(seed):RandomInt(4) == 1 then
			Spawn(5, 20, 0) --随机硬币
			Spawn(5, 20, 0) --随机硬币
			Spawn(5, 20, 0) --随机硬币
		else		
			game:GetLevel():AddAngelRoomChance(0.5)
			game:GetHUD():ShowFortuneText(self:ChooseLanguage('你被祝福了 !', 'You Feel Blessed!'))
		end
	elseif sacrifice == 6 then
		if RNG(seed):RandomInt(4) == 1 then
			--传送至天使/恶魔房
			level:InitializeDevilAngelRoom(false, false)
			game:StartRoomTransition(-1, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
		else
			Spawn(5, 51, 0) --石箱子
		end
	elseif sacrifice == 7 then
		if RNG(seed):RandomInt(4) == 1 then
			--生成天使房道具
			local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, true, seed)
			Spawn(5, 100, id)
		else
			Spawn(5, 51, 0) --石箱子
		end		
	elseif sacrifice == 8 then
		Spawn(5, 40, 0) --随机炸弹
	elseif sacrifice == 9 then
		Spawn(5, 100, 238) --钥匙碎片1
	elseif sacrifice == 10 then
		if RNG(seed):RandomInt(100) < 50 then
			--半魂心
			for i = 1,7 do
				Spawn(5, 10, 8)
			end
		else
			--随机硬币
			for i = 1,14 do
				Spawn(5, 20, 0)
			end			
		end
	elseif sacrifice == 11 then
		Spawn(5, 100, 239) --钥匙碎片2
	elseif sacrifice == 12 then
		game:GetHUD():ShowFortuneText(self:ChooseLanguage('达标...', 'Reached the standard...'))
	end
end

--效果
function BAzazel:OnUse(card, player, flag)
	local data = self:GetData()
	data.Sacrifice = data.Sacrifice + 1
	self:Bonus(data.Sacrifice, player:GetCardRNG(self.ID):Next(), player)
	player:ResetDamageCooldown()
	player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(player), 0)
	player:AddCard(self.ID)
	player:AnimateCard(self.ID, 'UseItem')
end
BAzazel:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BAzazel.ID)

--新层移除
function BAzazel:OnNewLevel()
	local data = self:GetIBSData('temp').FalsehoodBAzazel
	local lose = false

	if (not data) or data.Sacrifice < 12 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			for slot = 0,3 do
				if player:GetCard(slot) == self.ID then
					player:RemovePocketItem(slot)
					lose = true
				end
			end
		end
	end
		
	if lose then
		self:DelayFunction(function()		
			game:GetHUD():ShowFortuneText(self:ChooseLanguage('你被炒了 !', 'You are fired!'))
		end, 20)
	end
	
	self:GetIBSData('temp').FalsehoodBAzazel = nil
end
BAzazel:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -7777, 'OnNewLevel')


--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BAzazel.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/bazazel.png",
		textKey = "FALSEHOOD_BAZAZEL",
		name = {
			zh = "阿撒泻勒的伪忆",
			en = "Falsehood of Azazel",
		},
		desc = {
			zh = "任意地刺均可献祭",
			en = "Sacrifice at any ground spike",
		}, 
	})
	
	--受尖刺伤害时触发该符文效果
	function BAzazel:OnTakeDMG(ent, dmg, flag, source)
		local player = ent:ToPlayer()
		if player and (flag & DamageFlag.DAMAGE_SPIKES > 0) and RuneSword:HasInsertedRune(player, self.ID) then
			local data = self:GetData()
			data.Sacrifice = data.Sacrifice + 1
			self:Bonus(data.Sacrifice, player:GetCardRNG(self.ID):Next(), player)	
		end
	end
	BAzazel:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')
	
end


return BAzazel