--宽容

local mod = Isaac_BenightedSoul
local IBS_Sound = mod.IBS_Sound
local IBS_PlayerKey = mod.IBS_PlayerKey

local game = Game()
local sfx = SFXManager()

local Kindness = mod.IBS_Class.Item(mod.IBS_ItemID.Kindness)

--是否可出现
function Kindness:CanAppear()
	if not self:GetIBSData('persis')['boss_kindness'] then return false end
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	--八层后不出,除非回溯线
	if level:GetStage() > 8 and not level:IsAscent() then
		return false
	end

	--表表抹检测
	if room:GetType() == RoomType.ROOM_MINIBOSS and PlayerManager.AnyoneIsPlayerType(mod.IBS_PlayerID.BMaggy) then
		return false
	end
	
	--成就检测,非boss房
	if self:GetIBSData('persis')[IBS_PlayerKey.BSamson].FINISHED and (room:GetType() ~= RoomType.ROOM_BOSS) then
		return true
	end
	
	return false
end

function Kindness:OnNpcInit(npc)
	if (npc.Variant <= 1) and self:CanAppear() then
		--尝试替换嫉妒
		local rng = RNG(npc.InitSeed)
		local int = rng:RandomInt(10000)
		local replac = false
		
		--嫉妒
		if npc.Variant == 0 and int < 1225 then
			replac = true
		end
		
		--超级嫉妒
		if npc.Variant == 1 and int < 1225 then
			replac = true
		end

		if replac then
			Isaac.Spawn(5, 100, self.ID, npc.Position, Vector.Zero, nil)
			npc:Remove()
			
			--提示
			self:DelayFunction(function()
				game:GetHUD():ShowItemText(self:ChooseLanguage('嫉妒有些不对劲 ?', 'Envy ?'), self:ChooseLanguage('宽容 !', 'Kindness !'))
			end, 30)			
		end
	end
end
Kindness:AddCallback(ModCallbacks.MC_POST_NPC_INIT, 'OnNpcInit', 51)

--打断攻击
function Kindness:OnPlayeUpdate(player)
	local has = player:HasCollectible(self.ID)

	--检测
	if not has and not self:GetIBSData("temp").MiniBossKindnessTriggered then 
		return
	end
	
	if not self._Players:IsShooting(player) then return end

	if math.random(1,100) == 23 then
		self._Players:AddShield(player, 45)
		sfx:Play(math.random(620,622), 1, 2, false, 4)

		--正邪增强
		if has and mod.IBS_Compat.THI:SeijaBuff(player) then
			return
		end
		
		player:AnimatePitfallOut()
		player:AddControlsCooldown(30)
	end
end
Kindness:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)

--播放神秘音效
function Kindness:OnPickItem(player, item, touched)
	sfx:Play(IBS_Sound.Kindness, 1, 10, false)
end
Kindness:AddCallback(mod.IBS_CallbackID.PICK_COLLECTIBLE, 'OnPickItem', Kindness.ID)


return Kindness