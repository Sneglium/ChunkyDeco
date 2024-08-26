
local cached_physics = {}
local player_sitting = {}
local player_unsit = {}

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

function chunkydeco.chair_on_rightclick (offset, invert)
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
			
			local facing = node.param2 > 3 and node.param2 - (math.floor(node.param2 / 4) * 4) or node.param2
			local dir = minetest.facedir_to_dir(facing)
			local horiz_rot = math.atan2(invert and -dir.x or dir.x, invert and dir.z or -dir.z)
			local offset_rotated = vector.rotate_around_axis(offset, vector.new(0, 1, 0), horiz_rot)
			local newpos = pos + offset_rotated
			
			clicker: set_pos(newpos)
			player_sitting[playername] = newpos
			
			minetest.after(0, function()
				clicker: set_look_horizontal(horiz_rot)
			end)
			
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

function chunkydeco.chair_on_dig (pos, node, digger)
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
