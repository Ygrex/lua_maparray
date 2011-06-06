local map = require "maparray";
local _ = map.wrap;

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

io.write "negations of squares:\n"
write( map.map(cp(integer), - _() * _()) );
io.write "letter equivalents:\n"
write( map.map(cp(integer), _(_() + ("A"):byte(), string.char) ) );
io.write "map even integers:\n"
write( map.map(cp(integer), 1 - _() % 2) );
io.write "format sequence output with a map function:\n"
write( map.map(cp(integer), "Integer #" .. (_() + 1) .. ": " .. _() .. ";" ) );

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

