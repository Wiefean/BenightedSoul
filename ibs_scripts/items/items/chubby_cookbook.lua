--蛆虫食谱

local mod = Isaac_BenightedSoul

local game = Game()

local ChubbyCookbook = mod.IBS_Class.Item(mod.IBS_ItemID.ChubbyCookbook)


--生成列表
ChubbyCookbook.SpawnList = {
	{T = 21, V = 0, S = 0}, --蝇蛆
	{T = 23, V = 0, S = 0}, --冲锋蛆
	{T = 23, V = 0, S = 0}, --冲锋蛆
	{T = 23, V = 0, S = 0}, --冲锋蛆
	{T = 23, V = 0, S = 0}, --冲锋蛆
	{T = 23, V = 0, S = 0}, --冲锋蛆
	{T = 23, V = 1, S = 0}, --溺水冲锋蛆
	{T = 23, V = 1, S = 0}, --溺水冲锋蛆
	{T = 23, V = 1, S = 0}, --溺水冲锋蛆
	{T = 23, V = 2, S = 0}, --阴湿冲锋蛆
	{T = 23, V = 2, S = 0}, --阴湿冲锋蛆
	{T = 23, V = 2, S = 0}, --阴湿冲锋蛆
	{T = 31, V = 0, S = 0}, --吐血蛆
	{T = 31, V = 0, S = 0}, --吐血蛆
	{T = 31, V = 0, S = 0}, --吐血蛆
	{T = 31, V = 0, S = 0}, --吐血蛆
	{T = 31, V = 1, S = 0}, --堕化吐血蛆
	{T = 39, V = 2, S = 0}, --蛆开膛怪
	{T = 39, V = 2, S = 0}, --蛆开膛怪
	{T = 243, V = 0, S = 0}, --双头吐血蛆
	{T = 243, V = 0, S = 0}, --双头吐血蛆
	{T = 243, V = 0, S = 0}, --双头吐血蛆
	{T = 853, V = 0, S = 0}, --冲锋蛆2
	{T = 853, V = 0, S = 0}, --冲锋蛆2
}

--获取数据
function ChubbyCookbook:GetData(player)
	local data = self._Players:GetData(player)
	data.ChubbyCookbook = data.ChubbyCookbook or {UsedTimes = 0}
	return data.ChubbyCookbook
end

--生成
function ChubbyCookbook:SpawnMascot(player, rng)
	local list = self.SpawnList
	local mascot = list[rng:RandomInt(1, #list)] or {T = 23, V = 0, S = 0}
	local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
	
	local ent = Isaac.Spawn(mascot.T, mascot.V, mascot.S, pos, Vector.Zero, player)
	ent:AddCharmed(EntityRef(player), -1)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
	ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)

	--彼列书
	--我的影子
	if player:HasCollectible(59) then
		local pos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)		
		local shadow = Isaac.Spawn(23, 0, 1, pos, Vector.Zero, player)
		shadow:AddCharmed(EntityRef(player), -1)
		shadow:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
		shadow:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)	
	end
end

--使用
function ChubbyCookbook:OnUse(item, rng, player, flags)
	local data = self:GetData(player)
	data.UsedTimes = data.UsedTimes + 1

	for i = 1,data.UsedTimes do
		self:SpawnMascot(player, rng, false)
	end

	--美德书
	if player:HasCollectible(584) and data.UsedTimes > 1 then
		for i = 1,(data.UsedTimes - 1) do
			player:AddWisp(self.ID, player.Position)
		end	
	end

	if data.UsedTimes >= 6 then 
		data.UsedTimes = data.UsedTimes - 6
	end
	
	return true
end
ChubbyCookbook:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', ChubbyCookbook.ID)


--显示使用次数
local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")
function ChubbyCookbook:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local data = self:GetData(player)

	local stringNum = tostring(data.UsedTimes)
	local color = KColor(1,1,1,1)

	if data.UsedTimes >= 5 then
		color = KColor(1,1,0,1)
	end
	
	local pos = Vector(scale, scale) + offset
	stringNum = "x"..stringNum
	fnt:DrawStringScaled(stringNum, pos.X, pos.Y, scale * 0.75, scale * 0.75, color)
end
ChubbyCookbook:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return ChubbyCookbook
