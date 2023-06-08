--玩家双击检测回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local Ents = mod.IBS_Lib.Ents
local Maths = mod.IBS_Lib.Maths

local WalkAction = {
ButtonAction.ACTION_LEFT,
ButtonAction.ACTION_RIGHT,
ButtonAction.ACTION_UP,
ButtonAction.ACTION_DOWN
}

local ShootAction = {
ButtonAction.ACTION_SHOOTRIGHT,
ButtonAction.ACTION_SHOOTDOWN,
ButtonAction.ACTION_SHOOTLEFT,
ButtonAction.ACTION_SHOOTUP
}

local OtherAction = {
ButtonAction.ACTION_BOMB,
ButtonAction.ACTION_ITEM,
ButtonAction.ACTION_PILLCARD,
ButtonAction.ACTION_DROP,
ButtonAction.ACTION_MAP
}


--获取上次输入
local function GetLastInputData(player)
	local data = Ents:GetTempData(player)
	data.LastInput = data.LastInput or {
		Walk = {Action = -1, TimeOut = 0},
		Shoot = {Direction = -1, TimeOut = 0},
		Other = {}
	} 
	return data.LastInput
end

--获取移动输入
local function GetWalkInput(player)
	local cid = player.ControllerIndex
	for _,action in pairs(WalkAction) do
		if Input.IsActionTriggered(action, cid) then
			return action
		end
	end
	return -1
end

--获取射击方向
local MouseState = 0
local function GetShootDirection(player)
	local cid = player.ControllerIndex
	if cid == 0 then
		if Input.IsMouseBtnPressed(0) then
			if MouseState == 0 then --检查鼠标按下状态
				MouseState = 1
				local dir = Maths:VectorToDirection(player:GetAimDirection())
				return dir
			end
		elseif MouseState == 1 then
			MouseState = 0
		end
	end
	for _,action in pairs(ShootAction) do
		if Input.IsActionTriggered(action, cid) then
			local dir = Maths:VectorToDirection(player:GetAimDirection())
			return dir
		end
	end	

    return -1
end

--更新数据以及双击回调
local function DoubleTapCallback(_,player)
	if (not Game():IsPaused()) and (player:AreControlsEnabled()) and (Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT) then
		local data = GetLastInputData(player)
		local cid = player.ControllerIndex
		
		if not Input.IsActionPressed(ButtonAction.ACTION_MAP, cid) then --没有按下地图键
			do--移动
				local action = GetWalkInput(player)
				if action >= 0 then
					if action == data.Walk.Action then
						Isaac.RunCallback(IBS_Callback.PLAYER_DOUBLE_TAP, player, 0, action)
						data.Walk.TimeOut = 0
					else
						data.Walk.Action = action
						data.Walk.TimeOut = 10
					end
				end	
			end
			do--射击
				local dir = GetShootDirection(player)
				if dir >= 0 then
					if dir == data.Shoot.Direction then
						Isaac.RunCallback(IBS_Callback.PLAYER_DOUBLE_TAP, player, 1, dir)
						data.Shoot.TimeOut = 0
					else
						data.Shoot.Direction = dir
						data.Shoot.TimeOut = 10
					end
				end
			end
			do--其他
				for _,action in pairs(OtherAction) do
					if Input.IsActionTriggered(action, cid) then
						local exist = false
						for _,v in pairs(data.Other) do
							if action == v.Action then
								Isaac.RunCallback(IBS_Callback.PLAYER_DOUBLE_TAP, player, 2, action)
								v.TimeOut = 0						
								exist = true
								break
							end
						end
						if not exist then
							table.insert(data.Other, {Action = action, TimeOut = 10})
						end
					end
				end
			end
		end
		
		--刷新
		if data.Walk.TimeOut > 0 then
			data.Walk.TimeOut = data.Walk.TimeOut - 1
		elseif data.Walk.Action ~= -1 then
			data.Walk.Action = -1
		end
		if data.Shoot.TimeOut > 0 then
			data.Shoot.TimeOut = data.Shoot.TimeOut - 1
		elseif data.Shoot.Direction ~= -1 then
			data.Shoot.Direction = -1
		end
		for k,v in pairs(data.Other) do
			if v.TimeOut > 0 then
				v.TimeOut = v.TimeOut - 1
			else
				data.Other[k] = nil
			end 
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, DoubleTapCallback, 0)
