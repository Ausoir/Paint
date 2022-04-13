extends Node

var current = -1
var nodes
var size
var open

func _ready():
	nodes = []
	open = []
	size = get_child_count()
	for i in range(size):
		open.append(i)
		var node = get_node(str(i))
		nodes.append(node)
		node.connect("finished", self, "on_finished", [i])

func play(sound):
	if nodes != null:
		var player = nodes[find_player()]
		player.set_stream(G.data.get_sound(sound))
		player.play(0)

func find_player():
	if open.empty():
		current += 1
		if current >= size:
			current = 0
		return current
	return open.pop_front()

func on_finished(p):
	open.append(p)
