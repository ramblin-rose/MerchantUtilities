local AddOn = _G[select(1, ...)]
--------------------------------
local function getItemIdFromLink(link)
	if type(link) == "string" then
		local match = link:match("|Hitem:(%d+):")
		if match == nil then
			match = link:match("|Hspell:(%d+):")
		end
		if match == nil then
			match = link:match("|Hcurrency:(%d+):")
		end
		return tonumber(match or 0)
	end
	return 0
end
--------------------------------
local function getItemNameFromLink(link)
	if type(link) == "string" then
		local match = link:match("|h[(%w+)]h|")
		return tostring(match or 0)
	end
	return 0
end
--------------------------------
local function pack(...)
	return { n = select("#", ...), ... }
end
--------------------------------
local function unpack(t, i, j)
	i = i or 1
	j = j or #t
	if i <= j then
		return t[i], unpack(t, i + 1, j)
	end
end
--------------------------------
local function getPrintableLink(link)
	return link:gsub("\124", "\124\124")
end
--------------------------------
local function split(text, separator)
	local parts = {}
	for part in string.gmatch(text, "[^" .. separator .. "]+") do
		table.insert(parts, part)
	end
	return unpack(parts)
end
--------------------------------
AddOn.Utility = {
	getItemIdFromLink = getItemIdFromLink,
	getItemNameFromLink = getItemNameFromLink,
	pack = pack,
	unpack = unpack,
	getPrintableLink = getPrintableLink,
	split = split,
}
