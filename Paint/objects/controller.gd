extends Node

const Pathing = preload("res://objects/pathing.gd")
var unit
var sight_range = 8
var target
var tasks = []
var pathing

func on_assign():
	pathing = Pathing.new(unit.pos.world)
	target = null

func unassign(_dead=false):
	if unit != null:
		unit.controller = null
		unit = null

func on_turn():
	if !tasks.empty():
		var task = tasks[0]
		if perform(task):
			tasks.pop_front()

func perform(task):
	if task[0] == "path":
		if task[2] != null and validate_target(task[2]):
			var exc = [unit.n_collider, target.n_collider]
			if unit.n_collider.cast_col_ray(task[2].position, exc, 12).empty():
				unit.slide(task[2].position)
				return false
		unit.slide(task[1].position)
		return (task[1].position - unit.position).length_squared() < 64
	elif task[0] == "move":
		var v = G.DIRS[task[1]]
		unit.slide(Vector2(unit.position.x+v[0], unit.position.y+v[1]))
	elif task[0] == "command":
		G.cmds(task[1], task[2], task[3])
	return true

func validate_target(p):
	if p == null:
		return false
	elif !is_instance_valid(p):
		if p == target:
			target = null
		return false
	return true

func path_to(pos, tgt=null):
	pathing.result = []
	var unitpos_vec = unit.pos.to_vector()
	var pos_vec = pos.to_vector()
	if unitpos_vec == pos_vec:
		tasks = []
	else:
		var path = pathing.update(unitpos_vec, pos_vec)
		if path:
			tasks = []
			for p in path:
				tasks.append(["path", unit.pos.world.tiles[p.y][p.x], tgt])

func remove():
	queue_free()
