
local cached_physics = {}
local player_sitting = {}
local player_unsit = {}

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

local chairphys = {
	speed = 0,
	jump = 0,
	sneak = false
}

minetest.register_entity('chunkydeco:chair_ent', {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = 'sprite',
		textures = {'empty.png'},
		is_visible = false,
		static_save = false
	}
})

local function chair_on_rightclick (offset, invert)
	return function (pos, node, clicker, itemstack, pointed_thing)
		local playername = clicker: get_player_name()
		if player_sitting[playername] then
			clicker: set_physics_override(cached_physics[playername])
			clicker: set_pos(player_unsit[playername])
			player_sitting[playername] = false
		else
			if math.abs(clicker: get_velocity().y) >= 3 then return end
			cached_physics[playername] = clicker: get_physics_override()
			clicker: set_physics_override(chairphys)
			
			player_unsit[playername] = clicker: get_pos()
			
			local dir = minetest.facedir_to_dir(node.param2)
			local horiz_rot = math.atan2(invert and -dir.x or dir.x, invert and dir.z or -dir.z)
			local offset_rotated = vector.rotate_around_axis(offset, vector.new(0, 1, 0), horiz_rot)
			local newpos = pos + offset_rotated
			
			clicker: set_pos(newpos)
			player_sitting[playername] = newpos
			clicker: set_look_horizontal(horiz_rot)
			
			local chair_ent = minetest.add_entity(pos, 'chunkydeco:chair_ent')
			clicker: set_attach(chair_ent, '', newpos, dir)
			
			minetest.after(0.1, function (clicker, chair_ent, newpos)
				if clicker and chair_ent then
					clicker: set_detach()
					chair_ent: remove()
					clicker: set_pos(newpos)
				end
			end, clicker, chair_ent, newpos)
		end
	end
end

local function chair_on_dig (pos, node, digger)
	local playername = digger: get_player_name()
	
	if player_sitting[playername] then
		digger: set_physics_override(cached_physics[playername])
		digger: set_pos(player_unsit[playername])
		player_sitting[playername] = false
	end
	
	return minetest.node_dig(pos, node, digger)
end

minetest.register_globalstep(function()
	local players = minetest.get_connected_players()
	for i = 1, #players do
		local player = players[i]
		local playername = player: get_player_name()
		
		if player_api and player_sitting[playername] then
			player_api.set_animation(player, 'sit')
		end
		
		if player: get_player_control().sneak and player_sitting[playername] then
			player: set_physics_override(cached_physics[playername])
			player: set_pos(player_unsit[playername])
			player_sitting[playername] = false
		end
	end
end)

local function register_chair_node (name, id, description, nodebox, texname_override, specialgroup, offset, invert)
	minetest.register_node('chunkydeco:chair_'..name..'_'..id, {
		description = description..'\nSneak while placing to put under tables.',
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
		sounds = default.node_sound_wood_defaults(),
		drop = 'chunkydeco:chair_'..name..'_0',
		on_place = id == 0 and chair_on_place or nil,
		on_rightclick = chair_on_rightclick(offset or vector.new(), invert),
		on_dig = chair_on_dig
	})
end

-- top_box is the seat, leg_box is the +XZ leg, back_box is the chair back which should be oriented to the -Z face
local function make_chair (name, description, top_box, leg_box, back_box, texname_override, special_group, sit_height)
	local nodebox = {}
	chunkydeco.unpack_and_inject(nodebox, top_box)
	chunkydeco.unpack_and_inject(nodebox, back_box)
	chunkydeco.unpack_and_inject(nodebox, leg_box)
	chunkydeco.unpack_and_inject(nodebox, etc.rotate_nodeboxes(leg_box, 'y', 1))
	chunkydeco.unpack_and_inject(nodebox, etc.rotate_nodeboxes(leg_box, 'y', 2))
	chunkydeco.unpack_and_inject(nodebox, etc.rotate_nodeboxes(leg_box, 'y', 3))
	
	register_chair_node(name, 0, description, {type = 'fixed', fixed = nodebox}, texname_override, special_group, vector.new(0, sit_height or 2/16, 0))
	
	local nodebox_2 = {}
	
	for _, v in ipairs(nodebox) do
		local new_box = table.copy(v)
		print(dump(new_box))
		new_box[3] = new_box[3] - 0.5
		new_box[6] = new_box[6] - 0.5
		
		table.insert(nodebox_2, etc.rotate_nodebox(new_box, 'y', 2))
	end
	
	register_chair_node(name, 1, description, {type = 'fixed', fixed = nodebox_2}, texname_override, special_group, vector.new(0, sit_height or 2/16, 0.5), true)
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
			{'', '', 'default:stick'},
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
			{'', '', 'default:stick'},
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

