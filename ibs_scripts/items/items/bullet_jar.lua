--罐中枪子

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_PickupID = mod.IBS_PickupID

local game = Game()
local sfx = SFXManager()

local BulletJar = mod.IBS_Class.Item(IBS_ItemID.BulletJar)

--设置特殊眼泪
function BulletJar:SetTear(tear)
	self._Ents:GetTempData(tear).BulletJar_TEAR = true
end

--是否为特殊眼泪
function BulletJar:IsTear(tear)
	return self._Ents:GetTempData(tear).BulletJar_TEAR
end

--是否可用
function BulletJar:CanUse()
	local keys = Isaac.GetPlayer(0):GetNumKeys()
	return keys >= 5 and #Isaac.FindByType(5,30,1) <= keys
end

--眼泪消失时生成钥匙
function BulletJar:OnTearRemoved(ent)
	if ent.Variant == 43 and self:IsTear(ent) then
		--钥匙行者兼容
		if PlayerManager.AnyoneHasCollectible(IBS_ItemID.KeyWalker) then
			for i = 1,5 do
				Isaac.Spawn(5, IBS_PickupID.KeyWalker.Variant, IBS_PickupID.KeyWalker.SubType.Common, ent.Position, 2 * RandomVector(), nil)
			end		
		else
			for i = 1,5 do
				Isaac.Spawn(5, 30, 1, ent.Position, RandomVector(), nil)
			end
		end
	end
end
BulletJar:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 'OnTearRemoved', 2)

--双击发射
function BulletJar:OnDoubleTap(player, type, dir)
	if (type == 1) and not Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
		if player:HasCollectible(self.ID)
			and self:CanUse()
			and player:IsExtraAnimationFinished()
			and not player:IsCoopGhost()
			and player:GetNumKeys() >= 5
		then
			player:AddKeys(-5)
			
			local dmg = math.max(17.5, player.Damage * 5)
			local tear = Isaac.Spawn(2, 43, 0, player.Position, self._Maths:DirectionToVector(dir)*30, player):ToTear()
			self:SetTear(tear)
			tear:AddTearFlags(TearFlags.TEAR_PIERCING)
			tear.CollisionDamage = dmg
			tear.Scale = self._Maths:TearDamageToScale(dmg)
			tear:Update()
			
			sfx:Play(SoundEffect.SOUND_GFUEL_GUNSHOT_SPREAD, 2, 2, false, 0.9)
			game:ShakeScreen(7)			
		end
	end	
end
BulletJar:AddCallback(mod.IBS_CallbackID.DOUBLE_TAP, 'OnDoubleTap')


return BulletJar