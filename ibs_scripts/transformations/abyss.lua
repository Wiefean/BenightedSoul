--无底坑

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Abyss = mod.IBS_Class.Transformation("trans_abyss", {
	Name = {
		zh = '无底坑！',
		en = 'Abyss!',
	},

	CostumeID = Isaac.GetCostumeIdByPath('gfx/ibs/characters/trans_abyss.anm2'),

	ItemList = {
		[16] = true, --生肝
		[69] = true, --巧克力牛奶
		[129] = true, --猪油
		[218] = true, --胎盘
		[336] = true, --烂洋葱
		[399] = true, --黑圈
		[402] = true, --混沌
		[418] = true, --水果蛋糕
		[443] = true, --苹果
		[477] = true, --虚空
		[479] = true, --熔炉
		[495] = true, --断魂椒
		[512] = true, --黑洞
		[538] = true, --弹珠袋
		[561] = true, --杏仁奶
		[606] = true, --邪眼裂口
		[616] = true, --鸟眼椒
		[618] = true, --烂番茄
		[639] = true, --难吃的心
		[664] = true, --大胃王
		[672] = true, --一磅肉
		[681] = true, --黑洞宝宝
		[700] = true, --回声室
		[706] = true, --无底坑
		
		[IBS_ItemID.SSG] = true, --仰望星空
		[IBS_ItemID.ForbiddenFruit] = true, --禁断之果
		[IBS_ItemID.ChubbyCookbook] = true, --蛆虫食谱
		[IBS_ItemID.Molekale] = true, --分子植物
		[IBS_ItemID.Ssstew] = true, --炖蛇羹
		[IBS_ItemID.DeciduousMeat] = true, --剥落古老肉
	},
})


--尝试吞下饰品
function Abyss:TrySmeltTrinkets(player)
	local chance = 9
	
	if player:HasCollectible(IBS_ItemID.Hoarding) then
		chance = chance + 3 * self:GetCount(player)
	end

	if player:GetCollectibleRNG(706):RandomInt(100) < chance then
		if self._Players:SmeltTrinkets(player, true) then
			player:AddHearts(1)
		end
		return true
	end
	
	return false
end

--受伤
function Abyss:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	if player and self:IsOwned(player) then
		self:TrySmeltTrinkets(player)
	end
end
Abyss:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--新层
function Abyss:OnNewLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self:IsOwned(player) then
			self:TrySmeltTrinkets(player)
		end
	end
end
Abyss:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--虚空增强(吸收饰品)
function Abyss:VoidUp(item, rng, player, flags)
	if self:IsOwned(player) then
		for _,ent in ipairs(Isaac.FindByType(5, 350)) do
			local trinket = ent:ToPickup()
			if trinket.SubType > 0 and trinket.Price == 0 then
				player:AddSmeltedTrinket(trinket.SubType, trinket.Touched)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil)						
				trinket:Remove()
			end
		end
	end
end
Abyss:AddCallback(ModCallbacks.MC_USE_ITEM, "VoidUp", 477)


--无底坑增强(吸收饰品)
function Abyss:AbyssUp(item, rng, player, flags)
	if self:IsOwned(player) then
		for _,ent in ipairs(Isaac.FindByType(5, 350)) do
			local trinket = ent:ToPickup()
			if trinket.SubType > 0 and trinket.Price == 0 then
				local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 2, trinket.Position, Vector.Zero, player):ToFamiliar()
				locust.Player = player
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil)						
				trinket:Remove()
			end
		end		
	end
end
Abyss:AddCallback(ModCallbacks.MC_USE_ITEM, "AbyssUp", 706)	

--鸭脖自带1进度
function Abyss:OnPlayerInit(player)
	local playerType = player:GetPlayerType()
	if playerType == 15 or playerType == 34 then	
		self:DelayFunction2(function()
			if not self:IsGameContinued() then
				self:AddCount(player, 1)
			end
		end, 1)
	end
end
Abyss:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, 'OnPlayerInit')

return Abyss