local AddOn = _G[select(1, ...)]
local L = AddOn.L
--------------------------------
function AddOn:OnInitialize()
	local options = {
		name = AddOn.String.CommandName,
		handler = self,
		type = "group",
		args = {
			[L["on"]] = {
				name = L["on"],
				desc = ENABLE .. " " .. AddOn.String.Title,
				type = "input",
				set = function()
					AddOn:SendMessage(AddOn.Message.ENABLE_ADDON)
					AddOn:Print(READY)
				end,
			},
			[L["off"]] = {
				name = L["off"],
				desc = DISABLE .. " " .. AddOn.String.Title,
				type = "input",
				set = function()
					AddOn:SendMessage(AddOn.Message.DISABLE_ADDON)
					AddOn:Print(ADDON_DISABLED)
				end,
			},
		},
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable(tostring(self), options, AddOn.String.CommandName)
	AddOn:SendMessage(AddOn.Message.ENABLE_ADDON)
end
--------------------------------
local plugins, onEnableAddOn, onDisableAddOn, onPurchase, OnMerchantUpdate, OnMerchantShow, OnMerchantClosed, OnSetMerchantTab, currentMerchantTabIndex
--------------------------------
onPurchase = function(merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase, ...)
	local maxStack = GetMerchantItemMaxStack(merchantItemIndex)
	local quantity = 0
	while purchaseItemTotal > 0 do
		if purchaseItemTotal >= maxStack then
			quantity = maxStack
		else
			quantity = purchaseItemTotal
		end
		BuyMerchantItem(merchantItemIndex, quantity)
		purchaseItemTotal = purchaseItemTotal - quantity
	end
	AddOn:SendMessage(AddOn.Message.MERCHANT_PURCHASE_COMPLETED, merchantItemIndex, purchaseItemTotal, ...)
end
--------------------------------
OnMerchantShow = function(...)
	if InCombatLockdown() then
		AddOn:Print(BLIZZARD_STORE_ERROR_TITLE_PARENTAL_CONTROLS .. " (" .. ERR_NOT_IN_COMBAT .. ")")
	else
		AddOn:SecureHook("MerchantFrame_Update", OnMerchantUpdate)
		AddOn:SecureHook("PanelTemplates_SetTab", OnSetMerchantTab)
		AddOn:SendMessage(AddOn.Message.MERCHANT_SHOW)
	end
end
--------------------------------
OnMerchantUpdate = function(...)
	AddOn:SendMessage(AddOn.Message.MERCHANT_UPDATE)
end
--------------------------------
OnMerchantClosed = function(...)
	AddOn:Unhook("MerchantFrame_Update")
	AddOn:Unhook("PanelTemplates_SetTab")
	AddOn:SendMessage(AddOn.Message.MERCHANT_CLOSE)
end
--------------------------------
OnSetMerchantTab = function(_, tabIndex)
	currentMerchantTabIndex = tabIndex
end
--------------------------------
onEnableAddOn = function(...)
	AddOn:RegisterEvent("MERCHANT_SHOW", OnMerchantShow)
	AddOn:RegisterEvent("MERCHANT_CLOSED", OnMerchantClosed)
	AddOn:RegisterEvent("MERCHANT_CLOSED", OnMerchantClosed)
end
--------------------------------
onDisableAddOn = function(...)
	AddOn:UnregisterEvent("MERCHANT_SHOW")
	AddOn:UnregisterEvent("MERCHANT_CLOSED")
end
--------------------------------
local messageHandler = {
	[AddOn.Message.ENABLE_ADDON] = onEnableAddOn,
	[AddOn.Message.DISABLE_ADDON] = onDisableAddOn,
	[AddOn.Message.MERCHANT_PURCHASE] = onPurchase,
}
--------------------------------
local function onMessage(message, ...)
	local handler = messageHandler[message]
	if type(handler) == "function" then
		handler(...)
	end
end
--------------------------------
AddOn:RegisterMessage(AddOn.Message.MERCHANT_PURCHASE, onMessage)
AddOn:RegisterMessage(AddOn.Message.ENABLE_ADDON, onMessage)
AddOn:RegisterMessage(AddOn.Message.DISABLE_ADDON, onMessage)
--------------------------------
function AddOn:RegisterPlugin(that, handler)
	plugins = plugins or {}
	plugins[that.name] = that
	that:RegisterMessage(AddOn.Message.ENABLE_ADDON, handler)
	that:RegisterMessage(AddOn.Message.DISABLE_ADDON, handler)
	that:RegisterMessage(AddOn.Message.MERCHANT_SHOW, handler)
	that:RegisterMessage(AddOn.Message.MERCHANT_UPDATE, handler)
	that:RegisterMessage(AddOn.Message.MERCHANT_CLOSE, handler)
	that:RegisterMessage(AddOn.Message.MERCHANT_PURCHASE_COMPLETED, handler)
end
--------------------------------
function AddOn:UnregisterPlugin(that)
	plugins[that.name] = nil
	that:UnregisterMessage(AddOn.Message.ENABLE_ADDON)
	that:UnregisterMessage(AddOn.Message.DISABLE_ADDON)
	that:UnregisterMessage(AddOn.Message.MERCHANT_SHOW)
	that:UnregisterMessage(AddOn.Message.MERCHANT_UPDATE)
	that:UnregisterMessage(AddOn.Message.MERCHANT_CLOSE)
	that:RegisterMessage(AddOn.Message.MERCHANT_PURCHASE_COMPLETED)
end
--------------------------------
function AddOn:GetMerchantPageBounds()
	local lbound = (MerchantFrame.page - 1) * AddOn.Number.MERCHANT_ITEM_PER_PAGE + 1
	local ubound = lbound + AddOn.Number.MERCHANT_ITEM_PER_PAGE - 1
	return lbound, ubound
end
--------------------------------
-- 1 is purchase tab
-- 2 is buyback tab
function AddOn:GetCurrentMerchantTabIndex()
	return currentMerchantTabIndex
end

local progressBar
function AddOn:GetProgressBar()
	if progressBar == nil then
		progressBar = CreateFrame("StatusBar")
		progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		progressBar:SetStatusBarColor(0.22, 0.32, 0.7)
		progressBar.border = CreateFrame("Frame", nil, progressBar, "BackdropTemplate")
		progressBar.border:SetPoint("TOPLEFT", progressBar, "TOPLEFT", -2, 2)
		progressBar.border:SetPoint("BOTTOMRIGHT", progressBar, "BOTTOMRIGHT", 2, -2)
		progressBar.border:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = false,
			edgeSize = 8,
			insets = { left = 2, right = 2, top = 3, bottom = 3 },
		})
		progressBar.border:SetBackdropColor(0, 0, 0, 0.8)
		progressBar.border:SetFrameLevel(progressBar:GetFrameLevel())
		local label = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightCenter")
		label:SetPoint("CENTER", progressBar, "CENTER")
		label:SetJustifyH("LEFT")
		label:SetJustifyV("TOP")
		progressBar.label = label
		progressBar:Hide()
	end
	progressBar:SetParent(nil)
	return progressBar
end
--------------------------------
