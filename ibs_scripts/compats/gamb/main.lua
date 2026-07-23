--抽卡mod兼容
---@class PoolInfo
---@field costSingle? number                                -- Default: `6`
---@field costTen? number                                   -- Default: `54`
---@field pityStart? number                                 -- Default: `-1`, Usually: `40`
---@field pityIncrementPerDraw? number                      -- Default: `0.015`
---@field guarantee3? boolean                               -- Default: `false`, Usually: `true`
---@field guarantee4? boolean                               -- Default: `false`
---@field collectiblePools string[]                         -- e.g. `{ "DEFAULT", "MY_ITEMS" }`
---@field pickupPool? string                                -- Default: `"DEFAULT"`
---@field first4Unique? boolean                             -- Default: `false`
---@field hidden? boolean                                   -- Default: `false`
---@field noAllowDraw? boolean                              -- Default: `false`
---@field limitCollectible? table<CollectibleType, number>  -- Default: `nil`
---@field fouceQuality? integer                             -- Default: `nil`

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID
local IBS_TrinketID = mod.IBS_TrinketID
local IBS_PocketID = mod.IBS_PocketID

--愚昧池
do
	local name = "IBS"
	local items = {}
    local limitedItems = {}
	local pickups = {}

	for k,id in pairs(IBS_ItemID) do
		table.insert(items, id)
		limitedItems[id] = 1
	end
	for k,id in pairs(IBS_TrinketID) do
		table.insert(pickups, {v = "5.350."..id, w = 1})
	end
	for k,id in pairs(IBS_PocketID) do
		table.insert(pickups, {v = "5.300."..id, w = 1})
	end

	--注册池
	local items_name = JustGambling:RegisterCollectibleList(name.."_ITEMS", items)
	local pickups_name = JustGambling:RegisterPickupList(name.."_PICKUPS", pickups)
	local pool_name = JustGambling:RegisterPool(
		name,
		{
			hidden = true,
			costSingle = 7,
			costTen = 63,
			pityStart = 70,
			pityIncrementPerDraw = 0.007,
			collectiblePools = {items_name},
			pickupPool = pickups_name,
			limitCollectible = limitedItems
		},
		{
			en = "All from Benighted Soul\nEach item can only be drawn once*",
			zh = "只有来自愚昧的物品\n*每个道具最多抽到一次",
		}
	)

	--背景
	local path = "gfx/ibs/compats/gamb/ibs"
	local BG = Sprite()
	BG:Load(path..".anm2", true)
	JustGambling:RegisterPoolBG(pool_name, BG, "Idle", -1)
end


--SSR池
do
	local name = "IBS_SSR"
	local items = {
		IBS_ItemID.Envy,
		IBS_ItemID.CursedMantle,
		IBS_ItemID.NeedleMushroom,
		IBS_ItemID.MiniHorn,
		IBS_ItemID.ContactC,
		IBS_ItemID.FGHD,
		IBS_ItemID.TheBestWeapon,
		IBS_ItemID.Turbo,
		IBS_ItemID.ChillMind,
		IBS_ItemID.RedHook,
		IBS_ItemID.DoubleDosage,
		IBS_ItemID.KilleR,
		IBS_ItemID.CurseoftheFool,
		IBS_ItemID.RubbishBook,
		IBS_ItemID.DonaldDollar,
		IBS_ItemID.MimicInfestation,
		IBS_ItemID.BobsRottenHand,
	}
	local pickups = {
		{v = "5.350."..IBS_TrinketID.Barren, w = 1},
		{v = "5.350."..IBS_TrinketID.CultistMask, w = 1},
		{v = "5.350."..IBS_TrinketID.CrackCallback, w = 1},
		{v = "5.350."..IBS_TrinketID.Foe, w = 1},
		{v = "5.350."..IBS_TrinketID.ForScreenshot, w = 1},
		{v = "5.350."..IBS_TrinketID.TechSL, w = 1},
		{v = "5.350."..IBS_TrinketID.EnvyToWin, w = 1},
	}

	--注册池
	local items_name = JustGambling:RegisterCollectibleList(name.."_ITEMS", items)
	local pickups_name = JustGambling:RegisterPickupList(name.."_PICKUPS", pickups)
	local pool_name = JustGambling:RegisterPool(
		name,
		{
			hidden = true,
			costSingle = 6,
			costTen = 66,
			pityStart = 666666,
			pityIncrementPerDraw = 0,
			collectiblePools = {items_name},
			pickupPool = pickups_name,
		},
		{
			en = "Text",
			zh = "请输入文本",
		}
	)

	--背景
	local path = "gfx/ibs/compats/gamb/ssr"
	local BG = Sprite()
	BG:Load(path..".anm2", true)
	JustGambling:RegisterPoolBG(pool_name, BG, "Idle", 0)
	mod:AddCallback("JGAMBLING_LOCALIZATION_SPRITE", function()
		JustGambling:TryLocalization(BG, {"zh"}, path..".png")
	end)
end

--pvzh池
do
	local name = "IBS_PVZH"
	local items = {
		IBS_ItemID.Molekale,
		IBS_ItemID.CheeseCutter,
		IBS_ItemID.HyperBlock,
		IBS_ItemID.AstroVera,
		IBS_ItemID.SecretAgent,
		IBS_ItemID.Transmogrify,
	}
    local limitedItems = {}

	for k,id in pairs(items) do
		limitedItems[id] = 1
	end

	--注册池
	local items_name = JustGambling:RegisterCollectibleList(name.."_ITEMS", items)
	local pool_name = JustGambling:RegisterPool(
		name,
		{
			guarantee3 = true,
			costSingle = 6,
			costTen = 54,
			pityStart = 40,
			pityIncrementPerDraw = 0.015,
			collectiblePools = {items_name},
			pickupPool = "DEFAULT",
			limitCollectible = limitedItems,
		},
		{
			en = "PVZH items chance up\nEach item can only be drawn once*",
			zh = "PVZH道具出现概率提升\n*每个PVZH道具最多抽到一次",
		}
	)

	--背景
	local path = "gfx/ibs/compats/gamb/pvzh"
	local BG = Sprite()
	BG:Load(path..".anm2", true)
	JustGambling:RegisterPoolBG(pool_name, BG, "Idle", 0)
	mod:AddCallback("JGAMBLING_LOCALIZATION_SPRITE", function()
		JustGambling:TryLocalization(BG, {"zh"}, path..".png")
	end)
end


--添加固定池
mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.EARLY, function()
	if JustGambling then
		local oldfn = JustGambling.InitRunPools
		function JustGambling:InitRunPools()
			oldfn(self)
			table.insert(JustGambling.Data.PoolsList.Permanent, "IBS_SSR")
		end		
	end
end)

--测试用
--lua table.insert(JustGambling.Data.PoolsList.Permanent, "IBS")
--lua table.insert(JustGambling.Data.PoolsList.Permanent, "IBS_SSR")
--lua table.insert(JustGambling.Data.PoolsList.Permanent, "IBS_PVZH")