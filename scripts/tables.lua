
-- determines the correct shape and rotation for a table node based on its' surroundings, then swaps it
local function update_table_raw (pos, prefix, xpos, xneg, zpos, zneg)
	local neighbors = xpos + xneg + zpos + zneg
	if neighbors > 2 then -- 3 or 4 neighbors -> no legs
		minetest.swap_node(pos, {name = prefix .. '3'})
		return
	elseif neighbors == 2 then -- two neighbors
		if xpos + xneg == 2 then -- opposite on the X axis -> no legs
			minetest.swap_node(pos, {name = prefix .. '3'})
			return
		elseif zpos + zneg == 2 then -- opposite on the Z axis -> no legs
			minetest.swap_node(pos, {name = prefix .. '3'})
			return
		end
		if xpos + zpos == 2 then -- +XZ, one leg in the -XZ corner
			minetest.swap_node(pos, {name = prefix .. '2', param2 = 2})
			return
		elseif xneg + zneg == 2 then -- -XZ, one leg in the +XZ corner
			minetest.swap_node(pos, {name = prefix .. '2', param2 = 0})
			return
		end
		if xpos + zneg == 2 then -- +X -Z, one leg in the -X +Z corner
			minetest.swap_node(pos, {name = prefix .. '2', param2 = 3})
			return
		end
		 -- -X +Z, one leg in the +X -Z corner
		minetest.swap_node(pos, {name = prefix .. '2', param2 = 1})
		return
	elseif neighbors == 0 then -- no neighbors, all legs
		minetest.swap_node(pos, {name = prefix .. '0'})
		return
	else -- only one neighbor, turn to face it and switch to two legs
		if xpos == 1 then
			minetest.swap_node(pos, {name = prefix .. '1', param2 = 2})
			return
		end
		if xneg == 1 then
			minetest.swap_node(pos, {name = prefix .. '1', param2 = 0})
			return
		end
		if zpos == 1 then
			minetest.swap_node(pos, {name = prefix .. '1', param2 = 1})
			return
		end
		minetest.swap_node(pos, {name = prefix .. '1', param2 = 3})
	end
end

-- checks if a nodename is part of a table group
local function in_group (prefix, name)
	local name = name: gsub('^.+:', '')
	if #name < #prefix then
		return 0
	else
		if name: sub(1, #prefix) == prefix then
			return 1
		end
	end
	return 0
end

-- tests if the adjacent nodes are in a table group
local function get_adjacents_in_group (pos, prefix)
	return in_group(prefix, minetest.get_node(pos + vector.new(1, 0, 0)).name),
				 in_group(prefix, minetest.get_node(pos + vector.new(-1, 0, 0)).name),
				 in_group(prefix, minetest.get_node(pos + vector.new(0, 0, 1)).name),
				 in_group(prefix, minetest.get_node(pos + vector.new(0, 0, -1)).name)
end

-- optionally updates itself, then updates the 4 horizontally adjacent tables (if present)
local function update_table_shapes (name, self)
	return function (pos)
		local prefix = 'table_' .. name .. '_'
		local xpos, xneg, zpos, zneg = get_adjacents_in_group(pos, prefix)
		
		local place_prefix = 'chunkydeco:table_'..name..'_'
		if self then
			update_table_raw(pos, place_prefix, xpos, xneg, zpos, zneg)
		end
		
		if xpos == 1 then
			local adjpos = pos + vector.new(1, 0, 0)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, prefix)
			if not self then xneg = 0 end
			update_table_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg)
		end
		if xneg == 1 then
			local adjpos = pos + vector.new(-1, 0, 0)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, prefix)
			if not self then xpos = 0 end
			update_table_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg)
		end
		if zpos == 1 then
			local adjpos = pos + vector.new(0, 0, 1)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, prefix)
			if not self then zneg = 0 end
			update_table_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg)
		end
		if zneg == 1 then
			local adjpos = pos + vector.new(0, 0, -1)
			local xpos, xneg, zpos, zneg = get_adjacents_in_group(adjpos, prefix)
			if not self then zpos = 0 end
			update_table_raw(adjpos, place_prefix, xpos, xneg, zpos, zneg)
		end
	end
end

local function register_table_node (name, id, description, nodebox, texname_override, specialgroup, sounds)
	chunkydeco.register_node('table_'..name..'_'..id, {
		displayname = description,
		tiles = {
			{name = 'chunkydeco_table_'..(texname_override or name)..'_top.png', align_style = 'world'},
			{name = 'chunkydeco_table_'..(texname_override or name)..'_bottom.png', align_style = 'world'},
			{name = 'chunkydeco_table_'..name..'_side.png', align_style = 'world'}
		},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = '4dir',
		drawtype = 'nodebox',
		node_box = nodebox,
		groups = {choppy = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = id, [specialgroup or 'table'] = 1},
		sounds = sounds or default.node_sound_wood_defaults(),
		drop = 'chunkydeco:table_'..name..'_0',
		on_construct = update_table_shapes(name, true),
		on_destruct = update_table_shapes(name, false)
	})
end

-- top_box is the tabletop and anything that should always be present
-- leg_box is used for each single leg, strut_box is present when two legs on a side are present (optional)
-- leg boxes will be rotated so the +x +z corner faces outward on each corner of the table
-- strut boxes will be rotated so the +x side faces outward for each side of the table with two legs
local function make_connected_table (name, description, top_box, leg_box, strut_box, texname_override, special_group, sounds)
	local box_0 = {}
	chunkydeco.unpack_and_inject(box_0, top_box)
	chunkydeco.unpack_and_inject(box_0, leg_box)
	chunkydeco.unpack_and_inject(box_0, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(box_0, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(box_0, etc.rotate_nodeboxes(leg_box, 'y', 3))
	chunkydeco.unpack_and_inject(box_0, strut_box)
	chunkydeco.unpack_and_inject(box_0, strut_box and etc.rotate_nodeboxes(strut_box, 'y', 1))
	chunkydeco.unpack_and_inject(box_0, strut_box and etc.rotate_nodeboxes(strut_box, 'y', 2))
	chunkydeco.unpack_and_inject(box_0, strut_box and etc.rotate_nodeboxes(strut_box, 'y', 3))
	
	
	register_table_node(name, 0, description, {type = 'fixed', fixed = box_0}, texname_override, special_group, sounds)
	
	local box_1 = {}
	chunkydeco.unpack_and_inject(box_1, top_box)
	chunkydeco.unpack_and_inject(box_1, leg_box)
	chunkydeco.unpack_and_inject(box_1, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(box_1, strut_box)
	
	
	register_table_node(name, 1, description, {type = 'fixed', fixed = box_1}, texname_override, special_group, sounds)
	
	local box_2 = {}
	chunkydeco.unpack_and_inject(box_2, top_box)
	chunkydeco.unpack_and_inject(box_2, leg_box)
	
	
	register_table_node(name, 2, description, {type = 'fixed', fixed = box_2}, texname_override, special_group, sounds)
	
	local box_3 = {}
	chunkydeco.unpack_and_inject(box_3, top_box)

	register_table_node(name, 3, description, {type = 'fixed', fixed = box_3}, texname_override, special_group, sounds)
end

local function make_dining_table (id, woodid, displayname)
	make_connected_table(id..'_dining', displayname..' Dining Table',
	{0.5, 0.5, 0.5, -0.5, 5/16, -0.5}, {
		{6/16, 0, 6/16, 4/16, -7/16, 4/16},
		{7/16, -6/16, 7/16, 5/16, -0.5, 5/16},
		{7/16, 5/16, 7/16, 5/16, 0, 5/16}
	})

	minetest.register_craft {
		output = 'chunkydeco:table_'..id..'_dining_0 2',
		recipe = {
			{woodid, woodid, woodid},
			{'default:stick', 'default:stick', 'default:stick'},
			{'default:stick', 'etc:ct_saw', 'default:stick'}
		}
	}
end

make_dining_table('apple', 'default:wood', 'Applewood')
make_dining_table('acacia', 'default:acacia_wood', 'Acacia')
make_dining_table('aspen', 'default:aspen_wood', 'Aspen')
make_dining_table('jungle', 'default:junglewood', 'Junglewood')
make_dining_table('pine', 'default:pine_wood', 'Pine')

local function make_end_table (id, woodid, displayname)
	make_connected_table(id..'_end', displayname..' End Table',
	{0.5, 6/16, 0.5, -0.5, 4/16, -0.5}, {
		{6/16, 4/16, 6/16, 4/16, -7/16, 4/16},
		{7/16, -6/16, 7/16, 5/16, -0.5, 5/16}
	}, {
		{5/16, -1/16, 5/16, 4/16, -3/16, 1/16},
		{5/16, -1/16, -1/16, 4/16, -3/16, -5/16},
		{5/16, 0, 2/16, 4/16, -2/16, -2/16}
	}, id..'_dining')

	minetest.register_craft {
		output = 'chunkydeco:table_'..id..'_end_0 2',
		recipe = {
			{woodid, woodid, woodid},
			{'default:stick', woodid, 'default:stick'},
			{'default:stick', 'etc:ct_saw', 'default:stick'}
		}
	}
end

make_end_table('apple', 'default:wood', 'Applewood')
make_end_table('acacia', 'default:acacia_wood', 'Acacia')
make_end_table('aspen', 'default:aspen_wood', 'Aspen')
make_end_table('jungle', 'default:junglewood', 'Junglewood')
make_end_table('pine', 'default:pine_wood', 'Pine')

local function make_workbench (id, woodid, displayname)
	make_connected_table(id..'_workbench', displayname..' Workbench',
	{
		{0.5, 0.5, 0.5, -0.5, 5/16, -0.5},
		{0.5, -2/16, 0.5, -0.5, -3/16, -0.5}
	}, {
		{7/16, 5/16, 7/16, 4/16, -0.5, 4/16},
	}, {
		{5/16, 4/16, 6/16, 4/16, -3/16, -6/16},
	}, nil, 'workbench')

	minetest.register_craft {
		output = 'chunkydeco:table_'..id..'_workbench_0 2',
		recipe = {
			{woodid, woodid, woodid},
			{woodid, 'etc:ct_saw', woodid},
			{'default:stick', '', 'default:stick'}
		}
	}
end

make_workbench('apple', 'default:wood', 'Applewood')
make_workbench('acacia', 'default:acacia_wood', 'Acacia')
make_workbench('aspen', 'default:aspen_wood', 'Aspen')
make_workbench('jungle', 'default:junglewood', 'Junglewood')
make_workbench('pine', 'default:pine_wood', 'Pine')

make_connected_table('wrought_iron', 'Wrought Iron Table',
{
	{-0.3125, 0.375, -0.3125, -0.25, 0.4375, 0.3125},
	{0.25, 0.375, -0.3125, 0.3125, 0.4375, 0.3125},
	{-0.3125, 0.375, 0.25, 0.3125, 0.4375, 0.3125},
	{-0.3125, 0.375, -0.3125, 0.3125, 0.4375, -0.25},
	{-0.1875, 0.4375, -0.4375, 0.1875, 0.5, -0.375},
	{-0.1875, 0.4375, 0.375, 0.1875, 0.5, 0.4375},
	{0.375, 0.4375, -0.1875, 0.4375, 0.5, 0.1875},
	{-0.4375, 0.4375, -0.1875, -0.375, 0.5, 0.1875},
	{-0.375, 0.4375, 0.1875, -0.3125, 0.5, 0.3125},
	{-0.375, 0.4375, -0.3125, -0.3125, 0.5, -0.1875},
	{0.3125, 0.4375, -0.3125, 0.375, 0.5, -0.1875},
	{0.3125, 0.4375, 0.1875, 0.375, 0.5, 0.3125},
	{-0.3125, 0.4375, 0.3125, -0.1875, 0.5, 0.375},
	{0.1875, 0.4375, 0.3125, 0.3125, 0.5, 0.375},
	{-0.3125, 0.4375, -0.375, -0.1875, 0.5, -0.3125},
	{0.1875, 0.4375, -0.375, 0.3125, 0.5, -0.3125},
	{0.4375, 0.4375, -0.5, 0.5, 0.5, 0.4375},
	{-0.5, 0.4375, -0.4375, -0.4375, 0.5, 0.5},
	{-0.5, 0.4375, -0.5, 0.4375, 0.5, -0.4375},
	{-0.4375, 0.4375, 0.4375, 0.5, 0.5, 0.5},
	{-0.125, 0.4375, -0.0625, -0.0625, 0.5, 0.0625},
	{0.0625, 0.4375, -0.0625, 0.125, 0.5, 0.0625},
	{-0.0625, 0.4375, 0.0625, 0.0625, 0.5, 0.125},
	{-0.0625, 0.4375, -0.125, 0.0625, 0.5, -0.0625},
	{0.0625, 0.4375, -0.375, 0.125, 0.5, -0.125},
	{-0.125, 0.4375, 0.125, -0.0625, 0.5, 0.375},
	{0.125, 0.4375, 0.0625, 0.375, 0.5, 0.125},
	{-0.375, 0.4375, -0.125, -0.125, 0.5, -0.0625},
	{-0.25, 0.4375, -0.0625, -0.1875, 0.5, 0.0625},
	{0.1875, 0.4375, -0.0625, 0.25, 0.5, 0.0625},
	{-0.0625, 0.4375, 0.1875, 0.0625, 0.5, 0.25},
	{-0.0625, 0.4375, -0.25, 0.0625, 0.5, -0.1875},
	{0.125, 0.4375, -0.1875, 0.25, 0.5, -0.125},
	{-0.25, 0.4375, 0.125, -0.125, 0.5, 0.1875},
	{0.125, 0.4375, 0.125, 0.1875, 0.5, 0.25},
	{-0.1875, 0.4375, -0.25, -0.125, 0.5, -0.125},
	{-0.4375, 0.4375, 0.375, -0.375, 0.5, 0.4375},
	{0.375, 0.4375, 0.375, 0.4375, 0.5, 0.4375},
	{0.375, 0.4375, -0.4375, 0.4375, 0.5, -0.375},
	{-0.4375, 0.4375, -0.4375, -0.375, 0.5, -0.375}
}, {
	{0.3125, -0.5, 0.3125, 0.375, -0.375, 0.375},
	{0.25, -0.375, 0.25, 0.3125, -0.1875, 0.3125},
	{0.1875, -0.1875, 0.1875, 0.25, 0.1875, 0.25},
	{0.25, 0.1875, 0.25, 0.3125, 0.375, 0.3125},
	{0.375, -0.5, 0.375, 0.4375, -0.4375, 0.4375}
}, {
	{0.25, 0, -0.25, 0.3125, 0.0625, -0.125},
	{0.25, 0, 0.125, 0.3125, 0.0625, 0.25},
	{0.3125, 0, -0.125, 0.375, 0.0625, 0.125}
}, 'wrought_iron', nil, default.node_sound_metal_defaults())

minetest.register_craft {
	output = 'chunkydeco:table_wrought_iron_0 4',
	recipe = {
		{'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot'},
		{'', 'chunkydeco:metal_rod_wrought_iron', ''},
		{'etcetera:wrought_iron_ingot', 'etc:ct_hammer', 'etcetera:wrought_iron_ingot'}
	}
}
