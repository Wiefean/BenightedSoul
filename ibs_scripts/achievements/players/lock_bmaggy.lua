--解锁昧化抹大拉

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Class.CharacterLock

local game = Game()
local sfx = SFXManager()
local music = MusicManager()

local BMaggy = CharacterLock(mod.IBS_PlayerID.BMaggy, {'bmaggy_unlock', 'bc2'} )

--献祭房踩刺判定
function BMaggy:OnTakeDMG(ent, amount, flag, source)
	if self:IsUnlocked() then return end
	if game:GetRoom():GetType() ~= RoomType.ROOM_SACRIFICE then return end
	local player = ent:ToPlayer()
	
	if player and not game:AchievementUnlocksDisallowed() then
		if (flag & DamageFlag.DAMAGE_NO_PENALTIES > 0) and (flag & DamageFlag.DAMAGE_SPIKES > 0) then
			local playerType = player:GetPlayerType()
			local data = self:GetIBSData('level')
			data.SpikeForBMaggy = true
		end
	end	
end
BMaggy:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 'OnTakeDMG')


--生成
local function Spawn(T, V, S, grid)
	local room = game:GetRoom()
	local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(grid), 0, true)
	return Isaac.Spawn(T, V, S, pos, Vector.Zero, nil)
end

--七宗罪列表
local SinList = {
	'Sloth',
	'Lust',
	'Wrath',
	'Gluttony',
	'Greed',
	'Envy',
	'Pride'
}

--七宗罪突袭
function BMaggy:SinAmbush()
	local persisData = self:GetIBSData('persis')
	local sin = 'Sloth'
	local typ = 45
	local variant = 0

	--不重复出已经打过的
	for _,v in ipairs(SinList) do
		typ = typ + 1
		if not persisData['maggy'..v] then
			sin = v
			break
		end
	end

	for _,grid in ipairs({66, 68}) do
		local ent = Spawn(typ, variant, 0, grid)
		ent.MaxHitPoints = ent.MaxHitPoints * 2
		ent.HitPoints = ent.HitPoints * 2
		variant = 1
	end

	--主教
	-- for _,grid in ipairs({16, 28, 106, 118}) do
		-- local bishop = Spawn(805, 0, 0, grid)
		-- bishop.MaxHitPoints = bishop.MaxHitPoints * 2
		-- bishop.HitPoints = bishop.HitPoints * 2
	-- end

	game:GetRoom():SetClear(false)
	self:GetIBSData('level').FightForBMaggy = sin
	self:DelayFunction(function() music:Crossfade(Music.MUSIC_CHALLENGE_FIGHT, 1) end, 1)
end

--抹大拉进入献祭房判定
function BMaggy:OnNewRoom()
	if self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local room = game:GetRoom()
		local data = self:GetIBSData('level')
		
		if not (data.SpikeForBMaggy or data.FightForBMaggy) and room:GetType() == RoomType.ROOM_SACRIFICE and not room:IsFirstVisit() then
			local maggy = false
			-- local piece1 = false --钥匙碎片1
			-- local piece2 = false --钥匙碎片2
		
			for i = 0, game:GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				local playerType = player:GetPlayerType()
				if (playerType == PlayerType.PLAYER_MAGDALENE) or (playerType == PlayerType.PLAYER_MAGDALENE_B) then
					maggy = true
				end
				-- if player:HasCollectible(238, true) then
					-- piece1 = true
				-- end
				-- if player:HasCollectible(239, true) then
					-- piece2 = true
				-- end
			end

			if maggy then
				self:SinAmbush()
				sfx:Play(mod.IBS_Sound.SecretFound, 1.5)
			end
		end
	end
end
BMaggy:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--清理房间判定
function BMaggy:OnRoomCleaned()
	if self:IsLocked() and not game:AchievementUnlocksDisallowed() then
		local room = game:GetRoom()
		local data = self:GetIBSData('level')
		local persisData = self:GetIBSData('persis')
		
		if data.FightForBMaggy and room:GetType() == RoomType.ROOM_SACRIFICE then
			persisData['maggy'..(data.FightForBMaggy)] = true
			self:GetIBSData('temp').GenerateSacrificeRoomForBMaggy = true

			if music:GetCurrentMusicID() == Music.MUSIC_CHALLENGE_FIGHT then
				music:Crossfade(Music.MUSIC_BOSS_OVER, 0.01)
			end

			do --尝试解锁
				local canUnlock = true
				for _,sin in pairs(SinList) do
					if not persisData['maggy'..sin] then
						canUnlock = false
						break
					end
				end
				if canUnlock then
					for _,sin in pairs(SinList) do
						persisData['maggy'..sin] = false
					end
					self:Unlock(true, true)
				end
			end
		end
	end	
end
BMaggy:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

--尝试生成献祭房
function BMaggy:TryGenerateSacrificeRoom()
	local level = game:GetLevel()
	if level:GetStage() == 1 then return end
	if self:GetIBSData('temp').GenerateSacrificeRoomForBMaggy == nil then return end

	--没有献祭房时才会生成
	for _,roomDesc in pairs(self._Levels:GetRooms()) do
		local roomData = roomDesc.Data
		if roomData and roomData.Type == RoomType.ROOM_SACRIFICE then
			return
		end
	end

	local seed = level:GetDungeonPlacementSeed()
	local roomData = self._Levels:CreateRoomData{
		Seed = seed,
		Type = RoomType.ROOM_SACRIFICE,
	}
	if roomData then
		for _,gridIndex in pairs(level:FindValidRoomPlacementLocations(roomData)) do
			local secretNeighbor = false
			local normalNeighbor = false
			
			--相邻房间有隐藏房时需要再相邻一个普通房间
			for _,neighborDesc in pairs(level:GetNeighboringRooms(gridIndex, 1)) do
				local neighborType = (neighborDesc.Data and neighborDesc.Data.Type) or -1
				if neighborType == 1 then
					normalNeighbor = true
				end
				if neighborType == 7 or neighborType == 8 or neighborType == 29 then
					secretNeighbor = true
				end
			end
			
			--在隔壁生成普通房间,以求尽量有路走
			if secretNeighbor and not normalNeighbor then
				local stbType = Isaac.GetCurrentStageConfigId()
				local normalData = self._Levels:CreateRoomData{
					Seed = seed,
					Type = 1,
					StbType = stbType,
				}
				for _,offset in pairs{1, -1, 13, -13} do
					if level:TryPlaceRoom(normalData, gridIndex + offset, -1, seed, true, true) then
						break
					end
				end
			end
			
			if level:TryPlaceRoom(roomData, gridIndex, -1, seed) then
				break
			end
		end
	end
end
BMaggy:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'TryGenerateSacrificeRoom')

--移除献祭房刺
function BMaggy:OnSpikeUpdate(spike)
	if self:GetIBSData('temp').GenerateSacrificeRoomForBMaggy and not self:GetIBSData('level').SpikeForBMaggy and not game:GetRoom():IsFirstVisit() then
		if spike.State ~= 1 then
			spike.State = 1
			spike:GetSprite():Play('Unsummon')
		end
	end
end
BMaggy:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPIKES_UPDATE, 'OnSpikeUpdate')



return BMaggy