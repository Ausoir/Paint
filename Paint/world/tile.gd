const COL_BITS = [1,2,4,8]

var item_type = "tile"
var x
var y
var position
var world
var terrain
var items = []
var visible = true
var dat
var col: int
var autotile = 0
var slow = 1
var shade = -1
var sight_frame = -1

func _init(wld, px, py):
	world = wld
	x = px
	y = py
	position = Vector2(x * G.W + G.HW, y * G.H + G.HH)

func to_vector():
	return Vector2(x, y)

func to_array():
	return [x, y]

func to_string():
	return str(x) + "," + str(y)

func set_terrain(val):
	var data = G.data.terrain_data.get(val)
	if data != null:
		terrain = val
		if "autotile" in data:
			autotile = data.autotile
		slow = data.get("slow", 1)
		var tile_image = world.tileset.find_tile_by_name(val)
		world.tilemap.set_cell(x, y, tile_image)
		dat = data
		dat.col = int(dat.col)
		col = dat.col
	else:
		push_error("Could not find terrain data " + val)

func add_item(item):
	if item.get_parent() == null:
		world.items.add_child(item)
	if item.layer < 0:
		items.insert(0, item)
	else:
		items.append(item)
	item.set_z_index(y - 4000)
	item.pos = self

func remove_item(item):
	if item.get_parent() == world.items:
		world.items.remove_child(item)
	items.erase(item)

func is_col(bit):
	return col & bit > 0

func get_item_by_name(val):
	for item in items:
		if item.item_name == val:
			return item
	return null

func get_item_by_type(val):
	for item in items:
		if item.item_type == val:
			return item
	return null

func get_adjacent(dir, val=1):
	if dir == -1:
		return self
	var t = G.DIRS[dir]
	var ry = y + t[1]*val
	var rx = x + t[0]*val
	if world.is_inbound(rx, ry):
		return world.tiles[ry][rx]
	return self

func get_area(p):
	var r = []
	for iy in range(-p, p+1):
		for ix in range(-p, p+1):
			var rx = x + ix
			var ry = y + iy
			if world.is_inbound(rx, ry):
				r.append(world.tiles[ry][rx])
	return r

func distance_to(tile):
	return max(abs(x - tile.x), abs(y - tile.y))

func get_items_by_type(p):
	var r = []
	for i in items:
		if i.item_type == p:
			r.append(i)
	return r

func get_available_adjacents(cols):
	var r = []
	for i in range(8):
		var adj = get_adjacent(i)
		if !adj.is_col(cols):
			r.append(adj)
	return r

func is_edge():
	return x == 0 or x == world.size.x-1 or y == 0 or y == world.size.y-1

func get_rand_offset(_x, _y):
	var rx = R.ir(-_x, _x)
	var ry = R.ir(-_y, _y)
	return world.fit_bound(x + rx, y + ry)

func get_beam_to(dest, col_mask, distance=-1):
	var diffx = dest.x - x
	var diffy = dest.y - y
	var step = max(abs(diffx), abs(diffy))
	var current = self
	var prev = self
	while current != dest and distance != 0:
		distance -= 1
		var tx = round(current.x + (diffx/step))
		var ty = round(current.y + (diffy/step))
		if world.is_inbound(tx, ty):
			current = world.tiles[ty][tx]
			if current.is_col(col_mask):
				break
		else:
			break
		prev = current
	return [prev, current]
