--昧化以撒

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents
local IBS_RNG = mod:GetUniqueRNG("Player_BIsaac")

local sfx = SFXManager()

--装扮
local costume_devilBonus = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bisaac_devil.anm2')
local costume_angelBonus = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bisaac_angel.anm2')
local costume_bothBonus = Isaac.GetCostumeIdByPath('gfx/ibs/characters/bisaac_both.anm2')

--临时玩家数据
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.BISAAC = data.BISAAC or {
		PlayerMatched = false,
		CostumeState = "none"
	}

	return data.BISAAC
end

--变身
local function Henshin(_,player)
	local canHenshin = false 

	--检测D6
	for slot = 0,1 do
		if player:GetActiveItem(slot) == 105 then
			player:RemoveCollectible(105, true, slot)
			canHenshin = true
			break
		end	
	end
	if player:GetActiveItem(2) == 105 then canHenshin = true end
	
	if canHenshin then
		player:ChangePlayerType(IBS_Player.bisaac)
		player:AddSoulHearts(6)
		player:AddMaxHearts(-6)
		player:SetPocketActiveItem(IBS_Item.ld6, ActiveSlot.SLOT_POCKET, false)
		
		--如果完成了对应挑战,生成一个骰子碎片
		if IBS_Data.Setting["bc1"] then
			sfx:Play(500, 0.7)
			Isaac.Spawn(5, 300, 49, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, nil)
		end
		
		player:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
	end
end
mod:AddCallback(IBS_Callback.BENIGHTED_HENSHIN, Henshin, PlayerType.PLAYER_ISAAC)

--初始化角色
local function Bisaac_Init(_, player)
    if player:GetPlayerType() == (IBS_Player.bisaac) then
        local game = Game()
        if not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0) then
            player:SetPocketActiveItem((IBS_Item.ld6), ActiveSlot.SLOT_POCKET, false)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Bisaac_Init)

--更新装扮
local function Bisaac_Costume(_,player)
    local data = GetPlayerData(player)	
    local state = 1

	if player:GetPlayerType() == (IBS_Player.bisaac) then
		if not data.PlayerMatched then data.PlayerMatched = true end
		
		--恶魔/天使奖励装扮
		if IBS_Data.GameState.Temp.BenightedIsaac then		
			local mode = IBS_Data.GameState.Temp.BenightedIsaac.BonusMode
			if data.CostumeState ~= mode then
				data.CostumeState = mode
				player:TryRemoveNullCostume(costume_devilBonus)
				player:TryRemoveNullCostume(costume_angelBonus)
				player:TryRemoveNullCostume(costume_bothBonus)
				
				if data.CostumeState == "both" then
					player:AddNullCostume(costume_bothBonus)
				elseif data.CostumeState == "angel" then
					player:AddNullCostume(costume_angelBonus)
				elseif data.CostumeState == "devil" then
					player:AddNullCostume(costume_devilBonus)					
				end
			end			
		end	
	else
		if data.PlayerMatched then
			data.PlayerMatched = false
			player:TryRemoveNullCostume(costume_devilBonus)
			player:TryRemoveNullCostume(costume_angelBonus)
			player:TryRemoveNullCostume(costume_bothBonus)
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Bisaac_Costume)

--记录初始化
local function TryInit()
	if not IBS_Data.GameState.Temp.BenightedIsaac then
		IBS_Data.GameState.Temp.BenightedIsaac = {["BonusMode"] = "none"}
	end
end

--查看记录
local function Check(key)
	TryInit()
	return IBS_Data.GameState.Temp.BenightedIsaac[key]
end

--更改记录
local function Change(key, value)
	TryInit()
	IBS_Data.GameState.Temp.BenightedIsaac[key] = value
end


--检测房门
local function IsDAOpen()
	local devil = false
	local angel = false

	local room = Game():GetRoom()
	local level = Game():GetLevel()
	for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door ~= nil then
			local idx = door.TargetRoomIndex
			local data = level:GetRoomByIdx(idx).Data
			if data then
				if (data.Type == RoomType.ROOM_DEVIL) then	
					devil = true
				end
				if (data.Type == RoomType.ROOM_ANGEL) then	
					angel = true
				end
			end
		end
	end
	
	return devil,angel
end

--二元性
local function Duality()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(498) then
			return true
		end
	end

	return false
end

--击败Boss后检测房门
local function AfterBoss()
	if not (Game():IsGreedMode()) then --非贪婪
		local bossRoom = Game():GetRoom():GetType() == RoomType.ROOM_BOSS
		if bossRoom then
			for i = 0, Game():GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				if player:GetPlayerType() == (IBS_Player.bisaac) then
					local devil,angel = IsDAOpen()
					if Check("BonusMode") == "none" then
						if Duality() then --二元性
							Change("BonusMode", "both")
							break
						end					
						if devil and angel then
							Change("BonusMode", "both")
						elseif devil then
							Change("BonusMode", "angel")
						elseif angel then
							Change("BonusMode", "devil")
						end	
					end
				end
			end
		end	
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, AfterBoss)

--贪婪模式完成额外波次后检测房门
local function AfterDealWave(_,state)
	if state == 3 then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == (IBS_Player.bisaac) then
				local devil,angel = IsDAOpen()
				if Check("BonusMode") == "none" then
					if Duality() then
						Change("BonusMode", "both")
						break
					end
					if devil and angel then
						Change("BonusMode", "both")
					elseif devil then
						Change("BonusMode", "angel")
					elseif angel then
						Change("BonusMode", "devil")
					end
				end
			end
		end
	end	
end
mod:AddCallback(IBS_Callback.GREED_WAVE_END_STATE, AfterDealWave)


--触发天使奖励时房间内至少有一个道具,恶魔则为两个
local function TryCompensation(num, isDevil)
	local total = 0
	
	for _,item in pairs(Isaac.FindByType(5, 100)) do
		if item.SubType ~= 0 then
			total = total + 1	
		end
	end
	
	if total < num then
		for i = 1,(num - total) do
			local pool = Pools:GetRoomPool(IBS_RNG:Next())
			local id = Game():GetItemPool():GetCollectible(pool, true, IBS_RNG:Next())
			local pos = Game():GetRoom():FindFreePickupSpawnPosition((Game():GetRoom():GetCenterPos()), 0, true)
			local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()

			if isDevil then
				item.ShopItemId = -2
				item.Price = -1
			end
		end
	end	
end

--长子权
local function BirthRight(player)
	if Game():GetRoom():IsFirstVisit() and player:HasCollectible(619) then
		player:UseCard(81, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	end
end

--尝试奖励
local function EnterDARoom()
	local roomType = Game():GetRoom():GetType()
	local devilRoom = roomType == RoomType.ROOM_DEVIL
	local angelRoom = roomType == RoomType.ROOM_ANGEL

	if devilRoom or angelRoom then
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == (IBS_Player.bisaac) then
				local bothBonus = Check("BonusMode") == "both"
				local devilBonus = Check("BonusMode") == "devil"
				local angelBonus = Check("BonusMode") == "angel"
				
					if devilRoom then
						BirthRight(player)
						if devilBonus or bothBonus then
							TryCompensation(2, true)
							player:UseCard(81, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
							sfx:Play(IBS_Sound.devilbonus, 0.7)
							Change("BonusMode", "none")
							if devilBonus then
								Change("LastBonus", "devil")
							elseif bothBonus then
								Change("LastBonus", "both")
							end
						end
						if angelBonus then
							Change("BonusMode", "none")
						end
					end
					if angelRoom then
						BirthRight(player)
						if angelBonus or bothBonus then
							TryCompensation(1, false)
							player:UseCard(81, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
							sfx:Play(IBS_Sound.angelbonus)
							Change("BonusMode", "none")
							if angelBonus then
								Change("LastBonus", "angel")
							elseif bothBonus then
								Change("LastBonus", "both")
							end
						end	
						if devilBonus then
							Change("BonusMode", "none")
						end	
					end
					
					--移除烟雾特效
					local poof = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01)
					for i = 1, #poof do
						poof[i]:Remove()
					end
				break
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EnterDARoom)

--调整房率
local function EvaluateADChance()
	local level = Game():GetLevel()
	for i = 0, Game():GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == (IBS_Player.bisaac) then
			if Check("BonusMode") == "devil" then
				Game():AddDevilRoomDeal()
				level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED,true)
				level:SetStateFlag(LevelStateFlag.STATE_SHOPKEEPER_KILLED_LVL,true)
			end
			if Check("BonusMode") == "angel" then
				Game():GetLevel():AddAngelRoomChance(1)
				level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED,true)
				level:SetStateFlag(LevelStateFlag.STATE_SHOPKEEPER_KILLED_LVL,true)
			end
			if Check("BonusMode") == "both" then
				level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED,true)
				level:SetStateFlag(LevelStateFlag.STATE_SHOPKEEPER_KILLED_LVL,true)
			end
			break
		end
	end	
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, EvaluateADChance)

--长子权飞行
local function Fly(_,player, flag)
	if player:GetPlayerType() == (IBS_Player.bisaac) then
		if player:HasCollectible(619) then	
			if flag == CacheFlag.CACHE_FLYING then
				player.CanFly = true
			end	
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Fly)

--翅膀装饰
local function FlyCostume(_,player)
	local effect = player:GetEffects()
	
	if player:GetPlayerType() == (IBS_Player.bisaac) then
		if player:HasCollectible(619) then	
			if not effect:HasCollectibleEffect(179) then
				effect:AddCollectibleEffect(179, true)
			end	
		end
	end	
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, FlyCostume)