--昧化夏娃

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local CharacterLock = mod.IBS_Achiev.CharacterLock
local IronHeart = mod.IBS_Class.IronHeart()
local ShockWave = mod.IBS_Effect.ShockWave

local game = Game()
local sfx = SFXManager()

local BEve = mod.IBS_Class.Character(mod.IBS_PlayerID.BEve, {
	BossIntroName = 'bmaggy',
	PocketActive = mod.IBS_ItemID.GlowingHeart,
})

--初始信息
local InitInfo = {
	MaxCharge = 150
}

--七宗罪击杀达标提示
BMaggy.SinText = {
	Sloth = {
		zh = {"懒惰", "震荡波追踪 !"},
		en = {"Sloth", "Homing Shockwave !"},
		Threshold = 3,
	},
	Lust = {
		zh = {"色欲", "震荡波加速 !"},
		en = {"Lust", "Shockwave speed up!"},
		Threshold = 1,
	},
	Wrath = {
		zh = {"愤怒", "震荡波快充 !"},
		en = {"Wrath", "Shockwave fast charge!"},
		Threshold = 4,
	},
	Gluttony = {
		zh = {"暴食", "更大的震荡波 !"},
		en = {"Gluttony", "Bigger shockwave!"},
		Threshold = 3,
	},
	Greed = {
		zh = {"贪婪", "震荡波恢复提升 !"},
		en = {"Greed", "Shockwave recovers more!"},
		Threshold = 4,
	},
	Envy = {
		zh = {"嫉妒", "震荡波分裂 !"},
		en = {"Envy", "Shockwave spilt!"},
		Threshold = 2,
	},
	Pride = {
		zh = {"傲慢", "震荡波更远 !"},
		en = {"Pride", "Longer Shockwave!"},
		Threshold = 2,
	},
}

--临时数据
function BMaggy:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	
	if not data.BMAGGY then
		data.BMAGGY = {
			Charge = 0
		}
		
		--充能条
		local bar = Sprite('gfx/ibs/ui/chargebar_ironheart.anm2')
		bar:SetFrame("Disappear", 99)

		data.BMAGGY.ChargeBar = bar
	end
	
	return data.BMAGGY
end

--七宗罪击杀数据
function BMaggy:GetSinData()
	local data = self:GetIBSData("temp")
	
	if not data.BMAGGY_SIN then
		data.BMAGGY_SIN = {
			Sloth = 0,
			Lust = 0,
			Wrath = 0,
			Gluttony = 0,
			Greed = 0,
			Envy = 0,
			Pride = 0,
			
			SlothTriggered = false,
			LustTriggered = false,
			WrathTriggered = false,
			GluttonyTriggered = false,
			GreedTriggered = false,
			EnvyTriggered = false,
			PrideTriggered = false,
		}
	end
	
	return data.BMAGGY_SIN
end

--显示提示
local function TryShowSinText(KEY)
	local tbl = BMaggy.SinText[KEY]; if not tbl then return end
	local text = BMaggy.SinText[KEY][mod.Language]
	local KEY2 = KEY.."Triggered"
	local sinData = BMaggy:GetSinData()
	if not sinData[KEY2] and sinData[KEY] >= tbl.Threshold then	
		sinData[KEY2] = true
		game:GetHUD():ShowItemText(text[1], text[2])
		sfx:Play(132)
	end
end

--获取每帧蓄力量
function BMaggy:GetFrameCharge(playerFireDelay)
	local standard = (30/11) --约为初始射速
	local tears = 30 / (playerFireDelay + 1)
	local charge = (tears/standard)
	
	--愤怒达4加速充能
	local sinData = self:GetSinData()
	if sinData.Wrath >= 4 then
		charge = charge + 0.7
	end
	
	return math.max(0.75, charge)
end 

--变身
function BMaggy:Benighted(player, fromMenu)
	if CharacterLock.BMaggy:IsLocked() then return end

	local CAN = false 

	--检测美心
	for slot = 0,1 do
		if player:GetActiveItem(slot) == 45 then
			player:RemoveCollectible(45, true, slot)
			CAN = true
			break
		end	
	end
	if player:GetActiveItem(2) == 45 then CAN = true end
	
	if CAN or fromMenu then
		player:ChangePlayerType(self.ID)
		player:AddMaxHearts(-8)
		player:AddSoulHearts(4)
		player:AddBrokenHearts(4)
		player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
		
		local itemPool = game:GetItemPool()
		local pill = itemPool:GetPillColor(5)
		if pill > 0 then		
			game:GetItemPool():UnidentifyPill(pill)
		end

		IronHeart:Apply(player, 7)
		

		--我释放震荡波
		local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, player.Position, Vector.Zero, player):ToEffect()
		wave.Parent = player
		wave:SetTimeout(15)
		wave:SetRadii(0,120)
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)				
		poof.SpriteScale = Vector(1.5,1.5)
		poof.Color = Color(0.5,0.5,0.5)
		player:SetMinDamageCooldown(120)
		
		if fromMenu then
			for slot = 0,3 do
				if player:GetPill(slot) ~= 0 then
					player:RemovePocketItem(slot)
				end
			end
		else
			game:ShakeScreen(40)
			sfx:Play(SoundEffect.SOUND_BLACK_POOF, 4)
		end
	end
end
BMaggy:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_MAGDALENE)

--检查铁心
function BMaggy:CheckIronHeart(player)
	if player:GetPlayerType() == self.ID then
		return true
	end
end
BMaggy:AddCallback(mod.IBS_CallbackID.CHECK_IRON_HEART, 'CheckIronHeart')

--心数限制
function BMaggy:HeartLimit(player, limit)
	return math.max(2, limit - 10)
end
BMaggy:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, 'HeartLimit', BMaggy.ID)

--角色更新
function BMaggy:OnPlayerUpDate(player)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetTempData(player)
	
	--蓄力
	if self._Players:IsShooting(player) and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		data.Charge = data.Charge + self:GetFrameCharge(player.MaxFireDelay)
	else
		data.Charge = math.max(data.Charge - 1.5, 0)
	end
	
	if data.Charge >= InitInfo.MaxCharge then
		local sinData = self:GetSinData()
		local vec = self._Players:GetAimingVector(player)
		local dir = self._Maths:VectorToDirection(vec)
		local offset = vec:Resized(35)		
		
		local tearFlags = player.TearFlags
		local dmg = 3.5 + 2 * player.Damage
		local spreadNum = math.max(1, math.floor(player.TearRange / 40 - 2)) --传播次数
		local spreadTimeout = math.ceil(math.max(0, 9 - 3 * player.ShotSpeed)) --传播计时	
		local scale = math.max(0.5, player.SpriteScale.X, player.SpriteScale.Y)
		if scale > 7 then scale = 7 end
		
		--突眼增大初始体型和伤害
		if player:HasCollectible(261) then
			scale = scale + 0.4
			dmg = dmg * 3
		end
		
		--懒惰达3则追踪
		if sinData.Sloth >= 3 then
			tearFlags = tearFlags | TearFlags.TEAR_HOMING
		end
		
		--色欲达1则加速
		if sinData.Lust >= 1 then		
			spreadTimeout = math.max(0, spreadTimeout - 2)
		end
		
		--暴食达3则增加体型
		if sinData.Gluttony >= 3 then
			scale = scale + 0.2
		end		
		
		--嫉妒达2则分裂
		if sinData.Envy >= 2 then
			tearFlags = tearFlags | TearFlags.TEAR_SPLIT
		end
		
		--傲慢达2则增加传播次数
		if sinData.Pride >= 2 then		
			spreadNum = spreadNum + 4
		end
		
		for i = 0,player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() - 1 do
			local angle = i * math.random(7,14)
			ShockWave:Spawn(player.Position + offset, player, 0, dmg, tearFlags, scale, vec:Rotated(angle*(-1)^i), spreadNum, spreadTimeout, "BMaggy")
		end
		
		--烟雾
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position + offset, Vector.Zero, player)				
		poof.SpriteScale = Vector(0.5*scale,0.5*scale)
		poof.Color = Color(0.5,0.5,0.5)
		sfx:Play(SoundEffect.SOUND_BLACK_POOF, 0.5)
		game:ShakeScreen(7)
		
		data.Charge = 0 
	end	
end
BMaggy:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpDate', 0)

--渲染
function BMaggy:OnPlayerRender(player, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetTempData(player)

	if data.Charge > 10 then
		data.ChargeBar:SetFrame("Charging", math.floor(100*(data.Charge)/InitInfo.MaxCharge))
	else
		data.ChargeBar:Play("Disappear")
		if not game:IsPaused() then
			data.ChargeBar:Update()
		end
	end
	
	local pos = self._Screens:GetEntityRenderPosition(player, Vector(-12,-39) + offset)
	data.ChargeBar:Render(pos)
end
BMaggy:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerRender', 0)


--记录七宗罪击杀数(不算嫉妒的分裂状态)
function BMaggy:OnNpcDeath(npc)
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	local Variant = npc.Variant; if Variant ~= 0 and Variant ~= 1 then return end
	local Type = npc.Type
	local sinData = self:GetSinData()
	local KEY = ""
	local num = 0

	if npc.Type == 46 then
		KEY = "Sloth"
	end
	if npc.Type == 47 then
		KEY = "Lust"
	end
	if npc.Type == 48 then
		KEY = "Wrath"
	end
	if npc.Type == 49 then
		KEY = "Gluttony"
	end
	if npc.Type == 50 then
		KEY = "Greed"
	end
	if npc.Type == 51 then
		KEY = "Envy"
	end
	if npc.Type == 52 then
		KEY = "Pride"
	end
	
	if KEY ~= "" then
		num = (Variant == 1 and 2) or 1 --超级版算两次
		sinData[KEY] = sinData[KEY] or 0
		sinData[KEY] = sinData[KEY] + num
		TryShowSinText(KEY)
	end
end
BMaggy:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath')

--替换房间
function BMaggy:ReplaceRooms(roomSlot, roomData, seed)
	if not PlayerManager.AnyoneIsPlayerType(self.ID) then return end
	local roomType = roomData.Type

	--献祭房替换为小头目房
	if roomType == RoomType.ROOM_SACRIFICE then
		local newData = self._Levels:CreateRoomData{
			Seed = seed,
			Type = RoomType.ROOM_MINIBOSS,
			Shape = roomSlot:Shape(),
			Doors = roomSlot:DoorMask()
		}
		if newData then
			return newData
		end
	end
end
BMaggy:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, -700, 'ReplaceRooms')

return BMaggy