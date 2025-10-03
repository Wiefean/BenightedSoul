--玩家双击检测回调

local mod = Isaac_BenightedSoul

local game = Game()

local DoubleTap = mod.IBS_Class.Callback(mod.IBS_CallbackID.DOUBLE_TAP)

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

--按键类型
DoubleTap.Type = {
	Walk = 0,
	Shoot = 1,
	Other = 2
}

--获取上次输入数据
function DoubleTap:GetData(player)
	local data = self._Ents:GetTempData(player)
	data.DoubleTapCallback = data.DoubleTapCallback or {
		Walk = {Action = -1, Timeout = 0},
		Shoot = {Direction = -1, Timeout = 0},
		Other = {}
	} 
	return data.DoubleTapCallback
end

--获取移动输入
function DoubleTap:GetWalkInput(player)
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
function DoubleTap:GetShootDirection(player)
	local cid = player.ControllerIndex
	if cid == 0 and Options.MouseControl then
		if Input.IsMouseBtnPressed(0) then
			if MouseState == 0 then --检查鼠标按下状态
				MouseState = 1
				local dir = self._Maths:VectorToDirection(player:GetAimDirection())
				return dir
			end
		elseif MouseState == 1 then
			MouseState = 0
		end
	end
	for _,action in pairs(ShootAction) do
		if Input.IsActionTriggered(action, cid) then
			local dir = self._Maths:VectorToDirection(player:GetAimDirection())
			return dir
		end
	end	

    return -1
end

--更新数据以及双击回调
function DoubleTap:DoubleTapCallback(player)
	if (not game:IsPaused()) and player:AreControlsEnabled() then
		local data = self:GetData(player)
		local cid = player.ControllerIndex
		
		do--移动
			local action = self:GetWalkInput(player)
			if action >= 0 then
				if action == data.Walk.Action then
					self:Run(player, self.Type.Walk, action)
					data.Walk.Timeout = 0
				else
					data.Walk.Action = action
					data.Walk.Timeout = 10
				end
			end	
		end
		do--射击
			local dir = self:GetShootDirection(player)
			if dir >= 0 then
				if dir == data.Shoot.Direction then
					self:Run(player, self.Type.Shoot, dir)
					data.Shoot.Timeout = 0
				else
					data.Shoot.Direction = dir
					data.Shoot.Timeout = 10
				end
			end
		end
		do--其他
			for _,action in pairs(OtherAction) do
				if Input.IsActionTriggered(action, cid) then
					local exist = false
					for _,v in pairs(data.Other) do
						if action == v.Action then
							self:Run(player, self.Type.Other, action)
							v.Timeout = 0						
							exist = true
							break
						end
					end
					if not exist then
						table.insert(data.Other, {Action = action, Timeout = 15})
					end
				end
			end
		end
		
		--刷新
		if data.Walk.Timeout > 0 then
			data.Walk.Timeout = data.Walk.Timeout - 1
		elseif data.Walk.Action ~= -1 then
			data.Walk.Action = -1
		end
		if data.Shoot.Timeout > 0 then
			data.Shoot.Timeout = data.Shoot.Timeout - 1
		elseif data.Shoot.Direction ~= -1 then
			data.Shoot.Direction = -1
		end
		for k,v in pairs(data.Other) do
			if v.Timeout > 0 then
				v.Timeout = v.Timeout - 1
			else
				data.Other[k] = nil
			end 
		end
	end
end
DoubleTap:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'DoubleTapCallback', 0)



return DoubleTap