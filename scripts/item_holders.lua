
local function set_holder_display (pos, node)
	local meta = minetest.get_meta(pos)
	local inv = meta: get_inventory()
	
	local def = minetest.registered_nodes[node.name]
	
	if not inv: is_empty 'item' then
		for i = 1, inv: get_size 'item' do
			local pos = def._item_visual_pos and pos+def._item_visual_pos(pos, node, i) or pos
			local rot = def._item_visual_rotation and def._item_visual_rotation(pos, node, i) or 'random_flat'
			local scale = def._item_visual_scale and def._item_visual_scale(pos, node) or 1
			
			if inv: get_stack('item', i): get_name() then
				etc.add_item_display(pos, inv: get_stack('item', i), scale, rot)
			end
		end
	end
end

minetest.register_lbm {
	name  = 'chunkydeco:update_item_holders',
	nodenames = {'group:item_holder'},
	run_at_every_load = true,
	action = function (pos, node)
		set_holder_display(pos, node)
	end
}

local wallmounted_dir_map = {
	[0] = vector.new(0, 1.15, 0),
	[1] = vector.new(0, -0.85, 0),
	[2] = vector.new(1, 0, 0),
	[3] = vector.new(-1, 0, 0),
	[4] = vector.new(0, 0, 1),
	[5] = vector.new(0, 0, -1)
}

local wallmounted_rot_map = {
	[0] = vector.new(0.5*math.pi, 0, 0),
	[1] = vector.new(-0.5*math.pi, 0, 0),
	[2] = vector.new(0, -0.5*math.pi, 0),
	[3] = vector.new(0, 0.5*math.pi, 0),
	[4] = vector.new(0, 0, 0),
	[5] = vector.new(0, math.pi, 0)
}

local frame_shape = {-6/16, 5/16, 7/16, -0.5, -7/16, -7/16}

local function item_frame_on_construct (pos)
	local meta = minetest.get_meta(pos)
	local inv = meta: get_inventory()
	
	inv: set_size('item', 1)
end

local function item_frame_on_dig (item)
	return function (pos, node, digger)
		if minetest.is_protected(pos, digger: get_player_name()) then
			return false
		end
		
		etc.remove_item_display(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty('item') then
			etc.give_or_drop(digger, vector.add(pos, vector.new(0, 0.5, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
		end
		
		etc.give_or_drop(digger, pos, item)
		minetest.set_node(pos, {name='air'})
		return true
	end
end

local function item_frame_scale (pos, node)
	local meta = minetest.get_meta(pos)
	local inv = meta: get_inventory()
	
	return minetest.registered_nodes[inv: get_stack('item', 1): get_name()] and 1.1 or 1.5
end

local function item_frame_rotation (pos, node)
	return wallmounted_rot_map[node.param2]
end

chunkydeco: register_node('item_frame', {
	displayname = 'Item Frame',
	stats = '<RMB> to add/remove item',
	tiles = {
		'chunkydeco_item_frame_front.png',
		'chunkydeco_item_frame_edge.png',
		'chunkydeco_item_frame_edge.png',
		'chunkydeco_item_frame_edge.png',
		'chunkydeco_item_frame_edge.png',
		'chunkydeco_item_frame_edge.png'
	},
	inventory_image = 'chunkydeco_item_frame_front.png',
	wield_image = 'chunkydeco_item_frame_front.png',
	use_texture_alpha = 'clip',
	paramtype = 'light',
	sunlight_propagates = true,
	paramtype2 = 'wallmounted',
	drawtype = 'nodebox',
	node_box = {
		type = 'wallmounted',
		wall_side = frame_shape,
		wall_bottom = etc.rotate_nodebox(etc.rotate_nodebox(frame_shape, 'z', 1), 'y', 1),
		wall_top = etc.rotate_nodebox(etc.rotate_nodebox(frame_shape, 'z', -1), 'y', -1)
	},
	walkable = false,
	groups = {dig_immediate = 3, attached_node = 1, item_holder = 1},
	sounds = default.node_sound_wood_defaults(),
	
	on_construct = item_frame_on_construct,
	on_dig = item_frame_on_dig(ItemStack 'chunkydeco:item_frame'),
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		if minetest.is_protected(pos, clicker: get_player_name()) then
			return clicker: get_wielded_item()
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty 'item' then
			etc.give_or_drop(clicker, vector.add(pos, vector.new(0, 0.5, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
			meta: set_string('infotext', '')
			etc.remove_item_display(pos)
			return clicker: get_wielded_item()
		end
		
		local taken_item = itemstack: peek_item(1)
		inv: set_stack('item', 1, taken_item)
		meta: set_string('infotext', taken_item: get_short_description())
		set_holder_display (pos, node)
		
		itemstack: take_item(1)
		return itemstack
	end,
	
	_item_visual_pos = function (pos, node)
		return (wallmounted_dir_map[node.param2] * 0.35) - vector.new(0, 0.05, 0)
	end,
	
	_item_visual_rotation = item_frame_rotation,
	_item_visual_scale = item_frame_scale
})

minetest.register_craft {
	recipe = {
		{'default:stick', 'group:string', 'default:stick'},
		{'default:stick', 'default:paper', 'default:stick'},
		{'default:stick', 'default:stick', 'default:stick'}
	},
	output = 'chunkydeco:item_frame 3'
}

chunkydeco: register_node('item_frame_glass', {
	displayname = 'Glass Item Frame',
	description = 'Invisible when holding an item',
	stats = '<RMB> to add/remove item',
	tiles = {
		'chunkydeco_item_frame_glass_front.png',
		'chunkydeco_item_frame_glass_edge.png',
		'chunkydeco_item_frame_glass_edge.png',
		'chunkydeco_item_frame_glass_edge.png',
		'chunkydeco_item_frame_glass_edge.png',
		'chunkydeco_item_frame_glass_edge.png'
	},
	inventory_image = 'chunkydeco_item_frame_glass_front.png',
	wield_image = 'chunkydeco_item_frame_glass_front.png',
	use_texture_alpha = 'blend',
	paramtype = 'light',
	sunlight_propagates = true,
	paramtype2 = 'wallmounted',
	drawtype = 'nodebox',
	node_box = {
		type = 'wallmounted',
		wall_side = frame_shape,
		wall_bottom = etc.rotate_nodebox(etc.rotate_nodebox(frame_shape, 'z', 1), 'y', 1),
		wall_top = etc.rotate_nodebox(etc.rotate_nodebox(frame_shape, 'z', -1), 'y', -1)
	},
	walkable = false,
	groups = {dig_immediate = 3, attached_node = 1, item_holder = 1},
	sounds = default.node_sound_glass_defaults(),
	
	on_construct = item_frame_on_construct,
	on_dig = item_frame_on_dig(ItemStack 'chunkydeco:item_frame_glass'),
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		if minetest.is_protected(pos, clicker: get_player_name()) then
			return clicker: get_wielded_item()
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		local taken_item = itemstack: peek_item(1)
		inv: set_stack('item', 1, taken_item)
		meta: set_string('infotext', taken_item: get_short_description())
		set_holder_display (pos, node)
		
		node.name = 'chunkydeco:item_frame_glass_hidden'
		minetest.swap_node(pos, node)
		
		itemstack: take_item(1)
		return itemstack
	end,
	
	_item_visual_pos = function (pos, node)
		return (wallmounted_dir_map[node.param2] * 0.475) - vector.new(0, 0.05, 0)
	end,
	
	_item_visual_rotation = item_frame_rotation,
	_item_visual_scale = item_frame_scale
})

local frame_shape_min = {-6/16, 2/16, 3/16, -0.5, -4/16, -3/16}

chunkydeco: register_node('item_frame_glass_hidden', {
	tiles = {'empty.png'},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	sunlight_propagates = true,
	paramtype2 = 'wallmounted',
	drawtype = 'nodebox',
	node_box = {
		type = 'wallmounted',
		wall_side = frame_shape_min,
		wall_bottom = etc.rotate_nodebox(etc.rotate_nodebox(frame_shape_min, 'z', 1), 'y', 1),
		wall_top = etc.rotate_nodebox(etc.rotate_nodebox(frame_shape_min, 'z', -1), 'y', -1)
	},
	walkable = false,
	groups = {dig_immediate = 3, attached_node = 1, item_holder = 1, not_in_creative_inventory = 1},
	sounds = default.node_sound_glass_defaults(),
	
	on_construct = item_frame_on_construct,
	on_dig = item_frame_on_dig(ItemStack 'chunkydeco:item_frame_glass'),
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		if minetest.is_protected(pos, clicker: get_player_name()) then
			return clicker: get_wielded_item()
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		etc.give_or_drop(clicker, vector.add(pos, vector.new(0, 0.5, 0)), inv: get_stack('item', 1))
		inv: set_stack('item', 1, '')
		meta: set_string('infotext', '')
		etc.remove_item_display(pos)
		
		node.name = 'chunkydeco:item_frame_glass'
		minetest.swap_node(pos, node)
		
		return clicker: get_wielded_item()
	end,
	
	_item_visual_pos = function (pos, node)
		return (wallmounted_dir_map[node.param2] * 0.475) - vector.new(0, 0.05, 0)
	end,
	
	_item_visual_rotation = item_frame_rotation,
	_item_visual_scale = item_frame_scale
})

minetest.register_craft {
	recipe = {
		{'xpanes:pane_flat', 'group:glue', 'xpanes:pane_flat'},
		{'xpanes:pane_flat', 'default:paper', 'xpanes:pane_flat'},
		{'xpanes:pane_flat', 'xpanes:pane_flat', 'xpanes:pane_flat'}
	},
	output = 'chunkydeco:item_frame_glass 8'
}

local sword_holder_rot_map = {
	[0] = vector.new(0, math.pi, 0.75*math.pi),
	[1] = vector.new(0, 0.5*math.pi, 0.75*math.pi),
	[2] = vector.new(0, -math.pi, 0.75*math.pi),
	[3] = vector.new(0, -0.5*math.pi, 0.75*math.pi)
}

chunkydeco: register_node('sword_holder', {
	displayname = 'Sword Stand',
	stats = '<RMB> to add/remove item',
	tiles = {
		'default_stone.png',
		'default_stone.png',
		'default_stone.png^chunkydeco_sword_holder_side.png',
	},
	inventory_image = 'chunkydeco_sword_holder_inv.png',
	use_texture_alpha = 'clip',
	paramtype = 'light',
	sunlight_propagates = true,
	paramtype2 = '4dir',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{-3/16, -0.5, -2/16, 3/16, -5/16, 2/16},
			{-4/16, -0.5, -2/16, 4/16, -7/16, 2/16},
			{-2/16, -5/16, -1.5/16, 2/16, -4/16, 1.5/16},
		}
	},
	walkable = true,
	groups = {cracky = 3, dig_immediate = 3, attached_node = 1, item_holder = 1},
	sounds = default.node_sound_stone_defaults(),
	
	on_construct = function (pos)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		inv: set_size('item', 1)
	end,
	on_dig = item_frame_on_dig(ItemStack 'chunkydeco:sword_holder'),
	on_rightclick = function (pos, node, clicker, itemstack, pointed_thing)
		if minetest.is_protected(pos, clicker: get_player_name()) then
			return clicker: get_wielded_item()
		end
		
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		if not inv: is_empty 'item' then
			etc.give_or_drop(clicker, vector.add(pos, vector.new(0, 0.5, 0)), inv: get_stack('item', 1))
			inv: set_stack('item', 1, '')
			meta: set_string('infotext', '')
			etc.remove_item_display(pos)
			return clicker: get_wielded_item()
		end
		
		if minetest.get_item_group(itemstack: get_name(), 'sword') ~= 0 then
			local taken_item = itemstack: peek_item(1)
			inv: set_stack('item', 1, taken_item)
			meta: set_string('infotext', taken_item: get_short_description())
			set_holder_display (pos, node)
			
			itemstack: take_item(1)
		end
		
		return itemstack
	end,
	
	_item_visual_pos = function (pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
	
		local scale = (inv: get_stack('item', 1): get_definition().wield_scale or {x = 1, y = 1})
		local hypot = math.sqrt((scale.x^2) + (scale.y^2))
	
		return vector.new(0, (0.4*hypot) - 0.45, 0)
	end,
	
	_item_visual_rotation = function (pos, node)
		return sword_holder_rot_map[node.param2]
	end,
	
	_item_visual_scale = function (pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta: get_inventory()
		
		local scale = vector.new(inv: get_stack('item', 1): get_definition().wield_scale or {x = 1, y = 1, z = 1}) * 0.4
		scale.z = math.min(scale.z, 0.5)
		
		return scale
	end
})

minetest.register_craft {
	recipe = {
		{'', 'default:bronze_ingot', ''},
		{'', 'group:stone', ''},
		{'group:stone', 'group:stone', 'group:stone'}
	},
	output = 'chunkydeco:sword_holder 3'
}
