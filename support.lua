-- Code in this file is not subject to the copyright or license conditions
-- as specified in the COPYRIGHT and/or LICENSE files

-- console log with optional string formatting
log = function (...)
	local arg = table.pack(...)
	local a,b = math.modf(os.clock())
	if b==0 then b='000' else b=tostring(b):sub(3,5) end
	local prefix = os.date("%x %X", os.time())..'.'..b
	arg[1] = prefix .. ": " .. arg[1]
	if #arg > 1 then
		print(string.format(table.unpack(arg)))
	else
		print(arg[1])
	end
end

dlog = function (...)
	if _G['debugEnabled'] then
		log(...)
	end
end

-- look for value in first level
in_array = function (tb, value)
	for k,v in pairs(tb) do
		if v == value then
			return k
		end
	end
	return false
end

-- Source: http://lua-users.org/wiki/SplitJoin
-- Author: Lance Li
function explode(sep, str, limit)
    if not sep or sep == "" then return false end
    if not str then return false end
    limit = limit or mhuge
    if limit == 0 or limit == 1 then return {str},1 end

    local r = {}
    local n, init = 0, 1

    while true do
        local s,e = string.find(str, sep, init, true)
        if not s then break end
        r[#r+1] = string.sub(str, init, s - 1)
        init = e + 1
        n = n + 1
        if n == limit - 1 then break end
    end

    if init <= string.len(str) then
        r[#r+1] = string.sub(str, init)
    else
        r[#r+1] = ""
    end
    n = n + 1

    if limit < 0 then
        for i=n, n + limit + 1, -1 do r[i] = nil end
        n = n + limit
    end

    return r, n
end
