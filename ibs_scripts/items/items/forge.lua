--白日之铸

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local Forge = mod.IBS_Class.Item(mod.IBS_ItemID.Forge)

--获得时生成审判卡
function Forge:OnGain(item, charge, first, slot, varData, player)
	if first then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
		Isaac.Spawn(5, 300, 21, pos, Vector.Zero, nil)
	end
end
Forge:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', Forge.ID)

--生成火焰特效
function Forge:SpawnFlame(pos, scale, timeout)
	local flame = Isaac.Spawn(1000,52, 0, pos, Vector.Zero, nil):ToEffect()
	flame.Timeout = timeout or 30
	flame.Scale = scale or 1
	flame.DepthOffset = 10
	return flame
end

--使用审判卡
function Forge:OnUseCard(card, player)
	if player:HasCollectible(self.ID) then
		for i = 0,1 do
			local id = player:GetTrinket(0)
			if id > 0 then
				--变为金饰品并吞下
				player:TryRemoveTrinket(id)
				player:AddSmeltedTrinket((id - 32768 < 0 and id+32768) or id, false)
				self:SpawnFlame(player.Position, math.max(player.SpriteScale.X, player.SpriteScale.Y))
				sfx:Play(43)
			end
		end		
	end
end
Forge:AddCallback(ModCallbacks.MC_USE_CARD, 'OnUseCard', 21)


--机器列表
Forge.MachineList = {1, 2, 3, 10}
Forge.MachineList2 = {}
for _,v in ipairs(Forge.MachineList) do
	Forge.MachineList2[v] = true
end


--乞丐列表
Forge.BeggerList = {4, 5, 7, 9, 13, 18}
Forge.BeggerList2 = {}
for _,v in ipairs(Forge.BeggerList) do
	Forge.BeggerList2[v] = true
end

--可互动实体生成摧毁时
function Forge:OnExplosion(slot)
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local pos = slot.Position
		
		--机器
		if self.MachineList2[slot.Variant] then 
			local rng = RNG(slot.InitSeed)
			if rng:RandomInt(100) < 60 then
				Isaac.Spawn(5, 300, 21, pos,  RandomVector(), nil)
				self:SpawnFlame(slot.Position, 2)
				slot:Remove()
				sfx:Play(43)
			else
				Isaac.Spawn(5, 40, 0, pos, RandomVector(), nil)
			end		
		end
		
		--乞丐
		if self.BeggerList2[slot.Variant] then
			local rng = RNG(slot.InitSeed)
			if rng:RandomInt(100) < 60 then
				Isaac.Spawn(6, self.MachineList[rng:RandomInt(1,#self.MachineList)] or 4, 0, pos, RandomVector(), nil)
				self:SpawnFlame(slot.Position, 2)
				slot:Remove()
				sfx:Play(43)
			else
				Isaac.Spawn(5, 40, 0, pos, RandomVector(), nil)
			end				
		end
	end
end
Forge:AddCallback(ModCallbacks.MC_POST_SLOT_CREATE_EXPLOSION_DROPS, 'OnExplosion')


return Forge