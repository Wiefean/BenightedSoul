--炸钥人

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents

local game = Game()
local sfx = SFXManager()

local BomberKey = mod.IBS_Class.Item(mod.IBS_ItemID.BomberKey)

--十字钥匙眼泪
function BomberKey:Cross(player, pos)
	local vec = Vector(0,1)
	local angle = 0
	
	for i = 0,3 do
		angle = 90 * i
		local tear = Isaac.Spawn(2, 43, 0, pos, vec:Rotated(angle)*20, player):ToTear()
		tear:AddTearFlags(TearFlags.TEAR_PIERCING)
		tear.CollisionDamage = 10
		tear.Scale = 2
		tear:Update()		
	end
end

--炸弹更新
function BomberKey:OnBombUpdate(bomb)
	if bomb:IsDead() then
		local player = self._Ents:IsSpawnerPlayer(bomb, true)
		if player and player:HasCollectible(self.ID) then
			self:Cross(player, bomb.Position)
		end
	end
end
BomberKey:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, 'OnBombUpdate')

--史诗胎儿兼容
function BomberKey:AlsoEpicFetus(effect)
	if effect.Timeout == 1 then
		local player = self._Ents:IsSpawnerPlayer(effect, true)
		
		if player and player:HasCollectible(self.ID) then
			self:DelayFunction(function()			
				self:Cross(player, effect.Position)
			end, 1)
		end
	end
end
BomberKey:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'AlsoEpicFetus', EffectVariant.ROCKET)



return BomberKey