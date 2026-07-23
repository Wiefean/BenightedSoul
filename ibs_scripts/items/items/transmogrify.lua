--变形术

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local Transmogrify = mod.IBS_Class.Item(IBS_ItemID.Transmogrify)

--使用效果
function Transmogrify:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		local owned = (flags & UseFlag.USE_OWNED > 0) --是否拥有
		local item = self._Finds:ClosestCollectible(player.Position)
		
		if item ~= nil then
			local newItem = 25
		
			--小概率变为切片器
			if rng:RandomInt(100) < 1 then
				newItem = IBS_ItemID.CheeseCutter
			else
				--重置为1级道具
				local pool = self._Pools:GetRoomPool(self._Levels:GetRoomUniqueSeed())
				newItem = self._Pools:GetCollectibleWithQuality(rng:Next(), 1, pool, true)
			end
			
			item:Morph(5,100,newItem,true)
			item.Touched = false
			
			--烟雾特效
			Isaac.Spawn(1000,15,0, item.Position, Vector.Zero, nil)		
		end
	end	
	
	return true
end
Transmogrify:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Transmogrify.ID)

--蝗虫和蓝苍蝇抵挡敌弹
function Transmogrify:OnWsipCollision(wisp, other)
	if wisp.SubType ~= self.ID then return end
	if other and self._Ents:IsEnemy(other, false, false, true) and RNG(other.InitSeed):RandomInt(100) < 10 then
		Isaac.Spawn(13,0,0, other.Position, Vector.Zero, nil)
		Isaac.Spawn(1000,15,0, other.Position, Vector.Zero, nil)
		other:Remove()
	end	
end
Transmogrify:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, 'OnWsipCollision', 206)


return Transmogrify