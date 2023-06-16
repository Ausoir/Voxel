extends Node

const PLAYER_PATH = "user://player.json"
const SCORE_PATH = "user://highscores.json"
const TEMPLATE_PLAYER_PATH = "res://save/template.json"
const SETTINGS_PATH = "user://settings.json"
var data


func load_player_data():
	var file_loaded = true
	data = get_json_from_dir(PLAYER_PATH)
	if data == null:
		file_loaded = false
		data = get_json_from_dir(TEMPLATE_PLAYER_PATH)
	if data != null:
		if data.seed == -1:
			data.seed = Time.get_unix_time_from_system()
		data.seed = int(data.seed)
		G.rng.set_seed(data.seed)
		G.vars.merge(data, true)
		G.set_map(G.vars.map)
	var u = G.stock.make_unit(Vector3(), G.vars.name, G.player, G.vars.unit)
	u.health = min(G.vars.health, u.data.health)
	u.mana = min(G.vars.mana, u.data.mana)
	if file_loaded:
		u.buffs.add("stunted", -1)
	return u


func save_player_data():
	G.you.buffs.pre_save()
	G.vars["name"] = G.you.sid
	G.vars["health"] = G.you.health
	G.vars["mana"] = G.you.mana
	var r = G.vars.duplicate()
	var unit_data = G.you.serialize()
	r["unit"] = unit_data
	save(PLAYER_PATH, r)


func clear_player_data():
	if FileAccess.file_exists(PLAYER_PATH):
		var file = FileAccess.open(PLAYER_PATH, FileAccess.WRITE)
		file.store_string("")
		file.close()
	else:
		push_error("Could not open file [" +PLAYER_PATH+ "] for saving.")


func save_highscore(record):
	var r = []
	data = get_json_from_dir(SCORE_PATH)
	if data != null:
		r = data
	r.append(record)
	save(SCORE_PATH, r)


func load_settings():
	var settings = get_json_from_dir(SETTINGS_PATH)
	if settings != null:
		G.settings = settings
		if G.settings.get("fullscreen", true):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func save_settings():
	save(SETTINGS_PATH, G.settings)


func save(dir, contents):
	var file = FileAccess.open(dir, FileAccess.WRITE)
	var json = JSON.new()
	var json_string = json.stringify(contents)
	file.store_string(json_string)
	file.close()


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
