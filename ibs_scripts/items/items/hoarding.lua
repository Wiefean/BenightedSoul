--成套收集

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local config = Isaac.GetItemConfig()

local Hoarding = mod.IBS_Class.Item(mod.IBS_ItemID.Hoarding)

--获得道具触发
function Hoarding:OnGainItem(item, charge, first, slot, varData, player)
	if slot > 1 then return end
	if first and player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(item)
	
		if itemConfig then

			--恶魔套件给黑心
			if itemConfig:HasTags(ItemConfig.TAG_DEVIL) then
				player:AddBlackHearts(1)
			end

			--天使套件给魂心
			if itemConfig:HasTags(ItemConfig.TAG_ANGEL) then
				player:AddSoulHearts(2)
			end

			--蘑菇套件概率给心容
			if itemConfig:HasTags(ItemConfig.TAG_MUSHROOM) then
				if player:GetCollectibleRNG(self.ID):RandomInt(100) < 50 then
					player:AddMaxHearts(2)
					player:AddHearts(2)
				end
			end

			--刷新属性
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end
end
Hoarding:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGainItem')

--失去道具触发
function Hoarding:OnLoseItem(player, item)
	if player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(item)

		if itemConfig then
			--刷新属性
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end
end
Hoarding:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, 'OnLoseItem')


--使用道具触发
function Hoarding:OnUseItem(item, rng, player)
	if player:HasCollectible(self.ID) then
		local itemConfig = config:GetCollectible(item)
	
		if itemConfig then
			local maxCharges = itemConfig.MaxCharges or 0

			if itemConfig.ChargeType == ItemConfig.CHARGE_TIMED then
				maxCharges = 1
			end

			if maxCharges > 12 then --用作某些特殊充能道具
				maxCharges = 1
			end

			--书套件给护盾
			if itemConfig:HasTags(ItemConfig.TAG_BOOK) then
				local num = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_BOOK_WORM)
				if num > 0 then				
					self._Players:AddShield(player, 15*num*maxCharges)
				end
			end
		end
	end
end
Hoarding:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, -9999, 'OnUseItem')

--使用青春期药丸触发
function Hoarding:OnUsePubertyPill(pill, player)
	if player:HasCollectible(self.ID) then
		--成人套件给白心
		player:AddEternalHearts(1)
	end
end
Hoarding:AddPriorityCallback(ModCallbacks.MC_USE_PILL, 9999, 'OnUsePubertyPill', PillEffect.PILLEFFECT_PUBERTY)

--角色受伤前判定
function Hoarding:PrePlayerTakeDMG(player, dmg, flag)
	if player:HasCollectible(self.ID) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) then
		--鲍勃套件爆炸免疫
		if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_BOB) >= 3 then
			return false
		end
	end
end
Hoarding:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -800, 'PrePlayerTakeDMG')


--受伤触发
function Hoarding:OnTakeDamage(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end

	if self._Ents:IsEnemy(ent) then
		local extraDMG = 0

		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local rng = player:GetCollectibleRNG(self.ID)

				--猫套件概率生成蓝苍蝇
				local guppy = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY)
				if guppy > 0 then
					for i = 1,guppy do	
						if rng:RandomInt(100) < 10 then
							player:AddBlueFlies(1, player.Position, nil)
						end
					end
				end

				--妈套件妈刀额外伤害
				local mom = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_MOM)
				if mom > 0 then
					extraDMG = extraDMG + (mom * 0.25)
				end
			end
		end

		if extraDMG > 0 then
			return {Damage = dmg + extraDMG, DamageFlags = flag, DamageCountdown = cd}
		end
	end	
end
Hoarding:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, 'OnTakeDamage')

--击杀敌人触发
function Hoarding:OnEntityKilled(ent)
	if self._Ents:IsEnemy(ent, true) then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local rng = player:GetCollectibleRNG(self.ID)

				--苍蝇套件生成蓝苍蝇
				local fly = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES)
				if fly > 0 then
					for i = 1,fly do	
						if rng:RandomInt(100) < 50 then
							player:AddBlueFlies(1, player.Position, nil)
						end
					end				
				end
			end
		end	
	end
end
Hoarding:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')

--角色碰撞触发
function Hoarding:OnPlayerCollision(player, other)
	if player:IsFrame(7,0) and player:HasCollectible(self.ID) and self._Ents:IsEnemy(other) then
		--践踏套件碰撞伤害
		local stompy = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_STOMPY)
		if stompy > 0 then
			other:TakeDamage(20 * stompy, 0, EntityRef(player), 0)
		end
	end
end
Hoarding:AddCallback(ModCallbacks.MC_POST_PLAYER_COLLISION, 'OnPlayerCollision')

--大便套件回血
function Hoarding:OnPoopBreak()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_POOP) >= 3 then
				player:AddHearts(2)
			end
		end
	end
end
Hoarding:AddCallback(mod.IBS_CallbackID.POOP_BREAK, 'OnPoopBreak')

--新房间触发
function Hoarding:OnNewRoom()
	if not game:GetRoom():IsFirstVisit() then return end
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local rng = player:GetCollectibleRNG(self.ID)
			
			--蜘蛛套件生成蓝蜘蛛
			local spider = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_SPIDERBABY)
			if spider > 0 then
				for i = 1,spider do
					player:AddBlueSpider(player.Position)
					player:AddBlueSpider(player.Position)
				end
			end
		end
	end
end
Hoarding:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--贪婪模式新波次触发
function Hoarding:OnGreedNewWave()
	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local rng = player:GetCollectibleRNG(self.ID)
			
			--蜘蛛套件生成蓝蜘蛛
			local spider = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_SPIDERBABY)
			if spider > 0 then
				for i = 1,spider do
					player:AddBlueSpider(player.Position)
					player:AddBlueSpider(player.Position)
				end
			end
		end
	end
end
Hoarding:AddCallback(IBS_CallbackID.GREED_NEW_WAVE, 'OnGreedNewWave')

--属性变动
function Hoarding:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_LUCK then
			self._Stats:Luck(player, player:GetCollectibleNum(self.ID))
		end
	
		--针套件给伤害
		if flag == CacheFlag.CACHE_DAMAGE then
			local drug = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_DRUGS)
			if drug > 0 then
				self._Stats:Damage(player, 0.25*drug)
			end
		end
		
		--宝宝套件给射速
		if flag == CacheFlag.CACHE_FIREDELAY then
			local baby = player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_BABY)
			if baby > 0 then
				self._Stats:TearsModifier(player, 0.15*baby)	
			end
		end	
	end	
end
Hoarding:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')


return Hoarding