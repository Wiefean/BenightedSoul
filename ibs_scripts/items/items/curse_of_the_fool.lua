-- 愚者之诅咒

local mod = Isaac_BenightedSoul

local CurseoftheFool = mod.IBS_Class.Item(mod.IBS_ItemID.CurseoftheFool)

local game = Game()
local config = Isaac.GetItemConfig()

-- 道具变量
CurseoftheFool.MaxTimes = 11
CurseoftheFool.ShowTimeout = 90

-- 获取数据
function CurseoftheFool:GetPData(player)
    local data = self._Players:GetData(player, false)
    data.CurseoftheFool = data.CurseoftheFool or {
        HurtTimes = 0,
        Timeout = 0,
    }
    return data.CurseoftheFool
end

-- 获取显示剩余次数时间
do
    function CurseoftheFool:GetShowTimeout(player)
        local data = CurseoftheFool:GetPData(player)
        return data.Timeout or 0
    end

    function CurseoftheFool:SetShowTimeout(player, value)
        local data = CurseoftheFool:GetPData(player)
        data.Timeout = (value or CurseoftheFool.ShowTimeout)
    end

    function CurseoftheFool:AddShowTimeout(player, value)
        local timeout = CurseoftheFool:GetShowTimeout(player)
        CurseoftheFool:SetShowTimeout(player, math.max(timeout + (value or -1), 0))
    end
end

-- 受伤次数相关数据
do
    function CurseoftheFool:GetHurtTimes(player)
        local data = CurseoftheFool:GetPData(player)
        return data.HurtTimes or 0
    end

    function CurseoftheFool:SetHurtTimes(player, value)
        local data = CurseoftheFool:GetPData(player)
        data.HurtTimes = (value or 0)
    end

    function CurseoftheFool:AddHurtTimes(player, value)
        local hurtTimes = CurseoftheFool:GetHurtTimes(player)
        CurseoftheFool:SetHurtTimes(player, hurtTimes + (value or 1))
    end
end

function CurseoftheFool:SpawnDiceShard(player, num)
    for i = 1, num do
        local game = Game()
        local room = game:GetRoom()
        local position = room:FindFreePickupSpawnPosition(player.Position, 40, true, false)
        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_DICE_SHARD, position, Vector.Zero, player):ToPickup()
    end
end

-- 忏悔龙的受伤后触发回调，避免受伤被取消后依旧增加计数
function CurseoftheFool:PostEntityTakeDamage(entity, amount, flag, source, countdownFrames)
    local player = entity:ToPlayer()
    if not player then return end
    if player:HasCollectible(self.ID) then
        self:AddHurtTimes(player, 1)
        self:SetShowTimeout(player, self.ShowTimeout)
    end
end
CurseoftheFool:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'PostEntityTakeDamage', EntityType.ENTITY_PLAYER)

-- 玩家每帧检测计数是否大于等于11
function CurseoftheFool:OnPlayerUpdate(player)
	if not player:HasCollectible(self.ID) then return end
    local hurtTimes = self:GetHurtTimes(player)
    if hurtTimes >= self.MaxTimes then
        self:SetHurtTimes(player, hurtTimes - self.MaxTimes)
		player:UseCard(Card.CARD_REVERSE_FOOL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		self:DelayFunction(function()
			player:UseCard(Card.CARD_FOOL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end, 1)
        if mod.IBS_Compat.THI:SeijaBuff(player) then
            -- 正邪兼容生成强化等级个骰子碎片
            local seijaBLevel = mod.IBS_Compat.THI:GetSeijaBLevel(player)
			if seijaBLevel > 0 then
				self:SpawnDiceShard(player, seijaBLevel)
			end
        end
    end
end
CurseoftheFool:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')


--道具贴图
local spr = Sprite('gfx/ibs/ui/items/any.anm2')
local itemConfig = config:GetCollectible(CurseoftheFool.ID)
spr:ReplaceSpritesheet(0, itemConfig.GfxFileName, true)
spr:Play('Idle')
spr.Scale = Vector(0.5,0.5)

-- 显示计数
do
    local font = Font()
    font:Load("font/pftempestasevencondensed.fnt")

    function CurseoftheFool:OnPlayerRender(player, offset)
        if not player:HasCollectible(self.ID) then return end
        local timeout = self:GetShowTimeout(player)
        if timeout <= 0 then return end
        if not game:IsPaused() then self:AddShowTimeout(player, -1) end
        local alpha = math.min(timeout, 30) / 30
        local renderPos = self._Screens:GetEntityRenderPosition(player, offset + Vector(-8, -100+timeout))
        local num = self:GetHurtTimes(player)
        local text = string.format("%d/%d", num, self.MaxTimes)
		spr.Color.A = alpha
		spr:Render(Vector(renderPos.X-8, renderPos.Y+8))
        font:DrawString(text, renderPos.X, renderPos.Y, KColor(1, 1, 1, alpha, 0, 0, 0), 0, true)
    end
    CurseoftheFool:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, 'OnPlayerRender')
end

return CurseoftheFool