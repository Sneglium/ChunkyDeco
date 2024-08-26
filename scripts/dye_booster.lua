
chunkydeco: register_item('dye_booster', {
	displayname = 'Color Rendering Catalyst',
	description = 'A mixture of substances that increases the vibrance of pigment.',
	inventory_image = 'chunkydeco_dye_booster.png'
})

minetest.register_craft {
	type = 'shapeless',
	output = 'chunkydeco:dye_booster 4',
	recipe = {'default:coral_pink', 'default:coral_cyan', 'etc:acid'}
}
