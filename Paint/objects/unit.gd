extends "res://objects/item.gd"

const Ai = preload("res://objects/ai.gd")
const Buffs = preload("res://objects/buffs.gd")
const SPEED = 10

onready var n_sprites = $Sprites
onready var n_animation = $Animation
onready var n_sprite = $Sprites/Sprite
onready var n_skeleton = $Skeleton2D

var delay = 0

var is_dead = false
var is_engaged = false
var controller
var cooldowns = {}
var buffs = Buffs.new(self)
var current_action = ""
var weapon_name: String

func _ready():
	n_collider = get_node("Body")
	n_collider.parent = self
	possess()

func set_texture(p):
	var r_sprite = get_node("Sprites/Sprite")
	var img_size = p.get_size()
	var x = img_size.x
	var y = img_size.y
	var x2 = img_size.x/2
	var y2 = img_size.y/2
	r_sprite.offset.x = -int(img_size.x) / 2
	r_sprite.offset.y = -int(img_size.y) + 16
	var uv = PoolVector2Array([
		Vector2(0,0),Vector2(x2,0),Vector2(x,0),Vector2(x,y2),
		Vector2(x,y),Vector2(x2,y),Vector2(0,y),Vector2(0,y2)
	])
	r_sprite.texture = p
	r_sprite.set_uv(uv)
	r_sprite.set_polygon(uv)

func possess(ctlr = null):
	if ctlr == null:
		ctlr = Ai.new()
	else:
		ctlr.unassign()
	if controller != null:
		controller.remove()
		controller = null
	controller = ctlr
	ctlr.unit = self
	ctlr.on_assign()

func reposition(p):
	position = p
	on_slide()

func place(p):
	.place(p)
	n_collider.check_overlap()

func slide(toward):
	var ms = dat.g("move speed", 0)
	if ms > 0:
		ms = max(.2, ms * pos.slow)
		n_animation.play("walk", -1, ms / 4)
		var deg = atan2(toward.y-position.y, toward.x-position.x)
		var vx = cos(deg)
		var vy = sin(deg)
		if vx > .1:
			face(1)
		elif vx < -.1:
			face(-1)
		ms *= SPEED
		n_collider.vel.x += vx * ms
		n_collider.vel.y += vy * ms
	return on_slide()

func on_slide():
	var newpos = pos.world.from_vec(position)
	if newpos != pos:
		pos.remove_item(self)
		newpos.add_item(self)

func set_animation(p, spd=0):
	current_action = p
	if spd > 0:
		n_animation.play(p, -1, 1/(spd*.15))
	else:
		n_animation.play(p)

func get_health():
	var vit = dat.g("vitality", -1)
	if vit == -1:
		return 1
	elif vit == 0:
		return 0
	var hurt = dat.g("damage", 0)
	return 1 - (hurt / vit)

func on_turn():
	if is_dead:
		die()
	else:
		if delay == 0:
			if controller != null:
				controller.on_turn()
		else:
			if delay > 0:
				delay -= 1
			if delay == 0:
				set_animation("idle")
		.on_turn()

func face(p):
	if (p > 0) != (n_sprites.scale.x > 0):
		n_sprites.scale.x *= -1
		n_skeleton.scale.x *= -1

func face_toward(p):
	if p != null:
		if p.x > position.x:
			face(1)
		elif p.x < position.x:
			face(-1)

func die():
	var ondie = dat.g("ondie")
	if ondie != null:
		G.cmds(ondie, self)
	G.factory.make_corpse(self, pos)
	remove()

func remove():
	if n_collider != null:
		n_collider.queue_free()
	if controller != null:
		controller.remove()
	for child in get_children():
		child.queue_free()
	.remove()
	buffs.remove()
	G.world.turn.remove(self)
