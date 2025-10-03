--AKEY47
--(照搬了箱子武器的写法)

local mod = Isaac_BenightedSoul
local IBS_FamiliarID = mod.IBS_FamiliarID

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local AKEY47 = mod.IBS_Class.Familiar{
	Variant = IBS_FamiliarID.AKEY47.Variant,
	SubType = IBS_FamiliarID.AKEY47.SubType,
	Name = {zh = 'AKEY47', en = 'AKEY47'}
}

--获取数据
function AKEY47:GetData(familiar)
	local data = self._Ents:GetTempData(familiar)
	data.AKEY47 = data.AKEY47 or {CD = 0}
	return data.AKEY47
end

--查找
function AKEY47:FindAKey47(player)
	local result = {}
	
	for _,ent in pairs(Isaac.FindByType(3, self.Variant)) do
		local familiar = ent:ToFamiliar()
		if familiar and self._Ents:IsTheSame(familiar.Player, player) then
			table.insert(result, familiar)
		end	
	end
	
	return result
end

--初始化
function AKEY47:OnFamiliarInit(familiar)
	local data = self:GetData(familiar)
end
AKEY47:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, 'OnFamiliarInit', AKEY47.Variant)


--游戏更新
function AKEY47:OnFamiliarUpdate(familiar)
	local spr = familiar:GetSprite()
	local data = self:GetData(familiar)
	local player = familiar.Player if not player then return end
	local vec = self._Players:GetAimingVector(player)
	local isShooting = self._Players:IsShooting(player)
	local dir = -1
	local offset = vec:Resized(35)
	local shotSpeed = math.min(30, 20*player.ShotSpeed)

	--攻击动画
	if isShooting then
		familiar.DepthOffset = -100
		dir = self._Maths:VectorToDirection(vec)
		
		if dir == Direction.UP then
			spr:SetFrame("Up", 0)
			offset = offset + Vector(0,-15)
			familiar.DepthOffset = -100
		elseif dir == Direction.DOWN then
			spr:SetFrame("Down", 0)
			offset = offset + Vector(0,-15)
			familiar.DepthOffset = 100
		elseif dir == Direction.LEFT then		
			spr:SetFrame("Left", 0)
			offset = offset + Vector(0,-20)
			familiar.DepthOffset = -100
		elseif dir == Direction.RIGHT then			
			spr:SetFrame("Right", 0)
			offset = offset + Vector(0,-20)
			familiar.DepthOffset = -100
		end			
		
		familiar:FollowPosition(player.Position + offset)
		familiar.Velocity = familiar.Velocity * 10
	else --待机动画
		spr:SetFrame("Down", 0)
		vec = player.Velocity
		familiar:FollowPosition(player.Position + Vector(0,-20))
		familiar.Velocity = familiar.Velocity * 3.5
		if familiar.Position:Distance(player.Position) <= 40 then
			familiar.Position = player.Position + Vector(0,-20)
		end
		dir = (vec:Length() > 1 and self._Maths:VectorToDirection(vec:Normalized())) or Direction.DOWN
		
		if dir == Direction.UP then
			familiar.DepthOffset = 100
		else				
			familiar.DepthOffset = -100
		end
	end
	
	if data.CD > 0 then
		data.CD = data.CD - 1
	end
	
	--正邪削弱(东方mod)
	--没钥匙不能攻击
	--攻击有概率失去钥匙
	local seija = mod.IBS_Compat.THI:SeijaNerf(player)
	
	if isShooting and data.CD <= 0 and (not seija or player:GetNumKeys() > 0) then
		data.CD = math.min(15, math.ceil(player.MaxFireDelay / 2))
		local vel = vec:Resized(shotSpeed)
		local target = self._Finds:ClosestEnemy(familiar.Position)
		
		--偏移
		local bia = vel:Rotated((-1)^math.random(1,2)*math.random(0,7))
		
		local posOffset = Vector.Zero --位置修正
		if dir == Direction.UP then
			posOffset = Vector(0,8)
		elseif dir == Direction.DOWN then
			posOffset = Vector(0,36)
		elseif dir == Direction.LEFT then		
			posOffset = Vector(-10,18)
		elseif dir == Direction.RIGHT then			
			posOffset = Vector(10,18)
		end		
		
		self._Players:FireTears(player, function(tear)
			tear.CollisionDamage = math.max(1.7, player.Damage * 0.5)
			if tear.Variant ~= 43 then
				tear:ChangeVariant(43)
			end
			local scale = self._Maths:TearDamageToScale(tear.CollisionDamage)
			tear.SpriteScale = Vector(scale, scale)
			tear.Color = Color(234/255, 203/255, 116/255, 1)
		end, familiar.Position - offset:Resized(15) + posOffset, bia, false, false, false, familiar, 1)
		
		--正邪削弱
		if seija and player:GetCollectibleRNG(mod.IBS_ItemID.AKEY47):RandomInt(100) < 5 then
			player:AddKeys(-1)
		end
		
		--硬核后座
		familiar.Position = familiar.Position - 0.1*offset
		
		sfx:Play(830, 1, 2, false, 3)
	end	

end
AKEY47:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, 'OnFamiliarUpdate', AKEY47.Variant)

--新房间调整
function AKEY47:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for _,familiar in ipairs(self:FindAKey47(player)) do
			familiar.Position = player.Position + Vector(0,-20)
		end
	end
end
AKEY47:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return AKEY47