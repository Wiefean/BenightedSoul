--圣乔治蘑菇

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local CalocybeGambosa = mod.IBS_Class.Item(mod.IBS_ItemID.CalocybeGambosa)

--新房间触发
function CalocybeGambosa:OnNewRoom()
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	local room = game:GetRoom()
	if room:GetType() ~= RoomType.ROOM_SACRIFICE then return end
	if not room:IsFirstVisit() then return end
	local centerPos = room:GetCenterPos()

	--生成两个刺
	for i = 1,2 do
		local pos = Vector(80*(-1)^i,0) + centerPos
		local idx = room:GetClampedGridIndex(pos)
		if idx then
			room:RemoveGridEntity(idx, 0, false)
			self:DelayFunction(function()
				room:SpawnGridEntity(idx, 8)
				Isaac.Spawn(1000,15,0, pos, Vector.Zero, nil)
			end, 0)
		end
	end
end
CalocybeGambosa:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


return CalocybeGambosa