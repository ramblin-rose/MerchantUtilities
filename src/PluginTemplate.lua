local AddOn = _G[select(1, ...)]
---@class PluginTemplate
local PluginTemplate = {}
--------------------------------
--------------------------------
function PluginTemplate:new(obj)
	local instance = setmetatable(obj or {}, self)
	self.__index = self
	return instance
end

function PluginTemplate:init(plugin)
	self.plugin = plugin
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
function PluginTemplate:__tostring()
	return self.PluginTemplate.name .. ".PluginTemplate"
end
--------------------------------
function PluginTemplate:Register()
	assert(self.plugin)
	AddOn:RegisterPlugin(self.plugin, function(...)
		self:OnMessage(...)
	end)
	return self
end
--------------------------------
function PluginTemplate:Unregister()
	AddOn:UnegisterPlugin(self.plugin)
	return self
end
--------------------------------
function PluginTemplate:GetMerchantItemProfile(merchantItemIndex)
	local itemLink = GetMerchantItemLink(merchantItemIndex)
	if itemLink then
		local itemId = AddOn.Utility.getItemIdFromLink(itemLink)

		local itemName,
			itemTexture,
			itemPrice,
			itemQuantityPerPurchase,
			itemNumAvailable,
			_, --[[itemIsPurchasable]]
			itemIsUsable,
			itemExtendedCost =
			GetMerchantItemInfo(merchantItemIndex)
		local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemLink)
		local this = self
		return {
			itemLink = itemLink,
			itemId = itemId,
			itemName = itemName,
			itemTexture = itemTexture,
			merchantItemIndex = merchantItemIndex,
			itemPrice = itemPrice,
			itemQuantityPerPurchase = itemQuantityPerPurchase,
			itemNumAvailable = itemNumAvailable,
			--	itemIsPurchasable = isPurchasable, unreliable/bad documentation.
			itemIsUsable = itemIsUsable == true,
			itemExtendedCost = itemExtendedCost,
			itemStackCount = itemStackCount,
			purchaseFunc = function(...)
				this:onPurchase(...)
			end,
		}
	end
end
--------------------------------
function PluginTemplate:onPurchase(merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase)
	AddOn:SendMessage(AddOn.Message.MERCHANT_PURCHASE, merchantItemIndex, purchaseItemTotal, itemQuantityPerPurchase)
end
--------------------------------
function PluginTemplate:onPurchaseCompleted(...) end
--------------------------------
function PluginTemplate:onMerchantShow(...) end
--------------------------------
function PluginTemplate:onMerchantUpdate(...) end
--------------------------------
function PluginTemplate:onMerchantClose(...) end
--------------------------------
function PluginTemplate:OnEnableAddOn(...) end
--------------------------------
function PluginTemplate:OnDisableAddOn(...) end
--------------------------------
function PluginTemplate:OnMessage(message, ...)
	local handler = self.messageHandler[message]
	if type(handler) == "function" then
		handler(self, ...)
	end
end
--------------------------------
AddOn.PluginTemplate = PluginTemplate
