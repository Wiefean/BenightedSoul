--模组本体

--[[说明书:
要加载新的文件请填入对应lua文件的加载表中
]]

Isaac_BenightedSoul = RegisterMod("Benighted Soul",1)

local mod = Isaac_BenightedSoul
mod.ModVersion = "0.5.0"
mod.Language = Options.Language
if mod.Language ~= "zh" then mod.Language = "en" end

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
	"ibs_entities",
	"ibs_players",
	"ibs_items",
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

--东方幻想曲
do

--检查东方mod和前置mod的开启情况
function mod:CheckTHI()
	if CuerLib and THI then
		return true
	end
	return false
end

--玩家是否使用正邪的增强道具方案
function mod:THI_WillSeijaBuff(player)
	if mod:CheckTHI() then
		return THI.Players.Seija:WillPlayerBuff(player)
	end
	return false
end

--玩家是否使用正邪的削弱道具方案
function mod:THI_WillSeijaNerf(player)
	if mod:CheckTHI() then
		return THI.Players.Seija:WillPlayerNerf(player)
	end
	return false
end

end
----------------

--成功加载提示
print("[Benighted Soul] Loaded (v"..(mod.ModVersion)..").")