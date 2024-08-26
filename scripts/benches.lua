
local function update_bench_raw (pos, prefix, xpos, xneg, zpos, zneg, param2)
	local color = math.floor(param2 / 4) * 4
	if param2 %2 == 0 then -- aligned to the z axis
		local neighbours = xpos + xneg
		
		if neighbours == 2 then -- both neighbours, mid section form
			minetest.swap_node(pos, {name = prefix .. '1', param2 = param2})
		elseif neighbours == 1 then
			if xpos == 1 then -- neighbour to the +x, so put the arm on the -x side
				minetest.swap_node(pos, {name = prefix .. (param2 - color == 2 and '2' or '3'), param2 = param2})
			else -- neighbour to the -x, so put the arm on the +x side
				minetest.swap_node(pos, {name = prefix .. (param2 - color == 2 and '3' or '2'), param2 = param2})
			end
		else -- no neighbours, single chair form
			minetest.swap_node(pos, {name = prefix .. '0', param2 = param2})
		end
	else
		local neighbours = zpos + zneg
		
		if neighbours == 2 then -- both neighbours, mid section form
			minetest.swap_node(pos, {name = prefix .. '1', param2 = param2})
		elseif neighbours == 1 then
			if zpos == 1 then -- neighbour to the +z, so put the arm on the -z side
				minetest.swap_node(pos, {name = prefix .. (param2 - color == 1 and '2' or '3'), param2 = param2})
			else -- neighbour to the -z, so put the arm on the +z side
				minetest.swap_node(pos, {name = prefix .. (param2 - color == 1 and '3' or '2'), param2 = param2})
			end
		else -- no neighbours, single chair form
			minetest.swap_node(pos, {name = prefix .. '0', param2 = param2})
		end
	end
end

local function in_group (prefix, param2, pos)
	local node = minetest.get_node(pos)
	
	local color = math.floor(param2 / 4) * 4
	local color2 = math.floor(node.param2 / 4) * 4
	if node.param2 - color2 ~= param2 - color then return 0 end
	
	local name = node.name: gsub('^.+:', '')
	if #name < #prefix then
		return 0
	else
		if name: sub(1, #prefix) == prefix then
			return 1
		end
	end
	return 0
end

local function get_adjacents_in_group (pos, param2, prefix)
	return in_group(prefix, param2, pos + vector.new(1, 0, 0)),
				 in_group(prefix, param2, pos + vector.new(-1, 0, 0)),
				 in_group(prefix, param2, pos + vector.new(0, 0, 1)),
				 in_group(prefix, param2, pos + vector.new(0, 0, -1))
end

local function update_bench_shapes (name, self)
	return function (pos)
		local prefix = 'bench_' .. name .. '_'
		local node = minetest.get_node(pos)
		local xpos, xneg, zpos, zneg = get_adjacents_in_group(pos, node.param2, prefix)
		
		local place_prefix = 'chunkydeco:bench_'..name..'_'
		if self then
			local node = minetest.get_node(pos)
			update_bench_raw(pos, place_prefix, xpos, xneg, zpos, zneg, node.param2)
		end
		
		if xpos == 1 then
			local adjpos = pos + vector.new(1, 0, 0)
			local node = minetest.get_node(adjpos)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, node.param2, prefix)
			if not self then xneg = 0 end
			update_bench_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg, node.param2)
		end
		if xneg == 1 then
			local adjpos = pos + vector.new(-1, 0, 0)
			local node = minetest.get_node(adjpos)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, node.param2, prefix)
			if not self then xpos = 0 end
			update_bench_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg, node.param2)
		end
		if zpos == 1 then
			local adjpos = pos + vector.new(0, 0, 1)
			local node = minetest.get_node(adjpos)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, node.param2, prefix)
			if not self then zneg = 0 end
			update_bench_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg, node.param2)
		end
		if zneg == 1 then
			local adjpos = pos + vector.new(0, 0, -1)
			local node = minetest.get_node(adjpos)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, node.param2, prefix)
			if not self then zpos = 0 end
			update_bench_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg, node.param2)
		end
	end
end

local function register_bench_node (name, id, description, nodebox, offset, sounds, color)
	chunkydeco: register_node('bench_'..name..'_'..id, {
		displayname = description,
		description = color and 'Craft with dye to change cushion color.',
		tiles = color and {
			{name = 'chunkydeco_bench_'..name..'_top.png'},
			{name = 'chunkydeco_bench_'..name..'_bottom.png', color = 'white'},
			{name = 'chunkydeco_bench_'..name..'_cushion_side.png'}
		} or {
			{name = 'chunkydeco_bench_'..name..'.png'}
		},
		overlay_tiles = color and {
			'', '',
			{name = 'chunkydeco_bench_'..name..'_side.png', color = 'white'}
		},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = 'color4dir',
		palette = 'chunkydeco_4dir_nodes_palette.png',
		color = 'white',
		drawtype = 'nodebox',
		node_box = nodebox,
		groups = {choppy = 3, cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = id, bouncy = color and 25 or 0},
		sounds = sounds or default.node_sound_wood_defaults(),
		drop = color and {
			items = {
				{items = {'chunkydeco:bench_'..name..'_0'}, inherit_color = true },
			}
		} or 'chunkydeco:bench_'..name..'_0',
		on_construct = update_bench_shapes(name, true),
		on_destruct = update_bench_shapes(name, false),
		on_rightclick = chunkydeco.chair_on_rightclick(offset or vector.new(), false),
		on_dig = chunkydeco.chair_on_dig
	})
end

local function make_connected_bench (name, description, seat_box, leg_box, arm_box, sit_height, sounds, has_color)
	local box_0 = {}
	chunkydeco.unpack_and_inject(box_0, seat_box)
	chunkydeco.unpack_and_inject(box_0, leg_box)
	chunkydeco.unpack_and_inject(box_0, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(box_0, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(box_0, etc.rotate_nodeboxes(leg_box, 'y', 3))
	chunkydeco.unpack_and_inject(box_0, arm_box)
	chunkydeco.unpack_and_inject(box_0, etc.flip_nodeboxes(arm_box, 'x', 1))
	
	register_bench_node(name, 0, description, {type = 'fixed', fixed = box_0}, vector.new(0, sit_height, 0), sounds, has_color)
	
	local box_1 = {}
	chunkydeco.unpack_and_inject(box_1, seat_box)
	
	register_bench_node(name, 1, description, {type = 'fixed', fixed = box_1}, vector.new(0, sit_height, 0), sounds, has_color)
	
	local box_2 = {}
	chunkydeco.unpack_and_inject(box_2, seat_box)
	chunkydeco.unpack_and_inject(box_2, leg_box)
	chunkydeco.unpack_and_inject(box_2, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(box_2, arm_box)
	
	register_bench_node(name, 2, description, {type = 'fixed', fixed = box_2}, vector.new(0, sit_height, 0), sounds, has_color)
	
	local box_3 = {}
	chunkydeco.unpack_and_inject(box_3, seat_box)
	chunkydeco.unpack_and_inject(box_3, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(box_3, etc.rotate_nodeboxes(leg_box, 'y', 3))
	chunkydeco.unpack_and_inject(box_3, etc.flip_nodeboxes(arm_box, 'x', 1))
	
	register_bench_node(name, 3, description, {type = 'fixed', fixed = box_3}, vector.new(0, sit_height, 0), sounds, has_color)
end

make_connected_bench('sofa', 'Upholstered Sofa', {
	{0.5, 0, 0.5, -0.5, -6/16, -6/16},
	{0.5, 0.5, 0.5, -0.5, -6/16, 4/16}
}, {
	6/16, -6/16, 6/16, 2/16, -0.5, 2/16
}, {
	{9/16, 6/16, 0.5, 5/16, -5/16, -6/16}
}, 0.0, nil, true)

for index, dye in pairs(chunkydeco.colors) do
	minetest.register_craft {
		type = 'shapeless',
		output = minetest.itemstring_with_palette('chunkydeco:bench_sofa_0', (index)*4),
		recipe = {'chunkydeco:bench_sofa_0', dye}
	}
	
	minetest.register_craft {
		type = 'shapeless',
		output = minetest.itemstring_with_palette('chunkydeco:bench_sofa_0', (index+16)*4),
		recipe = {'chunkydeco:bench_sofa_0', dye, 'chunkydeco:dye_booster'}
	}
end

minetest.register_craft {
	output = minetest.itemstring_with_palette('chunkydeco:bench_sofa_0 4', 0),
	recipe = {
		{'wool:white', '', 'wool:white'},
		{'wool:white', 'wool:white', 'wool:white'},
		{'group:wood', '', 'group:wood'}
	}
}

local function make_park_bench (id, woodid, displayname)
	make_connected_bench(id..'_park', displayname..' Park Bench',
	{
		{-0.5, -0.125, -0.5, 0.5, -0.0625, -0.375},
		{-0.5, -0.0625, -0.3125, 0.5, -5.02914e-08, -0.1875},
		{-0.5, -0.0625, -0.125, 0.5, -3.53903e-08, -0},
		{-0.5, -0.0625, 0.0625, 0.5, -2.23517e-08, 0.1875},
		{-0.5, 0, 0.25, 0.5, 0.0625, 0.375},
		{-0.5, 0.125, 0.3125, 0.5, 0.25, 0.375},
		{-0.5, 0.3125, 0.3125, 0.5, 0.4375, 0.375},
		{-0.5, 0.5, 0.375, 0.5, 0.625, 0.4375},
		{-0.5, 0.625, 0.4375, 0.5, 0.75, 0.5},
		{-0.0625, 0.5, 0.4375, 0.0625, 0.625, 0.5},
		{-0.0625, 0, 0.375, 0.0625, 0.5, 0.4375},
		{-0.0625, -0.0625, 0.1875, 0.0625, 0, 0.375},
		{-0.0625, -0.125, -0.375, 0.0625, -0.0625, 0.1875},
		{-0.5, -0.5, -0.25, 0.5, -0.375, -0.125},
		{-0.5, -0.5, 0.1875, 0.5, -0.375, 0.3125}
	}, {
		
	}, {
		{0.375, 0.1875, 0.125, 0.5, 0.3125, 0.4375},
		{0.375, -0.5, 0.3125, 0.5, 0.25, 0.4375},
		{0.375, -0.5, -0.3125, 0.5, -0.375, 0.3125},
		{0.375, 0.25, -0.25, 0.5, 0.375, 0.125},
		{0.375, 0.1875, -0.5, 0.5, 0.3125, -0.25}
	}, 0.0, nil, false)

	minetest.register_craft {
		output = 'chunkydeco:bench_'..id..'_park_0 4',
		recipe = {
			{'default:stick', 'default:stick', 'default:stick'},
			{woodid, woodid, woodid},
			{'default:stick', 'etc:ct_saw', 'default:stick'}
		}
	}
end

make_park_bench('apple', 'default:wood', 'Applewood')
make_park_bench('acacia', 'default:acacia_wood', 'Acacia')
make_park_bench('aspen', 'default:aspen_wood', 'Aspen')
make_park_bench('jungle', 'default:junglewood', 'Junglewood')
make_park_bench('pine', 'default:pine_wood', 'Pine')

make_connected_bench('wrought_iron_park', 'Wrought Iron Park Bench',
{
	{-0.5, -0.125, -0.5, 0.5, -0.0625, -0.375},
	{-0.5, -0.0625, -0.3125, 0.5, -5.02914e-08, -0.1875},
	{-0.5, -0.0625, -0.125, 0.5, -3.53903e-08, -0},
	{-0.5, -0.0625, 0.0625, 0.5, -2.23517e-08, 0.1875},
	{-0.5, 0, 0.25, 0.5, 0.0625, 0.375},
	{-0.5, 0.125, 0.3125, 0.5, 0.25, 0.375},
	{-0.5, 0.3125, 0.3125, 0.5, 0.4375, 0.375},
	{-0.5, 0.5, 0.375, 0.5, 0.625, 0.4375},
	{-0.5, 0.625, 0.4375, 0.5, 0.75, 0.5},
	{-0.0625, 0.5, 0.4375, 0.0625, 0.625, 0.5},
	{-0.0625, 0, 0.375, 0.0625, 0.5, 0.4375},
	{-0.0625, -0.0625, 0.1875, 0.0625, 0, 0.375},
	{-0.0625, -0.125, -0.375, 0.0625, -0.0625, 0.1875},
	{-0.5, -0.5, -0.25, 0.5, -0.375, -0.125},
	{-0.5, -0.5, 0.1875, 0.5, -0.375, 0.3125}
}, {
	
}, {
	{0.375, 0.1875, 0.125, 0.5, 0.3125, 0.4375},
	{0.375, -0.5, 0.3125, 0.5, 0.25, 0.4375},
	{0.375, -0.5, -0.3125, 0.5, -0.375, 0.3125},
	{0.375, 0.25, -0.25, 0.5, 0.375, 0.125},
	{0.375, 0.1875, -0.5, 0.5, 0.3125, -0.25}
}, 0.0, default.node_sound_metal_defaults(), false)

minetest.register_craft {
	output = 'chunkydeco:bench_wrought_iron_park_0 6',
	recipe = {
		{'chunkydeco:metal_rod_wrought_iron', 'chunkydeco:metal_rod_wrought_iron', 'chunkydeco:metal_rod_wrought_iron'},
		{'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot', 'etc:wrought_iron_ingot'},
		{'chunkydeco:metal_rod_wrought_iron', 'etc:ct_hammer', 'chunkydeco:metal_rod_wrought_iron'}
	}
}
