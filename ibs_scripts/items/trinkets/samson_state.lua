--参孙姿态
--(用于表表参孙占用饰品栏)

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local BSamson = mod.IBS_Player.BSamson

local SamsonState = mod.IBS_Class.Trinket(mod.IBS_TrinketID.SamsonState)

local game = Game()

--不能出现在地上
function SamsonState:OnTrinketUpdate(pickup)
	if pickup.SubType == self.ID then	
		pickup:Remove()
	end
end
SamsonState:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnTrinketUpdate', 350)

--避免从饰品池中抽取
function SamsonState:PreGetTrinket(id)
	if id == self.ID then	
		local itemPool = game:GetItemPool()
		itemPool:RemoveTrinket(id)
		return itemPool:GetTrinket()
	end	
end
SamsonState:AddPriorityCallback(ModCallbacks.MC_GET_TRINKET, CallbackPriority.IMPORTANT, 'PreGetTrinket')

--角色更新
function SamsonState:OnPlayerUpdate(player)

	--移除吞下的
	local tbl = player:GetSmeltedTrinkets()[self.ID]
	if tbl then	
		if tbl.trinketAmount and tbl.trinketAmount > 0 then
			player:TryRemoveSmeltedTrinket(self.ID)
		end
		if tbl.goldenTrinketAmount and tbl.goldenTrinketAmount > 0 then
			player:TryRemoveSmeltedTrinket(self.ID+32768)
		end
	end

	--其他角色不能拿
	if player:GetPlayerType() ~= BSamson.ID then
		for slot = 0,1 do
			local id = player:GetTrinket(slot)
			if id == self.ID then
				player:TryRemoveTrinket(id)
			end
		end
	end
end
SamsonState:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)

--不让丢
do

local cache = {}
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	for k,v in ipairs(cache) do
		if v.Timeout > 0 then
			v.Timeout = v.Timeout - 1
		else
			table.remove(cache, k)
		end
	end
end)

function SamsonState:OnTrinketInit(pickup)
	if pickup.SubType <= 0 then return end
	local ent = pickup.SpawnerEntity
	if ent and ent:ToPlayer() and (pickup.SubType == self.ID or pickup.SubType - 32768 == self.ID) then
		table.insert(cache, {Pickup = pickup, Timeout = 1})
	end
end
SamsonState:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnTrinketInit', 350)

function SamsonState:OnLoseTrinket(player, trinket)
	if player:GetPlayerType() ~= BSamson.ID then return end

	if trinket == self.ID and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
		for k,v in ipairs(cache) do
			local pickup = v.Pickup
			if self._Ents:IsTheSame(player, pickup.SpawnerEntity) then
				player:AddTrinket(self.ID)
				pickup:Remove()
				table.remove(cache, k)
			end
		end		
	end
end
SamsonState:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 'OnLoseTrinket')

end


--获取数据
function SamsonState:GetData(player)
	local data = self._Ents:GetTempData(player)
	
	if not data.SamsonStateTrinket then
		local Icon = Sprite('gfx/ibs/ui/players/bsamson_state.anm2')
		Icon:Play('CalmIdle')

		local ChargeBar = Sprite('gfx/ibs/ui/players/bsamson_chargebar.anm2')
		ChargeBar:Play("Charging")
	
		data.SamsonStateTrinket = {
			State = 0,
			Wait = 0,
			Icon = Icon,
			ChargeBar = ChargeBar,
		}
	end
	
	return data.SamsonStateTrinket
end


--饰品栏渲染
function SamsonState:OnTrinketRender(slot, pos, scale, player)
	if player:GetPlayerType() ~= BSamson.ID then return end
	local trinket = player:GetTrinket(slot); if trinket ~= self.ID and trinket ~= self.ID + 32768 then return end
	local data = self:GetData(player)
	local state = BSamson:GetState(player)
	local wrath = (state == BSamson.Wrath)
	local calm = (state == BSamson.Calm)
	
	--切换姿态动画
	if data.State ~= state then
		data.State = state
		
		if wrath then
			data.Icon:Play("WrathEnter")
		elseif calm then
			data.Icon:Play("CalmEnter")
		end
	end
	
	if wrath then
		if data.Icon:IsFinished("WrathEnter") then		
			data.Icon:Play("WrathIdle")
		end
	elseif calm then
		if data.Icon:IsFinished("CalmEnter") then		
			data.Icon:Play("CalmIdle")
		end
	end	
	
	data.Icon.Scale = Vector(scale, scale)
	data.Icon:Render(pos + Vector(16*scale, 16*scale))

	--让平静看起来更平静一点
	if not game:IsPaused() then	
		if calm and data.Icon:IsPlaying("CalmIdle") then
			if data.Wait > 0 then
				data.Wait = data.Wait - 1
			else
				data.Wait = 2
				data.Icon:Update()
			end
		else
			data.Icon:Update()
		end
	end
	
	--暴怒剩余时间显示
	if wrath and not BSamson:HasCard(player, 70) and Isaac.GetChallenge() ~= IBS_ChallengeID[7] then
		data.ChargeBar.Scale = Vector(scale, scale)
		data.ChargeBar:SetFrame("Charging", math.floor(100*(BSamson:GetData(player).WrathDuration)/BSamson:GetMaxWrathDuration(player)))
		data.ChargeBar:Render(pos + Vector(scale, 16*scale))
	end
	
	return true
end
SamsonState:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_TRINKET_RENDER, 'OnTrinketRender')


return SamsonState