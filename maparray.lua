--[[
	Map - module to map 1D arrays
--]]

-- {{{ Map - operator stack
local Map = {} do
	-- metatable for instances of `Map`
	local _mt_Map = { ["__index"] = Map };

	-- required globals
	local _assert		= assert;
	if not assert then return false end;
	local _getmetatable	= _assert( getmetatable );
	local _rawequal		= _assert( rawequal );
	local _setmetatable	= _assert( setmetatable );
	local _type		= _assert( type );

	-- identifier of unary functions
	local _unary = {};

	-- make table with global `table` as index
	local _new_table do
		local _mt_table = { ["__index"] = table };
		_new_table = function()
			return _setmetatable({}, _mt_table);
		end;
	end;

	-- make handler for binary operator
	local function _handler(meth)
		return function(self, val)
			local rev;
			if _getmetatable(self) ~= _mt_Map then
				self, val = val, self;
				rev = true;
			end;
			self["queue"]:insert {self[meth], val, rev};
			return self;
		end;
	end;

	-- make handler for unary operator
	local function _handler_unary(meth)
		return function(self)
			self["queue"]:insert {self[meth], _unary};
			return self;
		end;
	end;

	-- add functions to queue, when statement is preparing
	_mt_Map["__add"] = _handler "add";
	_mt_Map["__sub"] = _handler "sub";
	_mt_Map["__mul"] = _handler "mul";
	_mt_Map["__div"] = _handler "div";
	_mt_Map["__mod"] = _handler "mod";
	_mt_Map["__pow"] = _handler "pow";
	_mt_Map["__unm"] = _handler_unary "unm";
	_mt_Map["__concat"] = _handler "concat";
--[[
	these methods cannot be wrapped, for they always return true/false
	_mt_Map["__eq"] = _handler "eq";
	_mt_Map["__lt"] = _handler "lt";
	_mt_Map["__le"] = _handler "le";
--]]

	-- make stacked evaluations
	local function _call(self, initval, val, cx)
		local o = self["queue"][cx];
		if not o then return val end;
		local b = o[2];
		if _getmetatable(b) == _mt_Map then
			if _rawequal(b, self) then
				-- do not call `self` to avoid inf loop;
				-- place initial value instead
				b = initval;
			else
				-- call wrapped function(s)
				b = b(initval);
			end;
		end;
		if o[3] then val, b = b, val end;
		if _rawequal(b, _unary) then
			val = o[1](val);
		else
			val = o[1](val, b);
		end;
		return _call(self, initval, val, cx + 1);
	end;

	-- mapper
	function _mt_Map:__call(val) return _call(self, val, val, 1) end;

	-- operators cannot be referred to and placed unto the stack,
	-- wrap them with functions in order to do the trick
	function Map.add(a, b)		return a + b end;
	function Map.concat(a, b)	return a .. b end;
	function Map.div(a, b)		return a / b end;
	function Map.eq(a, b)		print "here" return a == b end;
	function Map.ge(a, b)		return a >= b end;
	function Map.gt(a, b)		return a > b end;
	function Map.le(a, b)		return a <= b end;
	function Map.lt(a, b)		return a < b end;
	function Map.mod(a, b)		return a % b end;
	function Map.mul(a, b)		return a * b end;
	function Map.n(a)		return not a end;
	function Map.pow(a, b)		return a ^ b end;
	function Map.sub(a, b)		return a - b end;
	function Map.unm(a)		return -a end;

	-- constructor
	do
		-- fill stack `tbl` with given functions
		local function _fill(tbl, func, ...)
			if func == nil then return tbl end;
			tbl:insert {func, _unary};
			return _fill(tbl, ...);
		end;

		function Map:new(...)
			local q = _fill(_new_table(), ...);
			return _setmetatable({["queue"] = q}, _mt_Map);
		end;
	end;

end;
-- }}} Map

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
local function wrap(...) return Map:new(...) end;

return {
	["Map"]		= Map,
	["map"]		= map,
	["mapa"]	= mapa,
	["wrap"]	= wrap,
};

