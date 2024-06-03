local AddOn = _G[select(1, ...)]
local PluginTemplate = AddOn.PluginTemplate
---@class ButtonsPluginTemplate:PluginTemplate
local ButtonsPluginTemplate = PluginTemplate:new({})
--------------------------------
function ButtonsPluginTemplate:new()
	local instance = setmetatable({}, self)
	self.__index = self
	instance.buttons = {}
	return instance
end
--------------------------------
function ButtonsPluginTemplate:init(plugin, buttonTexturePath, buttonHighlightTexturePath)
	PluginTemplate:init(plugin)
	self.buttonTexturePath = buttonTexturePath
	self.buttonHighlightTexturePath = buttonHighlightTexturePath
	self.messageHandler = {
		[AddOn.Message.ENABLE_ADDON] = self.OnEnableAddOn,
		[AddOn.Message.DISABLE_ADDON] = self.OnDisableAddOn,
		[AddOn.Message.MERCHANT_SHOW] = self.onMerchantShow,
		[AddOn.Message.MERCHANT_CLOSE] = self.onMerchantClose,
		[AddOn.Message.MERCHANT_UPDATE] = self.onMerchantUpdate,
		[AddOn.Message.MERCHANT_PURCHASE_COMPLETED] = self.onPurchaseCompleted,
	}
	return self
end
--------------------------------
function ButtonsPluginTemplate:__tostring()
	return self.plugin.name .. ".ButtonsPluginTemplate"
end
--------------------------------
function ButtonsPluginTemplate:SetButton(merchantButtonIndex, button)
	self.buttons[merchantButtonIndex] = button
	return button
end
--------------------------------
function ButtonsPluginTemplate:GetButton(merchantButtonIndex)
	return self.buttons[merchantButtonIndex]
end
--------------------------------
function ButtonsPluginTemplate:HideButtons()
	for merchantButtonIndex = 1, AddOn.Number.MERCHANT_ITEM_PER_PAGE do
		local button = self:GetButton(merchantButtonIndex)
		if button ~= nil then
			button:Hide()
		end
	end
end
--------------------------------
function ButtonsPluginTemplate:EnableButtons(enable)
	for merchantButtonIndex = 1, AddOn.Number.MERCHANT_ITEM_PER_PAGE do
		local button = self:GetButton(merchantButtonIndex)
		if button ~= nil then
			if enable then
				button:Enable()
			else
				button:Disable()
			end
		end
	end
end
--------------------------------
function ButtonsPluginTemplate:CreateButton(merchantItemIndex)
	local merchantItemContainerName = "MerchantItem" .. merchantItemIndex
	local merchantItemContainer = _G[merchantItemContainerName]
	local button = CreateFrame("Button", AddOn.name .. merchantItemContainerName, merchantItemContainer)
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetPoint("BOTTOMRIGHT", merchantItemContainer, "BOTTOMRIGHT", -8, 1)

	local texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetTexture(self.buttonTexturePath)
	button:SetNormalTexture(texture)

	texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetTexture(self.buttonHighlightTexturePath)
	button:SetHighlightTexture(texture)

	button:SetScript("OnClick", function()
		self:OnClickButton(button)
	end)

	button:SetScript("OnEnter", function()
		self:OnEnterButton(button)
	end)

	button:SetScript("OnLeave", function()
		self:OnLeaveButton(button)
	end)

	-- avoid cursor ambiguity
	button:RegisterForClicks("RightButtonUp", "LeftButtonUp")

	return button
end
--------------------------------
function ButtonsPluginTemplate:OnClickButton(button)
	self:onPurchase(
		button.itemProfile.merchantItemIndex,
		button.itemProfile.itemStackCount,
		button.itemProfile.itemQuantityPerPurchase
	)
end
--------------------------------
function ButtonsPluginTemplate:OnEnterButton(button) end
--------------------------------
function ButtonsPluginTemplate:OnLeaveButton(button)
	SetCursor(nil)
	GameTooltip:Hide()
end
--------------------------------
function ButtonsPluginTemplate:UpdateButtons()
	self:HideButtons()
	if AddOn:GetCurrentMerchantTabIndex() == 1 then
		local lbound, ubound = AddOn:GetMerchantPageBounds()
		local merchantButtonIndex = 1
		for merchantItemIndex = lbound, ubound do
			local itemProfile = self:GetMerchantItemProfile(merchantItemIndex)
			local button = self:GetButton(merchantButtonIndex)
			if itemProfile then
				if button == nil then
					button = self:CreateButton(merchantButtonIndex)
					self:SetButton(merchantButtonIndex, button)
				end
				assert(button)
				button.itemProfile = itemProfile
				button:Show()
			end
			merchantButtonIndex = merchantButtonIndex + 1
		end
	end
end
--------------------------------
function ButtonsPluginTemplate:onPurchase(merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase)
	self:EnableButtons(false) -- debounce
	PluginTemplate:onPurchase(merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase)
end
--------------------------------
function ButtonsPluginTemplate:onPurchaseCompleted(...)
	self:EnableButtons(true) -- debounce
	self:UpdateButtons()
end
--------------------------------
function ButtonsPluginTemplate:onMerchantShow(...)
	self:UpdateButtons()
end
--------------------------------
function ButtonsPluginTemplate:onMerchantUpdate(...)
	self:UpdateButtons()
end
--------------------------------
function ButtonsPluginTemplate:onMerchantClose(...)
	self:HideButtons()
end
--------------------------------
function ButtonsPluginTemplate:OnDisableAddOn(...)
	self:HideButtons()
end
--------------------------------
function ButtonsPluginTemplate:OnEnableAddOn(...)
	self:UpdateButtons()
end
--------------------------------
AddOn.ButtonsPluginTemplate = ButtonsPluginTemplate
