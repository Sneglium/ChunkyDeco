
local function make_metal_rod (id, ingot_id, block_id, displayname)
	local blockdef = minetest.registered_nodes[block_id]
	chunkydeco.register_node('metal_rod_'..id, {
		displayname = displayname .. ' Rod',
		tiles = block_id: find '%.png' and {block_id} or blockdef.tiles,
		use_texture_alpha = 'clip',
		paramtype = 'light',
		sunlight_propagates = true,
		paramtype2 = 'facedir',
		drawtype = 'nodebox',
		node_box = {
			type = 'fixed',
			fixed = {1.5/16, 0.5, 1.5/16, -1.5/16, -0.5, -1.5/16}
		},
		groups = {cracky = 2, metal = 1},
		sounds = default.node_sound_metal_defaults(),
		on_place = minetest.rotate_node
	})
	
	minetest.register_craft {
		output = 'chunkydeco:metal_rod_'..id..' 2',
		recipe = {
			{'etc:ct_hammer', ingot_id, ''},
			{'', ingot_id, ''},
			{'', ingot_id, ''}
		}
	}
end

make_metal_rod('steel', 'default:steel_ingot', 'chunkydeco_steel_rod.png', 'Steel')
if etc.modules.wrought_iron then
	make_metal_rod('wrought_iron', 'etc:wrought_iron_ingot', 'chunkydeco_wrought_iron_rod.png', 'Wrought Iron')
end

local function make_metal_post (id, ingot_id, block_id, displayname)
	local blockdef = minetest.registered_nodes[block_id]
	chunkydeco.register_node('metal_post_'..id, {
		displayname = displayname .. ' Post',
		tiles = block_id: find '%.png' and {block_id} or blockdef.tiles,
		use_texture_alpha = 'clip',
		paramtype = 'light',
		sunlight_propagates = true,
		paramtype2 = 'facedir',
		drawtype = 'nodebox',
		node_box = {
			type = 'fixed',
			fixed = {
				{2.5/16, 0.5, 2.5/16, -2.5/16, -0.5, 1.5/16},
				{2.5/16, 0.5, 2.5/16, 1.5/16, -0.5, -2.5/16},
				{-1.5/16, 0.5, 2.5/16, -2.5/16, -0.5, -2.5/16},
				{2.5/16, 0.5, -1.5/16, -2.5/16, -0.5, -2.5/16}
			}
		},
		selection_box = {
			type = 'fixed',
			fixed = {2.5/16, 0.5, 2.5/16, -2.5/16, -0.5, -2.5/16}
		},
		groups = {cracky = 2, metal = 1},
		sounds = default.node_sound_metal_defaults(),
		on_place = minetest.rotate_node
	})
	
	minetest.register_craft {
		output = 'chunkydeco:metal_post_'..id,
		recipe = {
			{'', 'etc:ct_hammer', ''},
			{'', ingot_id, ''},
			{'', ingot_id, ''}
		}
	}
	
	chunkydeco.register_node('metal_post_end_'..id, {
		displayname = displayname .. ' Post Endcap',
		tiles = block_id: find '%.png' and {block_id} or blockdef.tiles,
		use_texture_alpha = 'clip',
		paramtype = 'light',
		sunlight_propagates = true,
		paramtype2 = 'facedir',
		drawtype = 'nodebox',
		node_box = {
			type = 'fixed',
			fixed = {
				{2.5/16, 0.5, 2.5/16, -2.5/16, -0.5, 1.5/16},
				{2.5/16, 0.5, 2.5/16, 1.5/16, -0.5, -2.5/16},
				{-1.5/16, 0.5, 2.5/16, -2.5/16, -0.5, -2.5/16},
				{2.5/16, 0.5, -1.5/16, -2.5/16, -0.5, -2.5/16},
				{3.5/16, -7/16, 3.5/16, -3.5/16, -0.5, -3.5/16}
			}
		},
		selection_box = {
			type = 'fixed',
			fixed = {
				{2.5/16, 0.5, 2.5/16, -2.5/16, -7/16, -2.5/16},
				{3.5/16, -7/16, 3.5/16, -3.5/16, -0.5, -3.5/16}
			}
		},
		groups = {cracky = 2, metal = 1},
		sounds = default.node_sound_metal_defaults(),
		on_place = minetest.rotate_node
	})
	
	minetest.register_craft {
		output = 'chunkydeco:metal_post_end_'..id..' 2',
		recipe = {
			{'', 'etc:ct_hammer', ''},
			{'', ingot_id, ''},
			{ingot_id, ingot_id, ingot_id}
		}
	}
end

make_metal_post('steel', 'default:steel_ingot', 'chunkydeco_steel_rod.png', 'Steel')
if etc.modules.wrought_iron then
	make_metal_post('wrought_iron', 'etc:wrought_iron_ingot', 'chunkydeco_wrought_iron_rod.png', 'Wrought Iron')
end

local function make_metal_beam (id, ingot_id, block_id, displayname)
	local nodebox = {
		{0.5, -7/16, 3/16, -0.5, -0.5, -3/16},
		{0.5, -4/16, 2/16, -0.5, -7/16, 1/16},
		{0.5, -4/16, -2/16, -0.5, -7/16, -1/16},
		{0.5, -3/16, 3/16, -0.5, -4/16, -3/16}
	}
	
	local blockdef = minetest.registered_nodes[block_id]
	chunkydeco.register_node('metal_beam_'..id, {
		displayname = displayname .. ' I-Beam',
		tiles = block_id: find '%.png' and {block_id} or blockdef.tiles,
		paramtype = 'light',
		sunlight_propagates = true,
		paramtype2 = 'facedir',
		drawtype = 'nodebox',
		node_box = {
			type = 'fixed',
			fixed = nodebox
		},
		selection_box = {
			type = 'fixed',
			fixed = {0.5, -3/16, 3/16, -0.5, -0.5, -3/16}
		},
		collision_box = {
			type = 'fixed',
			fixed = {0.5, -3/16, 3/16, -0.5, -0.5, -3/16}
		},
		groups = {cracky = 2, metal = 1},
		sounds = default.node_sound_metal_defaults(),
		on_place = etc.copy_or_calculate_rotation
	})
	
	minetest.register_craft {
		output = 'chunkydeco:metal_beam_'..id..' 6',
		recipe = {
			{'', 'etc:ct_hammer', ''},
			{ingot_id, ingot_id, ingot_id},
			{'', '', ''}
		}
	}
end

make_metal_beam('steel', 'default:steel_ingot', 'chunkydeco_steel_ibeam.png', 'Steel')
if etc.modules.wrought_iron then
	make_metal_beam('wrought_iron', 'etc:wrought_iron_ingot', 'chunkydeco_wrought_iron_ibeam.png', 'Wrought Iron')
end

local brace_nodebox = {
	{4/16, -7/16, 2/16, -0.5, -0.5, -2/16},
	etc.rotate_nodebox({0.5, -7/16, 2/16, -2/16, -0.5, -2/16}, 'z', -1),
	{0.5, 0.5, 0, -0.5, -0.5, 0}
}

local brace_collisionbox = {
	brace_nodebox[1],
	brace_nodebox[2]
}

local brace_selectionbox = {
	{4/16, 2/16, 2/16, -0.5, -0.5, -2/16}
}

chunkydeco.register_node('metal_brace_steel', {
	displayname = 'Steel Corner Brace',
	tiles = {
		'chunkydeco_steel_ibeam.png',
		'chunkydeco_steel_ibeam.png',
		'chunkydeco_steel_ibeam.png',
		'chunkydeco_steel_ibeam.png',
		'chunkydeco_steel_brace_side.png^[transformFXR270',
		'chunkydeco_steel_brace_side.png^[transformR90'
	},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	sunlight_propagates = true,
	paramtype2 = 'facedir',
	drawtype = 'nodebox',
	node_box = {type = 'fixed', fixed = brace_nodebox},
	collision_box = {type = 'fixed', fixed = brace_collisionbox},
	selection_box = {type = 'fixed', fixed = brace_selectionbox},
	groups = {cracky = 2, metal = 1},
	sounds = default.node_sound_metal_defaults(),
	on_place = etc.copy_or_calculate_rotation
})

minetest.register_craft {
	output = 'chunkydeco:metal_brace_steel 3',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', ''},
		{'default:steel_ingot', 'etc:ct_file', ''},
		{'', '', ''}
	}
}

chunkydeco.register_node('metal_brace_wrought_iron', {
	displayname = 'Wrought Iron Corner Brace',
	tiles = {
		'chunkydeco_wrought_iron_ibeam.png',
		'chunkydeco_wrought_iron_ibeam.png',
		'chunkydeco_wrought_iron_ibeam.png',
		'chunkydeco_wrought_iron_ibeam.png',
		'chunkydeco_wrought_iron_brace_side.png^[transformFXR270',
		'chunkydeco_wrought_iron_brace_side.png^[transformR90'
	},
	use_texture_alpha = 'clip',
	paramtype = 'light',
	sunlight_propagates = true,
	paramtype2 = 'facedir',
	drawtype = 'nodebox',
	node_box = {type = 'fixed', fixed = brace_nodebox},
	collision_box = {type = 'fixed', fixed = brace_collisionbox},
	selection_box = {type = 'fixed', fixed = brace_selectionbox},
	groups = {cracky = 2, metal = 1},
	sounds = default.node_sound_metal_defaults(),
	on_place = etc.copy_or_calculate_rotation
})

minetest.register_craft {
	output = 'chunkydeco:metal_brace_wrought_iron 3',
	recipe = {
		{'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot', ''},
		{'etcetera:wrought_iron_ingot', 'etc:ct_file', ''},
		{'', '', ''}
	}
}

minetest.register_node('chunkydeco:scaffold_ladder', {
	drawtype = 'airlike',
	paramtype2 = '4dir',
	collision_box = {type = 'fixed', fixed = {-6/16, 0.5, 0.5, -0.5, -0.5, -0.5}},
	pointable = false,
	buildable_to = true,
	walkable = false,
	climbable = true,
	paramtype = 'light',
	sunlight_propagates = true,
	move_resistance = 0,
	groups = {not_in_creative_inventory = 1}
})

local function check_and_place (pos, rot)
	if minetest.get_node(pos).name == 'air' then
		minetest.set_node(pos, {name = 'chunkydeco:scaffold_ladder', param2 = rot})
	end
end

local scaffold_on_construct = function (pos)
	check_and_place(pos +vector.new(1, 0, 0), 0)
	check_and_place(pos +vector.new(0, 0, -1), 1)
	check_and_place(pos +vector.new(-1, 0, 0), 2)
	check_and_place(pos +vector.new(0, 0, 1), 3)
end

local function check_and_remove (pos, rot)
	if minetest.get_node(pos).name == 'chunkydeco:scaffold_ladder' then
		minetest.set_node(pos, {name = 'air', param2 = rot})
	end
end

local scaffold_on_destruct = function (pos)
	check_and_remove(pos +vector.new(1, 0, 0), 0)
	check_and_remove(pos +vector.new(0, 0, -1), 1)
	check_and_remove(pos +vector.new(-1, 0, 0), 2)
	check_and_remove(pos +vector.new(0, 0, 1), 3)
end

chunkydeco.register_node('metal_scaffold_wrought_iron', {
	displayname = 'Wrought Iron Scaffolding',
	description = 'Can be climbed like a ladder.',
	tiles = {
		'chunkydeco_wrought_iron_scaffold_edge.png',
		{name = 'chunkydeco_wrought_iron_scaffold_middle.png', backface_culling = false}
	},
	drawtype = 'glasslike_framed',
	paramtype = 'light',
	use_texture_alpha = 'clip',
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = scaffold_on_construct,
	on_destruct = scaffold_on_destruct
})

chunkydeco.register_node('metal_scaffold_steel', {
	displayname = 'Steel Scaffolding',
	description = 'Can be climbed like a ladder.',
	tiles = {
		'chunkydeco_steel_scaffold_edge.png',
		{name = 'chunkydeco_steel_scaffold_middle.png', backface_culling = false}
	},
	drawtype = 'glasslike_framed',
	paramtype = 'light',
	use_texture_alpha = 'clip',
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = scaffold_on_construct,
	on_destruct = scaffold_on_destruct
})

if stairs then
	stairs.register_stair_and_slab(
		'scaffold_wrought_iron',
		'chunkydeco:metal_scaffold_wrought_iron',
		{cracky=1},
		{'chunkydeco_wrought_iron_scaffold_middle.png^chunkydeco_wrought_iron_scaffold_edge.png'},
		'Wrought Iron Scaffolding Stairs',
		'Wrought Iron Scaffolding Slab',
		default.node_sound_metal_defaults(),
		false,
		'Wrought Iron Scaffolding Stairs (Inner Corner)',
		'Wrought Iron Scaffolding Stairs (Outer Corner)'
	)
	
	stairs.register_stair_and_slab(
		'scaffold_steel',
		'chunkydeco:metal_scaffold_steel',
		{cracky=1},
		{'chunkydeco_steel_scaffold_middle.png^chunkydeco_steel_scaffold_edge.png'},
		'Steel Scaffolding Stairs',
		'Steel Scaffolding Slab',
		default.node_sound_metal_defaults(),
		false,
		'Steel Scaffolding Stairs (Inner Corner)',
		'Steel Scaffolding Stairs (Outer Corner)'
	)
end

minetest.register_craft {
	output = 'chunkydeco:metal_scaffold_wrought_iron 30',
	recipe = {
		{'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot'},
		{'chunkydeco:metal_rod_wrought_iron', 'etc:ct_drill', 'chunkydeco:metal_rod_wrought_iron'},
		{'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot', 'etcetera:wrought_iron_ingot'}
	}
}

minetest.register_craft {
	output = 'chunkydeco:metal_scaffold_steel 30',
	recipe = {
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
		{'chunkydeco:metal_rod_steel', 'etc:ct_drill', 'chunkydeco:metal_rod_steel'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'}
	}
}
