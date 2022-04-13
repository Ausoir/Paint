const Tile = preload("res://world/tile.gd")
var output

func _init(p):
	make_vault(p)
	G.world.width = len(output[0])
	G.world.height = len(output)
	var r = []
	for y in range(G.world.height):
		var row = []
		for x in range(G.world.width):
			row.append(Tile.new(G.world, x, y))
		r.append(row)
	G.world.tiles = r
	paint_map()

func paint_map():
	for x in range(G.world.width):
		for y in range(G.world.height):
			var value = output[y][x]
			if value != null:
				G.world.set_terrain(x, y, value[0])
			else:
				G.world.set_terrain(x, y, 'void')
	for x in range(G.world.width):
		for y in range(G.world.height):
			var value = output[y][x]
			if value != null:
				for i in range(1, value.size()):
					var list = G.data.get_combo(value[i])
					for item in list:
						G.cmds([["make", item, G.world.tiles[y][x]]])

func is_inbound(x, y):
	return x >= 0 and x < G.world.width and y >= 0 and y < G.world.height

func get_tile(_map, x, y, default=null):
	if x < 0 or x >= G.world.width:
		return default
	if y < 0 or y >= G.world.height:
		return default
	return _map[y][x]

func make_base(sx, sy, val):
	var r = []
	for _y in range(sy):
		var row = []
		for _x in range(sx):
			row.append(val)
		r.append(row)
	return r

func make_vault(type):
	var data = G.data.get_json_data("vaults/" + type)
	var flip = R.ir(0, 3)
	var rot = R.b()
	for vault_data in data:
		var chance = vault_data[0]
		var map = vault_data[1]
		var palette = vault_data[2]
		if R.ir(0, 99) < chance:
			return place_vault(map, palette, flip, rot)
	return null

func place_vault(vault, palette, flip, rot):
	var sizeY = len(vault)
	var sizeX = len(vault[0])
	if rot:
		output = make_base(sizeY, sizeX, 0)
	else:
		output = make_base(sizeX, sizeY, 0)

	for y in range(sizeY):
		for x in range(sizeX):
			var sX = x
			var sY = y
			var fX
			var fY
			if flip == 1:
				sX = (sizeX-1 - x)
				sY = y
			elif flip == 2:
				sX = x
				sY = (sizeY-1 - y)
			elif flip == 3:
				sX = (sizeX-1 - x)
				sY = (sizeY-1 - y)
			if rot:
				fX = sY
				fY = sX
			else:
				fX = sX
				fY = sY
			var val = vault[y][x]
			var palet = palette.get(val)
			if palet != null:
				output[fY][fX] = palet
			else:
				push_error("Invalid vault palette value: "+str(val))
