extends Node

const Item = preload("res://game/item/prop_item.tscn")
const RANK_COLOR = ["DIM_GRAY", "GRAY", "DARK_GREEN", "BLUE", "PURPLE", "RED", "ORANGE"]

var sid := ""
var sprite : Texture2D
var model : Mesh
var model2
var size = 1
var part
var data = {}
var callback = Callable(self, "use_callback")
var _options = []


func use(_user: Node3D):
	_user.animator.play("swing_down")


func use2(_user: Node3D):
	return false


func use_callback(_user: Node3D):
	pass


func get_pointed_block(_user: Node3D, col=3):
	var origin = _user.get_head()
	var hit = G.tool.raycast(origin, _user.forward, 1.3, col)
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
	if "health" in data:
		r += str("\nProvides Health: ", data.health)
	if "mana" in data:
		r += str("\nProvides Mana: ", data.mana)
	if "armor" in data:
		r += str("\nProvides Armor: ", data.armor)
	if "speed" in data:
		r += str("\nProvides Speed: ", data.speed)
	if "damage" in data:
		r += str("\nDamage: ", data.damage)
	if "spread" in data:
		r += str("\nSpread: ", data.spread)
	if "light" in data:
		r += str("\nLight intensity: ", data.light)
	if "light spread" in data:
		r += str("\nLight spread: ", data["light spread"])
	for i in _options:
		r += str("\n", i)
	return str("[b]", get_display_name().capitalize(), "[/b]\n", r)


func on_held(_user):
	pass


func on_unheld(_user):
	pass


func on_wear(_user):
	pass


func on_unwear(_user):
	pass


func on_held_tick(_user: Node3D):
	pass


func imbue(sd):
	seed(sd)
	var candids = ["size", "essence"]
	if "speed" in data:
		candids.append("speed")
	if "damage" in data:
		candids.append("damage")
	if "spread" in data:
		candids.append("spread")
	if "health" in data:
		candids.append("health")
	if "mana" in data:
		candids.append("mana")
	if "armor" in data:
		candids.append("armor")
	if "light" in data:
		candids.append("light")
	if "light spread" in data:
		candids.append("light spread")
	candids.shuffle()
	var rnd = randf()
	if rnd < .9:
		imbue_option(candids.pop_front(), randi_range(1, 2))
		if rnd < .8:
			imbue_option(candids.pop_front(), randi_range(1, 5))
			if rnd < .7:
				var ess = G.stock.make_group("#ego", randf())
				if ess == null or randf() < .1:
					imbue_option(candids.pop_front(), randi_range(5, 10))
				else:
					data["essence"] = ess
					data.value += 300
					_options.append(str("Ego: ", ess.capitalize()))


func imbue_option(opt, rank):
	match (opt):
		"size":
			if rank == 1:
				data["size"] = .4
				data.value = int(data.value * .8)
				_options.append("Reduced size")
			else:
				data["size"] = .4 + rank*.1
				data.value = int(data.value * (1 + rank*.1))
				_attach_option_description("Increased size", rank)
		"damage":
			data.damage += rank
			data.value = int(data.value * (1 + rank*.1))
			_attach_option_description("Increased damage", rank)
		"speed":
			data.speed += rank * .1
			data.value = int(data.value * (1 + rank*.1))
			_attach_option_description("Increased speed", rank)
		"spread":
			data.spread = data.spread / (rank+1)
			data.value = int(data.value * (1 + rank*.03))
			_attach_option_description("Reduced spread", rank)
		"health":
			data.health += rank * 5
			data.value = int(data.value * (1 + rank*.15))
			_attach_option_description("Increased health", rank)
		"mana":
			data.mana += rank
			data.value = int(data.value * (1 + rank*.1))
			_attach_option_description("Increased mana", rank)
		"armor":
			data.armor += int(rank / 2)
			data.value = int(data.value * (1 + rank*.2))
			_attach_option_description("Increased armor", rank)
		"light":
			data.light += rank * 5
			data.value += rank * 5
			_attach_option_description("Increased light", rank)
		"light spread":
			data["light spread"] += rank * 10
			data.value += rank * 5
			_attach_option_description("Increased light spread", rank)


func _attach_option_description(desc, rank):
	var txt = str(desc, ": [color=", RANK_COLOR[min(6, rank-1)], "]Rank ",rank,"[/color]")
	_options.append(txt)

