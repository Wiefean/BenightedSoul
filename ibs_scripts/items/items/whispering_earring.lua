--低语耳环

local mod = Isaac_BenightedSoul
local LANG = mod.Language == "zh"

local game = Game()
local sfx = SFXManager()

local WhisperingEarring = mod.IBS_Class.Item(mod.IBS_ItemID.WhisperingEarring)

local ShouldReverse = false

function WhisperingEarring:OnUpdate()
	if PlayerManager.AnyoneHasCollectible(WhisperingEarring.ID) then
		local room = game:GetRoom()
		
		if not room:IsClear() and room:GetFrameCount() <= 390 then
		
			--反转判定
			if Isaac.GetFrameCount() % 13 == 0 and math.random(1,100) < 50 then
				Isaac.CenterCursor()
				ShouldReverse = not ShouldReverse
				sfx:Play(math.random(598,601), 0.5, 120, false, 0.01*math.random(120,150))
			end	
		
			--提示
			if room:GetFrameCount() == 390 then
				for i = 0, game:GetNumPlayers() - 1 do
					local player = Isaac.GetPlayer(i)
					if player:HasCollectible(self.ID) then
						player:AnimateSad()
					end
				end
				sfx:Stop(598)
				sfx:Stop(599)
				sfx:Stop(600)
				sfx:Stop(601)
				game:GetHUD():ShowFortuneText((LANG and "只怪你自己") or "Blame nobody but yourself")
			end
		end
	end
end
WhisperingEarring:AddCallback(ModCallbacks.MC_POST_UPDATE, "OnUpdate")

function WhisperingEarring:CheckInput(ent, hook, action)
	if (hook ~= InputHook.GET_ACTION_VALUE) then return end
	local player = (ent and ent:ToPlayer())
	
	if player and player:HasCollectible(self.ID) then
		local room = game:GetRoom()
		
		--随机反转角色射击操作
		if not room:IsClear() and room:GetFrameCount() < 390 and ShouldReverse then		
			local cid = player.ControllerIndex
			if (action >= 4 and action <= 7) then
				return -Input.GetActionValue(action, cid)
			end
		end
	end
end
WhisperingEarring:AddPriorityCallback(ModCallbacks.MC_INPUT_ACTION, -1, 'CheckInput')

--属性变动
function WhisperingEarring:OnEvalueateCache(player, flag)
	if player:HasCollectible(self.ID) then
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.5
		end
	end	
end
WhisperingEarring:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 100, 'OnEvalueateCache')

return WhisperingEarring