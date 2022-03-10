local clamp = function(value, min, max)
	assert( min < max )
	if value < min then
		return min
	end
	if value > max then
		return max
	end
	return value
end

assert( clamp(000, -100, 100) == 000 )
assert( clamp(999, -100, 100) == 100 )
assert( clamp(999, -999, 999) == 999 )
assert( clamp(998, 999, 1999) == 999 )
assert( clamp(999, 999, 1999) == 999 )

local clamp_s16 = function(value)
	-- seems minetest hangs on -32768 and 32767
	return clamp(value, -32767, 32766)
end

assert( clamp_s16(000000) == 000000 )
assert( clamp_s16(000001) == 000001 )
assert( clamp_s16(000010) == 000010 )
assert( clamp_s16(000100) == 000100 )
assert( clamp_s16(001000) == 001000 )
assert( clamp_s16(010000) == 010000 )
assert( clamp_s16(100000) == 032766 )

assert( clamp_s16(-00000) == -00000 )
assert( clamp_s16(-00009) == -00009 )
assert( clamp_s16(-00099) == -00099 )
assert( clamp_s16(-00999) == -00999 )
assert( clamp_s16(-09999) == -09999 )
assert( clamp_s16(-99999) == -32767 )

local minetest_find_nodes_in_area = minetest.find_nodes_in_area
minetest.find_nodes_in_area = function(minp, maxp, ...)
	if
		minp.x >= 32767 or minp.x <= -32768 or
		minp.y >= 32767 or minp.y <= -32768 or
		minp.z >= 32767 or minp.z <= -32768 or
		maxp.x >= 32767 or maxp.x <= -32768 or
		maxp.y >= 32767 or maxp.y <= -32768 or
		maxp.z >= 32767 or maxp.z <= -32768
	then
		minetest.log(
			"warning",
			"find_nodes_in_area() called with coords outside interval (-32768, 32767), clamping arguments: " ..
			"minp { x=" .. minp.x .. ", y=" .. minp.y .. " z=" .. minp.z .. " } " ..
			"maxp { x=" .. maxp.x .. ", y=" .. maxp.y .. " z=" .. maxp.z .. " } "
		)
		return minetest_find_nodes_in_area(
			{ x=clamp_s16(minp.x), y=clamp_s16(minp.y), z=clamp_s16(minp.z) },
			{ x=clamp_s16(maxp.x), y=clamp_s16(maxp.y), z=clamp_s16(maxp.z) },
			...
		)
	else
		return minetest_find_nodes_in_area(
			minp,
			maxp,
			...
		)
	end
end

deep_compare = function(a, b)
	local type_a = type(a)
	local type_b = type(b)
	if type_a ~= type_b then
		return false
	end
	if type_a ~= "table" and type_b ~= "table" then
		return a == b
	end
	for key_a, value_a in pairs(a) do
		local value_b = b[key_a]
		if not deep_compare(value_a, value_b) then
			return false
		end
	end
	for key_b, value_b in pairs(b) do
		local value_a = a[key_b]
		if not deep_compare(value_b, value_a) then
			return false
		end
	end
	return true
end

assert(
	deep_compare(
		1,
		1.0
	) == true
)

assert(
	deep_compare(
		true,
		"true"
	) == false
)

assert(
	deep_compare(
		{ a=1, b=-2, c=3.4 },
		{ a=1, b=-2, c=3.4 }
	) == true
)

assert(
	deep_compare(
		{ a={ 1, 2, 3 }, b="foo", c=false },
		{ a={ 1, 2, 3 }, b="foo", c=false }
	) == true
)

assert(
	deep_compare(
		{ a={ 1, 2, 3 }, b="foo", c=false },
		{ a={ 4, 5, 6 }, b="foo", c=false }
	) == false
)

assert(
	deep_compare(
		{ a={ 1, 2, 3 }, b={ c=false } },
		{ a={ 1, 2, 3 }, b={ c=false } }
	) == true
)

assert(
	deep_compare(
		{ a={ 1, 2, 3 }, b={ } },
		{ a={ 1, 2, 3 }, b={ c=false } }
	) == false
)

local test_minetest_find_nodes_in_area_implementation_equivalence = function()
	-- If any assertion in this test function fails, the wrapper
	-- for minetest.find_nodes_in_area() does not behave like the
	-- original function. If you are reading the code because your
	-- server crashed, please inform the Mineclonia developers.
	local fun_1 = minetest_find_nodes_in_area
	local fun_2 = minetest.find_nodes_in_area
	for x = -31000, 31000, 15500 do
		for y = -31000, 31000, 15500 do
			for z = -31000, 31000, 15500 do
				for d = 1, 9, 3 do
					local minp = { x=x, y=y, z=z }
					local maxp = { x=x+d, y=y+d, z=z+d }
					minetest.emerge_area(
						minp,
						maxp,
						function(blockpos, action, calls_remaining)
							local npos_1, nnum_1 = fun_1(
								minp,
								maxp,
								{ "air", "ignore" }
							)
							local npos_2, nnum_2 = fun_2(
								minp,
								maxp,
								{ "air", "ignore" }
							)
							assert(
								deep_compare(
									npos_1,
									npos_2
								) == true
							)
							assert(
								deep_compare(
									nnum_1,
									nnum_2
								) == true
							)
							local ntab_1 = fun_1(
								minp,
								maxp,
								{ "air", "ignore" },
								true
							)
							local ntab_2 = fun_2(
								minp,
								maxp,
								{ "air", "ignore" },
								true
							)
							assert(
								deep_compare(
									ntab_1,
									ntab_2
								) == true
							)
						end
					)
				end
			end
		end
	end
end

minetest.after( 0, test_minetest_find_nodes_in_area_implementation_equivalence )
