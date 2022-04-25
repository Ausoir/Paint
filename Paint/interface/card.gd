extends Control

onready var tween = $Tween
var orig_pos
var orig_rot
var dat
var item_name
var mouse_over = false
var text

func _ready():
	remember()

func set_card(p):
	$Sprite.texture = p

func set_image(p):
	$Sprite/Image.texture = p

func set_title(p):
	item_name = p
	$Sprite/Title.set_text(p.capitalize())

func set_text(p):
	text = p
	$Sprite/Scroll/Description.set_bbcode(p)

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
	if !mouse_over:
		mouse_over = true
		tween.interpolate_property(self, "rect_scale",
			Vector2(1, 1), Vector2(1.2, 1.2), .5,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		tween.start()
		$Sprite.z_index = 2

func _on_mouse_exited():
	if mouse_over:
		tween.stop_all()
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

func toggle_selection():
	if dat.g("select", false) == true:
		on_deselected()
	else:
		on_selected()

func on_selected():
	tween.interpolate_property(self, "rect_rotation",
		0, 15, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	$Sprite/Selection.show()
	dat.a("select", true)

func on_deselected():
	tween.interpolate_property(self, "rect_rotation",
		15, 0, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	$Sprite/Selection.hide()
	dat.a("select", false)
