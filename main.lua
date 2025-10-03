--模组本体

--[[
在选择存档界面使用控制台"luamod"指令可以避免重置数据
]]

Isaac_BenightedSoul = RegisterMod("Benighted Soul",1)

local mod = Isaac_BenightedSoul
mod.Version = "0.10.3"
mod.Language = Options.Language
mod.NameStr = "愚昧"
if mod.Language ~= "zh" then mod.Language = "en" mod.NameStr = mod.Name end

--测试模式
mod._Debug = false

--忏悔龙检测
if not REPENTOGON then
	local Texts = {
		zh = {
			"[愚昧] 需要 [[REPENTOGON]] 来运行",
			"还不快去安装, 你个 [[[小海绵]]]"
		},
		en = {
			"[[BENIGHTED SOUL]] REQUIRES  [[REPENTOGON]]  TO RUN",
			"INSTALL IT, YOU  [[[[SPONGE]]]]"
		}
	}
	local fnt = Font() fnt:Load("font/cjk/lanapixel.fnt")
	local texts = Texts[mod.Language] or Texts.en
	local color = KColor(0,1,1,1)

	mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
		local posX = Isaac.GetScreenWidth() / 2
		local posY = Isaac.GetScreenHeight() / 2
		for i, text in ipairs(texts) do
			fnt:DrawStringUTF8(text, posX - 200, posY + (i-1)*20, color, 400, true)
		end	
	end)
	
	print("[[BENIGHTED SOUL]] REQUIRES  [[REPENTOGON]]  TO RUN")
	print("INSTALL IT, YOU  [[[[SPONGE]]]]")

	return
end


--防止渲染崩溃
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, -7000, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) <= 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)

----加载模组本体文件----
local function LoadScript(fileName)
	include("ibs_scripts."..fileName)
end
LoadScript('ibs_common')
LoadScript('ibs_compat')
LoadScript('ibs_callback')
LoadScript('ibs_curse')
LoadScript('ibs_achiev')
LoadScript('ibs_entity')
LoadScript('ibs_room')
LoadScript('ibs_player')
LoadScript('ibs_item')
LoadScript('future')

--角色菜单
include("ibs_scripts.ibs_menu")

--忏悔龙特色调试菜单
require("ibs_scripts.ibs_imgui")
----------------


--成功加载提示
if mod.Language == "zh" then
	print("[愚昧] 已加载 (v"..(mod.Version)..")")
else
	print("[Benighted Soul] Loaded (v"..(mod.Version)..")")
end



--以下为测试功能,只在测试时使用


--电子斗蛐蛐专用
-- local Finds = mod.IBS_Lib.Finds
-- local Temperance = mod.IBS_Boss.Temperance
-- local Fortitude = mod.IBS_Boss.Fortitude

-- local LockPosition = false

-- mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_,player)
	-- if Input.IsButtonTriggered(Keyboard.KEY_0, 0) then
		-- LockPosition = not LockPosition
	-- end

	-- if LockPosition then
		-- ent = Finds:ClosestEntity(player.Position, Temperance.Type, Temperance.Variant, 0, function(ent)
			-- return ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		-- end)

		-- if ent then
			-- player.Position = ent.Position
		-- end

		-- --player.Visible = false
	-- else
		-- player.Visible = true
	-- end
	
	-- --表情
	-- if Input.IsButtonTriggered(Keyboard.KEY_G, 0) then
		-- player:AnimateHappy()
	-- end
	-- if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
		-- player:AnimateAppear()
	-- end
-- end)

--mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, function()
	--if LockPosition then
		--return true
	--end
--end)

--mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, function()
	--if LockPosition then
		--return true
	--end
--end)

-- mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, function()
	-- if LockPosition then
		-- return true
	-- end
-- end)

-- mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, function()
	-- if LockPosition then
		-- return false
	-- end
-- end)

