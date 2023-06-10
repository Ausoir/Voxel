extends Node

const COLLISION_DESCRIPTION = ["interact", "sight", "unit", "projectile"]
const CARDINALS = [Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0, 0, 1)]
const GRAVITY = 14.0
const HORIZONTAL_PLANE = Plane(Vector3.UP, 0)
const V_HALF = Vector3(.5, .5, .5)
const V2_HALF = Vector3(.5, 0, .5)
const Map_JSON = preload("res://assets/json/maps.json")

var _envs = {
	"outside": preload("res://game/environment/env_outside.tscn").instantiate(),
	"cave": preload("res://game/environment/env_cave.tscn").instantiate(),
}

var _frame = 0
var _custom_script = preload("res://game/script.gd").new()
var files = preload("res://game/player/save.gd").new()
var rng = preload("res://game/rng.gd").new()
var sfx = preload("res://game/fx/Sfx.tscn").instantiate()
var player
var you
var vars = {}
var settings = {}
var mapdata = Map_JSON.get_data().get("camp")
var env
var filler_animator = AnimationPlayer.new()
var sec = 0
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


func clear():
	terrain.queue_free()
	late_loader.queue_free()
	tool.queue_free()
	stock.queue_free()
	blocks.queue_free()
	ui.queue_free()
	turn.queue_free()


func manual_ready(root):
	terrain = root.get_node("Terrain")
	late_loader = root.get_node("Terrain/LateLoader")
	tool = root.get_node("Tool")
	stock = root.get_node("Stock")
	blocks = root.get_node("Blocks")
	ui = root.get_node("Player/Interface")
	turn = root.get_node("Turn")


func set_map(p):
	vars.map = p
	var maps = Map_JSON.get_data()
	mapdata = maps.get(vars.map)
	if mapdata == null:
		print("Map ", p, " not found!")
		set_map("camp")
	else:
		var parent = get_tree().get_root().get_node("Game")
		if env != null and env.get_parent() == parent:
			parent.remove_child.call_deferred(env)
		env = _envs[mapdata.get("env", "outside")]
		parent.add_child.call_deferred(env)


func run_script(p, params):
	if p != null:
		var fn = Callable(_custom_script, p)
		if fn.is_valid():
			fn.call(params)
		else:
			print("Invalid custom script ", p)


func _process(delta):
	_frame += delta
	if _frame >= 0.5:
		sec += 1
		_frame -= 0.5
		sec_frame = true
	else:
		sec_frame = false
