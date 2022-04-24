extends "res://objects/controller.gd"

onready var n_camera = $Camera
onready var n_cursor = $Cursor

var p_id: int
var p_name: String
var last_pos

func on_assign():
	.on_assign()
	last_pos = unit.pos
	$Camera/Area2D/CollisionShape2D.shape.radius = unit.get_node("Body/CollisionShape2D").shape.radius + G.HW

func _on_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var mouse_pos = get_cursor_position(event.global_position)
		n_cursor.position = G.pos_to_pixel(G.pixel_to_pos(mouse_pos))
	elif event is InputEventMouseButton:
		var mouse_pos = get_cursor_position(event.global_position)
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_UP:
				if n_camera.zoom.x > .5:
					n_camera.zoom *= .9
			elif event.button_index == BUTTON_WHEEL_DOWN:
				if n_camera.zoom.x < .5 + (unit.dat.g("perception", 8) * .05):
					n_camera.zoom *= 1.1
			elif event.button_index == BUTTON_MIDDLE: #Teleport to cursor
				pass
			elif Input.is_action_just_pressed("move"):
				var mousetarget = G.pixel_to_pos(mouse_pos)
				var t = G.world.get_tile(mousetarget.x, mousetarget.y)
				if t != null:
					move_to(t)

func get_cursor_position(mouse):
	var screen_mouse = mouse * G.ui.screen_ratio
	screen_mouse -= G.ui.screen_size / 2
	return Vector2(screen_mouse.x*n_camera.zoom.x + n_camera.position.x,
					screen_mouse.y*n_camera.zoom.y + n_camera.position.y)

func _physics_process(_delta):
	n_camera.position = unit.n_collider.global_position
	if unit.delay == 0 and !G.ui.on:
		var dir = -1
		if Input.is_action_pressed("move_up"):
			if Input.is_action_pressed("move_left"):
				dir = 7
			elif Input.is_action_pressed("move_right"):
				dir = 1
			else:
				dir = 0
		elif Input.is_action_pressed("move_down"):
			if Input.is_action_pressed("move_left"):
				dir = 5
			elif Input.is_action_pressed("move_right"):
				dir = 3
			else:
				dir = 4
		elif Input.is_action_pressed("move_right"):
			dir = 2
		elif Input.is_action_pressed("move_left"):
			dir = 6
		if dir != -1:
			tasks = [["move", dir]]
		elif unit.n_collider.vel != Vector2.ZERO and tasks.empty():
			unit.set_animation("idle")

func _on_collision(body):
	if G.world.turn.lock_timer != 0:
		if body != unit.n_collider and body is KinematicBody2D:
			var node = body.get_parent()
			if node.item_type == "unit" and !node.is_engaged:
				G.cmds([["menu", "battle", node]])

func on_item_click(item): #runs after _unhandled_input
	if tasks.empty():
		tasks.append(["interact", item])
	elif tasks.size() == 1 and tasks[0][0] == "interact":
		tasks[0][1] = item

func on_hit(_hitter):
	if _hitter != null and target == null:
		target = _hitter

func interact(item):
	if !G.ui.on:
		var oninteract = item.dat.g("oninteract")
		if oninteract != null:
			G.cmds(oninteract, item, unit)

func move_to(tile):
	var distance = unit.pos.distance_to(tile)
	if distance <= 1:
		return unit.pos
	elif distance == 1:
		tasks = [["smash", tile]]
		return unit.pos
	path_to(tile)

func remove():
	if unit.get_health() <= 0:
		G.cmds([["menu","dialog","Death"]])

func save_data():
	var save_dict = {
		"id": p_id,
		"unit": unit.item_name,
		"unit_data": unit.dat.v,
		"position": unit.pos.to_array()
	}
	return save_dict

func load_data(_data):
	var player_pos = G.world.tiles[_data.position[1]][_data.position[0]]
	var player_unit = G.cmds([["make", _data.unit, player_pos]])
	player_unit.dat.load_data(_data.unit_data)
	player_unit.possess(self)
