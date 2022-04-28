extends Node

const Turn = preload("res://world/turn.gd")
const Tile = preload("res://world/tile.gd")
var tileset = preload("res://assets/tileset.tres")
var levels = preload("res://world/Levels.tscn").instance()
var turn = Turn.new()
var width
var height
var terrain
var sound
var tiles

onready var tilemap = $Tilemap
onready var image = $Sprite
onready var items = $Items
onready var players = $Players
onready var others = $Others
var map_name: String
var spawn_points
var units = []

func create(_map_name):
	map_name = _map_name
	G.vars["shop"] = G.data.get_random_cards(3)
	G.vars["mobs"] = G.data.get_random_units(12)
	var level = levels.get_node(_map_name)
	var level_background = level.get_child(0)
	image.set_texture(level_background.texture)
	var bounds = level_background.get_rect().size
	width = bounds.x / G.W
	height = bounds.y / G.H
	tiles = []
	spawn_points = []
	var ids = {}
	for i in range(tileset.get_last_unused_tile_id()):
		ids[i] = tileset.tile_get_name(i)
	for y in range(height):
		var row = []
		for x in range(width):
			var tile = Tile.new(self, x, y)
			var t = level.get_cell(x, y)
			if t > 3:
				if ids[t] == "enemy":
					spawn_points.append(tile)
			elif t > 0:
				G.cmds([["make",ids[t],tile]])
			row.append(tile)
		tiles.append(row)

func spawn(p):
	for i in p.size():
		var tile = spawn_points[i % spawn_points.size()]
		var unit = G.cmds([["make", p[i], tile]])
		unit.controller.target = G.you.unit
		units.append(unit)

func get_units():
	var r = []
	for i in units:
		if i != null and is_instance_valid(i):
			r.append(i)
	return r

func get_tile(x, y):
	if is_inbound(x, y):
		return tiles[y][x]

func from_vec(v):
	var x = int(v.x / G.W)
	var y = int(v.y / G.H)
	return tiles[y][x]

func is_inbound(x, y):
	return x >= 0 and x < width and y >= 0 and y < height

func get_routes(pos):
	var r = []
	for i in G.CARDINALS:
		var ty = pos.y + i[1]
		var tx = pos.x + i[0]
		if is_inbound(tx, ty) and !tiles[ty][tx].is_col(12):
			r.append(i)
	return r
