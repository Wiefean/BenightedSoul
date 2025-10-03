--渲染相关回调

local mod = Isaac_BenightedSoul

local RenderOverlay = mod.IBS_Class.Callback(mod.IBS_CallbackID.RENDER_OVERLAY)

--上层渲染回调(其实是一个空shader)
function RenderOverlay:RenderOverlayCallback(shaderName)
	if shaderName == 'IBS_Empty' then 
		self:Run()
	end
end
RenderOverlay:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, 'RenderOverlayCallback')



return RenderOverlay