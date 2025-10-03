--21点

local mod = Isaac_BenightedSoul
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Blackjack = mod.IBS_Class.Item(mod.IBS_ItemID.Blackjack)


--检查点数
function Blackjack:CheckPoints(player)
	if not player:HasCollectible(self.ID) then return end
	local data = self:GetIBSData('temp')
	local p = data.Blackjack or 0
	
	--超出范围
	if p > 21 or p < 0 then
		data.Blackjack = 0
		local id = p
		if id < 0 then id = -id end
		if id > 0 then
			player:AddCard(id)
			sfx:Play(268)
		end
	elseif p == 21 then --正好21点
		data.Blackjack = 0
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 100, 624, pos, Vector.Zero, nil)
		sfx:Play(268)
	end
end

--效果
function Blackjack:OnUseCard(id, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if not player:HasCollectible(self.ID) then return end

	--正塔罗牌
	if id >= 1 and id <= 22 then
		local data = self:GetIBSData('temp')
		local p = math.min(10, id - 1)
		data.Blackjack = data.Blackjack or 0
		data.Blackjack = data.Blackjack + p
		self:CheckPoints(player)
	end
	
	--倒塔罗牌
	if id >= 56 and id <= 77 then
		local data = self:GetIBSData('temp')
		local p = math.min(10, id - 56)
		data.Blackjack = data.Blackjack or 0
		data.Blackjack = data.Blackjack - p
		self:CheckPoints(player)
	end	
end
Blackjack:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard')


local spr = Sprite('gfx/ibs/ui/items/blackjack.anm2')
spr.Scale = Vector(0.5,0.5)
spr:Play('Idle')

local fnt = Font('font/pftempestasevencondensed.fnt')


--渲染提示
function Blackjack:OnRender()
	if not game:GetHUD():IsVisible() then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local data = self:GetIBSData('temp')
	local p = data.Blackjack or 0
	local pos = Vector(Isaac:GetScreenWidth() / 2, 16)
	fnt:DrawStringScaled(p, pos.X, pos.Y - 8, 1, 1, KColor(1,1,1,1))
	spr:Render(pos - Vector(10, 0))
end
Blackjack:AddCallback(ModCallbacks.MC_POST_RENDER, 'OnRender')

--为每个房间使用特定种子
local rng = RNG()
rng:SetSeed(1)
function Blackjack:RefreshSeed()
	rng:SetSeed(self._Levels:GetRoomUniqueSeed())
end
Blackjack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'RefreshSeed')

--清理房间触发
function Blackjack:OnRoomCleaned()
	if game:IsGreedMode() then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end

	if rng:RandomInt(100) < 10 then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition((room:GetCenterPos()), 0, true)
		Isaac.Spawn(5, 300, rng:RandomInt(1, 22), pos, Vector.Zero, nil)	
	end
end
Blackjack:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'OnRoomCleaned')

return Blackjack