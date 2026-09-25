--蒙特祖玛的遗产

local mod = Isaac_BenightedSoul

local game = Game()

local MontezumasHeritage = mod.IBS_Class.Item(mod.IBS_ItemID.MontezumasHeritage)

--获取数据
function MontezumasHeritage:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.MontezumasHeritage = data.MontezumasHeritage or {
		Damage = 0,
		CD = 0,
	}
	return data.MontezumasHeritage
end

--放屁
local function Fart(player)
	player:UseActiveItem(294, false, false)
	
	local proj = Isaac.Spawn(9, 5, 0, player.Position, math.random(5, 10) * RandomVector(), player):ToProjectile()
	proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
	proj:Update()
end

--失去钥匙时触发
function MontezumasHeritage:OnKeyNumChange(delta)
	if delta < 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				Fart(player)
				
				--水迹
				local effect = Isaac.Spawn(1000, 195, 0, player.Position, Vector.Zero, player):ToEffect()
				local scale = 0.01 * math.random(150, 200)
				effect.Scale = scale
			end
		end
	end
end
MontezumasHeritage:AddCallback(mod.IBS_CallbackID.NUM_CHANGE_KEY,'OnKeyNumChange')

--摧毁大便触发
function MontezumasHeritage:OnPoopBreak(gridEnt, ent, variant)	
	if PlayerManager.AnyoneHasCollectible(self.ID) then
		local pos = (gridEnt and gridEnt.Position) or ent.Position
		Isaac.Spawn(5, 30, 0, pos, Vector.Zero, nil)
		
		--红大便
		if gridEnt and variant == 1 then
			game:GetRoom():RemoveGridEntity(gridEnt:GetGridIndex(), 0, false)
		end
	end
end
MontezumasHeritage:AddCallback(mod.IBS_CallbackID.POOP_BREAK, 'OnPoopBreak')

--角色更新
function MontezumasHeritage:OnPlayerUpdate(player)
	local data = self._Ents:GetTempData(player).MontezumasHeritage
	if data and data.CD then
		if data.CD > 0 then
			data.CD = data.CD - 1
		end
	end
end
MontezumasHeritage:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--伤害判定
function MontezumasHeritage:OnTakeDamage(entity, dmg, flag, source)
	if dmg <= 0 then return end
	
	if self._Ents:IsEnemy(entity) then
		local threshold = (40 * game:GetLevel():GetStage() + 80) / 3
	
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID) then
				local data = self:GetData(player)
				data.Damage = data.Damage + dmg

				if data.CD <= 0 and data.Damage + math.random(1, math.floor(threshold)) > threshold then
					data.CD = 90
					data.Damage = 0
					if player:GetNumKeys() > 0 then
						player:AddKeys(-1)
						Fart(player)
						Isaac.Spawn(5, 30, 0, player.Position, 0.1 * math.random(20,30) * RandomVector(), nil)
					end
				end
			end	
		end
	end	
end
MontezumasHeritage:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDamage')

return MontezumasHeritage