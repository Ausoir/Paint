extends Control

const IDLE = 0
const ANIMATION = 1
var orig_pos
var orig_rot
var dat
var item_name
var state = IDLE
var mouse_over = false
var text
var price = 0
var selected = false
var holder

func set_card(p):
	$Sprite.texture = p

func set_image(p):
	$Sprite/Image.texture = p

func set_title(p):
	item_name = p
	$Sprite/Title.set_text(p.capitalize())

func set_text(p):
	text = p
	var r = G.replace_vars(p, funcref(self, "replace_texts"))
	$Sprite/Scroll/Description.set_bbcode(r)

func set_price(prefix, p=-1):
	if p == -1:
		var rank = 5 << int(dat.g("rank", 1))
		price = R.ir(rank, rank*2)
	else:
		price = p
	$Sprite/Price.set_text(prefix+str(price))
	$Sprite/Price.show()

func on_draw():
	pass

func remember():
	orig_pos = rect_position
	orig_rot = rect_rotation

func recall():
	rect_position = orig_pos
	rect_rotation = orig_rot
	modulate = Color.white

func gfx(p):
	var fx = G.data.get_particle(p)
	fx.set_emitting(true)
	fx.position = Vector2(80, 80)
	add_child(fx)

func _on_mouse_entered():
	if state == IDLE and !mouse_over:
		mouse_over = true
		$Tween.interpolate_property(self, "rect_scale",
			Vector2(1, 1), Vector2(1.2, 1.2), .5,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()
		$Sprite.z_index = 2

func _on_mouse_exited():
	if state == IDLE and mouse_over:
		$Tween.stop_all()
		mouse_over = false
		rect_scale = Vector2(1, 1)
		G.ui.description.hide()
		$Sprite.z_index = 0

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_action_pressed("move"):
			if G.ui.description.visible:
				G.ui.description.hide()
			else:
				G.ui.describe("card", item_name)

func on_selected():
	$Tween.interpolate_property(self, "rect_rotation",
		0, 15, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	$Sprite/Selection.show()
	selected = true

func on_deselected():
	$Tween.interpolate_property(self, "rect_rotation",
		15, 0, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	$Sprite/Selection.hide()
	selected = false

func replace_texts(v):
	var r
	var split = v.split(":")
	if split[0] == "burn":
		r = texttype(split[1],"red")
	elif split[0] == "bash" or split[0] == "cut":
		r = texttype(split[1],"red","attack")
	elif split[0] == "block":
		r = texttype(split[1],"gray","defense")
	elif split[0] == "heal":
		r = texttype(split[1],"green")
	return r

func texttype(v,color,q=null,mod=1):
	if holder == null:
		return "[color="+color+"]"+v+"[/color]"
	else:
		var t = str(int(v) + holder.get(q)*mod)
		return "[color="+color+"]"+t+"[/color]"
