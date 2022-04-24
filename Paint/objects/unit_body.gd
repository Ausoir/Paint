extends KinematicBody2D

var parent
var vel = Vector2()
var last_col

func _physics_process(_delta):
	var _t = move_and_slide(vel)
	parent.position = global_position
	position.x = 0
	position.y = 0
	vel *= .92

func get_collider():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is KinematicBody2D and collision.collider.item_type == "unit":
			return collision.collider.get_parent()

func check_overlap():
	if get_slide_count() > 0:
		var _t = move_and_slide(Vector2.ZERO)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider is KinematicBody2D:
				var tpos = collision.collider.position
				if (tpos - position).length_squared() < G.W:
					position += Vector2(G.HW, G.HH) * (tpos - position).normalized()

func cast_col_ray(to, exc, mask=1):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, to, exc, mask)
	return result

func check_area(rad, mask=15):
	var space_state = get_world_2d().direct_space_state
	var shape = Physics2DShapeQueryParameters.new()
	var circle = CircleShape2D.new()
	circle.radius = rad
	shape.set_shape(circle)
	shape.set_collision_layer(mask)
	shape.set_transform(get_parent().transform)
	return space_state.intersect_shape(shape, 8)

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and Input.is_action_just_pressed("use"):
		G.you.on_item_click(parent)
