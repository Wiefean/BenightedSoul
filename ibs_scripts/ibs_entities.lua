--实体
local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.entities."..v)
    end
end

local entities = {
	"bosses.temperance",
	
	"effects.pickingup",
	

}
LoadScripts(entities)