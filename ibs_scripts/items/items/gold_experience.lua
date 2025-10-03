--黄金体验

--[[原版硬币心机制:
自动清除半空的硬币心
硬币心一次最多只会受到一心伤害
在硬币增加时尝试恢复硬币心
受伤生成硬币效果生成的硬币数量改为0~1个
]]

--[[说明:
对于模组,无法实现对不同玩家获得硬币的检测,
所以模组硬币心只能通过拾取硬币恢复
(也有可能只是我技术力不足)

为了还原受伤生成硬币数量减少的效果,
这里的自定义硬币心受伤时有50%概率移除生成的硬币
]]

local mod = Isaac_BenightedSoul

local game = Game()

local GoldExperience = mod.IBS_Class.Item(mod.IBS_ItemID.GoldExperience)


--临时玩家数据(用于渲染硬币心以及临时储存硬币数量)
function GoldExperience:GetTempData(player)
	local data = self._Ents:GetTempData(player)
	
	if not data.GoldExperience then
		local fullSpr = Sprite()
		fullSpr:Load("gfx/ibs/ui/coinheart.anm2", true)
		fullSpr:Play("Full")		

		local emptySpr = Sprite()
		emptySpr:Load("gfx/ibs/ui/coinheart.anm2", true)
		emptySpr:Play("Empty")

		local fullSpr2 = Sprite()
		fullSpr2:Load("gfx/ibs/ui/coinheart.anm2", true)
		fullSpr2:Play("Full")		

		local emptySpr2 = Sprite()
		emptySpr2:Load("gfx/ibs/ui/coinheart.anm2", true)
		emptySpr2:Play("Empty")

		data.GoldExperience = {
			PickingCoins = false,
			HurtCoinHeart = false, --用于尝试移除玩家生成的硬币
			SpriteFull = fullSpr,
			SpriteEmpty = emptySpr,
			SpriteFull2 = fullSpr2, --用于表骨
			SpriteEmpty2 = emptySpr2 --用于表骨
		}
		
		data.GoldExperience.SpriteFull2.Color = Color(1,1,1,0.3)
		data.GoldExperience.SpriteEmpty2.Color = Color(1,1,1,0.3)		
	end
	
	return data.GoldExperience
end

--长久玩家数据(用于储存硬币心数量)
function GoldExperience:GetData(player, returnAnotherFormData)
	local playerType = player:GetPlayerType()
	local data = self._Players:GetData(player, true) --true表示区分表骨和其灵魂的数据
	data.GoldExperience = data.GoldExperience or {Num = 0}
	
	--为表骨的另一形态预先创建数据
	if (playerType == 16) or (playerType == 17) then
		local data2 = self._Players:GetDataOfAnotherForm(player)
		data2.GoldExperience = data2.GoldExperience or {Num = 0}

		--可选择是否返回表骨的另一形态数据
		if returnAnotherFormData then
			return data2.GoldExperience
		end
	end
	
	return data.GoldExperience
end

--获得
function GoldExperience:OnGain(item, charge, first, slot, varData, player)
	if first then
		local playerType = player:GetPlayerType()
		
		if (playerType == 14) or (playerType == 33) then --表里店长吞下妈吻
			player:AddSmeltedTrinket(156)
		else
			local data = self:GetData(player)
			local tData = self:GetTempData(player)
			player:AddBrokenHearts(1)
			data.Num = math.min(data.Num + 1, player:GetBrokenHearts())
			tData.SpriteFull:Play('Heal')
		end
	end
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', GoldExperience.ID)


--拾取硬币检测
function GoldExperience:OnCoinCollision(pickup, other)
	local player = other:ToPlayer()
	if player and player:HasCollectible(self.ID) and self._Pickups:CanCollect(pickup, player) then
		self:GetTempData(player).PickingCoins = true
	end	
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, 'OnCoinCollision', PickupVariant.PICKUP_COIN)

--硬币心更新
function GoldExperience:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	local playerType = player:GetPlayerType() if (playerType == 10) or (playerType == 31) or (playerType == 14) or (playerType == 33) then return end --忽略表里店长游魂
	local data = self:GetData(player)
	local tData = self:GetTempData(player)
	local MAX = player:GetBrokenHearts()
	local coin = player:GetNumCoins()
	
	--修正
	if data.Num > MAX then data.Num = MAX end
	if data.Num < 0 then data.Num = 0 end

	--尝试恢复硬币心
	if tData.PickingCoins and (data.Num < MAX) then
		data.Num = data.Num + 1
		player:AddCoins(-1)
		tData.SpriteFull:Play("Heal")
	end

	tData.PickingCoins = false
	tData.HurtCoinHeart = false
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerUpdate', 0)

--硬币心受伤判定
function GoldExperience:OnTakeDMG(ent, dmg, flag, source, cd)
	if (dmg <= 0) then return end
	local player = ent:ToPlayer()
	
	if player then
		local slot = (source.Type == 6 and source.Entity) --可互动实体
		
		--持有道具,非游魂诅咒
		if player:HasCollectible(self.ID) and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
			local playerType = player:GetPlayerType() if (playerType == 10) or (playerType == 31) or (playerType == 14) or (playerType == 33) then return end --忽略表里店长游魂
			local tData = self:GetTempData(player)
			local data = self:GetData(player)
			
			if data.Num > 0 then
				data.Num = math.max(0, data.Num - 1)
				tData.HurtCoinHeart = true --用于尝试移除玩家生成的硬币

				--用于尝试移除可互动实体生成的硬币(主要是献血机)
				if slot then
					self._Ents:GetTempData(slot).GoldExperience_HurtCoinHeart = true
				end

				return {Damage = 1, DamageFlags = flag | DamageFlag.DAMAGE_FAKE, DamageCountdown = cd}
			end
		elseif slot then
			self._Ents:GetTempData(slot).GoldExperience_HurtCoinHeart = nil
		end	
	end
end	
GoldExperience:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1, 'OnTakeDMG')

--尝试移除玩家生成的硬币
function GoldExperience:OnCoinInit(pickup)
	local player = self._Ents:IsSpawnerPlayer(pickup, true)
	if player then
		local tData = self._Ents:GetTempData(player).GoldExperience
		if tData and tData.HurtCoinHeart then
			local rng = RNG()
			rng:SetSeed(pickup.InitSeed, 35)
			if rng:RandomFloat() < 0.5 then
				pickup:Remove()
			end
		end	
	end
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnCoinInit', PickupVariant.PICKUP_COIN)

--尝试移除可互动实体生成的硬币(主要是献血机)
function GoldExperience:OnSlotUpdate(slot)
	if self._Ents:GetTempData(slot).GoldExperience_HurtCoinHeart and slot:GetSprite():IsEventTriggered("Prize") then
		self:DelayFunction2(function()
			for _,pickup in ipairs(Isaac.FindByType(5,20)) do
				if (pickup.FrameCount <= 1) and (not pickup.SpawnerEntity) and (pickup.Position:DistanceSquared(slot.Position) <= 400) then
					local rng = RNG()
					rng:SetSeed(pickup.InitSeed, 35)
					if rng:RandomFloat() < 0.5 then
						pickup:Remove()
					end
				end
			end
		end, 2, nil, true)
		self._Ents:GetTempData(slot).GoldExperience_HurtCoinHeart = nil
	end
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, 'OnSlotUpdate')

--为角色渲染硬币心
function GoldExperience:RenderCoinContainers(player, index)
	local playerType = player:GetPlayerType() if (playerType == 10) or (playerType == 31) or (playerType == 14) or (playerType == 33) then return end --忽略表里店长游魂
	local MAX = player:GetBrokenHearts()
	local data = self:GetData(player)
	local tData = self:GetTempData(player)
	local pos,firstPos,column,maxColumn,intervalX = Vector.Zero,Vector.Zero,0,0,12

	--获取碎心槽位
	local slot = 1 + math.ceil(player:GetMaxHearts() / 2) + math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts()
	if player.Parent then
		pos,firstPos,column,maxColumn = self._Screens:GetSubPlayerHpRenderInfo(player, slot)
	elseif (index ~= nil) then
		pos,firstPos,column,maxColumn,intervalX = self._Screens:GetPlayerHpRenderInfo(player, index, slot)
	end	

	--为游魂诅咒调整贴图透明度
	if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
		tData.SpriteFull.Color = Color(1,1,1,0.3)
		tData.SpriteEmpty.Color = Color(1,1,1,0.3)
	else
		tData.SpriteFull.Color = Color(1,1,1,1)
		tData.SpriteEmpty.Color = Color(1,1,1,1)
	end

	--反向排列心时水平翻转贴图(其实只有以扫是反向排列)
	if intervalX < 0 then
		tData.SpriteFull.FlipX = true
		tData.SpriteEmpty.FlipX = true
	else
		tData.SpriteFull.FlipX = false
		tData.SpriteEmpty.FlipX = false
	end

	--在碎心上渲染硬币心容器
	for i = 1,MAX do
		if i <= data.Num then
			tData.SpriteFull:Render(pos)
		else
			tData.SpriteEmpty:Render(pos)
		end

		pos.X = pos.X + intervalX
		column = column + 1

		if column > maxColumn then
			column = 1
			pos.X = firstPos.X
			pos.Y = pos.Y + 10
		end
	end

	--调整动画
	if tData.SpriteFull:IsPlaying("Heal") and not game:IsPaused() then
		tData.SpriteFull:Update()
	end
	if tData.SpriteFull:IsFinished("Heal") then
		tData.SpriteFull:Play("Full")
	end


	--为表骨的另一形态渲染硬币心
	if (not player.Parent) and (playerType == 16 or playerType == 17) and player:GetSubPlayer() then	
		local player2 = player:GetSubPlayer()
		local MAX2 = player2:GetBrokenHearts() if (MAX2 <= 0) then return end
		local data2 = self:GetData(player, true)
		local slot2 = 1 + maxColumn + math.ceil(player2:GetMaxHearts() / 2) + math.ceil(player2:GetSoulHearts() / 2) + player2:GetBoneHearts()
		local pos2,firstPos2,column2 = self._Screens:GetPlayerHpRenderInfo(player2, index, slot2)

		--渲染
		for i = 1,MAX2 do
			if i <= data2.Num then
				tData.SpriteFull2:Render(pos2)
			else
				tData.SpriteEmpty2:Render(pos2)
			end

			pos2.X = pos2.X + 12
			column2 = column2 - 1
			if column2 > maxColumn then
				column2 = 1
				pos2.X = firstPos2.X
				pos2.Y = pos2.Y + 10
			end
		end	
	end
end

--渲染回调
function GoldExperience:OnRender()
	--HUD不可见或未知诅咒则直接跳过
	if (not game:GetHUD():IsVisible()) or (game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0) then return end
	local controllers = {} --用于为控制器编号
	local index = 0

	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local cid = player.ControllerIndex

		if (player.Variant == 0) and not player:IsCoopGhost() then
			if player.Parent then --副角色无需考虑玩家号数
				if player:HasCollectible(self.ID) then
					self:RenderCoinContainers(player)
				end
			elseif not controllers[cid] then --主角色考虑玩家号数
				if player:HasCollectible(self.ID) then
					self:RenderCoinContainers(player, index)
				end

				--双子兼容
				if (index == 0) and (player:GetPlayerType() == PlayerType.PLAYER_JACOB) and player:GetOtherTwin() then
					local player2 = player:GetOtherTwin()
					if player2:HasCollectible(self.ID) then
						self:RenderCoinContainers(player2, index)
					end	
				end	

				controllers[cid] = true
				index = index + 1
			end
		end
	end
end
GoldExperience:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnRender')



return GoldExperience