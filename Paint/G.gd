extends Node

const W = 32
const H = 32
const HW = 16
const HH = 16
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

func display_damage(val, pos, color=Color.white, _scale=1, _speed=800, lifetime=100):
	var r = Damage_Label.instance()
	r.lifetime = lifetime
	r.rect_position = pos
	r.rect_position.y -= HH
	world.others.add_child(r)
	r.set_damage(str(val), color, _scale, _speed)

func cmds(p, host=null, tgt=null):
	return command.run(p, host, tgt)

func replace_vars(arg, fn):
	var last = arg.find("}")
	if last != -1:
		var r = ""
		var v = ""
		var on = false
		var once = last == len(arg) - 1 and arg[0] == "{"
		for i in arg:
			if i == "{":
				on = true
			elif i == "}":
				var t = fn.call_func(v)
				if once:
					return t
				r += str(t)
				v = ""
				on = false
			elif on:
				v += i
			else:
				r += i
		return r
	return arg

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
	G.ui.money.display(0)
	R.set_seed(vars.seed)
	travel(node_data.map)
	while save_game.get_position() < save_game.get_len():
		node_data = parse_json(save_game.get_line())
		you.load_data(node_data)
		r = true
	save_game.close()
	return r
