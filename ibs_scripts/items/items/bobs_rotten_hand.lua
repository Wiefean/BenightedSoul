--鲍勃的烂手

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local BobsRottenHand = mod.IBS_Class.Item(mod.IBS_ItemID.BobsRottenHand)

function BobsRottenHand:OnPlayeUpdate(player)
	if not player:HasCollectible(self.ID) then return end
	local data = self._Ents:GetTempData(player)
	
	--每次按住攻击只触发一次
	if self._Players:IsShooting(player) then
		if not data.BobsRottenHandTriggered then
			data.BobsRottenHandTriggered = true
		
			--爆炸眼泪
			local tear = Isaac.Spawn(2, 0, 0, player.Position, self._Players:GetAimingVector(player)*20, player):ToTear()
			tear:AddTearFlags(TearFlags.TEAR_EXPLOSIVE)
			tear.CollisionDamage = player.Damage
			tear:SetColor(Color(100/255, 1, 100/255, 1),-1,0)
			tear:Update()
		end
	else
		data.BobsRottenHandTriggered = nil 
	end
end
BobsRottenHand:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayeUpdate', 0)


return BobsRottenHand