extends Node2D

const ColBox = preload("res://objects/CollisionBox.tscn")
var n_collider
var id = 0
var item_type
var item_name = 'item'
var dat
var col: int = 0
var layer: int
var pos
var turns = 0

func set_col(p):
	col = p
	if p > 0:
		n_collider = ColBox.instance()
		add_child(n_collider)
		n_collider.collision_layer = p

func place(p):
	position = p.position
	pos = p
	p.add_item(self)

func remove():
	G.world.turn.remove(self)
	pos.remove_item(self)
	get_parent().remove_child(self)
	queue_free()

func relocate(to):
	pos.remove_item(self)
	position = to.position
	to.add_item(self)

func move_world(wld):
	var x = pos.x
	var y = pos.y
	pos.remove_item(self)
	wld.tiles[y][x].add_item(self)

func on_turn():
	turns += 1
	if turns > dat.g("turn", 0):
		dat.run(self, "onturn")
		turns = 0

func autotilize():
	var autotile = dat.g("autotile", 0)
	if autotile != 0:
		var dirs = []
		for i in range(4):
			var adj = pos.get_adjacent(i * 2)
			var item = adj.get_item_by_name(item_name)
			if item != null:
				dirs.append(i)
		var v = G.get_autotile_coord(dirs)
		self.region_rect.position = v * G.W
