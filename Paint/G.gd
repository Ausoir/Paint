extends Node

const W = 32
const H = 32
const HW = 16
const HH = 16
const OCTANT_FLIP = [[1, 0, 0, 1], [0, 1, 1, 0], [0, -1, 1, 0], [-1, 0, 0, 1], \
	[-1, 0, 0, -1], [0, -1, -1, 0], [0, 1, -1, 0], [1, 0, 0, -1]]
const CARDINALS = [[0,-1],[1,0],[0,1],[-1,0]]
const DIRS = [[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1]]
const UP = 0
const UPRIGHT = 1
const RIGHT = 2
const DOWNRIGHT = 3
const DOWN = 4
const DOWNLEFT = 5
const LEFT = 6
const UPLEFT = 7

const Player = preload("res://objects/Player.tscn")
const Damage_Label = preload("res://fx/particles/Damage_Label.tscn")
const Gfx = preload("res://fx/Gfx.tscn")
var sfx = preload("res://fx/Sfx.tscn").instance()
var influence = preload("res://objects/influence.gd").new()
var data = preload("res://classes/json.gd").new()
var factory = preload("res://classes/factory.gd").new()
var world = preload("res://world/World.tscn").instance()
var ui = preload("res://interface/Interface.tscn").instance()
var command = load("res://classes/command.gd").new()
var bcommand = preload("res://classes/bcommand.gd").new()
var events = []
var vars = {}
var temp = {}
var you
var interval = .25


func _ready():
	set_process(false)

func start():
	var root = get_tree().get_root()
	root.add_child(ui)
	root.add_child(world)
	set_process(true)

func _process(_delta):
	interval -= _delta
	if interval <= 0:
		world.turn.process_frames += 1
		interval = .125
	world.turn.on_process()

func pixel_to_pos(pos):
	return Vector2(pos.x / W, pos.y / H).floor()

func pos_to_pixel(pos):
	return Vector2(pos.x*W+HW, pos.y*H+HH)

func vector_to_dir(x, y):
	var count = 0
	for i in DIRS:
		if i[0] == x and i[1] == y:
			return count
		count += 1
	return -1

func get_autotile_coord(dirs):
	var v
	if dirs.empty():
		v = Vector2()
	else:
		if dirs == [0]:
			v = Vector2(0, 3)
		elif dirs == [1]:
			v = Vector2(1, 0)
		elif dirs == [2]:
			v = Vector2(0, 1)
		elif dirs == [3]:
			v = Vector2(3, 0)
		elif dirs == [0, 1]:
			v = Vector2(1, 3)
		elif dirs == [0, 2]:
			v = Vector2(0, 2)
		elif dirs == [0, 3]:
			v = Vector2(3, 3)
		elif dirs == [1, 2]:
			v = Vector2(1, 1)
		elif dirs == [1, 3]:
			v = Vector2(2, 0)
		elif dirs == [2, 3]:
			v = Vector2(3, 1)
		elif dirs == [0, 1, 2]:
			v = Vector2(1, 2)
		elif dirs == [0, 1, 3]:
			v = Vector2(2, 3)
		elif dirs == [0, 2, 3]:
			v = Vector2(3, 2)
		elif dirs == [1, 2, 3]:
			v = Vector2(2, 1)
		elif dirs == [0, 1, 2, 3]:
			v = Vector2(2, 2)
		else:
			v = Vector2()
	return v

func get_direction_between(from, to):
	var tx = from.x - to.x
	var ty = from.y - to.y
	if tx == 0 and ty == 0:
		return -1
	var dir
	var angle = atan2(ty, tx) + PI
	var octant = int(angle / .3927)
	if octant == 15 or octant == 0:
		dir = LEFT
	elif octant == 1 or octant == 2:
		dir = UPLEFT
	elif octant == 3 or octant == 4:
		dir = UP
	elif octant == 5 or octant == 6:
		dir = UPRIGHT
	elif octant == 7 or octant == 8:
		dir = RIGHT
	elif octant == 9 or octant == 10:
		dir = DOWNRIGHT
	elif octant == 11 or octant == 12:
		dir = DOWN
	elif octant == 13 or octant == 14:
		dir = DOWNLEFT
	return dir

func is_vec_in_range(pos):
	var dist = pos - you.n_camera.position
	var length = max(abs(dist.x), abs(dist.y))
	return length/H < you.n_camera.sight_range

func is_vec_visible(p):
	var pos = pixel_to_pos(p)
	var tile = world.get_tile(pos.x, pos.y)
	return tile != null and tile.visible

func display_damage(val, pos, color=Color.white, _scale=1, _speed=800, lifetime=100):
	if is_vec_visible(pos):
		var r = Damage_Label.instance()
		r.lifetime = lifetime
		r.rect_position = pos
		r.rect_position.y -= HH
		world.others.add_child(r)
		r.set_damage(str(val), color, _scale, _speed)

func cmds(p, host=null, tgt=null):
	return command.run(p, host, tgt)

func travel(_map):
	world.create(_map)
	world.others.add_child(sfx)
	if you.get_parent() != null:
		you.get_parent().remove_child(you)
	world.players.add_child(you)
	if you.unit != null:
		you.unit.move_world(world)

func save_game(_map="city"):
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_list = [you]
	vars["map"] = _map
	vars["seed"] = R.init_seed
	save_game.store_line(to_json(vars))
	for to_save in save_list:
		var node_data = to_save.save_data()
		save_game.store_line(to_json(node_data))
	save_game.close()

func load_game():
	var r = false
	var save_game = File.new()
	var node_data
	var save_exists = save_game.file_exists("user://savegame.save")
	if save_exists:
		save_game.open("user://savegame.save", File.READ)
		node_data = parse_json(save_game.get_line())
	if node_data == null:
		save_game.close()
		save_game = File.new()
		save_game.open("res://assets/template.save", File.READ)
		node_data = parse_json(save_game.get_line())
	you = Player.instance()
	vars = node_data
	R.set_seed(vars.seed)
	travel(node_data.map)
	while save_game.get_position() < save_game.get_len():
		node_data = parse_json(save_game.get_line())
		you.load_data(node_data)
		r = true
	save_game.close()
	return r
