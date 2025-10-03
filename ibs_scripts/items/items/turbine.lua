--涡轮
--(握握手,握握双手)

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Turbine = mod.IBS_Class.Item(mod.IBS_ItemID.Turbine)

--机器功能列表
Turbine.MachineFunc = {
	[1] = function(slot, player, rng)
		--赌博机生成随机掉落物
		for i = 1,2 do
			Isaac.Spawn(5,0,0, slot.Position, 2*RandomVector(), nil)
		end
		local spr = slot:GetSprite()
		spr:Play('Initiate', true)
		sfx:Play(24)
	end,
	
	[2] = function(slot, player, rng)
		--献血机生成随机心
		for i = 1,2 do
			Isaac.Spawn(5,10,0, slot.Position, 2*RandomVector(), nil)
		end
		local spr = slot:GetSprite()
		spr:Play('Prize', true)
		sfx:Play(175)
	end, 
	
	[3] = function(slot, player, rng)
		--预言机生成魂心或饰品
		if rng:RandomInt(100) < 50 then
			Isaac.Spawn(5,10,3, slot.Position, 2*RandomVector(), nil)
		else
			Isaac.Spawn(5,350, game:GetItemPool():GetTrinket(), slot.Position, 2*RandomVector(), nil)
		end
		local spr = slot:GetSprite()
		spr:Play('Initiate', true)
		sfx:Play(24)
	end,
	
	[10] = function(slot, player, rng)
		local room = game:GetRoom()

		--补货机重置道具或商品
		if room:GetType() == RoomType.ROOM_SHOP then
			room:ShopRestockFull()
		else
			player:UseActiveItem(105,false,false) --D6
		end
		
		local spr = slot:GetSprite()
		spr:Play('Initiate', true)
		sfx:Play(24)
	end,
	
	[16] = function(slot, player, rng)
		--摧毁娃娃机并生成展示的道具
		local item = slot:GetPrizeCollectible()
		Isaac.Spawn(5,100,item, slot.Position, Vector.Zero, nil)
		Isaac.Spawn(1000, 1, 0, slot.Position, Vector.Zero, nil) --爆炸特效
		Isaac.Spawn(1000, 18, 0, slot.Position, Vector.Zero, nil) --爆炸痕迹特效
		slot:SetState(3)
		slot.Velocity = slot.Velocity + 4*RandomVector()
	end,
}

--使用效果
function Turbine:OnUse(item, rng, player, flags)
	local found = false
	for _,ent in pairs(Isaac.FindByType(6)) do
		local slot = ent:ToSlot()
		if slot and slot.GridCollisionClass ~= 5 then		
			local func = self.MachineFunc[slot.Variant]
			if func ~= nil then
				func(slot, player, rng)
				found = true
			end
		end
	end

	--没有触发任何效果则获得命运之轮
	if not found then
		player:AddCard(11)
	end
	
	return true
end
Turbine:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', Turbine.ID)


return Turbine