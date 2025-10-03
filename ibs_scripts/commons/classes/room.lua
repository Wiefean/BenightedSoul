--房间Class

--[[

"info_tbl"包含内容
{
	Type, --房间大类
	Variant, --房间类
	SubType, --房间小类(可为nil)
	EnterFunc, --进出房间时触发的函数,带参数"self","first",'room'和"roomData"
}

]]

local mod = Isaac_BenightedSoul

local game = Game()

local Component = mod.IBS_Class.Component

local Room = mod.Class(Component, function(self, info_tbl)
	Component._ctor(self)
	
	self.Type = info_tbl.Type
	self.Variant = info_tbl.Variant
	self.SubType = info_tbl.SubType
	self.EnterFunc = info_tbl.EnterFunc

	--是否在房间内
	function self:IsInRoom(subType)
		local room = game:GetRoom()
		local desc = game:GetLevel():GetCurrentRoomDesc()
		if not desc.Data then return end
		local roomData = desc.Data
		if room:GetType() == self.Type and roomData.Variant == self.Variant and (roomData.SubType == subType or not subType) then
			return true
		end
		return false
	end	

	--房间初始化
	function self:_RoomInit()
		local room = game:GetRoom()
		local desc = game:GetLevel():GetCurrentRoomDesc()
		if not desc.Data then return end
		local roomData = desc.Data
		if type(self.EnterFunc) == 'function' and room:GetType() == self.Type and roomData.Variant == self.Variant then
			self:EnterFunc(room:IsFirstVisit(), room,roomData)
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -10^7, '_RoomInit')	

end, { {expectedType = 'table'} })


return Room
