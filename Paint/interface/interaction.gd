var tgt
var ignore = false
var stop = false

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

func run_command(p, host):
	var args = p
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
	elif command == "make":
		tgt = G.factory.make_unit(args[1], args[2])
	elif command == "sfx":
		G.sfx.play(args[1])
	elif command == "block":
		host.change("block", args[1] + host.defense)
	elif command == "defense" or command == "attack":
		host.change(command, args[1])
	elif command == "gfx":
		tgt.gfx(args[1])
	elif tgt.health > 0:
		if command == "burn":
			tgt.damage("true", args[1])
		elif command == "cut" or command == "bash":
			tgt.damage(command, args[1] + host.attack)
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
