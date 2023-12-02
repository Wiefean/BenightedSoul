--屏幕相关函数

local mod = Isaac_BenightedSoul 

local Screens = {}


--获取屏幕尺寸
--(这个函数真的有存在的必要吗...)
function Screens:GetScreenSize() 
    return Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
end


--游戏位置转屏幕位置
--[[
输入:世界位置(矢量), 屏幕位置修正(矢量), 忽略屏幕摇晃效果(是否), 忽略镜世界(是否)
输出:屏幕位置(矢量)

包含镜世界位置修正和屏幕摇晃同步,
但不知为何,贴图(Sprite)可以同步晃动,而字体(Font)不能
]]
function Screens:WorldToScreen(worldPos, screenOffset, ignoreShake, ignoreMirror)
	screenOffset = screenOffset or Vector.Zero
	local game = Game()
	local room = game:GetRoom()	
	local shakeOffset = (ignoreShake and Vector.Zero) or game.ScreenShakeOffset
	local screenPos = Isaac.WorldToScreen(worldPos)

	--镜世界
	if (not ignoreMirror) and room:IsMirrorWorld() then
		local mirroredOffset = Vector(-screenOffset.X, screenOffset.Y)
		local mirroredPos = screenPos + mirroredOffset + shakeOffset
		return Vector(Isaac.GetScreenWidth() - mirroredPos.X, mirroredPos.Y)
	end
	
    return screenPos + screenOffset - shakeOffset
end


--获取实体在屏幕上的位置
--[[
输入:实体, 屏幕位置修正(矢量), 实体世界位置修正(矢量), 实体世界位置修正是否忽略倒影效果(是否)
输出:屏幕位置(矢量)
]]
function Screens:GetEntityRenderPosition(entity, screenOffset, worldOffset, ignoreReflection)
	screenOffset = screenOffset or Vector.Zero
    worldOffset = worldOffset or Vector.Zero
    
	--实体世界位置修正是否忽略倒影效果
    if (not ignoreReflection) and (Game():GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT) then
		worldOffset = -worldOffset
    end
	
    return Screens:WorldToScreen(entity.Position + entity.PositionOffset + worldOffset, screenOffset)
end


--获取鼠标位置
--[[
输入:由屏幕位置调整为世界位置(是否)
输出:屏幕位置或世界位置(矢量)

这个函数主要是用于获取鼠标世界位置的,
因为屑官方没有给鼠标镜世界位置做修正
]]
function Screens:GetMousePosition(toWorldPos)
	toWorldPos = toWorldPos or false
	local pos = Input.GetMousePosition(toWorldPos)
	local room = Game():GetRoom()
	
	--镜世界修正
	if toWorldPos and room:IsMirrorWorld() then
		return Vector(2*(room:GetCenterPos().X) - pos.X , pos.Y)
	end
	
	return pos
end



return Screens