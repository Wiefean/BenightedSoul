--劳动明灯

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_EffectID = mod.IBS_EffectID

local game = Game()
local sfx = SFXManager()

local DiligenceLamp = mod.IBS_Class.Effect{
	Variant = IBS_EffectID.DiligenceLamp.Variant,
	SubType = IBS_EffectID.DiligenceLamp.SubType,
	Name = {zh = '劳灯', en = 'Diligence Lamp'}
}

--临时玩家数据
function DiligenceLamp:GetData(effect)
	local data = self._Ents:GetTempData(effect)
	data.DiligenceLamp = data.DiligenceLamp or {
		Timeout = 0,
		Light = false,
	}
	return data.DiligenceLamp
end


--初始化
function DiligenceLamp:OnInit(effect)
	--光效
	local light = self._Ents:ApplyLight(effect, 2, Color(1,1,0,2,0.5,0.5), function(light)
		local data = self:GetData(effect)
		if data.Light then
			light.Visible = true
		else
			light.Visible = false
		end
	end)
	light.Visible = false
	effect:GetSprite():SetFrame('Idle', 1)
end
DiligenceLamp:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, 'OnInit', DiligenceLamp.Variant)

--逻辑
function DiligenceLamp:OnUpdate(effect)
	local data = self:GetData(effect)

	local room = game:GetRoom()
	local spr = effect:GetSprite()

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		--点亮时生成魂火
		if data.Light and effect:IsFrame(135,0) then
			player:AddWisp(IBS_ItemID.LODI, effect.Position + RandomVector() * 35)
		end

		--玩家在附近时点亮
		if player.Position:Distance(effect.Position) ^ 2 <= 30 ^ 2 then
			data.Timeout = 210
		end
	end	

	if data.Timeout > 0 then
		data.Timeout = data.Timeout - 1
		data.Light = true
		spr:SetFrame('Idle', 0)
	else
		data.Light = false
		spr:SetFrame('Idle', 1)
	end

	if data.Light then	
		--泪弹概率获得追踪效果
		for _,ent in pairs(Isaac.FindInRadius(effect.Position, 40, EntityPartition.TEAR)) do
			local tear = ent:ToTear()
			if tear then
				if RNG(tear.InitSeed):RandomInt(100) < 50 then	
					tear:AddTearFlags(TearFlags.TEAR_HOMING)
					tear:AddTearFlags(TearFlags.TEAR_LASERSHOT)
					tear:SetColor(Color(1, 1, 1, 1, 1, 1, 0),-1,0)
					tear.CollisionDamage = tear.CollisionDamage + 1
				end
			end
		end
	end
end
DiligenceLamp:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, 'OnUpdate', DiligenceLamp.Variant)


return DiligenceLamp