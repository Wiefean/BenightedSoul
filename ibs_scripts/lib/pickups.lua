--掉落物实体相关函数

local config = Isaac.GetItemConfig()

local Pickups = {}

--通过单选掉落物参数获取掉落物组
function Pickups:GetPickupsByOptionsIndex(idx)
	local result = {}

	for _,ent in pairs(Isaac.FindByType(5)) do
		local pickup = ent:ToPickup()
		if pickup.OptionsPickupIndex == idx then
			table.insert(result, pickup)
		end
	end
	
	return result
end

--获取新的单选掉落物参数
function Pickups:GetUniqueOptionsIndex()
    local idx = 1
    local pickups = Isaac.FindByType(5)
    local unique = false
	
    while (not unique) do
        unique = true
        for _,ent in pairs(pickups) do
            if ent:ToPickup().OptionsPickupIndex == idx then
                idx = idx + 1
                unique = false
                break
            end
        end
    end
	
    return idx
end


return Pickups