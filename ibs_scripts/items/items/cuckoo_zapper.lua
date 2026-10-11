--杀威棍

local mod = Isaac_BenightedSoul

local CuckooZapper = mod.IBS_Class.Item(mod.IBS_ItemID.CuckooZapper)

local game = Game()

CuckooZapper.Delay = 0
CuckooZapper.SpreadRange = 15

function CuckooZapper:PostAddCollectible(item, charge, firstTime, slot, varData, player)
    if not firstTime then return end
    local room = game:GetRoom()
    local position = room:FindFreePickupSpawnPosition(player.Position + Vector(0, 40))
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_LOVERS, position, Vector.Zero, player)
end
CuckooZapper:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'PostAddCollectible', CuckooZapper.ID)

function CuckooZapper:PostPlayerUpdate(player)
    if not player:HasCollectible(self.ID) then return end
    local num = player:GetBrokenHearts()
    if num <= 0 then return end

    self.Delay = math.max((self.Delay or 0) - num, 0)
    local vec = self._Players:GetAimingVector(player)
    if self._Players:IsShooting(player) and vec:Length() > 0 and self.Delay <= 0 then
        self.Delay = player.MaxFireDelay * 10
        for time = 1, 3 do
            local vel = Vector.FromAngle(vec:GetAngleDegrees() + math.random(-self.SpreadRange, CuckooZapper.SpreadRange))
            self._Players:FireTechLasers(player, function(laser)
                laser:SetMaxDistance(80)
                laser:SetColor(Color(0, 1, 0, 1, 0, 0.8, 0), -1, 0)
                laser:SetScale(0.5)
                local data = self._Ents:GetTempData(laser)
                data.SPREADING_LASER_FROM_CUCKOO_ZAPPER = math.random(2, 4)
            end,
            player.Position, 0, vel, false, true, player, 0.8)
        end
    end
end
CuckooZapper:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'PostPlayerUpdate')

function CuckooZapper:PostLaserUpdate(laser)
    local data = self._Ents:GetTempData(laser)
    if data.SPREADING_LASER_FROM_CUCKOO_ZAPPER and data.SPREADING_LASER_FROM_CUCKOO_ZAPPER > 0 then
        local pos = laser:GetEndPoint() + laser.PositionOffset
        local newlaser = Isaac.Spawn(laser.Type, laser.Variant, laser.SubType, pos, Vector.Zero, laser.SpawnerEntity):ToLaser()
        newlaser:SetColor(Color(0, 1, 0, 1, 0, 0.8, 0), -1, 0)
        local newData = self._Ents:GetTempData(newlaser)
        newData.SPREADING_LASER_FROM_CUCKOO_ZAPPER = data.SPREADING_LASER_FROM_CUCKOO_ZAPPER - 1
        local angleOffset = math.random(-self.SpreadRange, self.SpreadRange)
        newlaser.Angle = laser.Angle + angleOffset
        newlaser.AngleDegrees = laser.AngleDegrees + angleOffset
        newlaser.RotationDegrees = laser.RotationDegrees + angleOffset
        newlaser.CollisionDamage = laser.CollisionDamage
        newlaser:SetOneHit(laser.OneHit)
        newlaser:SetTimeout(3)
        newlaser:AddTearFlags(laser.TearFlags)
        newlaser:SetMaxDistance(laser.MaxDistance)
        newlaser:SetScale(laser:GetScale())
        data.SPREADING_LASER_FROM_CUCKOO_ZAPPER = nil
    end
end
CuckooZapper:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, 'PostLaserUpdate')

--新层
function CuckooZapper:OnNewLevel()
    local room = game:GetRoom()

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID) then
			local found = false
			
			for slot = 0,4 do
				local card = player:GetCard(slot)
				if card and card == 7 then
					player:SetCard(slot, 62)
					found = true
				end
			end
			
			if not found then
				local position = room:FindFreePickupSpawnPosition(player.Position + Vector(0, 40))
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_LOVERS, position, Vector.Zero, player)
			end
		end
	end
end
CuckooZapper:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'OnNewLevel')

--获取数据
function CuckooZapper:GetData(player)
	local data = self._Ents:GetTempData(player)
	if not data.CuckooZapper then
		local spr = Sprite()
		spr:Load('gfx/ibs/effects/otto_hat.anm2', true)
		spr:Play('HeadDown')
		data.CuckooZapper = {
			Sprite = spr
		}
	end
	return data.CuckooZapper
end

--渲染图标
function CuckooZapper:OnPlayerRender(player, offset)
	if not player:HasCollectible(self.ID) then return end
	local data = self:GetData(player)
	local num = player:GetBrokenHearts()
	if num > 0 then
		local spr = data.Sprite
		spr.Scale = Vector(player.SpriteScale.X, player.SpriteScale.Y)
		spr:SetFrame(player:GetSprite():GetOverlayFrame())
	
		local dir = player:GetHeadDirection()
		if dir == 0 then
			spr:Play("HeadLeft")
		elseif dir == 1 then
			spr:Play("HeadUp")
		elseif dir == 2 then
			spr:Play("HeadRight")
		else
			spr:Play("HeadDown")
		end
	
		local scale = player.SpriteScale.Y
		for i = 0,num-1 do		
			spr:Render(self._Screens:GetEntityRenderPosition(player, offset, Vector(0,-8 * i * scale)))
		end
	end
end
CuckooZapper:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_RENDER, -800, 'OnPlayerRender', 0)

return CuckooZapper