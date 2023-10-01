--坚韧面罩

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local Maths = mod.IBS_Lib.Maths

--抵挡面前子弹,受伤清除子弹,爆炸伤害以半心替代
local function PreTakeDMG(_,ent, amount, flag, source)
	local player = ent:ToPlayer()
	
	if player and player:HasCollectible(IBS_Item.guard) then
		if source and (source.Type == EntityType.ENTITY_PROJECTILE) then
			local dir = Maths:VectorToDirection((player.Position - source.Entity.Position):Normalized())

			if player:GetHeadDirection() ~= dir then
				return false
			else	
				for _,proj in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, proj.Position, Vector.Zero, nil)	
					proj:Remove()
				end
				SFXManager():Play(267)
				Game():ShakeScreen(30)				
			end	
		end

		if (amount > 0) and (flag & DamageFlag.DAMAGE_EXPLOSION > 0) and (flag & DamageFlag.DAMAGE_CLONES <= 0) then
			player:TakeDamage(1, flag | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_NO_MODIFIERS, source, 0)
			return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PreTakeDMG)


