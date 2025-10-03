--薇艺

local mod = Isaac_BenightedSoul

local game = Game()

local BXXX = mod.IBS_Player.BXXX
local Memories = mod.IBS_Class.Memories()
local MemoryPickup = mod.IBS_Pickup.Memory
local Falowerse = mod.IBS_Class.Item(mod.IBS_ItemID.Falowerse)

--死亡时复活伪表表蓝
function Falowerse:PrePlayerDeath(player)
	if player:HasCollectible(self.ID) then
		player:RemoveCollectible(self.ID)
		player:ChangePlayerType(BXXX.ID)
		Memories:Add(70)
		player:UseActiveItem(127, false, false)
		self:DelayFunction2(function()
			player:AddSoulHearts(5)
		end, 0)
		SFXManager():Play(53)
		return false
	end
end
Falowerse:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, 'PrePlayerDeath')

--生成伪忆三选一
function Falowerse:SpawnFalsehoods(spawner, pos)
	local idx = self._Pickups:GetUniqueOptionsIndex()
	for _ = 1,3 do
		local falsehood = self._Pools:GetRandomFalsehood(self:GetRNG("Player_BXXX"))
		local pickup = Isaac.Spawn(5, 300, falsehood, pos or spawner.Position, Vector.Zero, spawner):ToPickup()
		pickup.OptionsPickupIndex = idx
		pickup.Velocity = RandomVector()
		pickup.Wait = 45
	end
	if spawner:ToPlayer() then
		spawner:ToPlayer():AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
	end
end

--使用时生成伪忆三选一
function Falowerse:OnUse(item, rng, player, flags)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then
	
		--特定条件下阻止触发效果
		if (flags & UseFlag.USE_OWNED > 0) then --持有
			if player:GetPlayerType() == BXXX.ID then --表表蓝
				BXXX:GetData(player).FalowerseUsed = true
				SFXManager():Play(53)
				return {ShowAnim = true, Remove = true}
			end
		end

		--虚空
		if (flags & UseFlag.USE_VOID > 0) then
			self:SpawnFalsehoods(player)
		else
			if Memories:GetNum() >= 21 then
				Memories:Add(-21)
				self:SpawnFalsehoods(player)
				return true
			end
		end
		
		return false
	end
end
Falowerse:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Falowerse.ID)

--按住丢弃键时拆道具
function Falowerse:PrePickupCollision(pickup, other)
	local player = other:ToPlayer()

	if player and player:HasCollectible(self.ID, true) and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then	
		--角色为表表蓝人时跳过
		if player:GetPlayerType() == BXXX.ID then
			return
		end

		if Memories:DecomposePickup(pickup, true) then
			player:AnimateSad()
			return true
		end
	end
end
Falowerse:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'PrePickupCollision')

local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

--显示记忆碎片数量
function Falowerse:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	if player:GetPlayerType() == BXXX.ID then return end
	local pos = Vector(10*scale, 16*scale) + offset

	local num,MAX = Memories:GetNum(),Memories:GetMax()
	local stringNum = tostring(num)
	local color = KColor(1,1,1,1)
	
	if num >= MAX then
		color = KColor(1,1,0,1)
	end
	
	stringNum = "x"..stringNum
	fnt:DrawStringScaled(stringNum, pos.X, pos.Y, scale * 0.75, scale * 0.75, color)	
end
Falowerse:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')


return Falowerse