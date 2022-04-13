extends Control

const VICTORY = 1
const DEFEAT = 2
const TRANSITION = 3
onready var tween = $Tween
onready var n_player = $Player
onready var n_enemy = $Enemy
onready var n_hand = $Hand
onready var n_stamina = $Stamina
onready var n_pointer = $Pointer
onready var n_timer = $Timer
var cmd = preload("res://interface/interaction.gd").new()
var discard = []
var forgot
var hand = [null, null, null, null]
var hand_orig_pos = [null,null,null,null]
var hand_orig_rot = [null,null,null,null]
var turn = -1
var stamina = 3
var target = null
var state = 0

func _ready():
	rect_size = G.ui.screen_size
	G.world.turn.lockdown(0)
	G.factory.make_cardunit(n_player, G.you.unit.item_name)
	var mhp = G.you.unit.dat.g("vitality", 1)
	n_player.battle = self
	n_player.unit = G.you.unit
	n_player.damage("true", mhp - G.you.unit.dat.g("health", mhp))
	n_player.set_deck(G.you.unit.dat.g("deck"))
	n_player.deck.shuffle()
	draw()

func add_enemy(enemy):
	var new = G.factory.make_cardunit(null, enemy.item_name)
	new.unit = enemy
	new.battle = self
	new.set_deck(enemy.dat.g("deck"))
	new.set_next()
	n_enemy.add_child(new)
	if target == null:
		target = new

func _on_gui_input(event, card):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("use"):
			deal(card)

func _unhandled_input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("deal1"):
			deal(0)
		elif Input.is_action_just_pressed("deal2"):
			deal(1)
		elif Input.is_action_just_pressed("deal3"):
			deal(2)
		elif Input.is_action_just_pressed("deal4"):
			deal(3)

func add_stamina(p):
	stamina += p
	n_stamina.set_text(str(stamina))
	if stamina <= 0:
		on_turn()

func draw():
	for finger in range(4):
		if hand[finger] == null:
			if n_player.deck.size() == 0:
				shuffle()
			var node = n_hand.get_child(finger)
			node.modulate = Color.white
			hand[finger] = n_player.deck.pop_front()
			G.factory.make_card(node, hand[finger])
			node.recall()
			node.on_draw()

func shuffle():
	if discard.size() == 0:
		n_player.deck = ["filler"]
	else:
		n_player.deck = discard
		discard = []
		n_player.deck.shuffle()

func verify_state():
	if n_player.health <= 0:
		state = DEFEAT
		defeat()
		return false
	else:
		for enemy in n_enemy.get_children():
			if enemy.health <= 0:
				enemy.unit.die()
				enemy.queue_free()
				n_enemy.remove_child(enemy)
		var enemy_num = n_enemy.get_child_count()
		if enemy_num == 0:
			state = VICTORY
			win()
			return false
		elif target.health <= 0:
			target = n_enemy.get_child(0)
	return true

func _on_tween_all_completed():
	if state == TRANSITION:
		clear()
	else:
		draw()
		for enemy in n_enemy.get_children():
			enemy.next.rect_position = Vector2(160, 0)
			enemy.next.modulate = Color.white

func on_turn():
	if state == 0:
		G.world.turn.lockdown(8)
		if turn >= 0:
			dealt(turn)
			turn -= 1
		elif turn == -1 and stamina <= 0:
			stamina = 3
			add_stamina(0)
			turn = n_enemy.get_child_count() - 1
			n_player.on_turn()
			n_timer.start(.5)

func deal(p):
	if turn == -1 and stamina > 0 and hand[p] != null:
		var node = get_node("Hand/" + str(p))
		var to = target.rect_global_position
		if node.dat.g("type") == "target":
			tween.interpolate_property(node, "rect_global_position",
				node.rect_global_position, to, .3,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.interpolate_property(node, "rect_rotation",
				node.rect_rotation, 360, .4,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property(node, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), .4,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		discard.append(hand[p])
		hand[p] = null
		add_stamina(-1)
		run(node.dat.g("onstart"), n_player, target)

func dealt(p):
	var enemy = n_enemy.get_child(p)
	var next = enemy.next
	tween.interpolate_property(next, "rect_global_position",
		next.rect_global_position, Vector2(0, G.ui.screen_size.y), .3,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(next, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), .4,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	run(next.dat.g("onstart"), enemy, n_player)
	n_timer.start(.5)

func win():
	state = TRANSITION
	turn = -2
	G.you.unit.dat.a("health", n_player.health)
	tween.interpolate_property(n_player, "rect_scale",
		n_player.rect_scale, Vector2(4, 4), .5,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.interpolate_property(n_player, "rect_position",
		n_player.rect_position, G.ui.screen_size/2, .5,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.interpolate_property(n_player, "rect_rotation",
		n_player.rect_rotation, 720, .5,
		Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func defeat():
	state = TRANSITION
	turn = -2
	for child in n_hand.get_children():
		tween.interpolate_property(child, "rect_scale",
			child.rect_scale, Vector2(.1, .1), 1.5,
			Tween.TRANS_CIRC, Tween.EASE_IN)
		tween.interpolate_property(child, "rect_position",
			child.rect_position, G.ui.screen_size/2, 1.5,
			Tween.TRANS_SINE, Tween.EASE_IN)
		tween.interpolate_property(child, "rect_rotation",
			child.rect_rotation, -360, 1.5,
			Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func run(p, host, to):
	if p != null:
		cmd.run(p, host, to)
		verify_state()

func clear():
	for i in get_children():
		i.queue_free()
	queue_free()
	G.ui.battle = null
	G.ui.clear()
	G.world.turn.lockdown(-1)

func _process(_delta):
	if target != null:
		var point_to = target.rect_global_position
		n_pointer.global_position.x += ((point_to.x + 80) - n_pointer.global_position.x)/12
		n_pointer.global_position.y += ((point_to.y + 240) - n_pointer.global_position.y)/12

func _on_timer():
	on_turn()
