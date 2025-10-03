--截图用具

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item

local game = Game()
local config = Isaac.GetItemConfig()

local ForScreenshot = mod.IBS_Class.Trinket(mod.IBS_TrinketID.ForScreenshot)


--模拟配方(按动画帧顺序)
local Recipe = {
	{Symbol = "h", Value = 1}, --红心
	{Symbol = "s", Value = 4}, --魂心
	{Symbol = "b", Value = 5}, --黑心
	{Symbol = "e", Value = 5}, --白心
	{Symbol = "g", Value = 5}, --金心
	{Symbol = "B", Value = 5}, --骨心
	{Symbol = "r", Value = 1}, --腐心
	{Symbol = ".", Value = 1}, --硬币
	{Symbol = "o", Value = 3}, --镍币
	{Symbol = "O", Value = 5}, --铸币
	{Symbol = "Q", Value = 8}, --幸运币
	{Symbol = "/", Value = 2}, --钥匙
	{Symbol = "|", Value = 7}, --金钥匙
	{Symbol = "%", Value = 5}, --电钥匙
	{Symbol = "v", Value = 2}, --炸弹
	{Symbol = "^", Value = 7}, --金炸弹
	{Symbol = "V", Value = 10}, --大炸弹
	{Symbol = "1", Value = 2}, --小电池
	{Symbol = "2", Value = 4}, --电池
	{Symbol = "3", Value = 8}, --大电池
	{Symbol = "[", Value = 2}, --卡牌
	{Symbol = "(", Value = 2}, --胶囊
	{Symbol = ">", Value = 4}, --符文
	{Symbol = "?", Value = 4}, --骰子碎片
	{Symbol = "~", Value = 2}, --红钥匙碎片
	{Symbol = "$", Value = 7}, --金币
	{Symbol = "{", Value = 7}, --金胶囊
	{Symbol = "4", Value = 7}, --金电池
	{Symbol = "_", Value = 0}, --便便
}

local Sequence = {} --合成序列
local Result = 25 --合成结果
local LastResult = 25 --上一次合成结果

--根据掉落物价值选取道具品质
local function GetQuality(value)
	if value < 8 then
		return math.random(0,1)
	elseif value >= 9 and value <= 14 then
		return math.random(0,2)
	elseif value >= 15 and value <= 18 then
		return math.random(1,2)
	elseif value >= 19 and value <= 22 then
		return math.random(2,3)
	elseif value >= 23 and value <= 26 then
		return math.random(2,4)
	elseif value >= 23 and value <= 26 then
		return math.random(2,4)
	elseif value >= 27 and value <= 34 then
		return math.random(3,4)
	elseif value > 35 then
		return 4
	end
	return 0
end

--重置序列和结果
local function RerollSequence(player)
	local value = 0

	for k,v in pairs(Sequence) do
		Sequence[k] = nil
	end
	for i = 1,8 do
		local frame = math.random(1,#Recipe)
		local tbl = Recipe[frame] or Recipe[1]
		Sequence[i] = frame
		value = value + tbl.Value
	end
	
	--有EID时利用EID获取更真实的模拟结果
	if EID then
		--EID配方更新
		if player then
			EID.bagPlayer = player
			EID:handleBagOfCraftingUpdating()
		end
		Result = EID:calculateBagOfCrafting(Sequence)
	else
		local quality = GetQuality(value)
		local seed = Random()
		local pool = game:GetItemPool():GetRandomPool(RNG(seed))
		Result = self._Pools:GetCollectibleWithQuality(seed, quality, pool, false, 25, true)
	end
end

RerollSequence()

--死亡时尝试复活为力里该隐
function ForScreenshot:PrePlayerDeath(player)
	if player:HasTrinket(self.ID) and player:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B then
		if player:GetTrinketMultiplier(self.ID) >= 2 then		
			player:ChangePlayerType(PlayerType.PLAYER_CAIN_B)
			player:SetPocketActiveItem(710, ActiveSlot.SLOT_POCKET, false)
			player:SetMinDamageCooldown(60)
			return false
		end
	end
end
ForScreenshot:AddPriorityCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, 200, 'PrePlayerDeath')


--拾起时
function ForScreenshot:OnGain(player)
	RerollSequence(player)
	
	--4级伪装
	for _,ent in ipairs(Isaac.FindByType(5,100)) do
		local pickup = ent:ToPickup()
		if pickup and pickup.SubType > 0 and not self._Ents:GetTempData(pickup).EnvyDisguise then
			local itemConfig = config:GetCollectible(pickup.SubType)
			if itemConfig and itemConfig.Quality < 4 then
				local seed = pickup.InitSeed
				local pool = self._Pools:GetRoomPool(seed)
				local disguiseID = self._Pools:GetCollectibleWithQuality(seed, 4, pool, false, 25, true, true)	
				self._Pickups:CollectibleDisguise(pickup, disguiseID)
			end
		end
	end
	
	--装扮	
	if player:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B then	
		player:AddNullCostume(NullItemID.ID_CAIN_B)
	end
end
ForScreenshot:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGain', ForScreenshot.ID)
ForScreenshot:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 'OnGain', ForScreenshot.ID+32768)

--失去时
function ForScreenshot:OnLose(player)
	if not player:HasTrinket(self.ID) then
		if player:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B then		
			player:TryRemoveNullCostume(NullItemID.ID_CAIN_B)
		end
		
	end
	
	--移除伪装
	if not PlayerManager.AnyoneHasTrinket(self.ID) then	
		for _,ent in ipairs(Isaac.FindByType(5,100)) do
			local pickup = ent:ToPickup()
			if pickup and pickup.SubType > 0 then
				self._Pickups:RemoveCollectibleDisguise(pickup)
			end
		end	
	end
end
ForScreenshot:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 'OnLose', ForScreenshot.ID)
ForScreenshot:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 'OnLose', ForScreenshot.ID+32768)


local bagSpr = Sprite('gfx/ibs/ui/items/ui_crafting.anm2'); bagSpr:Play('Bag')
local resultSpr = Sprite('gfx/ibs/ui/items/ui_crafting.anm2'); resultSpr:Play('Result')
local recipeSpr = Sprite('gfx/ibs/ui/items/ui_crafting.anm2'); recipeSpr:Play('Idle')
local itemSpr = Sprite('gfx/ibs/ui/items/ui_crafting.anm2'); itemSpr:Play('Item')

--默认结果是早餐
local itemConfig = config:GetCollectible(25)
if itemConfig then
	itemSpr:ReplaceSpritesheet(1, itemConfig.GfxFileName, true)
end	

--不显示在饰品栏,为玩家一显示伪合成袋
function ForScreenshot:OnTrinketRender(slot, pos, scale, player)
	if player.ControllerIndex ~= 0 then return end
	local trinket = player:GetTrinket(slot)
	if trinket ~= self.ID and trinket ~= self.ID + 32768 then return end
	
	--替换合成结果的贴图
	local itemConfig = config:GetCollectible(Result)
	if itemConfig and LastResult ~= Result then
		LastResult = Result
		itemSpr:ReplaceSpritesheet(1, itemConfig.GfxFileName, true)	
	end		
	
	--以合成袋副手位置为基准位置
	local offset = Options.HUDOffset
	local baseX = Isaac.GetScreenWidth() - 20 - 16*offset
	local baseY = Isaac.GetScreenHeight() - 14 - 6*offset
	
	--渲染合成袋
	bagSpr:Render(Vector(baseX,baseY))
	
	--渲染结果
	resultSpr:Render(Vector(baseX - 26, baseY - 1))
	itemSpr:Render(Vector(baseX - 26, baseY - 1))
	
	--渲染配方
	for slot,frame in ipairs(Sequence) do
		local colum = slot % 4 + 1
		recipeSpr:SetFrame(frame)
		recipeSpr:Render(Vector(baseX - 102 + colum *12, baseY + 5 + ((slot > 4 and -12) or 0)))
	end
	
	return true
end
ForScreenshot:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_TRINKET_RENDER, 'OnTrinketRender')


return ForScreenshot