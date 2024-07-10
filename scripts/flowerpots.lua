
local flowerlist = {}

chunkydeco.register_node('flowerpot_empty', {
	displayname = 'Flowerpot',
	stats = 'Add and remove flowers with <RMB>',
	tiles = {{name = 'chunkydeco_flowerpot_dirt.png', color = 'white'}, {name = 'empty.png', color = 'white'}},
	overlay_tiles = {'chunkydeco_flowerpot_clay.png', ''},
	use_texture_alpha = 'clip',
	drawtype = 'mesh',
	mesh = 'chunkydeco_flowerpot_cross.obj',
	paramtype = 'light',
	paramtype2 = 'color',
	palette = 'chunkydeco_dyed_nodes_palette.png',
	color = '#A1673B',
	selection_box = {
		type = 'fixed',
		fixed = {
			{4/16, 0, 4/16, -4/16, -0.5, -4/16},
			{5/16, 2/16, 5/16, -5/16, 0, -5/16}
		}
	},
	collision_box = {
		type = 'fixed',
		fixed = {
			{4/16, 0, 4/16, -4/16, -0.5, -4/16},
			{5/16, 2/16, 5/16, -5/16, 0, -5/16}
		}
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_stone_defaults(),
	
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if flowerlist[itemstack: get_name()] then
			minetest.swap_node(pos, {name = flowerlist[itemstack: get_name()], param2 = node.param2})
			itemstack: take_item(1)
			return itemstack
		end
		return clicker: get_wielded_item()
	end
})

local function make_flowerpot (flower, override_tex)
	local pot_name ='flowerpot_' .. flower: gsub(':', '_')
	flowerlist[flower] = 'chunkydeco:'..pot_name
	
	local def = minetest.registered_nodes[flower]
	
	chunkydeco.register_node(pot_name, {
		tiles = {
			{name = 'chunkydeco_flowerpot_dirt.png', color = 'white'},
			{name = override_tex or def.tiles[1], color = 'white'}
		},
		overlay_tiles = {'chunkydeco_flowerpot_clay.png', ''},
		use_texture_alpha = 'clip',
		drawtype = 'mesh',
		mesh = 'chunkydeco_flowerpot_cross.obj',
		paramtype = 'light',
		paramtype2 = 'color',
		palette = 'chunkydeco_dyed_nodes_palette.png',
		color = '#A1673B',
		selection_box = {
			type = 'fixed',
			fixed = {
				{4/16, 0, 4/16, -4/16, -0.5, -4/16},
				{5/16, 2/16, 5/16, -5/16, 0, -5/16}
			}
		},
		collision_box = {
			type = 'fixed',
			fixed = {
				{4/16, 0, 4/16, -4/16, -0.5, -4/16},
				{5/16, 2/16, 5/16, -5/16, 0, -5/16}
			}
		},
		groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory = 1},
		sounds = default.node_sound_stone_defaults(),
		
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			etc.give_or_drop(clicker, pos, ItemStack(flower))
			
			minetest.swap_node(pos, {name = 'chunkydeco:flowerpot_empty', param2 = node.param2})
			return clicker: get_wielded_item()
		end,
		
		on_dig = function(pos, node, digger)
			minetest.node_dig(pos, node, digger)
			etc.give_or_drop(digger, pos, ItemStack(flower))
			return true
		end,
		
		drop = {
			items = {
				{items = {'chunkydeco:flowerpot_empty'}, inherit_color = true}
			}
		}
	})
end

make_flowerpot 'flowers:chrysanthemum_green'
make_flowerpot 'flowers:dandelion_white'
make_flowerpot 'flowers:dandelion_yellow'
make_flowerpot 'flowers:geranium'
make_flowerpot 'flowers:rose'
make_flowerpot 'flowers:tulip'
make_flowerpot 'flowers:tulip_black'
make_flowerpot 'flowers:viola'

make_flowerpot 'flowers:mushroom_red'
make_flowerpot 'flowers:mushroom_brown'

make_flowerpot 'default:acacia_bush_sapling'
make_flowerpot 'default:acacia_sapling'
make_flowerpot 'default:aspen_sapling'
make_flowerpot 'default:blueberry_bush_sapling'
make_flowerpot 'default:bush_sapling'
make_flowerpot 'default:emergent_jungle_sapling'
make_flowerpot 'default:junglesapling'
make_flowerpot 'default:pine_bush_sapling'
make_flowerpot 'default:pine_sapling'
make_flowerpot 'default:sapling'

make_flowerpot 'default:large_cactus_seedling'
make_flowerpot 'default:fern_1'

-- old functionality would attempt to place fern_2 or fern_3 sometimes, which is clunky
local old_on_place = minetest.registered_items['default:fern_1'].on_place
minetest.override_item('default:fern_1', {
	on_place = function(itemstack, placer, pointed_thing)
		local node = minetest.get_node(pointed_thing.under)
		if node.name == 'chunkydeco:flowerpot_empty' then
			return minetest.item_place(itemstack, placer, pointed_thing)
		end
		old_on_place(itemstack, placer, pointed_thing)
	end,
})

make_flowerpot('farming:seed_cotton', 'farming_cotton_wild.png')

for index, dye in pairs(chunkydeco.colors) do
	minetest.register_craft {
		type = 'shapeless',
		output = minetest.itemstring_with_palette('chunkydeco:flowerpot_empty', index),
		recipe = {'chunkydeco:flowerpot_empty', dye}
	}
	
	minetest.register_craft {
		type = 'shapeless',
		output = minetest.itemstring_with_palette('chunkydeco:flowerpot_empty', index+16),
		recipe = {'chunkydeco:flowerpot_empty', dye, 'chunkydeco:dye_booster'}
	}
end

minetest.register_craft {
	output = minetest.itemstring_with_palette('chunkydeco:flowerpot_empty', 0),
	recipe = {
		{'', '', ''},
		{'default:clay_brick', 'default:dirt', 'default:clay_brick'},
		{'', 'default:clay_brick', ''}
	}
}
