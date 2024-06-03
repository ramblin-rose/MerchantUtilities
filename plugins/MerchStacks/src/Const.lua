local AddOn = _G[select(1, ...)]
--------------------------------
AddOn.String = {
	DBName = "MerchantUtilitiesStacksDB", -- must be as defined in .toc ## SavedVariables
	Title = string.gsub(select(2, GetAddOnInfo(AddOn:GetName())), _G["MerchantUtilities"].String.Title .. " ", ""),
}
