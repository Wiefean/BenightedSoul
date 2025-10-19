--昧化夏娃

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Achiev.CharacterLock

local game = Game()
local sfx = SFXManager()

local BEve = mod.IBS_Class.Character(mod.IBS_PlayerID.BEve, {
	BossIntroName = 'beve',
	PocketActive = mod.IBS_ItemID.MyFruit,
})


--变身
function BEve:Benighted(player, fromMenu)
	if CharacterLock.BEve:IsLocked() then return end

	local CAN = false 

	--检测
	if player:HasCollectible(122) then	
		for slot = 0,1 do
			if player:GetActiveItem(slot) == 126 then
				player:RemoveCollectible(126, true, slot)
				break
			end
		end
		player:RemoveCollectible(117, true)
		player:RemoveCollectible(122, true)
		CAN = true
	end
	
	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		player:SetMinDamageCooldown(60)
		player:AddControlsCooldown(100)
		player.Visible = false
		game:GetItemPool():RemoveCollectible(IBS_ItemID.MyFault)
		self:DelayFunction(function()
			player.Visible = true
			player:AnimateTeleport()
			sfx:Play(SoundEffect.SOUND_HELL_PORTAL2)
		end, 1)
	end
end
BEve:AddCallback(mod.IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_EVE)

--动画文件
local SpriteDefaultPath = "gfx/001.000_player.anm2"
local SpritePath = 'gfx/ibs/characters/player_beve.anm2'
local SpritePath2 = 'gfx/ibs/characters/player_beve2.anm2'
local SheetPath = 'gfx/ibs/characters/costumes/players/beve/beve.png'
local SheetPath2 = 'gfx/ibs/characters/costumes/players/beve/beve2.png'

--装扮
local costume_hair = Isaac.GetCostumeIdByPath('gfx/ibs/characters/beve_hair.anm2')
local costume_hair2 = Isaac.GetCostumeIdByPath('gfx/ibs/characters/beve_hair2.anm2')

--更新贴图
function BEve:__UpdatePlayerSprite(player, data)
	local sprPath = SpritePath
	local sprPath2 = SpritePath2
	local sprState = 1
	local path = sprPath
	local sheetPath = SheetPath
	
	--副手不为我果
	if player:GetActiveItem(2) ~= IBS_ItemID.MyFruit then
		path = sprPath2
		sheetPath = SheetPath2
		sprState = 2
	end
	
	--飞行
	if player.CanFly then
		path = sprPath
		sheetPath = SheetPath
		sprState = 3
		
		--副手不为我果
		if player:GetActiveItem(2) ~= IBS_ItemID.MyFruit then
			path = sprPath2
			sheetPath = SheetPath2
			sprState = 4
		end
	end	
	
	--超大蘑菇
	if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
		path = SpriteDefaultPath
		sprState = 0
	end

	if data.SpriteState ~= sprState then
		data.SpriteState = sprState
		self:__ChangeSprite(player, path, sheetPath)
		
		--调整装扮
		if sprState == 1 or sprState == 3 then
			player:TryRemoveNullCostume(costume_hair2)
			player:AddNullCostume(costume_hair)
		elseif sprState == 2 or sprState == 4 then
			player:TryRemoveNullCostume(costume_hair)
			player:AddNullCostume(costume_hair2)
		end
	end	
end

--新层尝试换回我果
function BEve:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local slot = 2
			local item = player:GetActiveItem(slot)
			if item == mod.IBS_ItemID.MyFault then
				local varData = player:GetActiveItemDesc(slot).VarData
				if varData < 4 then
					player:SetPocketActiveItem(IBS_ItemID.MyFruit, slot, false)
					player:SetActiveVarData(varData, slot)
					player:SetActiveCharge(0, slot)
				end
			end
		end
	end	
end
BEve:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--完成挑战后可主动切换副手
function BEve:OnNewRoom()
	if game:GetRoom():IsFirstVisit() then return end
	
	--挑战完成状态检测
	if not self:GetIBSData('persis')['bc6'] then
		return
	end
	
	--初始房间检测
	local level = game:GetLevel()
	if level:GetCurrentRoomDesc().SafeGridIndex ~= level:GetStartingRoomIndex() then
		return
	end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local slot = 2
			local item = player:GetActiveItem(slot)
			
			--没用过我果才可换
			if item == mod.IBS_ItemID.MyFault and not self:GetIBSData('level').MyFruitTriggered then
				local varData = player:GetActiveItemDesc(slot).VarData
				if varData < 4 then
					player:SetPocketActiveItem(IBS_ItemID.MyFruit, slot, false)
					player:SetActiveVarData(varData, slot)
				end
			end
			
			--满充能我果才可换
			if item == mod.IBS_ItemID.MyFruit and self._Players:GetSlotCharges(player, slot, true, true) >= 12 then
				local varData = player:GetActiveItemDesc(slot).VarData
				if varData < 4 then
					player:SetPocketActiveItem(IBS_ItemID.MyFault, slot, false)
					player:SetActiveVarData(varData, slot)
				end
			end
		end
	end	
end
BEve:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

return BEve