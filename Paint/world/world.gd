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

func create(_map_name):
	map_name = _map_name
	var level = levels.get_node(_map_name)
	var level_background = level.get_child(0)
	image.set_texture(level_background.texture)
	var bounds = level.get_used_rect()
	width = bounds.size.x
	height = bounds.size.y
	tiles = []
	var spawns = []
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
					spawns.append(tile)
			elif t > 0:
				G.cmds([["make",ids[t],tile]])
			row.append(tile)
		tiles.append(row)
	for y in range(height):
		for x in range(width):
			apply_autotile(x, y)
	spawn(spawns)

func spawn(spawns):
	var ordered = []
	var ordered2 = []
	for tile in spawns:
		var dist = tile.x + tile.y
		var added = false
		for i in range(ordered.size()):
			if dist < ordered[i].x + ordered[i].y:
				ordered.insert(i, tile)
				ordered2.insert(i, dist)
				added = true
				break
		if !added:
			ordered.append(tile)
			ordered2.append(dist)
	var list = G.data.level_data.get(map_name)
	var third = ordered.size() / 3
	for i in range(ordered.size()):
		var unit
		if i < third:
			unit = G.data.get_combo(list[0])
		elif i < third * 2:
			unit = G.data.get_combo(list[1])
		else:
			unit = G.data.get_combo(list[2])
		if !unit.empty():
			G.cmds([["make", unit[0], ordered[i]]])

func apply_autotile(x, y):
	var pos = tiles[y][x]
	if pos.autotile == 1:
		var dirs = []
		for i in range(4):
			var adj = pos.get_adjacent(i * 2)
			if adj.height == pos.height:
				dirs.append(i)
		var v = G.get_autotile_coord(dirs)
		var tileid = tilemap.get_cell(x, y)
		tilemap.set_cell(x, y, tileid, false, false, false, v)
	for item in pos.items:
		item.autotilize()

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
