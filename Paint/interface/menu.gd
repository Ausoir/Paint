extends Control

onready var n_deck = $Scroll/Deck

func _background_input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			G.ui.clear()

func display():
	rect_size = G.ui.screen_size
	update_cards()
	show()

func clear():
	for i in n_deck.get_children():
		i.queue_free()
		n_deck.remove_child(i)
	hide()

func update_cards():
	var cards = G.you.unit.dat.g("deck", [])
	for card_name in cards:
		var card = G.factory.make_card(null, card_name)
		n_deck.add_child(card)
