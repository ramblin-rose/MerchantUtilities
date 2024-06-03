local AddOn = _G[select(1, ...)]
--------------------------------
AddOn.Number = {
	MERCHANT_ITEM_PER_PAGE = 10, -- defined at v3.4.3 in MerchantFrame
}
--------------------------------
AddOn.Message = {
	ENABLE_ADDON = "ENABLE",
	DISABLE_ADDON = "DISABLE",
	MERCHANT_SHOW = "MERCHANT_SHOW",
	MERCHANT_CLOSE = "MERCHANT_CLOSE",
	MERCHANT_UPDATE = "MERCHANT_UPDATE",
	MERCHANT_PURCHASE = "PURCHASE",
	MERCHANT_PURCHASE_COMPLETED = "PURCHASE_COMPLETED",
}
--------------------------------
AddOn.String = {
	CommandName = string.lower(AddOn.name),
	Title = select(2, GetAddOnInfo(AddOn:GetName())),
}
