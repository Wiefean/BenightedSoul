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
	"items.hypercube",
	"items.defined",
	"items.chocolate",
	"items.diamoond",
	"items.cranium",
	"items.ether",
	"items.wisper",
	"items.bone_of_temperance",
	"items.guard_of_fortitude",
	"items.v7",

	"trinkets.bottleshard",
	"trinkets.dadspromise",
	"trinkets.divineretaliation",
	"trinkets.toughheart",
	
	"pocketitems.CuZnD6",
	"pocketitems.goldenprayer",
}
LoadScripts(items)


