--腐骸挑战
--(部分效果在对应文件)

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_FamiliarID = mod.IBS_FamiliarID
local IBS_CallbackID = mod.IBS_CallbackID
local Damage = mod.IBS_Class.Damage()

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local BC15 = mod.IBS_Class.Challenge(15, {
	PaperNames = {'bforgotten_up'},
	Destination = 'Satan'
})

--白名单
BC15.WhiteList = {
	[448] = true,
	[498] = true,
	[537] = true,
	[619] = true,
	[IBS_ItemID.DeciduousMeat] = true,
}

local MaxCharge = 3600
local MaxCharge2 = 100
local MaxCharge3 = 180
local MaxCharge4 = 999

--获取数据
function BC15:GetData(player)
	local data = self._Ents:GetTempData(player)
	
	if not data.BENIGHTED_CHALLENGE_15_PLAYER then
		local bar = Sprite('gfx/chargebar_sumptorium.anm2')
		bar:SetFrame("Disappear", 99)		
	
		local bar2 = Sprite('gfx/chargebar_berserk.anm2')
		bar2:SetFrame("Disappear", 99)
		
		local bar3 = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar3:SetFrame("Disappear", 99)
		
		local bar4 = Sprite('gfx/ibs/ui/chargebar.anm2')
		bar4.Color = Color(0.5, 0.5, 1, 1, 0, 0.5, 0.5)
		bar4:SetFrame("Disappear", 99)
	
		data.BENIGHTED_CHALLENGE_15_PLAYER = {
			Charge = MaxCharge - 10,
			ChargeBar = bar,
			
			Charge2 = 0,
			Charge2DamageCheck = 0,
			Charge2Enabled = false,	
			ChargeBar2 = bar2,
			
			Charge3 = 0,
			ChargeBar3 = bar3,
			
			Charge4 = 0,
			ChargeBar4 = bar4,				
		}
	end
	
	return data.BENIGHTED_CHALLENGE_15_PLAYER
end


--角色初始化
function BC15:OnPlayerInit(player)
	if not self:Challenging() then return end
	self:DelayFunction2(function()
		if not self:IsGameContinued() then
			local itemPool = game:GetItemPool()
			player:SetPocketActiveItem(IBS_ItemID.CursedMantle, 2, false)
			itemPool:RemoveCollectible(IBS_ItemID.DeciduousMeat)
		end
	end, 1)	
	player:AddCollectible(IBS_ItemID.DeciduousMeat)
end
BC15:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')


--角色更新
function BC15:OnPlayerUpdate(player)
	if not self:Challenging() then return end
	local data = self:GetData(player)
	local isBone = (player:GetPlayerType() == 16)
	local isSoul = (player:GetPlayerType() == 17)

	--骨形态红心变腐心
	if isBone then
		local num = player:GetHearts() - 2 * player:GetRottenHearts()
		if num > 0 then
			player:AddHearts(-num)
			player:AddRottenHearts(num)
		end
	end

	--骨形态流血蓄力
	if isBone and (player:GetHearts() > 0 or player:GetRottenHearts() > 0) then
		if data.Charge < MaxCharge then
			data.Charge = data.Charge + 1
		else
			data.Charge = 0
			data.Charge2DamageCheck = 2
			player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(player), 30)
		end
	end
	
	if data.Charge2DamageCheck > 0 then
		data.Charge2DamageCheck = data.Charge2DamageCheck - 1
	end
	
	--即死蓄力
	if data.Charge2Enabled then
		if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) then
			if data.Charge2 >= MaxCharge2 then
				data.Charge2Enabled = false
				data.Charge2 = 0
			end
		else
			if data.Charge2 < MaxCharge2 then
				data.Charge2Enabled = false
				data.Charge2 = 0
				player:Die()
			end			
		end
	end
	
	--拆道具蓄力
	do
		local ent = self._Finds:ClosestCollectible(player.Position)
		if ent and ent:ToPickup() and ent.SubType > 0 and ent.Timeout < 0 and ent.Position:Distance(player.Position) <= 67 then
			if data.Charge3 < MaxCharge3 then
				data.Charge3 = data.Charge3 + 1
			else
				data.Charge3 = 0
				
				local itemConfig = config:GetCollectible(ent.SubType)
				if itemConfig then
					local room = game:GetRoom()
					local quality = (itemConfig.Quality or 0) - 1
					
					--魂形态把道具拆成硬币
					if isSoul then
						local num = (quality < 2 and 5) or 10
					
						for i = 1,num do
							Isaac.Spawn(5, 20, 0, ent.Position, RandomVector(), nil)
						end
					elseif isBone then
						local rng = RNG(ent.InitSeed)
						local pool = self._Pools:GetRoomPool()

						--把道具变为两个品质减一的道具
						for i = 1,2 do
							local pos = room:FindFreePickupSpawnPosition(ent.Position + Vector(40,0) * (-1)^i, 0, true)
							local id = self._Pools:GetCollectibleWithQuality(rng:Next(), quality, pool, true)
							local pickup = Isaac.Spawn(5, 100, id, pos, Vector.Zero, nil):ToPickup()
							pickup.Wait = 45
							pickup.Timeout = 300
							
							--瞎眼特效
							local color = Color(1,1,1,1,0,0,0, 1)
							local spr = pickup:GetSprite()
							spr:SetRenderFlags(AnimRenderFlags.STATIC)
							spr.Color = color
							
							Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
						end
					end

					Isaac.Spawn(1000, 15, 0, ent.Position, Vector.Zero, nil)
					ent:Remove()
					sfx:Play(644)
				end
			end
		else
			data.Charge3 = 0
		end
	end
	
	--魂形态限时蓄力
	if isSoul then
		if data.Charge4 > 0 then
			data.Charge4 = data.Charge4 - 1
		else
			player:SwapForgottenForm()
		end
	elseif isBone then
		if data.Charge4 < MaxCharge4 then
			data.Charge4 = data.Charge4 + 2
		end	
	end
end
BC15:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--只能拾取腐心
function BC15:PreHeartCollision(pickup, other)
	if not self:Challenging() then return end
	local player = other:ToPlayer()
	if player and self:Challenging() and pickup.SubType ~= 12 then
		return false
	end
end
BC15:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -100, 'PreHeartCollision', PickupVariant.PICKUP_HEART)

--这也是特制的炸弹,懂吗
function BC15:OnUseBomb(player, bomb)
	if not self:Challenging() then return end
	
	if math.random(1,100) <= 50 then
		player:UseActiveItem(578, false, false)
		bomb:Remove()
	end
end
BC15:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, -114514, 'OnUseBomb')

--属性
function BC15:OnEvaluateCache(player, flag)
	if not self:Challenging() then return end

	--魂形态给跟班
	if flag & CacheFlag.CACHE_FAMILIARS > 0 then
		if player:GetPlayerType() == 17 then
			player:CheckFamiliar(IBS_FamiliarID.CapeSoul.Variant, 4, RNG(1))
			player:CheckFamiliar(IBS_FamiliarID.BLostWeapon.Variant, 1, RNG(1), nil, IBS_FamiliarID.BLostWeapon.SubType.Spike)
		else
			player:CheckFamiliar(IBS_FamiliarID.CapeSoul.Variant, 0, RNG(1))
			player:CheckFamiliar(IBS_FamiliarID.BLostWeapon.Variant, 0, RNG(1), nil, IBS_FamiliarID.BLostWeapon.SubType.Spike)
		end
	end
	
	--魂形态伤害减半
	if player:GetPlayerType() == 17 then
		if flag & CacheFlag.CACHE_DAMAGE > 0 then		
			player.Damage = player.Damage * 0.5
		end
	end
end
BC15:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvaluateCache')

--受伤判定
function BC15:OnTakeDMG(ent, dmg, flag, source)
	if not self:Challenging() then return end
	local player = ent:ToPlayer()
	
	if player then
		--骨形态受到惩罚性伤害触发即死蓄力
		if player:GetPlayerType() == 16 then
			local data = self:GetData(player)
			
			if not data.Charge2Enabled 
				and data.Charge2DamageCheck > 0
				and Damage:IsPenalt(player, flag, source)
				and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK)
			then		
				data.Charge2 = 0
				data.Charge2Enabled = true
				player:UseCard(87, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
				player:UseCard(87, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
			end
			
			--攻击者变成腐烂gaper
			local target = self._Ents:GetSourceEnemy(source.Entity)
			if target ~= nil and target:IsVulnerableEnemy() and not target:IsBoss() then
				Isaac.Spawn(10,3,0, target.Position, Vector.Zero, player)
				target:Remove()
			end			
		end
	elseif self._Ents:IsEnemy(ent) then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			local data = self:GetData(player)
			
			if data.Charge2Enabled then
				data.Charge2 = data.Charge2 + dmg			
			end	
		end		
	end
end
BC15:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--获取一个角色身上的道具
local function GetItem(player, seed)
	local result = {}

	local MAX = config:GetCollectibles().Size - 1
	for id = 1, MAX do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and not BC15.WhiteList[id]
			and player:HasCollectible(id, true)
			and itemConfig.Type ~= ItemType.ITEM_ACTIVE
			and not itemConfig:HasTags(ItemConfig.TAG_QUEST)
		then
			table.insert(result, id)
		end
	end

	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
end

--新层
function BC15:OnNewLevel()
	if not self:Challenging() then return end
	if game:GetLevel():GetStage() == 1 then return end
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetData(player)
		data.Charge = 0
		
		local seed = player:GetCollectibleRNG(725):Next()
		local id = GetItem(player, seed)
		if id then		
			player:RemoveCollectible(id)
			player:AddItemWisp(id, player.Position, true)
		end
	end
end
BC15:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--新房间
function BC15:OnNewRoom()
	if not self:Challenging() then return end
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_SHOP then
		if room:IsFirstVisit() then		
			for _,ent in ipairs(Isaac.FindByType(5)) do
				ent:Remove()
			end
		end
		
		--究极贪婪
		local data = self:GetIBSData("level")
		data.BENIGHTED_CHALLENGE_15_GREED_NUM = (data.BENIGHTED_CHALLENGE_15_GREED_NUM or 0) + 1
		if data.BENIGHTED_CHALLENGE_15_GREED_NUM <= 5 then		
			local ent = Isaac.Spawn(406, 1, 0, room:GetCenterPos(), Vector.Zero, nil)
			ent.MaxHitPoints = 25 + (10 * game:GetLevel():GetStage() * data.BENIGHTED_CHALLENGE_15_GREED_NUM)
			ent.HitPoints = ent.MaxHitPoints
			game:GetLevel():GetCurrentRoomDesc().Clear = false
		end
	end
end
BC15:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--清理房间
function BC15:OnRoomCleaned(ent)
	if not self:Challenging() then return end
	local room = game:GetRoom()

	if room:GetType() == RoomType.ROOM_SHOP then
		local num = self:GetIBSData("level").BENIGHTED_CHALLENGE_15_GREED_NUM or 0
		if num <= 5 then
			local num2 = math.max(1, num - 1)
			for i = 1,num2 do			
				local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_SHOP, true, ent.InitSeed)
				local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
				local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
				item.ShopItemId = -1
				item.Price = 1
			end
		end
	end
end
BC15:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')


--渲染蓄力条
function BC15:OnHUDRender()
	if not self:Challenging() then return end
	if not game:GetHUD():IsVisible() then return end
	if game:GetRoom():GetFrameCount() <= 0 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetData(player)

		--流血蓄力条
		if data.ChargeBar then		
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,-32), true)
			if data.Charge > 0 then
				data.ChargeBar:SetFrame("Charging", math.floor(100*(data.Charge)/MaxCharge))
			else
				data.ChargeBar:Play("Disappear")
				if not game:IsPaused() then
					data.ChargeBar:Update()
				end
			end
			data.ChargeBar:Render(pos)
		end
		
		--即死蓄力条
		if data.ChargeBar2 then
			if data.Charge2Enabled then		
				data.ChargeBar2:SetFrame("Charging", math.floor(100*(data.Charge2)/MaxCharge2))
			else
				data.ChargeBar2:Play("Disappear")
				if not game:IsPaused() then
					data.ChargeBar2:Update()
				end
			end		
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,-16), true)
			data.ChargeBar2:Render(pos)
		end
		
		--拆道具蓄力条
		if data.ChargeBar3 then		
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,8), true)
			if data.Charge3 > 0 then
				data.ChargeBar3:SetFrame("Charging", math.floor(100*(data.Charge3)/MaxCharge3))
			else
				data.ChargeBar3:Play("Disappear")
				if not game:IsPaused() then
					data.ChargeBar3:Update()
				end
			end
			data.ChargeBar3:Render(pos)
		end		
		
		--魂形态限时蓄力条
		if data.ChargeBar4 then		
			local pos = self._Screens:WorldToScreen(player.Position, Vector(0,16), true)
			if data.Charge4 > 0 and data.Charge4 < MaxCharge4 then
				data.ChargeBar4:SetFrame("Charging", math.floor(100*(data.Charge4)/MaxCharge4))
			else
				data.ChargeBar4:Play("Disappear")
				if not game:IsPaused() then
					data.ChargeBar4:Update()
				end
			end
			data.ChargeBar4:Render(pos)
		end				
	end
end
BC15:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')

--恶魔房道具免费
function BC15:OnPickupUpdate(pickup)
	if not self:Challenging() then return end
	local roomType = game:GetRoom():GetType()
	if roomType == RoomType.ROOM_DEVIL then
		if pickup.Price < 0 then
			pickup.AutoUpdatePrice = false
			pickup.Price = 0
		end
	end
end
BC15:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate')

--拾取道具
function BC15:OnPickItem(player, item, touched, pickup)
	if not self:Challenging() then return end
	if touched then return end	
	local roomType = game:GetRoom():GetType()
	if roomType == RoomType.ROOM_DEVIL then
		player:AddBrokenHearts(1)
	elseif roomType == RoomType.ROOM_ANGEL then
		player:AddBrokenHearts(-1)
	end	
end
BC15:AddCallback(IBS_CallbackID.PICK_COLLECTIBLE, 'OnPickItem')

--完成
function BC15:TryFinish()
	if self:IsUnfinished() and self:AtDestination() then
		self:Finish(true, true)
	end
end
BC15:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'TryFinish')


return BC15