extends Node

const PATH = "user://save/player.json"
const TEMPLATE_PATH = "res://save/template.json"
const PROP_PATH = "user://save/props.json"
var data


func load_data():
	return load_player_data()


func load_player_data():
	data = get_json_from_dir(PATH)
	if data == null:
		data = get_json_from_dir(TEMPLATE_PATH)
	if data != null:
		if data.seed == -1:
			data.seed = Time.get_unix_time_from_system()
		data.seed = int(data.seed)
		G.rng.set_seed(data.seed)
		G.vars = data
		G.set_map("camp")
	var u = G.stock.make_any_unit(G.player, Vector3(), G.vars.unit.name, G.vars.unit)
	u.health = G.vars.get("health", u.health)
	u.mana = G.vars.get("mana", u.mana)
	return u


func save_data():
	save_player_data()


func save_player_data():
	G.vars["health"] = G.you.health
	G.vars["mana"] = G.you.mana
	var r = G.vars.duplicate()
	var unit_data = G.you.serialize()
	r["unit"] = unit_data
	save(PATH, r)


func _save_prop_data(): #unused
	var r = []
	for i in G.stock.get_children():
		if i.get("sid") != null:
			var prop_data = i.serialize()
			r.append(prop_data)
	save(PROP_PATH, r)


func save(dir, contents):
	if FileAccess.file_exists(dir):
		var file = FileAccess.open(dir, FileAccess.WRITE)
		var json = JSON.new()
		var json_string = json.stringify(contents)
		file.store_string(json_string)
		file.close()
	else:
		push_error("Could not open file [" +dir+ "] for saving.")


func get_json_from_dir(dir):
	if FileAccess.file_exists(dir):
		var file = FileAccess.open(dir, FileAccess.READ)
		var data_text = file.get_as_text()
		file.close()
		if data_text.is_empty():
			print("JSON file empty: " + dir)
		else:
			var data_parse = JSON.parse_string(data_text)
			if data_parse != null:
				return data_parse
			else:
				print("Could not parse JSON file " + dir)
	else:
		print("Could not open JSON file " + dir)
