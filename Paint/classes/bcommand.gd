var tgt
var ignore = false
var stop = false
var battle

func run(args, host, ptgt):
	if args != null:
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

func replace_dats(v):
	var t
	if "~" in v:
		var split = v.split("~")
		t = R.ir(int(split[0]), int(split[1]))
	elif "," in v:
		t = R.r_arr(v.split(","))
	elif v == "t":
		t = tgt
	return t

func run_command(p, host):
	var args = replace_vars(host, p)
	var command = args[0]
	if command[0] == "?":
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
	elif command == "cmd":
		G.cmds(args[1], host.unit)
	elif command == "sfx":
		G.sfx.play(args[1])
	elif command == "gfx":
		tgt.gfx(args[1])
	elif command == "cycle":
		battle.cycle()
	elif command == "weapon":
		if host.unit == G.you.unit:
			battle.set_weapon(args[1])
	else:
		var subject = args[1]
		if subject.health > 0:
			if command == "burn":
				subject.damage("true", args[2], host)
			elif command == "cut" or command == "bash":
				subject.damage(command, args[2] + host.attack, host)
			elif command == "block":
				subject.change("block", args[2] + host.defense)
			elif command == "defense" or command == "attack":
				subject.change(command, args[2])
	return tgt

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
						elif arg[2] == "a":
							var adjs = unit.pos.get_available_adjacents("0011")
							var adj = R.r_arr(adjs)
							if adj == null:
								r.append(unit.pos)
							else:
								r.append(adj)
						elif arg[2] == "c":
							r.append(unit.controller)
						elif arg[2] == "h":
							r.append(unit.host)
					else:
						r.append(unit)
					continue
				else:
					arg = G.replace_vars(arg, funcref(self, "replace_dats"))
		r.append(arg)
	return r
