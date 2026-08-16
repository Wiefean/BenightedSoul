--钥匙行者

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID
local IBS_Sound = mod.IBS_Sound
local Pickups = mod.IBS_Lib.Pickups

local game = Game()
local sfx = SFXManager()

local KeyWalker = mod.IBS_Class.Pickup{
	Variant = IBS_PickupID.KeyWalker.Variant,
	SubType = IBS_PickupID.KeyWalker.SubType,
	Name = {zh = '钥匙行者', en = 'Key Walker'}
}

--更新
function KeyWalker:OnPickupUpdate(pickup)
	local spr = pickup:GetSprite()
	
	--生成动画
	if spr:IsPlaying("Appear") then
		if spr:IsEventTriggered("Drop") then
			sfx:Play(59)
		end
		return
	end
	
	local target = self._Finds:ClosestEnemy(pickup.Position)
	local golden = (pickup.SubType == self.SubType.Golden)
	
	if target and pickup.FrameCount < 360 then
		local vec = target.Position - pickup.Position
		pickup.Velocity = pickup.Velocity + (vec):Resized(math.max(1, vec:Length() / 40))
		
		--碰撞伤害
		if pickup:IsFrame(7,0) then
			local dmg = 3 + 0.1 * Isaac.GetPlayer(0):GetNumKeys()
			
			--金钥匙
			if golden then
				for _,ent in ipairs(Isaac.GetRoomEntities()) do
					if self._Ents:IsEnemy(ent) and self._Ents:AreColliding(ent, pickup) then
						ent:TakeDamage(dmg, 0, EntityRef(nil), 0)
						
						--概率施加点金
						if math.random(1,100) < 20 then		
							ent:AddMidasFreeze(EntityRef(nil), 45)
						end
					end
				end			
			else			
				for _,ent in ipairs(Isaac.GetRoomEntities()) do
					if self._Ents:IsEnemy(ent) and self._Ents:AreColliding(ent, pickup) then
						ent:TakeDamage(dmg, 0, EntityRef(nil), 0)
					end
				end
			end	
		end
		
		spr:Play("Walk")
		sfx:Play(IBS_Sound.KeyWalker, 0.2, 10, false, 0.01 * math.random(80, 120))
	else
		--变回钥匙
		
		--金钥匙
		if golden then
			Isaac.Spawn(5, 30, 2, pickup.Position, pickup.Velocity, nil)
		else		
			Isaac.Spawn(5, 30, 0, pickup.Position, pickup.Velocity, nil)
		end
		
		Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
		pickup:Remove()
	end
end
KeyWalker:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', KeyWalker.Variant)

--忽略玩家碰撞
function KeyWalker:OnCollision(pickup, collider)
	local player = collider:ToPlayer()
	if player then
		return true
	end	
end
KeyWalker:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 'OnCollision', KeyWalker.Variant)

return KeyWalker