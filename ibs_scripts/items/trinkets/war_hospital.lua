--战地医院

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local WarHospital = mod.IBS_Class.Trinket(mod.IBS_TrinketID.WarHospital)

--获取最近的目标(友好怪)
function WarHospital:GetTarget(pos)
	local target = nil
	local closestDist = 114514

	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		--具有血量且未满血,为友好怪或跟班
		if ent.MaxHitPoints > 0 and ent.HitPoints < ent.MaxHitPoints and
			(
				(ent:IsEnemy() and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
				or
				ent:ToFamiliar()
			)
		then
			local dist = ent.Position:Distance(pos)
			if dist < 90 and dist < closestDist then
				closestDist = dist
				target = ent
			end
		end
	end
	
	return target
end

--更新
function WarHospital:OnTrinketUpdate(pickup)
	local golden = (pickup.SubType == self.ID + 32768)
	if not (pickup.SubType == self.ID or golden) then return end
	local target = self:GetTarget(pickup.Position)
	
	--为目标回血
	if target ~= nil and pickup:IsFrame(10,0)then
		local percent = 0.05
		
		--金饰品
		if golden then
			percent = percent + 0.05
		end
		
		--妈盒
		if PlayerManager.AnyoneHasCollectible(439) then
			percent = percent + 0.05
		end
		
		target.HitPoints = math.min(target.MaxHitPoints, target.HitPoints + percent * target.MaxHitPoints)
		
		--特效
		Isaac.Spawn(1000, 49, 0, target.Position, Vector.Zero, nil)
	end
end
WarHospital:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnTrinketUpdate', PickupVariant.PICKUP_TRINKET)

--未清理的房间不能拾取
function WarHospital:PrePickupCollision(pickup, other)
	if pickup.SubType ~= self.ID then return end
	if pickup.Price ~= 0 then return end --检查价格
	local player = other:ToPlayer()
	if player and not game:GetRoom():IsClear() then	
		return false
	end	
end
WarHospital:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 233, 'PrePickupCollision', 350)


return WarHospital