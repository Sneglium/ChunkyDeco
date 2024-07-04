
local trashcan_form = [[
formspec_version[7]
size[10.25,10.25]
background9[0,0;0,0;etc_formbg.png;true;8]

list[current_player;main;0.25,5.25;8,4]
list[context;trash;2.75,0.25;4,3]
listring[]
image_button[3.125,4;4,1;chunkydeco_trash_button.png;empty;]
tooltip[empty;Empty Trash]
]]

local function trashcan_construct (pos)
	local meta = minetest.get_meta(pos)
	
	meta: get_inventory(): set_size('trash', 12)
	meta: set_string('formspec', trashcan_form)
end

local function trashcan_receive_fields (pos, formname, fields, sender)
	local inv = minetest.get_meta(pos): get_inventory()
	
	inv: set_list('trash', {})
	inv: set_size('trash', 12)
end

minetest.register_node('chunkydeco:trashcan', {
	description = 'Trash Can\nDeletes all items inside it when closed.',
	tiles = {'chunkydeco_trashcan_top.png', 'chunkydeco_trashcan_bottom.png', 'chunkydeco_trashcan_side.png'},
	drawtype = 'nodebox',
	paramtype = 'light',
	use_texture_alpha = 'clip',
	node_box = {
		type = 'fixed',
		fixed = {
			{5/16, 4/16, 5/16, -5/16, -0.5, -5/16},
			{6/16, 6/16, 6/16, -6/16, 4/16, -6/16},
			{5.5/16, 7/16, 5.5/16, -5.5/16, 6/16, -5.5/16},
			{2/16, 8/16, 1/16, -2/16, 7/16, -1/16}
		}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_metal_defaults(),
	on_construct = trashcan_construct,
	on_receive_fields = trashcan_receive_fields
})

minetest.register_craft {
	output = 'chunkydeco:trashcan 2',
	recipe = {
		{'', 'default:tin_ingot', ''},
		{'default:tin_ingot', 'default:paper', 'default:tin_ingot'},
		{'default:tin_ingot', 'default:tin_ingot', 'default:tin_ingot'}
	}
}

minetest.register_node('chunkydeco:trashcan_wire', {
	description = 'Wire Wastepaper Basket\nDeletes all items inside it when closed.',
	tiles = {'chunkydeco_trashcan_wire_top.png', 'chunkydeco_trashcan_bottom.png', 'chunkydeco_trashcan_wire_side.png'},
	drawtype = 'nodebox',
	paramtype = 'light',
	use_texture_alpha = 'clip',
	node_box = {
		type = 'fixed',
		fixed = {
			{4.5/16, -7.5/16, 4.5/16, -4.5/16, -0.5, -4.5/16},
			{4.5/16, 4/16, -4/16, -4.5/16, -0.5, -4.5/16},
			{4.5/16, 4/16, 4.5/16, -4.5/16, -0.5, 4/16},
			{-4/16, 4/16, 4.5/16, -4.5/16, -0.5, -4.5/16},
			{4.5/16, 4/16, 4.5/16, 4/16, -0.5, -4.5/16}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {4.5/16, 4/16, 4.5/16, -4.5/16, -0.5, -4.5/16}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_metal_defaults(),
	on_construct = trashcan_construct,
	on_receive_fields = trashcan_receive_fields
})

minetest.register_craft {
	output = 'chunkydeco:trashcan_wire 2',
	recipe = {
		{'default:tin_ingot', '', 'default:tin_ingot'},
		{'default:tin_ingot', 'default:paper', 'default:tin_ingot'},
		{'', 'default:tin_ingot', ''}
	}
}

minetest.register_node('chunkydeco:trashcan_wire_full', {
	description = 'Wire Wastepaper Basket (Full)\nDeletes all items inside it when closed.',
	tiles = {'chunkydeco_trashcan_paper.png', 'chunkydeco_trashcan_bottom.png', 'chunkydeco_trashcan_paper.png^chunkydeco_trashcan_wire_side.png'},
	drawtype = 'nodebox',
	paramtype = 'light',
	use_texture_alpha = 'clip',
	node_box = {
		type = 'fixed',
		fixed = {
			{4.5/16, -7.5/16, 4.5/16, -4.5/16, -0.5, -4.5/16},
			{4.5/16, 4/16, -4/16, -4.5/16, -0.5, -4.5/16},
			{4.5/16, 4/16, 4.5/16, -4.5/16, -0.5, 4/16},
			{-4/16, 4/16, 4.5/16, -4.5/16, -0.5, -4.5/16},
			{4.5/16, 4/16, 4.5/16, 4/16, -0.5, -4.5/16},
			{4/16, 2/16, 4/16, -4/16, -0.5, -4/16}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {4.5/16, 4/16, 4.5/16, -4.5/16, -0.5, -4.5/16}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_metal_defaults(),
	on_construct = trashcan_construct,
	on_receive_fields = trashcan_receive_fields
})

minetest.register_craft {
	output = 'chunkydeco:trashcan_wire_full 2',
	recipe = {
		{'default:tin_ingot', 'default:paper', 'default:tin_ingot'},
		{'default:tin_ingot', 'default:paper', 'default:tin_ingot'},
		{'', 'default:tin_ingot', ''}
	}
}
