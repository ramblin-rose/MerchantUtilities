local AddOn = _G[select(1, ...)]
local L = AddOn.L
local StaticPopupConfirmPurchaseWithOptOut = AddOn.name .. "_CONFIRM_PURCHASE"
local StaticPopupConfirmWithOptOut_CheckButton
local StaticPopupConfirmWithOptOut_CheckButtonFontString
-- data must be a table with
-- acceptCallback(optOut [boolean|nil]) - function invoked when the purchase is confirmed.
local function ConfirmWithOptOut(message, data)
	local popup = StaticPopup_Show(StaticPopupConfirmPurchaseWithOptOut, nil, nil, data)
	_G[popup:GetName() .. "Text"]:SetText(message)
	return popup
end
--[[
	Display a simple purchase confirmation with an opt out check button 
]]
StaticPopupDialogs[StaticPopupConfirmPurchaseWithOptOut] = {
	text = "Stub",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		if StaticPopupConfirmWithOptOut_CheckButton:IsVisible() then
			data.acceptCallback(StaticPopupConfirmWithOptOut_CheckButton:GetChecked())
		else
			data.acceptCallback(nil)
		end
	end,
	OnShow = function(self, data)
		local point, _, relativePoint, _, yOfs = self.editBox:GetPoint()
		self.editBox:Hide()
		local cb = StaticPopupConfirmWithOptOut_CheckButton
			or CreateFrame("CheckButton", nil, nil, "ChatConfigCheckButtonTemplate")
		cb:SetParent(self)
		cb:SetPoint(point, self, relativePoint, -100, yOfs)
		cb:SetChecked(false)
		cb:Show()

		local fontString = StaticPopupConfirmWithOptOut_CheckButtonFontString
			or self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		fontString:SetParent(self)
		fontString:SetText(L["DontAskAgain"])
		fontString:SetPoint("LEFT", cb, "RIGHT", 3, 0)
		fontString:Show()

		StaticPopupConfirmWithOptOut_CheckButton = cb
		StaticPopupConfirmWithOptOut_CheckButtonFontString = fontString
	end,
	OnHide = function()
		AddOn.skipPurchaseConfirmationDialog = StaticPopupConfirmWithOptOut_CheckButton:GetChecked()
		StaticPopupConfirmWithOptOut_CheckButton:Hide()
		StaticPopupConfirmWithOptOut_CheckButton:SetParent(nil)
		StaticPopupConfirmWithOptOut_CheckButtonFontString:Hide()
		StaticPopupConfirmWithOptOut_CheckButtonFontString:SetParent(nil)
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasEditBox = true, -- hack to use editbox as an anchor for the checkbox and its text
}

AddOn.Popups = {
	ConfirmWithOptOut = ConfirmWithOptOut,
}

