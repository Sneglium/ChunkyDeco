
local function chair_on_place (itemstack, placer, pointed_thing)
	local control = placer: get_player_control()
	
	if control.sneak then
		local itemstack2 = ItemStack(itemstack)
		itemstack2: set_name(itemstack: get_name(): gsub('0', '1'))
		minetest.item_place_node(itemstack2, placer, pointed_thing)
		itemstack: set_count(itemstack2: get_count())
		return itemstack
	else
		return minetest.rotate_node(itemstack, placer, pointed_thing)
	end
end

local function register_chair_node (name, id, description, nodebox, texname_override, specialgroup, offset, invert, sounds)
	chunkydeco: register_node('chair_'..name..'_'..id, {
		displayname = description,
		description = 'Sneak while placing to put under tables.',
		tiles = {
			{name = 'chunkydeco_chair_'..(texname_override or name)..'_top.png', align_style = 'world'},
			{name = 'chunkydeco_chair_'..(texname_override or name)..'_bottom.png', align_style = 'world'},
			{name = 'chunkydeco_chair_'..(texname_override or name)..'_side.png', align_style = 'world'}
		},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = '4dir',
		drawtype = 'nodebox',
		node_box = nodebox,
		groups = {choppy = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = id, [specialgroup or 'chair'] = 1},
		sounds = sounds or default.node_sound_wood_defaults(),
		drop = 'chunkydeco:chair_'..name..'_0',
		on_place = id == 0 and chair_on_place or nil,
		on_rightclick = chunkydeco.chair_on_rightclick(offset or vector.new(), invert),
		on_dig = chunkydeco.chair_on_dig
	})
end

-- top_box is the seat, leg_box is the +XZ leg, back_box is the chair back which should be oriented to the -Z face
local function make_chair (name, description, top_box, leg_box, back_box, texname_override, special_group, sit_height, sounds)
	local nodebox = {}
	chunkydeco.unpack_and_inject(nodebox, top_box)
	chunkydeco.unpack_and_inject(nodebox, back_box)
	chunkydeco.unpack_and_inject(nodebox, leg_box)
	chunkydeco.unpack_and_inject(nodebox, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(nodebox, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(nodebox, etc.rotate_nodeboxes(leg_box, 'y', 3))
	
	register_chair_node(name, 0, description, {type = 'fixed', fixed = nodebox}, texname_override, special_group, vector.new(0, sit_height or 2/16, 0), false, sounds)
	
	local nodebox_2 = {}
	
	for _, v in ipairs(nodebox) do
		local new_box = table.copy(v)
		new_box[3] = new_box[3] - 0.5
		new_box[6] = new_box[6] - 0.5
		
		table.insert(nodebox_2, etc.rotate_nodebox(new_box, 'y', 2))
	end
	
	register_chair_node(name, 1, description, {type = 'fixed', fixed = nodebox_2}, texname_override, special_group, vector.new(0, sit_height or 2/16, 0.5), true, sounds)
end

local function make_kitchen_chair (id, woodid, displayname)
	make_chair(id..'_kitchen', displayname..' Kitchen Chair',
	{5/16, 2/16, 6/16, -5/16, 0, -6/16},
	{5/16, 0, 5/16, 3/16, -0.5, 3/16},
	{
		{5/16, 12/16, 6/16, 3/16, 2/16, 4/16},
		{1/16, 12/16, 6/16, -1/16, 2/16, 4/16},
		{-3/16, 12/16, 6/16, -5/16, 2/16, 4/16},
		{4/16, 13/16, 6/16, -4/16, 11/16, 4/16}
	})

	minetest.register_craft {
		output = 'chunkydeco:chair_'..id..'_kitchen_0 4',
		recipe = {
			{'etc:ct_saw', '', 'default:stick'},
			{woodid, woodid, woodid},
			{'default:stick', '', 'default:stick'}
		}
	}
end

make_kitchen_chair('apple', 'default:wood', 'Applewood')
make_kitchen_chair('acacia', 'default:acacia_wood', 'Acacia')
make_kitchen_chair('aspen', 'default:aspen_wood', 'Aspen')
make_kitchen_chair('jungle', 'default:junglewood', 'Junglewood')
make_kitchen_chair('pine', 'default:pine_wood', 'Pine')

local function make_fancy_chair (id, woodid, displayname)
	make_chair(id..'_fancy', displayname..' Fancy Chair',
	{5/16, 2/16, 6/16, -5/16, 0, -6/16},
	{
		{5/16, 0, 5/16, 3/16, -0.5, 3/16},
		{4/16, -3/16, 4/16, 3/16, -4/16, -4/16}
	},
	{
		{5/16, 6/16, 6/16, 3/16, 2/16, 4/16},
		{-3/16, 6/16, 6/16, -5/16, 2/16, 4/16},
		{6/16, 13/16, 7/16, 4/16, 6/16, 5/16},
		{-4/16, 13/16, 7/16, -6/16, 6/16, 5/16},
		{4/16, 13/16, 7/16, -4/16, 11/16, 5/16},
		{0.5/16, 11/16, 6/16, -0.5/16, 2/16, 5/16},
		{2.5/16, 11/16, 6/16, 1.5/16, 2/16, 5/16},
		{-1.5/16, 11/16, 6/16, -2.5/16, 2/16, 5/16},
	}, id..'_kitchen')

	minetest.register_craft {
		output = 'chunkydeco:chair_'..id..'_fancy_0 4',
		recipe = {
			{'etc:ct_saw', '', 'default:stick'},
			{woodid, woodid, woodid},
			{'default:stick', 'default:stick', 'default:stick'}
		}
	}
end

make_fancy_chair('apple', 'default:wood', 'Applewood')
make_fancy_chair('acacia', 'default:acacia_wood', 'Acacia')
make_fancy_chair('aspen', 'default:aspen_wood', 'Aspen')
make_fancy_chair('jungle', 'default:junglewood', 'Junglewood')
make_fancy_chair('pine', 'default:pine_wood', 'Pine')

local function make_kitchen_chair_cushion (id, woodid, displayname)
	local collisionbox = {}
	chunkydeco.unpack_and_inject(collisionbox, {5/16, 2/16, 6/16, -5/16, 0, -6/16})
	chunkydeco.unpack_and_inject(collisionbox, {
		{5/16, 6/16, 6/16, -5/16, 2/16, 4/16},
		{6/16, 13/16, 7/16, -6/16, 6/16, 5/16},
	})
	
	local leg_box = {
		{5/16, 0, 5/16, 3/16, -0.5, 3/16}
	}
	
	chunkydeco.unpack_and_inject(collisionbox, leg_box)
	chunkydeco.unpack_and_inject(collisionbox, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(collisionbox, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(collisionbox, etc.rotate_nodeboxes(leg_box, 'y', 3))
	
	local collision_box = {type = 'fixed', fixed = collisionbox}
	
	local collisionbox2 = {}
	
	for _, v in ipairs(collisionbox) do
		local new_box = table.copy(v)
		new_box[3] = new_box[3] - 0.5
		new_box[6] = new_box[6] - 0.5
		
		table.insert(collisionbox2, etc.rotate_nodebox(new_box, 'y', 2))
	end
	
	local collision_box2 = {type = 'fixed', fixed = collisionbox2}
	
	chunkydeco: register_node('chair_kitchen_cushion_'..id..'_0', {
		displayname = displayname..' Upholstered Kitchen Chair',
		description = 'Sneak while placing to put under tables.\nCraft with dye to change cushion color.',
		tiles = {{name = 'chunkydeco_chair_kitchen_fancy_'..id..'.png', color = 'white'}},
		overlay_tiles = {'chunkydeco_chair_kitchen_fancy_cushion.png'},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = 'color4dir',
		palette = 'chunkydeco_4dir_nodes_palette.png',
		color = 'white',
		drawtype = 'mesh',
		mesh = 'chunkydeco_chair_kitchen.obj',
		selection_box = collision_box,
		collision_box = collision_box,
		groups = {choppy = 3, oddly_breakable_by_hand = 1},
		sounds = default.node_sound_wood_defaults(),
		on_place = chair_on_place,
		on_rightclick = chunkydeco.chair_on_rightclick(vector.new(0, 0.1, 0), false),
		on_dig = chunkydeco.chair_on_dig
	})
	
	chunkydeco: register_node('chair_kitchen_cushion_'..id..'_1', {
		tiles = {{name = 'chunkydeco_chair_kitchen_fancy_'..id..'.png', color = 'white'}},
		overlay_tiles = {'chunkydeco_chair_kitchen_fancy_cushion.png'},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = 'color4dir',
		palette = 'chunkydeco_4dir_nodes_palette.png',
		color = 'white',
		drawtype = 'mesh',
		mesh = 'chunkydeco_chair_kitchen_reverse.obj',
		selection_box = collision_box2,
		collision_box = collision_box2,
		groups = {choppy = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
		sounds = default.node_sound_wood_defaults(),
		on_place = chair_on_place,
		on_rightclick = chunkydeco.chair_on_rightclick(vector.new(0, 0.1, 0.5), true),
		on_dig = chunkydeco.chair_on_dig,
		drop = {
			items = {
				{items = {'chunkydeco:chair_kitchen_cushion_'..id..'_0'}, inherit_color = true },
			}
		},
	})
	
	for index, dye in pairs(chunkydeco.colors) do
		minetest.register_craft {
			type = 'shapeless',
			output = minetest.itemstring_with_palette('chunkydeco:chair_kitchen_cushion_'..id..'_0', (index)*4),
			recipe = {'chunkydeco:chair_kitchen_cushion_'..id..'_0', dye}
		}
		
		minetest.register_craft {
			type = 'shapeless',
			output = minetest.itemstring_with_palette('chunkydeco:chair_kitchen_cushion_'..id..'_0', (index+16)*4),
			recipe = {'chunkydeco:chair_kitchen_cushion_'..id..'_0', dye, 'chunkydeco:dye_booster'}
		}
	end
	
	minetest.register_craft {
		output = minetest.itemstring_with_palette('chunkydeco:chair_kitchen_cushion_'..id..'_0 4', 0),
		recipe = {
			{'etc:ct_saw', 'wool:white', 'default:stick'},
			{woodid, woodid, woodid},
			{'default:stick', '', 'default:stick'}
		}
	}
end

make_kitchen_chair_cushion('apple', 'default:wood', 'Applewood')
make_kitchen_chair_cushion('acacia', 'default:acacia_wood', 'Acacia')
make_kitchen_chair_cushion('aspen', 'default:aspen_wood', 'Aspen')
make_kitchen_chair_cushion('jungle', 'default:junglewood', 'Junglewood')
make_kitchen_chair_cushion('pine', 'default:pine_wood', 'Pine')

local function make_bar_stool (id, woodid, displayname)
	local collisionbox = {}
	chunkydeco.unpack_and_inject(collisionbox, {5/16, 0.5, 5/16, -5/16, 4/16, -5/16})
	
	local leg_box = {
		{5/16, 4/16, 5/16, 3/16, -0.5, 3/16},
		{4/16, -3/16, 4/16, 3/16, -4/16, -4/16}
	}
	
	chunkydeco.unpack_and_inject(collisionbox, leg_box)
	chunkydeco.unpack_and_inject(collisionbox, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(collisionbox, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(collisionbox, etc.rotate_nodeboxes(leg_box, 'y', 3))
	
	local collision_box = {type = 'fixed', fixed = collisionbox}
	
	chunkydeco: register_node('barstool_'..id, {
		displayname = displayname..' Bar Stool',
		description = 'Craft with dye to change cushion color.',
		tiles = {'chunkydeco_barstool_cushion.png'},
		overlay_tiles = {{name = 'chunkydeco_barstool_'..id..'.png', color = 'white'}},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = 'color4dir',
		palette = 'chunkydeco_4dir_nodes_palette.png',
		color = 'white',
		drawtype = 'mesh',
		mesh = 'chunkydeco_barstool.obj',
		selection_box = collision_box,
		collision_box = collision_box,
		groups = {choppy = 3, oddly_breakable_by_hand = 1},
		sounds = default.node_sound_wood_defaults(),
		on_rightclick = chunkydeco.chair_on_rightclick(vector.new(0, 0.5, 0), false),
		on_place = chair_on_place,
		on_dig = chunkydeco.chair_on_dig
	})
	
	for index, dye in pairs(chunkydeco.colors) do
		minetest.register_craft {
			type = 'shapeless',
			output = minetest.itemstring_with_palette('chunkydeco:barstool_'..id, (index)*4),
			recipe = {'chunkydeco:barstool_'..id, dye}
		}
		
		minetest.register_craft {
			type = 'shapeless',
			output = minetest.itemstring_with_palette('chunkydeco:barstool_'..id, (index+16)*4),
			recipe = {'chunkydeco:barstool_'..id, dye, 'chunkydeco:dye_booster'}
		}
	end
	
	minetest.register_craft {
			output = minetest.itemstring_with_palette('chunkydeco:barstool_'..id..' 4', 0),
			recipe = {
				{'', 'wool:white', ''},
				{'etc:ct_saw', woodid, ''},
				{'default:stick', '', 'default:stick'}
			}
	}
end

make_bar_stool('apple', 'default:wood', 'Applewood')
make_bar_stool('acacia', 'default:acacia_wood', 'Acacia')
make_bar_stool('aspen', 'default:aspen_wood', 'Aspen')
make_bar_stool('jungle', 'default:junglewood', 'Junglewood')
make_bar_stool('pine', 'default:pine_wood', 'Pine')

local function make_single_seat (id, woodid, displayname)
	local nodebox = {type = 'fixed', fixed = {7/16, -7/16, 7/16, -7/16, -0.5, -7/16}}
	
	chunkydeco: register_node('seat_'..id, {
		displayname = displayname..' Seat Base',
		description = 'Place on top of any node to make it sittable.',
		tiles = {'chunkydeco_chair_'..id..'_kitchen_top.png'},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = '4dir',
		drawtype = 'nodebox',
		node_box = nodebox,
		selection_box = nodebox,
		collision_box = nodebox,
		groups = {choppy = 3, oddly_breakable_by_hand = 1},
		sounds = default.node_sound_wood_defaults(),
		on_rightclick = chunkydeco.chair_on_rightclick(vector.new(0, -0.4, 0), false),
		on_place = chair_on_place,
		on_dig = chunkydeco.chair_on_dig
	})
	
	
	minetest.register_craft {
		output = 'chunkydeco:seat_'..id..' 4',
		recipe = {
			{'', 'etc:ct_saw', ''},
			{woodid, woodid, woodid},
			{'', 'default:stick', ''}
		}
	}
end

make_single_seat('apple', 'default:wood', 'Applewood')
make_single_seat('acacia', 'default:acacia_wood', 'Acacia')
make_single_seat('aspen', 'default:aspen_wood', 'Aspen')
make_single_seat('jungle', 'default:junglewood', 'Junglewood')
make_single_seat('pine', 'default:pine_wood', 'Pine')

do
	local nodebox = {type = 'fixed', fixed = {6/16, -4/16, 6/16, -6/16, -0.5, -6/16}}
	
	chunkydeco: register_node('cushion', {
		displayname = 'Seat Cushion',
		description = 'Place on top of any node to make it sittable.\nCraft with dye to change cushion color.',
		tiles = {'chunkydeco_cushion_top.png', 'chunkydeco_cushion_top.png', 'chunkydeco_cushion_side.png'},
		use_texture_alpha = 'clip',
		paramtype = 'light',
		paramtype2 = 'color4dir',
		palette = 'chunkydeco_4dir_nodes_palette.png',
		color = 'white',
		drawtype = 'nodebox',
		node_box = nodebox,
		selection_box = nodebox,
		collision_box = nodebox,
		groups = {choppy = 3, oddly_breakable_by_hand = 1},
		sounds = default.node_sound_wood_defaults(),
		on_rightclick = chunkydeco.chair_on_rightclick(vector.new(0, -4/16, 0), false),
		on_place = chair_on_place,
		on_dig = chunkydeco.chair_on_dig
	})
	
	for index, dye in pairs(chunkydeco.colors) do
		minetest.register_craft {
			type = 'shapeless',
			output = minetest.itemstring_with_palette('chunkydeco:cushion', (index)*4),
			recipe = {'chunkydeco:cushion', dye}
		}
		
		minetest.register_craft {
			type = 'shapeless',
			output = minetest.itemstring_with_palette('chunkydeco:cushion', (index+16)*4),
			recipe = {'chunkydeco:cushion', dye, 'chunkydeco:dye_booster'}
		}
	end
	
	minetest.register_craft {
		output = minetest.itemstring_with_palette('chunkydeco:cushion 4', 0),
		recipe = {
			{'etc:ct_saw', 'wool:white', ''},
			{'group:wood', 'group:wood', 'group:wood'},
			{'', 'default:stick', ''}
		}
	}
end
