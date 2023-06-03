extends Node

const PATH = "user://save/player.json"
const TEMPLATE_PATH = "res://save/template.json"
const PROP_PATH = "user://save/props.json"
var data


func load_data():
#	load_prop_data()
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
		G.set_map("town")
		G.player.proficiency.unserialize(data.proficiency)
	var u = G.stock.make_any(G.player, Vector3(), G.vars.name, G.vars.unit)
	return u


func load_prop_data():
	data = get_json_from_dir(PROP_PATH)
	if data != null:
		for i in data:
			var scene = load("res://" + i.name + ".tscn").instantiate()
			G.stock.add_child(scene)
			scene.position = Vector3(i.position[0], i.position[1], i.position[2])


func save_data():
	save_player_data()


func save_player_data():
	var r = {}
	for key in G.vars.keys():
		r[key] = G.vars[key]
	data = G.you.serialize()
	for key in data.keys():
		r[key] = data[key]
	r["proficiency"] = G.player.proficiency.serialize()
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
