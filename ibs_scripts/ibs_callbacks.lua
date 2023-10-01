--回调

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.callbacks."..v)
    end
end

local callbacks = {
	"mirrorbroken",
	"greed",
	"item",
	"doubletap",
	"tryuseitem",
	"activerender",
	"holditem",
}
LoadScripts(callbacks)