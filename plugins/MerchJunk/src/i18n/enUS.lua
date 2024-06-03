local addonName = select(1, ...)
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

L["SlashCommand"] = "mujunk"
L["OptOut"] = "optout"
L["OptOutDesc"] = "Disable junk sale confirmation"
L["OptOutSet"] = "Junk sale confirmation disabled"

L["OptIn"] = "optout"
L["OptInDesc"] = "Enable junk sale confirmation"
L["OptInSet"] = "Junk sale confirmation enabled"

L["ConfirmJunkSaleFormat"] = "Sell all junk items?"
L["SellJunkToolTipText"] = "Sell all junk items\n(%i available)"
