--分子植物

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local Molekale = mod.IBS_Class.Item(mod.IBS_ItemID.Molekale)

Molekale.Name = {
	zh = '分子植物',
	en = 'Molekale'
}

--文本信息
Molekale.Texts = {
	zh = {
		'积累',
		'视财如命',
		'血腥复仇',
		'忍耐',
		'跟你爆了',
	},
	en = {
		'Accumulation',
		'Money is life',
		'Bloody revenge',
		'Endurance',
		'Eruption',
	},
}

--获取数据
function Molekale:GetData(player)
	local data = self._Players:GetData(player)
	data.Molekale = data.Molekale or {
		LastItem = 0,
		Quality = 0,
		EnemyKilled = 0,
		CoinPicked = 0,
		ShootingTime = 0,
	}
	return data.Molekale
end

--获取上一个道具的品质
function Molekale:GetQuality(player)
	local id = self:GetData(player).LastItem
	if id > 0 then
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig.Quality then
			return itemConfig.Quality
		end
	end
	return 0
end

--根据最高品质决定效果
function Molekale:OnGainItem(item, charge, first, slot, varData, player)
	if slot > 1 then return end
	if item == self.ID then
		local quality = self:GetQuality(player)
		self:GetData(player).Quality = quality
		if quality < 0 then quality = 0 end
		if quality > 4 then quality = 4 end
		local LANG = mod.Language
		local desc = self.Texts[LANG][quality+1] or ''
		game:GetHUD():ShowItemText(self.Name[LANG] or '', desc)
		sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
	elseif item > 0 then
		self:GetData(player).LastItem = item
	end
	
	--0级效果,生成炸弹和钥匙
	if first and player:HasCollectible(self.ID) and self:GetData(player).Quality <= 0 then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 40, 1, pos, Vector.Zero, nil)
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 30, 1, pos, Vector.Zero, nil)		
	end
end
Molekale:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')

---1级效果,杀敌给钱
function Molekale:OnEntityKilled(ent)
	if not ent:IsEnemy() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local data = self:GetData(player)
			if data.Quality == 1 then
				data.EnemyKilled = data.EnemyKilled + 1
				if data.EnemyKilled >= 6 then
					Isaac.Spawn(5, 20, 1, ent.Position, RandomVector(), nil)
					data.EnemyKilled = data.EnemyKilled - 6
				end
			end
		end
	end		
end
Molekale:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

---1级效果,捡钱回血
function Molekale:OnCoinCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:HasCollectible(self.ID) and self._Pickups:CanCollect(pickup, player) then
		local data = self:GetData(player)
		if data.Quality == 1 then
			data.CoinPicked = data.CoinPicked + 1
			if data.CoinPicked >= 3 then
				player:AddHearts(1)
				Isaac.Spawn(1000,49,0, player.Position, Vector.Zero, nil)
				sfx:Play(SoundEffect.SOUND_VAMP_GULP)
				data.CoinPicked = data.CoinPicked - 3
			end
		end
	end	
end
Molekale:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnCoinCollision', PickupVariant.PICKUP_COIN)

--2级效果,受伤生成血团宝宝
function Molekale:OnTakeDMG(ent, dmg)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()
	if not player or not player:HasCollectible(self.ID) then return end
	if self:GetData(player).Quality == 2 then
		local familiar = Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, 0, player.Position, RandomVector(), player):ToFamiliar()
		familiar.Player = player
	end
end
Molekale:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 200, 'OnTakeDMG')

--2级效果,进入新Boss房生成血团宝宝
function Molekale:OnNewRoom()
	local room = game:GetRoom()
	if room:GetType() ~= RoomType.ROOM_BOSS	or not room:IsFirstVisit() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) and self:GetData(player).Quality == 2 then
			local familiar = Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, 0, player.Position, RandomVector(), player):ToFamiliar()
			familiar.Player = player
		end
	end	
end
Molekale:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--3级效果,切换房间时无敌5秒
function Molekale:OnNewRoom2()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) and self:GetData(player).Quality == 3 then
			player:SetMinDamageCooldown(300)
		end
	end	
end
Molekale:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom2')

--4级效果,使附近敌人获得硫磺诅咒,每攻击6秒生成悬浮硫磺火
function Molekale:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	local data = self:GetData(player)
	if data.Quality < 4 then return end

	
	--发射硫磺火
	if player:IsFrame(2,0) and self._Players:IsShooting(player) then
		data.ShootingTime = data.ShootingTime + 1
		local delay = math.ceil(8 * player.MaxFireDelay)
		if data.ShootingTime >= delay then
			local laser = player:FireBrimstone(player.Position, player)
			laser:AddTearFlags(TearFlags.TEAR_WAIT | TearFlags.TEAR_HOMING)
			laser:SetHomingType(1)
			laser.AngleDegrees = self._Players:GetAimingVector(player):GetAngleDegrees()
			data.ShootingTime = math.max(0, data.ShootingTime - delay)
		end
	end
	
	--硫磺诅咒
	if not player:IsFrame(15,0) then return end
	for _,target in pairs(Isaac.FindInRadius(player.Position, 160, EntityPartition.ENEMY)) do
		if self._Ents:IsEnemy(target) then				
			target:SetBossStatusEffectCooldown(0)
			if target:GetBrimstoneMarkCountdown() < 20 then
				target:AddBrimstoneMark(EntityRef(player), 20)
				target:SetBrimstoneMarkCountdown(20)
			end
		end
	end	
end
Molekale:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)



return Molekale