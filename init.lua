
chunkydeco = {modpath = minetest.get_modpath 'chunkydeco'}

local translate = minetest.get_translator 'chunkydeco'

etc.gettext.chunkydeco = function(text, colormode, ...)
	if (not colormode) or colormode == 'normal' then
		return translate(text, ...)
	else
		return minetest.colorize(assert(etc.textcolors[colormode], 'Invalid color: ' .. colormode), translate(etc.wrap_text(text, ETC_DESC_WRAP_LIMIT), ...): gsub('\n', '|n|')): gsub('|n|', '\n'): sub(1, -1)
	end
end

chunkydeco.register_node, chunkydeco.register_item, chunkydeco.register_tool = etc.create_wrappers('chunkydeco', 'chunky')

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

-- (mostly) Indoor Furniture
load_script 'tables'
load_script 'chairs'

load_script 'trashcans'

-- Lighting

-- Construction
load_script 'metal_deco'

-- Miscellaneous
