extends Node2D

const Healthbar = preload("res://interface/Health.tscn")
var n_healthbar
var n_collider
var id = 0
var item_type
var item_name = 'item'
var display_name
var dat
var col: int = 0
var layer: int
var pos
var prev_pos
var turns = 0
var hp = Vector2()
var host
var flash_state = [0, 0, 0, 0]

func get_display_name():
	if display_name == null:
		return item_name
	return display_name

func place(p):
	position = p.position
	pos = p
	p.add_item(self)

func remove():
	if host != null and is_instance_valid(host):
		host.on_item_remove(self)
	if n_healthbar != null:
		n_healthbar.queue_free()
	G.world.turn.remove(self)
	pos.remove_item(self)
	queue_free()

func show_healthbar():
	var vit = dat.g("vitality", 0)
	if vit > 0:
		if n_healthbar == null:
			n_healthbar = Healthbar.instance()
			add_child(n_healthbar)
		n_healthbar.set_mhp(vit)
		n_healthbar.set_hp(vit - dat.g("damage", 0))

func relocate(to):
	pos.remove_item(self)
	position = to.position
	prev_pos = pos
	to.add_item(self)

func move_world(wld):
	var x = pos.x
	var y = pos.y
	pos.remove_item(self)
	prev_pos = pos
	wld.tiles[y][x].add_item(self)

func on_turn():
	turns += 1
	if turns > dat.g("turn", 0):
		dat.run(self, "onturn")
		turns = 0

func _process(delta):
	if flash_state[0] > 0:
		var percent = flash_state[0] / flash_state[1]
		if flash_state[2] > 0:
			modulate.r = 1
			modulate.g = 1-flash_state[2]*percent
			modulate.b = modulate.g
		elif flash_state[3] > 0:
			modulate.r = 1-flash_state[3]*percent
			modulate.g = 1
			modulate.b = modulate.r
		flash_state[0] -= delta
	else:
		set_process(false)

func flash(c, dur):
	dur = max(.1, dur)
	flash_state = [dur, dur, 0, 0]
	flash_state[2 + c] = 1
	set_process(true)
