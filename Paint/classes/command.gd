var tgt
var ignore = false
var stop = false
var onstop = null

func run(args, host, ptgt):
	if ptgt != null:
		tgt = ptgt
	for arg in args:
		if stop:
			stop = false
			return tgt
		elif ignore:
			ignore = false
		else:
			tgt = run_command(arg, host)
	return tgt

func replace_dats(host, arg):
	var last = arg.find("}")
	if last != -1:
		var r = ""
		var v = ""
		var on = false
		var once = last == len(arg) - 1 and arg[0] == "{"
		for i in arg:
			if i == "{":
				on = true
			elif i == "}":
				var t
				if "~" in v:
					var split = v.split("~")
					t = R.ir(int(split[0]), int(split[1]))
				elif "," in v:
					t = R.r_arr(v.split(","))
				elif v == "t":
					t = tgt
				else:
					t = host.dat.g(v,"")
				if once:
					return t
				r += str(t)
				v = ""
				on = false
			elif on:
				v += i
			else:
				r += i
		return r
	return arg

func replace_vars(host, _args):
	var r = []
	for arg in _args:
		if arg is Array:
			arg = replace_vars(host, arg)
		elif arg is String:
			var s = len(arg)
			if s >= 2:
				if arg[0] == "$":
					var unit
					if arg[1] == "t":
						unit = tgt
					elif arg[1] == "h":
						unit = host
					elif arg[1] == "$":
						r.append(arg.substr(1))
						continue
					elif arg[1] == "p":
						unit = G.you.unit
					if unit == null:
						r.append(null)
						continue
					if s >= 3:
						if arg[2] == "p":
							r.append(unit.pos)
						elif arg[2] == "v":
							r.append(unit.position)
						elif arg[2] == "c":
							r.append(unit.controller)
						elif arg[2] == "a":
							var adjs = unit.pos.get_available_adjacents("0011")
							var adj = R.r_arr(adjs)
							if adj == null:
								r.append(unit.pos)
							else:
								r.append(adj)
					else:
						r.append(unit)
					continue
				else:
					arg = replace_dats(host, arg)
		r.append(arg)
	return r

func run_command(p, host):
	var args = replace_vars(host, p)
	var command = args[0]
	if command[0] == "=":
		if command[1] == "t":
			return args[1]
		elif command[1] == "h":
			host = args[1]
		elif command[1] == "+":
			return args[1] + args[2]
		elif command == "=items":
			return G.world.get_items_by_name(args[1])
	elif command[0] == "?":
		if command == "?=":
			stop = args[1] != args[2]
		elif command == "?>":
			stop = args[1] <= args[2]
		elif command == "?>=":
			stop = args[1] < args[2]
	elif command[0] == "!":
		if command == "!stop":
			stop = !stop
		elif command == "!ignore":
			ignore = !ignore
	elif command[0] == "^":
		return run_operation(command, args, G.vars, tgt)
	elif command[0] == "&":
		return run_operation(command, args, G.temp, tgt)
	elif command == "onstop":
		onstop = args[1]
	elif command == "make":
		tgt = G.factory.make_unit(args[1], args[2])
	elif command == "menu":
		if args[1] == "msg":
			G.msg(args[2])
		elif args[1] == "menu":
			G.ui.display_menu()
		elif args[1] == "battle":
			G.ui.display_battle(args[2])
		elif args[1] == "dialog":
			G.ui.display_dialog(args[2], host)
		else:
			G.ui.clear()
	elif command == "gfx":
		if args[1] == "label":
			if args.size() > 5:
				G.display_damage(args[2], args[3], args[4], args[5], args[6], args[7])
			else:
				G.display_damage(args[2], args[3], args[4])
		elif args[1] == "$":
			if args[2] > 0:
				G.display_damage("+$"+str(args[2]), args[3], "#3D3", 1, 100, 50)
			elif args[2] < 0:
				G.display_damage("-$"+str(-args[2]), args[3], "#D33", 1, 100, 50)
		elif args[1] == "particle":
			G.make_particle(args[2], args[3])
	elif command == "sfx":
		G.sfx.play(args[1], args[2])
	elif command == "fade":
		G.ui.fadein()
	elif command == "cast":
		G.influence.do(args[1], args[2], args[3])
	return tgt

func get_arg(args, idx, default=null):
	if args.size() > idx:
		return args[idx]
	return default

func run_operation(command, args, dict, _tgt):
	if command.length() == 1:
		return dict.get(args[1])
	elif command[1] == "=":
		dict[args[1]] = args[2]
	elif args[1] in dict:
		if command[1] == "+":
			dict[args[1]] += args[2]
		elif command[1] == "^":
			dict[args[1]].append(args[2])
		elif command[1] == "v":
			dict[args[1]].erase(args[2])
		elif command[1] == "*" and command[2] == "=":
			dict[args[1]] *= args[2]
	return _tgt
