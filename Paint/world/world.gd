extends Node

const Turn = preload("res://classes/turn.gd")
const Generator = preload("res://world/generator.gd")
var tileset = preload("res://assets/tileset.tres")
var turn = Turn.new()
var width
var height
var terrain
var sound
var tiles

onready var tilemap = $Tilemap
onready var items = $Items
onready var players = $Players
onready var others = $Others
var map_name: String

func create(_type):
	map_name = _type
	var _t = Generator.new(_type)
	tilemap.update_bitmask_region(Vector2(), Vector2(width, height))
	$Borders.position = Vector2(width * G.HW, height * G.HH)
	$Borders/Left.position = Vector2(width * -G.HW - 4, 0)
	$Borders/Right.position = Vector2(width * G.HW + 4, 0)
	$Borders/Top.position = Vector2(0, height * -G.HH - 4)
	$Borders/Bottom.position = Vector2(0, height * G.HH + 4)

func get_items_by_name(p):
	var r = []
	for y in range(height):
		for x in range(width):
			for item in tiles[y][x].items:
				if item.item_name == p and is_instance_valid(item):
					r.append(item)
	return r

func get_tile(x, y):
	if is_inbound(x, y):
		return tiles[y][x]

func from_vec(v):
	var x = int(v.x / G.W)
	var y = int(v.y / G.H)
	return tiles[y][x]

func set_terrain(x, y, val):
	tiles[y][x].set_terrain(val)

func add_item(x, y, val):
	tiles[y][x].items.append(val)

func is_inbound(x, y):
	return x >= 0 and x < width and y >= 0 and y < height

func fit_bound(x, y):
	return tiles[clamp(y, 0, height-1)][clamp(x, 0, width-1)]

func get_routes(pos):
	var r = []
	for i in G.CARDINALS:
		var ty = pos.y + i[1]
		var tx = pos.x + i[0]
		if is_inbound(tx, ty) and !tiles[ty][tx].is_col(12):
			r.append(i)
	return r
