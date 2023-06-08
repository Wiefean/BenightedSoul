--Boss

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.bosses."..v)
    end
end

local bosses = {
	"mini.temperance",

}

LoadScripts(bosses)