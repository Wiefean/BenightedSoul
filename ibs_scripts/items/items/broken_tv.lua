--损坏的电视

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()

local BrokenTV = mod.IBS_Class.Item(mod.IBS_ItemID.BrokenTV)

--使用效果
function BrokenTV:OnUse(item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) and (flags & UseFlag.USE_VOID <= 0) then--拒绝车载电池和虚空
		if slot >= 0 and slot <= 1 and player:HasCollectible(self.ID, true) then
		
			--彼列书
			if player:HasCollectible(59) then
				player:RemoveCollectible(self.ID, true)
				self._Stats:PersisDamage(player, 1, true)
				sfx:Play(610, 1, 2, false, 0.6)
			else			
				self:DelayFunction(function()
					player:DropCollectible(self.ID)
				end, 0)
			end
		end
		return {ShowAnim = false, Discharge = true}
	end
end
BrokenTV:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', BrokenTV.ID)

--雪花屏效果
function BrokenTV:UpdateRenderFlags(pickup)
	local spr = pickup:GetSprite()
	local flags = spr:GetRenderFlags()

	if pickup.SubType == self.ID then
		if flags & AnimRenderFlags.STATIC <= 0 then		
			spr:SetRenderFlags(flags | AnimRenderFlags.STATIC)
		end
		self._Ents:GetTempData(pickup).LastIsBrokenTV = true
	else
		if self._Ents:GetTempData(pickup).LastIsBrokenTV and flags & AnimRenderFlags.STATIC > 0 then
			spr:SetRenderFlags(flags &~ AnimRenderFlags.STATIC)
			self._Ents:GetTempData(pickup).LastIsBrokenTV = nil
		end
	end
end

function BrokenTV:OnNewRoom()
	local room = game:GetRoom()
	
	--进商店
	if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() then
		for i = 0, game:GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if player:HasCollectible(self.ID, true) then
				local coins = player:GetNumCoins()
			
				if coins <= 0 then
					return
				end

				local chance = 20
				
				--美德书
				if player:HasCollectible(584) then
					chance = chance * 2
				end
				
				if player:GetCollectibleRNG(self.ID):RandomInt(100) < chance then
					player:RemoveCollectible(self.ID, true)
					player:AddCollectible(633)
					player:AddCoins(-coins)
					sfx:Play(274)
					break
				end
			end
		end
	end	
	
	for _,ent in ipairs(Isaac.FindByType(5, 100)) do
		if ent.SubType ~= 0 then
			self:UpdateRenderFlags(ent)		
		end
	end
end
BrokenTV:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

function BrokenTV:OnPickupInit(pickup)
	self:UpdateRenderFlags(pickup)
end
BrokenTV:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, 'OnPickupInit', 100)

function BrokenTV:OnPickupRender(pickup)
	self:UpdateRenderFlags(pickup)
end
BrokenTV:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, 'OnPickupRender', 100)


--道具图标
local Icon = Sprite()
Icon:Load("gfx/ibs/ui/items/any.anm2")
Icon:ReplaceSpritesheet(0, config:GetCollectible(BrokenTV.ID).GfxFileName, true)
Icon:Play(Icon:GetDefaultAnimation())
Icon:SetRenderFlags(AnimRenderFlags.STATIC)

--主动槽
function BrokenTV:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	Icon.Scale = Vector(scale, scale)
	Icon.Color = Color(1,1,1,alpha)
	Icon:Render(offset + Vector(16*scale,16*scale))
end
BrokenTV:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')

return BrokenTV