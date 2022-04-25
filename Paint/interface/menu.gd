extends Control

onready var n_deck = $Scroll/Container/Deck

func display(arg):
	rect_size = G.ui.screen_size
	if arg == "deck":
		update_cards()
	elif arg == "shop":
		update_shop()
	elif arg == "fight":
		update_fight()
	show()

func clear():
	for i in n_deck.get_children():
		i.queue_free()
		n_deck.remove_child(i)
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
		n_deck.add_child(card)
	$Scroll.grab_focus()

func update_fight():
	$Label.set_text("Choose 3")
	var cards = G.vars.mobs
	for card_name in cards:
		var card = G.factory.make_cardunit(null, card_name)
		card.connect("gui_input", self, "on_fight_card", [card])
		n_deck.add_child(card)
	$Scroll.grab_focus()

func on_shop_card(event, p):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("use"):
			p.toggle_selection()

func on_fight_card(event, p):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("use"):
			p.toggle_selection()
