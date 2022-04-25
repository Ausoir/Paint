extends "res://objects/controller.gd"

var think_delay = 0

func on_turn():
	if think_delay == 0:
		if target == null:
			perceive()
		if !hunt():
			think()
	else:
		think_delay -= 1
		hunt()
	.on_turn()

func think():
	if tasks.empty():
		path_to(unit.pos.get_rand_offset(12, 12))
		think_delay = R.ir(4, 32)

func perceive():
	var seen = search(8)
	if seen != null:
		target = seen

func search(_dist):
	var seen = G.you.unit
	if is_instance_valid(seen) and seen != unit:
		var dist = unit.pos.distance_to(seen.pos)
		if dist <= _dist:
			if seen.n_sprites.visible:
				if unit.pos.get_beam_to(seen.pos, 1)[1] == seen.pos:
					return seen
	return null

func hunt():
	if target != null and is_instance_valid(target):
		path_to(target.pos, target)
		return true
	else:
		target = null
		return false
