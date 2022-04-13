extends Control

onready var title = $Control/Title
onready var content = $Control/Content

func on_display(header, desc):
	rect_size.y = 32
	title.set_text(header.capitalize())
	content.set_bbcode(desc)
	show()
	rect_global_position = get_global_mouse_position()
	rect_global_position.x = min(rect_global_position.x, G.ui.screen_size.x - rect_size.x)
	rect_global_position.y = min(rect_global_position.y, G.ui.screen_size.y - rect_size.y)

func array_to_string(arr):
	var r = ""
	var prefix = ""
	for i in arr:
		r += prefix + i.capitalize()
		prefix = ", "
	return r

func display(type, header, subject):
	if type == "text":
		on_display(header, subject)
	elif type == "card":
		display_card(header)
	elif type == "unit":
		display_unit(header)

func display_card(card):
	var data = G.data.card_data.get(card)
	var desc = ""
	if data != null:
		var bash = data.get("bash", 0)
		if bash != 0:
			desc += "[color=#C84]Bash Damage: "+ str(bash) +"[/color]\n"
		var cut = data.get("cut", 0)
		if cut != 0:
			desc += "[color=#C48]Cut Damage: "+ str(cut) +"[/color]\n"
		var skills = data.get("skills", [])
		if !skills.empty():
			desc += "[color=#56A]Skills: "+ array_to_string(skills) +"[/color]\n"
		var block = data.get("block")
		if block != null:
			desc += "[color=#CC3]"+ str(block) +" Block[/color]\n"
		desc += data.get("desc", "")
		on_display(card, desc)

func display_unit(card):
	var data = G.data.unit_data.get(card)
	if data != null:
		var desc = "[b]Health: [color=red]20[/color][/b]\n"
		desc += data.get("desc", "")
		on_display(card, desc)
