--架势

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_PlayerID = mod.IBS_PlayerID
local IBS_Sound = mod.IBS_Sound
local BSamson = mod.IBS_Player.BSamson
local Swing = mod.IBS_Effect.Swing
local Damage = mod.IBS_Class.Damage()

local game = Game()
local sfx = SFXManager()

local Posture = mod.IBS_Class.Item(mod.IBS_ItemID.Posture)

--加载技能
Posture.Skills = {}
for id = 1,22 do
	Posture.Skills[id] = include("ibs_scripts.samson_skills."..id)
end
for id = 56,77 do
	Posture.Skills[id] = include("ibs_scripts.samson_skills."..id)
end

--技能消耗充能
Posture.SkillCost = {}
for k,v in pairs(Posture.Skills) do
	Posture.SkillCost[k] = {
		Calm = v.CalmCost,
		Wrath = v.WrathCost,
	}
end


--获取技能
function Posture:GetSkill(id)
	return self.Skills[id]
end

--获取数据
function Posture:GetData(player)
	local data = self._Players:GetData(player)
	data.Posture = data.Posture or {
		DoingSelection = 1,
		NextSelection = 1,		
		Duration = 0,
		Damage = 0,
		FreeTimes = 0,
		ConsumedCount = 0,
		Cards = {0, 0, 0, 0, 0},
		Cards2 = {0, 0, 0, 0, 0},
	}
	return data.Posture
end

--获取兼容
local function GetCompats(player)
	local compats = {}
	local tearFlags = player.TearFlags
	local luck = player.Luck

	--高射速模式
	if (30 / (player.MaxFireDelay + 1)) >= 10 then
		compats.HIGH = true
	end

	--减速
	if tearFlags & TearFlags.TEAR_SLOW > 0
		or (player:HasCollectible(89) and math.random(1,100) < 25 + 4 * player.Luck)
	then
		compats.Slow = true
	end
	
	--中毒
	if tearFlags & TearFlags.TEAR_POISON > 0
		or player:HasCollectible(305)
		or player:HasCollectible(149)
	then
		compats.Poison = true
	end
	
	--石化
	if tearFlags & TearFlags.TEAR_FREEZE > 0
		or (player:HasCollectible(110) and math.random(1,100) < math.max(50, 20 + player.Luck))
	then
		compats.Petrify = true
	end
	
	--爆炸(没人会喜欢这个的)
	-- if tearFlags & TearFlags.TEAR_EXPLOSIVE > 0 then
		-- compats.Explode = true
	-- end
	
	--混乱
	if tearFlags & TearFlags.TEAR_CONFUSION > 0 then
		compats.Confuse = true
	else
		if (player:HasCollectible(201)
				or player:HasCollectible(637)
			) and math.random(1,100) < math.max(50, 10 + 2 * player.Luck)
		then		
			compats.Confuse = true
		end
	end		
	
	--恐惧
	if tearFlags & TearFlags.TEAR_FEAR > 0 then
		compats.Fear = true
	else
		if (player:HasCollectible(228)
				or player:HasCollectible(230)
				or player:HasCollectible(259)
			) and math.random(1,100) < 10 + player.Luck
		then		
			compats.Fear = true
		end
	end		
	
	--燃烧
	if tearFlags & TearFlags.TEAR_BURN > 0
		or player:HasCollectible(257)
	then
		compats.Burn = true
	end
	
	--标记
	if tearFlags & TearFlags.TEAR_BAIT > 0 then
		compats.Bait = true
	else
		if player:HasCollectible(618) and math.random(1,100) < 16 + 4 * player.Luck then		
			compats.Bait = true
		end
	end		
	
	--流血
	if player:HasCollectible(506) then
		compats.Bleed = true
	end

	--水果蛋糕或黏土饼干
	if (player:HasCollectible(418) or player:HasCollectible(570)) then
		local int = math.random(1,6)
		
		if int == 1 then
			compats.Slow = true
		elseif int == 2 then
			compats.Poison = true
		elseif int == 3 then
			compats.Petrify = true
		elseif int == 4 then
			compats.Confuse = true
		elseif int == 5 then
			compats.Fear = true
		elseif int == 6 then
			compats.Burn = true	
		end
	end

	--胎儿博士
	if player:HasWeaponType(WeaponType.WEAPON_BOMBS) then
		compats.DrFetus = true
	end

	--妈刀和骨棒
	for _,ent in ipairs(Isaac.FindByType(8,-1,0)) do
		local knife = ent:ToKnife()
		
		if knife and (knife.Variant ~= 4 and knife.Variant < 6) then
			local player = Posture._Ents:IsSpawnerPlayer(knife, true)
			if player then
				compats.Knife = true
				break
			end
		end
	end		
	
	--硫磺火
	if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
		compats.Brimstone = true
	end
	
	--肺
	if player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then
		compats.Lung = true
	end
	
	--英灵剑
	if player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) then
		compats.Sword = true
	end

	return compats
end

--获取角色临时数据
function Posture:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	if not data.Posture then
		local spr = Sprite('gfx/ibs/ui/items/ui_cardfronts.anm2')
		spr:SetFrame("Idle", 0)
	
		--充能条
		local bar = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar:SetFrame("Disappear", 99)
		local bar2 = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar2:SetFrame("Disappear", 99)
	
		data.Posture = {
			Selection = 1,		
			Wait = 0,
			CD = 0,
			MaxCD = 0,
			AttackDelay = 0,
			HighLight = spr,
			ChargeBar = bar,
			CDBar = bar2,
			List = {},
			List2 = {},
			Compats = GetCompats(player),
		}
	end
	return data.Posture
end

--获取兼容
function Posture:GetCompats(player)
	local data = self:GetTempData(player)
	return data.Compats
end

--设置冷却
function Posture:SetCD(player, frames)
	local data = self:GetTempData(player)
	data.MaxCD = frames or 0
	data.CD = data.MaxCD
end

--是否持有牌
function Posture:HasCard(player, id)
	if not player:HasCollectible(self.ID, true) then return end
	local data = self._Players:GetData(player).Posture

	if data then
		for _,_id in ipairs(data.Cards) do
			if _id > 0 and _id == id then
				return true
			end
		end	
		for _,_id in ipairs(data.Cards2) do
			if _id > 0 and _id == id then
				return true
			end
		end
	end
	
	return false
end

--获取牌数量
function Posture:GetCardNum(player, id)
	if not player:HasCollectible(self.ID, true) then return 0 end
	local num = 0
	local data = self._Players:GetData(player).Posture

	if data then
		for _,_id in ipairs(data.Cards) do
			if _id > 0 and _id == id then
				num = num + 1
			end
		end
		for _,_id in ipairs(data.Cards2) do
			if _id > 0 and _id == id then
				num = num + 1
			end
		end			
	end

	return num
end

--获取选中的牌
function Posture:GetCurrentCard(player)
	local data = self._Players:GetData(player).Posture
	
	if data then
		return data.Cards[data.DoingSelection] or 0
	end
	
	return 0
end


--充能
function Posture:Charge(player, slot, num)
	num = num or 1
	if player:GetActiveItem(slot) == self.ID then
		local charges = self._Players:GetSlotCharges(player, slot, true, true)
		local maxCharges = 6

		for i = 1,num do
			if charges < maxCharges then
				self._Players:ChargeSlot(player, slot, 1, true, true, true)

				--音效
				charges = charges + 1
				if charges == 3 or charges == 6 then
					sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)					
				else
					sfx:Play(SoundEffect.SOUND_BEEP)
				end
			end
		end
	end
end

--清理房间充能
function Posture:RoomCharge()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		--倒正义
		if not self:HasCard(player, 64) then		
			for slot = 0,2 do		
				self:Charge(player, slot, (self._Levels:IsInBigRoom() and 2) or 1)
			end
		end
	end	
end
Posture:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'RoomCharge')
Posture:AddCallback(IBS_CallbackID.GREED_NEW_WAVE, 'RoomCharge') --贪婪模式波次充能

--受伤充能
function Posture:HurtCharge(ent, dmg)
	local player = ent:ToPlayer()
	if player and dmg > 0 then
		for slot = 0,2 do
			self:Charge(player, slot, dmg)
		end
	end	
end
Posture:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'HurtCharge')

--获取伤害充能阈值
function Posture:GetDamageChargeThreshold()
	return 70 + 35 * game:GetLevel():GetStage() --伤害需求
end

--造成伤害充能
function Posture:DamageCharge(ent, dmg, flag, source)
	if dmg <= 0 then return end
	
	if self._Ents:IsEnemy(ent) then
		local threshold = self:GetDamageChargeThreshold()
	
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID, true) then
				local data = self:GetData(player)
				local tData = self:GetTempData(player)
				
				--冷却期间暂停伤害充能,更符合视觉直觉
				if tData.CD <= 0 then
					if data.Damage > threshold then
						data.Damage = 0
						for slot = 0,2 do
							self:Charge(player, slot, 1)
						end
					else
						--倒正义
						if self:HasCard(player, 64) then
							dmg = dmg * 2
						end
						data.Damage = data.Damage + dmg
					end
				end
			end	
		end
	end	
end
Posture:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'DamageCharge')

--切招
function Posture:Next(player)
	local data = self:GetData(player)
	local cards = data.Cards
	local cardNum = 0

	for _,v in ipairs(cards) do
		if v > 0 then
			cardNum = cardNum + 1
		end
	end

	if cardNum > 1 then
		local selection = data.DoingSelection
		for i = 1,5 do
			selection = selection + 1; if selection > 5 then selection = 1 end
		
			local id = cards[selection]
			if id and id > 0 then
				data.DoingSelection = selection
				break
			end
		end
	end

	--下一张牌预选
	if cardNum <= 1 then
		data.NextSelection = data.DoingSelection
	else
		local selection = data.DoingSelection
		
		for i = 1,5 do
			selection = selection + 1
			if selection > 5 then
				selection = 1
			end
		
			local id = cards[selection]
			if id > 0 then	
				data.NextSelection = selection
				break
			end
		end
	end
end

--是否能攻击
function Posture:CanAttack(player)
	if self:GetTempData(player).AttackDelay <= 0 then
		
		--为了不打扰goodtrip
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
			return false
		end
		
		--表表参孙暴怒
		if player:GetPlayerType() == BSamson.ID then
			return BSamson:GetState(player) == BSamson.Wrath
		end
		
		--检测持续时间
		if self:GetData(player).Duration > 0 then
			return true
		end

	end
	return false
end

--攻击
function Posture:DoAttack(player, vec, skipSetDelay, pos, dmgMult, scaleMult, followEntity)
	pos = pos or player.Position
	dmgMult = dmgMult or 1
	scaleMult = scaleMult or 1
	local compats = self:GetCompats(player)
	local skills = {}
	
	for _,id in ipairs(self:GetData(player).Cards) do
		local skill = self:GetSkill(id)
		if skill then
			table.insert(skills, skill)
		end	
	end	
	for _,id in ipairs(self:GetData(player).Cards2) do
		local skill = self:GetSkill(id)
		if skill then
			table.insert(skills, skill)
		end	
	end	
	
	--射程额外影响大小
	local scale = player.SpriteScale.X
	local percent = ((player.TearRange / 40) / 6.5) / 2
	if percent > 1 then
		scale = scale * math.min(1.5, percent)
	end

	local params = {
		AttackDelay = 3 * math.max(1, math.ceil(player.MaxFireDelay)),
		Num = player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears(),
		AngleBetween = 30,
		Size = 30,
		Distance = 30,
		Scale = scale * scaleMult,
		Damage = player.Damage * 1.5 * dmgMult,
		Color = Color(1,1,1,1),
		BounceSpeed = (compats.HIGH and 3) or 10,
		SelfBounceSpeed = (compats.HIGH and 1) or 5,
		DestroyGrid = false,
		DestroyDoor = false,
		SoundID = 252,
	}

	--不是自己攻击则没有后坐力
	if followEntity then
		SelfBounceSpeed = 0
	end

	--硫磺火
	if compats.Brimstone then
		params.Color = Color(0.6,0,0,1)
	end

	--英灵剑
	if compats.Sword then
		params.BounceSpeed = params.BounceSpeed * 0.5
		params.SelfBounceSpeed = 0
	end

	for _,skill in ipairs(skills) do
		if skill.PreAttack then
			skill.PreAttack(player, compats, params)
		end	
	end
	
	if params.Num < 1 then
		params.Num = 1
	end
	
	--足够大时可以摧毁障碍物和门
	if params.Size * scale > 44 then
		params.DestroyGrid = true
		params.DestroyDoor = true
	end	
	
	local bounceSpd = params.BounceSpeed
	local selfBounceSpd = params.SelfBounceSpeed	
	local angle = 0
	local k = 0
	for i = 0,params.Num - 1 do
		k = k + 1
		
		if k >= 2 then
			k = 0
			angle = angle + params.AngleBetween
		end

		local aimingVector = vec:Rotated(angle * (-1)^i)

		local targets, effect = Swing:DoSwing{
			Spawner = player,
			AimingVector = aimingVector,
			Position = pos,
			PositionOffsets = (followEntity and followEntity.Type == 2 and {
				Up = Vector(0,0),
				Down = Vector(0,0),
				Left = Vector(0,0),
				Right = Vector(0,0),	
			}) or nil,
			Color = params.Color,
			Size = params.Size,
			Distance = params.Distance,
			Scale = params.Scale,
			Damage = params.Damage,
			BounceSpeed = bounceSpd,
			SelfBounceSpeed = selfBounceSpd,
			DestroyGrid = params.DestroyGrid,
			DestroyDoor = params.DestroyDoor,
			CollectPickup = true,
			ClearProj = true,
			FollowEntity = followEntity,
		}
		
		if #targets > 0 then
			bounceSpd = 0
			selfBounceSpd = 0
			
			local hitEnemy = false
			
			for _,ent in ipairs(targets) do
				if self._Ents:IsEnemy(ent) then
					hitEnemy = true
					
					--减速
					if compats.Slow then
						ent:AddSlowing(EntityRef(player), 75, 0.5, Color(1,1,1,1,0.3,0.3,0.3))
						ent:SetBossStatusEffectCooldown(0)
					end

					--中毒
					if compats.Poison then
						ent:AddPoison(EntityRef(player), 60, player.Damage)
						ent:SetBossStatusEffectCooldown(0)
					end
					
					--燃烧
					if compats.Burn then
						ent:AddBurn(EntityRef(player), 60, player.Damage)
						ent:SetBossStatusEffectCooldown(0)
					end					
					
					--石化
					if compats.Petrify and ent:GetFreezeCountdown() <= 0 then
						ent:AddFreeze(EntityRef(player), 60)
					end
					
					--混乱
					if compats.Confuse then
						ent:AddConfusion(EntityRef(player), 60)
					end
					
					--恐惧
					if compats.Fear then
						ent:AddFear(EntityRef(player), 60)
					end			
					
					--标记
					if compats.Bait then
						ent:SetBossStatusEffectCooldown(0)
						ent:AddBaited(EntityRef(player), 150, player.Damage)
						ent:SetBossStatusEffectCooldown(0)
					end
					
					--背刺
					if compats.Bleed then
						ent:AddBleeding(EntityRef(player), 150)
					end
					
					--硫磺火
					if compats.Brimstone then
						ent:SetBossStatusEffectCooldown(0)
						ent:AddBrimstoneMark(EntityRef(player), 180)
						if ent:GetBrimstoneMarkCountdown() < 180 then
							ent:SetBrimstoneMarkCountdown(180)
						end	
					end
				else
					--胎儿博士
					if compats.DrFetus then					
						local bomb = ent:ToBomb()
						if bomb then
							bomb:SetExplosionCountdown(0)
						end
					end
				end
			end
			
			if hitEnemy then
				sfx:Play(IBS_Sound.SwingHit, 1, 2, false, 0.01*math.random(90,120))
			end
		end
		
		--妈刀和骨棒
		if compats.Knife then
			for _,ent in ipairs(Isaac.FindByType(8,-1,0)) do
				local knife = ent:ToKnife()
				
				if knife and not knife:IsFlying()
					and (knife.Variant ~= 4 and knife.Variant < 6)
				then
					local player = self._Ents:IsSpawnerPlayer(knife, true)
					if player then
						knife:Shoot(1, math.min(300, player.TearRange / 1.5))
					end
				end
			end		
		end
		
		for _,skill in ipairs(skills) do
			if skill.OnAttack then
				skill.OnAttack(player, compats, targets, effect, vec, params)
			end	
		end	
	end

	--设置攻击间隔
	if not skipSetDelay then
	
		--胎儿博士
		if compats.DrFetus then
			params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 0.4))
		end
		
		--妈刀和骨棒
		if compats.Knife then
			params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 3))
		end
		
		--硫磺火
		if compats.Brimstone then
			params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 0.4))
		end
		
		--肺
		if compats.Lung then
			params.AttackDelay = math.max(1, math.floor(params.AttackDelay * 0.2))
		end
		
		self:GetTempData(player).AttackDelay = params.AttackDelay
	end
	
	local pitch = 1
	
	if params.SoundID == 540 then
		pitch = pitch + 0.2
	end
	
	if params.Size * scale > 44 then
		sfx:Play(params.SoundID, 0.7, 2, false, pitch / 2)
	elseif params.Size * scale < 24 then
		sfx:Play(params.SoundID, 0.7, 2, false, pitch * 1.5)
	else
		sfx:Play(params.SoundID, 0.7, 2, false, pitch)
	end

	for _,skill in ipairs(skills) do
		if skill.PostAttack then
			skill.PostAttack(player, compats)
		end	
	end		
end

--获取卡牌贴图
local function GetCardSprite(id)
	local spr = Sprite()

	if id <= 0 then
		spr:Load('gfx/ibs/ui/selection.anm2', true)
		spr:SetFrame("Idle", 1)	
	else	
		spr:Load('gfx/ibs/ui/items/ui_cardfronts.anm2', true)
		spr:SetFrame("Idle", id)
		spr.Scale = Vector(0.5, 0.5)
	end
	
	return spr
end

--获取主动槽的卡牌贴图
local function GetCardSprite2(id)
	local spr = Sprite()

	if id <= 0 then
		spr:Load('gfx/ibs/ui/selection.anm2', true)
		spr:SetFrame("Idle", 1)	
	else	
		spr:Load('gfx/ibs/ui/items/ui_cardfronts.anm2', true)
		spr:SetFrame("Idle", id)
	end
	
	return spr
end

--刷新列表
function Posture:RefreshList(player)
	local data = self:GetTempData(player)

	for k,_ in pairs(data.List) do
		data.List[k] = nil
	end

	for k,_ in pairs(data.List2) do
		data.List2[k] = nil
	end

	for _,id in ipairs(self:GetData(player).Cards) do
		table.insert(data.List, {ID = id, Sprite = GetCardSprite(id), Sprite2 = GetCardSprite2(id), Sprite3 = GetCardSprite(id),})
	end
	
	for _,id in ipairs(self:GetData(player).Cards2) do
		table.insert(data.List2, {ID = id, Sprite = GetCardSprite(id)})
	end	
end

--消耗牌
function Posture:ConsumeCard(player, slot, isReversed, skipEvaluate, skipRefreshSpr)
	local data = self:GetData(player)
	local cards = (isReversed and data.Cards2) or data.Cards
	cards[slot] = 0
	data.ConsumedCount = data.ConsumedCount + 1
	
	--刷新属性
	if not skipEvaluate then
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)	
	end
	
	--刷新列表
	if not skipRefreshSpr then
		self:RefreshList(player)
	end
end

--是否可学习(需要是塔罗牌)
function Posture:CanLearn(player, id)
	if player:GetPlayerType() == BSamson.ID then
		return (id >=1 and id <= 22) or (id >= 56 and id <= 77)
	end
	return (id >=1 and id <= 22)
end

--获取最近的卡牌
function Posture:FindCardPickup(player, pos)
	local ent = self._Finds:ClosestEntity(pos, 5, 300, -1, function(ent)
		local pickup = ent:ToPickup()
		return pickup ~= nil 
			and self:CanLearn(player, pickup.SubType) 
			and pickup.Price == 0 
			and ent.Position:Distance(pos) < 100
	end)
	
	return ent and ent:ToPickup()
end


--尝试使用
function Posture:OnTryUse(slot, player)
	if game:GetRoom():IsClear() and self:FindCardPickup(player, player.Position) then
		return 0
	end
end
Posture:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', Posture.ID)

--计算充能消耗
function Posture:GetDischarge(player)
	local discharge = 3
	
	--在已清理房间使用
	if game:GetRoom():IsClear() then
		local pickup = self:FindCardPickup(player, player.Position)
		if pickup then
			return 0
		end
	end	
	
	--表表参孙
	if player:GetPlayerType() == BSamson.ID then
		local data = self:GetData(player)
		local selected = data.Cards[data.NextSelection]
		
		if selected and self.SkillCost[selected] then
			if data.FreeTimes > 0 then		
				discharge = 0
			else
				local state = BSamson:GetState(player)
				local cost
				
				if state == BSamson.Calm then
					cost = self.SkillCost[selected].Calm
				elseif state == BSamson.Wrath then
					cost = self.SkillCost[selected].Wrath
				end
				
				if type(cost) == "function" then
					discharge = cost(player)
				else
					discharge = cost or discharge
				end
			end
		end
		
		--允许0费存在
		if discharge == 0 then
			return discharge
		end
	end

	if player:HasCollectible(116) then discharge = discharge - 1 end --9伏特
	
	--默认最低消耗1充能
	return math.max(1, discharge)
end

--尝试使用
function Posture:OnTryUse(slot, player)
	return self:GetDischarge(player)
end
Posture:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, 'OnTryUse', Posture.ID)


--使用
function Posture:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_OWNED > 0) and (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then
		local holding = self._Players:IsHoldingItem(player, self.ID)
	
		--在已清理房间使用
		if game:GetRoom():IsClear() then
			local pickup = self:FindCardPickup(player, player.Position)
			
			--尝试握住
			if not holding and pickup then
				self._Players:TryHoldItem(self.ID, player, flags, slot)
				return {ShowAnim = false, Discharge = false}				
			end
		end
		
		--正在握住
		if holding then
			local tData = self:GetTempData(player)

			if tData.Wait <= 0 then
				local data = self:GetData(player)
				local selection = tData.Selection
				local pickup = self:FindCardPickup(player, player.Position)
				local cards = (pickup and pickup.SubType > 22 and data.Cards2) or data.Cards
				local selected = cards[selection]
				
				if selected and selected > 0 then
					Isaac.Spawn(5,300, selected, player.Position, Vector.Zero, player)
				end
				
				--存牌或取牌
				if pickup then
					cards[selection] = pickup.SubType
					Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
					pickup:Remove()
				else					
					cards[selection] = 0
				end
				player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
				
				self:RefreshList(player)
				tData.Wait = 15
			end
			
			return {ShowAnim = false, Discharge = false}
		end		
		
		local data = self:GetData(player)
		local tData = self:GetTempData(player)
		local selected = data.Cards[data.NextSelection]
		local cachedKey = data.NextSelection
		local discharge = self:GetDischarge(player)
		
		--使用
		if not self._Players:IsHoldingItem(player, self.ID)
			and tData.CD <= 0
			and selected and selected > 0
			and self._Players:DischargeSlot(player, slot, discharge, true, false, true, true)
		then
			
			--切招
			self:Next(player)
			
			--表表参孙
			if player:GetPlayerType() == BSamson.ID then
				local state = BSamson:GetState(player)
				local skill = self:GetSkill(selected or 0)
			
				--清除待机计时
				BSamson:GetData(player).Standing = 0	
			
				if skill then
					data.FreeTimes = math.max(0, data.FreeTimes - 1)
					
					if state == BSamson.Calm then					
						if skill.CalmStateTrans and skill.CalmStateTrans == BSamson.Wrath then
							--平静只有切换到暴怒有用
							BSamson:ChangeState(player, BSamson.Wrath)
							
							--长子权
							if player:HasCollectible(619) then
								self:DelayFunction(function()
									self:Charge(player, slot, 1)
								end, 1)							
							end
						end
						if skill.CalmOnUse then
							skill.CalmOnUse(player, self:GetCompats(player), slot)
						end
					else
						if skill.WrathStateTrans then
							BSamson:ChangeState(player, skill.WrathStateTrans)
						end
						if skill.WrathOnUse then
							skill.WrathOnUse(player, self:GetCompats(player), slot)
						end
					end
				end
				
				--连续0费冷却,一些卡牌效果可能会进入冷却,所以要先判断
				if tData.CD <= 0 then
					if discharge <= 0 and self:GetDischarge(player) <= 0 then
						tData.MaxCD = 180
					else
						tData.MaxCD = 0
					end
					tData.CD = tData.MaxCD
				end
				
				--消耗世界
				if selected == 22 then
					self:ConsumeCard(player, cachedKey)
				end
			else
				--其他角色
				data.Duration = data.Duration + 1000
				sfx:Play(592, 0.5, 10)
			end
		end
	end

	return {ShowAnim = false, Discharge = false}	
end
Posture:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Posture.ID)

--尝试握住
function Posture:OnTryHoldItem(item, player, flag, slot, holdingItem)
	if holdingItem <= 0 then
		local canHold = true

		if (flag & UseFlag.USE_OWNED <= 0) or (flag & UseFlag.USE_CARBATTERY > 0) or (flag & UseFlag.USE_VOID > 0) then
			canHold = false
		end

		--刷新
		if canHold then
			self:RefreshList(player)
			local data = self:GetTempData(player)
			data.Wait = 10
		end

		return {CanHold = canHold}
	end
	return {CanHold = false}
end
Posture:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', Posture.ID)

--正在握住
function Posture:OnHoldingItem(item, player, flag, slot)
	if game:IsPaused() then return end
	local cid = player.ControllerIndex

	--按丢弃键结束握住
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid) then
		return false
	end
	
	local data = self:GetTempData(player)
	local LEFT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, cid)
	local RIGHT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, cid)

	--切换
	if LEFT then
		if data.Selection > 1 then
			data.Selection = data.Selection - 1
		else
			data.Selection = 5
		end
	end
	if RIGHT then
		if data.Selection < 5 then
			data.Selection = data.Selection + 1
		else
			data.Selection = 1
		end
	end
end
Posture:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', Posture.ID)

--结束握住
function Posture:OnHoldEnd(item, player, flag, slot, byActive, byTimeout, byHurt, byNewRoom)
	local data = self:GetTempData(player)
	for _,tbl in ipairs(data.List) do
		tbl.Sprite.Color.A = 1
	end
	for _,tbl in ipairs(data.List2) do
		tbl.Sprite.Color.A = 0.5
	end
end
Posture:AddCallback(IBS_CallbackID.HOLD_ITEM_END, 'OnHoldEnd', Posture.ID)

--角色更新
function Posture:OnPlayerUpdate(player)
	do
		--计时
		local data = self._Players:GetData(player).Posture
		if data and data.Duration > 0 then
			data.Duration = data.Duration - 1
		end
	end

	if not player:HasCollectible(self.ID, true) then return end
	
	local data = self:GetData(player)
	local tData = self:GetTempData(player)
	local cards = data.Cards
	local cardNum = 0

	--刷新兼容缓存
	if player:IsFrame(60,0) then
		for k,_ in pairs(tData.Compats) do
			tData.Compats[k] = nil
		end
		for k,v in pairs(GetCompats(player)) do
			tData.Compats[k] = v
		end
	end

	--冷却
	if tData.CD > 0 then
		tData.CD = tData.CD - 1
	end
	if tData.AttackDelay > 0 then
		tData.AttackDelay = tData.AttackDelay - 1
	end

	for _,v in ipairs(cards) do
		if v > 0 then
			cardNum = cardNum + 1
		end
	end

	--空招自动跳,除非没牌了
	local id = cards[data.DoingSelection]
	if id <= 0 then
		if cardNum > 0 then
			data.DoingSelection = data.DoingSelection + 1
			if data.DoingSelection > 5 then
				data.DoingSelection = 1
			end
		end
	end

	--下一张牌预选
	if cardNum <= 1 then
		data.NextSelection = data.DoingSelection
	else
		local selection = data.DoingSelection
		
		for i = 1,5 do
			selection = selection + 1
			if selection > 5 then
				selection = 1
			end
		
			local id = cards[selection]
			if id > 0 then	
				data.NextSelection = selection
				break
			end
		end
	end
	
	--攻击
	if self:CanAttack(player) and self._Players:IsShooting(player) then
		local mark = player:GetMarkedTarget()
		local vec = Vector.Zero
	
		--准心
		if mark then
			vec = (mark.Position - player.Position):Normalized()
			self:DoAttack(player, vec)
		else		
			vec = self._Players:GetAimingVector(player)
			if vec:Length() > 0.9 then
				self:DoAttack(player, vec)
				
				--设置头部方向
				player:SetHeadDirection(self._Maths:VectorToDirection(vec), 6, true)
			end
		end
		
		if mark or vec:Length() > 0.9 then
			--莉莉宝等
			local familiars = self._Finds:IncubusFamiliars(player)
			if #familiars > 0 then
				local isLilith = player:GetPlayerType() == 13 or player:GetPlayerType() == 32
				local mult = (isLilith and 1) or 0.75
				
				--大宝
				if player:HasCollectible(247) then
					mult = mult * 2
				end
				
				for _,familiar in ipairs(familiars) do
					local variant = familiar.Variant
					local pos = familiar.Position

					--莉莉宝
					if (variant == FamiliarVariant.INCUBUS) then
						self:DoAttack(player, vec, true, pos, mult, mult)
					elseif (variant == FamiliarVariant.TWISTED_BABY) then
						--作孽双子
						self:DoAttack(player, vec, true, pos, mult * 0.5, mult, familiar)
					else
						--格罗
						local target = self._Finds:ClosestEnemy(familiar.Position)
						if target then
							self:DoAttack(player, (target.Position - pos):Normalized(), true, pos, mult, mult, familiar)
						else
							self:DoAttack(player, vec, true, pos, mult, mult, familiar)
						end
					end		
				end
			end
			
			--剖腹产
			for _,ent in ipairs(Isaac.FindByType(2, 50, -1, true)) do
				local p = self._Ents:IsSpawnerPlayer(ent, true)
				if p and self._Ents:IsTheSame(p, player) then
					local pos = ent.Position
					local target = self._Finds:ClosestEnemy(pos)
					if target then
						self:DoAttack(player, (target.Position - pos):Normalized(), true, pos, 0.375, 0.75, ent)
					else
						self:DoAttack(player, vec, true, pos, 0.375, 0.75, ent)
					end					
				end
			end
		end
	end	
	
	--英灵剑
	if player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) then
		local cid = player.ControllerIndex
		local triggered = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, cid)
			or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, cid)
			or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, cid)
			or Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, cid)
		
		--鼠标
		if not triggered and cid == 0 and Options.MouseControl then
			if Input.IsMouseBtnPressed(0) then
				if not tData._MousePressed then
					tData._MousePressed = true
					triggered = true
				end
			elseif tData._MousePressed then
				tData._MousePressed = nil
			end
		end
		
		--刷新攻击冷却
		if triggered then
			tData.AttackDelay = 0
		end
	end	
end
Posture:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--暴怒受伤消耗选牌
function Posture:OnBSamsonTakeDamage(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	local player = ent:ToPlayer()

	if player
		and Damage:IsPenalt(player, flag, source)
		and player:GetPlayerType() == BSamson.ID
		and BSamson:GetState(player) == BSamson.Wrath
		and not self:HasCard(player, 69) --倒死亡
	then
		local data = self:GetData(player)
		local selection = data.DoingSelection
		local id = data.Cards[selection]
		
		if id and id > 1 and player:GetCollectibleRNG(self.ID):RandomInt(100) < math.max(10, 50 - 4 * player.Luck) then
			self:ConsumeCard(player, selection)
			sfx:Play(267)
		end
	end
end
Posture:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, -100, 'OnBSamsonTakeDamage')


local selectionSpr = Sprite('gfx/ibs/ui/selection.anm2')
selectionSpr:Play("Idle")

--渲染
function Posture:OnHUDRender()
	if not game:GetHUD():IsVisible() then return end
	local room = game:GetRoom()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local pickup = nil
		
		--显示塔罗牌
		if player:HasCollectible(self.ID, true) and room:IsClear() then
			local data = self:GetTempData(player)
			pickup = self:FindCardPickup(player, player.Position)
			
			--高亮
			if pickup then
				--镜世界翻转
				if room:IsMirrorWorld() then
					data.HighLight.FlipX = true
				else
					data.HighLight.FlipX = false
				end

				data.HighLight:SetFrame(pickup.SubType)
				data.HighLight.Color = Color(1, 1, 1, 1 + 0.2*math.sin(0.1*pickup.FrameCount), 70/255, 70/255, 0)		
				data.HighLight:Render(self._Screens:WorldToScreen(pickup.Position, Vector(0,-4), true))
			end		
		end
		
		if self._Players:IsHoldingItem(player, self.ID) then
			local data = self:GetTempData(player)
			local selection = data.Selection
			local selected = self:GetData(player)[selection] or 0
				
			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			end

			do
				local pos = self._Screens:WorldToScreen(player.Position, Vector(0,-48), true)
				local X,Y = pos.X - 32, pos.Y
				
				--显示图标
				for _,tbl in ipairs(data.List) do
					tbl.Sprite:Render(Vector(X,Y))
					X = X + 16
				end
				
				--倒卡显示
				if player:GetPlayerType() == BSamson.ID then				
					X,Y = pos.X - 32, pos.Y + 16
					for _,tbl in ipairs(data.List2) do
						tbl.Sprite:Render(Vector(X,Y))
						X = X + 16
					end
				end
				
				--显示选择框
				if pickup and pickup.SubType > 22 then
					for _,tbl in ipairs(data.List) do
						local alpha = tbl.Sprite.Color.A
						if alpha > 0.5 then
							alpha = alpha - 0.02
						end
						tbl.Sprite.Color.A = math.max(0.5, alpha)
					end
					for _,tbl in ipairs(data.List2) do
						local alpha = tbl.Sprite.Color.A
						if alpha < 1 then
							alpha = alpha + 0.02
						end
						tbl.Sprite.Color.A = math.min(1, alpha)
					end
					selectionSpr:Render(Vector(pos.X + selection * 16 - 48, pos.Y + 16))
				else
					for _,tbl in ipairs(data.List) do
						local alpha = tbl.Sprite.Color.A
						if alpha < 1 then
							alpha = alpha + 0.02
						end
						tbl.Sprite.Color.A = math.min(1, alpha)
					end
					for _,tbl in ipairs(data.List2) do
						local alpha = tbl.Sprite.Color.A
						if alpha > 0.5 then
							alpha = alpha - 0.02
						end
						tbl.Sprite.Color.A = math.max(0.5, alpha)
					end				
					selectionSpr:Render(Vector(pos.X + selection * 16 - 48, pos.Y))
				end
			end
			
		end
	end
end
Posture:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')

local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

--主动槽渲染
function Posture:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local data = self:GetData(player)
	local tData = self:GetTempData(player)
	local bsamson = (player:GetPlayerType() == BSamson.ID)
	local selected = nil
	local canShow = false
	local discharge = ""
	local fntPos = Vector.Zero
	
	--表表参孙显示下一张牌
	if bsamson then
		selected = tData.List[data.NextSelection]
		
		--显示充能消耗
		local pickup = self:FindCardPickup(player, player.Position)
		if (not game:GetRoom():IsClear() or not pickup)
			and selected ~= nil
			and selected.ID
			and selected.ID > 0
		then
			discharge = tostring(self:GetDischarge(player))
			fntPos = Vector(22*scale, 1*scale) + offset
			canShow = true
		end
	else
		--其他角色显示持续时间
		canShow = true
	end
	
	if selected ~= nil and canShow
		and selected.ID > 0 
		and selected.Sprite2 
		and (data.Duration > 0 or bsamson)
	then
		selected.Sprite2.Scale = Vector(scale, scale)
		selected.Sprite2.Color = Color(1,1,1, 0.7*alpha)
		
		--颜色提示姿态转换
		if bsamson then
			local skill = self:GetSkill(selected.ID)
			if skill then
				local stateTrans
				
				if BSamson:GetState(player) == BSamson.Calm then
					stateTrans = skill.CalmStateTrans
				else
					stateTrans = skill.WrathStateTrans
				end		
				
				if stateTrans then
					if stateTrans == BSamson.Calm then
						selected.Sprite2.Color = Color(1,1,1, 0.7*alpha, 0.1, 0.2, 0.3)
					elseif stateTrans == BSamson.Wrath then
						selected.Sprite2.Color = Color(1,1,1, 0.7*alpha, 0.5, 0.1, 0.1)
					end
				end
			end			
		end
		
		selected.Sprite2:Render(offset + Vector(16*scale,18*scale))
	end	
	
	--显示冷却
	if tData.CD > 0 and tData.MaxCD > 0 then
		local color = Color(1,1,1,alpha)
		color:SetColorize(1,1,1,2) --反色
		tData.CDBar.Color = color
		tData.CDBar:SetFrame("Charging", math.floor(100 *(tData.CD)/tData.MaxCD))
		tData.CDBar:Render(Vector(16*scale, 16*scale) + offset)
		canShow = false
	end	
	
	if canShow then
		if bsamson then		
			local color = (data.FreeTimes > 0 and KColor(1, 1, 0, alpha)) or KColor(0.2, 1, 0.2, alpha)
			fnt:DrawStringScaled(discharge, fntPos.X, fntPos.Y, scale, scale, color)
		end
		
		--显示伤害充能进度
		local threshold = self:GetDamageChargeThreshold()
		tData.ChargeBar.Color = Color(1,1,1,alpha)
		tData.ChargeBar:SetFrame("Charging", math.floor(100 *(data.Damage)/threshold))
		tData.ChargeBar:Render(Vector(8*scale, 8*scale) + offset)
		
		--其他角色显示持续时间
		if not bsamson and data.Duration > 0 then
			local color = Color(1,1,1,alpha)
			color:SetColorize(1,1,1,2) --反色
			tData.CDBar.Color = color
			tData.CDBar:SetFrame("Charging", math.floor(100 *(data.Duration)/1000))
			tData.CDBar:Render(Vector(16*scale, 16*scale) + offset)
		end			
	end
end
Posture:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


--获得时生成愚者
function Posture:OnGainItem(item, charge, first, slot, varData, player)
	if first and slot >= 0 and slot <= 1 then
		local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 1, pos, Vector.Zero, nil)
	end
end
Posture:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem', Posture.ID)


-------------------------------------以下内容为兼容效果-------------------------------------

--受伤前
function Posture:PrePlayerTakeDMG(player, dmg, flag, source)

	--胎儿博士/史诗胎儿防爆
	if (flag & DamageFlag.DAMAGE_EXPLOSION > 0) 
		and (player:HasCollectible(52) or player:HasCollectible(168))
		and (self:GetData(player).Duration > 0 or BSamson:GetState(player) == BSamson.Wrath)
	then
		return false
	end
end
Posture:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -1000, 'PrePlayerTakeDMG')

--史诗胎儿
function Posture:OnEpicFetusUpdate(effect)
	local player = self._Ents:IsSpawnerPlayer(effect, true)
	if player and player:HasWeaponType(WeaponType.WEAPON_ROCKETS)
		and (self:GetData(player).Duration > 0 or BSamson:GetState(player) == BSamson.Wrath)
	then
		local target = self._Finds:ClosestEnemy(player.Position)
		if target then
			effect.Position = target.Position
		end
	end
end
Posture:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnEpicFetusUpdate', EffectVariant.TARGET)


return Posture