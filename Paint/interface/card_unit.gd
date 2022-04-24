extends "res://interface/card.gd"

var health = 1
var block = 0
var attack = 0
var defense = 0
var battle
var deck
var unit
var next
var last

func on_draw():
	pass

func on_turn():
	block = 0
	set_text(text)

func set_text(p):
	text = p
	var desc = "[b]Health: [color=red]"+str(health)+"[/color][/b]\n"
	if block != 0:
		desc += "[b]Block: [color=gray]"+str(block)+"[/color][/b]\n"
	if attack != 0:
		desc += "[b]Attack: [color=orange]"+str(attack)+"[/color][/b]\n"
	if defense != 0:
		desc += "[b]Defense: [color=brown]"+str(defense)+"[/color][/b]\n"
	$Sprite/Scroll/Description.set_bbcode(desc + text)

func change(variable, p):
	set(variable, get(variable)+p)
	set_text(text)

func set_deck(p):
	deck = p.duplicate()

func set_next(p=null):
	if p == null:
		if deck.empty():
			set_deck(unit.dat.g("deck"))
		p = G.factory.make_card(null, deck.pop_front())
	next = p
	next.rect_position.x = 160
	next.set_rotation_degrees(5)
	next.rect_pivot_offset.y = 240
	add_child(next)
	return next

func damage(type, p, hitter):
	var dmg = p
	if type == "bash":
		dmg = max(0, p - block)
		block = max(0, block - p)
	elif type == "cut":
		if block > 0:
			dmg = 0
	health -= dmg
	if health <= 0:
		if hitter != null:
			G.bcommand.run(hitter.last.dat.g("onkill"), hitter, self)
		G.bcommand.run(unit.dat.g("onlethal"), self, self)
	set_text(text)

func die():
	queue_free()
