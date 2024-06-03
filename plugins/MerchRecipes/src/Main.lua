local AddOn = _G[select(1, ...)]
local Merch = _G["MerchantUtilities"]
local L = AddOn.L
local RecipesPlugin = Merch.ButtonsPluginTemplate:new({})
local RECIPE_CLASSID = 9
-------------------------------
local function toolTipScanText(text, ...)
	local matched = false
	for i = 1, select("#", ...) do
		local region = select(i, ...)
		if region and region:GetObjectType() == "FontString" then
			local value = region:GetText()
			matched = value == text
			if matched then
				break
			end
		end
	end
	return matched
end
-------------------------------
function RecipesPlugin:GetMerchantItemProfile(merchantItemIndex)
	if self.ttip == nil then
		self.ttip = CreateFrame("GameTooltip", AddOn:GetName() .. "Tooltip", nil, "GameTooltipTemplate")
		---@diagnostic disable-next-line: param-type-mismatch
		self.ttip:SetOwner(WorldFrame, "ANCHOR_NONE")
	end

	local profile = Merch.PluginTemplate:GetMerchantItemProfile(merchantItemIndex)

	if profile then
		profile.isRecipe = select(12, GetItemInfo(profile.itemId)) == RECIPE_CLASSID
		if profile.isRecipe then
			---@diagnostic disable-next-line: param-type-mismatch
			self.ttip:SetMerchantItem(merchantItemIndex)
			-- lacking knowledge of another method, this is how code determines of player knows the recipe.
			profile.recipeKnown = toolTipScanText(ITEM_SPELL_KNOWN, self.ttip:GetRegions())
		end
		if profile.isRecipe == true and profile.recipeKnown == true and profile.itemIsUsable == true then
			return profile
		else
			profile = nil
		end
	end

	return profile
end
----------------------------------
function RecipesPlugin:OnEnterButton(button)
	GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT")
	local tiptext = string.format(L["TooltipTextFormat"], button.itemProfile.itemName)

	GameTooltip:AddLine(tiptext, 250, 250, 250, 0.9)
	GameTooltip:Show()
end
----------------------------------
-- override to prevent purchase by this button
function RecipesPlugin:OnClickButton(button) end
----------------------------------
function AddOn:OnInitialize()
	local buttonTexture = "Interface\\AddOns\\" .. AddOn.name .. "\\assets\\check.png"
	local buttonHighlightText = "Interface\\AddOns\\" .. AddOn.name .. "\\assets\\check.png"

	RecipesPlugin:new():init(AddOn, buttonTexture, buttonHighlightText):Register()

	self.db = LibStub("AceDB-3.0"):New(AddOn.String.DBName, { realm = { optOut = false } })
	local options = {
		name = L["SlashCommand"],
		handler = self,
		type = "group",
		args = {},
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable(tostring(self), options, options.name)
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
