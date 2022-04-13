extends "res://interface/card.gd"

var health = 1
var block = 0
var attack = 0
var defense = 0
var battle
var deck
var unit
var next

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

func set_next():
	var skill = G.factory.make_card(null, deck.pop_front())
	next = skill
	next.rect_position.x = 160
	next.set_rotation_degrees(5)
	add_child(skill)

func damage(type, p):
	var dmg = p
	if type == "bash":
		dmg = max(0, p - block)
		block = max(0, block - p)
	elif type == "cut":
		if block > 0:
			dmg = 0
	health -= dmg
	if health <= 0:
		battle.run(unit.dat.g("onlethal"), self, self)
	set_text(text)

func die():
	queue_free()
