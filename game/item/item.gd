extends Node

const Item = preload("res://game/item/prop_item.tscn")
const ITEM_RANK_COLOR = ["DIM_GRAY", "WHITE", "GREEN", "ORANGE", "MAGENTA"]
const OPTION_RANK_COLOR = ["DIM_GRAY", "GRAY", "DARK_GREEN", "BLUE", "PURPLE", "RED", "ORANGE"]
const INFLICTS = ["slow", "poison", "sleep", "down", "corrosion", "snare", "daze", "flight"]

var sid := ""
var sprite : Texture2D
var model : Mesh
var model2
var size = 1
var part
var data = {}
var callback = Callable(self, "use_callback")
var rank = 1
var _options = []


func use(_user: Node3D):
	_user.animator.play("swing_down")


func use2(_user: Node3D):
	return false


func use_callback(_user: Node3D):
	pass


func get_pointed_block(_user: Node3D, col=3):
	var origin = _user.get_center()
	var hit = G.tool.raycast(origin, _user.forward, 1.5, col)
	return hit


func get_user_block(_user: Node3D):
	var origin = _user.get_global_transform().origin
	var hit = G.tool.raycast(origin, Vector3(0, -99, 0), 10, 8)
	return hit


func drop(_user):
	var user_pos = get_user_block(_user)
	if user_pos != null:
		drop_at(user_pos.previous_position)


func drop_at(_pos):
	var floor_item = to_prop_item()
	floor_item.position = Vector3(_pos) + G.V2_HALF
	G.stock.add_child(floor_item)
	floor_item.on_drop()
	floor_item.turn_random()


func to_prop_item():
	var floor_item = Item.instantiate()
	floor_item.set_item(self)
	return floor_item


func get_display_name():
	return sid.split(":")[0]


func get_seed():
	var split = sid.split(":")
	if split.size() > 1:
		return int(split[1])
	return -1


func get_description():
	var r = str("[i]", data.get("desc", ""), "[/i]")
	if "weight" in data:
		r += str("\nWeight: ", data.weight)
	if data.get("health", 0) != 0:
		r += str("\nProvides Health: ", data.health)
	if data.get("mana", 0) != 0:
		r += str("\nProvides Mana: ", data.mana)
	if data.get("defense", 0) != 0:
		r += str("\nProvides Defense: ", data.defense)
	if "space" in data:
		r += str("\nPockets: ", data.space)
	if "speed" in data:
		r += str("\nSpeed: ", data.speed)
	if "damage" in data:
		r += str("\nDamage: ", data.damage)
	if "backstab" in data:
		r += str("\nBackstab Damage: ", data.backstab)
	if "spread" in data:
		r += str("\nSpread: ", data.spread)
	if "manause" in data:
		r += str("\nMana Use: ", data.manause)
	if "radius" in data:
		r += str("\nEffect Radius: ", data.radius)
	if "noise" in data:
		r += str("\nNoise: ", data.noise)
	if "power" in data:
		r += str("\nProjectile Speed: ", data.power)
	if "light" in data:
		r += str("\nLight intensity: ", data.light)
	if "light spread" in data:
		r += str("\nLight spread: ", data["light spread"])
	for i in _options:
		r += str("\n", i)
	if "req" in data:
		r += str("\n[color=DARK_RED]Requires ", data.req[0].capitalize(), " Level ", data.req[1], "[/color]")
	var color = ITEM_RANK_COLOR[clamp(rank, 0, 4)]
	var title = str("[color=",color,"][b]",get_display_name().capitalize(),"[/b][/color]")
	return str(title, "\n", r)


func on_held(_user):
	_user.procedure.speed -= data.get("weight", 1)*.05


func on_unheld(_user):
	_user.procedure.speed += data.get("weight", 1)*.05


func on_wear(_user):
	pass


func on_unwear(_user):
	pass


func on_held_tick(_user: Node3D):
	pass


func imbue(sd):
	seed(sd)
	var candids = ["weight+", "weight-", "size+", "size-"]
	if "speed" in data:
		candids.append("speed")
	if "damage" in data:
		candids.append("damage")
		candids.append("damage*")
		candids.append("inflict")
	if "backstab" in data:
		candids.append("backstab")
	if "spread" in data:
		candids.append("spread")
	if "health" in data:
		candids.append("health")
	if "mana" in data:
		candids.append("mana")
	if "defense" in data:
		candids.append("defense")
	if "manause" in data:
		candids.append("manause")
	if "power" in data:
		candids.append("power")
	if "noise" in data:
		candids.append("noise")
	if "space" in data:
		candids.append("space-")
		candids.append("space+")
	if "radius" in data:
		candids.append("radius")
	if "light" in data:
		candids.append("light")
	if "light spread" in data:
		candids.append("light spread")
	candids.shuffle()
	var rnd = randf()
	if rnd < .4:
		rank += 1
		imbue_option(candids.pop_front(), randi_range(1, 2))
		if rnd < .15:
			rank += 1
			candids.append("essence")
			candids.shuffle()
			imbue_option(candids.pop_front(), randi_range(1, 5))
			if rnd < .02:
				rank += 1
				imbue_option(candids.pop_front(), randi_range(5, 10))
	if rank == 0:
		data.value = int(data.value / 2)


func imbue_option(opt, lvl):
	match (opt):
		"essence":
			var ess = G.rng.pick(G.stock.ego_list)
			data["essence"] = ess
			data.value += 100
			_options.append(str("[color=ORANGE]Ego: ", ess.capitalize(), "[/color]"))
		"size+":
			data["size"] = .5 + lvl*.1
			data.value = int(data.value * (1 + lvl*.1))
			_attach_option_description("Increased Size", lvl)
		"size-":
			rank -= 1
			data["size"] = max(.1, .5 - lvl*.05)
			data.value = int(data.value * (1 - lvl*.05))
			_attach_option_description("Reduced Size", lvl)
		"weight+":
			rank -= 2
			data["weight"] = data.get("weight", 1) + lvl
			data.value = int(data.value * (1 - lvl*.15))
			_attach_option_description("Increased Weight", lvl)
		"weight-":
			data["weight"] = data.get("weight", 1) - lvl
			data.value = int(data.value * (1 + lvl*.2))
			_attach_option_description("Decreased Weight", lvl)
		"space-":
			rank -= 2
			lvl = int(lvl/5) + 1
			data["space"] = data.get("space", 0) - lvl
			data.value = int(data.value * (1 - lvl*.1))
			_attach_option_description("Less Pockets", lvl)
		"space+":
			lvl = int(lvl/5) + 1
			data["space"] = data.get("space", 0) + lvl
			data.value = int(data.value * (1 + lvl*.3))
			_attach_option_description("More Pockets", lvl)
		"damage":
			data.damage += lvl
			data.value += lvl * 30
			_attach_option_description("Added Damage", lvl)
		"damage*":
			data.damage += int(data.damage * lvl*.2)
			data.value += lvl * 30
			_attach_option_description("Increased Damage", lvl)
		"inflict":
			var inflict = G.rng.pick(INFLICTS)
			data["inflict"] = data.get("inflict", []) + [[inflict, lvl]]
			data.value += lvl * 30
			_attach_option_description(str("Inflict <",inflict.capitalize(),">"), lvl)
		"backstab":
			data.backstab += lvl * 2
			data.value += lvl * 15
			_attach_option_description("Enhanced Backstab", lvl)
		"speed":
			data.speed += lvl * .1
			data.value = int(data.value * (1 + lvl*.2))
			_attach_option_description("Increased Speed", lvl)
		"spread":
			data.spread = data.spread / (1 + lvl*.5)
			data.spread = snapped(data.spread, 0.01)
			data.value = int(data.value * (1 + lvl*.2))
			_attach_option_description("Increased Accuracy", lvl)
		"health":
			data.health += lvl * 5
			data.value = int(data.value * (1 + lvl*.2))
			_attach_option_description("Increased Health", lvl)
		"mana":
			data.mana += lvl
			data.value = int(data.value * (1 + lvl*.1))
			_attach_option_description("Increased Mana", lvl)
		"defense":
			lvl = int(lvl/2) + 1
			data.defense += lvl
			data.value = int(data.value * (1 + lvl*.25))
			_attach_option_description("Increased Defense", lvl)
		"manause":
			rank -= 2
			data.manause += lvl
			data.value = int(data.value * (1 - lvl*.25))
			_attach_option_description("Mana Inefficiency", lvl)
		"noise":
			data.noise = max(0, data.noise - lvl)
			data.value = int(data.value * (1 + lvl*.1))
			_attach_option_description("Reduced Noise", lvl)
		"power":
			data.power += lvl * 5
			data.value = int(data.value * (1 + lvl*.05))
			_attach_option_description("Projectile Speed", lvl)
		"radius":
			data.radius += lvl * .5
			data.value = int(data.value * (1 + lvl*.2))
			_attach_option_description("Area of Effect", lvl)
		"light":
			data.light += lvl * 5
			data.value += lvl * 5
			_attach_option_description("Increased Light", lvl)
		"light spread":
			data["light spread"] += lvl * 10
			data.value += lvl * 5
			_attach_option_description("Increased Light Spread", lvl)
	data.value = max(0, data.value)


func _attach_option_description(desc, lvl):
	var txt = str(desc, ": [color=", OPTION_RANK_COLOR[min(6, lvl-1)], "]Rank ",lvl,"[/color]")
	_options.append(txt)

