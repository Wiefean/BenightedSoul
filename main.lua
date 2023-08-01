--模组本体

--[[说明书:
要加载新的文件请填入对应lua文件的加载表中
]]

Isaac_BenightedSoul = RegisterMod("Benighted Soul",1)

local mod = Isaac_BenightedSoul
mod.ModVersion = "0.2.5"


--防止渲染崩溃
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) <= 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)

----加载文件----
local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts."..v)
    end
end

local Scripts = {
	"ibs_data",
	"ibs_constants",
	"ibs_callbacks",
	"ibs_achievements",
	"ibs_items",
	"ibs_players",
	"ibs_entities",
	"ibs_curses",
	"ibs_debug_console",
}
LoadScripts(Scripts)
----------------


----模组兼容----
--EID
if EID then
	include("ibs_scripts.compats.EID.main")
	
	--设置模组名称
	if EID:getLanguage() == "zh_cn" then
		EID:setModIndicatorName("愚昧")
	else
		EID:setModIndicatorName("IBS")
	end
end

--模组配置菜单
if ModConfigMenu then
	require("ibs_scripts.compats.mod_config_menu")
end
----------------

--成功加载提示
print("[Benighted Soul] Loaded (v"..(mod.ModVersion)..")")