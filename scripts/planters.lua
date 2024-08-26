
chunkydeco: register_node('flowerpot_large', {
	displayname = 'Terracotta Planter',
	tiles = {
		{name = 'chunkydeco_planter_dirt.png', color = 'white'},
		'chunkydeco_planter_clay_bottom.png',
		'chunkydeco_planter_clay_side.png'
	},
	overlay_tiles = {'chunkydeco_planter_clay_top.png', '', '', ''},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	paramtype2 = 'color',
	palette = 'chunkydeco_dyed_nodes_palette.png',
	color = '#A1673B',
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{7/16, 0.5, 7/16, -7/16, -6/16, -7/16},
			{0.5, 7/16, 0.5, -0.5, -4/16, -0.5},
			{6/16, -6/16, 6/16, -6/16, -0.5, -6/16},
			{6/16, 0.5, 6/16, -6/16, 9/16, -6/16}
		}
	},
	selection_box = {
		type = 'fixed',
		fixed = {
			{7/16, 0.5, 7/16, -7/16, -6/16, -7/16},
			{0.5, 7/16, 0.5, -0.5, -4/16, -0.5},
			{6/16, -6/16, 6/16, -6/16, -0.5, -6/16}
		}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_stone_defaults()
})

for index, dye in pairs(chunkydeco.colors) do
	minetest.register_craft {
		type = 'shapeless',
		output = minetest.itemstring_with_palette('chunkydeco:flowerpot_large', index),
		recipe = {'chunkydeco:flowerpot_large', dye}
	}
	
	minetest.register_craft {
		type = 'shapeless',
		output = minetest.itemstring_with_palette('chunkydeco:flowerpot_large', index+16),
		recipe = {'chunkydeco:flowerpot_large', dye, 'chunkydeco:dye_booster'}
	}
end

minetest.register_craft {
	output = minetest.itemstring_with_palette('chunkydeco:flowerpot_large', 0),
	recipe = {
		{'default:clay_brick', '', 'default:clay_brick'},
		{'default:clay_brick', 'default:dirt', 'default:clay_brick'},
		{'default:clay_brick', 'default:clay_brick', 'default:clay_brick'}
	}
}
