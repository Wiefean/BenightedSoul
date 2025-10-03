--勤麦

local mod = Isaac_BenightedSoul
local IBS_PickupID = mod.IBS_PickupID
local Pickups = mod.IBS_Lib.Pickups
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Diligence = mod.IBS_Boss.Diligence

local DeligenceWheat = mod.IBS_Class.Pickup{
	Variant = IBS_PickupID.DeligenceWheat.Variant,
	SubType = IBS_PickupID.DeligenceWheat.SubType,
	Name = {zh = '勤麦', en = 'Deligence Wheat'}
}

--尝试生成(勤勤数量+勤劳偶像数量,上限7)
function DeligenceWheat:TrySpawn()
	local num = #Isaac.FindByType(Diligence.Type, Diligence.Variant, Diligence.SubType.Farmer)
	
	--房间未清理时才计算勤劳偶像
	if not game:GetRoom():IsClear() and PlayerManager.AnyoneHasCollectible(IBS_ItemID.MODE) then
		num = num + 2
	end
	
	if num <= 0 then return end
	if num > 7 then num = 7 end
	
	if #Isaac.FindByType(5, self.Variant) < num then
		local room = game:GetRoom()
		local width = room:GetGridWidth()
		local height = room:GetGridHeight()
		local x = math.random(1, width-1)
		local y = math.random(1, height-1)
		local gridIndex = x + y * width
		local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(gridIndex), 0, true)
		Isaac.Spawn(5, self.Variant, self.SubType, pos, Vector.Zero, nil)
	end
end
DeligenceWheat:AddCallback(ModCallbacks.MC_POST_UPDATE, 'TrySpawn')

--切换房间时移除
function DeligenceWheat:OnNewRoom()
	for _,ent in ipairs(Isaac.FindByType(5, self.Variant, self.SubType)) do
		ent:Remove()
	end
end
DeligenceWheat:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--被勤勤拾取
function DeligenceWheat:OnPickedByDeligence(pickup, deligence)
	local friendly = deligence:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
	
	--镰刀特效与伤害
	local DeligenceSwing = mod.IBS_Effect and mod.IBS_Effect.DeligenceSwing
	if DeligenceSwing then
		local rotation = 90 + (deligence.Position - pickup.Position):GetAngleDegrees()

		--旋转位置修正
		local offset = Vector(30,0)
		offset = offset:Rotated(rotation)
		
		--友好状态下对敌人造成伤害,否则对玩家造成伤害
		if friendly then
			for _,ent in ipairs(Isaac.FindInRadius(deligence.Position + offset, 40, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(ent) then
					ent:TakeDamage(70, 0, EntityRef(deligence), 0)
				end
			end
			
			--勤劳偶像记录
			local MODE = mod.IBS_Item and mod.IBS_Item.MODE
			if MODE then
				for i = 0, game:GetNumPlayers() - 1 do
					local player = Isaac.GetPlayer(i)
					if player:HasCollectible(MODE.ID) then
						MODE:AddWheatCollected(player, 1)
					end
				end
			end
		else
			for _,ent in ipairs(Isaac.FindInRadius(deligence.Position + offset, 40, EntityPartition.PLAYER)) do
				if ent:ToPlayer() and not ent:ToPlayer():IsCoopGhost() then
					ent:TakeDamage(2, 0, EntityRef(deligence), 120)
				end
			end				
		end

		--为相同友好状态的勤劳提升血量并记录数量
		for _,ent2 in ipairs(Isaac.FindByType(Diligence.Type, Diligence.Variant)) do
			if friendly == ent2:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
				Diligence:AddWheatCollected(ent2, 1)

				ent2.HitPoints = math.min(ent2.MaxHitPoints, ent2.HitPoints + 7)
				local effect = Isaac.Spawn(1000, 49, 0, ent2.Position, Vector.Zero, ent2):ToEffect()
				effect:FollowParent(ent2)
				sfx:Play(SoundEffect.SOUND_VAMP_GULP, 0.5)
			else --否则造成伤害
				ent2.HitPoints = math.max(0, ent2.HitPoints - 13)
				ent2:TakeDamage(1, 0, EntityRef(deligence), 0)
			end
		end

		DeligenceSwing:Spawn(deligence.Position, rotation, deligence)
	end		
end

--被玩家拾取
function DeligenceWheat:OnPickedByPlayer(pickup)
	--勤劳偶像记录
	local MODE = mod.IBS_Item and mod.IBS_Item.MODE
	if MODE then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(MODE.ID) then
				MODE:AddWheatCollected(player, 1)
			end
		end
	end

	--为友好勤劳提升血量并记录小麦数量
	for _,ent in ipairs(Isaac.FindByType(Diligence.Type, Diligence.Variant)) do
		if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			Diligence:AddWheatCollected(ent, 1)
		
			ent.HitPoints = math.min(ent.MaxHitPoints, ent.HitPoints + 7)
			local effect = Isaac.Spawn(1000, 49, 0, ent.Position, Vector.Zero, ent):ToEffect()
			effect:FollowParent(ent)
		else --否则造成伤害
			ent.HitPoints = math.max(0, ent.HitPoints - 13)
			ent:TakeDamage(1, 0, EntityRef(player), 0)
		end
	end
end

--更新
function DeligenceWheat:OnPickupUpdate(pickup)
	if pickup.SubType ~= self.SubType then return end
	
	--音效
	if pickup:GetSprite():IsEventTriggered('DropSound') then
		sfx:Play(SoundEffect.SOUND_FETUS_JUMP, 2)
	end
	
	--勤勤拾取
	for _,deligence in ipairs(Isaac.FindByType(Diligence.Type, Diligence.Variant, Diligence.SubType.Farmer)) do
		if deligence.Position:Distance(pickup.Position) ^ 2 <= 60 ^ 2 then
			Pickups:PlayCollectAnim(pickup)
			self:OnPickedByDeligence(pickup, deligence)
			pickup:Remove()
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 2, false, 1.2)
			return
		end
	end
	
	--玩家拾取
	for _,p in ipairs(Isaac.FindByType(1)) do
		if p.Position:Distance(pickup.Position) ^ 2 <= 20 ^ 2 then
			Pickups:PlayCollectAnim(pickup)
			self:OnPickedByPlayer(pickup)
			pickup:Remove()
			sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 2, false, 1.2)
			return
		end
	end	
	
	--挥动拾取检测
	local player = Pickups:GetSwingPickupPlayer(pickup)
	if player then
		Pickups:PlayCollectAnim(pickup)
		self:OnPickedByPlayer(pickup)
		pickup:Remove()
		sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 2, false, 1.2)
	end
end
DeligenceWheat:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', DeligenceWheat.Variant)


return DeligenceWheat