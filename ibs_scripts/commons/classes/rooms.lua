--房间合集Class

--[[

"info_tbl"包含内容
{
	Type, --房间大类
	Variants, --房间类(表)
	EnterFunc, --进出房间时触发的函数,带参数"self","first",'room'和"roomData"
}

]]

local mod = Isaac_BenightedSoul

local game = Game()

local Component = mod.IBS_Class.Component

local Rooms = mod.Class(Component, function(self, info_tbl)
	Component._ctor(self)
	
	self.Type = info_tbl.Type
	self.EnterFunc = info_tbl.EnterFunc

	self.Variants = {}
	
	for _,v in ipairs(info_tbl.Variants) do
		table.insert(self.Variants, v)
	end

	--抽取一个
	function self:GetRandomVariant(seed)
		return self.Variants[RNG(seed):RandomInt(1, #self.Variants)] or self.Variants[1]
	end

	--是否在房间内
	function self:IsInRoom()
		local room = game:GetRoom()
		local desc = game:GetLevel():GetCurrentRoomDesc()
		if not desc.Data then return end
		local roomData = desc.Data
		if room:GetType() == self.Type then
			for _,v in ipairs(self.Variants) do
				if v == roomData.Variant then
					return true
				end
			end
		end
		return false
	end	

	--房间初始化
	function self:_RoomInit()
		local room = game:GetRoom()
		local desc = game:GetLevel():GetCurrentRoomDesc()
		if not desc.Data then return end
		local roomData = desc.Data
		if type(self.EnterFunc) == 'function' and room:GetType() == self.Type then
			for _,v in ipairs(self.Variants) do
				if v == roomData.Variant then
					self:EnterFunc(room:IsFirstVisit(), room, roomData)
					break
				end
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -10^7, '_RoomInit')	

end, { {expectedType = 'table'} })


return Rooms
