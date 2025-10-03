--遗骸的伪忆

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()

local BForgotten = mod.IBS_Class.Pocket(mod.IBS_PocketID.BForgotten)

--获取满足要求的道具ID
function BForgotten:GetItemID(player, seed)
	local result = {}
	
	--已从道具池中移除,可召唤,角色未持有的被动道具
	for id,removed in ipairs(game:GetItemPool():GetRemovedCollectibles()) do
		if removed and not player:HasCollectible(id, true) then
			local itemConfig = config:GetCollectible(id)
			if itemConfig and itemConfig:HasTags(ItemConfig.TAG_SUMMONABLE) and itemConfig.Type ~= ItemType.ITEM_ACTIVE then				
				if itemConfig.Quality >= 2 then
					--不重复的道具魂火
					if not player:GetWispCollectiblesList()[id] then
						table.insert(result, id)
					end
				end
			end
		end
	end
	
	--抽取一个
	if #result > 0 then
		return result[RNG(seed):RandomInt(1, #result)] or result[1]
	end
	
	--默认悲伤洋葱
	return 1
end

--使用
function BForgotten:OnUse(card, player, flag)
	for i = 1,3 do
		local id = self:GetItemID(player, player:GetCardRNG(self.ID):Next())
		if id then
			local wisp = player:AddItemWisp(id, player.Position + math.random(100, 200) * RandomVector(), true)
			wisp.MaxHitPoints = wisp.MaxHitPoints * 2
			wisp.HitPoints = wisp.HitPoints * 2
		end
	end

	--骨头环绕物
	for i = 1,12 do
		player:AddBoneOrbital(player.Position + math.random(100, 200) * RandomVector())
	end
	SFXManager():Play(27)
	SFXManager():Play(33)
	game:ShakeScreen(20)
end
BForgotten:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUse', BForgotten.ID)

--符文佩剑(东方mod)
if mod.IBS_Compat.THI:IsEnabled() then
	local RuneSword = THI.Collectibles.RuneSword

	mod.IBS_Compat.THI:AddRuneSwordCompat(BForgotten.ID, {
		png = "gfx/ibs/items/pick ups/falsehoods/BForgotten.png",
		textKey = "FALSEHOOD_BFORGOTTEN",
		name = {
			zh = "遗骸的伪忆",
			en = "Falsehood of the Forgotten",
		},
		desc = {
			zh = "骨头帮",
			en = "Bony Gang",
		}, 
	})
	
	--杀敌触发
	function BForgotten:OnEntityKilled(ent)
		if not self._Ents:IsEnemy(ent, true) then return end
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local num = RuneSword:GetInsertedRuneNum(player, self.ID)
			if num > 0 and player:GetTrinketRNG(167):RandomInt(100) < 18*num then	
				local bony = Isaac.Spawn(227,0,0, ent.Position, Vector.Zero, player)
				bony:AddCharmed(EntityRef(player), -1)
			end
		end
	end
	BForgotten:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, 'OnEntityKilled')
	
end


return BForgotten