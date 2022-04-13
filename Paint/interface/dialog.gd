extends Control

var page_data
var host

func display(_page, _host):
	var data = G.data.dialog_data.get(_page)
	if data != null:
		display_data(data, _host)

func display_data(_data, _host):
	page_data = _data
	host = _host
	var cmd = page_data.get("cmd")
	if cmd != null:
		G.cmds(cmd, host)
	var title = page_data.get("title")
	if title != null:
		G.ui.dialog.set_tab_title(0, title)
		var text
		var req_met = true
		var req = page_data.get("req")
		if req != null:
			req_met = is_req_met(req)
		if req_met:
			text = page_data.get("true", "")
		else:
			text = page_data.get("false", "")
		get_node("Dialog/RichTextLabel").set_bbcode(text)
		show()

func is_req_met(reqs):
	for req in reqs:
		if !check_supplies(req[0], req[1]):
			return false
	return true

func check_supplies(item, amount):
	for supply in G.vars.supplies:
		if supply == item:
			amount -= 1
			if amount <= 0:
				return true
	return false

func _on_meta_clicked(meta):
	G.ui.clear()
	var opts = page_data.get("opt", [])
	if opts.size() > int(meta):
		var option = page_data.opt[int(meta)]
		var req = option.get("req")
		if req != null:
			if !is_req_met(req):
				return
		var cmd = option.get("cmd")
		if cmd != null:
			G.cmds(cmd, host)

func _on_meta_hover_started(meta):
	var opts = page_data.get("opt", [])
	if opts.size() > int(meta):
		var option = page_data.opt[int(meta)]
		var hover = option.get("hover")
		if hover != null:
			if hover[0] == "text":
				G.ui.describe("text", hover[1], hover[2])
			elif hover[0] == "item":
				var item = G.data.item_data.get(hover[1])
				if item != null:
					G.ui.describe("item", hover[1], item)

func _on_meta_hover_ended(_meta):
	G.ui.description.hide()
