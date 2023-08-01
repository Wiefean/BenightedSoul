--诅咒
local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.curses."..v)
    end
end

local curses = {
	"moving",
	"forgotten",
	"d7",
	"binding",
}
LoadScripts(curses)