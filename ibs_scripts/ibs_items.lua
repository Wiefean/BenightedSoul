--物品

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.items."..v)
    end
end

local items = {
	"items.lightd6",
	"items.nop",
	"items.d4d",
	"items.shooting_stars_gazer",
	"items.waster",
	"items.envy",
	"items.glowingheart",
	"items.purplebubbles",
	"items.cursedmantle",

	"trinkets.bottleshard",
	"trinkets.dadspromise",
	
	"pocketitems.CuZnD6",	
}
LoadScripts(items)


