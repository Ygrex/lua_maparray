--[[
	Map - module to map 1D arrays
--]]

-- {{{ Lambda - Lambda-functions constructor
local Lambda = {} do

	-- {{{ global scope dependencies
	local _assert = assert;
	if not _assert then return false end;
	local _getmetatable = _assert(getmetatable);
	local _rawequal = _assert( rawequal );
	local _select = _assert( select );
	local _setmetatable = _assert(setmetatable);
	local _table = _assert(table);
	local _type = _assert(type);
	-- }}} global scope dependencies

	-- some different value, where stack to store
	local _stack = {};
	-- Lambda metatable
	local _mt_Lambda = {};
	Lambda["mt"] = _mt_Lambda;

	local _mt_table = { ["__index"] = _table };
	local _new_table = function() return _setmetatable({}, _mt_table) end;

	function Lambda.lt(a, b) return a < b end;
	function Lambda.index(t, k) return t[k] end;
	Lambda[""] = function(...) return ... end;

	Lambda["%"] = function(a, b) return a % b end;
	Lambda["^"] = function(a, b) return a ^ b end;
	Lambda["-"] = function(a, b)
		if not b then return -a end;
		return a - b;
	end;
	Lambda["+"] = function(a, b) return a + b end;
	Lambda["/"] = function(a, b) return a / b end;
	Lambda["*"] = function(a, b) return a * b end;
	Lambda[".."] = function(a, b) return a .. b end;
	Lambda["<"] = function(a, b) return a < b end;
	Lambda["<="] = function(a, b) return a <= b end;
	Lambda[">"] = function(a, b) return a > b end;
	Lambda[">="] = function(a, b) return a >= b end;
	Lambda["=="] = function(a, b) return a == b end;

	local function _is_Lambda(obj)
		return _getmetatable(obj) == _mt_Lambda;
	end;

	local function _unpack_tbl(tbl, cx)
		if tbl["n"] < cx then return end;
		return tbl[cx], _unpack_tbl(tbl, cx + 1);
	end;

	local function _params(self, cx, step, init, ...)
		if cx > #step then return end;
		local val = step[cx];
		if _rawequal(val, self) then
			val = (...);
		elseif _is_Lambda(val) then
			val = val(_unpack_tbl(init, 1));
		end;
		return val, _params(self, cx + 1, step, init, ...);
	end;

	local function _run(self, step, init, ...)
		local f = step[1];
		if _rawequal(f, nil) then return ... end;
		if _type(f) == "number" then return init[f] end;
		if _rawequal(f, self) then return init[1] end;
		return f(_params(self, 2, step, init, ...));
	end;

	local function _call(self, cx, init, ...)
		local step = self[_stack][cx];
		if not step then return ... end;
		return _call(
			self, cx + 1, init,
			_run(self, step, init, ...)
		);
	end;

	function _make_oper(oper)
		return function(a, b)
			local obj = a;
			if not _is_Lambda(obj) then obj = b end;
			obj[_stack]:insert {Lambda[oper], a, b};
			return obj;
		end;
	end;

	_mt_Lambda["__concat"] = _make_oper "..";
	_mt_Lambda["__unm"] = function(a)
		a[_stack]:insert {Lambda["-"], a};
		return a;
	end;
	_mt_Lambda["__eq"] = _make_oper "==";
	_mt_Lambda["__add"] = _make_oper "+";
	_mt_Lambda["__sub"] = _make_oper "-";
	_mt_Lambda["__mul"] = _make_oper "*";
	_mt_Lambda["__div"] = _make_oper "/";
	_mt_Lambda["__mod"] = _make_oper "%";
	_mt_Lambda["__pow"] = _make_oper "^";
	_mt_Lambda["__index"] = function(tbl, k)
		tbl[_stack]:insert {Lambda.index, tbl, k};
		return tbl;
	end;

	local function _pack_tbl(...)
		return {["n"] = _select("#", ...), ...};
	end;

	_mt_Lambda["__call"] = function(self, ...)
		return _call(self, 1, _pack_tbl(...), ...);
	end;

	function Lambda:apply_params(obj, func, ...)
		obj[_stack]:insert {func, ...}
		return obj;
	end;

	-- {{{ Lambda:new(…) - constructor
	--	... - is a number for parameter placeholder or
	--		function with argument list
	function Lambda:new(...)
		local operator = (...);
		if operator and _type(operator) == "string" then
			local operator = self[operator];
			return function(...)
				return self:new(operator, ...);
			end;
		end;
		local p = _setmetatable({[_stack] = _new_table()}, _mt_Lambda);
		self:apply_params(p, ...);
		return p;
	end;
	-- }}} Lambda:new()
end;
-- }}} Lambda

-- map array
local function map(array, func)
	for i = 1, #array, 1 do array[i] = func(array[i]) end;
	return array;
end;

-- map associative array
local function mapa(array, func)
	for k, v in pairs(array) do array[k] = func(v) end;
	return array;
end;

-- Map wrapper for functions
local function wrap(...) return Lambda:new(...) end;

return {
	["Lambda"]	= Lambda,
	["map"]		= map,
	["mapa"]	= mapa,
	["wrap"]	= wrap,
};

