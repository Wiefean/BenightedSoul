--眼泪相关函数

local mod = Isaac_BenightedSoul

local Tears = {}

--血泪
Tears.BloodVariant = {
	[TearVariant.BLUE] = TearVariant.BLOOD,
	[TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
	[TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
	[TearVariant.PUPULA_BLOOD] = TearVariant.PUPULA,
	[TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA,
	[TearVariant.GLAUCOMA_BLOOD] = TearVariant.GLAUCOMA_BLOOD
}

--眼泪伤害转眼泪大小
function Tears:DamageToScale(dmg)
    return dmg ^ 0.5 * 0.23 + dmg * 0.01 + 0.55
end

--转换为剖腹产眼泪
function Tears:ToFetus(tear, player)
	tear:ChangeVariant(TearVariant.FETUS)
	tear:AddTearFlags(TearFlags.TEAR_FETUS)
	
	if player then
		local playerType = player:GetPlayerType()
	
		--英灵剑
		if player:HasCollectible(579) then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_SWORD)
		end
		
		--骨哥
		if playerType == 16 or playerType == 35 then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_BONE)
		end
		
		--妈刀
		if player:HasCollectible(114) then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_KNIFE)
		end
		
		--科技X
		if player:HasCollectible(395) then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_TECHX)
		end
	
		--科技
		if player:HasCollectible(68) then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_TECH)
		end
		
		--硫磺火+泪血
		if player:HasCollectible(118) and player:HasCollectible(531) then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_BRIMSTONE)
		end
		
		--胎儿博士
		if player:HasCollectible(52) or (player:HasCollectible(168) and player:HasCollectible(579)) then
			tear:AddTearFlags(TearFlags.TEAR_FETUS_BOMBER)
		end
	end

end

return Tears