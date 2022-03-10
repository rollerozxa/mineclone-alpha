local test_minetest_find_nodes_in_area_can_count = function(dtime)
	-- This function tests that minetest.find_nodes_in_area() can
	-- count nodes correctly. If it fails, the engine can not be
	-- trusted to actually count how many nodes of a given type
	-- are in a given volume. Yes, *it* is bad if that happens.
	--
	-- If you are looking at this function because it executes at
	-- startup and crashes the game, by far the most stupid thing
	-- you could do is disabling it. Only an absolute moron would
	-- disable tests that ensure basic functionality still works.
	--
	-- Experience has taught me that such warnings are mostly not
	-- taken seriously by both Minetest mod & core developers. As
	-- there are very few situations in which someone would read
	-- the code of the function without a crash, you are probably
	-- asking yourself how bad it can be. Surely you will want an
	-- example of what will break if this test breaks. The answer
	-- to this simple question is equally simple and consists of a
	-- heartfelt “What the fuck did you say, you stupid fuckwad?”.
	--
	-- Alrighty then, let's get it on …

	local pos = { x=30999, y=30999, z=30999 }
	-- You think there is nothing there? Well, here is the thing:
	-- With standard settings you can only see map until x=30927,
	-- although the renderer can actually render up to x=31007 if
	-- you configure it to. Any statements given by minetest core
	-- devs that contradict the above assertion are probably lies.
	--
	-- In any way, this area should be so far out that no one has
	-- built here … yet. Now that you know it is possible, I know
	-- you want to. How though? I suggest to figure the technique
	-- out yourself, then go on and build invisible lag machines.

	local radius = 3
	local minp = vector.subtract(pos, radius)
	local maxp = vector.add(pos, radius)
	local nodename = "air"
	local c_nodename = minetest.get_content_id(nodename)

	-- Why not use minetest.set_node() here? Well, some mods do
	-- trigger on every placement of a node in the entire map …
	-- and we do not want to crash those mods in this test case.
	-- (Voxelmanip does not trigger callbacks – so all is well.)
	--
	-- And now for a funny story: I initially copied the following
	-- code from the Minetest developer wiki. Can you spot a typo?
	-- <https://dev.minetest.net/index.php?title=minetest.get_content_id&action=edit>
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(
		minp,
		maxp
	)
	local area = VoxelArea:new({
		MinEdge=emin,
		MaxEdge=emax
	})
	local data = vm:get_data()
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			local vi = area:index(minp.x, y, z)
			for x = minp.x, maxp.y do
				data[vi] = c_nodename
				vi = vi + 1
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map()
	local npos, nnum = minetest.find_nodes_in_area(
		minp,
		maxp,
		{ nodename }
	)
	local nodes_expected = math.pow( 1 + (2 * radius), 3 )
	local nodes_counted = nnum[nodename]
	local nodes_difference = nodes_expected - nodes_counted
	-- Originally, there was an assertion here that made the game
	-- crash at startup if Minetest forgot how to count. This was
	-- originally intended to avoid buggy engine releases, but it
	-- mostly made people upset and hindered debugging. Also, the
	-- assertion contained no error message hinting at the reason
	-- for the crash, making it exceptionally user-unfriendly. It
	-- follows that a game or mod should only assert on behaviour
	-- of the Lua code, not the underlying implementation, unless
	-- engine bugs are bad enough to permanently corrupt a world.
	if ( 0 ~= nodes_difference ) then
		minetest.debug(
			"minetest.find_nodes_in_area() failed to find " ..
			nodes_difference .. " nodes that were placed. " ..
			"Downgrading to Minetest 5.4.1 might fix this."
		)
	end
end

minetest.after( 0, test_minetest_find_nodes_in_area_can_count )

local test_minetest_find_nodes_in_area_crash = function(dtime)
	-- And now for our feature presentation, where we call the
	-- function “minetest.find_nodes_in_area()” with a position
	-- out of bounds! Will it crash? Who knows‽ If it does, the
	-- workaround is not working though, so it should be patched.

	local pos = { x=32767, y=32767, z=32767 }
	-- Note that not all out of bounds values actually crash the
	-- function minetest.find_nodes_in_area()“. In fact, the vast
	-- majority of out of bounds values do not crash the function.

	local radius = 3
	local minp = vector.subtract(pos, radius)
	local maxp = vector.add(pos, radius)
	local nodename = "air"
	local npos, nnum = minetest.find_nodes_in_area(
		minp,
		maxp,
		{ nodename }
	)
	-- That's all, folks!
end

minetest.after( 0, test_minetest_find_nodes_in_area_crash )
