var json_cache = {}
var images_cache = {}
var sounds_cache = {}
var particles_cache = {}
var terrain_data
var unit_data
var card_data
var dialog_data

func _init():
	terrain_data = get_json_from_dir("res://assets/json/terrains.json")
	unit_data = get_json_from_dir("res://assets/json/units.json")
	card_data = get_json_from_dir("res://assets/json/cards.json")
	dialog_data = get_json_from_dir("res://assets/json/dialog.json")

func get_combo(dat):
	var r = []
	if R.r_percent(dat[1]):
		r.append(dat[0])
		if dat.size() > 2 and dat[2] == "+":
			r += get_combo(dat[3])
	elif dat.size() > 2 and dat[2] == "/":
		r += get_combo(dat[3])
	return r

func get_image(p):
	var r = images_cache.get(p)
	if r != null:
		return r
	else:
		r = load("res://assets/image/" + p + ".png")
		images_cache[p] = r
		return r

func get_sprite(p):
	var r = Sprite.new()
	r.texture = get_image(p)
	return r

func set_sprite_texture(sprite, p, autotile):
	sprite.texture = get_image(p)
	if autotile != 0:
		sprite.set_region(true)
		sprite.set_region_rect(Rect2(0, 0, 32, 32))

func get_sound(p):
	var r = sounds_cache.get(p)
	if r != null:
		return r
	else:
		r = load("res://assets/audio/" + p + ".wav")
		sounds_cache[p] = r
		return r

func get_particle(p):
	var r = particles_cache.get(p)
	if r != null:
		return r.instance()
	else:
		r = load("res://fx/particles/" + p + ".tscn")
		particles_cache[p] = r
		return r.instance()

func get_json_data(p, _cache=true):
	if _cache:
		var r = json_cache.get(p)
		if r != null:
			return r
		else:
			r = get_json_from_dir("res://assets/json/" + p + ".json")
			json_cache[p] = r
			return r
	else:
		return get_json_from_dir("res://assets/json/" + p + ".json")

func get_json_from_dir(dir):
	var data_file = File.new()
	if data_file.open(dir, File.READ) == OK:
		var data_text = data_file.get_as_text()
		data_file.close()
		var data_parse = JSON.parse(data_text)
		if data_parse.error == OK:
			return data_parse.result
		else:
			push_error("Could not parse JSON file " + dir)
	else:
		push_error("Could not load JSON file " + dir)
