extends "res://objects/controller.gd"

var reach = 1
var turn_delay = 0

func on_turn():
	turn_delay += 1
	if turn_delay > 3:
		turn_delay = 0
		if target == null:
			perceive()
		if !hunt():
			think()
	.on_turn()

func think():
	if tasks.empty():
		var goal = unit.dat.g("goal", "")
		if goal == "wander":
			path_to(unit.pos.get_rand_offset(12, 12))
		elif goal == "kill":
			target = G.you.unit

func perceive():
	var min_dist = unit.dat.g("perception", 4)
	var seen = search(min_dist)
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
