const Item = preload("res://objects/item.gd")
const Unit = preload("res://objects/Unit.tscn")
const Card = preload("res://interface/Card.tscn")
const Sprite_Unit = preload("res://assets/image/card2.png")
const Script_Unit = preload("res://interface/card_unit.gd")
const Script_Card = preload("res://interface/card.gd")
const Properties = preload("res://classes/properties.gd")

func make_cardunit(card, arg):
	var card_data = G.data.unit_data.get(arg)
	if card_data != null:
		var r
		if card == null:
			r = Card.instance()
		else:
			r = card
		r.set_script(Script_Unit)
		r.get_node("Sprite").texture = Sprite_Unit
		var sprite = G.data.get_image(card_data.get("img", "blank"))
		r.set_title(arg)
		r.health = int(card_data.get("vitality", 1))
		r.set_text(card_data.get("desc", ""))
		r.set_image(sprite)
		r.dat = Properties.new(card_data)
		return r

func make_card(card, arg):
	var card_data
	card_data = G.data.card_data.get(arg)
	if card_data != null:
		var r
		if card == null:
			r = Card.instance()
		else:
			r = card
		r.set_script(Script_Card)
		var sprite = G.data.get_image(card_data.get("img", "blank"))
		r.set_title(arg)
		r.set_text(card_data.get("desc", ""))
		r.set_image(sprite)
		r.dat = Properties.new(card_data)
		return r

func make_unit(arg, pos):
	var unit_data = G.data.unit_data.get(arg)
	if unit_data != null:
		var r = Unit.instance()
		var sprite = G.data.get_image(unit_data.img)
		if !sprite:
			return
		r.set_texture(sprite)
		r.item_name = arg
		r.item_type = "unit"
		r.dat = Properties.new(unit_data)
		r.place(pos)
		G.world.items.add_child(r)
		G.world.turn.add(r)
		r.dat.run(r, "onmake")
		r.possess()
		return r

func make_item(arg, pos=null):
	var item_data = G.data.item_data.get(arg)
	if item_data != null:
		var img = item_data.get("img")
		var r = Sprite.new()
		if img != null:
			G.data.set_sprite_texture(r, img, item_data.get("autotile", 0))
			if r.texture != null:
				if !r.region_enabled:
					var img_size = r.texture.get_size()
					if img_size.y > G.H:
						r.offset.y = -int((img_size.y - G.H) / 2)
		r.set_script(Item)
		r.item_name = arg
		r.item_type = "item"
		r.dat = Properties.new(item_data)
		r.set_col(r.dat.g("col", 0))
		if pos != null:
			r.place(pos)
		G.world.items.add_child(r)
		if r.dat.g("onturn") != null:
			G.world.turn.add(r)
		r.dat.run(r, "onmake")
		return r

func make_particle(arg, pos):
	var r = G.data.get_particle(arg)
	r.global_position = pos
	r.add()
	return r

func make_corpse(host, pos):
	var r = G.data.get_particle("Corpse")
	r.item_name = "corpse"
	r.item_type = "item"
	r.make(host)
	var item_data = G.data.unit_data.get("corpse")
	if item_data != null:
		r.dat = G.factory.Properties.new(item_data)
	if pos != null:
		r.place(pos)
	G.world.turn.add(r)
	return r
