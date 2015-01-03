-- Copyright (c) 2014, Jeffrey Clark. This file is licensed under the
-- Affero General Public License version 3 or later. See the COPYRIGHT file.

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

-- look for value in first level
in_array = function (tb, value)
	for k,v in pairs(tb) do
		if v == value then
			return k
		end
	end
	return false
end
