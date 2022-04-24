extends CanvasLayer

const BuffSlot = preload("res://interface/BuffSlot.tscn")
const Battle = preload("res://interface/Battle.tscn")
onready var menu = $Control/Menu
onready var dialog = $Control/Dialog
onready var tint = $Control/Tint
onready var description = $Control/Description
onready var buffs = $Control/Status
var screen_size
var screen_ratio
var mouse_pos = Vector2()
var on = false
var battle

func _ready():
	screen_size = get_viewport().get_size_override()
	screen_ratio = screen_size / get_viewport().size
	fadein()
	tint.get_stylebox("panel", "").set_bg_color(Color(0,0,0, .7))

func fadein():
	$AnimationPlayer/Fade.set_size(screen_size)
	$AnimationPlayer.play("FadeIn")

func _process(_delta):
	$FPS.set_text(str(Engine.get_frames_per_second())+' FPS')

func _unhandled_input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("quit"):
			get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
		elif Input.is_action_just_pressed("ui_fullscreen"):
			OS.window_fullscreen = !OS.window_fullscreen
		elif Input.is_action_just_pressed("menu"):
			if on:
				clear()
			else:
				G.cmds([["menu", "menu"]], G.you.unit)
		else:
			G.you._on_input(event)
	elif !on:
		G.you._on_input(event)

func display_dialog(_page, _host):
	tint.set_size(screen_size)
	tint.show()
	dialog.display(_page, _host)
	dialog.rect_position = screen_size / 2 - dialog.rect_size / 2
	on = true

func display_menu():
	if !on:
		on = true
		tint.set_size(screen_size)
		tint.show()
		menu.display()

func display_battle(arg):
	if on and battle == null:
		clear()
	on = true
	tint.set_size(screen_size)
	tint.show()
	arg.is_engaged = true
	if battle == null:
		battle = Battle.instance()
		$Control.add_child_below_node(menu, battle)
		battle.add_enemy(arg)
	elif battle.state == 0:
		battle.add_enemy(arg)

func clear():
	if battle == null:
		on = false
		menu.clear()
		tint.hide()
		description.hide()
		dialog.hide()

func describe(type, header, subject=null):
	if !description.visible:
		if header != null:
			description.display(type, header, subject)
