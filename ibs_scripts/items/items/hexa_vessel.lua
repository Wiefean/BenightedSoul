--六魂容器

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local sfx = SFXManager()

local HexaVessel = mod.IBS_Class.Item(mod.IBS_ItemID.HexaVessel)

--获取魂火
function HexaVessel:GetWisps(player)
	local result = {}
	
	for _,ent in ipairs(Isaac.FindByType(3, 206, self.ID)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			table.insert(result, familiar)
		end
	end
	
	return result
end

--角色更新
function HexaVessel:OnPlayeUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	
	
	--射击时生成最多6个魂火
	if self._Players:IsShooting(player) then 
		if player:IsFrame(36,0) and #self:GetWisps(player) < 6 then
			local wisp = player:AddWisp(self.ID, player.Position, true)
			if wisp then
				wisp.Color = Color(1,1,1,1,0,0.5,0)
			end
		end
	elseif player:IsFrame(3,0) then
		--停止射击时熄灭魂火并发射火焰
		local wisp = self:GetWisps(player)[1]
		if wisp ~= nil then
			local vel = (player.Position - wisp.Position)
			local target = self._Finds:ClosestEnemy(player.Position)

			--自瞄
			if target and target.Position:Distance(player.Position) <= 300 then
				vel = (target.Position - wisp.Position)
			end		

			local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, wisp.Position, vel:Resized(0.01*math.random(666,1111)), player):ToEffect()
			fire.Parent = player
			fire.Color = Color(1,2,0,0.5,0,1,0)
			fire.CollisionDamage = 3 + player.Damage
			fire.Scale = 0.5*self._Maths:TearDamageToScale(fire.CollisionDamage)
			fire.Timeout = 15 + 6 * math.floor(player.TearRange / 40)
			wisp:Kill()
		end
	end

end
HexaVessel:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)



return HexaVessel