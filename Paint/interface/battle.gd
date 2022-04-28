extends Control

const START = 0
const MAIN = 1
const TRANSITION = 2
const PAUSE = 3
onready var tween = $Tween
onready var n_player = $Player
onready var n_enemy = $Enemy
onready var n_hand = $Hand
onready var n_stamina = $Stamina
onready var n_pointer = $Pointer
onready var n_timer = $Timer
var discard = []
var forgot
var hand = [null, null, null, null]
var hand_orig_pos = [null,null,null,null]
var hand_orig_rot = [null,null,null,null]
var enemies = []
var turn = -1
var stamina: int
var target = -1
var state = START

func _ready():
	rect_size = G.ui.screen_size
	G.bcommand.battle = self
	G.world.turn.lockdown(4)
	G.factory.make_cardunit(n_player, G.you.unit.item_name)
	n_player.dat.combine(G.you.unit.dat)
	n_player.battle = self
	var mhp = G.you.unit.dat.g("vitality", 1)
	n_player.health = mhp #Override card health
	n_player.unit = G.you.unit
	n_player.damage("true", mhp - G.you.unit.dat.g("health", mhp), null)
	n_player.set_deck(G.you.unit.dat.g("deck"))
	n_player.deck.shuffle()
	reset_stamina()
	set_weapon(n_player.unit.dat.g("weapon"))
	draw()
	state = MAIN

func set_weapon(p):
	n_player.unit.dat.a("weapon", p)
	var wpn = p
	if wpn != null:
		n_player.set_next(G.factory.make_card(null, wpn))
		n_player.next.connect("gui_input", self, "_on_gui_input", [-1])

func add_enemy(enemy):
	var new = G.factory.make_cardunit(null, enemy.item_name)
	new.unit = enemy
	new.battle = self
	new.set_deck(enemy.dat.g("deck"))
	new.set_next()
	enemies.append(new)
	n_enemy.add_child(new)
	target = max(target, 0)

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
		elif Input.is_action_just_pressed("weapon"):
			deal(-1)

func add_stamina(p):
	stamina += p
	n_stamina.set_text(str(stamina))
	if stamina <= 0:
		on_turn()

func reset_stamina():
	stamina = n_player.unit.dat.g("stamina", 1) + 1

func draw():
	for finger in range(4):
		if hand[finger] == null:
			if n_player.deck.size() == 0:
				shuffle()
			var node = n_hand.get_child(finger)
			hand[finger] = n_player.deck.pop_front()
			G.factory.make_card(node, hand[finger])
			node.on_draw()
			if state == START:
				node.remember()
			else:
				node.recall()

func shuffle():
	if discard.size() == 0:
		n_player.deck = ["spirit"]
	else:
		n_player.deck = discard
		discard = []
		n_player.deck.shuffle()

func cycle():
	var max_target = enemies.size()
	if max_target > 1:
		target = (target + 1) % max_target

func verify_state():
	if n_player.health <= 0:
		set_result(-1)
		return false
	else:
		var new = []
		for enemy in enemies.duplicate():
			if enemy.health <= 0:
				state = PAUSE
				enemy.die()
				enemies.erase(enemy)
		if enemies.empty():
			set_result(1)
			return false
		elif target >= enemies.size():
			cycle()
		elif enemies[target].health <= 0:
			cycle()
		state = MAIN
	return true

func _on_tween_all_completed():
	if state == TRANSITION:
		clear()
	else:
		draw()
		for enemy in enemies:
			enemy.next.rect_position = Vector2(160, 0)
			enemy.next.modulate = Color.white

func on_turn():
	if state == MAIN:
		G.world.turn.lockdown(8)
		turn = min(turn, enemies.size() - 1)
		if turn >= 0:
			dealt(turn)
			turn -= 1
			if turn == -1:
				n_player.on_turn()
		elif turn == -1 and stamina <= 0:
			reset_stamina()
			add_stamina(0)
			turn = 99
			n_timer.start(.5)

func deal(p):
	if turn == -1 and stamina > 0:# and !tween.is_active():
		var node
		if p == -1:
			node = n_player.next
		elif hand[p] == null:
			return
		else:
			node = get_node("Hand/" + str(p))
			discard.append(hand[p])
			hand[p] = null
		var cardtype = node.dat.g("type")
		node.state = node.ANIMATION
		if cardtype == 2:
			tween.interpolate_property(node, "rect_global_position",
				node.rect_global_position, enemies[target].rect_global_position, .3,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
			tween.interpolate_property(node, "rect_rotation",
				node.rect_rotation, 360, .4,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
		else:
			tween.interpolate_property(node, "rect_rotation",
				node.rect_rotation, 360, .4,
				Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property(node, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), .4,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		add_stamina(-1)
		run_action(node, n_player, enemies[target])

func dealt(p):
	var enemy = enemies[p]
	var next = enemy.next
	var cardtype = next.dat.g("type")
	if cardtype == 1:
		tween.interpolate_property(next, "rect_rotation",
			next.rect_rotation, 360, .4,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
	else:
		tween.interpolate_property(next, "rect_global_position",
			next.rect_global_position, Vector2(0, G.ui.screen_size.y), .3,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(next, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), .4,
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	run_action(next, enemy, n_player)
	enemy.set_next()
	n_timer.start(.5)

func set_result(p):
	n_timer.queue_free()
	tween.stop_all()
	state = TRANSITION
	turn = -2
	if p == 1:
		G.you.unit.dat.a("health", n_player.health)
		n_player.state = n_player.ANIMATION
		tween.interpolate_property(n_player, "rect_scale",
			n_player.rect_scale, Vector2(4, 4), .5,
			Tween.TRANS_SINE, Tween.EASE_IN)
		tween.interpolate_property(n_player, "rect_position",
			n_player.rect_position, G.ui.screen_size/2, .5,
			Tween.TRANS_SINE, Tween.EASE_IN)
		tween.interpolate_property(n_player, "rect_rotation",
			n_player.rect_rotation, 720, .5,
			Tween.TRANS_SINE, Tween.EASE_IN)
	else:
		for child in n_hand.get_children():
			child.state = n_player.ANIMATION
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

func run_action(node, host, to):
	host.last = node
	var query = node.dat.g("onstart")
	var targets = get_targets(node.dat.g("type"), host, to)
	for i in targets:
		run(query, host, i)

func run(query, host, to):
	G.bcommand.run(query, host, to)
	verify_state()

func get_targets(type, host, to):
	var targets = []
	if type == 1:
		targets.append(host)
	elif type == 2:
		targets.append(to)
	elif type == 3:
		if host == n_player:
			for i in enemies:
				targets.append(i)
		else:
			targets.append(to)
	return targets

func clear():
	for i in get_children():
		i.queue_free()
	queue_free()
	G.ui.battle = null
	G.ui.clear()
	G.world.turn.lockdown(-1)
	if G.world.get_units().empty():
		G.ui.toggle_options(true)

func _process(_delta):
	if target != -1 and state == MAIN:
		var point_to = enemies[target].rect_global_position
		n_pointer.global_position.x += ((point_to.x + 80) - n_pointer.global_position.x)/12
		n_pointer.global_position.y += ((point_to.y + 240) - n_pointer.global_position.y)/12

func _on_timer():
	tween.stop_all()
	on_turn()
