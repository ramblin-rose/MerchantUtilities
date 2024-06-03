local AddOn = _G[select(1, ...)]
--------------------------------
AddOn.String = {
	DBName = "MerchantUtilitiesRecipesDB", -- Must be as defined in .toc's SavedVariables
	Title = string.gsub(select(2, GetAddOnInfo(AddOn:GetName())), _G["MerchantUtilities"].String.Title .. " ", ""),
}
