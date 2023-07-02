extends Node

const COLLISION_DESCRIPTION = ["interact", "sight", "unit", "projectile"]
const CARDINALS = [Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0, 0, 1)]
const GRAVITY = 14.0
const HORIZONTAL_PLANE = Plane(Vector3.UP, 0)
const V_HALF = Vector3(.5, .5, .5)
const V2_HALF = Vector3(.5, 0, .5)

var _envs = {
	"outside": preload("res://game/environment/env_outside.tscn").instantiate(),
	"cave": preload("res://game/environment/env_cave.tscn").instantiate(),
	"arcane": preload("res://game/environment/env_arcane.tscn").instantiate(),
	"murky": preload("res://game/environment/env_murky.tscn").instantiate(),
}

var _frame = 0
var _custom_script = preload("res://game/script.gd").new()
var _commands = preload("res://game/commands.gd").new()
var files = preload("res://game/player/save.gd").new()
var rng = preload("res://game/rng.gd").new()
var sfx = preload("res://game/fx/Sfx.tscn").instantiate()
var map_loader
var player_name = "Player"
var player
var you
var vars = {}
var settings = {}
var mapdata
var env
var filler_animator = AnimationPlayer.new()
var sec: int = 0
var sec_frame = false
var terrain
var late_loader
var tool
var stock
var blocks
var ui
var turn


func _ready():
	add_child(sfx)
	files.load_settings()
	files.load_mapdata()
	mapdata = files.cache_maps["camp"]


func clear():
	vars = {}
	terrain.queue_free()
	late_loader.queue_free()
	tool.queue_free()
	stock.queue_free()
	blocks.queue_free()
	ui.queue_free()
	turn.queue_free()
	map_loader.queue_free()


func manual_ready(root):
	terrain = root.get_node("Terrain")
	late_loader = root.get_node("Terrain/LateLoader")
	tool = root.get_node("Tool")
	stock = root.get_node("Stock")
	blocks = root.get_node("Blocks")
	ui = root.get_node("Player/Interface")
	turn = root.get_node("Turn")
	map_loader = root.get_node("Generator")


func set_map(p):
	vars.map = p
	mapdata = files.cache_maps.get(vars.map)
	if mapdata == null:
		print("Map ", p, " not found!")
		set_map("camp")
	else:
		var newenv = _envs[mapdata.get("env", "outside")]
		add_env.call_deferred(env, newenv)
		env = newenv


func add_env(oldenv, newenv):
	var parent = get_tree().get_root().get_node("Game")
	if oldenv != null and oldenv.get_parent() != null:
		oldenv.get_parent().remove_child(oldenv)
	parent.add_child(newenv)


func run_script(p, params):
	if p != null:
		var fn = Callable(_custom_script, p)
		if fn.is_valid():
			fn.call(params)
		else:
			print("Invalid custom script ", p)


func run_cmd(p):
	if p != null:
		_commands.run(p)


func _process(delta):
	_frame += delta
	if _frame >= 0.5:
		sec += 1
		_frame -= 0.5
		sec_frame = true
	else:
		sec_frame = false


func quit():
	print("close")
	if G.ui != null and mapdata.get("safe", false):
		files.save_player_data()
	files.save_settings()
	get_tree().quit()

