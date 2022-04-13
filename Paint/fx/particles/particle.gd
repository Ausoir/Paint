extends Particles2D

export var duration: float = 1.0

func add():
	G.world.others.add_child(self)
	set_emitting(true)

func _process(delta):
	duration -= delta
	if duration < 0:
		get_parent().remove_child(self)
		queue_free()

func change_text(p):
	$Label/Control/Label.text = str(p)
