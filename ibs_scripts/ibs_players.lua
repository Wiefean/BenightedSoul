--角色

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.players."..v)
    end
end

local players = {
	"bisaac",
	"bmaggy",
}

LoadScripts(players)