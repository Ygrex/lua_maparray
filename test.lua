local map = require "maparray";
local L = map.wrap;

-- make a copy of the given table
local function cp(tbl)
	local t = {};
	for k, v in pairs(tbl) do t[k] = v end;
	return t;
end;

local integer = {0, 1, 2, 3, 4, 5};

-- print out the table content
local function write(tbl)
	for i = 1, #tbl, 1 do
		io.write("\t", integer[i], " -> ", tbl[i], "\n");
	end;
end;

--[[
local city = {
	{ ["name"] = "Helsinky" },
	{ ["name"] = "Riga" },
	{ ["name"] = "Moscow" },
	{ ["name"] = "Rome" },
	{ ["name"] = "Washington" },
	{ ["name"] = "Grozny" },
};
l = L "<" (L(1)["name"], L(2)["name"]);
_ = function(...) return l(...) end;
table.sort(city, _);
for i = 1, #city, 1 do print(i, city[i]["name"]) end;
--]]
io.write "negations of squares:\n"
write( map.map(cp(integer), - L() * L()) );
io.write "letter equivalents:\n"
write( map.map(cp(integer), L(string.char, L() + ("A"):byte()) ) );
io.write "map even integers:\n"
write( map.map(cp(integer), 1 - L() % 2) );
io.write "format sequence output with a map function:\n"
write( map.map(cp(integer), "Integer #" .. (L() + 1) .. ": " .. L() .. ";" ) );


--[[
-- same examples with regular Lua syntax:
write( map.map(cp(integer), function(v) return - v * v end) );
write( map.map(
	cp(integer),
	function(v) return string.char(v + ("A"):byte()) end
) );
write( map.map(cp(integer), function(v) return 1 - v % 2 end) );
write( map.map(
	cp(integer),
	function(v) return "Integer #" .. (v + 1) .. ": " .. v .. ";" end
) );
--]]

