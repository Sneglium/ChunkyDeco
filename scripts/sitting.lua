
function chunkydeco.chair_on_rightclick (offset, invert)
	return function (pos, node, clicker, itemstack, pointed_thing)
		if etc.get_sitting(clicker) then
			etc.set_sitting(clicker, false)
		else
			if math.abs(clicker: get_velocity().y) >= 3 then return end
			
			local facing = node.param2 > 3 and node.param2 - (math.floor(node.param2 / 4) * 4) or node.param2
			local dir = minetest.facedir_to_dir(facing)
			local horiz_rot = math.atan2(invert and -dir.x or dir.x, invert and dir.z or -dir.z)
			local offset_rotated = vector.rotate_around_axis(offset, vector.new(0, 1, 0), horiz_rot)
			local newpos = pos + offset_rotated
			
			etc.set_sitting(clicker, newpos)
			
			minetest.after(0, function()
				clicker: set_look_horizontal(horiz_rot)
			end)
		end
	end
end

function chunkydeco.chair_on_dig (pos, node, digger)
	etc.set_sitting(digger, false)
	
	return minetest.node_dig(pos, node, digger)
end
