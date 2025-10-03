--回调


local mod = Isaac_BenightedSoul


local function Load(fileName)
	return include("ibs_scripts.callbacks."..fileName)
end

--独立回调
mod.IBS_Callback = {
	RenderOverlay = Load('render_overlay'),
	Benighted = Load('benighted'),
	CheckIronHeart = Load('check_iron_heart'),
	DevilAngelOpenState = Load('devil_angel_open_state'),
	DoubTap = Load('double_tap'),
	CanCollectPickup = Load('can_collect_pickup'),
	PickupFirstAppear = Load('pickup_first_appear'),
	BumDonation = Load('bum_donation'),
}

--回调合集
mod.IBS_Callbacks = {
	Item = Load('item'),
	Greed = Load('greed'),
	Grid = Load('grid'),
	HoldItem = Load('hold_item'),
}

