extends Control

onready var n_deck = $Scroll/Container/Deck
var selected = []

func display(arg):
	rect_size = G.ui.screen_size
	if arg == "deck2":
		update_cards()
	elif arg == "deck":
		G.ui.clear()
		G.cmds([["make","pudding","$pp"],["menu","battle","$t"]])
	elif arg == "shop":
		update_shop()
	elif arg == "fight":
		update_fight()
	show()

func clear():
	for i in n_deck.get_children():
		i.queue_free()
		n_deck.remove_child(i)
	selected.clear()
	hide()

func update_cards():
	$Label.set_text("Deck")
	var cards = G.you.unit.dat.g("deck", [])
	for card_name in cards:
		var card = G.factory.make_card(null, card_name)
		n_deck.add_child(card)

func update_shop():
	$Label.set_text("Shop")
	var cards = G.vars.shop
	for card_name in cards:
		var card = G.factory.make_card(null, card_name)
		card.connect("gui_input", self, "on_shop_card", [card])
		card.set_price("$")
		n_deck.add_child(card)
	for i in [["random", 200],["sleep", 100],["heal", 100]]:
		var card = G.factory.make_card(null, i[0])
		card.connect("gui_input", self, "on_shop_card", [card])
		card.set_price("$", i[1])
		n_deck.add_child(card)
	$Scroll.grab_focus()

func update_fight():
	$Label.set_text("Choose 3")
	var cards = G.vars.mobs
	for card_name in cards:
		var card = G.factory.make_cardunit(null, card_name)
		card.connect("gui_input", self, "on_fight_card", [card])
		card.set_price("+$")
		n_deck.add_child(card)
	$Scroll.grab_focus()

func on_shop_card(event, p):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("use"):
			if G.cmds([["buy",p.price]]):
				G.vars.shop.erase(p.item_name)
				G.you.unit.dat.g("deck").append(p.item_name)
				G.ui.clear()

func on_fight_card(event, p):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("use"):
			if p.selected:
				G.cmds([["buy",p.price]])
				selected.erase(p.item_name)
				p.on_deselected()
			else:
				G.cmds([["buy",-p.price]])
				selected.append(p.item_name)
				p.on_selected()
				if selected.size() >= 3:
					var r = []
					for i in selected:
						G.vars.mobs.erase(i)
						r.append(i)
					for _i in range(min(3, G.vars.mobs.size())):
						G.vars.mobs.pop_front()
					G.world.spawn(r)
					G.ui.clear()
					G.ui.toggle_options(false)
