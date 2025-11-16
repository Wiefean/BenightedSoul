--贞洁
--(偷懒套用了色欲的id,多省事)

local mod = Isaac_BenightedSoul
local IBS_BossID = mod.IBS_BossID
local IBS_ItemID = mod.IBS_ItemID
local IBS_PocketID = mod.IBS_PocketID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Chastity = mod.IBS_Class.Entity{
	Type = IBS_BossID.Chastity.Type,
	Variant = IBS_BossID.Chastity.Variant,
	SubType = IBS_BossID.Chastity.SubType,
	Name = {zh = '贞洁', en = 'Chastity'}
}

--是否可出现
function Chastity:CanAppear()
	if not self:GetIBSData('persis')['boss_chastity'] then return false end
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	--前两层不出,除非回溯线
	if level:GetStage() < 3 and not level:IsAscent() then
		return false
	end

	--表表抹检测
	if room:GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	
	--成就检测,非boss房
	if self:GetIBSData('persis')[IBS_PlayerKey.BEve].FINISHED and (room:GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	
	return false
end

--状态
Chastity.State = {
	Normal = 200,
	HalfHp = 201
}

--临时数据
function Chastity:GetData(npc)
	local data = self._Ents:GetTempData(npc)
	data.Chastity_Boss = data.Chastity_Boss or {
		CD = 60,
		Swing = false,
		SwingDirection = Vector.Zero,
	}
	return data.Chastity_Boss
end

--是否二阶段
function Chastity:IsPhase2(npc)
	return (npc.HitPoints <= (npc.MaxHitPoints) / 2) or (npc.State == self.State.HalfHp)
end

--初始化
function Chastity:OnNpcInit(npc)
	if npc.Variant == Chastity.Variant then
		npc:GetSprite():Play("Appear", true)
		npc.State = self.State.Normal
		npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS --飞行
	elseif (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换色欲
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(100)
		local replac = false
		
		--色欲
		if npc.Variant == 0 and int < 25 then
			replac = true
		end
		
		--超级色欲
		if npc.Variant == 1 and int < 40 then
			replac = true
		end

		if replac then
			Isaac.Spawn(Chastity.Type, Chastity.Variant, 0, npc.Position, Vector.Zero, nil)
			npc:Remove()
			
			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('色欲有些不对劲 ?', 'Lust ?'), self:ChooseLanguage('贞洁 !', 'Chastity !'))
			end, 30)			
		end
	end
end
Chastity:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 47)

--行为
function Chastity:PreNpcUpdate(npc)
    if (npc.Variant ~= Chastity.Variant) then return end
	local spr = npc:GetSprite()

	local data = self:GetData(npc)
	local target = npc:GetPlayerTarget()
	local friendly = npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
	local P2 = self:IsPhase2(npc)
	local player = self._Finds:ClosestPlayer(npc.Position)
	
	--友好状态
	if friendly then
		--幽默神圣干预会对友好怪生效
		npc:ClearEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE)
	end
	
	if data.CD > 0 then
		data.CD = data.CD - 1
	elseif target and not data.Swing then
		data.CD = (P2 and 50) or 75
		data.Swing = true
		
		if friendly and player then
			--友好状态下
			data.SwingDirection = (player.Position - npc.Position):Normalized()
		else		
			local selectedPos = (P2 and npc.Position) or target.Position

			--选择最远的地方			
			local room = game:GetRoom()
			local width = room:GetGridWidth()
			local height = room:GetGridHeight()
			local farthestPos = Vector.Zero
			local farthest = -1
			for x = 1, width - 1 do
				for y = 1, height - 1 do
					local gridIndex = x + y * width
					local pos = room:GetGridPosition(gridIndex)
					if pos and (pos:Distance(selectedPos) > farthest) then
						farthestPos = pos
						farthest = pos:Distance(selectedPos)
					end
				end
			end
				
			--设置移动方向
			data.SwingDirection = (farthestPos - npc.Position):Normalized()
		end
	end	

	--移动攻击
	if data.Swing then
		local dir = self._Maths:VectorToDirection(data.SwingDirection)
		local anim = (P2 and "SwingLeftHead2") or "SwingLeftHead"
		
		if dir == Direction.LEFT then 
			spr.FlipX = false
		elseif dir == Direction.RIGHT then		
			spr.FlipX = true
		end	
		if not spr:IsPlaying(anim) then
			spr:Play(anim, true)
		end
		if spr:IsEventTriggered("Shoot") then
			local vel = math.random(10,14)*data.SwingDirection
			if friendly then
				local dist = (player.Position - npc.Position):Length()
				if dist < 80 then
					vel = vel * -0.001*dist
				else
					vel = vel * 0.002*dist
				end
			end
			npc:AddVelocity(vel)
			
			--神圣干预
			local ChastityShield = (mod.IBS_Effect and mod.IBS_Effect.ChastityShield)
			if ChastityShield then
				if friendly then
					for i = 0,3 do
						local angle = i * math.random(10,15)
						local vel = (target.Position - npc.Position):Resized(math.random(14,18)):Rotated(angle*(-1)^i)
						ChastityShield:Spawn(npc.Position, vel, math.random(30,45), npc, friendly)
					end
				else
					local vel = (target.Position - npc.Position):Resized(math.random(14,18))
					ChastityShield:Spawn(npc.Position, vel, math.random(30,45), npc, friendly)
				end			
				sfx:Play(568)
			end
			
			--二阶段三圣颂
			if P2 then
				local ChastityLaser = (mod.IBS_Effect and mod.IBS_Effect.ChastityLaser)
				if ChastityLaser then
					for i = 0,2 do
						self:DelayFunction(function()
							if target and npc:Exists() and not npc:IsDead() then
								local mult = math.random(1,3)
								local vel = (target.Position - npc.Position):Resized(mult)
								local effect = ChastityLaser:Spawn(npc.Position, vel, math.random(140,210), npc)
								if friendly then
									effect:GetSprite().Color = Color(1,1,1,0.1)
								end
							end
						end, 9*i)
					end
				end
			end

		end
		if spr:IsEventTriggered("Stop") then				
			data.Swing = false
		end
	else
		npc.Velocity = npc.Velocity * 0.9
		if npc.Velocity:Length() < 0.01 then
			npc.Velocity = Vector.Zero
		end
	end
	

	--半血进入二阶段
	if P2 or friendly then
		if npc.State == self.State.Normal then
			npc.State = self.State.HalfHp
			data.CD = 0
			
			--特效
			local AbandonedItem = (mod.IBS_Effect and mod.IBS_Effect.AbandonedItem)
			AbandonedItem:Spawn(npc.Position, 'gfx/ibs/bosses/mini/chastity_mask.png', RandomVector())
			sfx:Play(267)
		end
	end
	
	return true
end
Chastity:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, 'PreNpcUpdate', Chastity.Type)

--替换愤怒的掉落物
function Chastity:OnPickupInit(pickup)
	local ent = pickup.SpawnerEntity
	if ent and ent.Type == 47 and ent.Variant == Chastity.Variant then
		pickup:Remove()
	end
end
Chastity:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit')

--死亡
function Chastity:OnNpcDeath(npc)
	if (npc.SpawnerType == EntityType.ENTITY_PLAYER) or game:IsGreedMode() then return end
	if (npc.Variant ~= Chastity.Variant) then return end
	local int = npc:GetDropRNG():RandomInt(100)
		
	--25%魂心
	local V = 10
	local S = 3

	if int < 50 and not PlayerManager.AnyoneHasCollectible(568) then --50%神圣干预
		V = 100
		S = 568
	elseif (int >= 50 and int < 75) and not PlayerManager.AnyoneHasCollectible(IBS_ItemID.OOC) then --25%贞洁之誓
		V = 100
		S = IBS_ItemID.OOC
	end
	
	Isaac.Spawn(5, V, S, game:GetRoom():FindFreePickupSpawnPosition(npc.Position), RandomVector() / 2, nil)
end
Chastity:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 47)

return Chastity