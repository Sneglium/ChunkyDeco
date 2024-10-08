
etc.register_mod 'chunkydeco'

local translate = minetest.get_translator 'chunkydeco'

chunkydeco.gettext = function(text, colormode, ...)
	if (not colormode) or colormode == 'normal' or colormode == 'displayname' then
		return translate(text, ...)
	else
		return minetest.colorize(assert(etc.textcolors[colormode], 'Invalid color: ' .. colormode), translate(etc.wrap_text(text, ETC_DESC_WRAP_LIMIT), ...): gsub('\n', '|n|')): gsub('|n|', '\n'): sub(1, -1)
	end
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

-- NOTE: fair warning; a lot of this code is really crappy and duplicated across files because I have yet to make an Etc util for it.

-- Utilities
chunkydeco: load_script 'dye_booster'
chunkydeco: load_script 'sitting'

-- Outdoor Furniture
chunkydeco: load_script 'flowerpots'
chunkydeco: load_script 'planters'

-- (mostly) Indoor Furniture
chunkydeco: load_script 'tables'
chunkydeco: load_script 'chairs'
chunkydeco: load_script 'benches'

chunkydeco: load_script 'trashcans'

-- Construction
chunkydeco: load_script 'metal_deco'

-- General Decorations
chunkydeco: load_script 'item_holders'
