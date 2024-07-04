
chunkydeco = {modpath = minetest.get_modpath 'chunkydeco'}

local function load_script (fn)
	dofile(table.concat {chunkydeco.modpath, '/scripts/', fn, '.lua'})
end

function chunkydeco.unpack_and_inject (t, t2)
	if not t2 then return end
	if type(t2[1]) == 'table' then
		for k, v in ipairs(t2) do
			table.insert(t, v)
		end
	else
		table.insert(t, t2)
	end
end

chunkydeco.colors = {
	'dye:black',
	'dye:blue',
	'dye:brown',
	'dye:cyan',
	'dye:dark_green',
	'dye:dark_grey',
	'dye:green',
	'dye:grey',
	'dye:magenta',
	'dye:orange',
	'dye:pink',
	'dye:red',
	'dye:violet',
	'dye:yellow',
	'dye:white'
}

-- Utilities
load_script 'dye_booster'

-- Outdoor Furniture
load_script 'flowerpots'
load_script 'planters'

-- TODO: mesh-based chairs with dyeable cushions
--- upholstered kitchen chair
--- Bar stool
--- armchair
-- TODO: indoor/outdoor metal tables & chairs
-- TODO: park benches

-- (mostly) Indoor Furniture
load_script 'tables'
load_script 'chairs'

load_script 'trashcans'

-- Lighting

-- Construction

-- Miscellaneous
