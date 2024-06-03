local addonName = select(1, ...)
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

L["SlashCommand"] = "mustacks"

L["TooltipTextFormat"] = "Purchase a stack of\n%s" -- stack size, item name, money
L["ConfirmStackPurchaseFormat"] = "Are you sure you want to purchase a stack of %s for %s ?"

L["OptOut"] = "optout"
L["OptOutDesc"] = "Disable purchase confirmation"
L["OptOutSet"] = "Purchase confirmation disabled"

L["OptIn"] = "optout"
L["OptInDesc"] = "Enable purchase confirmation"
L["OptInSet"] = "Purchase confirmation enabled"
