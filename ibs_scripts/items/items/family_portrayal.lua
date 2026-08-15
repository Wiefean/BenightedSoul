--全家祸

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()

local FamilyPortrayal = mod.IBS_Class.Item(IBS_ItemID.FamilyPortrayal)


--获得时触发
function FamilyPortrayal:OnGain(item, charge, first, slot, varData, player)
	if first then
		player:AddCollectible(238)
		player:AddCollectible(239)
		player:AddCollectible(327)
		player:AddCollectible(328)
		player:AddCollectible(626)
		player:AddCollectible(627)
		player:AddCollectible(633)
		player:RemoveCollectible(self.ID)
	end
end
FamilyPortrayal:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 'OnGain', FamilyPortrayal.ID)

--非困难模式自动重置
function FamilyPortrayal:TryRerollSelf(pickup)
	if pickup.Variant == 100 and pickup.SubType == self.ID then
		local difficulty = game.Difficulty
		
		if difficulty ~= Difficulty.DIFFICULTY_HARD and difficulty ~= Difficulty.DIFFICULTY_GREEDIER then
			local seed = pickup.InitSeed
			local pool = self._Pools:GetRoomPool(seed)
			local id = game:GetItemPool():GetCollectible(pool, true, seed)
			pickup:Morph(5, 100, id, true, true)
		end
	end
end

function FamilyPortrayal:OnPickupInit(pickup)
	self:TryRerollSelf(pickup)
end
FamilyPortrayal:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 100)

function FamilyPortrayal:OnPickupUpdate(pickup)
	self:TryRerollSelf(pickup)
end
FamilyPortrayal:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, 'OnPickupUpdate', 100)

--雪花屏效果
function FamilyPortrayal:UpdateRenderFlags(pickup)
	local spr = pickup:GetSprite()
	local flags = spr:GetRenderFlags()

	if pickup.SubType == self.ID then
		if flags & AnimRenderFlags.STATIC <= 0 then		
			spr:SetRenderFlags(flags | AnimRenderFlags.STATIC)
		end
		self._Ents:GetTempData(pickup).LastIsFamilyPortrayal = true
	else
		if self._Ents:GetTempData(pickup).LastIsFamilyPortrayal and flags & AnimRenderFlags.STATIC > 0 then
			spr:SetRenderFlags(flags &~ AnimRenderFlags.STATIC)
			self._Ents:GetTempData(pickup).LastIsFamilyPortrayal = nil
		end
	end
end

function FamilyPortrayal:OnNewRoom()
	for _,ent in ipairs(Isaac.FindByType(5, 100)) do
		if ent.SubType ~= 0 then
			self:UpdateRenderFlags(ent)		
		end
	end
end
FamilyPortrayal:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

function FamilyPortrayal:OnPickupInit(pickup)
	self:UpdateRenderFlags(pickup)
end
FamilyPortrayal:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 100)

function FamilyPortrayal:OnPickupRender(pickup)
	self:UpdateRenderFlags(pickup)
end
FamilyPortrayal:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, 'OnPickupRender', 100)

return FamilyPortrayal