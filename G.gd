extends Node

signal post_ready

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

var rng = preload("res://game/rng.gd").new()
var player
var you
var noisemap
var vars
var mapdata = Map_JSON.get_data().get("town")
var _env
@onready var terrain = get_node("/root/Game/Terrain")
@onready var late_loader = get_node("/root/Game/Terrain/LateLoader")
@onready var tool = get_node("/root/Game/Tool")
@onready var stock = get_node("/root/Game/Stock")
@onready var blocks = get_node("/root/Game/Blocks")
@onready var ui = get_node("/root/Game/Player/Interface")
@onready var save = get_node("/root/Game/Player/Save")
@onready var turn = get_node("/root/Game/Turn")
@onready var sfx = get_node("/root/Game/Sfx")


func _ready():
	emit_signal("post_ready")
	var noise = FastNoiseLite.new()
	noise.seed = rng.rf()
	noisemap = noise.get_image(128, 128)


func set_map(p):
	vars.map = p
	var maps = Map_JSON.get_data()
	mapdata = maps.get(vars.map)
	var game = get_node("/root/Game")
	if _env != null:
		game.remove_child(_env)
	_env = _envs[mapdata.get("env", "outside")]
	game.add_child.call_deferred(_env)


func get_biome(_pos: Vector3):
	var x = int(_pos.x) % 128
	var z = int(_pos.z) % 128
	return G.noisemap.get_pixel(x, z).r
