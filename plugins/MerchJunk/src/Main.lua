local AddOn = _G[select(1, ...)]
local Merch = _G["MerchantUtilities"]
assert(Merch)
local L = AddOn.L
local JunkPlugin = Merch.PluginTemplate:new({})
local button, progressBar = nil, nil
local driverFrame, driver
local merchantIsOpen = false
--------------------------------
local function findBagItemsByQuality(itemQuality)
	local items = {}
	itemQuality = itemQuality or 0
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local meta = C_Container.GetContainerItemInfo(bag, slot)
			if meta then
				local quality = select(3, GetItemInfo(meta.itemID))
				if itemQuality == quality then
					table.insert(items, { bag = bag, slot = slot, itemID = meta.itemID })
				end
			end
		end
	end
	return table.getn(items), items
end
-------------------------------
local function initProgressBar()
	if progressBar == nil then
		progressBar = Merch:GetProgressBar()
		progressBar:SetParent(MerchantFrame)
		progressBar:SetPoint("LEFT", button, "RIGHT", 10, 0)
		progressBar:SetWidth(200)
		progressBar:SetHeight(20)
		progressBar.label:SetText("Status Bar")
		progressBar:SetMinMaxValues(1, 20)
		progressBar:SetValue(10)
		progressBar:Hide()
		driverFrame = CreateFrame("Frame")
		driver = Merch.CoroutineDriver:new(driverFrame, 0, 0.1)
	end
end
-------------------------------
local function sellJunk()
	local count, items = findBagItemsByQuality()
	if count then
		initProgressBar()
		assert(progressBar)
		local executeSale = function()
			progressBar:SetMinMaxValues(1, count + 1)
			progressBar:SetValue(0)
			progressBar:Show()
			for i, e in pairs(items) do
				local meta = C_Container.GetContainerItemInfo(e.bag, e.slot)
				progressBar.label:SetText(meta.itemName)
				if meta and meta.itemID == e.itemID then
					if merchantIsOpen then
						C_Container.UseContainerItem(e.bag, e.slot)
					else
						break
					end
				end
				progressBar:SetValue(progressBar:GetValue() + 1)
				if count ~= i then
					if coroutine.yield() then
						break
					end
				end
			end
			progressBar:Hide()
		end

		if AddOn:GetOptOut() then
			driver:Start(executeSale)
		else
			local message = string.format(L.ConfirmJunkSaleFormat, count)
			Merch.Popups.ConfirmWithOptOut(message, {
				skipPurchaseConfirmation = false,
				acceptCallback = function(optOut)
					AddOn:SetOptOut(optOut)
					driver:Start(executeSale)
				end,
			})
		end
	end
end
-------------------------------
local function updateState()
	if button then
		local count = findBagItemsByQuality()
		if count > 0 then
			button:Show()
		else
			button:Hide()
		end
	end
end
-------------------------------
local function createButton()
	local buttonTexturePath = "Interface\\AddOns\\" .. AddOn.name .. "\\assets\\trashcan.png"
	local buttonHighlightPath = "Interface\\AddOns\\" .. AddOn.name .. "\\assets\\trashcan.png"
	button = CreateFrame("Button", nil, MerchantFrame)
	button:Hide()
	button:SetWidth(20)
	button:SetHeight(20)
	button:SetPoint("TOPLEFT", MerchantFrame, "TOPLEFT", 60, -32)

	local texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetTexture(buttonTexturePath)
	button:SetNormalTexture(texture)

	texture = button:CreateTexture(nil, "ARTWORK")
	texture:SetTexture(buttonHighlightPath)
	button:SetHighlightTexture(texture)

	button:SetScript("OnEnter", function()
		SetCursor("BUY_CURSOR")
		GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
		GameTooltip:AddLine(
			string.format(L.SellJunkToolTipText, select(1, findBagItemsByQuality())),
			250,
			250,
			250,
			0.9
		)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		SetCursor(nil)
		GameTooltip:Hide()
	end)
	-- to avoid UI ambiguity due to cursor change
	button:RegisterForClicks("RightButtonUp", "LeftButtonUp")

	local coin = CreateFrame("Frame", nil, button)
	coin:SetWidth(12)
	coin:SetHeight(12)
	coin.texture = coin:CreateTexture(nil, "OVERLAY")
	coin.texture:SetAllPoints(coin)
	coin.texture:SetTexture("Interface\\MONEYFRAME\\UI-GoldIcon.blp")
	coin:SetPoint("TOPLEFT", button, "BOTTOMRIGHT", -8, 7)

	button:SetScript("OnClick", function()
		sellJunk()
	end)

	return button
end
--------------------------------
function JunkPlugin:onMerchantShow(...)
	merchantIsOpen = true
	updateState()
end
--------------------------------
function JunkPlugin:onMerchantUpdate(...)
	updateState()
end
--------------------------------
function JunkPlugin:onMerchantClose(...)
	merchantIsOpen = false
	if driver then
		driver:Stop()
	end
	assert(button)
	button:Hide()
end
----------------------------------
function AddOn:OnInitialize()
	JunkPlugin:new():init(AddOn):Register()
	self.db = LibStub("AceDB-3.0"):New(AddOn.String.DBName, { profile = {}, realm = { optOut = false } })
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
	createButton()
end
----------------------------------
function AddOn:SetOptOut(optOut)
	if type(optOut) == "boolean" then
		self.db.realm.optOut = optOut
	else
		self.db.realm.optOut = false
	end
end
----------------------------------
function AddOn:GetOptOut()
	return self.db.realm.optOut
end
----------------------------------
