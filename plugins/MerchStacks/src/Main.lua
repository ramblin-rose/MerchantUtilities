local AddOn = _G[select(1, ...)]
local Merch = _G["MerchantUtilities"]
local L = AddOn.L
local StacksPlugin = Merch.ButtonsPluginTemplate:new({})
--------------------------------
function StacksPlugin:GetMerchantItemProfile(merchantItemIndex)
	local profile = Merch.PluginTemplate:GetMerchantItemProfile(merchantItemIndex)
	if profile then
		if
			not profile.itemExtendedCost
			and profile.itemStackCount > 1
			and (profile.itemNumAvailable >= profile.itemStackCount or profile.itemNumAvailable == -1) -- do not show if a full stack cannot be purchased.
		then
			local stackCost = (profile.itemStackCount / profile.itemQuantityPerPurchase) * profile.itemPrice
			if GetMoney() >= stackCost then
				return profile
			end
		end
	end
end
----------------------------------
function StacksPlugin:onPurchase(merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase)
	local profile = StacksPlugin:GetMerchantItemProfile(merchantItemIndex)
	local executePurchase = function()
		Merch.ButtonsPluginTemplate.onPurchase(self, merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase)
	end
	-- the dialog provides an opt-out for future purchase confirmation.
	if AddOn:GetPurchaseOptOut() ~= true then
		local cost = (purchaseItemTotal / itemQuantityPerPurchase) * profile.itemPrice
		local message = string.format(L.ConfirmStackPurchaseFormat, profile.itemName, GetMoneyString(cost))
		Merch.Popups.ConfirmWithOptOut(message, {
			skipPurchaseConfirmation = AddOn:GetPurchaseOptOut(),
			acceptCallback = function(optOut)
				AddOn:SetPurchaseOptOut(optOut)
				executePurchase()
			end,
		})
	else
		executePurchase()
	end
end
--------------------------------
function StacksPlugin:OnEnterButton(button)
	SetCursor("BUY_CURSOR")
	GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
	local tiptext = string.format(L["TooltipTextFormat"], button.itemProfile.itemName)

	GameTooltip:AddLine(tiptext, 250, 250, 250, 0.9)
	GameTooltip:Show()
end
----------------------------------
function AddOn:OnInitialize()
	local buttonTexture = "Interface\\AddOns\\" .. AddOn.name .. "\\assets\\stack.png"
	local buttonHighlightText = "Interface\\AddOns\\" .. AddOn.name .. "\\assets\\stack.png"

	StacksPlugin:new():init(AddOn, buttonTexture, buttonHighlightText):Register()
	self.db = LibStub("AceDB-3.0"):New(AddOn.String.DBName, { realm = { optOut = false } })

	local options = {
		name = L["SlashCommand"],
		handler = self,
		type = "group",
		args = {
			[L["OptOut"]] = {
				name = L["OptOut"],
				desc = L["OptOutDesc"],
				type = "input",
				set = function()
					self.db.realm.optOut = true
					AddOn:Print(L["OptOutSet"])
				end,
			},
			optin = {
				name = L["OptIn"],
				desc = L["OptInDesc"],
				type = "input",
				set = function()
					self.db.realm.optOut = false
					AddOn:Print(L["OptInSet"])
				end,
			},
		},
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable(tostring(self), options, options.name)
end
----------------------------------
function AddOn:SetPurchaseOptOut(optOut)
	if type(optOut) == "boolean" then
		self.db.realm.optOut = optOut
	else
		self.db.realm.optOut = false
	end
end
----------------------------------
function AddOn:GetPurchaseOptOut()
	return self.db.realm.optOut
end
