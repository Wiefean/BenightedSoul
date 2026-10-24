--昧化亚玻伦(目前为亚波人)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local CharacterLock = mod.IBS_Achiev.CharacterLock
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()
local mus = MusicManager()
local music = Isaac.GetMusicIdByName('神秘2')
local music_boss = Isaac.GetMusicIdByName('神秘2Boss')

local BApollyon = mod.IBS_Class.Character(mod.IBS_PlayerID.BApollyon, {
	BossIntroName = 'bapollyon',
	PocketActive = 477,
	HiddenItems = {571},
})

--精神错乱加强
do

--获取数据
function BApollyon:Delirium_GetData()
	local data = self:GetIBSData('room')
	data.BApollyon_WTF_Delirium = data.BApollyon_WTF_Delirium or {
		Phase = 1,
		CD = 150,
	}
	return data.BApollyon_WTF_Delirium
end

function BApollyon:Delirium_OnGameUpdate()
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	local room = game:GetRoom()
	if room:GetBossID() ~= BossType.DELIRIUM or room:IsClear() then return end
	local data = self:Delirium_GetData()

	--切换二阶段检测
	if data.Phase <= 1 then
		for _,ent in ipairs(Isaac.FindByType(412, 0, 0)) do
			if ent.HitPoints <= 0.5 * ent.MaxHitPoints then
				data.Phase = 2
				for _,ent2 in ipairs(Isaac.FindByType(68, 1)) do
					ent2:Die()
				end
				for _,ent in ipairs(Isaac.FindByType(241,0,0)) do				
					ent:Die()
				end
				for _,ent in ipairs(Isaac.FindByType(241,1,0)) do				
					ent:Die()
				end				
				
				--嵌体怪
				local ent3 = Isaac.Spawn(910, 0, 0, room:GetCenterPos(), 40 * RandomVector(), nil)
				ent3.MaxHitPoints = ent3.MaxHitPoints * 10
				ent3.HitPoints = ent3.MaxHitPoints
				
				--教条
				local ent4 = Isaac.Spawn(950, 0, 0, room:GetCenterPos(), Vector.Zero, nil)
				-- ent4.MaxHitPoints = ent4.MaxHitPoints * 10
				-- ent4.HitPoints = ent4.MaxHitPoints		
				
				break
			end
		end	
	end

	--一阶段
	if data.Phase <= 1 then
		if #Isaac.FindByType(68,1) <= 0 then
			if data.CD > 0 then
				data.CD = data.CD - 1
				
				--爬墙硫磺火
				for _,ent in ipairs(Isaac.FindByType(241,0,0)) do				
					ent:Die()
				end
				
				--爬墙硫磺火2
				for _,ent in ipairs(Isaac.FindByType(241,1,0)) do				
					ent:Die()
				end
			else
				data.CD = 150
				
				--充血怪			
				local ent = Isaac.Spawn(68, 1, 0, room:GetCenterPos(), 20 * RandomVector(), nil)
				ent.MaxHitPoints = 9999
				ent.HitPoints = 9999
				
				--爬墙硫磺火
				if #Isaac.FindByType(241,0,0) <= 0 then				
					for i = 1,16 do				
						local ent = Isaac.Spawn(241, 0, 0, room:GetRandomPosition(40), 20 * RandomVector(), nil)
						ent.MaxHitPoints = 999
						ent.HitPoints = 999
					end
				end
				
				--爬墙硫磺火2
				if #Isaac.FindByType(241,1,0) <= 0 then				
					for i = 1,16 do				
						local ent = Isaac.Spawn(241, 1, 0, room:GetRandomPosition(40), 20 * RandomVector(), nil)
						ent.MaxHitPoints = 999
						ent.HitPoints = 999
					end				
				end
			end
		end
	end
	
	if data.Phase ~= 2 then
		--切换背景
		if room:GetFrameCount() % 99 ~= 0 then return end
		if room:GetBossID() == BossType.DELIRIUM and not room:IsClear()
			and room:GetBackdrop():GetFloorANM2():GetFilename() == 'gfx/backdrop/effect_error.anm2'
		then
			game:ShowHallucination(30, math.random(1,17))
		end	
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_UPDATE, "Delirium_OnGameUpdate")

--更新
local LOCKED = false
function BApollyon:Delirium_OnNPCUpdate(npc)
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	local room = game:GetRoom()
	if room:GetBossID() ~= BossType.DELIRIUM then return end

	--精神错乱一阶段
	if npc.Type == 412 and npc.Variant == 0 and npc.SubType == 0
		and self:Delirium_GetData().Phase <= 1
		and npc.HitPoints < npc.MaxHitPoints
	then
		npc.HitPoints = math.min(npc.MaxHitPoints, npc.HitPoints + 1)
	end	

	--精神错乱三阶段
	if npc.Type == 412 and npc.Variant == 0 and npc.SubType == 0
		and self:Delirium_GetData().Phase >= 3
		and npc.HitPoints > 100
	then
		if not LOCKED then
			LOCKED = true
			npc:Update()
		end
		LOCKED = false
	end	

	--教条一阶段电视
	if npc.Type == 950 and npc.Variant == 1 and npc.SubType == 0 then
		if npc.FrameCount == 1 then
			npc.MaxHitPoints = npc.MaxHitPoints * 10
			npc.HitPoints = npc.MaxHitPoints
		end
	end

	--教条二阶段
	if npc.Type == 950 and npc.Variant == 2 and npc.SubType == 0 then
		if not self._Ents:GetTempData(npc).BApollyon_WTF_DOGMA then
			npc.MaxHitPoints = npc.MaxHitPoints * 10
			npc.HitPoints = npc.MaxHitPoints
			self._Ents:GetTempData(npc).BApollyon_WTF_DOGMA = true
		end
		
		--回血
		npc.HitPoints = math.min(npc.MaxHitPoints, npc.HitPoints + 0.0003 * npc.MaxHitPoints)
		
		if npc.HitPoints <= 1 then
			npc:Remove()
		end
	end
end
BApollyon:AddCallback(ModCallbacks.MC_NPC_UPDATE, "Delirium_OnNPCUpdate")

--减伤
function BApollyon:Delirium_OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	local room = game:GetRoom()
	if room:GetBossID() ~= BossType.DELIRIUM or room:IsClear() then return end
	if self._Ents:IsEnemy(ent, true) then	
	
		--精神错乱二阶段锁血
		--切换三阶段检测
		if ent.Type == 412 and self:Delirium_GetData().Phase == 2 then
			if #Isaac.FindByType(910) > 0 or #Isaac.FindByType(950) > 0 then
				if ent.HitPoints - dmg < 0.5 * ent.MaxHitPoints then				
					ent.HitPoints = 0.5 * ent.MaxHitPoints
					return {Damage = 0}
				end
			else
				self:Delirium_GetData().Phase = 3
				ent.HitPoints = 0.25 * ent.MaxHitPoints
				
				local player = Isaac.GetPlayer(0)
				player:TakeDamage(999, DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(ent), 0)
				local bomb = Isaac.Spawn(4,17,0, player.Position, Vector.Zero, nil):ToBomb()
				bomb:SetExplosionCountdown(0)
			end
		end

		--教条二阶段减伤
		if ent.Type == 950 and ent.Variant == 2 and ent.SubType == 0 then		
			ent.MaxHitPoints = math.min(2147483647, ent.MaxHitPoints + dmg)
			
			local mult = 1
			if flag & DamageFlag.DAMAGE_IGNORE_ARMOR <= 0 then
				mult = math.max(0, 0.9 - (0.01 * ent.FrameCount / 30))
			end
			
			return {Damage = dmg * mult}
		end
		
		--关闭友伤
		local target = self._Ents:GetSourceEnemy(source.Entity)
		if target ~= nil and self._Ents:IsEnemy(target) then
			return false
		end
	end
end
BApollyon:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1000, 'Delirium_OnTakeDMG')


--角色受伤判定
function BApollyon:OnTakeDMG(ent, dmg, flag, source)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()

	if player and player:GetPlayerType() == self.ID
		and Damage:IsPenalt(player, flag, source)
	then
		local room = game:GetRoom()
		if room:GetBossID() == BossType.DELIRIUM 
			and not room:IsClear()
		then
			--角色无敌帧减少
			if self:Delirium_GetData().Phase < 3 then	
				player:ResetDamageCooldown()
				player:SetMinDamageCooldown(9)
			end
		
			--三阶段受伤删道具
			if self:Delirium_GetData().Phase >= 3 then			
				local list = {}
				
				for id,num in pairs(player:GetCollectiblesList()) do
					local itemConfig = config:GetCollectible(id)
					if num > 0 and itemConfig and itemConfig.Type ~= 3 then
						table.insert(list, id)
					end
				end
				
				if #list > 0 then			
					local result = list[math.random(1,#list)] or list[1]
					if result then
						player:RemoveCollectible(result, true)
						self._Stats:PersisLuck(player, 5, true)
					end
				end
			end
		end
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

end

--显示血量(懒得重写一遍了直接借用另一个模组)
do
	local CONFIG = {
		Y_OFFSET = 25
	}

	local font = Font()
	font:Load("font/pftempestasevencondensed.fnt")

	local floatingDamages = {}

	local function onRender()
		local room = game:GetRoom()
		if room:GetBossID() ~= BossType.DELIRIUM or room:IsClear() then
			return
		end
	
		local entities = Isaac.GetRoomEntities()
		
		for _, entity in ipairs(entities) do
			if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and entity.HitPoints > 0 and entity.MaxHitPoints > 0 then
				local hp = math.ceil(entity.HitPoints)
				local maxHp = math.ceil(entity.MaxHitPoints)

				local screenPos = Isaac.WorldToScreen(entity.Position)

				local text = hp .. " / " .. maxHp
				local textWidth = font:GetStringWidth(text)
				
				local drawX = screenPos.X - (textWidth / 2)
				local drawY = screenPos.Y - entity.Size - CONFIG.Y_OFFSET
				
				font:DrawString(text, drawX, drawY, KColor(1, 1, 1, 1), 0, true)
			end
		end

		for i = #floatingDamages, 1, -1 do
			local dmg = floatingDamages[i]
			dmg.timer = dmg.timer - 1

			if dmg.timer <= 0 then
				table.remove(floatingDamages, i)
			else
				dmg.offsetY = dmg.offsetY - 0.5
				
				local screenPos = Isaac.WorldToScreen(dmg.position)
				local textWidth = font:GetStringWidth(dmg.text)
				
				local drawX = screenPos.X + dmg.offsetX - (textWidth / 2)
				local drawY = screenPos.Y + dmg.offsetY
				
				local alpha = dmg.timer / 30 
				
				font:DrawString(dmg.text, drawX, drawY, KColor(1, 0, 0, alpha), 0, true)
			end
		end
	end

	local function onDamage(_, entity, damageAmount)
		local room = game:GetRoom()
		if room:GetBossID() ~= BossType.DELIRIUM or room:IsClear() then
			return
		end	
	
		if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
			local formattedDamage = string.format("%.1f", damageAmount)
			
			table.insert(floatingDamages, {
				text = "-" .. formattedDamage,
				position = entity.Position,
				offsetX = math.random(-15, 15), 
				offsetY = -entity.Size - 10,  
				timer = 30
			})
		end
	end

	local function onNewRoom()
		floatingDamages = {}
	end

	mod:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, onDamage)
	mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)
end


--角色初始化
function BApollyon:OnPlayerInit(player)
	if player:GetPlayerType() ~= self.ID then return end

end
BApollyon:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

--尝试使用
function BApollyon:OnTryUse(slot, player)
	if player:GetPlayerType() == self.ID then
		for _,ent in ipairs(Isaac.FindByType(5,100)) do
			local pickup = ent:ToPickup()
			if pickup and pickup.SubType ~= 0 and pickup.Price == 0 then
				return 0
			end
		end	
	end
end
BApollyon:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', 477)


--虚空12充
function BApollyon:OnGetMaxCharge(item, player, varData, maxCharge)
	if player:GetPlayerType() == self.ID then
		return 12
	end
end
BApollyon:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, 'OnGetMaxCharge', 477)

--不许动
function BApollyon:Freeze(frames)
	local boss= game:GetRoom():GetBossID() == BossType.DELIRIUM
	local adapted = boss and self:Delirium_GetData().Phase >= 2

	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if (ent.Type == 950 and ent.Variant <= 2 and ent.SubType == 0) then
		
		elseif (ent.Type == 412 and adapted) then
		
		elseif (ent.Type == 68) and boss then
			ent:Die()
		elseif self._Ents:IsEnemy(ent, false, false) then
			ent:SetBossStatusEffectCooldown(0)
			ent:AddFreeze(EntityRef(nil), frames)
			ent:AddWeakness(EntityRef(nil), frames)
			
			local mult = (ent:IsBoss() and 0.01) or 0.1
			self._Ents:LoseHP(ent, ent.MaxHitPoints * mult, true)
		end
	end
end


--使用虚空
function BApollyon:OnUseItem(item, rng, player, flags, slot)
	if player:GetPlayerType() == self.ID then
		local room = game:GetRoom()
	
		--吸道具恢复充能
		for _,ent in ipairs(Isaac.FindByType(5,100)) do
			local pickup = ent:ToPickup()
			if pickup and pickup.SubType ~= 0 and pickup.Price == 0 then
				player:AddActiveCharge(24, slot, true, true)
				break
			end
		end
		
		if Isaac.CountEnemies() > 0 and player:GetBrokenHearts() < 6
			and room:GetBackdrop():GetFloorANM2():GetFilename() ~= 'gfx/backdrop/effect_error.anm2'
		then
			player:TryRemoveNullCostume(14)
			game:ShowHallucination(30, 26)
			self:Freeze(40)
			
			--同一个房间使用加碎心
			local data = self:GetIBSData('room')
			if data.BApollyonBackdrop then
				player:AddBrokenHearts(2)
				sfx:Play(53, 2)
			end
			data.BApollyonBackdrop = true

			--精神错乱直接进二阶段
			if player:GetBrokenHearts() >= 4 then
				for _,ent in ipairs(Isaac.FindByType(412, 0, 0)) do
					if ent.HitPoints > 0.5 * ent.MaxHitPoints then
						ent.HitPoints = 0.5 * ent.MaxHitPoints
					end
				end	
			end

			local id = (room:GetBossID() == BossType.DELIRIUM and not room:IsClear() and music_boss) or music
			if mus:GetCurrentMusicID() ~= id then
				mus:Play(id)
			end
		end
	end
end
BApollyon:AddCallback(ModCallbacks.MC_USE_ITEM, "OnUseItem", 477)

--游戏更新
function BApollyon:OnGameUpdate()
	if Isaac.GetFrameCount() % 31 == 0
		and game:GetRoom():GetType() ~= RoomType.ROOM_ERROR
		and game:GetRoom():GetBackdrop():GetFloorANM2():GetFilename() == 'gfx/backdrop/effect_error.anm2'
	then
		self:Freeze(40)
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_UPDATE, "OnGameUpdate")

--切换房间触发
function BApollyon:OnNewRoom()
	local boss = game:GetRoom():GetBossID() == BossType.DELIRIUM
	local pos = game:GetRoom():GetCenterPos()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			if boss then
				player:TryRemoveNullCostume(14)
			else
				player:AddNullCostume(14)
			end
		end
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, "OnNewRoom")

--神秘动静
function BApollyon:WTF(player, pos)
	local room = game:GetRoom()
	local mult = 100
	local scale = 5
	
	if room:GetBossID() == BossType.DELIRIUM and not self:Delirium_GetData().First then
		mult = 200
		scale = 6
		self:Delirium_GetData().First = true
	end
	
	game:BombExplosionEffects(pos, player.Damage * mult, 0, Color(1,0,1,1), player, 4, true, false, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR)
	room:MamaMegaExplosion(pos)
	if mus:GetCurrentMusicID() ~= music_boss and room:GetBossID() == BossType.DELIRIUM and not room:IsClear() then
		mus:Play(music_boss)
	end
end

--角色更新
function BApollyon:OnUpdate(player)
	if player:GetPlayerType() ~= self.ID then return end
		
	--念力
	local room = game:GetRoom()
	if room:GetBossID() == BossType.DELIRIUM and not room:IsClear()
		and self:Delirium_GetData().Phase >= 3
	then
		--什么都不做
	else	
		local effects = player:GetEffects()
		local effect = effects:GetCollectibleEffect(522)
		if not effect then
			effects:AddCollectibleEffect(522)
			effect = effects:GetCollectibleEffect(522)
			effect.Cooldown = 0
		end
		if effect.Cooldown < 60 then	
			effect.Cooldown = 90
		end
	end
	
	if self._Players:IsShooting(player) then
		--裂隙眼泪
		if player:IsFrame(90,0) then		
			local velocity = 10*(self._Maths:DirectionToVector(player:GetFireDirection()))
			local tear = player:FireTear(player.Position, velocity, false, true, false, player, 5)
			tear.Visible = false
			tear:AddTearFlags(TearFlags.TEAR_RIFT)
		end
		
		--击退眼泪
		if player:IsFrame(9,0) and math.random(1,100) < math.min(50, 10 + player.Luck) then
			player:AddHearts(1)
			local velocity = 30*(self._Maths:DirectionToVector(player:GetFireDirection()))
			local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 37, 0, player.Position, velocity, player):ToTear()
			local dmg = player.Damage * 10
			tear.CollisionDamage = dmg
			tear.Scale = self._Maths:TearDamageToScale(dmg)
			tear:AddTearFlags(TearFlags.TEAR_PUNCH | TearFlags.TEAR_ACID | TearFlags.TEAR_PIERCING | TearFlags.TEAR_HOMING | TearFlags.TEAR_PULSE | TearFlags.TEAR_SPECTRAL)
			self._Ents:GetTempData(tear).BApollyonWTF = true
		end			
	end
	
	--自动充能
	if game:GetRoom():GetBossID() == BossType.DELIRIUM 
		and player:IsFrame(30,0)
		and player:GetBrokenHearts() < 6
	then
		player:AddActiveCharge(1, 2)
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnUpdate', 0)


--念力修改
function BApollyon:Telekinesis(effect)
	local player = self._Ents:IsSpawnerPlayer(effect)
	if player and player:GetPlayerType() == self.ID then
		effect.Visible = false
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'Telekinesis', 123)
BApollyon:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'Telekinesis', 123)

--裂隙改色
function BApollyon:OnRiftInit(effect)
	if effect.SubType ~= 0 then return end
	local player = self._Ents:IsSpawnerPlayer(effect)
	if player and player:GetPlayerType() == self.ID then
		local color = Color(1,1,1,1)
		color:SetColorize(1,1,1,2)
		effect.Color = color
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnRiftInit', 180)

--裂隙更新
function BApollyon:OnRiftUpdate(effect)
	if effect.SubType ~= 0 then return end
	if not effect:IsFrame(4,0) then return end
	local player = self._Ents:IsSpawnerPlayer(effect)
	if player and player:GetPlayerType() == self.ID then
		local room = game:GetRoom()
		local sacrifice = room:GetType() == RoomType.ROOM_SACRIFICE
		
		--摧毁障碍物
		for gridIdx,gridEnt in pairs(self._Finds:GridEntInRadius(effect.Position, effect.Scale * 30)) do
			if not gridEnt:ToDoor() 
				and not gridEnt:ToPit() 
				and not gridEnt:ToPressurePlate()
				and (not sacrifice or not gridEnt:ToSpikes())
			then			
				gridEnt:Hurt(7)
				gridEnt:Destroy(true)
			end
		end
		
		--检测击退眼泪
		for _,ent in ipairs(Isaac.FindInRadius(effect.Position, effect.Scale * 40, EntityPartition.TEAR)) do
			if self._Ents:GetTempData(ent).BApollyonWTF then
				self:WTF(player, effect.Position)
				ent:Remove()
				effect:Remove()
				break
			end			
		end
	end
end
BApollyon:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnRiftUpdate', 180)

--免伤
function BApollyon:PrePlayerTakeDMG(player, dmg, flag, source)
	if player:GetPlayerType() == self.ID and (
		source.Entity == nil
		or flag & DamageFlag.DAMAGE_EXPLOSION > 0
		or flag & DamageFlag.DAMAGE_FIRE > 0
		or flag & DamageFlag.DAMAGE_CURSED_DOOR > 0
	) then
		local room = game:GetRoom()
		if room:GetBossID() == BossType.DELIRIUM and not room:IsClear()
			and self:Delirium_GetData().Phase >= 3
		then
			--什么都不做
		else
			return false
		end
	end
end
BApollyon:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')

--碰撞免疫
function BApollyon:PreNPCCollision(npc, other)
	if not self._Ents:IsEnemy(npc, true) then return end
	if npc.Type == 33 and npc.Variant == 4 then return end --忽略白火
    local player = other:ToPlayer()
    if player and player:GetPlayerType() == self.ID then
		return false
    end
end
BApollyon:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, 'PreNPCCollision')

function BApollyon:PrePlayerGridCollision(player)
	if player and player:GetPlayerType() == self.ID then
		return true
	end
end
BApollyon:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, 'PrePlayerGridCollision')

--敌人血量增长
do
	local cache = {}
	local function EnemyHpUp(npc)
		if not PlayerManager.AnyoneIsPlayerType(BApollyon.ID) then return end
		local key = GetPtrHash(npc) + npc.Type + npc.Variant + npc.SubType
		if npc:IsActiveEnemy(false) and not cache[key] then

			--精神错乱房间只增长一次
			local room = game:GetRoom()
			if (room:GetBossID() ~= BossType.DELIRIUM or room:GetFrameCount() < 2) then				
				local mult = (room:GetBossID() == BossType.DELIRIUM and 100) or 5
				npc.MaxHitPoints = math.ceil(npc.MaxHitPoints * mult)
				npc.HitPoints = math.ceil(npc.HitPoints * mult)
			end
			
			cache[key] = EntityPtr(npc)
		end
	end
	mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, -1000, function(_,npc)
		EnemyHpUp(npc)
	end)
	mod:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, -1000, function(_,npc)	
		EnemyHpUp(npc)
	end)
	mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, -1000, function()
		--清理缓存
		for k,v in pairs(cache) do
			local ent = v.Ref
			if ent ~= nil then
				if not ent:Exists() or ent:IsDead() then
					cache[k] = nil
				end
			else
				cache[k] = nil
			end
		end
	end)

end



return BApollyon